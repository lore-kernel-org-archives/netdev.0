From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH net-next 0/5] tls: Add generic NIC offload infrastructure
Date: Thu, 14 Sep 2017 13:46:23 +0300
Message-ID: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, tom@herbertland.com,
        hannes@stressinduktion.org, borisp@mellanox.com,
        ilyal@mellanox.com, aviadye@mellanox.com, liranl@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37204 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751602AbdINKqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 06:46:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series add a generic infrastructure to offload TLS crypto to a
network devices. It enables the kernel TLS socket to skip encryption and
authentication operations on the transmit side of the data path. Leaving
those computationally expensive operations to the NIC.

The NIC offload infrastructure builds TLS records and pushes them to the
TCP layer just like the SW KTLS implementation and using the same API.
TCP segmentation is mostly unaffected. Currently the only exception is
that we prevent mixed SKBs where only part of the payload requires
offload. In the future we are likely to add a similar restriction
following a change cipher spec record.

The notable differences between SW KTLS and NIC offloaded TLS
implementations are as follows:
1. The offloaded implementation builds "plaintext TLS record", those
records contain plaintext instead of ciphertext and place holder bytes
instead of authentication tags.
2. The offloaded implementation maintains a mapping from TCP sequence
number to TLS records. Thus given a TCP SKB sent from a NIC offloaded
 TLS socket, we can use the tls NIC offload infrastructure to obtain
enough context to encrypt the payload of the SKB.
A TLS record is released when the last byte of the record is ack'ed,
this is done through the new icsk_clean_acked callback.

The infrastructure should be extendable to support various NIC offload
implementations.  However it is currently written with the
implementation below in mind:
The NIC assumes that packets from each offloaded stream are sent as
plaintext and in-order. It keeps track of the TLS records in the TCP
stream. When a packet marked for offload is transmitted, the NIC
encrypts the payload in-place and puts authentication tags in the
relevant place holders.

The responsibility for handling out-of-order packets (i.e. TCP
retransmission, qdisc drops) falls on the netdev driver.

The netdev driver keeps track of the expected TCP SN from the NIC's
perspective.  If the next packet to transmit matches the expected TCP
SN, the driver advances the expected TCP SN, and transmits the packet
with TLS offload indication.

If the next packet to transmit does not match the expected TCP SN. The
driver calls the TLS layer to obtain the TLS record that includes the
TCP of the packet for transmission. Using this TLS record, the driver
posts a work entry on the transmit queue to reconstruct the NIC TLS
state required for the offload of the out-of-order packet. It updates
the expected TCP SN accordingly and transmit the now in-order packet.
The same queue is used for packet transmission and TLS context
reconstruction to avoid the need for flushing the transmit queue before
issuing the context reconstruction request.

Expected TCP SN is accessed without a lock, under the assumption that
TCP doesn't transmit SKBs from different TX queue concurrently.

We assume that packets are not rerouted to a different network device.

Github with mlx5e TLS offload support:
https://github.com/Mellanox/tls-offload/tree/tls_device_v1

Paper: https://www.netdevconf.org/1.2/papers/netdevconf-TLS.pdf

Ilya Lesokhin (5):
  tls: Move release of tls_ctx into tls_sw_free_resources
  tcp: Add clean acked data hook
  net: Add TLS offload netdev ops
  net: Add TLS TX offload features
  tls: Add generic NIC offload infrastructure.

 include/linux/netdev_features.h    |   2 +
 include/linux/netdevice.h          |  21 ++
 include/net/inet_connection_sock.h |   2 +
 include/net/tls.h                  |  41 ++-
 net/core/ethtool.c                 |   1 +
 net/ipv4/tcp_input.c               |   3 +
 net/tls/Kconfig                    |   9 +
 net/tls/Makefile                   |   3 +
 net/tls/tls_device.c               | 673 +++++++++++++++++++++++++++++++++++++
 net/tls/tls_main.c                 |  68 ++--
 net/tls/tls_sw.c                   |   1 +
 11 files changed, 803 insertions(+), 21 deletions(-)
 create mode 100644 net/tls/tls_device.c

-- 
1.8.3.1
