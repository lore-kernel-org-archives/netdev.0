From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] filter: Add SKF_AD_QUEUE instruction
Date: Fri, 16 Oct 2009 19:10:46 +0200
Message-ID: <4AD8A916.3060807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53180 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbZJPRKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 13:10:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can help being able to filter packets on their queue_mapping.

If filter performance is not good, we could add a "numqueue" field
in struct packet_type, so that netif_nit_deliver() and other functions
can directly ignore packets with not expected queue number.

Lets experiment this simple filter extension first.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1354aaf..a93f885 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -123,7 +123,8 @@ struct sock_fprog	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_IFINDEX 	8
 #define SKF_AD_NLATTR	12
 #define SKF_AD_NLATTR_NEST	16
-#define SKF_AD_MAX	20
+#define SKF_AD_QUEUE	20
+#define SKF_AD_MAX	24
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index d1d779c..0fc83f7 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -303,6 +303,9 @@ load_b:
 		case SKF_AD_IFINDEX:
 			A = skb->dev->ifindex;
 			continue;
+		case SKF_AD_QUEUE:
+			A = skb->queue_mapping;
+			continue;
 		case SKF_AD_NLATTR: {
 			struct nlattr *nla;
 
