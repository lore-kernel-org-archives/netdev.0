From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/5] inet: ip_skb_dst_mtu() should use sk_fullsock()
Date: Sun,  4 Oct 2015 21:08:08 -0700
Message-ID: <1444018091-21987-3-git-send-email-edumazet@google.com>
References: <1444018091-21987-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34945 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbbJEEIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 00:08:34 -0400
Received: by pacfv12 with SMTP id fv12so166858165pac.2
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 21:08:34 -0700 (PDT)
In-Reply-To: <1444018091-21987-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYN_RECV & TIMEWAIT sockets are not full blown,
do not even try to call ip_sk_use_pmtu() on them.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 91a6b2c88341..aa7811993276 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -323,12 +323,15 @@ static inline unsigned int ip_dst_mtu_maybe_forward(const struct dst_entry *dst,
 
 static inline unsigned int ip_skb_dst_mtu(const struct sk_buff *skb)
 {
-	if (!skb->sk || ip_sk_use_pmtu(skb->sk)) {
+	struct sock *sk = skb->sk;
+
+	if (!sk || !sk_fullsock(sk) || ip_sk_use_pmtu(sk)) {
 		bool forwarding = IPCB(skb)->flags & IPSKB_FORWARDED;
+
 		return ip_dst_mtu_maybe_forward(skb_dst(skb), forwarding);
-	} else {
-		return min(skb_dst(skb)->dev->mtu, IP_MAX_MTU);
 	}
+
+	return min(skb_dst(skb)->dev->mtu, IP_MAX_MTU);
 }
 
 u32 ip_idents_reserve(u32 hash, int segs);
-- 
2.6.0.rc2.230.g3dd15c0
