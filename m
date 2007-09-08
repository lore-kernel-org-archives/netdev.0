From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] [-MM, FIX V3] e1000e: incorporate napi_struct changes
 from net-2.6.24.git
Date: Sat, 8 Sep 2007 09:53:49 +0200
Message-ID: <18146.21773.295381.108336@robur.slu.se>
References: <20070908002730.27700.3774.stgit@localhost.localdomain>
	<46E1ED43.4070506@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm@linux-foundation.org, jeff@garzik.org,
	netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:47217 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344AbXIHHyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2007 03:54:11 -0400
In-Reply-To: <46E1ED43.4070506@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Kok, Auke writes:

> david,
 > 
 > while testing this patch I noticed that the poll routine is now called 
 > 100% of the time, and since I'm not doing much different than before, I 
 > suspec that something in the new napi code is staying in polling mode 
 > forever? Since e1000e is pretty much the same code as e1000, I doubt the 
 > problem is there, but you can probably tell better. ideas?

 Hello,
 
 Yes a correct observation. I've spotted this bug too and it caused by the 
 policy change in the NAPI scheduling. Look at tx_cleaned. 


 I suggest we revert this change for now.
 

 Cheers
					--ro


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


 diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7b0bcdb..5cb883a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3944,7 +3944,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 	                  &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((tx_cleaned && (work_done < budget)) ||
+	if ((!tx_cleaned && (work_done == 0)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))




