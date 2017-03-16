From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 1/5] net: Do not record sender_cpu as napi_id in
 socket receive paths
Date: Thu, 16 Mar 2017 11:32:38 -0700
Message-ID: <20170316183238.15806.14293.stgit@localhost.localdomain>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316183142.15806.38824.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

Fix sk_mark_napi_id() and sk_mark_napi_id_once() to set sk_napi_id only if
skb->napi_id is a valid value.

This happens in loopback paths where skb->napi_id is not updated in
rx path and holds sender_cpu that is set in xmit path.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/net/busy_poll.h |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index c0452de83086..67991635953e 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -116,7 +116,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 static inline void sk_mark_napi_id(struct sock *sk, const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_RX_BUSY_POLL
-	sk->sk_napi_id = skb->napi_id;
+	if (skb->napi_id > (u32)NR_CPUS)
+		sk->sk_napi_id = skb->napi_id;
 #endif
 }
 
@@ -125,7 +126,7 @@ static inline void sk_mark_napi_id_once(struct sock *sk,
 					const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_RX_BUSY_POLL
-	if (!sk->sk_napi_id)
+	if (!sk->sk_napi_id && (skb->napi_id > (u32)NR_CPUS))
 		sk->sk_napi_id = skb->napi_id;
 #endif
 }
