From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 04/19] ndisc: Introduce ndisc_fill_redirect_hdr_option().
Date: Tue, 22 Jan 2013 01:48:09 +0900
Message-ID: <50FD7149.70304@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50340 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752397Ab3AUQsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 539b2ec..53a545f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1341,6 +1341,19 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
 }
 
+static u8 *ndisc_fill_redirect_hdr_option(u8 *opt, struct sk_buff *orig_skb,
+					  int rd_len)
+{
+	memset(opt, 0, 8);
+	*(opt++) = ND_OPT_REDIRECT_HDR;
+	*(opt++) = (rd_len >> 3);
+	opt += 6;
+
+	memcpy(opt, ipv6_hdr(orig_skb), rd_len - 8);
+
+	return opt + rd_len - 8;
+}
+
 void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 {
 	struct net_device *dev = skb->dev;
@@ -1470,12 +1483,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	 *	build redirect option and copy skb over to the new packet.
 	 */
 
-	memset(opt, 0, 8);
-	*(opt++) = ND_OPT_REDIRECT_HDR;
-	*(opt++) = (rd_len >> 3);
-	opt += 6;
-
-	memcpy(opt, ipv6_hdr(skb), rd_len - 8);
+	if (rd_len)
+		opt = ndisc_fill_redirect_hdr_option(opt, skb, rd_len);
 
 	msg->icmph.icmp6_cksum = csum_ipv6_magic(&saddr_buf, &ipv6_hdr(skb)->saddr,
 						 len, IPPROTO_ICMPV6,
-- 
1.7.9.5
