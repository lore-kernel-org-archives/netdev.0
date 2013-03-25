From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 3/3] ipv4: Fix ip-header identification for gso packets.
Date: Sun, 24 Mar 2013 20:36:29 -0700
Message-ID: <1364182589-1766-1-git-send-email-pshelar@nicira.com>
Cc: amwang@redhat.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:34283 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756772Ab3CYDhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 23:37:33 -0400
Received: by mail-pa0-f70.google.com with SMTP id bh4so345789pad.9
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 20:37:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip-header id needs to be incremented even if IP_DF flag is set.
This behaviour was changed in commit 490ab08127cebc25e3a26
(IP_GRE: Fix IP-Identification).

Following patch fixes it so that identification is always
incremented.

Reported-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ipip.h |   16 ++++++----------
 net/ipv4/af_inet.c |    3 +--
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index 0c046e3..483b91a 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -74,15 +74,11 @@ static inline void tunnel_ip_select_ident(struct sk_buff *skb,
 {
 	struct iphdr *iph = ip_hdr(skb);
 
-	if (iph->frag_off & htons(IP_DF))
-		iph->id	= 0;
-	else {
-		/* Use inner packet iph-id if possible. */
-		if (skb->protocol == htons(ETH_P_IP) && old_iph->id)
-			iph->id	= old_iph->id;
-		else
-			__ip_select_ident(iph, dst,
-					  (skb_shinfo(skb)->gso_segs ?: 1) - 1);
-	}
+	/* Use inner packet iph-id if possible. */
+	if (skb->protocol == htons(ETH_P_IP) && old_iph->id)
+		iph->id	= old_iph->id;
+	else
+		__ip_select_ident(iph, dst,
+				  (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 }
 #endif
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9e5882c..70b2d4c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1334,8 +1334,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 				iph->frag_off |= htons(IP_MF);
 			offset += (skb->len - skb->mac_len - iph->ihl * 4);
 		} else  {
-			if (!(iph->frag_off & htons(IP_DF)))
-				iph->id = htons(id++);
+			iph->id = htons(id++);
 		}
 		iph->tot_len = htons(skb->len - skb->mac_len);
 		iph->check = 0;
-- 
1.7.1
