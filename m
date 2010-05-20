From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: Use __this_cpu_inc() in fast path
Date: Thu, 20 May 2010 10:07:23 +0200
Message-ID: <1274342843.4046.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52261 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab0ETIH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 04:07:28 -0400
Received: by fxm10 with SMTP id 10so3212567fxm.19
        for <netdev@vger.kernel.org>; Thu, 20 May 2010 01:07:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch saves 224 bytes of text on my machine.

__this_cpu_inc() generates a single instruction, using no scratch
registers :

  65 ff 04 25 a8 30 01 00      incl   %gs:0x130a8

instead of :

  48 c7 c2 80 30 01 00         mov    $0x13080,%rdx
  65 48 8b 04 25 88 ea 00 00   mov    %gs:0xea88,%rax
  83 44 10 28 01               addl   $0x1,0x28(%rax,%rdx,1)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c   |    3 +--
 net/ipv4/route.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6c82065..76475f2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2826,8 +2826,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 			skb->dev = master;
 	}
 
-	__get_cpu_var(softnet_data).processed++;
-
+	__this_cpu_inc(softnet_data.processed);
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 560acc6..8495bce 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -253,8 +253,7 @@ static unsigned			rt_hash_mask __read_mostly;
 static unsigned int		rt_hash_log  __read_mostly;
 
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
-#define RT_CACHE_STAT_INC(field) \
-	(__raw_get_cpu_var(rt_cache_stat).field++)
+#define RT_CACHE_STAT_INC(field) __this_cpu_inc(rt_cache_stat.field)
 
 static inline unsigned int rt_hash(__be32 daddr, __be32 saddr, int idx,
 				   int genid)


