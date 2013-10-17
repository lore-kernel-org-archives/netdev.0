From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH ipsec v3] xfrm: prevent ipcomp scratch buffer race condition
Date: Thu, 17 Oct 2013 15:07:40 +0200 (CEST)
Message-ID: <20131017130740.D8741E8A5E@unicorn.suse.cz>
References: <20131017095502.GD7660@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58279 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574Ab3JQNHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 09:07:42 -0400
In-Reply-To: <20131017095502.GD7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipcomp_compress(), sortirq is enabled too early, allowing the
per-cpu scratch buffer to be rewritten by ipcomp_decompress()
(called on the same CPU in softirq context) between populating
the buffer and copying the compressed data to the skb.

v2: as pointed out by Steffen Klassert, if we also move the
local_bh_disable() before reading the per-cpu pointers, we can
get rid of get_cpu()/put_cpu().

v3: removed ipcomp_decompress part (as explained by Herbert Xu,
it cannot be called from process context), get rid of cpu
variable (thanks to Eric Dumazet)

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/xfrm/xfrm_ipcomp.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index 2906d52..3be02b6 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -141,14 +141,14 @@ static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
 	const int plen = skb->len;
 	int dlen = IPCOMP_SCRATCH_SIZE;
 	u8 *start = skb->data;
-	const int cpu = get_cpu();
-	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
-	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
+	struct crypto_comp *tfm;
+	u8 *scratch;
 	int err;
 
 	local_bh_disable();
+	scratch = *this_cpu_ptr(ipcomp_scratches);
+	tfm = *this_cpu_ptr(ipcd->tfms);
 	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
-	local_bh_enable();
 	if (err)
 		goto out;
 
@@ -158,13 +158,13 @@ static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
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
