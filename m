From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 2/4] net_dma: revert 'copied_early'
Date: Thu, 09 Jan 2014 12:16:36 -0800
Message-ID: <20140109201617.28381.62559.stgit@viggo.jf.intel.com>
References: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, Ali Saidi <saidi@engin.umich.edu>,
	James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Dave Jones <davej@redhat.com>,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: dmaengine@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51217 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753729AbaAIUQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 15:16:38 -0500
In-Reply-To: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that tcp_dma_try_early_copy() is gone nothing ever sets
copied_early.

Also reverts "53240c208776 tcp: Fix possible double-ack w/ user dma"
since it is no longer necessary.

Cc: Ali Saidi <saidi@engin.umich.edu>
Cc: James Morris <jmorris@namei.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
New in v2.

 net/ipv4/tcp_input.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 33ef18e550c5..15911a280485 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5145,19 +5145,15 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			}
 		} else {
 			int eaten = 0;
-			int copied_early = 0;
 			bool fragstolen = false;
 
-			if (tp->copied_seq == tp->rcv_nxt &&
-			    len - tcp_header_len <= tp->ucopy.len) {
-				if (tp->ucopy.task == current &&
-				    sock_owned_by_user(sk) && !copied_early) {
-					__set_current_state(TASK_RUNNING);
+			if (tp->ucopy.task == current &&
+			    tp->copied_seq == tp->rcv_nxt &&
+			    len - tcp_header_len <= tp->ucopy.len &&
+			    sock_owned_by_user(sk)) {
+				__set_current_state(TASK_RUNNING);
 
-					if (!tcp_copy_to_iovec(sk, skb, tcp_header_len))
-						eaten = 1;
-				}
-				if (eaten) {
+				if (!tcp_copy_to_iovec(sk, skb, tcp_header_len)) {
 					/* Predicted packet is in window by definition.
 					 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
 					 * Hence, check seq<=rcv_wup reduces to:
@@ -5173,9 +5169,8 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 					__skb_pull(skb, tcp_header_len);
 					tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 					NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITSTOUSER);
+					eaten = 1;
 				}
-				if (copied_early)
-					tcp_cleanup_rbuf(sk, skb->len);
 			}
 			if (!eaten) {
 				if (tcp_checksum_complete_user(sk, skb))
@@ -5212,8 +5207,7 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 					goto no_ack;
 			}
 
-			if (!copied_early || tp->rcv_nxt != tp->rcv_wup)
-				__tcp_ack_snd_check(sk, 0);
+			__tcp_ack_snd_check(sk, 0);
 no_ack:
 			if (eaten)
 				kfree_skb_partial(skb, fragstolen);
