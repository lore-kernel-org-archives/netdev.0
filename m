From: Jon Maxwell <jmaxwell37@gmail.com>
Subject: [net] igbvf: remove "link is Up" message when registering mcast address
Date: Mon, 25 Jan 2016 10:22:52 +1100
Message-ID: <1453677772-27075-1-git-send-email-jmaxwell37@gmail.com>
Cc: davem@davemloft.net, jmaxwell@redhat.com, vinschen@redhat.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jon Maxwell <jmaxwell37@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35137 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbcAXXXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 18:23:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A similar issue was addressed a few years ago in the following thread:

http://www.spinics.net/lists/netdev/msg245877.html

At that time there were concerns that removing this statement may cause other
side effects. However the submitter addressed those concerns. But the dialogue
went cold. We have a new case where a customers application is registering and 
un-registering multicast addresses every few seconds. This is leading to many 
"Link is Up" messages in the logs as a result of the 
"netif_carrier_off(netdev)" statement called by igbvf_msix_other(). Also on
some kernels it is interfering with the bonding driver causing it to failover 
and subsequently affecting connectivity.

The Sourgeforge driver does not make this call and is therefore not affected.
If there were any side effects I would expect that driver to also be affected.
I have tested re-loading the igbvf driver and downing the adapter with the PF
entity on the host where the VM has this patch. When I bring it back up again 
connectivity is restored as expected. Therefore I request that this patch gets 
submitted. 

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 297af80..c2dfc22 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -876,7 +876,6 @@ static irqreturn_t igbvf_msix_other(int irq, void *data)
 
 	adapter->int_counter1++;
 
-	netif_carrier_off(netdev);
 	hw->mac.get_link_status = 1;
 	if (!test_bit(__IGBVF_DOWN, &adapter->state))
 		mod_timer(&adapter->watchdog_timer, jiffies + 1);
-- 
1.8.3.1
