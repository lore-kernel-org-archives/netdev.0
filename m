From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 1/2] net/tg3: Fix kernel crash
Date: Wed, 24 Jul 2013 17:25:08 +0800
Message-ID: <1374657909-26929-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: nsujir@broadcom.com, mchan@broadcom.com, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:58465 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab3GXJZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 05:25:19 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 03:25:19 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 4D5C71FF001B
	for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 03:19:55 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O9PGaF148162
	for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 03:25:16 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O9PEBh004987
	for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 03:25:16 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While EEH error happens, we might not have network device instance
(struct net_device) yet. So we can't access the instance safely and
check its link state, which causes kernel crash. The patch fixes it.

EEH: Frozen PE#2 on PHB#3 detected
EEH: This PCI device has failed 1 times in the last hour
EEH: Notify device drivers to shutdown
(NULL net_device): PCI I/O error detected
Unable to handle kernel paging request for data at address 0x00000048
Faulting instruction address: 0xd00000001c9387a8
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=1024 NUMA PowerNV
:
NIP [d00000001c9387a8] .tg3_io_error_detected+0x78/0x2a0 [tg3]
LR [d00000001c9387a4] .tg3_io_error_detected+0x74/0x2a0 [tg3]
Call Trace:
[c000003f93a0f960] [d00000001c9387a4] .tg3_io_error_detected+0x74/0x2a0 [tg3]
[c000003f93a0fa30] [c00000000003844c] .eeh_report_error+0xac/0x120
[c000003f93a0fac0] [c0000000000371bc] .eeh_pe_dev_traverse+0x8c/0x150
[c000003f93a0fb60] [c000000000038858] .eeh_handle_normal_event+0x128/0x3d0
[c000003f93a0fbf0] [c000000000038db8] .eeh_handle_event+0x2b8/0x2c0
[c000003f93a0fc90] [c000000000038e80] .eeh_event_handler+0xc0/0x170
[c000003f93a0fd30] [c0000000000cc000] .kthread+0xf0/0x100
[c000003f93a0fe30] [c00000000000a0dc] .ret_from_kernel_thread+0x5c/0x80

Reported-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d964f30..aee1b9a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17773,7 +17773,8 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 
 	rtnl_lock();
 
-	if (!netif_running(netdev))
+	/* We probably don't have netdev yet */
+	if (!netdev || !netif_running(netdev))
 		goto done;
 
 	tg3_phy_stop(tp);
-- 
1.7.5.4
