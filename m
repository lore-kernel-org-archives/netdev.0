From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] Revert "ip_gre: make ipgre_tunnel_xmit() not parse network header as IP unconditionally"
Date: Wed, 13 Mar 2013 14:37:49 +0200
Message-ID: <1363178269-27553-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org, Isaku Yamahata <yamahata@valinux.co.jp>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:62065 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab3CMMhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 08:37:24 -0400
Received: by mail-ea0-f175.google.com with SMTP id o10so391694eaj.6
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 05:37:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 412ed94744d16806fbec3bd250fd94e71cde5a1f.

The commit is wrong as tiph points to the outer IPv4 header which is
installed at ipgre_header() and not the inner one which is protocol dep=
endant.

This commit broke succesfully opennhrp which use PF_PACKET socket with
ETH_P_NHRP protocol. Additionally ssl_addr is set to the link-layer
IPv4 address. This address is written by ipgre_header() to the skb
earlier, and this is the IPv4 header tiph should point to - regardless
of the inner protocol payload.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 net/ipv4/ip_gre.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)
=20
This commit appeared in 3.8.x. So should go to 3.8.x-stable.

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d0ef0e6..91d66db 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -798,10 +798,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buf=
f *skb, struct net_device *dev
=20
 	if (dev->header_ops && dev->type =3D=3D ARPHRD_IPGRE) {
 		gre_hlen =3D 0;
-		if (skb->protocol =3D=3D htons(ETH_P_IP))
-			tiph =3D (const struct iphdr *)skb->data;
-		else
-			tiph =3D &tunnel->parms.iph;
+		tiph =3D (const struct iphdr *)skb->data;
 	} else {
 		gre_hlen =3D tunnel->hlen;
 		tiph =3D &tunnel->parms.iph;
--=20
1.8.1.5
