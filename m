From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: [PATCH] IPv4: skip loopback checksums in ip_rcv()
Date: Mon, 19 Oct 2009 21:34:02 +0200
Message-ID: <200910192134.02125.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jessica.hrz.tu-chemnitz.de ([134.109.132.47]:40247 "EHLO
	jessica.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752602AbZJSUP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 16:15:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skip loopback checksum in ip_rcv() for speed optimisation.

Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
---
 net/ipv4/ip_input.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 6c98b43..dc72286 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -406,7 +406,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	 *
 	 *	1.	Length at least the size of an ip header
 	 *	2.	Version of 4
-	 *	3.	Checksums correctly. [Speed optimisation for later, skip loopback checksums]
+	 *	3.	Checksums correctly. [Speed optimisation: skip loopback checksums]
 	 *	4.	Doesn't have a bogus length
 	 */
 
@@ -418,8 +418,9 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	iph = ip_hdr(skb);
 
-	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
-		goto inhdr_error;
+	if (!ipv4_is_loopback(iph->daddr))
+		if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+			goto inhdr_error;
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
-- 
