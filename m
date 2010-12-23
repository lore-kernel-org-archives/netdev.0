From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH] Convert net %p usage %pK
Date: Wed, 22 Dec 2010 22:22:27 -0500
Message-ID: <1293074547.9820.367.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Patrick McHardy <kaber@trash.net>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Li Zefan <lizf@cn.fujitsu.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyan
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The %pK format specifier is designed to hide exposed kernel pointers,
specifically via /proc interfaces. Exposing these pointers provides an
easy target for kernel write vulnerabilities, since they reveal the
locations of writable structures containing easily triggerable function
pointers. The behavior of %pK depends on the kptr_restrict sysctl.

If kptr_restrict is set to 0, no deviation from the standard %p behavior
occurs.  If kptr_restrict is set to 1, the default, if the current user
(intended to be a reader via seq_printf(), etc.) does not have
CAP_SYSLOG (currently in the LSM tree), kernel pointers using %pK are
printed as 0's.  If kptr_restrict is set to 2, kernel pointers using %pK
are printed as 0's regardless of privileges.  Replacing with 0's was
chosen over the default "(null)", which cannot be parsed by userland %p,
which expects "(nil)".

The supporting code for kptr_restrict and %pK are currently in the -mm
tree.  This patch converts users of %p in net/ to %pK.  Cases of
printing pointers to the syslog are not covered, since this would
eliminate useful information for postmortem debugging and the reading of
the syslog is already optionally protected by the dmesg_restrict sysctl.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
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

diff --git a/net/atm/proc.c b/net/atm/proc.c
index f85da07..be3afde 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -191,7 +191,7 @@ static void vcc_info(struct seq_file *seq, struct atm_vcc *vcc)
 {
 	struct sock *sk = sk_atm(vcc);
 
-	seq_printf(seq, "%p ", vcc);
+	seq_printf(seq, "%pK ", vcc);
 	if (!vcc->dev)
 		seq_printf(seq, "Unassigned    ");
 	else
@@ -218,7 +218,7 @@ static void svc_info(struct seq_file *seq, struct atm_vcc *vcc)
 {
 	if (!vcc->dev)
 		seq_printf(seq, sizeof(void *) == 4 ?
-			   "N/A@%p%10s" : "N/A@%p%2s", vcc, "");
+			   "N/A@%pK%10s" : "N/A@%pK%2s", vcc, "");
 	else
 		seq_printf(seq, "%3d %3d %5d         ",
 			   vcc->dev->number, vcc->vpi, vcc->vci);
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 6faa825..1d2a0d6 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -165,9 +165,9 @@ static int bcm_proc_show(struct seq_file *m, void *v)
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
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 1f85ef2..6cb9d20 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -949,7 +949,7 @@ static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	      srcp  = inet->inet_num;
 
 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
 		i, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e13da6d..86e46a0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2389,7 +2389,7 @@ static void get_openreq4(struct sock *sk, struct request_sock *req,
 	int ttd = req->expires - jiffies;
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %pK%n",
 		i,
 		ireq->loc_addr,
 		ntohs(inet_sk(sk)->inet_sport),
@@ -2444,7 +2444,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d%n",
+			"%08X %5d %8d %lu %d %pK %lu %lu %u %u %d%n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
@@ -2479,7 +2479,7 @@ static void get_timewait4_sock(struct inet_timewait_sock *tw,
 	srcp  = ntohs(tw->tw_sport);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK%n",
 		i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
 		3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
 		atomic_read(&tw->tw_refcnt), tw, len);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5e0a3a5..55dcf56 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2046,7 +2046,7 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 	__u16 srcp	  = ntohs(inet->inet_sport);
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d%n",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 86c3952..9c883b7 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1231,7 +1231,7 @@ static void raw6_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	srcp  = inet_sk(sp)->inet_num;
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7e41e2c..60a2d56 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1975,7 +1975,7 @@ static void get_openreq6(struct seq_file *seq,
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3],
@@ -2026,7 +2026,7 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %lu %lu %u %u %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %lu %lu %u %u %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -2068,7 +2068,7 @@ static void get_timewait6_sock(struct seq_file *seq,
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 91def93..ba25da4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1395,7 +1395,7 @@ static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket
 	srcp  = ntohs(inet->inet_sport);
 	seq_printf(seq,
 		   "%5d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
 		   bucket,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index d87c22d..cf00ddf 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3643,7 +3643,7 @@ static int pfkey_seq_show(struct seq_file *f, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_printf(f ,"sk       RefCnt Rmem   Wmem   User   Inode\n");
 	else
-		seq_printf(f ,"%p %-6d %-6u %-6u %-6u %-6lu\n",
+		seq_printf(f, "%pK %-6d %-6u %-6u %-6u %-6lu\n",
 			       s,
 			       atomic_read(&s->sk_refcnt),
 			       sk_rmem_alloc_get(s),
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 478181d..31425fa 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1990,7 +1990,7 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 		struct sock *s = v;
 		struct netlink_sock *nlk = nlk_sk(s);
 
-		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %-8d %-8d %-8lu\n",
+		seq_printf(seq, "%pK %-3d %-6d %08x %-8d %-8d %pK %-8d %-8d %-8lu\n",
 			   s,
 			   s->sk_protocol,
 			   nlk->pid,
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8298e67..02b1b58 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2639,7 +2639,7 @@ static int packet_seq_show(struct seq_file *seq, void *v)
 		const struct packet_sock *po = pkt_sk(s);
 
 		seq_printf(seq,
-			   "%p %-6d %-4d %04x   %-5d %1d %-6u %-6u %-6lu\n",
+			   "%pK %-6d %-4d %04x   %-5d %1d %-6u %-6u %-6lu\n",
 			   s,
 			   atomic_read(&s->sk_refcnt),
 			   s->sk_type,
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 25f746d..2c8f9d9 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -632,7 +632,7 @@ static int pn_sock_seq_show(struct seq_file *seq, void *v)
 		struct pn_sock *pn = pn_sk(sk);
 
 		seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu "
-			"%d %p %d%n",
+			"%d %pK %d%n",
 			sk->sk_protocol, pn->sobject, 0, pn->resource,
 			sk->sk_state,
 			sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 61aacfb..05a6ce2 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -212,7 +212,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 	sctp_for_each_hentry(epb, node, &head->chain) {
 		ep = sctp_ep(epb);
 		sk = epb->sk;
-		seq_printf(seq, "%8p %8p %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
+		seq_printf(seq, "%8pK %8pK %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
 			   sctp_sk(sk)->type, sk->sk_state, hash,
 			   epb->bind_addr.port,
 			   sock_i_uid(sk), sock_i_ino(sk));
@@ -316,7 +316,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		assoc = sctp_assoc(epb);
 		sk = epb->sk;
 		seq_printf(seq,
-			   "%8p %8p %-3d %-3d %-2d %-4d "
+			   "%8pK %8pK %-3d %-3d %-2d %-4d "
 			   "%4d %8d %8d %7d %5lu %-5d %5d ",
 			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
 			   assoc->state, hash,
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 2268e67..e6d7d04 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2225,7 +2225,7 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 		struct unix_sock *u = unix_sk(s);
 		unix_state_lock(s);
 
-		seq_printf(seq, "%p: %08X %08X %08X %04X %02X %5lu",
+		seq_printf(seq, "%pK: %08X %08X %08X %04X %02X %5lu",
 			s,
 			atomic_read(&s->sk_refcnt),
 			0,
