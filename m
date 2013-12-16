From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net,v2] ip_gre: fix msg_name parsing for recvfrom/recvmsg
Date: Mon, 16 Dec 2013 11:02:09 +0200
Message-ID: <1387184529-6911-1-git-send-email-timo.teras@iki.fi>
References: <20131214.005232.1773340007123224291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Pravin B Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:50732 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab3LPJCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 04:02:32 -0500
Received: by mail-la0-f46.google.com with SMTP id eh20so2550513lab.33
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 01:02:31 -0800 (PST)
In-Reply-To: <20131214.005232.1773340007123224291.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipgre_header_parse() needs to parse the tunnel's ip header and it
uses mac_header to locate the iphdr. This got broken when gre tunneling
was refactored as mac_header is no longer updated to point to iphdr.
Introduce skb_pop_mac_header() helper to do the mac_header assignment
and use it in ipgre_rcv() to fix msg_name parsing.

Bug introduced in commit c54419321455 (GRE: Refactor GRE tunneling code=
=2E)

Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
Updated as suggested. Please queue for -stable too.

 include/linux/skbuff.h | 5 +++++
 net/ipv4/ip_gre.c      | 1 +
 2 files changed, 6 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 77c7aae..8b38a2f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1638,6 +1638,11 @@ static inline void skb_set_mac_header(struct sk_=
buff *skb, const int offset)
 	skb->mac_header +=3D offset;
 }
=20
+static inline void skb_pop_mac_header(struct sk_buff *skb)
+{
+	skb->mac_header =3D skb->network_header;
+}
+
 static inline void skb_probe_transport_header(struct sk_buff *skb,
 					      const int offset_hint)
 {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d7aea4c..e560ef3 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -217,6 +217,7 @@ static int ipgre_rcv(struct sk_buff *skb, const str=
uct tnl_ptk_info *tpi)
 				  iph->saddr, iph->daddr, tpi->key);
=20
 	if (tunnel) {
+		skb_pop_mac_header(skb);
 		ip_tunnel_rcv(tunnel, skb, tpi, log_ecn_error);
 		return PACKET_RCVD;
 	}
--=20
1.8.5.1
