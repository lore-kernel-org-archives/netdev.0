From: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Subject: [RFC PATCH 2/5] tcp: add TCP support for low latency receive poll.
Date: Wed, 27 Feb 2013 09:56:01 -0800
Message-ID: <20130227175601.10611.99536.stgit@gitlad.jf.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

an example of how one could add support for ndo_ll_poll to TCP.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 net/ipv4/Kconfig     |   11 +++++++++++
 net/ipv4/tcp.c       |   20 ++++++++++++++++++++
 net/ipv4/tcp_input.c |    4 ++++
 3 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index e52f011..9796aba 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -414,6 +414,17 @@ config INET_LL_RX_POLL
 
 	  If unsure, say N.
 
+config INET_LL_TCP_POLL
+	bool "Low Latency TCP Receive Poll"
+	depends on INET_LL_RX_POLL
+	default n
+	---help---
+	  TCP support for Low Latency TCP Queue Poll.
+	  (For network cards tht support this option.)
+	  Add support to the TCP stack for direct polling of the network card.
+
+	  If unsure, say N.
+
 config INET_DIAG
 	tristate "INET: socket monitoring interface"
 	default y
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 47e854f..e3d1a8e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -279,6 +279,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
+#include <net/ll_poll.h>
 
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
@@ -1475,6 +1476,17 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 
 	if (sk->sk_state == TCP_LISTEN)
 		return -ENOTCONN;
+
+#ifdef CONFIG_INET_LL_TCP_POLL
+/* TODO: what do we do if the state changes after sk_poll_ll()? */
+	if (sk_valid_ll(sk) && skb_queue_empty(&sk->sk_receive_queue)
+		&& (sk->sk_state == TCP_ESTABLISHED)) {
+
+		release_sock(sk);
+		sk_poll_ll(sk);
+		lock_sock(sk);
+	}
+#endif
 	while ((skb = tcp_recv_skb(sk, seq, &offset)) != NULL) {
 		if (offset < skb->len) {
 			int used;
@@ -1513,6 +1525,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 			if (offset + 1 != skb->len)
 				continue;
 		}
+		sk_mark_ll(sk, skb);
 		if (tcp_hdr(skb)->fin) {
 			sk_eat_skb(sk, skb, false);
 			++seq;
@@ -1560,6 +1573,12 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
 
+#ifdef CONFIG_INET_LL_TCP_POLL
+	if (sk_valid_ll(sk) && skb_queue_empty(&sk->sk_receive_queue)
+	    && (sk->sk_state == TCP_ESTABLISHED))
+		sk_poll_ll(sk);
+#endif
+
 	lock_sock(sk);
 
 	err = -ENOTCONN;
@@ -1864,6 +1883,7 @@ do_prequeue:
 					break;
 				}
 			}
+			sk_mark_ll(sk, skb);
 		}
 
 		*seq += used;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a759e19..5c40bd3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -74,6 +74,7 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <net/netdma.h>
+#include <net/ll_poll.h>
 
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
@@ -4618,6 +4619,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 				tp->copied_seq += chunk;
 				eaten = (chunk == skb->len);
 				tcp_rcv_space_adjust(sk);
+				sk_mark_ll(sk, skb);
 			}
 			local_bh_disable();
 		}
@@ -5185,6 +5187,7 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 		tp->ucopy.len -= chunk;
 		tp->copied_seq += chunk;
 		tcp_rcv_space_adjust(sk);
+		sk_mark_ll(sk, skb);
 	}
 
 	local_bh_disable();
@@ -5244,6 +5247,7 @@ static bool tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 		tp->ucopy.len -= chunk;
 		tp->copied_seq += chunk;
 		tcp_rcv_space_adjust(sk);
+		sk_mark_ll(sk, skb);
 
 		if ((tp->ucopy.len == 0) ||
 		    (tcp_flag_word(tcp_hdr(skb)) & TCP_FLAG_PSH) ||
