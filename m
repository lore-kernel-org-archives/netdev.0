From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net] ip_gre: fix msg_name parsing for recvfrom/recvmsg
Date: Thu, 12 Dec 2013 10:53:52 +0200
Message-ID: <1386838432-18889-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:61163 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671Ab3LLIxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 03:53:54 -0500
Received: by mail-la0-f42.google.com with SMTP id ec20so74382lab.1
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 00:53:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipgre_header_parse() needs to parse the tunnel's ip header for getting
the link-layer addresses, and uses mac_header to get the header. This
fixes setting mac_header on the receive path to original behaviour.

Bug added in commit c54419321455 (GRE: Refactor GRE tunneling code.)

Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
Alternate would be to do skb_reset_inner_headers() in ip_tunnel_rcv() a=
nd
update ipgre_header_parse() to use skb_inner_network_header(). Though, =
then
inner would then be referring to the "outer" headers.

If applied as-is, should go to -stable too.

 net/ipv4/ip_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d7aea4c..cc2c7f1 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -217,6 +217,7 @@ static int ipgre_rcv(struct sk_buff *skb, const str=
uct tnl_ptk_info *tpi)
 				  iph->saddr, iph->daddr, tpi->key);
=20
 	if (tunnel) {
+		skb->mac_header =3D skb->network_header;
 		ip_tunnel_rcv(tunnel, skb, tpi, log_ecn_error);
 		return PACKET_RCVD;
 	}
--=20
1.8.5.1
