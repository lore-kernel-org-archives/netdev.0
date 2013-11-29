From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net] {pktgen, xfrm} re-caculate IPv4 checksum after transformation
Date: Fri, 29 Nov 2013 10:59:09 +0800
Message-ID: <1385693949-3786-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49726 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972Ab3K2C7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 21:59:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I accidently observed incorrect IPv4 checksum by wireshark
when armming pktgen with IPsec by ESP transport mode with
following pktgen configuration:

pgset "flag IPSEC"
pgset "flows 1"

It seems that after transformation, IPv4 checksum remains the
origianl checksum as before, so encrypted packet will never
reach receiver's upper layer because of wrong IPv4 checksum
value.

Fix this by re-caculate checksum value.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/pktgen.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 261357a..8d13b41 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2786,6 +2786,8 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 #ifdef CONFIG_XFRM
 	if (!process_ipsec(pkt_dev, skb, protocol))
 		return NULL;
+	iph = ip_hdr(skb);
+	ip_send_check(iph);
 #endif
 
 	return skb;
-- 
1.7.9.5
