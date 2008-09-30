From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next] ipv6: almost identical frag hashing funcs combined
Date: Wed, 1 Oct 2008 01:57:47 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810010146001.27688@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-766920371-1222815467=:27688"
Cc: Netdev <netdev@vger.kernel.org>, Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-766920371-1222815467=:27688
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


$ diff-funcs ip6qhashfn reassembly.c netfilter/nf_conntrack_reasm.c
 --- reassembly.c:ip6qhashfn()
 +++ netfilter/nf_conntrack_reasm.c:ip6qhashfn()
@@ -1,5 +1,5 @@
-static unsigned int ip6qhashfn(__be32 id, struct in6_addr *saddr,
-			       struct in6_addr *daddr)
+static unsigned int ip6qhashfn(__be32 id, const struct in6_addr *saddr,
+			       const struct in6_addr *daddr)
 {
 	u32 a, b, c;

@@ -9,7 +9,7 @@

 	a += JHASH_GOLDEN_RATIO;
 	b += JHASH_GOLDEN_RATIO;
-	c += ip6_frags.rnd;
+	c += nf_frags.rnd;
 	__jhash_mix(a, b, c);

 	a += (__force u32)saddr->s6_addr32[3];

And codiff xx.o.old xx.o.new:

net/ipv6/netfilter/nf_conntrack_reasm.c:
  ip6qhashfn         | -512
  nf_hashfn          |   +6
  nf_ct_frag6_gather |  +36
 3 functions changed, 42 bytes added, 512 bytes removed, diff: -470
net/ipv6/reassembly.c:
  ip6qhashfn    | -512
  ip6_hashfn    |   +7
  ipv6_frag_rcv |  +89
 3 functions changed, 96 bytes added, 512 bytes removed, diff: -416

net/ipv6/reassembly.c:
  inet6_hash_frag | +510
 1 function changed, 510 bytes added, diff: +510

Total: -376

Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

Hmm, here came across git email format's limitation as it's stupid enough 
to make it impossible to have --- starting lines in the message part 
(disallowing direct quoting from anything that looks like a diff), I fixed 
(and tested with git-am) this for you already by adding space before the 
must-not-be-found line prefixes :-).

 include/net/ipv6.h                      |    2 +
 net/ipv6/netfilter/nf_conntrack_reasm.c |   32 +-----------------------------
 net/ipv6/reassembly.c                   |   11 +++++----
 3 files changed, 10 insertions(+), 35 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 113028f..dfa7ae3 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -576,6 +576,8 @@ extern int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
 extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 			 struct group_filter __user *optval,
 			 int __user *optlen);
+extern unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
+				    const struct in6_addr *daddr, u32 rnd);
 
 #ifdef CONFIG_PROC_FS
 extern int  ac6_proc_init(struct net *net);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 52d06dd..9967ac7 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -27,7 +27,6 @@
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 #include <linux/random.h>
-#include <linux/jhash.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -103,39 +102,12 @@ struct ctl_table nf_ct_ipv6_sysctl_table[] = {
 };
 #endif
 
-static unsigned int ip6qhashfn(__be32 id, const struct in6_addr *saddr,
-			       const struct in6_addr *daddr)
-{
-	u32 a, b, c;
-
-	a = (__force u32)saddr->s6_addr32[0];
-	b = (__force u32)saddr->s6_addr32[1];
-	c = (__force u32)saddr->s6_addr32[2];
-
-	a += JHASH_GOLDEN_RATIO;
-	b += JHASH_GOLDEN_RATIO;
-	c += nf_frags.rnd;
-	__jhash_mix(a, b, c);
-
-	a += (__force u32)saddr->s6_addr32[3];
-	b += (__force u32)daddr->s6_addr32[0];
-	c += (__force u32)daddr->s6_addr32[1];
-	__jhash_mix(a, b, c);
-
-	a += (__force u32)daddr->s6_addr32[2];
-	b += (__force u32)daddr->s6_addr32[3];
-	c += (__force u32)id;
-	__jhash_mix(a, b, c);
-
-	return c & (INETFRAGS_HASHSZ - 1);
-}
-
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
 {
 	const struct nf_ct_frag6_queue *nq;
 
 	nq = container_of(q, struct nf_ct_frag6_queue, q);
-	return ip6qhashfn(nq->id, &nq->saddr, &nq->daddr);
+	return inet6_hash_frag(nq->id, &nq->saddr, &nq->daddr, nf_frags.rnd);
 }
 
 static void nf_skb_free(struct sk_buff *skb)
@@ -209,7 +181,7 @@ fq_find(__be32 id, struct in6_addr *src, struct in6_addr *dst)
 	arg.dst = dst;
 
 	read_lock_bh(&nf_frags.lock);
-	hash = ip6qhashfn(id, src, dst);
+	hash = inet6_hash_frag(id, src, dst, nf_frags.rnd);
 
 	q = inet_frag_find(&nf_init_frags, &nf_frags, &arg, hash);
 	local_bh_enable();
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 89184b5..2eeadfa 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -99,8 +99,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
  * callers should be careful not to use the hash value outside the ipfrag_lock
  * as doing so could race with ipfrag_hash_rnd being recalculated.
  */
-static unsigned int ip6qhashfn(__be32 id, struct in6_addr *saddr,
-			       struct in6_addr *daddr)
+unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
+			     const struct in6_addr *daddr, u32 rnd)
 {
 	u32 a, b, c;
 
@@ -110,7 +110,7 @@ static unsigned int ip6qhashfn(__be32 id, struct in6_addr *saddr,
 
 	a += JHASH_GOLDEN_RATIO;
 	b += JHASH_GOLDEN_RATIO;
-	c += ip6_frags.rnd;
+	c += rnd;
 	__jhash_mix(a, b, c);
 
 	a += (__force u32)saddr->s6_addr32[3];
@@ -125,13 +125,14 @@ static unsigned int ip6qhashfn(__be32 id, struct in6_addr *saddr,
 
 	return c & (INETFRAGS_HASHSZ - 1);
 }
+EXPORT_SYMBOL_GPL(inet6_hash_frag);
 
 static unsigned int ip6_hashfn(struct inet_frag_queue *q)
 {
 	struct frag_queue *fq;
 
 	fq = container_of(q, struct frag_queue, q);
-	return ip6qhashfn(fq->id, &fq->saddr, &fq->daddr);
+	return inet6_hash_frag(fq->id, &fq->saddr, &fq->daddr, ip6_frags.rnd);
 }
 
 int ip6_frag_match(struct inet_frag_queue *q, void *a)
@@ -247,7 +248,7 @@ fq_find(struct net *net, __be32 id, struct in6_addr *src, struct in6_addr *dst,
 	arg.dst = dst;
 
 	read_lock(&ip6_frags.lock);
-	hash = ip6qhashfn(id, src, dst);
+	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
 	if (q == NULL)
-- 
1.5.2.2

---696208474-766920371-1222815467=:27688--
