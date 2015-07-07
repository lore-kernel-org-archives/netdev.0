From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net,v2] ip_tunnel: fix ipv4 pmtu check to honor inner ip header df
Date: Tue,  7 Jul 2015 08:34:13 +0300
Message-ID: <1436247253-6466-1-git-send-email-timo.teras@iki.fi>
References: <20150707033906.GF1173@brightrain.aerifal.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:33093 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbbGGFeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 01:34:20 -0400
Received: by laar3 with SMTP id r3so181624521laa.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 22:34:19 -0700 (PDT)
In-Reply-To: <20150707033906.GF1173@brightrain.aerifal.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rag needed should be sent only if the inner header asked
to not fragment. Currently fragmentation is broken if the
tunnel has df set, but df was not asked in the original
packet. The tunnel's df needs to be still checked to update
internally the pmtu cache.

Commit 23a3647bc4f93bac broke it, and this commit fixes
the ipv4 df check back to the way it was.

=46ixes: 23a3647bc4f93bac ("ip_tunnels: Use skb-len to PMTU check.")
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
Should go to -stable queues (3.12.y and newer).

v2: revised commit message wording a bit, and added
signed-off-by line that was forgotten accidentally.

 net/ipv4/ip_tunnel.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 4c2c3ba..626d9e5 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -586,7 +586,8 @@ int ip_tunnel_encap(struct sk_buff *skb, struct ip_=
tunnel *t,
 EXPORT_SYMBOL(ip_tunnel_encap);
=20
 static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb=
,
-			    struct rtable *rt, __be16 df)
+			    struct rtable *rt, __be16 df,
+			    const struct iphdr *inner_iph)
 {
 	struct ip_tunnel *tunnel =3D netdev_priv(dev);
 	int pkt_size =3D skb->len - tunnel->hlen - dev->hard_header_len;
@@ -603,7 +604,8 @@ static int tnl_update_pmtu(struct net_device *dev, =
struct sk_buff *skb,
=20
 	if (skb->protocol =3D=3D htons(ETH_P_IP)) {
 		if (!skb_is_gso(skb) &&
-		    (df & htons(IP_DF)) && mtu < pkt_size) {
+		    (inner_iph->frag_off & htons(IP_DF)) &&
+		    mtu < pkt_size) {
 			memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 			return -E2BIG;
@@ -737,7 +739,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net=
_device *dev,
 		goto tx_error;
 	}
=20
-	if (tnl_update_pmtu(dev, skb, rt, tnl_params->frag_off)) {
+	if (tnl_update_pmtu(dev, skb, rt, tnl_params->frag_off, inner_iph)) {
 		ip_rt_put(rt);
 		goto tx_error;
 	}
--=20
2.4.5
