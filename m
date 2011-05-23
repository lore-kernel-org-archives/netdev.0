From: akpm@linux-foundation.org
Subject: [patch 1/1] net: convert %p usage to %pK
Date: Mon, 23 May 2011 15:17:35 -0700
Message-ID: <201105232217.p4NMHZiC015498@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eric.dumazet@gmail.com,
	eugeneteo@kernel.org, jmorris@namei.org, kees.cook@canonical.com,
	mingo@elte.hu, tgraf@infradead.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49278 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934318Ab1EWWSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 18:18:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>

The %pK format specifier is designed to hide exposed kernel pointers,
specifically via /proc interfaces.  Exposing these pointers provides an
easy target for kernel write vulnerabilities, since they reveal the
locations of writable structures containing easily triggerable function
pointers.  The behavior of %pK depends on the kptr_restrict sysctl.

If kptr_restrict is set to 0, no deviation from the standard %p behavior
occurs.  If kptr_restrict is set to 1, the default, if the current user
(intended to be a reader via seq_printf(), etc.) does not have CAP_SYSLOG
(currently in the LSM tree), kernel pointers using %pK are printed as 0's.
 If kptr_restrict is set to 2, kernel pointers using %pK are printed as
0's regardless of privileges.  Replacing with 0's was chosen over the
default "(null)", which cannot be parsed by userland %p, which expects
"(nil)".

The supporting code for kptr_restrict and %pK are currently in the -mm
tree.  This patch converts users of %p in net/ to %pK.  Cases of printing
pointers to the syslog are not covered, since this would eliminate useful
information for postmortem debugging and the reading of the syslog is
already optionally protected by the dmesg_restrict sysctl.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: James Morris <jmorris@namei.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Thomas Graf <tgraf@infradead.org>
Cc: Eugene Teo <eugeneteo@kernel.org>
Cc: Kees Cook <kees.cook@canonical.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: David S. Miller <davem@davemloft.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Eric Paris <eparis@parisplace.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/atm/proc.c           |    4 ++--
 net/can/bcm.c            |    6 +++---
 net/ipv4/raw.c           |    2 +-
 net/ipv4/tcp_ipv4.c      |    6 +++---
 net/ipv4/udp.c           |    2 +-
 net/ipv6/raw.c           |    2 +-
 net/ipv6/tcp_ipv6.c      |    6 +++---
 net/ipv6/udp.c           |    2 +-
 net/key/af_key.c         |    2 +-
 net/netlink/af_netlink.c |    2 +-
 net/packet/af_packet.c   |    2 +-
 net/phonet/socket.c      |    2 +-
 net/sctp/proc.c          |    4 ++--
 net/unix/af_unix.c       |    2 +-
 14 files changed, 22 insertions(+), 22 deletions(-)

diff -puN net/atm/proc.c~net-convert-%p-usage-to-%pk net/atm/proc.c
--- a/net/atm/proc.c~net-convert-%p-usage-to-%pk
+++ a/net/atm/proc.c
@@ -191,7 +191,7 @@ static void vcc_info(struct seq_file *se
 {
 	struct sock *sk = sk_atm(vcc);
 
-	seq_printf(seq, "%p ", vcc);
+	seq_printf(seq, "%pK ", vcc);
 	if (!vcc->dev)
 		seq_printf(seq, "Unassigned    ");
 	else
@@ -218,7 +218,7 @@ static void svc_info(struct seq_file *se
 {
 	if (!vcc->dev)
 		seq_printf(seq, sizeof(void *) == 4 ?
-			   "N/A@%p%10s" : "N/A@%p%2s", vcc, "");
+			   "N/A@%pK%10s" : "N/A@%pK%2s", vcc, "");
 	else
 		seq_printf(seq, "%3d %3d %5d         ",
 			   vcc->dev->number, vcc->vpi, vcc->vci);
diff -puN net/can/bcm.c~net-convert-%p-usage-to-%pk net/can/bcm.c
--- a/net/can/bcm.c~net-convert-%p-usage-to-%pk
+++ a/net/can/bcm.c
@@ -165,9 +165,9 @@ static int bcm_proc_show(struct seq_file
 	struct bcm_sock *bo = bcm_sk(sk);
 	struct bcm_op *op;
 
-	seq_printf(m, ">>> socket %p", sk->sk_socket);
-	seq_printf(m, " / sk %p", sk);
-	seq_printf(m, " / bo %p", bo);
+	seq_printf(m, ">>> socket %pK", sk->sk_socket);
+	seq_printf(m, " / sk %pK", sk);
+	seq_printf(m, " / bo %pK", bo);
 	seq_printf(m, " / dropped %lu", bo->dropped_usr_msgs);
 	seq_printf(m, " / bound %s", bcm_proc_getifname(ifname, bo->ifindex));
 	seq_printf(m, " <<<\n");
diff -puN net/ipv4/raw.c~net-convert-%p-usage-to-%pk net/ipv4/raw.c
--- a/net/ipv4/raw.c~net-convert-%p-usage-to-%pk
+++ a/net/ipv4/raw.c
@@ -979,7 +979,7 @@ static void raw_sock_seq_show(struct seq
 	      srcp  = inet->inet_num;
 
 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
 		i, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
diff -puN net/ipv4/tcp_ipv4.c~net-convert-%p-usage-to-%pk net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c~net-convert-%p-usage-to-%pk
+++ a/net/ipv4/tcp_ipv4.c
@@ -2371,7 +2371,7 @@ static void get_openreq4(struct sock *sk
 	int ttd = req->expires - jiffies;
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %pK%n",
 		i,
 		ireq->loc_addr,
 		ntohs(inet_sk(sk)->inet_sport),
@@ -2426,7 +2426,7 @@ static void get_tcp4_sock(struct sock *s
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d%n",
+			"%08X %5d %8d %lu %d %pK %lu %lu %u %u %d%n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
@@ -2461,7 +2461,7 @@ static void get_timewait4_sock(struct in
 	srcp  = ntohs(tw->tw_sport);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK%n",
 		i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
 		3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
 		atomic_read(&tw->tw_refcnt), tw, len);
diff -puN net/ipv4/udp.c~net-convert-%p-usage-to-%pk net/ipv4/udp.c
--- a/net/ipv4/udp.c~net-convert-%p-usage-to-%pk
+++ a/net/ipv4/udp.c
@@ -2090,7 +2090,7 @@ static void udp4_format_sock(struct sock
 	__u16 srcp	  = ntohs(inet->inet_sport);
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d%n",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
diff -puN net/ipv6/raw.c~net-convert-%p-usage-to-%pk net/ipv6/raw.c
--- a/net/ipv6/raw.c~net-convert-%p-usage-to-%pk
+++ a/net/ipv6/raw.c
@@ -1240,7 +1240,7 @@ static void raw6_sock_seq_show(struct se
 	srcp  = inet_sk(sp)->inet_num;
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
diff -puN net/ipv6/tcp_ipv6.c~net-convert-%p-usage-to-%pk net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c~net-convert-%p-usage-to-%pk
+++ a/net/ipv6/tcp_ipv6.c
@@ -2036,7 +2036,7 @@ static void get_openreq6(struct seq_file
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3],
@@ -2087,7 +2087,7 @@ static void get_tcp6_sock(struct seq_fil
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %lu %lu %u %u %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %lu %lu %u %u %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -2129,7 +2129,7 @@ static void get_timewait6_sock(struct se
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
diff -puN net/ipv6/udp.c~net-convert-%p-usage-to-%pk net/ipv6/udp.c
--- a/net/ipv6/udp.c~net-convert-%p-usage-to-%pk
+++ a/net/ipv6/udp.c
@@ -1391,7 +1391,7 @@ static void udp6_sock_seq_show(struct se
 	srcp  = ntohs(inet->inet_sport);
 	seq_printf(seq,
 		   "%5d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
 		   bucket,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
diff -puN net/key/af_key.c~net-convert-%p-usage-to-%pk net/key/af_key.c
--- a/net/key/af_key.c~net-convert-%p-usage-to-%pk
+++ a/net/key/af_key.c
@@ -3656,7 +3656,7 @@ static int pfkey_seq_show(struct seq_fil
 	if (v == SEQ_START_TOKEN)
 		seq_printf(f ,"sk       RefCnt Rmem   Wmem   User   Inode\n");
 	else
-		seq_printf(f ,"%p %-6d %-6u %-6u %-6u %-6lu\n",
+		seq_printf(f, "%pK %-6d %-6u %-6u %-6u %-6lu\n",
 			       s,
 			       atomic_read(&s->sk_refcnt),
 			       sk_rmem_alloc_get(s),
diff -puN net/netlink/af_netlink.c~net-convert-%p-usage-to-%pk net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c~net-convert-%p-usage-to-%pk
+++ a/net/netlink/af_netlink.c
@@ -1985,7 +1985,7 @@ static int netlink_seq_show(struct seq_f
 		struct sock *s = v;
 		struct netlink_sock *nlk = nlk_sk(s);
 
-		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %-8d %-8d %-8lu\n",
+		seq_printf(seq, "%pK %-3d %-6d %08x %-8d %-8d %pK %-8d %-8d %-8lu\n",
 			   s,
 			   s->sk_protocol,
 			   nlk->pid,
diff -puN net/packet/af_packet.c~net-convert-%p-usage-to-%pk net/packet/af_packet.c
--- a/net/packet/af_packet.c~net-convert-%p-usage-to-%pk
+++ a/net/packet/af_packet.c
@@ -2706,7 +2706,7 @@ static int packet_seq_show(struct seq_fi
 		const struct packet_sock *po = pkt_sk(s);
 
 		seq_printf(seq,
-			   "%p %-6d %-4d %04x   %-5d %1d %-6u %-6u %-6lu\n",
+			   "%pK %-6d %-4d %04x   %-5d %1d %-6u %-6u %-6lu\n",
 			   s,
 			   atomic_read(&s->sk_refcnt),
 			   s->sk_type,
diff -puN net/phonet/socket.c~net-convert-%p-usage-to-%pk net/phonet/socket.c
--- a/net/phonet/socket.c~net-convert-%p-usage-to-%pk
+++ a/net/phonet/socket.c
@@ -607,7 +607,7 @@ static int pn_sock_seq_show(struct seq_f
 		struct pn_sock *pn = pn_sk(sk);
 
 		seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu "
-			"%d %p %d%n",
+			"%d %pK %d%n",
 			sk->sk_protocol, pn->sobject, pn->dobject,
 			pn->resource, sk->sk_state,
 			sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
diff -puN net/sctp/proc.c~net-convert-%p-usage-to-%pk net/sctp/proc.c
--- a/net/sctp/proc.c~net-convert-%p-usage-to-%pk
+++ a/net/sctp/proc.c
@@ -212,7 +212,7 @@ static int sctp_eps_seq_show(struct seq_
 	sctp_for_each_hentry(epb, node, &head->chain) {
 		ep = sctp_ep(epb);
 		sk = epb->sk;
-		seq_printf(seq, "%8p %8p %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
+		seq_printf(seq, "%8pK %8pK %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
 			   sctp_sk(sk)->type, sk->sk_state, hash,
 			   epb->bind_addr.port,
 			   sock_i_uid(sk), sock_i_ino(sk));
@@ -316,7 +316,7 @@ static int sctp_assocs_seq_show(struct s
 		assoc = sctp_assoc(epb);
 		sk = epb->sk;
 		seq_printf(seq,
-			   "%8p %8p %-3d %-3d %-2d %-4d "
+			   "%8pK %8pK %-3d %-3d %-2d %-4d "
 			   "%4d %8d %8d %7d %5lu %-5d %5d ",
 			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
 			   assoc->state, hash,
diff -puN net/unix/af_unix.c~net-convert-%p-usage-to-%pk net/unix/af_unix.c
--- a/net/unix/af_unix.c~net-convert-%p-usage-to-%pk
+++ a/net/unix/af_unix.c
@@ -2254,7 +2254,7 @@ static int unix_seq_show(struct seq_file
 		struct unix_sock *u = unix_sk(s);
 		unix_state_lock(s);
 
-		seq_printf(seq, "%p: %08X %08X %08X %04X %02X %5lu",
+		seq_printf(seq, "%pK: %08X %08X %08X %04X %02X %5lu",
 			s,
 			atomic_read(&s->sk_refcnt),
 			0,
_
