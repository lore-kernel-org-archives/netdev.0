From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ipv6: skip __ipv6_select_ident when there is no skb_dst
Date: Wed, 18 Mar 2015 14:52:15 +0100
Message-ID: <1426686735-6129-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, matt@mattgrant.net.nz,
	Sabrina Dubroca <sd@queasysnail.net>,
	Vladislav Yasevich <vyasevic@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:42485 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932754AbbCRNwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 09:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Grant reported frequent crashes in ipv6_select_ident when
udp6_ufo_fragment is called from openvswitch on a skb that doesn't
have a dst_entry set.

Skip __ipv6_select_ident in case of a NULL rt.

Fixes: 0508c07f5e0c ("ipv6: Select fragment id during UFO segmentation if not set.")
Cc: Vladislav Yasevich <vyasevic@redhat.com>
Reported-by: Matt Grant <matt@mattgrant.net.nz>
Tested-by: Matt Grant <matt@mattgrant.net.nz>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
David, can you queue it for stable (3.19)?

 net/ipv6/output_core.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 74581f706c4d..52b1bc76d5c5 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -62,12 +62,14 @@ EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
 void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 {
 	static u32 ip6_idents_hashrnd __read_mostly;
-	u32 id;
+	u32 id = 0;
 
 	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
 
-	id = __ipv6_select_ident(ip6_idents_hashrnd, &rt->rt6i_dst.addr,
-				 &rt->rt6i_src.addr);
+	if (rt)
+		id = __ipv6_select_ident(ip6_idents_hashrnd, &rt->rt6i_dst.addr,
+					 &rt->rt6i_src.addr);
+
 	fhdr->identification = htonl(id);
 }
 EXPORT_SYMBOL(ipv6_select_ident);
-- 
2.3.3
