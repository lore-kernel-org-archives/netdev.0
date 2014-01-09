From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 3/4] net: make tcp_cleanup_rbuf private
Date: Thu, 09 Jan 2014 12:16:52 -0800
Message-ID: <20140109201642.28381.82141.stgit@viggo.jf.intel.com>
References: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: dmaengine@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51694 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753729AbaAIUQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 15:16:53 -0500
In-Reply-To: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_dma was the only external user so this can become local to tcp.c
again.

Cc: James Morris <jmorris@namei.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
New in v2
 include/net/tcp.h |    1 -
 net/ipv4/tcp.c    |   10 +++++-----
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 084c163e9d40..571036b3bead 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -370,7 +370,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			 const struct tcphdr *th, unsigned int len);
 void tcp_rcv_space_adjust(struct sock *sk);
-void tcp_cleanup_rbuf(struct sock *sk, int copied);
 int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp);
 void tcp_twsk_destructor(struct sock *sk);
 ssize_t tcp_splice_read(struct socket *sk, loff_t *ppos,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8dc913dfbaef..70c905a7d2b8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1332,7 +1332,7 @@ static int tcp_peek_sndq(struct sock *sk, struct msghdr *msg, int len)
  * calculation of whether or not we must ACK for the sake of
  * a window update.
  */
-void tcp_cleanup_rbuf(struct sock *sk, int copied)
+static void cleanup_rbuf(struct sock *sk, int copied)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	bool time_to_ack = false;
@@ -1507,7 +1507,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	/* Clean up data we have read: This will do ACK frames. */
 	if (copied > 0) {
 		tcp_recv_skb(sk, seq, &offset);
-		tcp_cleanup_rbuf(sk, copied);
+		cleanup_rbuf(sk, copied);
 	}
 	return copied;
 }
@@ -1658,7 +1658,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			}
 		}
 
-		tcp_cleanup_rbuf(sk, copied);
+		cleanup_rbuf(sk, copied);
 
 		if (!sysctl_tcp_low_latency && tp->ucopy.task == user_recv) {
 			/* Install new reader */
@@ -1831,7 +1831,7 @@ skip_copy:
 	 */
 
 	/* Clean up data we have read: This will do ACK frames. */
-	tcp_cleanup_rbuf(sk, copied);
+	cleanup_rbuf(sk, copied);
 
 	release_sock(sk);
 	return copied;
@@ -2494,7 +2494,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			    (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT) &&
 			    inet_csk_ack_scheduled(sk)) {
 				icsk->icsk_ack.pending |= ICSK_ACK_PUSHED;
-				tcp_cleanup_rbuf(sk, 1);
+				cleanup_rbuf(sk, 1);
 				if (!(val & 1))
 					icsk->icsk_ack.pingpong = 1;
 			}
