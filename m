From: Ralf Baechle <ralf@linux-mips.org>
Subject: [RFC] memory barrier cleanups
Date: Wed, 6 Dec 2006 21:49:46 +0000
Message-ID: <20061206214946.GA22159@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:42944 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937681AbWLFVtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 16:49:50 -0500
Received: from localhost.localdomain ([127.0.0.1]:38125 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20038616AbWLFVtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 21:49:49 +0000
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I believe all the below memory barriers only matter on SMP so therefore
the smp_* variant of the barrier should be used.

I'm wondering if the barrier in net/ipv4/inet_timewait_sock.c should be
dropped entirely.  schedule_work's implementation currently implies a
memory barrier and I think sane semantics of schedule_work() should imply
a memory barrier, as needed so the caller shouldn't have to worry.
It's not quite obvious why the barrier in net/packet/af_packet.c is
needed; maybe it should be implied through flush_dcache_page?

  Ralf

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/net/core/wireless.c b/net/core/wireless.c
index cb1b872..f69ab7b 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -2130,7 +2130,7 @@ int iw_handler_set_spy(struct net_device
 	 * The rtnl_lock() make sure we don't race with the other iw_handlers.
 	 * This make sure wireless_spy_update() "see" that the spy list
 	 * is temporarily disabled. */
-	wmb();
+	smp_wmb();
 
 	/* Are there are addresses to copy? */
 	if(wrqu->data.length > 0) {
@@ -2159,7 +2159,7 @@ #endif	/* WE_SPY_DEBUG */
 	}
 
 	/* Make sure above is updated before re-enabling */
-	wmb();
+	smp_wmb();
 
 	/* Enable addresses */
 	spydata->spy_number = wrqu->data.length;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index cdd8053..1a852c2 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -178,7 +178,7 @@ void inet_twdr_hangman(unsigned long dat
 	need_timer = 0;
 	if (inet_twdr_do_twkill_work(twdr, twdr->slot)) {
 		twdr->thread_slots |= (1 << twdr->slot);
-		mb();
+		smp_mb();
 		schedule_work(&twdr->twkill_work);
 		need_timer = 1;
 	} else {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9304034..c701f6a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4235,7 +4235,7 @@ static int tcp_rcv_synsent_state_process
 		 * Change state from SYN-SENT only after copied_seq
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
-		mb();
+		smp_mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
 		security_inet_conn_established(sk, skb);
@@ -4483,7 +4483,7 @@ int tcp_rcv_state_process(struct sock *s
 		case TCP_SYN_RECV:
 			if (acceptable) {
 				tp->copied_seq = tp->rcv_nxt;
-				mb();
+				smp_mb();
 				tcp_set_state(sk, TCP_ESTABLISHED);
 				sk->sk_state_change(sk);
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 08e68b6..da73e8a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -660,7 +660,7 @@ static int tpacket_rcv(struct sk_buff *s
 	sll->sll_ifindex = dev->ifindex;
 
 	h->tp_status = status;
-	mb();
+	smp_mb();
 
 	{
 		struct page *p_start, *p_end;
