From: Kevin Xu <kaiwen.xu@hulu.com>
Subject: [PATCH] [PATCH net] net: Do not hold the reference for the same sk_rx_dst.
Date: Thu, 16 Mar 2017 01:08:30 -0700
Message-ID: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
Cc: netdev@vger.kernel.org, Kevin Xu <kaiwen.xu@hulu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtppool.hulu.com ([208.91.156.120]:8043 "EHLO
        smtppool.els.hulu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751130AbdCPIPO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 04:15:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some rare cases, inet_sk_rx_dst_set() may be called multiple times
on the same dst, causing reference count leakage. Eventually, it
prevents net_device to be destroyed. The bug then manifested as

unregister_netdevice: waiting for lo to become free. Usage count = 1

in the kernel log, preventing new network namespace creation.

The patch works around the issue by checking whether the socket already
has the same dst set.

Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
---
 net/ipv4/tcp_ipv4.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 575e19d..f425c14 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1807,9 +1807,14 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 
-	if (dst && dst_hold_safe(dst)) {
-		sk->sk_rx_dst = dst;
-		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+	if (dst) {
+		if (unlikely(dst == sk->sk_rx_dst))
+			return;
+
+		if (dst_hold_safe(dst)) {
+			sk->sk_rx_dst = dst;
+			inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+		}
 	}
 }
 EXPORT_SYMBOL(inet_sk_rx_dst_set);
-- 
1.9.1
