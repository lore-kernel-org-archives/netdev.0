From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH ipsec v2] xfrm: prevent ipcomp scratch buffer race condition
Date: Tue, 15 Oct 2013 23:40:30 +0200 (CEST)
Message-ID: <20131015214030.B0D06E8A60@unicorn.suse.cz>
References: <20131015083348.GW7660@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36297 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933181Ab3JOVkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 17:40:32 -0400
In-Reply-To: <20131015083348.GW7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipcomp_compress(), sortirq is enabled too early, allowing the
per-cpu scratch buffer to be rewritten by ipcomp_decompress()
(called on the same CPU in softirq context) between populating
the buffer and copying the compressed data to the skb.

Add similar protection into ipcomp_decompress() as it can be
called from process context as well (even if such scenario seems
a bit artificial).

v2: as pointed out by Steffen Klassert, if we also move the
local_bh_disable() before reading the per-cpu pointers, we can
get rid of get_cpu()/put_cpu().

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/xfrm/xfrm_ipcomp.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index 2906d52..9fe4f42 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -45,12 +45,17 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 	const int plen = skb->len;
 	int dlen = IPCOMP_SCRATCH_SIZE;
 	const u8 *start = skb->data;
-	const int cpu = get_cpu();
-	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
-	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
-	int err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
+	struct crypto_comp *tfm;
+	u8 *scratch;
+	int cpu;
+	int err;
 	int len;
 
+	local_bh_disable();
+	cpu = smp_processor_id();
+	scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
+	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
+	err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
 	if (err)
 		goto out;
 
@@ -103,7 +108,7 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 	err = 0;
 
 out:
-	put_cpu();
+	local_bh_enable();
 	return err;
 }
 
@@ -141,14 +146,16 @@ static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
 	const int plen = skb->len;
 	int dlen = IPCOMP_SCRATCH_SIZE;
 	u8 *start = skb->data;
-	const int cpu = get_cpu();
-	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
-	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
+	struct crypto_comp *tfm;
+	u8 *scratch;
+	int cpu;
 	int err;
 
 	local_bh_disable();
+	cpu = smp_processor_id();
+	scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
+	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
 	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
-	local_bh_enable();
 	if (err)
 		goto out;
 
@@ -158,13 +165,13 @@ static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
 	}
 
 	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
-	put_cpu();
+	local_bh_enable();
 
 	pskb_trim(skb, dlen + sizeof(struct ip_comp_hdr));
 	return 0;
 
 out:
-	put_cpu();
+	local_bh_enable();
 	return err;
 }
 
-- 
1.8.1.4
