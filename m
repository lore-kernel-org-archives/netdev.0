From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] sock: avoid dirtying incoming_cpu if not needed
Date: Wed, 21 Jun 2017 11:45:31 +0200
Message-ID: <a5af66d2a71c1fe229bbeee40db4a9aa48dd969a.1498038209.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56138 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751154AbdFUJpn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 05:45:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for connected socket, the incoming_cpu field in the sock struct
is not going to change frequently, but we are setting it
unconditionally for each packet.

Since sk_incoming_cpu and sk_flags share the same cacheline,
and the latter is access by udp_recvmsg(), this cause a cache
miss for each packet for UDP connected socket.

With this patch, we set the incoming cpu field only when the
ingress cpu really changes.

This gives a small but measurable performance improvement for
connected UDP socket.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/sock.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 858891c..00d0914 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -907,7 +907,10 @@ static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 
 static inline void sk_incoming_cpu_update(struct sock *sk)
 {
-	sk->sk_incoming_cpu = raw_smp_processor_id();
+	int cpu = raw_smp_processor_id();
+
+	if (unlikely(sk->sk_incoming_cpu != cpu))
+		sk->sk_incoming_cpu = cpu;
 }
 
 static inline void sock_rps_record_flow_hash(__u32 hash)
-- 
2.9.4
