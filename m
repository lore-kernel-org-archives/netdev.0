From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next crap] net: icmp: work around bogus pmtu errors
Date: Sat, 11 Jul 2015 01:56:49 +0200
Message-ID: <1436572609-2097-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43241 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752952AbbGKIWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 04:22:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sometimes tcp connections seem to hang.
tcpdump shows broken path mtu reports.  This "fix" avoids hang and gives:

[633.327834] icmp: 192.0.0.2 reports mtu 1474 for packet size 1474 to host 204.236.132.12
[635.586945] icmp: 192.0.0.2 reports mtu 1474 for packet size 1474 to host 54.219.255.254
[647.106708] icmp: 192.0.0.2 reports mtu 1474 for packet size 1466 to host 204.236.132.12
[663.084586] icmp: 192.0.0.2 reports mtu 1474 for packet size 1466 to host 54.219.255.254

sigh.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Might be caused by DS-LITE.  I either need the turd below or iptables TCPMSS
 mangling rules to artificially lower received mss.

 I don't mind if this is rejected; I'm mostly wondering if anyone
 else came across suprise like this.

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 36f5584..1ab08dd 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -771,6 +771,8 @@ static bool icmp_unreach(struct sk_buff *skb)
 		goto out_err;
 
 	if (icmph->type == ICMP_DEST_UNREACH) {
+		u16 tot_len;
+
 		switch (icmph->code & 15) {
 		case ICMP_NET_UNREACH:
 		case ICMP_HOST_UNREACH:
@@ -795,6 +797,17 @@ static bool icmp_unreach(struct sk_buff *skb)
 				/* fall through */
 			case 0:
 				info = ntohs(icmph->un.frag.mtu);
+
+				tot_len = ntohs(iph->tot_len);
+
+				if (tot_len <= info) {
+					pr_warn_ratelimited("%pI4 reports mtu %d for packet"
+							    " size %d to host %pI4\n",
+							    &ip_hdr(skb)->saddr, info,
+							    tot_len, &iph->daddr);
+					if (tot_len >= (536 + 8))
+						info = tot_len - 8;
+				}
 			}
 			break;
 		case ICMP_SR_FAILED:
-- 
2.0.5
