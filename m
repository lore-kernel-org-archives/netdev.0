From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Cleanup the IPv6 addresses printing in /proc files
Date: Tue, 23 Oct 2007 20:37:22 +0400
Message-ID: <471E2342.8090907@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39909 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbXJWQgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 12:36:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The /proc/net udp6, tcp6 and raw6 files print the IPs of
the connection ends. Make a NIP6Lxxx macros (L stands for
"long") for making the printing code look nicer.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 94bc996..5d199ae 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -307,6 +307,13 @@ static inline int __attribute__ ((format (printf, 1, 2))) pr_debug(const char *
 #define NIP6_FMT "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x"
 #define NIP6_SEQFMT "%04x%04x%04x%04x%04x%04x%04x%04x"
 
+#define NIP6L(addr) \
+	((addr).s6_addr32[0]), \
+	((addr).s6_addr32[1]), \
+	((addr).s6_addr32[2]), \
+	((addr).s6_addr32[3])
+#define NIP6L_FMT "%08X%08X%08X%08X"
+
 #if defined(__LITTLE_ENDIAN)
 #define HIPQUAD(addr) \
 	((unsigned char *)&addr)[3], \
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ca24ef1..c3a1939 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1250,13 +1250,9 @@ static void raw6_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	destp = 0;
 	srcp  = inet_sk(sp)->num;
 	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+		   "%4d: " NIP6L_FMT ":%04X " NIP6L_FMT ":%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p\n",
-		   i,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3], srcp,
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
+		   i, NIP6L(*src), srcp, NIP6L(*dest), destp,
 		   sp->sk_state,
 		   atomic_read(&sp->sk_wmem_alloc),
 		   atomic_read(&sp->sk_rmem_alloc),
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 737b755..0041be3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1945,15 +1945,10 @@ static void get_openreq6(struct seq_file *seq,
 		ttd = 0;
 
 	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+		   "%4d: " NIP6L_FMT ":%04X " NIP6L_FMT ":%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
-		   i,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3],
-		   ntohs(inet_sk(sk)->sport),
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3],
-		   ntohs(inet_rsk(req)->rmt_port),
+		   i, NIP6L(*src), ntohs(inet_sk(sk)->sport),
+		   NIP6L(*dest), ntohs(inet_rsk(req)->rmt_port),
 		   TCP_SYN_RECV,
 		   0,0, /* could print option size, but that is af dependent. */
 		   1,   /* timers active (only the expire timer) */
@@ -1996,13 +1991,9 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 	}
 
 	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+		   "%4d: " NIP6L_FMT ":%04X " NIP6L_FMT ":%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %u %u %u %u %d\n",
-		   i,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3], srcp,
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
+		   i, NIP6L(*src), srcp, NIP6L(*dest), destp,
 		   sp->sk_state,
 		   tp->write_seq-tp->snd_una,
 		   (sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
@@ -2037,13 +2028,9 @@ static void get_timewait6_sock(struct seq_file *seq,
 	srcp  = ntohs(tw->tw_sport);
 
 	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+		   "%4d: " NIP6L_FMT ":%04X " NIP6L_FMT ":%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
-		   i,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3], srcp,
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
+		   i, NIP6L(*src), srcp, NIP6L(*dest), destp,
 		   tw->tw_substate, 0, 0,
 		   3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
 		   atomic_read(&tw->tw_refcnt), tw);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index caebad6..bcc5f8e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -919,13 +919,9 @@ static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket
 	destp = ntohs(inet->dport);
 	srcp  = ntohs(inet->sport);
 	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+		   "%4d: " NIP6L_FMT ":%04X " NIP6L_FMT ":%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p\n",
-		   bucket,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3], srcp,
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
+		   bucket, NIP6L(*src), srcp, NIP6L(*dest), destp,
 		   sp->sk_state,
 		   atomic_read(&sp->sk_wmem_alloc),
 		   atomic_read(&sp->sk_rmem_alloc),
