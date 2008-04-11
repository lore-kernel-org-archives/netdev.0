From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH take2][NET_SCHED] cls_u32: refcounting fix for u32_delete()
Date: Fri, 11 Apr 2008 13:48:18 +0000
Message-ID: <20080411134818.GA3776@ff.dom.local>
References: <20080411124519.GA2701@ff.dom.local> <47FF5FBF.6030802@trash.net> <20080411132304.GB2701@ff.dom.local> <47FF662B.2040302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:21028 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbYDKNpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:45:54 -0400
Received: by nf-out-0910.google.com with SMTP id g13so185736nfb.21
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 06:45:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47FF662B.2040302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 03:22:51PM +0200, Patrick McHardy wrote:
...
> I'd suggest to behave similar to qdiscs when trying to
> removing classes that are still referenced, return -EBUSY.

Of course you are right!

Jarek P.

-------------------> (take 2)

[NET_SCHED] cls_u32: refcounting fix for u32_delete()

Deleting of nonroot hnodes mostly doesn't work in u32_delete():
refcnt == 1 is expected, but such hnodes' refcnts are initialized
with 0 and charged only with "link" nodes. Now they'll start with
1 like usual. Thanks to Patrick McHardy for an improving suggestion.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>

---

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index c5c16b4..4d75544 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -411,8 +411,10 @@ static void u32_destroy(struct tcf_proto *tp)
 			}
 		}
 
-		for (ht=tp_c->hlist; ht; ht = ht->next)
+		for (ht = tp_c->hlist; ht; ht = ht->next) {
+			ht->refcnt--;
 			u32_clear_hnode(tp, ht);
+		}
 
 		while ((ht = tp_c->hlist) != NULL) {
 			tp_c->hlist = ht->next;
@@ -441,8 +443,12 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 	if (tp->root == ht)
 		return -EINVAL;
 
-	if (--ht->refcnt == 0)
+	if (ht->refcnt == 1) {
+		ht->refcnt--;
 		u32_destroy_hnode(tp, ht);
+	} else {
+		return -EBUSY;
+	}
 
 	return 0;
 }
@@ -568,7 +574,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 		if (ht == NULL)
 			return -ENOBUFS;
 		ht->tp_c = tp_c;
-		ht->refcnt = 0;
+		ht->refcnt = 1;
 		ht->divisor = divisor;
 		ht->handle = handle;
 		ht->prio = tp->prio;
