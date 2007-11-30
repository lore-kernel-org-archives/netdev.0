From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: net_rx_action/NAPI oops [PATCH]
Date: Fri, 30 Nov 2007 17:56:44 +0100
Message-ID: <18256.16588.515008.897975@robur.slu.se>
References: <18252.26472.319078.165019@robur.slu.se>
	<20071127140904.20c4cba8@freepuppy.rosehill>
	<474C9B84.5090103@intel.com>
	<20071127145537.6bf1af68@freepuppy.rosehill>
	<474CB54A.2060804@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:54545 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762678AbXK3Q46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:56:58 -0500
In-Reply-To: <474CB54A.2060804@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Hello!

 After further investigations. The bug was just in front of us...

 ifconfig down in combination with the test for || !netif_running() can 
 return a full quota and netif_rx_complete() done which causes the oops 
 in net_rx_action. Of course the load must be high enough to fill the 
 quota.

 I've found a bunch of drivers having this bug.

 Cheers.
					--ro

 
Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index cf39473..f4137ad 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3947,6 +3947,10 @@ e1000_clean(struct napi_struct *napi, int budget)
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
+
+		if(work_done == budget)
+			work_done--;
+	
 		netif_rx_complete(poll_dev, napi);
 		e1000_irq_enable(adapter);
 	}
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4fd2e23..e43b5ca 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1408,6 +1408,9 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	if ((!tx_cleaned && (work_done < budget)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
+		if(work_done == budget)
+			work_done--;
+
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev, napi);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 3021234..e3064ef 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1783,6 +1783,10 @@ ixgb_clean(struct napi_struct *napi, int budget)
 
 	/* if no Tx and not enough Rx work done, exit the polling mode */
 	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
+
+		if(work_done == budget)
+			work_done--;
+
 		netif_rx_complete(netdev, napi);
 		ixgb_irq_enable(adapter);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 00bc525..204f5fa 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -579,6 +579,9 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	/* If no Tx and not enough Rx work done, exit the polling mode */
 	if ((work_done < budget) || !netif_running(netdev)) {
 quit_polling:
+		if(work_done == budget)
+			work_done--;
+
 		netif_rx_complete(netdev, napi);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
@@ -1483,6 +1486,9 @@ static int ixgbe_clean(struct napi_struct *napi, int budget)
 	if ((!tx_cleaned && (work_done < budget)) ||
 	    !netif_running(adapter->netdev)) {
 quit_polling:
+		if(work_done == budget)
+			work_done--;
+
 		netif_rx_complete(netdev, napi);
 		ixgbe_irq_enable(adapter);
 	}
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 3dbaec6..c566491 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1998,6 +1998,10 @@ static int e100_poll(struct napi_struct *napi, int budget)
 
 	/* If no Rx and Tx cleanup work was done, exit polling mode. */
 	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
+
+		if(work_done == budget)
+			work_done--;
+
 		netif_rx_complete(netdev, napi);
 		e100_enable_irq(nic);
 	}
