From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Perf data with recent tg3 patches
Date: Fri, 13 May 2005 22:20:07 -0700 (PDT)
Message-ID: <20050513.222007.78719997.davem@davemloft.net>
References: <Pine.LNX.4.61.0505131648140.14917@linux.site>
	<20050513.175013.00786860.davem@davemloft.net>
	<1116031159.6214.8.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1116031159.6214.8.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Perf data with recent tg3 patches
Date: Fri, 13 May 2005 17:39:19 -0700

> I like this. I think it will work well.

Here is a quick patch which implements this.

--- 1/drivers/net/tg3.c.~1~	2005-05-13 22:13:02.000000000 -0700
+++ 2/drivers/net/tg3.c	2005-05-13 22:18:03.000000000 -0700
@@ -2869,9 +2869,6 @@ static int tg3_poll(struct net_device *n
 
 	spin_lock_irqsave(&tp->lock, flags);
 
-	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
-		tp->last_tag = sblk->status_tag;
-
 	/* handle link change and other phy events */
 	if (!(tp->tg3_flags &
 	      (TG3_FLAG_USE_LINKCHG_REG |
@@ -2896,7 +2893,6 @@ static int tg3_poll(struct net_device *n
 	 * All RX "locking" is done by ensuring outside
 	 * code synchronizes with dev->poll()
 	 */
-	done = 1;
 	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr) {
 		int orig_budget = *budget;
 		int work_done;
@@ -2908,12 +2904,14 @@ static int tg3_poll(struct net_device *n
 
 		*budget -= work_done;
 		netdev->quota -= work_done;
-
-		if (work_done >= orig_budget)
-			done = 0;
 	}
 
+	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
+		tp->last_tag = sblk->status_tag;
+	rmb();
+
 	/* if no more work, tell net stack and NIC we're done */
+	done = !tg3_has_work(tp);
 	if (done) {
 		spin_lock_irqsave(&tp->lock, flags);
 		__netif_rx_complete(netdev);
