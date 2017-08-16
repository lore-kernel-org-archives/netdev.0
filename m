From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: better IP_MAX_MTU enforcement
Date: Wed, 16 Aug 2017 11:09:12 -0700
Message-ID: <1502906952.4936.140.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37770 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751692AbdHPSJP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 14:09:15 -0400
Received: by mail-pf0-f194.google.com with SMTP id p13so1957690pfd.4
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 11:09:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While working on yet another syzkaller report, I found
that our IP_MAX_MTU enforcements were not properly done.

gcc seems to reload dev->mtu for min(dev->mtu, IP_MAX_MTU), and
final result can be bigger than IP_MAX_MTU :/

This is a problem because device mtu can be changed on other cpus or
threads.

While this patch does not fix the issue I am working on, it is
probably worth addressing it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h |    4 ++--
 net/ipv4/route.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 821cedcc8e73..0cf7f5a65fe6 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -352,7 +352,7 @@ static inline unsigned int ip_dst_mtu_maybe_forward(const struct dst_entry *dst,
 	    !forwarding)
 		return dst_mtu(dst);
 
-	return min(dst->dev->mtu, IP_MAX_MTU);
+	return min(READ_ONCE(dst->dev->mtu), IP_MAX_MTU);
 }
 
 static inline unsigned int ip_skb_dst_mtu(struct sock *sk,
@@ -364,7 +364,7 @@ static inline unsigned int ip_skb_dst_mtu(struct sock *sk,
 		return ip_dst_mtu_maybe_forward(skb_dst(skb), forwarding);
 	}
 
-	return min(skb_dst(skb)->dev->mtu, IP_MAX_MTU);
+	return min(READ_ONCE(skb_dst(skb)->dev->mtu), IP_MAX_MTU);
 }
 
 u32 ip_idents_reserve(u32 hash, int segs);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7effa62beed3..fe877a4a72b1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1267,7 +1267,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	if (mtu)
 		return mtu;
 
-	mtu = dst->dev->mtu;
+	mtu = READ_ONCE(dst->dev->mtu);
 
 	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
 		if (rt->rt_uses_gateway && mtu > 576)
