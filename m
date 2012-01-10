From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v6 PATCH 1/3] NETFILTER added flags to ipv6_find_hdr()
Date: Tue, 10 Jan 2012 14:20:04 +0100
Message-ID: <1326201606-17241-2-git-send-email-hans.schillstrom@ericsson.com>
References: <1326201606-17241-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <kaber@trash.net>, <pablo@netfilter.org>, <jengelh@medozas.de>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1326201606-17241-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two new flags to ipv6_find_hdr,
One that tells us that this is a fragment.
One that stops at AH if any i.e. treat it like a transport header.
i.e. make handling of ESP and AH the same.

Version 2:
    wrapper removed and changes made at every call.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/linux/netfilter_ipv6/ip6_tables.h |    8 +++++++-
 net/ipv6/netfilter/ip6_tables.c           |   17 +++++++++++++----
 net/ipv6/netfilter/ip6t_ah.c              |    2 +-
 net/ipv6/netfilter/ip6t_frag.c            |    2 +-
 net/ipv6/netfilter/ip6t_hbh.c             |    2 +-
 net/ipv6/netfilter/ip6t_rt.c              |    2 +-
 net/netfilter/xt_TPROXY.c                 |    2 +-
 net/netfilter/xt_socket.c                 |    2 +-
 8 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index f549adc..e1ad013 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -288,9 +288,15 @@ extern unsigned int ip6t_do_table(struct sk_buff *skb,
 
 /* Check for an extension */
 extern int ip6t_ext_hdr(u8 nexthdr);
+enum {
+	IP6T_FH_FRAG,
+	IP6T_FH_AUTH,
+	IP6T_FH_F_FRAG = 1 << IP6T_FH_FRAG,
+	IP6T_FH_F_AUTH = 1 << IP6T_FH_AUTH,
+};
 /* find specified header and get offset to it */
 extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
-			 int target, unsigned short *fragoff);
+			 int target, unsigned short *fragoff, int *fragflg);
 
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 94874b0..96a49ba 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -146,7 +146,7 @@ ip6_packet_match(const struct sk_buff *skb,
 		int protohdr;
 		unsigned short _frag_off;
 
-		protohdr = ipv6_find_hdr(skb, protoff, -1, &_frag_off);
+		protohdr = ipv6_find_hdr(skb, protoff, -1, &_frag_off, NULL);
 		if (protohdr < 0) {
 			if (_frag_off == 0)
 				*hotdrop = true;
@@ -2302,9 +2302,13 @@ static void __exit ip6_tables_fini(void)
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
@@ -2329,6 +2333,9 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 		if (nexthdr == NEXTHDR_FRAGMENT) {
 			unsigned short _frag_off;
 			__be16 *fp;
+
+			if (flags)	/* Indicate that this is a fragment */
+				*flags |= IP6T_FH_F_FRAG;
 			fp = skb_header_pointer(skb,
 						start+offsetof(struct frag_hdr,
 							       frag_off),
@@ -2349,9 +2356,11 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
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
index 89cccc5..f321c1e 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -45,7 +45,7 @@ static bool ah_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	unsigned int hdrlen = 0;
 	int err;
 
-	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_AUTH, NULL);
+	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_AUTH, NULL, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
 			par->hotdrop = true;
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index eda898f..7454e60 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -43,7 +43,7 @@ frag_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	unsigned int ptr;
 	int err;
 
-	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_FRAGMENT, NULL);
+	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_FRAGMENT, NULL, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
 			par->hotdrop = true;
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index 59df051..e9329c2 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -62,7 +62,7 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 
 	err = ipv6_find_hdr(skb, &ptr,
 			    (par->match == &hbh_mt6_reg[0]) ?
-			    NEXTHDR_HOP : NEXTHDR_DEST, NULL);
+			    NEXTHDR_HOP : NEXTHDR_DEST, NULL, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
 			par->hotdrop = true;
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index d8488c5..ffa9958 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -49,7 +49,7 @@ static bool rt_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct in6_addr *ap;
 	int err;
 
-	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_ROUTING, NULL);
+	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_ROUTING, NULL, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
 			par->hotdrop = true;
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 35a959a..7898b57 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -285,7 +285,7 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	int thoff;
 	int tproto;
 
-	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
+	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
 	if (tproto < 0) {
 		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
 		return NF_DROP;
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 72bb07f..d5c36cc 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -266,7 +266,7 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 	int thoff, tproto;
 	const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
 
-	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
+	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
 	if (tproto < 0) {
 		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
 		return NF_DROP;
-- 
1.7.2.3

