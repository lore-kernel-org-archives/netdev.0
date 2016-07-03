From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/10] NCSI Support
Date: Sun,  3 Jul 2016 15:32:23 +1000
Message-ID: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	weixue@trustnetic.com, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:26819 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750713AbcGCFcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 01:32:41 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u635TKkk020718
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 01:32:41 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23x77vt0ux-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 01:32:40 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Sun, 3 Jul 2016 15:32:38 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 3C16D2CE8059
	for <netdev@vger.kernel.org>; Sun,  3 Jul 2016 15:32:36 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u635WaN021627116
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:36 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u635WZdi031408
	for <netdev@vger.kernel.org>; Sun, 3 Jul 2016 15:32:36 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series rebases on David's linux-net git repo ("master" branch). It's
to support NCSI stack on net/farady/ftgmac100.c

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

   * The NCSI interface is abstracted with "struct ncsi_dev". It's registered
     when net_device is created, started to work by calling ncsi_start_dev()
     when net_device is opened (ndo_open()). For the first time, NCSI packets
     are sent and received to/from the far end (host in above figure) to probe
     available NCSI packages and channels. After that, one channel is chosen as
     active one to provide service.
   * The NCSI stack is driven by workqueue and state machine internally.
   * AEN (Asychronous Event Notification) might be received from the far end
     (host). The currently active NCSI channel fails over to another available
     one if possible. Otherwise, the NCSI channel is out of service.
   * NCSI stack should be configurable through netlink or another mechanism,
     but it's not implemented in this patchset. It's something TBD.
   * The first NIC driver that is aware of NCSI: drivers/net/ethernet/faraday/ftgmac100.c

Gavin Shan (10):
  net/ncsi: Resource management
  net/ncsi: NCSI command packet handler
  net/ncsi: NCSI response packet handler
  net/ncsi: Package and channel management
  net/ncsi: NCSI AEN packet handler
  net/farady: Helper functions to create or destroy MDIO interface
  net/farady: Read MAC address from chip
  net/farady: Support NCSI mode
  net/farady: Match driver according to compatible property
  net/farady: Mask PHY interrupt with NCSI mode

 drivers/net/ethernet/faraday/ftgmac100.c | 280 +++++++--
 include/net/ncsi.h                       |  52 ++
 include/uapi/linux/if_ether.h            |   1 +
 net/Kconfig                              |   1 +
 net/Makefile                             |   1 +
 net/ncsi/Kconfig                         |  12 +
 net/ncsi/Makefile                        |   4 +
 net/ncsi/internal.h                      | 310 ++++++++++
 net/ncsi/ncsi-aen.c                      | 169 ++++++
 net/ncsi/ncsi-cmd.c                      | 396 ++++++++++++
 net/ncsi/ncsi-manage.c                   | 893 +++++++++++++++++++++++++++
 net/ncsi/ncsi-pkt.h                      | 395 ++++++++++++
 net/ncsi/ncsi-rsp.c                      | 997 +++++++++++++++++++++++++++++++
 13 files changed, 3448 insertions(+), 63 deletions(-)
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
