From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 20/24] [IPSEC]: Add async resume support on output
Date: Wed, 07 Nov 2007 22:08:37 +0800
Message-ID: <E1Ipla9-0001IX-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3790 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758230AbXKGO1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:27:06 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Add async resume support on output

This patch adds support for async resumptions on output.  To do so, the
transform would return -EINPROGRESS and subsequently invoke the function
xfrm_output_resume to resume processing.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h     |    1 
 net/xfrm/xfrm_output.c |   57 ++++++++++++++++++++++++++++++++++---------------
 2 files changed, 41 insertions(+), 17 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e674a78..b6c26da 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1119,6 +1119,7 @@ extern void xfrm_replay_notify(struct xfrm_state *x, int event);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
+extern int xfrm_output_resume(struct sk_buff *skb, int err);
 extern int xfrm_output(struct sk_buff *skb);
 extern int xfrm4_extract_header(struct sk_buff *skb);
 extern int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index bcb3701..048d240 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -18,6 +18,8 @@
 #include <net/dst.h>
 #include <net/xfrm.h>
 
+static int xfrm_output2(struct sk_buff *skb);
+
 static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
@@ -41,17 +43,13 @@ err:
 	return err;
 }
 
-static int xfrm_output_one(struct sk_buff *skb)
+static int xfrm_output_one(struct sk_buff *skb, int err)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
-	int err;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		err = skb_checksum_help(skb);
-		if (err)
-			goto error_nolock;
-	}
+	if (err <= 0)
+		goto resume;
 
 	do {
 		err = x->outer_mode->output(x, skb);
@@ -75,6 +73,8 @@ static int xfrm_output_one(struct sk_buff *skb)
 		spin_unlock_bh(&x->lock);
 
 		err = x->type->output(x, skb);
+
+resume:
 		if (err)
 			goto error_nolock;
 
@@ -97,18 +97,16 @@ error_nolock:
 	goto out_exit;
 }
 
-static int xfrm_output2(struct sk_buff *skb)
+int xfrm_output_resume(struct sk_buff *skb, int err)
 {
-	int err;
-
-	while (likely((err = xfrm_output_one(skb)) == 0)) {
+	while (likely((err = xfrm_output_one(skb, err)) == 0)) {
 		struct xfrm_state *x;
 
 		nf_reset(skb);
 
 		err = skb->dst->ops->local_out(skb);
 		if (unlikely(err != 1))
-			break;
+			goto out;
 
 		x = skb->dst->xfrm;
 		if (!x)
@@ -118,18 +116,25 @@ static int xfrm_output2(struct sk_buff *skb)
 			      x->inner_mode->afinfo->nf_post_routing, skb,
 			      NULL, skb->dst->dev, xfrm_output2);
 		if (unlikely(err != 1))
-			break;
+			goto out;
 	}
 
+	if (err == -EINPROGRESS)
+		err = 0;
+
+out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(xfrm_output_resume);
 
-int xfrm_output(struct sk_buff *skb)
+static int xfrm_output2(struct sk_buff *skb)
 {
-	struct sk_buff *segs;
+	return xfrm_output_resume(skb, 1);
+}
 
-	if (!skb_is_gso(skb))
-		return xfrm_output2(skb);
+static int xfrm_output_gso(struct sk_buff *skb)
+{
+	struct sk_buff *segs;
 
 	segs = skb_gso_segment(skb, 0);
 	kfree_skb(skb);
@@ -157,4 +162,22 @@ int xfrm_output(struct sk_buff *skb)
 
 	return 0;
 }
+
+int xfrm_output(struct sk_buff *skb)
+{
+	int err;
+
+	if (skb_is_gso(skb))
+		return xfrm_output_gso(skb);
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		err = skb_checksum_help(skb);
+		if (err) {
+			kfree_skb(skb);
+			return err;
+		}
+	}
+
+	return xfrm_output2(skb);
+}
 EXPORT_SYMBOL_GPL(xfrm_output);
