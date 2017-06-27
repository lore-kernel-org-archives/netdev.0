From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/16] Mellanox, mlx5 Innova IPsec offload
Date: Tue, 27 Jun 2017 17:28:40 +0300
Message-ID: <20170627142856.9448-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50356 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752759AbdF0OaL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 10:30:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Ilan provides the support for IPsec XFRM offload
in mlx5 drivers for Innova devices.

For more detalis please see tag log from Ilan below.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 593814d1beae8ad91be6c90f95764e09fc7ca236:

  net/mlx4: fix spelling mistake: "coalesing" -> "coalescing" (2017-06-26 23:18:29 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-06-27

for you to fetch changes up to 164f16f7021406795729916e100c7edd53ae954f:

  net/mlx5e: IPSec, Add IPSec ethtool stats (2017-06-27 16:36:48 +0300)

----------------------------------------------------------------
mlx5-updates-2017-06-27 (Innova IPsec offload support)

This patchset adds support for Innova IPSec network interface card.

About Innova device:
--------------------
Innova is a network card with a ConnectX chip and an FPGA chip as a
 bump-on-the-wire.

               Internal
+----------+   Link       +-----------------+
|          +--------------+      FPGA       |  +------+
| ConnectX |              |  Shell          +--+ QSFP |
|          +--------------+    +-------+    |  | Port |
+----------+      I2C     |    |  SBU  |    |  +------+
                          |    +-------+    |
                          +--+----------+---+
                             |          |
                          +--+--+   +---+---+
                          | DDR |   | Flash |
                          +-----+   +-------+

The FPGA synthesized logic is loaded from dedicated flash storage and has
 access to its own dedicated DDR RAM.
The ConnectX chip firmware programs the FPGA by accessing its configuration
space over either the slow internal I2C link or the high-speed internal link.

The FPGA logic is divided into a "Shell" and a "Sandbox Unit" (SBU).
mlx5_core driver (with CONFIG_MLX5_FPGA) handles all shell functionality,
while other components may handle the various SBU functionalities.

The driver opens high-speed reliable communication channels with the shell and
the SBU over the internal link.
These channels may be used for high-bandwidth configuration or for SBU-specific
out-of-band data paths.

About Innova IPSec device:
--------------------------
Innova IPSec is a network card that allows offloading IPSec cryptography operations
from the host CPU to the NIC. It is an Innova card with an IPSec SBU.
The hardware keeps the database of IPSec Security Associations (SADB) in the FPGA's
DDR memory.

               Internal
+----------+   Link       +-----------------+
|          +--------------+      FPGA       |  +------+
| ConnectX |              |  Shell          +--+ QSFP |
|          +--------------+    +-------+    |  | Port |
+----------+ Internal I2C |    | IPSec |    |  +------+
                          |    |  SBU  |    |
                          |    +-------+    |
                          +--+----------+---+
                             |          |
                          +--+--+   +---+---+
                          | DDR |   |       |
                          |     |   | Flash |
                          |SADB |   |       |
                          +-----+   +-------+

Modes and ciphers:
Currently the following modes and ciphers are supported:
IPv4 and IPv6
ESP tunnel and transport modes
AES 128 and 256 bit encryption, with GCM authentication (RFC4106)

IV is generated using seqiv, in sync with Linux's geniv.

More modes and ciphers may be added later.

Notes:
In the future similar functionality will be included in a single-chip NIC.

About the driver:
-----------------
Patches 1-4 prepare some existing driver code for the new feature:
  * Add support for reserved GIDs in the hardware GID table
  * Allow multiple modules to enable hardware RoCE support independently
Patches 5-6 define structs and helper functions for QP work-queues.
Patches 7-11 add various FPGA-related features required for Innova.
IPSec.
Patch 12 adds abstraction layer for Mellanox IPSec-offload capable devices.
atches 13-16 add IPSec offload support to the mlx5 netdevice.

This driver services the new IPSec offload API introduced in commit
d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")

Configuration Path:
If Innova IPSec device is detected, the mlx5e netdevice gets the new
NETIF_F_HW_ESP feature and the xdo callbacks, indicating ESP offload
capabilities, and also the matching TX checksum and GSO features.

The driver configures offloaded Security Associations (SAs) by sending
an ADD_SA or DEL_SA message to the IPSec SBU, which updates the SADB in DDR.
These messages and their responses are sent over a high-speed channel.
Counters for ethtool are retrieved by the driver from the SBU.

Data path:
On receive path, the SBU decrypts ESP packets which match the offloaded SADB,
but keeps them encapsulated.
The SBU injects metadata (Mellanox owned ethertype) indicating that crypto-offload
has taken place, the SA with which it was done, and the authentication result.

The ConnectX chip performs RX checksum offload on the packet, and RSS using the
ESP SPI value.  The driver detects the special ethertype, and attaches a struct
secpath to the RX SKB, including flags to indicate that crypto offload took place,
the authentication result, and which xfrm_state was used for decryption, in the
olen and ovec members. The RX SKB may have useful CHECKSUM_COMPLETE. A separate
patchset will add support for that in the xfrm stack.

On transmit path, the stack encapsulates the packet but does not encrypt it, and
indicates in the SKB's secpath that crypto offload is to be performed and the SA
to use to do so.
The driver avoids performing crypto-offload for ESP fragments, and packets with
IP options, as the SBU cannot currently do that.  For eligible packets, the driver
prepends a special ethertype with metadata instructing the hardware to perform crypto offload.
The stack builds regular (non-GSO) SKBs so that they contain a placeholder for the ESP trailer.
The driver trims it off, because the SBU automatically appends the trailer for offloaded packets.
The ConnectX chip performs TX checksum offload on inner UDP or TCP packets,
and GSO for TCP packets (duplicating the prepended metadata).
The segmented packets then undergo encryption in the SBU before going on the wire.

Performance:
We measure single stream of TCP on Intel(R) Xeon(R) CPU E5-2643 v2 @3.50GHz
Using AES-NI with ESP GSO we get constant 4.1 Gbps.
Using crypto offload we get constant 18 Gbps.

Note that these numbers require CHECKSUM_COMPLETE support in XFRM, which we submit separately.

-  Ilan Tayari

----------------------------------------------------------------
Ilan Tayari (16):
      net/mlx5: Set interface flags before cleanup in unload_one
      net/mlx5: Add reserved-gids support
      net/mlx5: Add support for multiple RoCE enable
      IB/mlx5: Respect mlx5_core reserved GIDs
      net/mlx5: Make get_cqe routine not ethernet-specific
      net/mlx5: Add QP WQ support
      net/mlx5: FPGA, Move FPGA init/cleanup to init_once
      net/mlx5: FPGA, Add FW commands for FPGA QPs
      net/mlx5: FPGA, Add high-speed connection routines
      net/mlx5: FPGA, Add SBU bypass and reset flows
      net/mlx5: FPGA, Add SBU infrastructure
      net/mlx5: Accel, Add IPSec acceleration interface
      net/mlx5e: IPSec, Innova IPSec offload infrastructure
      net/mlx5e: IPSec, Add Innova IPSec offload RX data path
      net/mlx5e: IPSec, Add Innova IPSec offload TX data path
      net/mlx5e: IPSec, Add IPSec ethtool stats

 MAINTAINERS                                        |   10 +
 drivers/infiniband/hw/mlx5/main.c                  |  119 +--
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   16 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   10 +-
 .../net/ethernet/mellanox/mlx5/core/accel/ipsec.c  |   78 ++
 .../net/ethernet/mellanox/mlx5/core/accel/ipsec.h  |  138 +++
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   10 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    5 +-
 .../ethernet/mellanox/mlx5/core/en_accel/ipsec.c   |  461 +++++++++
 .../ethernet/mellanox/mlx5/core/en_accel/ipsec.h   |  140 +++
 .../mellanox/mlx5/core/en_accel/ipsec_rxtx.c       |  378 +++++++
 .../mellanox/mlx5/core/en_accel/ipsec_rxtx.h       |   55 ++
 .../mellanox/mlx5/core/en_accel/ipsec_stats.c      |  133 +++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   49 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   45 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   27 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |   19 +-
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c |  174 ++++
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h |   25 +
 .../net/ethernet/mellanox/mlx5/core/fpga/conn.c    | 1042 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/fpga/conn.h    |   96 ++
 .../net/ethernet/mellanox/mlx5/core/fpga/core.c    |   87 +-
 .../net/ethernet/mellanox/mlx5/core/fpga/core.h    |   22 +-
 .../net/ethernet/mellanox/mlx5/core/fpga/ipsec.c   |  376 +++++++
 .../net/ethernet/mellanox/mlx5/core/fpga/ipsec.h   |   94 ++
 drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c |  164 +++
 drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.h |  204 ++++
 drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c  |  154 +++
 drivers/net/ethernet/mellanox/mlx5/core/lib/mlx5.h |   43 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   46 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |    4 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.c       |   46 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.h       |   27 +
 include/linux/mlx5/device.h                        |    3 +
 include/linux/mlx5/driver.h                        |   19 +
 include/linux/mlx5/mlx5_ifc.h                      |   14 +-
 include/linux/mlx5/mlx5_ifc_fpga.h                 |  288 ++++++
 include/linux/mlx5/qp.h                            |   14 +-
 39 files changed, 4518 insertions(+), 127 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/accel/ipsec.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/accel/ipsec.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_stats.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/conn.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/conn.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/mlx5.h
