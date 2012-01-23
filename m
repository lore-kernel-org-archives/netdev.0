From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tg3: fix ipv6 header length computation
Date: Mon, 23 Jan 2012 12:22:09 +0100
Message-ID: <1327317729.2525.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:62608 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752831Ab2AWLWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 06:22:14 -0500
Received: by lahc1 with SMTP id c1so1532496lah.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 03:22:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3_start_xmit() makes the wrong assumption for TSOV6 that skb->head
doesnt include any payload data.

if (skb_is_gso_v6(skb))
	hdr_len = skb_headlen(skb) - ETH_HLEN;

This is not true anymore after commit f07d960df3 (tcp: avoid frag
allocation for small frames)

We should instead use : skb_transport_offset(skb) + tcp_hdrlen(skb)

Its also true for IPv4

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Matt Carlson <mcarlson@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
---
I dont have a compatable hardware (5755_PLUS ?) so please guys test
this...

 drivers/net/ethernet/broadcom/tg3.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d529af9..a1f2e0f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6667,14 +6667,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		iph = ip_hdr(skb);
 		tcp_opt_len = tcp_optlen(skb);
 
-		if (skb_is_gso_v6(skb)) {
-			hdr_len = skb_headlen(skb) - ETH_HLEN;
-		} else {
-			u32 ip_tcp_len;
-
-			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
-			hdr_len = ip_tcp_len + tcp_opt_len;
+		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb) - ETH_HLEN;
 
+		if (!skb_is_gso_v6(skb)) {
 			iph->check = 0;
 			iph->tot_len = htons(mss + hdr_len);
 		}
