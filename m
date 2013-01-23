From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3] IP_GRE: Fix kernel panic in IP_GRE with GRE csum.
Date: Wed, 23 Jan 2013 13:45:42 -0800
Message-ID: <1358977542-1627-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:48900 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752109Ab3AWVqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 16:46:46 -0500
Received: by mail-pa0-f70.google.com with SMTP id hz11so10059331pad.5
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 13:46:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to IP_GRE GSO support, GRE can recieve non linear skb which
results in panic in case of GRE_CSUM.
Following patch fixes it by using correct csum API.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v3: Coding style Fix.

---
 net/ipv4/ip_gre.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 303012a..e81b1ca 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -963,8 +963,12 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			ptr--;
 		}
 		if (tunnel->parms.o_flags&GRE_CSUM) {
+			int offset = skb_transport_offset(skb);
+
 			*ptr = 0;
-			*(__sum16 *)ptr = ip_compute_csum((void *)(iph+1), skb->len - sizeof(struct iphdr));
+			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, offset,
+								 skb->len - offset,
+								 0));
 		}
 	}
 
-- 
1.7.10
