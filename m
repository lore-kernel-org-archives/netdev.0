From: Andy Zhou <azhou@nicira.com>
Subject: [patch net-next v2 2/5] net: add ipv6_select_ident_by_addr() API
Date: Tue, 10 Mar 2015 12:07:15 -0700
Message-ID: <1426014438-9317-3-git-send-email-azhou@nicira.com>
References: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:48671 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751330AbbCJTQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 15:16:42 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so4489821pdj.8
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 12:16:40 -0700 (PDT)
In-Reply-To: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the route information is not available but IPv6 identification
field needs to be calculated, for example, in ipv6 fragmentation. This
new API can used.

The current ipv6_select_ident() is kept as is. Its implementation now
calls the new API.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/ipv6.h     |  5 ++++-
 net/ipv6/output_core.c | 14 +++++++++++---
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index b767306..db92dc7 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -671,7 +671,10 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
-void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
+void ipv6_select_ident(struct frag_hdr *fhdr, const struct rt6_info *rt);
+void ipv6_select_ident_by_addr(struct frag_hdr *fhdr,
+			       const struct in6_addr *dst,
+			       const struct in6_addr *src);
 void ipv6_proxy_select_ident(struct sk_buff *skb);
 
 int ip6_dst_hoplimit(struct dst_entry *dst);
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 86ff1cf..6dd4ab2 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -59,17 +59,25 @@ void ipv6_proxy_select_ident(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
 
-void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
+void ipv6_select_ident_by_addr(struct frag_hdr *fhdr,
+			       const struct in6_addr *dst,
+			       const struct in6_addr *src)
 {
 	static u32 ip6_idents_hashrnd __read_mostly;
 	u32 id;
 
 	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
 
-	id = __ipv6_select_ident(ip6_idents_hashrnd, &rt->rt6i_dst.addr,
-				 &rt->rt6i_src.addr);
+	id = __ipv6_select_ident(ip6_idents_hashrnd, dst, src);
 	fhdr->identification = htonl(id);
 }
+EXPORT_SYMBOL(ipv6_select_ident_by_addr);
+
+void ipv6_select_ident(struct frag_hdr *fhdr, const struct rt6_info *rt)
+{
+	ipv6_select_ident_by_addr(fhdr, &rt->rt6i_dst.addr,
+				  &rt->rt6i_src.addr);
+}
 EXPORT_SYMBOL(ipv6_select_ident);
 
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
-- 
1.9.1
