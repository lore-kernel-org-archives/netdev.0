From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH RFC 0/6] NCSI Support
Date: Mon,  9 Nov 2015 11:10:00 +1100
Message-ID: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:45184 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbbKIALo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 19:11:44 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 9 Nov 2015 10:11:42 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 70F832CE8054
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 11:11:37 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tA90BUdI31457370
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:11:38 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tA90B4pW016719
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:11:04 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches are prototype requesting for comments. Please focus on
the big picture at current stage, but any comments to improve the implementaion
are welcomed.

The following figure gives an example about how NCSI is deployed: The NCSI is
specified by DSP0222, which can be downloaded from the following link here
(http://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.0.0.pdf).

   * The NC-SI (aka NCSI) is defined as the interface between a (Base) Management
     Controller (BMC) and one or multiple Network Controlers (NC) on host side.
     The interface is responsible for providing external network connectivity
     for BMC.
   * Each BMC can connect to multiple packages, up to 8. Each package can have
     multiple channels, up to 32. Every package and channel are identified by
     3-bits and 5-bits in NCSI packet. At one moment, one channel is active to
     provide service.
   * NCSI packet, encapsulated in ethernet frame, has 0x88F8 in the protocol
     field. The destination MAC address should be 0xFF's while the source MAC
     address can be arbitrary one.
   * NCSI packets are classified to command, response, AEN (Asynchronous Event
     Notification). Commands are sent from BMC to host for configuration and
     information retrival. Responses, corresponding to commands, are sent from
     host to BMC for confirmation and requested information. One command should
     have one and only one response. AEN is sent from host to BMC for notification
     (e.g. link down on active channel) so that BMC can take appropriate action.

   +------------------+        +----------------------------------------------+
   |                  |        |                     Host                     |
   |        BMC       |        |                                              |
   |                  |        | +-------------------+  +-------------------+ |
   |    +---------+   |        | |     Package-A     |  |     Package-B     | |
   |    |         |   |        | +---------+---------+  +-------------------+ |
   |    |   NIC   |   |        | | Channel | Channel |  | Channel | Channel | |
   +----+----+----+---+        +-+---------+---------+--+---------+---------+-+
             |                             |                      |
             |                             |                      |
             +-----------------------------+----------------------+           

The design for the patchset is highlighted as below:

   * All the code included in this patchset runs on BMC side. The major target
     of this patchset is to hide the NCSI details to BMC's NIC driver. The patchset
     abstracts a NCSI device (struct ncsi_dev), which is created when the driver
     is loaded and the BMC NIC (struct net_device) instance is created. When the
     NIC is opened (ndo_open()), all available packages and channels are probed
     through NCSI packets. At the same time, one active channel is selected to
     provide service. It means the NIC driver can receive/transmit packets before
     ndo_open().
   * When NCSI device (struct ncsi_dev) is created when NIC driver is loaded,
     NCSI protocl handler is added by dev_add_pack() so that the ingress NCSI
     packets can be routed to the stack for further processing. On the other
     hand, dev_queue_xmit_sk() is called to transmit skb that has been bound
     with the BMC's NIC.
   * The NCSI device is closed when the BMC's NIC is closed.
   * NCSI stack should be configurable through netlink, but it's not implemented
     in this patchset. It's something TBD.
   * The first NIC driver that is aware of NCSI: drivers/net/ethernet/faraday/ftgmac100.c

Gavin Shan (6):
  net/ncsi: Resource management
  net/ncsi: Packet handler
  net/ncsi: Manage NCSI device
  net/faraday: Replace use_nc_si with use_ncsi
  net/faraday: Enable NCSI interface
  net/faraday: Enable offload checksum according to device-tree

 drivers/net/ethernet/faraday/ftgmac100.c |  108 ++-
 include/net/ncsi.h                       |   57 ++
 include/uapi/linux/if_ether.h            |    1 +
 net/Kconfig                              |    1 +
 net/Makefile                             |    1 +
 net/ncsi/Kconfig                         |   10 +
 net/ncsi/Makefile                        |    5 +
 net/ncsi/internal.h                      |  313 ++++++++
 net/ncsi/ncsi-aen.c                      |  197 +++++
 net/ncsi/ncsi-cmd.c                      |  372 ++++++++++
 net/ncsi/ncsi-manage.c                   |  899 +++++++++++++++++++++++
 net/ncsi/ncsi-pkt.h                      |  391 ++++++++++
 net/ncsi/ncsi-rsp.c                      | 1166 ++++++++++++++++++++++++++++++
 13 files changed, 3490 insertions(+), 31 deletions(-)
 create mode 100644 include/net/ncsi.h
 create mode 100644 net/ncsi/Kconfig
 create mode 100644 net/ncsi/Makefile
 create mode 100644 net/ncsi/internal.h
 create mode 100644 net/ncsi/ncsi-aen.c
 create mode 100644 net/ncsi/ncsi-cmd.c
 create mode 100644 net/ncsi/ncsi-manage.c
 create mode 100644 net/ncsi/ncsi-pkt.h
 create mode 100644 net/ncsi/ncsi-rsp.c

-- 
2.1.0
