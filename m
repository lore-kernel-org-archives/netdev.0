From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: beet: fix worst case header_len calculation
Date: Sun, 08 Apr 2007 04:56:51 +0200
Message-ID: <461859F3.50303@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030400070904050400000707"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38277 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932664AbXDHC44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2007 22:56:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030400070904050400000707
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The pskb_copy_expand crash I was seeing was triggered by BEET
mode not calculating the SA's header_len value for the worst
case, causing skb headroom expansions. This patch uses the
worst case value by including the maximum length of the pseudo
header.

The patch applies on top of the MTU optimization patch.


--------------030400070904050400000707
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: beet: fix worst case header_len calculation

esp_init_state doesn't account for the beet pseudo header in the header_len
calculation, which may result in undersized skbs hitting xfrm4_beet_output,
causing unnecessary reallocations in ip_finish_output2.

The skbs should still always have enough room to avoid causing
skb_under_panic in skb_push since we have at least 16 bytes available
from LL_RESERVED_SPACE in xfrm_state_check_space.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 1a5c3645170382f52b957c693c3df957bb2ee824
tree 26fb4c3704df1485b5150c7eabc06c93525c704c
parent 9cb76fae709a9303777286998baa457b0730a225
author Patrick McHardy <kaber@trash.net> Sun, 08 Apr 2007 04:46:54 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 08 Apr 2007 04:46:54 +0200

 net/ipv4/esp4.c            |    3 ++-
 net/ipv4/xfrm4_mode_beet.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 24238fb..7459251 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -294,7 +294,6 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 		break;
 	case XFRM_MODE_BEET:
 		/* The worst case. */
-		mtu -= IPV4_BEET_PHMAXLEN;
 		mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem);
 		break;
 	}
@@ -409,6 +408,8 @@ static int esp_init_state(struct xfrm_state *x)
 	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
+	else if (x->props.mode == XFRM_MODE_BEET)
+		x->props.header_len += IPV4_BEET_PHMAXLEN;
 	if (x->encap) {
 		struct xfrm_encap_tmpl *encap = x->encap;
 
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 5a53aec..3c6a84b 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -40,7 +40,7 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (unlikely(optlen))
 		hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
 
-	skb_push(skb, x->props.header_len + hdrlen);
+	skb_push(skb, x->props.header_len - IPV4_BEET_PHMAXLEN + hdrlen);
 	skb_reset_network_header(skb);
 	top_iph = ip_hdr(skb);
 	skb->transport_header += sizeof(*iph) - hdrlen;

--------------030400070904050400000707--
