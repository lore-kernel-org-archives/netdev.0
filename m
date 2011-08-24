From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: [PATCH] bridge: Pseudo-header required for the checksum of ICMP6
 header of MLD
Date: Wed, 24 Aug 2011 13:56:13 +0900
Message-ID: <4E54846D.10906@sfc.wide.ad.jp>
References: <4E5367CA.3090005@sfc.wide.ad.jp>  <1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E539DA8.1070504@sfc.wide.ad.jp> <1314105027.2219.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4E53B360.8090107@sfc.wide.ad.jp> <4E53E237.1060401@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	yoshfuji@linux-ipv6.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:42505 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750795Ab1HXE4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 00:56:16 -0400
In-Reply-To: <4E53E237.1060401@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checksum of ICMPv6 is not properly computed because the pseudo header is not used.
Thus, the MLD packet gets dropped by the bridge. This patch fixes the problem for my
testbed. This bug was made visible by commit ff9a57a62afbbe2d0f3a09af321f1fd7645f38a.

This patch has been tested on 3.0.3. Due to lack of understanding on the checksum
optimization and multicast snooping of the kernel stack, can someone please verify the
correctness of this patch?

Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>
---
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2d85ca7..bbf361b 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1528,9 +1528,12 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
              break;
          /*FALLTHROUGH*/
      case CHECKSUM_NONE:
-        skb2->csum = 0;
-        if (skb_checksum_complete(skb2))
+        if (!skb_csum_unnecessary(skb2) && csum_ipv6_magic(&ip6h->saddr,
+ &ip6h->daddr, skb2->len, IPPROTO_ICMPV6,
+            skb_checksum(skb2, 0, skb2->len, 0))) {
+            err = -EINVAL;
              goto out;
+        }
      }

      err = 0;
---
