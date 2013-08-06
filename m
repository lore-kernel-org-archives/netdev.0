From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net] ip_gre: fix ipgre_header to return correct offset
Date: Tue,  6 Aug 2013 13:45:43 +0300
Message-ID: <1375785943-23908-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:47471 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756063Ab3HFKpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 06:45:18 -0400
Received: by mail-ea0-f179.google.com with SMTP id b10so133610eae.10
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 03:45:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix ipgre_header() (header_ops->create) to return the correct
amount of bytes pushed. Most callers of dev_hard_header() seem
to care only if it was success, but af_packet.c uses it as
offset to the skb to copy from userspace only once. In practice
this fixes packet socket sendto()/sendmsg() to gre tunnels.

Regression introduced in c54419321455631079c7d6e60bc732dd0c5914c5
("GRE: Refactor GRE tunneling code.")

Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
Should go to 3.10-stable too. Without this dmvpn setup does not work
at all, as opennhrp uses packet sockets to send the nhrp packets.

 net/ipv4/ip_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 855004f..c52fee0 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -572,7 +572,7 @@ static int ipgre_header(struct sk_buff *skb, struct=
 net_device *dev,
 	if (daddr)
 		memcpy(&iph->daddr, daddr, 4);
 	if (iph->daddr)
-		return t->hlen;
+		return t->hlen + sizeof(*iph);
=20
 	return -(t->hlen + sizeof(*iph));
 }
--=20
1.8.3.4
