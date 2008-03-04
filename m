From: David Miller <davem@davemloft.net>
Subject: Re: locking api self-test hanging
Date: Tue, 04 Mar 2008 12:30:00 -0800 (PST)
Message-ID: <20080304.123000.183265831.davem@davemloft.net>
References: <20080304084024.GA3980@ff.dom.local>
	<20080304011050.74f30dd3.akpm@linux-foundation.org>
	<20080304075137.6bbd285f@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33438
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756319AbYCDUaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 15:30:06 -0500
In-Reply-To: <20080304075137.6bbd285f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 4 Mar 2008 07:51:37 -0800

> On Tue, 4 Mar 2008 01:10:50 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > That bisecting took me several hours and at the time I hoped that it would
> > receive a more-than-zero response.  btw.
> 
> Mia culpa, individual tests of the netconsole when I did the patch worked.
> But obviously didn't stress it enough or trigger that drop code.
> 
> Plus, I didn't believe the bisect.

At least Jarek figured it out in the end :-)  I'll revert
these two changesets like so:

commit d9452e9f81e997cbd0c9bface8d2c2a4b064cc3e
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Mar 4 12:28:49 2008 -0800

    [NETPOLL]: Revert two bogus cleanups that broke netconsole.
    
    Based upon a report by Andrew Morton and code analysis done
    by Jarek Poplawski.
    
    This reverts 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7 ("[NETPOLL]:
    Kill NETPOLL_RX_DROP, set but never tested.")  and
    c7b6ea24b43afb5749cb704e143df19d70e23dea ("[NETPOLL]: Don't need
    rx_flags.").
    
    The rx_flags did get tested for zero vs. non-zero and therefore we do
    need those tests and that code which sets NETPOLL_RX_DROP et al.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index a0525a1..e3d7959 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -25,6 +25,7 @@ struct netpoll {
 
 struct netpoll_info {
 	atomic_t refcnt;
+	int rx_flags;
 	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
 	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
@@ -50,12 +51,12 @@ static inline int netpoll_rx(struct sk_buff *skb)
 	unsigned long flags;
 	int ret = 0;
 
-	if (!npinfo || !npinfo->rx_np)
+	if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
 		return 0;
 
 	spin_lock_irqsave(&npinfo->rx_lock, flags);
-	/* check rx_np again with the lock held */
-	if (npinfo->rx_np && __netpoll_rx(skb))
+	/* check rx_flags again with the lock held */
+	if (npinfo->rx_flags && __netpoll_rx(skb))
 		ret = 1;
 	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 6faa128..4b7e756 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -39,6 +39,8 @@ static struct sk_buff_head skb_pool;
 static atomic_t trapped;
 
 #define USEC_PER_POLL	50
+#define NETPOLL_RX_ENABLED  1
+#define NETPOLL_RX_DROP     2
 
 #define MAX_SKB_SIZE \
 		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
@@ -126,11 +128,13 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
 		return budget;
 
+	npinfo->rx_flags |= NETPOLL_RX_DROP;
 	atomic_inc(&trapped);
 
 	work = napi->poll(napi, budget);
 
 	atomic_dec(&trapped);
+	npinfo->rx_flags &= ~NETPOLL_RX_DROP;
 
 	return budget - work;
 }
@@ -472,7 +476,7 @@ int __netpoll_rx(struct sk_buff *skb)
 	if (skb->dev->type != ARPHRD_ETHER)
 		goto out;
 
-	/* if receive ARP during middle of NAPI poll, then queue */
+	/* check if netpoll clients need ARP */
 	if (skb->protocol == htons(ETH_P_ARP) &&
 	    atomic_read(&trapped)) {
 		skb_queue_tail(&npi->arp_tx, skb);
@@ -534,9 +538,6 @@ int __netpoll_rx(struct sk_buff *skb)
 	return 1;
 
 out:
-	/* If packet received while already in poll then just
-	 * silently drop.
-	 */
 	if (atomic_read(&trapped)) {
 		kfree_skb(skb);
 		return 1;
@@ -675,6 +676,7 @@ int netpoll_setup(struct netpoll *np)
 			goto release;
 		}
 
+		npinfo->rx_flags = 0;
 		npinfo->rx_np = NULL;
 
 		spin_lock_init(&npinfo->rx_lock);
@@ -756,6 +758,7 @@ int netpoll_setup(struct netpoll *np)
 
 	if (np->rx_hook) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
+		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
 		npinfo->rx_np = np;
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
@@ -797,6 +800,7 @@ void netpoll_cleanup(struct netpoll *np)
 			if (npinfo->rx_np == np) {
 				spin_lock_irqsave(&npinfo->rx_lock, flags);
 				npinfo->rx_np = NULL;
+				npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
 				spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 			}
 
