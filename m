From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH 1/2] net: Cache IPv6 extension header "skip" parsing
Date: Mon, 03 Sep 2012 23:16:26 +0200
Message-ID: <20120903211602.8851.2843.stgit@dragon>
References: <20120903211504.8851.6894.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: "Patrick McHardy" <kaber@trash.net>,
	Hans Schillstrom <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120903211504.8851.6894.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Store IPv6 exthdr data from ipv6_find_hdr() in skb->cb[].

Introducing struct inet6_skb_exthdr_cache / IP6CB_EXTHDR, as its not
possible to extend inet6_skb_parm directly, or else DCCP dccp_skb_cb
CB size gets too big.

Adding:
 __u16	thoff;   /* L4 Transport Header offset */
 __s16	protocol;/* L4 protocol */
 __u16	fragoff; /* packet is a fragment, with offset */

Optimize ip6t_do_table() by using the new ipv6_find_hdr_cb() in
ip6_packet_match().  Before ipv6_find_hdr() were called for each
iptables rule, with a "-p" protocol option (including -p all), which
is very commonly used. The function ipv6_find_hdr_cb() is inlined to
optimize this case and avoid a function call.

The inet6_skb_exthdr_cache / IP6CB_EXTHDR is added to linux/ipv6.h in
the hope that ipv6_skip_exthdr() might also take advantage of this, in
the future.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
Can someone tell me if netfilter (with all of its different HOOKs) can be
allowed to modify data after inet6_skb_parm/IP6CB ???


 include/linux/ipv6.h                      |   15 +++++++++++
 include/linux/netfilter_ipv6/ip6_tables.h |   40 +++++++++++++++++++++++++++++
 net/ipv6/netfilter/ip6_tables.c           |    2 +
 3 files changed, 56 insertions(+), 1 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0b94e91..21d8cc3 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -266,6 +266,21 @@ struct inet6_skb_parm {
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
 #define IP6CBMTU(skb)	((struct ip6_mtuinfo *)((skb)->cb))
 
+/* Caching of exthdr info
+ * - This is used by netfilter and IPVS.
+ * (cannot extend inet6_skb_parm directly due to DCCP CB size gets too big)
+ */
+struct inet6_skb_exthdr_cache {
+	union {
+		struct inet6_skb_parm	h6;
+	} header;
+	/* Caching IPv6 exthdr "skip" info */
+	__u16	thoff;   /* L4 Transport Header offset */
+	__s16	protocol;/* L4 protocol */
+	__u16	fragoff; /* packet is a fragment, with offset */
+};
+#define IP6CB_EXTHDR(skb) ((struct inet6_skb_exthdr_cache*)((skb)->cb))
+
 static inline int inet6_iif(const struct sk_buff *skb)
 {
 	return IP6CB(skb)->iif;
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 08c2cbb..5209aff 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -303,6 +303,46 @@ enum {
 	IP6T_FH_F_AUTH	= (1 << 1),
 };
 
+/* Function caches IPv6 exthdr data from ipv6_find_hdr() in skb->cb[]
+ * - uses inet6_skb_exthdr_cache / IP6CB_EXTHDR
+ */
+static inline int
+ipv6_find_hdr_cb(const struct sk_buff *skb, unsigned int *offset,
+		 int target, unsigned short *fragoff, int *flags)
+{
+	struct inet6_skb_exthdr_cache *exthdr_cache = IP6CB_EXTHDR(skb);
+	__s16 protocol;
+
+	/* Only cache the "skip" exthdr usage */
+	if (target > 0) /* looking for a specific nexthdr target */
+		goto no_cache;
+	if (*offset) /* start at a specific offset */
+		goto no_cache;
+	if (flags) /* not caching flags at the moment */
+		goto no_cache;
+
+	/* Use thoff (transport header) as cache avail indicator */
+	if (exthdr_cache->thoff > 0) {
+		*offset  = exthdr_cache->thoff;
+		protocol = exthdr_cache->protocol;
+		if (fragoff)
+			*fragoff = exthdr_cache->fragoff;
+		return protocol;
+	}
+
+	protocol = ipv6_find_hdr(skb, offset, target, fragoff, flags);
+	if (protocol > 0) {
+                /* save a copy in the CB */
+		exthdr_cache->thoff = *offset;
+		exthdr_cache->protocol = protocol;
+		if (fragoff)
+			exthdr_cache->fragoff = *fragoff;
+	}
+	return protocol;
+no_cache:
+	return ipv6_find_hdr(skb, offset, target, fragoff, flags);
+}
+
 /* find specified header and get offset to it */
 extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 			 int target, unsigned short *fragoff, int *fragflg);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index d7cb045..79367f2 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -133,7 +133,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		int protohdr;
 		unsigned short _frag_off;
 
-		protohdr = ipv6_find_hdr(skb, protoff, -1, &_frag_off, NULL);
+		protohdr = ipv6_find_hdr_cb(skb, protoff, -1, &_frag_off, NULL);
 		if (protohdr < 0) {
 			if (_frag_off == 0)
 				*hotdrop = true;

