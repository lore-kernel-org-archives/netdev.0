From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.6] fix deadlock with ip_queue and tcp local input path
Date: Thu, 26 May 2005 16:24:21 +0200
Message-ID: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r3Mh/mGWsojp83Sz"
Cc: Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--r3Mh/mGWsojp83Sz
Content-Type: multipart/mixed; boundary="moLig8uJibGkz5Yz"
Content-Disposition: inline


--moLig8uJibGkz5Yz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

When we have ip_queue being used from LOCAL_IN, then we end up with a
situation where the verdicts coming back from userspace traverse the TCP
input path from syscall context.  While this seems to work most of the
time, there's an ungly deadlock:

syscall context is interrupted by the timer interrupt.  When the timer
interrupt leaves, the timer softirq get's scheduled and calls
tcp_delack_timer() and alike.  They themselves do bh_lock_sock(sk),
which is already held from somewhere else[1] -> boom.

The patch below adds an additional queue for ip_queue verdicts.  They
come up from userspace, are appended to a queue which is then processed
by a tasklet.  The tasklet itself runs in softirq context, so when timer
hardirq leaves, no tcp_delack_timer() will be executed until
nf_reinject() has finished.

Dave: Please don't apply yet, I want to receive feedback from the
netfilter developers first.  I'm just Cc'ing netdev in case somebody
wants an intermediate fix to fix the problem.

[1] i didn't actually find from where that lock was held.  In any case,
it didn't seem nice to traverse the IP input codepath from syscall
context.  There might be a number of places which just assume to run in
softirq.

Comments welcome!

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--moLig8uJibGkz5Yz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment;
	filename="2.6.12-rc5-ip_queue-local-reinject-smp-deadlock-fix.patch"
Content-Transfer-Encoding: quoted-printable

Fix ip_queue when used from LOCAL_IN hook.  Without this patch, packets are
nf_reinject()ed from syscall context.   Syscall context will be interupted
=66rom timer interrupt, and timer interrupt will call TCP timer code such as
tcp_delack_timer(), which in turn tries to bh_lock_sock() and deadlocks at =
that
point.

Thanks to Holger Eitzenberger <heitzenberger@astaro.com> and=20
Stephan Scholz <sscholz@astaro.com> for providing me with backtraces.

Signed-off-by: Harald Welte <laforge@netfilter.org>


Index: linux-2.6.12-rc5/net/ipv4/netfilter/ip_queue.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.12-rc5.orig/net/ipv4/netfilter/ip_queue.c	2005-05-26 15:50:01=
=2E000000000 +0200
+++ linux-2.6.12-rc5/net/ipv4/netfilter/ip_queue.c	2005-05-26 16:09:08.0000=
00000 +0200
@@ -3,6 +3,8 @@
  * communicating with userspace via netlink.
  *
  * (C) 2000-2002 James Morris <jmorris@intercode.com.au>
+ * (C) 2003-2004 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2005 Harald Welte <laforge@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -17,6 +19,9 @@
  * 2005-01-10: Added /proc counter for dropped packets; fixed so
  *             packets aren't delivered to user space if they're going=20
  *             to be dropped.=20
+ * 2005-05-25: Issue verdict from tasklet context, not from syscall (netli=
nk
+ *             sendmsg) to avoid deadlocks in TCP input path with timer
+ *             softirq.
  *
  */
 #include <linux/module.h>
@@ -40,6 +45,7 @@
 #define IPQ_PROC_FS_NAME "ip_queue"
 #define NET_IPQ_QMAX 2088
 #define NET_IPQ_QMAX_NAME "ip_queue_maxlen"
+#define	IPQ_VERDICT_BATCH 10
=20
 struct ipq_rt_info {
 	__u8 tos;
@@ -52,6 +58,16 @@
 	struct nf_info *info;
 	struct sk_buff *skb;
 	struct ipq_rt_info rt_info;
+
+	/* only used in verdict_queue */
+	int verdict;
+};
+
+struct ipq_queue {
+	struct list_head list;
+	unsigned int total;
+	unsigned int dropped;
+	unsigned int user_dropped;
 };
=20
 typedef int (*ipq_cmpfn)(struct ipq_queue_entry *, unsigned long);
@@ -61,14 +77,16 @@
 static DEFINE_RWLOCK(queue_lock);
 static int peer_pid;
 static unsigned int copy_range;
-static unsigned int queue_total;
-static unsigned int queue_dropped =3D 0;
-static unsigned int queue_user_dropped =3D 0;
 static struct sock *ipqnl;
-static LIST_HEAD(queue_list);
 static DECLARE_MUTEX(ipqnl_sem);
=20
-static void
+static struct ipq_queue pkt_queue;	/* queue of packets to userspace */
+static struct ipq_queue verdict_queue;	/* queue of verdicst from userspace=
 */
+
+static void ipq_verdict_task(unsigned long arg);
+static DECLARE_TASKLET(ipq_verdict_tasklet, ipq_verdict_task, 0);
+
+static inline void
 ipq_issue_verdict(struct ipq_queue_entry *entry, int verdict)
 {
 	nf_reinject(entry->skb, entry->info, verdict);
@@ -76,10 +94,10 @@
 }
=20
 static inline void
-__ipq_enqueue_entry(struct ipq_queue_entry *entry)
+__ipq_enqueue_entry(struct ipq_queue *queue, struct ipq_queue_entry *entry)
 {
-       list_add(&entry->list, &queue_list);
-       queue_total++;
+       list_add(&entry->list, &queue->list);
+       queue->total++;
 }
=20
 /*
@@ -87,11 +105,11 @@
  * entry if cmpfn is NULL.
  */
 static inline struct ipq_queue_entry *
-__ipq_find_entry(ipq_cmpfn cmpfn, unsigned long data)
+__ipq_find_entry(struct ipq_queue *queue, ipq_cmpfn cmpfn, unsigned long d=
ata)
 {
 	struct list_head *p;
=20
-	list_for_each_prev(p, &queue_list) {
+	list_for_each_prev(p, &queue->list) {
 		struct ipq_queue_entry *entry =3D (struct ipq_queue_entry *)p;
 	=09
 		if (!cmpfn || cmpfn(entry, data))
@@ -101,33 +119,49 @@
 }
=20
 static inline void
-__ipq_dequeue_entry(struct ipq_queue_entry *entry)
+__ipq_dequeue_entry(struct ipq_queue *queue, struct ipq_queue_entry *entry)
 {
 	list_del(&entry->list);
-	queue_total--;
+	queue->total--;
 }
=20
 static inline struct ipq_queue_entry *
-__ipq_find_dequeue_entry(ipq_cmpfn cmpfn, unsigned long data)
+__ipq_find_dequeue_entry(struct ipq_queue *queue, ipq_cmpfn cmpfn,=20
+			 unsigned long data)
 {
 	struct ipq_queue_entry *entry;
=20
-	entry =3D __ipq_find_entry(cmpfn, data);
+	entry =3D __ipq_find_entry(queue, cmpfn, data);
 	if (entry =3D=3D NULL)
 		return NULL;
=20
-	__ipq_dequeue_entry(entry);
+	__ipq_dequeue_entry(queue, entry);
 	return entry;
 }
=20
+static void
+ipq_enqueue_verdict(struct ipq_queue_entry *entry, int verdict)
+{
+	entry->verdict =3D verdict;
+
+	write_lock_bh(&queue_lock);
+	if (verdict_queue.total >=3D queue_maxlen) {
+		verdict_queue.dropped++;
+		write_unlock_bh(&queue_lock);
+	}
+	__ipq_enqueue_entry(&verdict_queue, entry);
+	write_unlock_bh(&queue_lock);
+
+	tasklet_schedule(&ipq_verdict_tasklet);
+}
=20
 static inline void
 __ipq_flush(int verdict)
 {
 	struct ipq_queue_entry *entry;
 =09
-	while ((entry =3D __ipq_find_dequeue_entry(NULL, 0)))
-		ipq_issue_verdict(entry, verdict);
+	while ((entry =3D __ipq_find_dequeue_entry(&pkt_queue, NULL, 0)))
+		ipq_enqueue_verdict(entry, verdict);
 }
=20
 static inline int
@@ -166,12 +200,13 @@
 }
=20
 static struct ipq_queue_entry *
-ipq_find_dequeue_entry(ipq_cmpfn cmpfn, unsigned long data)
+ipq_find_dequeue_entry(struct ipq_queue *queue, ipq_cmpfn cmpfn,=20
+		       unsigned long data)
 {
 	struct ipq_queue_entry *entry;
 =09
 	write_lock_bh(&queue_lock);
-	entry =3D __ipq_find_dequeue_entry(cmpfn, data);
+	entry =3D __ipq_find_dequeue_entry(queue, cmpfn, data);
 	write_unlock_bh(&queue_lock);
 	return entry;
 }
@@ -182,6 +217,7 @@
 	write_lock_bh(&queue_lock);
 	__ipq_flush(verdict);
 	write_unlock_bh(&queue_lock);
+
 }
=20
 static struct sk_buff *
@@ -306,24 +342,24 @@
 	if (!peer_pid)
 		goto err_out_free_nskb;=20
=20
-	if (queue_total >=3D queue_maxlen) {
-                queue_dropped++;
+	if (pkt_queue.total >=3D queue_maxlen) {
+                pkt_queue.dropped++;
 		status =3D -ENOSPC;
 		if (net_ratelimit())
 		          printk (KERN_WARNING "ip_queue: full at %d entries, "
-				  "dropping packets(s). Dropped: %d\n", queue_total,
-				  queue_dropped);
+				  "dropping packets(s). Dropped: %d\n",=20
+				  pkt_queue.total, pkt_queue.dropped);
 		goto err_out_free_nskb;
 	}
=20
  	/* netlink_unicast will either free the nskb or attach it to a socket */=
=20
 	status =3D netlink_unicast(ipqnl, nskb, peer_pid, MSG_DONTWAIT);
 	if (status < 0) {
-	        queue_user_dropped++;
+	        pkt_queue.user_dropped++;
 		goto err_out_unlock;
 	}
=20
-	__ipq_enqueue_entry(entry);
+	__ipq_enqueue_entry(&pkt_queue, entry);
=20
 	write_unlock_bh(&queue_lock);
 	return status;
@@ -406,7 +442,7 @@
 	if (vmsg->value > NF_MAX_VERDICT)
 		return -EINVAL;
=20
-	entry =3D ipq_find_dequeue_entry(id_cmp, vmsg->id);
+	entry =3D ipq_find_dequeue_entry(&pkt_queue, id_cmp, vmsg->id);
 	if (entry =3D=3D NULL)
 		return -ENOENT;
 	else {
@@ -416,7 +452,11 @@
 			if (ipq_mangle_ipv4(vmsg, entry) < 0)
 				verdict =3D NF_DROP;
 	=09
-		ipq_issue_verdict(entry, verdict);
+		/* instead of issuing the verdict herer from syscall
+		 * context, we enqueue the verdict to the verdict_queue,
+		 * which is later processed by softirq context */
+		ipq_enqueue_verdict(entry, verdict);
+
 		return 0;
 	}
 }
@@ -479,8 +519,9 @@
 {
 	struct ipq_queue_entry *entry;
 =09
-	while ((entry =3D ipq_find_dequeue_entry(dev_cmp, ifindex)) !=3D NULL)
-		ipq_issue_verdict(entry, NF_DROP);
+	while ((entry =3D ipq_find_dequeue_entry(&pkt_queue,
+						dev_cmp, ifindex)) !=3D NULL)
+		ipq_enqueue_verdict(entry, NF_DROP);
 }
=20
 #define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } whi=
le (0)
@@ -630,6 +671,29 @@
 	{ .ctl_name =3D 0 }
 };
=20
+/* This tasklet feeds queued verdicts through the network stack.  Since it=
 runs
+ * in tasklet softirq context, this makes the TCP local input path happy -=
HW */
+static void
+ipq_verdict_task(unsigned long arg)
+{
+	struct ipq_queue_entry *entry;
+	unsigned int num =3D 0;
+
+	/* we want to stall other processing for too long. */
+	for (num =3D 0; num < IPQ_VERDICT_BATCH; num++) {
+		entry =3D ipq_find_dequeue_entry(&verdict_queue, NULL, 0);
+		if (!entry) {
+			break;
+		}
+		ipq_issue_verdict(entry, entry->verdict);
+	}
+
+	if (verdict_queue.total) {
+		/* more work to be done, schedule us again */
+		tasklet_schedule(&ipq_verdict_tasklet);
+	}
+}
+
 #ifdef CONFIG_PROC_FS
 static int
 ipq_get_info(char *buffer, char **start, off_t offset, int length)
@@ -639,20 +703,24 @@
 	read_lock_bh(&queue_lock);
 =09
 	len =3D sprintf(buffer,
-	              "Peer PID          : %d\n"
-	              "Copy mode         : %hu\n"
-	              "Copy range        : %u\n"
-	              "Queue length      : %u\n"
-	              "Queue max. length : %u\n"
-		      "Queue dropped     : %u\n"
-		      "Netlink dropped   : %u\n",
+	              "Peer PID              : %d\n"
+	              "Copy mode             : %hu\n"
+	              "Copy range            : %u\n"
+	              "Queue length          : %u\n"
+	              "Queue max. length     : %u\n"
+		      "Queue dropped         : %u\n"
+		      "Netlink dropped       : %u\n"
+		      "Verdict queue len     : %u\n"
+		      "Verdict queue dropped : %u\n",
 	              peer_pid,
 	              copy_mode,
 	              copy_range,
-	              queue_total,
+	              pkt_queue.total,
 	              queue_maxlen,
-		      queue_dropped,
-		      queue_user_dropped);
+		      pkt_queue.dropped,
+		      pkt_queue.user_dropped,
+		      verdict_queue.total,
+		      verdict_queue.dropped);
=20
 	read_unlock_bh(&queue_lock);
 =09
@@ -675,6 +743,16 @@
 	if (!init)
 		goto cleanup;
=20
+	INIT_LIST_HEAD(&pkt_queue.list);
+	pkt_queue.total =3D 0;
+	pkt_queue.dropped =3D 0;
+	pkt_queue.user_dropped =3D 0;
+
+	INIT_LIST_HEAD(&verdict_queue.list);
+	verdict_queue.total =3D 0;
+	verdict_queue.dropped =3D 0;
+	verdict_queue.user_dropped =3D 0;
+
 	netlink_register_notifier(&ipq_nl_notifier);
 	ipqnl =3D netlink_kernel_create(NETLINK_FIREWALL, ipq_rcv_sk);
 	if (ipqnl =3D=3D NULL) {
@@ -704,6 +782,14 @@
 	nf_unregister_queue_handler(PF_INET);
 	synchronize_net();
 	ipq_flush(NF_DROP);
+
+	while (verdict_queue.total !=3D 0) {
+		printk(KERN_INFO "ip_queue: verdict queue not empty while "
+			"module unload, scheduling\n");
+		tasklet_schedule(&ipq_verdict_tasklet);
+		schedule();
+	}
+	tasklet_disable(&ipq_verdict_tasklet);
 =09
 cleanup_sysctl:
 	unregister_sysctl_table(ipq_sysctl_header);

--moLig8uJibGkz5Yz--

--r3Mh/mGWsojp83Sz
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFCldwUXaXGVTD0i/8RAiacAJ9VwFtQlrTRw5Q+4VOhi3gIBXK2HgCglnst
cKqDqvL40obw2X/wjkCjdEs=
=tE3A
-----END PGP SIGNATURE-----

--r3Mh/mGWsojp83Sz--
