From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v3 00/10] NCSI Support
Date: Tue, 19 Jul 2016 11:54:15 +1000
Message-ID: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:46714 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752097AbcGSByf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 21:54:35 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6J1sSR8019815
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:34 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2495r7fy5v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 21:54:33 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 19 Jul 2016 11:54:30 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id CCE9C2BB0059
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:27 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6J1sRKF25034798
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:27 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6J1sQ7R001392
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:54:27 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series rebases on David's linux-net git repo ("master" branch). It's
to support NCSI stack on drivers/net/ethernet/faraday/ftgmac100.c. The
implementation is based on NCSI spec (version: 1.1.0):
https://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.1.0.pdf

As the following figure shows and defined in NCSI spec:

 * The NC-SI (aka NCSI) is defined as the interface between a (Base)
   Management Controller (BMC) and one or multiple Network Interface
   Controlers (NIC) on host side. The interface is responsible for providing
   external network connectivity for BMC.
 * Each BMC can connect to multiple packages, up to 8. Each package can have
   multiple channels, up to 32. Every package and channel are identified by
   3-bits and 5-bits in NCSI packet.
 * NCSI packet, encapsulated in ethernet frame, has 0x88F8 in the protocol
   field. The destination MAC address should be 0xFF's while the source MAC
   address can be arbitrary one.
 * NCSI packets are classified to command, response, AEN (Asynchronous Event Notification).
   Commands are sent from BMC to host (NIC) for configuration and
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
   |    |ftgmac100|   |        | | Channel | Channel |  | Channel | Channel | |
   +----+----+----+---+        +-+---------+---------+--+---------+---------+-+
             |                             |                      |
             |                             |                      |
             +-----------------------------+----------------------+

The series of patches is highlighted as:

The design for the patchset is highlighted as below:

 * The network driver uses 3 interfaces exported from NCSI stack:
   ncsi_register_dev() - Register (create) a associated NCSI device.
   ncsi_start_dev() - Bring up the NCSI device.
   ncsi_unregister_dev() - Destroy the registered NCSI device.
 * There are several data structures introduced for different objects:
   struct ncsi_dev - NCSI device seen by network device driver.
   struct ncsi_dev_priv - NCSI device seen by NCSI stack.
   struct ncsi_package - NCSI package which can have multiple channels.
   struct ncsi_channel - NCSI channel.
 * The NCSI stack is driven by workqueue and state machine internally.
 * The all available NCSI packages and channels are enumerated (probed) on
   the first call to ncsi_start_dev(). The NCSI topology won't change until
   the NCSI device is destroyed.
 * All available channels will be brought up When the hardware arbitration
   is enabled. Otherwise, only one channel is selected as active one. The
   NCSI internal is driven by state machine with help of a workqueue. In
   the meanwhile, there are 3 states for each channel which can be put into
   a queue requesting for configuration or suspending. Channels in the queue
   with inactive state set will be configured (bringup) while channels in
   the queue with active state will be suspended (teardown). The request
   configuration or suspending is being applied on the channel if it's in
   invisible state.
 * Failover, another inactive channel is selected as active, can happen when
   the hardware arbitration is disabled. The failover can be caused by timeout
   on link monitor and AEN.
 * NCSI stack should be configurable through netlink or another mechanism, it's
   not implemented in this patchset. It's something TBD.
 * The first NIC driver that is aware of NCSI: drivers/net/ethernet/faraday/ftgmac100.c

Changelog
=========
v2 -> v3:
 * Include (one line) change in include/uapi/linux/if_ether.h to fix build
   error.
v1 -> v2:
 * Support NCSI spec v1.1.0 (3 more commands and 4 hardware arbitration
   modes added).
 * Enable AEN packets according to the supported list.
 * Introduce NCSI channel states and processing queue in order to support
   the hardware arbitration.
 * The hardware arbitration is supported (tested with emulated environment).
 * Introduce link monitor with GLS (Get Link Status) command/response as part
   of the error handling defined in NCSI spec.
 * Support IPv6 address discovery when CONFIG_IPV6 is enabled.

Gavin Shan (10):
  net/ncsi: Resource management
  net/ncsi: NCSI command packet handler
  net/ncsi: NCSI response packet handler
  net/ncsi: Package and channel management
  net/ncsi: NCSI AEN packet handler
  net/faraday: Helper functions to create or destroy MDIO interface
  net/faraday: Read MAC address from chip
  net/faraday: Support NCSI mode
  net/faraday: Match driver according to compatible property
  net/faraday: Mask PHY interrupt with NCSI mode

 drivers/net/ethernet/faraday/ftgmac100.c |  280 +++++--
 include/net/ncsi.h                       |   52 ++
 include/uapi/linux/if_ether.h            |    1 +
 net/Kconfig                              |    1 +
 net/Makefile                             |    1 +
 net/ncsi/Kconfig                         |   12 +
 net/ncsi/Makefile                        |    4 +
 net/ncsi/internal.h                      |  328 ++++++++
 net/ncsi/ncsi-aen.c                      |  193 +++++
 net/ncsi/ncsi-cmd.c                      |  367 +++++++++
 net/ncsi/ncsi-manage.c                   | 1199 ++++++++++++++++++++++++++++++
 net/ncsi/ncsi-pkt.h                      |  415 +++++++++++
 net/ncsi/ncsi-rsp.c                      | 1035 ++++++++++++++++++++++++++
 13 files changed, 3825 insertions(+), 63 deletions(-)
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
