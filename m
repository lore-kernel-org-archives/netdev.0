From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [-MM, FIX V3] e1000e: incorporate napi_struct changes
 from net-2.6.24.git
Date: Wed, 12 Sep 2007 07:53:24 -0700 (PDT)
Message-ID: <20070912.075324.98878193.davem@davemloft.net>
References: <20070908002730.27700.3774.stgit@localhost.localdomain>
	<46E1ED43.4070506@intel.com>
	<18146.21773.295381.108336@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, akpm@linux-foundation.org,
	jeff@garzik.org, netdev@vger.kernel.org
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:57287
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965033AbXILOxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 10:53:41 -0400
In-Reply-To: <18146.21773.295381.108336@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Sat, 8 Sep 2007 09:53:49 +0200

>  Yes a correct observation. I've spotted this bug too and it caused by the 
>  policy change in the NAPI scheduling. Look at tx_cleaned. 
> 
>  I suggest we revert this change for now.

The tx_cleaned logic change was not intentional, and
that's the bug that makes e1000 spin endlessly in NAPI.

The other part, the work_done < budget part, was intentional
so I'm going to keep it in there for now.  I've checked
in the patch below to deal with this.

I suspect the check "work_done == 0" is some shamans dance
to get slightly better performance, but it's 1) wrong and
2) at best needs to be explained in a comment and fully
quantified.

>From e8cbb449155000eecc6e855ea71510fecfc7d5ee Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@kimchee.(none)>
Date: Wed, 12 Sep 2007 16:50:32 +0200
Subject: [PATCH] [E1000]: Fix unintended NAPI breakout logic change.

The inversion of the !tx_cleaned test in e1000_clean()
was not intentional, we just wanted to change the
"work_done == 0" to "work_done < budget"

Noticed by Robert Olsson.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7b0bcdb..58bb758 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3944,7 +3944,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 	                  &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((tx_cleaned && (work_done < budget)) ||
+	if ((!tx_cleaned && (work_done < budget)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
-- 
1.5.2.4

