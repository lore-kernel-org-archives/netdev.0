From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH] RFC save a few atomics in tcp_memory_schedule()
Date: Mon, 20 May 2002 13:52:55 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0205201347400.7881-100000@w-nivedita2.des.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

The patch below tries to save a few atomic reads,
based on the assumption that we can tolerate slightly
stale data here, given that actions are "relaxed".
(Otherwise we should be locking whole thing anyway)..

Would this be reasonable, or what am I missing?

thanks,
Nivedita


diff -urN linux-2.4.18/net/ipv4/tcp.c linux-2.4.18new/net/ipv4/tcp.c
--- linux-2.4.18/net/ipv4/tcp.c	Fri Dec 21 09:42:05 2001
+++ linux-2.4.18new/net/ipv4/tcp.c	Mon May 20 12:40:00 2002
@@ -286,25 +286,27 @@
 int tcp_mem_schedule(struct sock *sk, int size, int kind)
 {
 	int amt = TCP_PAGES(size);
+	int allocated;
 
 	sk->forward_alloc += amt*TCP_MEM_QUANTUM;
 	atomic_add(amt, &tcp_memory_allocated);
+	allocated = atomic_read(&tcp_memory_allocated);
 
 	/* Under limit. */
-	if (atomic_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
+	if (allocated < sysctl_tcp_mem[0]) {
 		if (tcp_memory_pressure)
 			tcp_memory_pressure = 0;
 		return 1;
 	}
 
 	/* Over hard limit. */
-	if (atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2]) {
+	if (allocated > sysctl_tcp_mem[2]) {
 		tcp_enter_memory_pressure();
 		goto suppress_allocation;
 	}
 
 	/* Under pressure. */
-	if (atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[1])
+	if (allocated > sysctl_tcp_mem[1])
 		tcp_enter_memory_pressure();
 
 	if (kind) {
@@ -316,7 +318,7 @@
 	}
 
 	if (!tcp_memory_pressure ||
-	    sysctl_tcp_mem[2] > atomic_read(&tcp_sockets_allocated)
+	    sysctl_tcp_mem[2] > allocated
 	    * TCP_PAGES(sk->wmem_queued+atomic_read(&sk->rmem_alloc)+
 			sk->forward_alloc))
 		return 1;
