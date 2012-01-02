From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v5 PATCH 1/3] NETFILTER added flags to __ipv6_find_hdr()
Date: Mon, 2 Jan 2012 16:06:39 +0100
Message-ID: <1325516801-25488-2-git-send-email-hans.schillstrom@ericsson.com>
References: <1325516801-25488-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <kaber@trash.net>, <pablo@netfilter.org>, <jengelh@medozas.de>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:62672 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab2ABPGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 10:06:46 -0500
In-Reply-To: <1325516801-25488-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two new flags to __ipv6_find_hdr,
One that tells us that this is a fragemnt.
One that stops at AH if any i.e. treat it like a transport header.
i.e. make handling of ESP and AH the same.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/linux/netfilter_ipv6/ip6_tables.h |   16 ++++++++++++++--
 net/ipv6/netfilter/ip6_tables.c           |   19 ++++++++++++++-----
 2 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index f549adc..ee0c68e 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -288,9 +288,21 @@ extern unsigned int ip6t_do_table(struct sk_buff *skb,
 
 /* Check for an extension */
 extern int ip6t_ext_hdr(u8 nexthdr);
+enum {
+	IP6T_FH_FRAG,
+	IP6T_FH_AUTH,
+	IP6T_FH_F_FRAG = 1 << IP6T_FH_FRAG,
+	IP6T_FH_F_AUTH = 1 << IP6T_FH_AUTH,
+};
 /* find specified header and get offset to it */
-extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
-			 int target, unsigned short *fragoff);
+extern int __ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
+			 int target, unsigned short *fragoff, int *fragflg);
+
+static inline int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
+		  int target, unsigned short *fragoff)
+{
+	return __ipv6_find_hdr(skb, offset, target, fragoff, NULL);
+}
 
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 94874b0..8729bff 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -2302,9 +2302,13 @@ static void __exit ip6_tables_fini(void)
  * *offset is meaningless and fragment offset is stored in *fragoff if fragoff
  * isn't NULL.
  *
+ * if flags != NULL AND
+ *    it's a fragment the frag flag "IP6T_FH_F_FRAG" will be set
+ *    it's an AH header and IP6T_FH_F_AUTH is set and target < 0
+ *      stop at AH (i.e. treat is as a transport header)
  */
-int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
-		  int target, unsigned short *fragoff)
+int __ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
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
@@ -2367,7 +2376,7 @@ EXPORT_SYMBOL(ip6t_register_table);
 EXPORT_SYMBOL(ip6t_unregister_table);
 EXPORT_SYMBOL(ip6t_do_table);
 EXPORT_SYMBOL(ip6t_ext_hdr);
-EXPORT_SYMBOL(ipv6_find_hdr);
+EXPORT_SYMBOL(__ipv6_find_hdr);
 
 module_init(ip6_tables_init);
 module_exit(ip6_tables_fini);
-- 
1.7.2.3
