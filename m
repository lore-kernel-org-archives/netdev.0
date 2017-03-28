From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 00/15] cover letter
Date: Tue, 28 Mar 2017 16:26:17 +0300
Message-ID: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47609 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932175AbdC1N0w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:26:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Overview
========
A kernel TLS Tx only socket option for TCP sockets.
Similarly to the kernel TLS socket(https://lwn.net/Articles/665602),
only symmetric crypto is done in the kernel, as well as TLS record framing.
The handshake remains in userspace, and the negotiated cipher keys/iv are provided to the TCP socket.

Today, userspace TLS must perform 2 passes over the data. First, it has to encrypt the data. Second, the data is copied to the TCP socket in the kernel.
Kernel TLS avoids one pass over the data by encrypting the data from userspace pages into kernelspace buffers.

Non application-data TLS records must be encrypted using the latest crypto state available in the kernel. It is possible to get the crypto context from the kernel and encrypt such recrods in user-space. But we choose to encrypt such TLS records in the kernel by setting the MSG_OOB flag and providing the record type with the data.

TLS Tx crypto offload is a new feature of network devices. It enables the kernel TLS socket to skip encryption and authentication operations on the transmit side of the data path, delegating those to the NIC. In turn, the NIC encrypts packets that belong to an offloaded TLS socket on the fly. The NIC does not modify any packet headers. It expects to receive fully framed TCP packets with TLS records as payload. The NIC replaces plaintext with ciphertext and fills the authentication tag. The NIC does not hold any state beyond the context needed to encrypt the next expected packet, i.e. expected TCP sequence number and crypto state.

There are 2 flows for TLS Tx offload, a fast path and a slow path.
Fast path: packet matches the expected TCP sequence number in the context.
Slow path: packet does not match the expected TCP sequence number in the context. For example: TCP retransmissions. For a packet in the slow path, we need to resynchronize the crypto context of the NIC by providing the TLS record data for that packet before it could be encrypted and transmitted by the NIC.

Motivation
==========
1) Performance: The CPU overhead of encryption in the data path is high, at least 4x for netperf over TLS between 2 machines connected back-to-back.
Our single stream performance tests show that using crypto offload for TLS sockets achieves the same throughput as plain TCP traffic while increasing CPU utilization by only
 x1.4.

2) Flexibility: The protocol stack is implemented entirely on the host CPU.
Compared to solutions based on TCP offload, this approach offloads only encryption. Keeping memory management, congestion control, etc. in the host CPU.

Notes
=====
1) New paths:
    o net/tls - TLS layer in kernel
    o drivers/net/ethernet/mellanox/accelerator/* - NIC driver support, currently implemented as seperated modules.
      In the future this code will go into the mlx5 driver. We attached to this patch only the module that integrated with TLS layer.
      The complete NIC sample driver is available at https://github.com/Mellanox/tls-offload/tree/tx_rfc_v5

2) We implemented support for this API in OpenSSL 1.1.0, the code is available at https://github.com/Mellanox/tls-openssl/tree/master

3) TLS crypto offload was presented during netdevconf1.2, more details could be found in the presentation and paper:
   https://netdevconf.org/1.2/session.html?boris-pismenny

4) These RFC patches are based on kernel 4.9-rc7.

Aviad Yehezkel (5):
  tcp: export do_tcp_sendpages function
  tcp: export tcp_rate_check_app_limited function
  tcp: Add TLS socket options for TCP sockets
  tls: tls offload support
  mlx/tls: Enable MLX5_CORE_QP_SIM mode for tls

Dave Watson (2):
  crypto: Add gcm template for rfc5288
  crypto: rfc5288 aesni optimized intel routines

Ilya Lesokhin (8):
  tcp: Add clean acked data hook
  net: Add TLS offload netdevice and socket support
  mlx/mlx5_core: Allow sending multiple packets
  mlx/tls: Hardware interface
  mlx/tls: Sysfs configuration interface Configure the driver/hardware
    interface via sysfs.
  mlx/tls: Add mlx_accel offload driver for TLS
  mlx/tls: TLS offload driver Add the main module entrypoints and tie
    the module into the build system
  net/tls: Add software offload

 MAINTAINERS                                        |  14 +
 arch/x86/crypto/aesni-intel_asm.S                  |   6 +
 arch/x86/crypto/aesni-intel_avx-x86_64.S           |   4 +
 arch/x86/crypto/aesni-intel_glue.c                 | 105 ++-
 crypto/gcm.c                                       | 122 ++++
 crypto/tcrypt.c                                    |  14 +-
 crypto/testmgr.c                                   |  16 +
 crypto/testmgr.h                                   |  47 ++
 drivers/net/ethernet/mellanox/Kconfig              |   1 +
 drivers/net/ethernet/mellanox/Makefile             |   1 +
 .../net/ethernet/mellanox/accelerator/tls/Kconfig  |  11 +
 .../net/ethernet/mellanox/accelerator/tls/Makefile |   4 +
 .../net/ethernet/mellanox/accelerator/tls/tls.c    | 658 +++++++++++++++++++
 .../net/ethernet/mellanox/accelerator/tls/tls.h    | 100 +++
 .../ethernet/mellanox/accelerator/tls/tls_cmds.h   | 112 ++++
 .../net/ethernet/mellanox/accelerator/tls/tls_hw.c | 429 ++++++++++++
 .../net/ethernet/mellanox/accelerator/tls/tls_hw.h |  49 ++
 .../ethernet/mellanox/accelerator/tls/tls_main.c   |  77 +++
 .../ethernet/mellanox/accelerator/tls/tls_sysfs.c  | 196 ++++++
 .../ethernet/mellanox/accelerator/tls/tls_sysfs.h  |  47 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  11 +-
 include/linux/netdevice.h                          |  23 +
 include/net/inet_connection_sock.h                 |   2 +
 include/net/tcp.h                                  |   2 +
 include/net/tls.h                                  | 228 +++++++
 include/uapi/linux/Kbuild                          |   1 +
 include/uapi/linux/tcp.h                           |   2 +
 include/uapi/linux/tls.h                           |  84 +++
 net/Kconfig                                        |   1 +
 net/Makefile                                       |   1 +
 net/ipv4/tcp.c                                     |  37 +-
 net/ipv4/tcp_input.c                               |   3 +
 net/ipv4/tcp_rate.c                                |   1 +
 net/tls/Kconfig                                    |  12 +
 net/tls/Makefile                                   |   7 +
 net/tls/tls_device.c                               | 594 +++++++++++++++++
 net/tls/tls_main.c                                 | 352 ++++++++++
 net/tls/tls_sw.c                                   | 729 +++++++++++++++++++++
 38 files changed, 4078 insertions(+), 25 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls.c
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls.h
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls_cmds.h
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls_hw.c
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls_hw.h
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls_main.c
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h
 create mode 100644 include/net/tls.h
 create mode 100644 include/uapi/linux/tls.h
 create mode 100644 net/tls/Kconfig
 create mode 100644 net/tls/Makefile
 create mode 100644 net/tls/tls_device.c
 create mode 100644 net/tls/tls_main.c
 create mode 100644 net/tls/tls_sw.c

-- 
2.7.4
