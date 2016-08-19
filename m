From: fgao@ikuai8.com
Subject: [PATCH 1/1] ppp: Fix one deadlock issue of PPP when reentrant
Date: Fri, 19 Aug 2016 23:16:41 +0800
Message-ID: <1471619801-11405-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: paulus@samba.org, g.nault@alphalink.fr,
        philipp@redfish-solutions.com, linux-ppp@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG179.QQ.COM ([119.147.194.222]:56497 "EHLO
        smtpbg179.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754146AbcHSPR3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 11:17:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

PPP channel holds one spinlock before send frame. But the skb may
select the same PPP channel with wrong route policy. As a result,
the skb reaches the same channel path. It tries to get the same
spinlock which is held before. Bang, the deadlock comes out.

Now add one lock owner to avoid it like xmit_lock_owner of
netdev_queue. Check the lock owner before try to get the spinlock.
If the current cpu is already the owner, it means ppp finds there is
one reentrant and returns directly. If not owner and hold the spinlock
successfully, it sets owner with current CPU ID.

The following is the panic stack of 3.3.8. But the same issue
should be in the upstream too.

[<ffffffff81568131>] ? _raw_spin_lock_bh+0x11/0x40
[<ffffffffa006a2b7>] ppp_unregister_channel+0x1347/0x2170 [ppp_generic]
[<ffffffff810a2827>] ? kmem_cache_free+0xa7/0xc0
[<ffffffffa006ad27>] ppp_unregister_channel+0x1db7/0x2170 [ppp_generic]
[<ffffffffa006afd5>] ppp_unregister_channel+0x2065/0x2170 [ppp_generic]
[<ffffffff8148f1dd>] dev_hard_start_xmit+0x4cd/0x620
[<ffffffff814a6254>] sch_direct_xmit+0x74/0x1d0
[<ffffffff8148f88d>] dev_queue_xmit+0x1d/0x30
[<ffffffff81496a4c>] neigh_direct_output+0xc/0x10
[<ffffffff814d9dae>] ip_finish_output+0x25e/0x2b0
[<ffffffff814da688>] ip_output+0x88/0x90
[<ffffffff814d9e9f>] ? __ip_local_out+0x9f/0xb0
[<ffffffff814d9ed4>] ip_local_out+0x24/0x30
[<ffffffffa00b9745>] 0xffffffffa00b9744
[<ffffffffa006b068>] ppp_unregister_channel+0x20f8/0x2170 [ppp_generic]
[<ffffffffa006b202>] ppp_output_wakeup+0x122/0x11d0 [ppp_generic]
[<ffffffff810a7978>] vfs_write+0xb8/0x160
[<ffffffff810a7c55>] sys_write+0x45/0x90
[<ffffffff815689e2>] system_call_fastpath+0x16/0x1b

The call flow is like this.
ppp_write->ppp_channel_push->start_xmit->select inappropriate route
.... -> dev_hard_start_xmit->ppp_start_xmit->ppp_xmit_process->
ppp_push. Now ppp_push tries to get the same spinlock which is held
in ppp_channel_push.

Although the PPP deadlock is caused by inappropriate route policy
with L2TP, I think it is not accepted the PPP module would cause kernel
deadlock with wrong route policy.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v3: Change the fix solution. Giveup the send chance instead of recursive lock
 v2: Fix recursive unlock issue
 v1: Initial patch
 
 drivers/net/ppp/ppp_generic.c | 95 +++++++++++++++++++++++++++++++++----------
 1 file changed, 73 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 70cfa06..b653f1f 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -162,6 +162,46 @@ struct ppp {
 			 |SC_MULTILINK|SC_MP_SHORTSEQ|SC_MP_XSHORTSEQ \
 			 |SC_COMP_TCP|SC_REJ_COMP_TCP|SC_MUST_COMP)
 
+struct channel_lock {
+	spinlock_t lock;
+	int owner;
+};
+
+static inline void ppp_channel_lock_init(struct channel_lock *cl)
+{
+	cl->owner = -1;
+	spin_lock_init(&cl->lock);
+}
+
+static inline bool ppp_channel_lock_bh(struct channel_lock *cl)
+{
+	int cpu;
+
+	local_bh_disable();
+	cpu = smp_processor_id();
+	if (cpu == cl->owner) {
+		/* The CPU already holds this channel lock and sends. But the
+		 * channel is selected after inappropriate route. It causes
+		 * reenter the channel again. It is forbidden by PPP module.
+		 */
+		if (net_ratelimit())
+			pr_err("PPP detects one recursive channel send\n");
+		local_bh_enable();
+		return false;
+	}
+	spin_lock(&cl->lock);
+	cl->owner = cpu;
+
+	return true;
+}
+
+static inline void ppp_channel_unlock_bh(struct channel_lock *cl)
+{
+	cl->owner = -1;
+	spin_unlock(&cl->lock);
+	local_bh_enable();
+}
+
 /*
  * Private data structure for each channel.
  * This includes the data structure used for multilink.
@@ -171,7 +211,7 @@ struct channel {
 	struct list_head list;		/* link in all/new_channels list */
 	struct ppp_channel *chan;	/* public channel data structure */
 	struct rw_semaphore chan_sem;	/* protects `chan' during chan ioctl */
-	spinlock_t	downl;		/* protects `chan', file.xq dequeue */
+	struct channel_lock downl;	/* protects `chan', file.xq dequeue */
 	struct ppp	*ppp;		/* ppp unit we're connected to */
 	struct net	*chan_net;	/* the net channel belongs to */
 	struct list_head clist;		/* link in list of channels per unit */
@@ -1587,9 +1627,7 @@ ppp_push(struct ppp *ppp)
 	list = &ppp->channels;
 	if (list_empty(list)) {
 		/* nowhere to send the packet, just drop it */
-		ppp->xmit_pending = NULL;
-		kfree_skb(skb);
-		return;
+		goto drop;
 	}
 
 	if ((ppp->flags & SC_MULTILINK) == 0) {
@@ -1597,16 +1635,19 @@ ppp_push(struct ppp *ppp)
 		list = list->next;
 		pch = list_entry(list, struct channel, clist);
 
-		spin_lock_bh(&pch->downl);
+		if (unlikely(!ppp_channel_lock_bh(&pch->downl))) {
+			/* Fail to hold channel lock */
+			goto drop;
+		}
 		if (pch->chan) {
 			if (pch->chan->ops->start_xmit(pch->chan, skb))
 				ppp->xmit_pending = NULL;
 		} else {
 			/* channel got unregistered */
-			kfree_skb(skb);
-			ppp->xmit_pending = NULL;
+			ppp_channel_unlock_bh(&pch->downl);
+			goto drop;
 		}
-		spin_unlock_bh(&pch->downl);
+		ppp_channel_unlock_bh(&pch->downl);
 		return;
 	}
 
@@ -1617,6 +1658,7 @@ ppp_push(struct ppp *ppp)
 		return;
 #endif /* CONFIG_PPP_MULTILINK */
 
+drop:
 	ppp->xmit_pending = NULL;
 	kfree_skb(skb);
 }
@@ -1645,6 +1687,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 	struct channel *pch;
 	struct sk_buff *frag;
 	struct ppp_channel *chan;
+	bool locked;
 
 	totspeed = 0; /*total bitrate of the bundle*/
 	nfree = 0; /* # channels which have no packet already queued */
@@ -1735,17 +1778,21 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 			pch->avail = 1;
 		}
 
-		/* check the channel's mtu and whether it is still attached. */
-		spin_lock_bh(&pch->downl);
-		if (pch->chan == NULL) {
-			/* can't use this channel, it's being deregistered */
+		locked = ppp_channel_lock_bh(&pch->downl);
+		if (!locked || !pch->chan) {
+			/* can't use this channel, it's being deregistered
+			 * or fail to lock the channel
+			 */
 			if (pch->speed == 0)
 				nzero--;
 			else
 				totspeed -= pch->speed;
 
-			spin_unlock_bh(&pch->downl);
-			pch->avail = 0;
+			if (locked) {
+				/* channel is deregistered */
+				ppp_channel_unlock_bh(&pch->downl);
+				pch->avail = 0;
+			}
 			totlen = len;
 			totfree--;
 			nfree--;
@@ -1795,7 +1842,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		 */
 		if (flen <= 0) {
 			pch->avail = 2;
-			spin_unlock_bh(&pch->downl);
+			ppp_channel_unlock_bh(&pch->downl);
 			continue;
 		}
 
@@ -1840,14 +1887,14 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		len -= flen;
 		++ppp->nxseq;
 		bits = 0;
-		spin_unlock_bh(&pch->downl);
+		ppp_channel_unlock_bh(&pch->downl);
 	}
 	ppp->nxchan = i;
 
 	return 1;
 
  noskb:
-	spin_unlock_bh(&pch->downl);
+	ppp_channel_unlock_bh(&pch->downl);
 	if (ppp->debug & 1)
 		netdev_err(ppp->dev, "PPP: no memory (fragment)\n");
 	++ppp->dev->stats.tx_errors;
@@ -1865,7 +1912,8 @@ ppp_channel_push(struct channel *pch)
 	struct sk_buff *skb;
 	struct ppp *ppp;
 
-	spin_lock_bh(&pch->downl);
+	if (unlikely(!ppp_channel_lock_bh(&pch->downl)))
+		return;
 	if (pch->chan) {
 		while (!skb_queue_empty(&pch->file.xq)) {
 			skb = skb_dequeue(&pch->file.xq);
@@ -1879,7 +1927,7 @@ ppp_channel_push(struct channel *pch)
 		/* channel got deregistered */
 		skb_queue_purge(&pch->file.xq);
 	}
-	spin_unlock_bh(&pch->downl);
+	ppp_channel_unlock_bh(&pch->downl);
 	/* see if there is anything from the attached unit to be sent */
 	if (skb_queue_empty(&pch->file.xq)) {
 		read_lock_bh(&pch->upl);
@@ -2520,7 +2568,7 @@ int ppp_register_net_channel(struct net *net, struct ppp_channel *chan)
 	pch->lastseq = -1;
 #endif /* CONFIG_PPP_MULTILINK */
 	init_rwsem(&pch->chan_sem);
-	spin_lock_init(&pch->downl);
+	ppp_channel_lock_init(&pch->downl);
 	rwlock_init(&pch->upl);
 
 	spin_lock_bh(&pn->all_channels_lock);
@@ -2599,9 +2647,12 @@ ppp_unregister_channel(struct ppp_channel *chan)
 	 * the channel's start_xmit or ioctl routine before we proceed.
 	 */
 	down_write(&pch->chan_sem);
-	spin_lock_bh(&pch->downl);
+	if (unlikely(!ppp_channel_lock_bh(&pch->downl))) {
+		up_write(&pch->chan_sem);
+		return;
+	}
 	pch->chan = NULL;
-	spin_unlock_bh(&pch->downl);
+	ppp_channel_unlock_bh(&pch->downl);
 	up_write(&pch->chan_sem);
 	ppp_disconnect_channel(pch);
 
-- 
1.9.1
