From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH] ipv6: icmp6_send: fix Oops when pinging a not set up IPv6 peer on a sit tunnel
Date: Fri,  7 Feb 2014 11:22:37 +0100
Message-ID: <1391768557-6337-1-git-send-email-fx.lebail@yahoo.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp07.smtpout.orange.fr ([80.12.242.129]:24693 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbaBGKtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 05:49:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 446fab59333dea91e54688f033dd8d788d0486fb ("ipv6: enable anycast addresses
as source addresses in ICMPv6 error messages") causes an Oops when pinging a not
set up IPv6 peer on a sit tunnel.

The problem is that ipv6_anycast_destination() uses unconditionally skb_dst(skb),
which is NULL in this case.

The solution is to use instead the ipv6_chk_acast_addr_src() function.

Here are the steps to reproduce it:
modprobe sit
ip link add sit1 type sit remote 10.16.0.121 local 10.16.0.249
ip l s sit1 up
ip -6 a a dev sit1 2001:1234::123 remote 2001:1234::121
ping6 2001:1234::121

Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
Thanks Nicolas !

 net/ipv6/icmp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index f81f596..f2610e1 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -414,7 +414,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	addr_type = ipv6_addr_type(&hdr->daddr);
 
 	if (ipv6_chk_addr(net, &hdr->daddr, skb->dev, 0) ||
-	    ipv6_anycast_destination(skb))
+	    ipv6_chk_acast_addr_src(net, skb->dev, &hdr->daddr))
 		saddr = &hdr->daddr;
 
 	/*
