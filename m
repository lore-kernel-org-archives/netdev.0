From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] TCP acts like it is always out of memory.
Date: Thu, 1 Jul 2004 13:37:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org>
	<20040629222751.392f0a82.davem@redhat.com>
	<20040630152750.2d01ca51@dell_ss3.pdx.osdl.net>
	<20040630153049.3ca25b76.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040630153049.3ca25b76.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Current 2.6.7 tree acts as if it is alway under memory pressure because
a recent change did a s/tcp_memory_pressure/tcp_prot.memory_pressure/.
The problem is tcp_prot.memory_pressure is a pointer, so it is always non-zero!

Rather than using *tcp_prot.memory_pressure, just go back to looking at
tcp_memory_pressure.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-07-01 13:36:58 -07:00
+++ b/net/ipv4/tcp_input.c	2004-07-01 13:36:58 -07:00
@@ -259,7 +259,7 @@
 	/* Check #1 */
 	if (tp->rcv_ssthresh < tp->window_clamp &&
 	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
-	    !tcp_prot.memory_pressure) {
+	    !tcp_memory_pressure) {
 		int incr;
 
 		/* Check #2. Increase window, if skb with such overhead
@@ -349,7 +349,7 @@
 	if (ofo_win) {
 		if (sk->sk_rcvbuf < sysctl_tcp_rmem[2] &&
 		    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK) &&
-		    !tcp_prot.memory_pressure &&
+		    !tcp_memory_pressure &&
 		    atomic_read(&tcp_memory_allocated) < sysctl_tcp_mem[0])
 			sk->sk_rcvbuf = min(atomic_read(&sk->sk_rmem_alloc),
 					    sysctl_tcp_rmem[2]);
@@ -3764,7 +3764,7 @@
 
 	if (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
 		tcp_clamp_window(sk, tp);
-	else if (tcp_prot.memory_pressure)
+	else if (tcp_memory_pressure)
 		tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U * tp->advmss);
 
 	tcp_collapse_ofo_queue(sk);
@@ -3844,7 +3844,7 @@
 
 	if (tp->packets_out < tp->snd_cwnd &&
 	    !(sk->sk_userlocks & SOCK_SNDBUF_LOCK) &&
-	    !tcp_prot.memory_pressure &&
+	    !tcp_memory_pressure &&
 	    atomic_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
  		int sndmem = max_t(u32, tp->mss_clamp, tp->mss_cache) +
 			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff),
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-07-01 13:36:58 -07:00
+++ b/net/ipv4/tcp_output.c	2004-07-01 13:36:58 -07:00
@@ -672,7 +672,7 @@
 	if (free_space < full_space/2) {
 		tp->ack.quick = 0;
 
-		if (tcp_prot.memory_pressure)
+		if (tcp_memory_pressure)
 			tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U*tp->advmss);
 
 		if (free_space < mss)
diff -Nru a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	2004-07-01 13:36:58 -07:00
+++ b/net/ipv4/tcp_timer.c	2004-07-01 13:36:58 -07:00
@@ -257,7 +257,7 @@
 	TCP_CHECK_TIMER(sk);
 
 out:
-	if (tcp_prot.memory_pressure)
+	if (tcp_memory_pressure)
 		sk_stream_mem_reclaim(sk);
 out_unlock:
 	bh_unlock_sock(sk);
