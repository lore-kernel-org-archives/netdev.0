From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v2] IP_GRE: Fix kernel panic in IP_GRE with GRE csum.
Date: Tue, 22 Jan 2013 14:56:38 -0800
Message-ID: <1358895398-2088-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:60516 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751765Ab3AVWzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 17:55:48 -0500
Received: by mail-ve0-f198.google.com with SMTP id ox1so1134385veb.9
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 14:55:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed code indentation according to comments from David Miller.

--8<--------------------------cut here-------------------------->8--
Due to GSO support, GRE can recieve non linear skb which
results in panic in case of GRE_CSUM.
Following patch fixes it by using correct csum API.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_gre.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 303012a..8179e066 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -964,7 +964,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 		if (tunnel->parms.o_flags&GRE_CSUM) {
 			*ptr = 0;
-			*(__sum16 *)ptr = ip_compute_csum((void *)(iph+1), skb->len - sizeof(struct iphdr));
+			*(__sum16 *)ptr = csum_fold(skb_checksum(skb,
+						    skb_transport_offset(skb),
+						    skb->len - skb_transport_offset(skb),
+						    0));
 		}
 	}
 
-- 
1.7.10
