From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: [PATCH] Fix slab corruption with netem (2nd try)
Date: Sun, 16 Jul 2006 23:56:31 +0200
Message-ID: <44BAB60F.7060600@yahoo.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010503000401020607070909"
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:40400 "EHLO smtp4-g19.free.fr")
	by vger.kernel.org with ESMTP id S1750836AbWGPVzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2006 17:55:23 -0400
Received: from [192.168.0.4] (bar06-2-82-224-157-131.fbx.proxad.net [82.224.157.131])
	by smtp4-g19.free.fr (Postfix) with ESMTP id B5EA5547E9
	for <netdev@vger.kernel.org>; Sun, 16 Jul 2006 23:55:22 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010503000401020607070909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

CONFIG_DEBUG_SLAB found the following bug:
netem_enqueue() in sch_netem.c gets a pointer inside a slab object:
struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
But then, the slab object may be freed:
skb = skb_unshare(skb, GFP_ATOMIC)
cb is still pointing inside the freed skb, so here is a patch to
initialize cb later, and make it clear that initializing it sooner
is a bad idea.

[From Stephen Hemminger: leave cb unitialized in order to let gcc
complain in case of use before initialization]

Thanks.

-- 
Guillaume




--------------010503000401020607070909
Content-Type: text/x-patch;
 name="netem_cb_initialization.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netem_cb_initialization.diff"

Signed-off-by: Guillaume Chazarain <guichaz@yahoo.fr>
---
 net/sched/sch_netem.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff -r 1b8d63e34819 net/sched/sch_netem.c
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -148,7 +148,8 @@ static int netem_enqueue(struct sk_buff 
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
+	/* We don't fill cb now as skb_unshare() may invalidate it */
+	struct netem_skb_cb *cb;
 	struct sk_buff *skb2;
 	int ret;
 	int count = 1;
@@ -200,6 +201,7 @@ static int netem_enqueue(struct sk_buff 
 		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
 	}
 
+	cb = (struct netem_skb_cb *)skb->cb;
 	if (q->gap == 0 		/* not doing reordering */
 	    || q->counter < q->gap 	/* inside last reordering gap */
 	    || q->reorder < get_crandom(&q->reorder_cor)) {


--------------010503000401020607070909--
