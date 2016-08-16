From: fgao@ikuai8.com
Subject: [PATCH 1/1] ppp: Fix one deadlock issue of PPP when send frame
Date: Tue, 16 Aug 2016 19:05:03 +0800
Message-ID: <1471345503-10085-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG252.QQ.COM ([183.60.52.105]:55910 "EHLO smtpbg252.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246AbcHPLGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 07:06:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

PPP channel holds one spinlock before send frame. But the skb may
select the same PPP channel with wrong route policy. As a result,
the skb reaches the same channel path. It tries to get the same
spinlock which is held before. Bang, the deadlock comes out.

Now add one lock owner to avoid it like xmit_lock_owner of
netdev_queue. Check the lock owner before try to get the spinlock.
If the current cpu is already the owner, needn't lock again. When
PPP channel holds the spinlock at the first time, it sets owner
with current CPU ID.

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
 v1: Initial Patch

 drivers/net/ppp/ppp_generic.c | 49 +++++++++++++++++++++++++++++++------------
 1 file changed, 36 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 70cfa06..ffd0233 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -162,6 +162,29 @@ struct ppp {
 			 |SC_MULTILINK|SC_MP_SHORTSEQ|SC_MP_XSHORTSEQ \
 			 |SC_COMP_TCP|SC_REJ_COMP_TCP|SC_MUST_COMP)
 
+struct chennel_lock {
+	spinlock_t lock;
+	u32 owner;
+};
+
+#define PPP_CHANNEL_LOCK_INIT(cl) \
+	cl.owner = -1; \
+	spin_lock_init(&cl.lock)
+
+#define PPP_CHANNEL_LOCK_BH(cl) \
+	do { \
+		local_bh_disable(); \
+		if (cl.owner != smp_processor_id()) { \
+			spin_lock(&cl.lock); \
+			cl.owner = smp_processor_id(); \
+		} \
+	} while (0)
+
+#define PPP_CHANNEL_UNLOCK_BH(cl) \
+	cl.owner = -1; \
+	spin_unlock(&cl.lock); \
+	local_bh_enable()
+
 /*
  * Private data structure for each channel.
  * This includes the data structure used for multilink.
@@ -171,7 +194,7 @@ struct channel {
 	struct list_head list;		/* link in all/new_channels list */
 	struct ppp_channel *chan;	/* public channel data structure */
 	struct rw_semaphore chan_sem;	/* protects `chan' during chan ioctl */
-	spinlock_t	downl;		/* protects `chan', file.xq dequeue */
+	struct chennel_lock downl;	/* protects `chan', file.xq dequeue */
 	struct ppp	*ppp;		/* ppp unit we're connected to */
 	struct net	*chan_net;	/* the net channel belongs to */
 	struct list_head clist;		/* link in list of channels per unit */
@@ -1597,7 +1620,7 @@ ppp_push(struct ppp *ppp)
 		list = list->next;
 		pch = list_entry(list, struct channel, clist);
 
-		spin_lock_bh(&pch->downl);
+		PPP_CHANNEL_LOCK_BH(pch->downl);
 		if (pch->chan) {
 			if (pch->chan->ops->start_xmit(pch->chan, skb))
 				ppp->xmit_pending = NULL;
@@ -1606,7 +1629,7 @@ ppp_push(struct ppp *ppp)
 			kfree_skb(skb);
 			ppp->xmit_pending = NULL;
 		}
-		spin_unlock_bh(&pch->downl);
+		PPP_CHANNEL_UNLOCK_BH(pch->downl);
 		return;
 	}
 
@@ -1736,7 +1759,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		}
 
 		/* check the channel's mtu and whether it is still attached. */
-		spin_lock_bh(&pch->downl);
+		PPP_CHANNEL_LOCK_BH(pch->downl);
 		if (pch->chan == NULL) {
 			/* can't use this channel, it's being deregistered */
 			if (pch->speed == 0)
@@ -1744,7 +1767,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 			else
 				totspeed -= pch->speed;
 
-			spin_unlock_bh(&pch->downl);
+			PPP_CHANNEL_UNLOCK_BH(pch->downl);
 			pch->avail = 0;
 			totlen = len;
 			totfree--;
@@ -1795,7 +1818,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		 */
 		if (flen <= 0) {
 			pch->avail = 2;
-			spin_unlock_bh(&pch->downl);
+			PPP_CHANNEL_UNLOCK_BH(pch->downl);
 			continue;
 		}
 
@@ -1840,14 +1863,14 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		len -= flen;
 		++ppp->nxseq;
 		bits = 0;
-		spin_unlock_bh(&pch->downl);
+		PPP_CHANNEL_UNLOCK_BH(pch->downl);
 	}
 	ppp->nxchan = i;
 
 	return 1;
 
  noskb:
-	spin_unlock_bh(&pch->downl);
+	PPP_CHANNEL_UNLOCK_BH(pch->downl);
 	if (ppp->debug & 1)
 		netdev_err(ppp->dev, "PPP: no memory (fragment)\n");
 	++ppp->dev->stats.tx_errors;
@@ -1865,7 +1888,7 @@ ppp_channel_push(struct channel *pch)
 	struct sk_buff *skb;
 	struct ppp *ppp;
 
-	spin_lock_bh(&pch->downl);
+	PPP_CHANNEL_LOCK_BH(pch->downl);
 	if (pch->chan) {
 		while (!skb_queue_empty(&pch->file.xq)) {
 			skb = skb_dequeue(&pch->file.xq);
@@ -1879,7 +1902,7 @@ ppp_channel_push(struct channel *pch)
 		/* channel got deregistered */
 		skb_queue_purge(&pch->file.xq);
 	}
-	spin_unlock_bh(&pch->downl);
+	PPP_CHANNEL_UNLOCK_BH(pch->downl);
 	/* see if there is anything from the attached unit to be sent */
 	if (skb_queue_empty(&pch->file.xq)) {
 		read_lock_bh(&pch->upl);
@@ -2520,7 +2543,7 @@ int ppp_register_net_channel(struct net *net, struct ppp_channel *chan)
 	pch->lastseq = -1;
 #endif /* CONFIG_PPP_MULTILINK */
 	init_rwsem(&pch->chan_sem);
-	spin_lock_init(&pch->downl);
+	PPP_CHANNEL_LOCK_INIT(pch->downl);
 	rwlock_init(&pch->upl);
 
 	spin_lock_bh(&pn->all_channels_lock);
@@ -2599,9 +2622,9 @@ ppp_unregister_channel(struct ppp_channel *chan)
 	 * the channel's start_xmit or ioctl routine before we proceed.
 	 */
 	down_write(&pch->chan_sem);
-	spin_lock_bh(&pch->downl);
+	PPP_CHANNEL_LOCK_BH(pch->downl);
 	pch->chan = NULL;
-	spin_unlock_bh(&pch->downl);
+	PPP_CHANNEL_UNLOCK_BH(pch->downl);
 	up_write(&pch->chan_sem);
 	ppp_disconnect_channel(pch);
 
-- 
1.9.1
