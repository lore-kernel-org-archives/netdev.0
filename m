From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Mon, 14 Oct 2013 18:03:34 +0200 (CEST)
Message-ID: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34638 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906Ab3JNQDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:03:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipcomp_compress(), sortirq is enabled too early, allowing the
per-cpu scratch buffer to be rewritten by ipcomp_decompress()
(called on the same CPU in softirq context) between populating
the buffer and copying the compressed data to the skb.

Add similar protection into ipcomp_decompress() as it can be
called from process context as well (even if such scenario seems
a bit artificial).

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/xfrm/xfrm_ipcomp.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index 2906d52..96946fb 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -48,9 +48,11 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 	const int cpu = get_cpu();
 	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
 	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
-	int err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
+	int err;
 	int len;
 
+	local_bh_disable();
+	err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
 	if (err)
 		goto out;
 
@@ -103,6 +105,7 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 	err = 0;
 
 out:
+	local_bh_enable();
 	put_cpu();
 	return err;
 }
@@ -148,7 +151,6 @@ static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
 
 	local_bh_disable();
 	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
-	local_bh_enable();
 	if (err)
 		goto out;
 
@@ -158,12 +160,14 @@ static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
 	}
 
 	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
+	local_bh_enable();
 	put_cpu();
 
 	pskb_trim(skb, dlen + sizeof(struct ip_comp_hdr));
 	return 0;
 
 out:
+	local_bh_enable();
 	put_cpu();
 	return err;
 }
-- 
1.8.1.4
