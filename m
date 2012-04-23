From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v12 PATCH 1/3] NETFILTER added flags to ipv6_find_hdr()
Date: Mon, 23 Apr 2012 15:35:26 +0200
Message-ID: <1335188128-23645-2-git-send-email-hans.schillstrom@ericsson.com>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <kaber@trash.net>, <jengelh@medozas.de>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:60549 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343Ab2DWNfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 09:35:36 -0400
In-Reply-To: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two new flags to ipv6_find_hdr,
One that tells us that this is a fragment.
One that stops at AH if any i.e. treat it like a transport header.
i.e. make handling of ESP and AH the same.
Param offset can now point to an inner icmp ipv5 header.

Version 3:
    offset param into ipv6_find_hdr set to zero.

Version 2:
    wrapper removed and changes made at every call.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/linux/netfilter_ipv6/ip6_tables.h |   12 +++++++++-
 net/ipv6/netfilter/ip6_tables.c           |   35 ++++++++++++++++++++++++----
 net/ipv6/netfilter/ip6t_ah.c              |    4 +-
 net/ipv6/netfilter/ip6t_frag.c            |    4 +-
 net/ipv6/netfilter/ip6t_hbh.c             |    4 +-
 net/ipv6/netfilter/ip6t_rt.c              |    4 +-
 net/netfilter/xt_TPROXY.c                 |    4 +-
 net/netfilter/xt_socket.c                 |    4 +-
 8 files changed, 53 insertions(+), 18 deletions(-)

diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 1bc898b..d96a39d 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -287,6 +287,7 @@ extern unsigned int ip6t_do_table(struct sk_buff *skb,
 				  struct xt_table *table);
 
 /* Check for an extension */
+
 static inline int
 ip6t_ext_hdr(u8 nexthdr)
 {	return (nexthdr == IPPROTO_HOPOPTS) ||
@@ -298,9 +299,18 @@ ip6t_ext_hdr(u8 nexthdr)
 	       (nexthdr == IPPROTO_DSTOPTS);
 }
 
+
+extern int ip6t_ext_hdr(u8 nexthdr);
+enum {
+	IP6T_FH_FRAG,
+	IP6T_FH_AUTH,
+	IP6T_FH_F_FRAG = 1 << IP6T_FH_FRAG,
+	IP6T_FH_F_AUTH = 1 << IP6T_FH_AUTH,
+};
+
 /* find specified header and get offset to it */
 extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
-			 int target, unsigned short *fragoff);
+			 int target, unsigned short *fragoff, int *fragflg);
 
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index d4e350f..1f18662 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -133,7 +133,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		int protohdr;
 		unsigned short _frag_off;
 
-		protohdr = ipv6_find_hdr(skb, protoff, -1, &_frag_off);
+		protohdr = ipv6_find_hdr(skb, protoff, -1, &_frag_off, NULL);
 		if (protohdr < 0) {
 			if (_frag_off == 0)
 				*hotdrop = true;
@@ -362,6 +362,7 @@ ip6t_do_table(struct sk_buff *skb,
 		const struct xt_entry_match *ematch;
 
 		IP_NF_ASSERT(e);
+		acpar.thoff = 0;
 		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
 		    &acpar.thoff, &acpar.fragoff, &acpar.hotdrop)) {
  no_match:
@@ -2277,6 +2278,8 @@ static void __exit ip6_tables_fini(void)
  * find the offset to specified header or the protocol number of last header
  * if target < 0. "last header" is transport protocol header, ESP, or
  * "No next header".
+ * Note, *offset is used as input param. an if != 0
+ * it must be an offset to an inner ipv6 header ex. icmp error
  *
  * If target header is found, its offset is set in *offset and return protocol
  * number. Otherwise, return -1.
@@ -2289,17 +2292,34 @@ static void __exit ip6_tables_fini(void)
  * *offset is meaningless and fragment offset is stored in *fragoff if fragoff
  * isn't NULL.
  *
+ * if flags != NULL AND
+ *    it's a fragment the frag flag "IP6T_FH_F_FRAG" will be set
+ *    it's an AH header and IP6T_FH_F_AUTH is set and target < 0
+ *      stop at AH (i.e. treat is as a transport header)
  */
 int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
-		  int target, unsigned short *fragoff)
+		  int target, unsigned short *fragoff, int *flags)
 {
 	unsigned int start = skb_network_offset(skb) + sizeof(struct ipv6hdr);
 	u8 nexthdr = ipv6_hdr(skb)->nexthdr;
-	unsigned int len = skb->len - start;
+	unsigned int len;
 
 	if (fragoff)
 		*fragoff = 0;
 
+	if (*offset) {
+		struct ipv6hdr _ip6, *ip6;
+
+		ip6 = skb_header_pointer(skb, *offset, sizeof(_ip6), &_ip6);
+		if (!ip6 || (ip6->version != 6)) {
+			printk(KERN_ERR "IPv6 header not found\n");
+			return -EBADMSG;
+		}
+		start = *offset + sizeof(struct ipv6hdr);
+		nexthdr = ip6->nexthdr;
+	}
+	len = skb->len - start;
+
 	while (nexthdr != target) {
 		struct ipv6_opt_hdr _hdr, *hp;
 		unsigned int hdrlen;
@@ -2316,6 +2336,9 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 		if (nexthdr == NEXTHDR_FRAGMENT) {
 			unsigned short _frag_off;
 			__be16 *fp;
+
+			if (flags)	/* Indicate that this is a fragment */
+				*flags |= IP6T_FH_F_FRAG;
 			fp = skb_header_pointer(skb,
 						start+offsetof(struct frag_hdr,
 							       frag_off),
@@ -2336,9 +2359,11 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 				return -ENOENT;
 			}
 			hdrlen = 8;
-		} else if (nexthdr == NEXTHDR_AUTH)
+		} else if (nexthdr == NEXTHDR_AUTH) {
+			if (flags && (*flags & IP6T_FH_F_AUTH) && (target < 0))
+				break;
 			hdrlen = (hp->hdrlen + 2) << 2;
-		else
+		} else
 			hdrlen = ipv6_optlen(hp);
 
 		nexthdr = hp->nexthdr;
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index 89cccc5..04099ab 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -41,11 +41,11 @@ static bool ah_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	struct ip_auth_hdr _ah;
 	const struct ip_auth_hdr *ah;
 	const struct ip6t_ah *ahinfo = par->matchinfo;
-	unsigned int ptr;
+	unsigned int ptr = 0;
 	unsigned int hdrlen = 0;
 	int err;
 
-	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_AUTH, NULL);
+	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_AUTH, NULL, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
 			par->hotdrop = true;
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index eda898f..3b5735e 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -40,10 +40,10 @@ frag_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	struct frag_hdr _frag;
 	const struct frag_hdr *fh;
 	const struct ip6t_frag *fraginfo = par->matchinfo;
-	unsigned int ptr;
+	unsigned int ptr = 0;
 	int err;
 
-	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_FRAGMENT, NULL);
+	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_FRAGMENT, NULL, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
 			par->hotdrop = true;
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index 59df051..01df142 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -50,7 +50,7 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct ipv6_opt_hdr *oh;
 	const struct ip6t_opts *optinfo = par->matchinfo;
 	unsigned int temp;
-	unsigned int ptr;
+	unsigned int ptr = 0;
 	unsigned int hdrlen = 0;
 	bool ret = false;
 	u8 _opttype;
@@ -62,7 +62,7 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 
 	err = ipv6_find_hdr(skb, &ptr,
 			    (par->match == &hbh_mt6_reg[0]) ?
-			    NEXTHDR_HOP : NEXTHDR_DEST, NULL);
+			    NEXTHDR_HOP : NEXTHDR_DEST, NULL, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
 			par->hotdrop = true;
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index d8488c5..2c99b94 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -42,14 +42,14 @@ static bool rt_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct ipv6_rt_hdr *rh;
 	const struct ip6t_rt *rtinfo = par->matchinfo;
 	unsigned int temp;
-	unsigned int ptr;
+	unsigned int ptr = 0;
 	unsigned int hdrlen = 0;
 	bool ret = false;
 	struct in6_addr _addr;
 	const struct in6_addr *ap;
 	int err;
 
-	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_ROUTING, NULL);
+	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_ROUTING, NULL, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
 			par->hotdrop = true;
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 35a959a..146033a 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -282,10 +282,10 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	struct sock *sk;
 	const struct in6_addr *laddr;
 	__be16 lport;
-	int thoff;
+	int thoff = 0;
 	int tproto;
 
-	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
+	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
 	if (tproto < 0) {
 		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
 		return NF_DROP;
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 72bb07f..9ea482d 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -263,10 +263,10 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 	struct sock *sk;
 	struct in6_addr *daddr, *saddr;
 	__be16 dport, sport;
-	int thoff, tproto;
+	int thoff = 0, tproto;
 	const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
 
-	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
+	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
 	if (tproto < 0) {
 		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
 		return NF_DROP;
-- 
1.7.2.3
