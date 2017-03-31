From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] udp: use sk_protocol instead of pcflag to detect udplite sockets
Date: Fri, 31 Mar 2017 11:47:39 +0200
Message-ID: <fc91ec83ecf454fad74c326380203a34434cb1ec.1490953526.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35492 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932677AbdCaJrx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 05:47:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the udp_sock struct, the 'forward_deficit' and 'pcflag' fields
share the same cacheline. While the first is dirtied by
udp_recvmsg, the latter is read, possibly several times, by the
bottom half processing to discriminate between udp and udplite
sockets.

With this patch, sk->sk_protocol is used to check is the socket is
really an udplite one, avoiding some cache misses per
packet and improving the performance under udp_flood with
small packet up to 10%.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/udp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index c0f5308..6cb4061 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -115,6 +115,6 @@ static inline bool udp_get_no_check6_rx(struct sock *sk)
 #define udp_portaddr_for_each_entry_rcu(__sk, list) \
 	hlist_for_each_entry_rcu(__sk, list, __sk_common.skc_portaddr_node)
 
-#define IS_UDPLITE(__sk) (udp_sk(__sk)->pcflag)
+#define IS_UDPLITE(__sk) (__sk->sk_protocol == IPPROTO_UDPLITE)
 
 #endif	/* _LINUX_UDP_H */
-- 
2.9.3
