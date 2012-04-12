From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [RFC v3] Add TCP encap_rcv hook
Date: Thu, 12 Apr 2012 16:42:04 +0900
Message-ID: <20120412074159.GA10866@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This hook is based on a hook of the same name provided by UDP.  It provides
a way for to receive packets that have a TCP header and treat them in some
alternate way.

It is intended to be used by an implementation of the STT tunneling
protocol within Open vSwtich's datapath. A prototype of such an
implementation has been made.

The STT draft is available at
http://tools.ietf.org/html/draft-davie-stt-01

My prototype STT implementation has been posted to the dev-UOEtcQmXneFl884UGnbwIQ@public.gmane.org
The first version can be found at:
http://www.mail-archive.com/dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org/msg08877.html

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---
 include/linux/tcp.h |    3 +++
 net/ipv4/tcp_ipv4.c |   23 ++++++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

v3
* First post to netdev
* Replace more UDP references with TCP
* Move socket accesses to inside socket lock
  and release lock on return.

v2
* Fix comment to refer to TCP rather than UDP
* Allow skb to continue traversing the stack if
  the encap_rcv callback returns a positive value.
  This is the same behaviour as the UDP hook.

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b6c62d2..7210b23 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -472,6 +472,9 @@ struct tcp_sock {
 	 * contains related tcp_cookie_transactions fields.
 	 */
 	struct tcp_cookie_values  *cookie_values;
+
+	/* For encapsulation sockets. */
+	int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3a25cf7..9898f71 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1666,8 +1666,10 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	struct sock *sk;
+	struct tcp_sock *tp;
 	int ret;
 	struct net *net = dev_net(skb->dev);
+	int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
 
 	if (skb->pkt_type != PACKET_HOST)
 		goto discard_it;
@@ -1726,9 +1728,27 @@ process:
 
 	bh_lock_sock_nested(sk);
 	ret = 0;
+
+	tp = tcp_sk(sk);
+	encap_rcv = ACCESS_ONCE(tp->encap_rcv);
+	if (encap_rcv != NULL) {
+		/*
+		 * This is an encapsulation socket so pass the skb to
+		 * the socket's tcp_encap_rcv() hook. Otherwise, just
+		 * fall through and pass this up the TCP socket.
+		 * up->encap_rcv() returns the following value:
+		 * <=0 if skb was successfully passed to the encap
+		 *     handler or was discarded by it.
+		 * >0 if skb should be passed on to TCP.
+		 */
+		if (encap_rcv(sk, skb) <= 0) {
+			ret = 0;
+			goto unlock_sock;
+		}
+	}
+
 	if (!sock_owned_by_user(sk)) {
 #ifdef CONFIG_NET_DMA
-		struct tcp_sock *tp = tcp_sk(sk);
 		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
 			tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
 		if (tp->ucopy.dma_chan)
@@ -1744,6 +1764,7 @@ process:
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
 		goto discard_and_relse;
 	}
+unlock_sock:
 	bh_unlock_sock(sk);
 
 	sock_put(sk);
-- 
1.7.9.5
