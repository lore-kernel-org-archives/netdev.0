From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 7/44] [XFRM] STATE: Add a hook to find offset to be inserted header in outbound.
Date: Thu, 24 Aug 2006 00:02:08 +0900
Message-ID: <1156345365264-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:62088 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964921AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <1156345365651-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

On current kernel, ip6_find_1stfragopt() is used by IPv6 IPsec to find offset to
be inserted header in outbound for transport mode. (BTW, no usage may be needed for
IPv4 case.)
Mobile IPv6 requires another logic for routing header and destination options
header respectively. This patch is common platform for the offset and adopts it to
IPsec.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h              |    3 +++
 net/ipv6/ah6.c                  |    3 ++-
 net/ipv6/esp6.c                 |    3 ++-
 net/ipv6/ipcomp6.c              |    1 +
 net/ipv6/ipv6_syms.c            |    1 +
 net/ipv6/xfrm6_mode_transport.c |    2 +-
 net/ipv6/xfrm6_output.c         |    6 ++++++
 7 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bd51224..a936423 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -266,6 +266,7 @@ struct xfrm_type
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
+	int			(*hdr_offset)(struct xfrm_state *, struct sk_buff *, u8 **);
 	/* Estimate maximal size of result of transformation of a dgram */
 	u32			(*get_max_size)(struct xfrm_state *, int size);
 };
@@ -960,6 +961,8 @@ extern u32 xfrm6_tunnel_alloc_spi(xfrm_a
 extern void xfrm6_tunnel_free_spi(xfrm_address_t *saddr);
 extern u32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr);
 extern int xfrm6_output(struct sk_buff *skb);
+extern int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
+				 u8 **prevhdr);
 
 #ifdef CONFIG_XFRM
 extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index b085562..ab90b2d 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -424,7 +424,8 @@ static struct xfrm_type ah6_type =
 	.init_state	= ah6_init_state,
 	.destructor	= ah6_destroy,
 	.input		= ah6_input,
-	.output		= ah6_output
+	.output		= ah6_output,
+	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
 static struct inet6_protocol ah6_protocol = {
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 9231981..0e2b372 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -365,7 +365,8 @@ static struct xfrm_type esp6_type =
 	.destructor	= esp6_destroy,
 	.get_max_size	= esp6_get_max_size,
 	.input		= esp6_input,
-	.output		= esp6_output
+	.output		= esp6_output,
+	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
 static struct inet6_protocol esp6_protocol = {
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 1578529..8669146 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -460,6 +460,7 @@ static struct xfrm_type ipcomp6_type = 
 	.destructor	= ipcomp6_destroy,
 	.input		= ipcomp6_input,
 	.output		= ipcomp6_output,
+	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
 static struct inet6_protocol ipcomp6_protocol = 
diff --git a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
index dd4d1ce..e1a7416 100644
--- a/net/ipv6/ipv6_syms.c
+++ b/net/ipv6/ipv6_syms.c
@@ -31,6 +31,7 @@ EXPORT_SYMBOL(ipv6_chk_addr);
 EXPORT_SYMBOL(in6_dev_finish_destroy);
 #ifdef CONFIG_XFRM
 EXPORT_SYMBOL(xfrm6_rcv);
+EXPORT_SYMBOL(xfrm6_find_1stfragopt);
 #endif
 EXPORT_SYMBOL(rt6_lookup);
 EXPORT_SYMBOL(ipv6_push_nfrag_opts);
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
index 711d713..a5dce21 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -35,7 +35,7 @@ static int xfrm6_transport_output(struct
 	skb_push(skb, x->props.header_len);
 	iph = skb->nh.ipv6h;
 
-	hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
+	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
 	skb->nh.raw = prevhdr - x->props.header_len;
 	skb->h.raw = skb->data + hdr_len;
 	memmove(skb->data, iph, hdr_len);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 26f1886..b4628fb 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -17,6 +17,12 @@ #include <linux/netfilter_ipv6.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
+int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
+			  u8 **prevhdr)
+{
+	return ip6_find_1stfragopt(skb, prevhdr);
+}
+
 static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 {
 	int mtu, ret = 0;
-- 
1.4.0

