From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 2/2] IPv6: conntrack: Use protocol-related match routine in
 IPv6 connection track
Date: Tue, 26 Jan 2010 10:31:16 +0800
Message-ID: <4B5E53F4.4020106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61256 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753390Ab0AZCce (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 21:32:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IPv6 connection track and IPv6 stack separately use a different queue to 
manage received fragments. So using protocol-related match routine.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/net/ipv6.h                      |    1 -
 net/ipv6/netfilter/nf_conntrack_reasm.c |   13 ++++++++++++-
 net/ipv6/reassembly.c                   |    3 +--
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ccab594..cbd768b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -365,7 +365,6 @@ struct ip6_create_arg {
 };
 
 void ip6_frag_init(struct inet_frag_queue *q, void *a);
-int ip6_frag_match(struct inet_frag_queue *q, void *a);
 
 static inline int ipv6_addr_any(const struct in6_addr *a)
 {
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 312c20a..66b6161 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -146,6 +146,17 @@ static void nf_ct_frag6_evictor(void)
 	local_bh_enable();
 }
 
+static int nf_ct_frag_match(struct inet_frag_queue *q, void *a)
+{
+	struct nf_ct_frag6_queue *fq;
+	struct ip6_create_arg *arg = a;
+	fq = container_of(q, struct nf_ct_frag6_queue, q);
+
+	return (fq->id == arg->id &&
+		ipv6_addr_equal(&fq->saddr, arg->src) &&
+		ipv6_addr_equal(&fq->daddr, arg->dst));
+}
+
 static void nf_ct_frag6_expire(unsigned long data)
 {
 	struct nf_ct_frag6_queue *fq;
@@ -665,7 +676,7 @@ int nf_ct_frag6_init(void)
 	nf_frags.destructor = NULL;
 	nf_frags.skb_free = nf_skb_free;
 	nf_frags.qsize = sizeof(struct nf_ct_frag6_queue);
-	nf_frags.match = ip6_frag_match;
+	nf_frags.match = nf_ct_frag_match;
 	nf_frags.frag_expire = nf_ct_frag6_expire;
 	nf_frags.secret_interval = 10 * 60 * HZ;
 	nf_init_frags.timeout = IPV6_FRAG_TIMEOUT;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 2cddea3..2fa4355 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -136,7 +136,7 @@ static unsigned int ip6_hashfn(struct inet_frag_queue *q)
 	return inet6_hash_frag(fq->id, &fq->saddr, &fq->daddr, ip6_frags.rnd);
 }
 
-int ip6_frag_match(struct inet_frag_queue *q, void *a)
+static int ip6_frag_match(struct inet_frag_queue *q, void *a)
 {
 	struct frag_queue *fq;
 	struct ip6_create_arg *arg = a;
@@ -146,7 +146,6 @@ int ip6_frag_match(struct inet_frag_queue *q, void *a)
 			ipv6_addr_equal(&fq->saddr, arg->src) &&
 			ipv6_addr_equal(&fq->daddr, arg->dst));
 }
-EXPORT_SYMBOL(ip6_frag_match);
 
 /* Memory Tracking Functions. */
 static inline void frag_kfree_skb(struct netns_frags *nf,
-- 
1.6.3.3


