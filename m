From: Ang Way Chuang <wcang79@gmail.com>
Subject: [PATCH] bridge: Pseudo-header required for the checksum of ICMP6
 header of MLD
Date: Wed, 24 Aug 2011 15:10:50 +0900
Message-ID: <4E5495EA.1080906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:46809 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab1HXGKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 02:10:54 -0400
Received: by gya6 with SMTP id 6so645554gya.19
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 23:10:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just saw Eric's patch for icmp6_type. Suspect this patch may have issue for reference
of ip6h after pskb_trim_rcsum()?

Checksum of ICMPv6 is not properly computed because the pseudo header is not used.
Thus, the MLD packet gets dropped by the bridge. This patch fixes the problem for my
testbed. This bug was made visible by commit ff9a57a62afbbe2d0f3a09af321f1fd7645f38a.

This patch has been tested on 3.0.3. Due to lack of understanding on the checksum
optimization and multicast snooping of the kernel stack, can someone please verify the
correctness of this patch?

Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>
---
index 2d85ca7..bbf361b 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1528,9 +1528,12 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 			break;
 		/*FALLTHROUGH*/
 	case CHECKSUM_NONE:
-		skb2->csum = 0;
-		if (skb_checksum_complete(skb2))
+		if (!skb_csum_unnecessary(skb2) && csum_ipv6_magic(&ip6h->saddr,
+			&ip6h->daddr, skb2->len, IPPROTO_ICMPV6,
+			skb_checksum(skb2, 0, skb2->len, 0))) {
+			err = -EINVAL;
 			goto out;
+		}
 	}
 
 	err = 0;
---
