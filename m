From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] filter: add SKF_AD_RXHASH and SKF_AD_CPU
Date: Wed, 01 Dec 2010 08:45:56 +0100
Message-ID: <1291189556.2856.476.camel@edumazet-laptop>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
	 <1291109699.2904.11.camel@edumazet-laptop>
	 <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
	 <1291127670.2904.96.camel@edumazet-laptop>
	 <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
	 <1291176215.2856.383.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rui <wirelesser@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38042 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab0LAHqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 02:46:02 -0500
Received: by wyb28 with SMTP id 28so6631994wyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 23:46:01 -0800 (PST)
In-Reply-To: <1291176215.2856.383.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SKF_AD_RXHASH and SKF_AD_CPU to filter ancillary mechanism,
to be able to build advanced filters.

This can help spreading packets on several sockets with a fast
selection, after RPS dispatch to N cpus for example, or to catch a
percentage of flows in one queue.

tcpdump -s 500 "cpu = 1" :

[0] ld CPU
[1] jeq #1  jt 2  jf 3 
[2] ret #500
[3] ret #0

# take 12.5 % of flows (average)
tcpdump -s 1000 "rxhash & 7 = 2" :

[0] ld RXHASH
[1] and #7
[2] jeq #2  jt 3  jf 4 
[3] ret #1000
[4] ret #0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Rui <wirelesser@gmail.com>
---
 include/linux/filter.h |    4 +++-
 net/core/filter.c      |    6 ++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 447a775..5334ada 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -124,7 +124,9 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_MARK 	20
 #define SKF_AD_QUEUE	24
 #define SKF_AD_HATYPE	28
-#define SKF_AD_MAX	32
+#define SKF_AD_RXHASH	32
+#define SKF_AD_CPU	36
+#define SKF_AD_MAX	40
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index a44d27f..054e286 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -375,6 +375,12 @@ load_b:
 				return 0;
 			A = skb->dev->type;
 			continue;
+		case SKF_AD_RXHASH:
+			A = skb->rxhash;
+			continue;
+		case SKF_AD_CPU:
+			A = raw_smp_processor_id();
+			continue;
 		case SKF_AD_NLATTR: {
 			struct nlattr *nla;
 


