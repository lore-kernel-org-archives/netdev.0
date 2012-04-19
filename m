From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Thu, 19 Apr 2012 13:53:35 +0900
Message-ID: <20120419045333.GA21311@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
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
The second version can be found at:
http://www.mail-archive.com/dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org/msg09001.html
It needs to be updated to call tcp_encap_enable()

Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---
v4
* Make use of static_key,
  a tonic for insanity suggested by Eric Dumazet

v3
* Replace more UDP references with TCP
* Move socket accesses to inside socket lock
  and release lock on return.

v2
* Fix comment to refer to TCP rather than UDP
* Allow skb to continue traversing the stack if
  the encap_rcv callback returns a positive value.
  This is the same behaviour as the UDP hook.
---
 include/linux/tcp.h |    3 +++
 include/net/tcp.h   |    1 +
 net/ipv4/tcp_ipv4.c |   34 +++++++++++++++++++++++++++++++++-
 3 files changed, 37 insertions(+), 1 deletion(-)

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
diff --git a/include/net/tcp.h b/include/net/tcp.h
index d5984e3..35d4070 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1576,5 +1576,6 @@ static inline struct tcp_extend_values *tcp_xv(struct request_values *rvp)
 
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
+extern void tcp_encap_enable(void);
 
 #endif	/* _TCP_H */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0cb86ce..907735d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -62,6 +62,7 @@
 #include <linux/init.h>
 #include <linux/times.h>
 #include <linux/slab.h>
+#include <linux/static_key.h>
 
 #include <net/net_namespace.h>
 #include <net/icmp.h>
@@ -1657,6 +1658,14 @@ csum_err:
 }
 EXPORT_SYMBOL(tcp_v4_do_rcv);
 
+static struct static_key tcp_encap_needed __read_mostly;
+void tcp_encap_enable(void)
+{
+	if (!static_key_enabled(&tcp_encap_needed))
+		static_key_slow_inc(&tcp_encap_needed);
+}
+EXPORT_SYMBOL(tcp_encap_enable);
+
 /*
  *	From tcp_input.c
  */
@@ -1666,6 +1675,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	struct sock *sk;
+	struct tcp_sock *tp;
 	int ret;
 	struct net *net = dev_net(skb->dev);
 
@@ -1726,9 +1736,30 @@ process:
 
 	bh_lock_sock_nested(sk);
 	ret = 0;
+
+	tp = tcp_sk(sk);
+	if (static_key_false(&tcp_encap_needed)) {
+		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
+		encap_rcv = ACCESS_ONCE(tp->encap_rcv);
+		if (encap_rcv != NULL) {
+			/*
+			 * This is an encapsulation socket so pass the skb to
+			 * the socket's tcp_encap_rcv() hook. Otherwise, just
+			 * fall through and pass this up the TCP socket.
+			 * up->encap_rcv() returns the following value:
+			 * <=0 if skb was successfully passed to the encap
+			 *     handler or was discarded by it.
+			 * >0 if skb should be passed on to TCP.
+			 */
+			if (encap_rcv(sk, skb) <= 0) {
+				ret = 0;
+				goto unlock_sock;
+			}
+		}
+	}
+
 	if (!sock_owned_by_user(sk)) {
 #ifdef CONFIG_NET_DMA
-		struct tcp_sock *tp = tcp_sk(sk);
 		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
 			tp->ucopy.dma_chan = net_dma_find_channel();
 		if (tp->ucopy.dma_chan)
@@ -1744,6 +1775,7 @@ process:
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
 		goto discard_and_relse;
 	}
+unlock_sock:
 	bh_unlock_sock(sk);
 
 	sock_put(sk);
-- 
1.7.9.5
