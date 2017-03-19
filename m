From: Kevin Xu <kaiwen.xu@hulu.com>
Subject: [PATCH net v2] net: Do not hold the reference for the same sk_rx_dst
Date: Sat, 18 Mar 2017 18:48:41 -0700
Message-ID: <1489888121-1051-1-git-send-email-kaiwen.xu@hulu.com>
References: <20170316.111647.1545474188593011995.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Kevin Xu <kaiwen.xu@hulu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtppool.hulu.com ([208.91.156.120]:58453 "EHLO
        smtppool.els.hulu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751189AbdCSCFK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 22:05:10 -0400
In-Reply-To: <20170316.111647.1545474188593011995.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some rare cases, inet_sk_rx_dst_set() may be called multiple times
on the same dst, causing double refcounting. Eventually, it
prevents net_device to be destroyed. The bug manifested as

unregister_netdevice: waiting for lo to become free. Usage count = 1

in the kernel log, preventing new network namespace creation.

Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
---
 net/ipv4/tcp_ipv4.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 575e19d..ca588d1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1806,9 +1806,11 @@ int tcp_v4_rcv(struct sk_buff *skb)
 void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
+	struct dst_entry *old;
 
 	if (dst && dst_hold_safe(dst)) {
-		sk->sk_rx_dst = dst;
+		old = xchg(&sk->sk_rx_dst, dst);
+		dst_release(old);
 		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 	}
 }
-- 
1.9.1
