From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFCv2 PATCH net-next 0/3] MACsec IEEE 802.1AE implementation
Date: Tue,  2 Feb 2016 14:29:18 +0100
Message-ID: <cover.1454404823.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755212AbcBBN3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 08:29:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MACsec (IEEE 802.1AE [0]) is a protocol that provides security for
wired ethernet LANs.  MACsec offers two protection modes:
authentication only, or authenticated encryption.

MACsec defines "secure channels" that allow transmission from one node
to one or more others.  Communication on a channel is done over a
succession of "secure associations", that each use a specific key.
Secure associations are identified by their "association number" in
the range 0..3.  A secure association is retired when its 32-bit
packet number would wrap, and the same association number can later be
reused with a new key and packet number.

The standard mode of encryption is GCM AES with 128 bits keys,
although an extension allows 256 bits keys [1] (not implemented in
this submission).

When using MACsec, an extra header, called "SecTAG", is added between
the ethernet header and the original payload:

 +---------------------------------+----------------+----------------+
 |        (MACsec ethertype)       |     TCI_AN     |       SL       |
 +---------------------------------+----------------+----------------+
 |                           Packet Number                           |
 +-------------------------------------------------------------------+
 |                     Secure Channel Identifier                     |
 |                            (optional)                             |
 +-------------------------------------------------------------------+

TCI_AN:
 version
 end_station
 sci_present
 scb
 encrypted
 changed_text
 association_number (2 bits)
SL:
 short_length (6 bits)
 unused (2 bits)

The ethertype for the packet is set to 0x88E5, and the original
ethertype becomes part of the secure payload, which may be encrypted.
The ethernet header and the SecTAG are always transmitted in the
clear, but are integrity-protected.

MACsec supports optional replay protection with a configurable replay
window.

MACsec is designed to be used with the MKA extension to 802.1X (MACsec
Key Agreement protocol) [2], which provides channel attribution and
key distribution to the nodes, but can also be used with static keys
getting fed manually by an administrator.

Optional (not supported yet) features:
 - confidentiality offset: in encryption mode, part of the payload may
   be left unencrypted.
 - choice of cipher suite: GCM AES with 256 bits has been standardised
   [1].


Implementation

A netdevice is created on top of a real device for each TX secure
channel, like we do for VLANs.  Multiple TX channels can be created on
top of the same underlying device.

Several other approaches were considered for the RX path:

 - dev_add_pack: doesn't work, because we want to filter out
   unprotected packets
 - transparent mode: MACsec would be enabled directly on the real
   netdevice.  For this, we cannot use a rx_handler directly because
   MACsec must be available for underlying devices enslaved in a
   bridge or in a bond, so we need a hook directly in
   __netif_receive_skb_core.  This approach makes it harder to filter
   non-encrypted packets on RX without forcing the user to setup some
   rules, so the "transparent" mode is not so transparent after all.
   It also makes TX more complex than with a dedicated netdevice.

One issue with the proposed implementation is that the qdisc layer for
the real device operates on already encrypted packets.


Netlink API

This is currently a mix of rtnetlink (to create the device and set up
the TX channel) and genl (for RX channels, secure associations and
their keys).  genl provides clean demultiplexing of the {TX,RX}{SC,SA}
commands.


Use cases

The normal use case is wired LANs, including veth and slave devices
for bonding/teaming or bridges.

MACsec can also be used on any device that makes a full ethernet
header visible, for example VXLAN.
The VXLAN+MACsec setup would be:

         hypervisor        |     virtual machine
    <real_dev>---<VXLAN>---|---<dev>---<macsec_dev>

And the packets would look like this:

| eth | IP | UDP | VXLAN | eth | MACsec | IP | ... | MACsec ICV |

One benefit on this approach to encryption in the cloud is that the
payload is encrypted by the tenant, not by the tunnel provider, thus
the tenant has full control over the keys.

Changes from RFCv1 (details in individual patches):
 - addressed comments from Florian and Paolo + kbuild robot
 - also perform post-decrypt handling after crypto callback
 - fixed ->dellink behavior

Future plans:
 - offload to hardware, on nics that support it (at least some ixgbe)
 - implement optional features


[0] http://standards.ieee.org/getieee802/download/802.1AE-2006.pdf
[1] http://standards.ieee.org/getieee802/download/802.1AEbn-2011.pdf
[2] http://standards.ieee.org/getieee802/download/802.1X-2010.pdf
[3] link to RFCv1: http://www.spinics.net/lists/netdev/msg358151.html

Sabrina Dubroca (3):
  uapi: add MACsec bits
  net: add MACsec netdevice priv_flags and helper
  macsec: introduce IEEE 802.1AE driver

 drivers/net/Kconfig            |    7 +
 drivers/net/Makefile           |    1 +
 drivers/net/macsec.c           | 3031 ++++++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h      |    8 +
 include/uapi/linux/Kbuild      |    1 +
 include/uapi/linux/if_ether.h  |    1 +
 include/uapi/linux/if_link.h   |   21 +
 include/uapi/linux/if_macsec.h |  165 +++
 8 files changed, 3235 insertions(+)
 create mode 100644 drivers/net/macsec.c
 create mode 100644 include/uapi/linux/if_macsec.h

-- 
2.7.0
