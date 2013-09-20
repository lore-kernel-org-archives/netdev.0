From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 1/2] remove all uses of printf's %n
Date: Fri, 20 Sep 2013 13:09:43 +0900
Message-ID: <201309201309.GFB52620.OQOtSFLMJVHOFF@I-love.SAKURA.ne.jp>
References: <CAGXu5jL+NeBw2_vXymM81UdtS6UO7KZA2S4rf3gwM_7nSJ2h6g@mail.gmail.com>
	<20130917205742.16147.qmail@science.horizon.com>
	<201309191756.BCF65661.MQFOLSJOFHFtOV@I-love.SAKURA.ne.jp>
	<CAGXu5jK_D1BJOQr=1A-UFrpM5Ad+Qu894HT_XjkZh4EmsbCkTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: keescook@chromium.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	linux@horizon.com, akpm@linux-foundation.org,
	dan.carpenter@oracle.com, geert@linux-m68k.org, JBeulich@suse.com,
	joe@perches.com, kosaki.motohiro@gmail.com
To: jslaby@suse.cz, viro@zeniv.linux.org.uk, xemul@openvz.org,
	remi.denis-courmont@nokia.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jK_D1BJOQr=1A-UFrpM5Ad+Qu894HT_XjkZh4EmsbCkTQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

We are discussing about removal of %n support from vsnprintf() at
https://lkml.org/lkml/2013/9/16/52 , and you are using %n in seq_printf().

I posted https://lkml.org/lkml/diff/2013/9/19/53/1 which introduces
seq_setwidth() / seq_pad() which can avoid use of %n in seq_printf().
Assuming that this patch is merged, would you confirm that I didn't break
your code with below patch?

Regards.
----------------------------------------
>From f8b60ebe3971901b93dedb8eee0f85b60d0fdc5f Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 20 Sep 2013 12:01:07 +0900
Subject: [PATCH] Remove "%n" usage from seq_file users.

All seq_printf() users are using "%n" for calculating padding size, convert
them to use seq_setwidth() / seq_pad() pair.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 fs/proc/consoles.c   |   10 ++++------
 fs/proc/nommu.c      |   12 +++++-------
 fs/proc/task_mmu.c   |   20 ++++++--------------
 fs/proc/task_nommu.c |   19 ++++++-------------
 net/ipv4/fib_trie.c  |   13 +++++++------
 net/ipv4/ping.c      |   15 +++++++--------
 net/ipv4/tcp_ipv4.c  |   33 +++++++++++++++------------------
 net/ipv4/udp.c       |   15 +++++++--------
 net/phonet/socket.c  |   24 +++++++++++-------------
 net/sctp/objcnt.c    |    9 +++++----
 10 files changed, 73 insertions(+), 97 deletions(-)

diff --git a/fs/proc/consoles.c b/fs/proc/consoles.c
index b701eaa..51942d5 100644
--- a/fs/proc/consoles.c
+++ b/fs/proc/consoles.c
@@ -29,7 +29,6 @@ static int show_console_dev(struct seq_file *m, void *v)
 	char flags[ARRAY_SIZE(con_flags) + 1];
 	struct console *con = v;
 	unsigned int a;
-	int len;
 	dev_t dev = 0;
 
 	if (con->device) {
@@ -47,11 +46,10 @@ static int show_console_dev(struct seq_file *m, void *v)
 			con_flags[a].name : ' ';
 	flags[a] = 0;
 
-	seq_printf(m, "%s%d%n", con->name, con->index, &len);
-	len = 21 - len;
-	if (len < 1)
-		len = 1;
-	seq_printf(m, "%*c%c%c%c (%s)", len, ' ', con->read ? 'R' : '-',
+	seq_setwidth(m, 21 - 1);
+	seq_printf(m, "%s%d", con->name, con->index);
+	seq_pad(m, ' ');
+	seq_printf(m, "%c%c%c (%s)", con->read ? 'R' : '-',
 			con->write ? 'W' : '-', con->unblank ? 'U' : '-',
 			flags);
 	if (dev)
diff --git a/fs/proc/nommu.c b/fs/proc/nommu.c
index ccfd99b..5f9bc8a 100644
--- a/fs/proc/nommu.c
+++ b/fs/proc/nommu.c
@@ -39,7 +39,7 @@ static int nommu_region_show(struct seq_file *m, struct vm_region *region)
 	unsigned long ino = 0;
 	struct file *file;
 	dev_t dev = 0;
-	int flags, len;
+	int flags;
 
 	flags = region->vm_flags;
 	file = region->vm_file;
@@ -50,8 +50,9 @@ static int nommu_region_show(struct seq_file *m, struct vm_region *region)
 		ino = inode->i_ino;
 	}
 
+	seq_setwidth(m, 25 + sizeof(void *) * 6 - 1);
 	seq_printf(m,
-		   "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n",
+		   "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
 		   region->vm_start,
 		   region->vm_end,
 		   flags & VM_READ ? 'r' : '-',
@@ -59,13 +60,10 @@ static int nommu_region_show(struct seq_file *m, struct vm_region *region)
 		   flags & VM_EXEC ? 'x' : '-',
 		   flags & VM_MAYSHARE ? flags & VM_SHARED ? 'S' : 's' : 'p',
 		   ((loff_t)region->vm_pgoff) << PAGE_SHIFT,
-		   MAJOR(dev), MINOR(dev), ino, &len);
+		   MAJOR(dev), MINOR(dev), ino);
 
 	if (file) {
-		len = 25 + sizeof(void *) * 6 - len;
-		if (len < 1)
-			len = 1;
-		seq_printf(m, "%*c", len, ' ');
+		seq_pad(m, ' ');
 		seq_path(m, &file->f_path, "");
 	}
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7366e9d..cc24165 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -83,14 +83,6 @@ unsigned long task_statm(struct mm_struct *mm,
 	return mm->total_vm;
 }
 
-static void pad_len_spaces(struct seq_file *m, int len)
-{
-	len = 25 + sizeof(void*) * 6 - len;
-	if (len < 1)
-		len = 1;
-	seq_printf(m, "%*c", len, ' ');
-}
-
 #ifdef CONFIG_NUMA
 /*
  * These functions are for numa_maps but called in generic **maps seq_file
@@ -268,7 +260,6 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 	unsigned long long pgoff = 0;
 	unsigned long start, end;
 	dev_t dev = 0;
-	int len;
 	const char *name = NULL;
 
 	if (file) {
@@ -286,7 +277,8 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 	if (stack_guard_page_end(vma, end))
 		end -= PAGE_SIZE;
 
-	seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n",
+	seq_setwidth(m, 25 + sizeof(void *) * 6 - 1);
+	seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
 			start,
 			end,
 			flags & VM_READ ? 'r' : '-',
@@ -294,14 +286,14 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 			flags & VM_EXEC ? 'x' : '-',
 			flags & VM_MAYSHARE ? 's' : 'p',
 			pgoff,
-			MAJOR(dev), MINOR(dev), ino, &len);
+			MAJOR(dev), MINOR(dev), ino);
 
 	/*
 	 * Print the dentry name for named mappings, and a
 	 * special [heap] marker for the heap:
 	 */
 	if (file) {
-		pad_len_spaces(m, len);
+		seq_pad(m, ' ');
 		seq_path(m, &file->f_path, "\n");
 		goto done;
 	}
@@ -333,7 +325,7 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 				name = "[stack]";
 			} else {
 				/* Thread stack in /proc/PID/maps */
-				pad_len_spaces(m, len);
+				seq_pad(m, ' ');
 				seq_printf(m, "[stack:%d]", tid);
 			}
 		}
@@ -341,7 +333,7 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 
 done:
 	if (name) {
-		pad_len_spaces(m, len);
+		seq_pad(m, ' ');
 		seq_puts(m, name);
 	}
 	seq_putc(m, '\n');
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 56123a6..678455d 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -123,14 +123,6 @@ unsigned long task_statm(struct mm_struct *mm,
 	return size;
 }
 
-static void pad_len_spaces(struct seq_file *m, int len)
-{
-	len = 25 + sizeof(void*) * 6 - len;
-	if (len < 1)
-		len = 1;
-	seq_printf(m, "%*c", len, ' ');
-}
-
 /*
  * display a single VMA to a sequenced file
  */
@@ -142,7 +134,7 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
 	unsigned long ino = 0;
 	struct file *file;
 	dev_t dev = 0;
-	int flags, len;
+	int flags;
 	unsigned long long pgoff = 0;
 
 	flags = vma->vm_flags;
@@ -155,8 +147,9 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
 		pgoff = (loff_t)vma->vm_pgoff << PAGE_SHIFT;
 	}
 
+	seq_setwidth(m, 25 + sizeof(void *) * 6 - 1);
 	seq_printf(m,
-		   "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n",
+		   "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
 		   vma->vm_start,
 		   vma->vm_end,
 		   flags & VM_READ ? 'r' : '-',
@@ -164,16 +157,16 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
 		   flags & VM_EXEC ? 'x' : '-',
 		   flags & VM_MAYSHARE ? flags & VM_SHARED ? 'S' : 's' : 'p',
 		   pgoff,
-		   MAJOR(dev), MINOR(dev), ino, &len);
+		   MAJOR(dev), MINOR(dev), ino);
 
 	if (file) {
-		pad_len_spaces(m, len);
+		seq_pad(m, ' ');
 		seq_path(m, &file->f_path, "");
 	} else if (mm) {
 		pid_t tid = vm_is_stack(priv->task, vma, is_pid);
 
 		if (tid != 0) {
-			pad_len_spaces(m, len);
+			seq_pad(m, ' ');
 			/*
 			 * Thread stack in /proc/PID/task/TID/maps or
 			 * the main process stack.
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3df6d3e..b1af50e 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2530,16 +2530,17 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
 			const struct fib_info *fi = fa->fa_info;
 			unsigned int flags = fib_flag_trans(fa->fa_type, mask, fi);
-			int len;
 
 			if (fa->fa_type == RTN_BROADCAST
 			    || fa->fa_type == RTN_MULTICAST)
 				continue;
 
+			seq_setwidth(seq, 127);
+
 			if (fi)
 				seq_printf(seq,
 					 "%s\t%08X\t%08X\t%04X\t%d\t%u\t"
-					 "%d\t%08X\t%d\t%u\t%u%n",
+					 "%d\t%08X\t%d\t%u\t%u",
 					 fi->fib_dev ? fi->fib_dev->name : "*",
 					 prefix,
 					 fi->fib_nh->nh_gw, flags, 0, 0,
@@ -2548,15 +2549,15 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 					 (fi->fib_advmss ?
 					  fi->fib_advmss + 40 : 0),
 					 fi->fib_window,
-					 fi->fib_rtt >> 3, &len);
+					 fi->fib_rtt >> 3);
 			else
 				seq_printf(seq,
 					 "*\t%08X\t%08X\t%04X\t%d\t%u\t"
-					 "%d\t%08X\t%d\t%u\t%u%n",
+					 "%d\t%08X\t%d\t%u\t%u",
 					 prefix, 0, flags, 0, 0, 0,
-					 mask, 0, 0, 0, &len);
+					 mask, 0, 0, 0);
 
-			seq_printf(seq, "%*s\n", 127 - len, "");
+			seq_pad(seq, '\n');
 		}
 	}
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index d7d9882..94cc685 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -1073,7 +1073,7 @@ void ping_seq_stop(struct seq_file *seq, void *v)
 EXPORT_SYMBOL_GPL(ping_seq_stop);
 
 static void ping_v4_format_sock(struct sock *sp, struct seq_file *f,
-		int bucket, int *len)
+		int bucket)
 {
 	struct inet_sock *inet = inet_sk(sp);
 	__be32 dest = inet->inet_daddr;
@@ -1082,7 +1082,7 @@ static void ping_v4_format_sock(struct sock *sp, struct seq_file *f,
 	__u16 srcp = ntohs(inet->inet_sport);
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
@@ -1090,23 +1090,22 @@ static void ping_v4_format_sock(struct sock *sp, struct seq_file *f,
 		from_kuid_munged(seq_user_ns(f), sock_i_uid(sp)),
 		0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp,
-		atomic_read(&sp->sk_drops), len);
+		atomic_read(&sp->sk_drops));
 }
 
 static int ping_v4_seq_show(struct seq_file *seq, void *v)
 {
+	seq_setwidth(seq, 127);
 	if (v == SEQ_START_TOKEN)
-		seq_printf(seq, "%-127s\n",
-			   "  sl  local_address rem_address   st tx_queue "
+		seq_puts(seq, "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
 			   "inode ref pointer drops");
 	else {
 		struct ping_iter_state *state = seq->private;
-		int len;
 
-		ping_v4_format_sock(v, seq, state->bucket, &len);
-		seq_printf(seq, "%*s\n", 127 - len, "");
+		ping_v4_format_sock(v, seq, state->bucket);
 	}
+	seq_pad(seq, '\n');
 	return 0;
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b14266b..2948b76 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2598,13 +2598,13 @@ void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 EXPORT_SYMBOL(tcp_proc_unregister);
 
 static void get_openreq4(const struct sock *sk, const struct request_sock *req,
-			 struct seq_file *f, int i, kuid_t uid, int *len)
+			 struct seq_file *f, int i, kuid_t uid)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	long delta = req->expires - jiffies;
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK",
 		i,
 		ireq->loc_addr,
 		ntohs(inet_sk(sk)->inet_sport),
@@ -2619,11 +2619,10 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
 		0,  /* non standard timer */
 		0, /* open_requests have no inode */
 		atomic_read(&sk->sk_refcnt),
-		req,
-		len);
+		req);
 }
 
-static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
+static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i)
 {
 	int timer_active;
 	unsigned long timer_expires;
@@ -2662,7 +2661,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5u %8d %lu %d %pK %lu %lu %u %u %d%n",
+			"%08X %5u %8d %lu %d %pK %lu %lu %u %u %d",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
@@ -2679,12 +2678,11 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		tp->snd_cwnd,
 		sk->sk_state == TCP_LISTEN ?
 		    (fastopenq ? fastopenq->max_qlen : 0) :
-		    (tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh),
-		len);
+		    (tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh));
 }
 
 static void get_timewait4_sock(const struct inet_timewait_sock *tw,
-			       struct seq_file *f, int i, int *len)
+			       struct seq_file *f, int i)
 {
 	__be32 dest, src;
 	__u16 destp, srcp;
@@ -2696,10 +2694,10 @@ static void get_timewait4_sock(const struct inet_timewait_sock *tw,
 	srcp  = ntohs(tw->tw_sport);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK",
 		i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
 		3, jiffies_delta_to_clock_t(delta), 0, 0, 0, 0,
-		atomic_read(&tw->tw_refcnt), tw, len);
+		atomic_read(&tw->tw_refcnt), tw);
 }
 
 #define TMPSZ 150
@@ -2707,11 +2705,10 @@ static void get_timewait4_sock(const struct inet_timewait_sock *tw,
 static int tcp4_seq_show(struct seq_file *seq, void *v)
 {
 	struct tcp_iter_state *st;
-	int len;
 
+	seq_setwidth(seq, TMPSZ - 1);
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "%-*s\n", TMPSZ - 1,
-			   "  sl  local_address rem_address   st tx_queue "
+		seq_puts(seq, "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
 			   "inode");
 		goto out;
@@ -2721,17 +2718,17 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 	switch (st->state) {
 	case TCP_SEQ_STATE_LISTENING:
 	case TCP_SEQ_STATE_ESTABLISHED:
-		get_tcp4_sock(v, seq, st->num, &len);
+		get_tcp4_sock(v, seq, st->num);
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
-		get_openreq4(st->syn_wait_sk, v, seq, st->num, st->uid, &len);
+		get_openreq4(st->syn_wait_sk, v, seq, st->num, st->uid);
 		break;
 	case TCP_SEQ_STATE_TIME_WAIT:
-		get_timewait4_sock(v, seq, st->num, &len);
+		get_timewait4_sock(v, seq, st->num);
 		break;
 	}
-	seq_printf(seq, "%*s\n", TMPSZ - 1 - len, "");
 out:
+	seq_pad(seq, '\n');
 	return 0;
 }
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 74d2c95..31c132c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2150,7 +2150,7 @@ EXPORT_SYMBOL(udp_proc_unregister);
 
 /* ------------------------------------------------------------------------ */
 static void udp4_format_sock(struct sock *sp, struct seq_file *f,
-		int bucket, int *len)
+		int bucket)
 {
 	struct inet_sock *inet = inet_sk(sp);
 	__be32 dest = inet->inet_daddr;
@@ -2159,7 +2159,7 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 	__u16 srcp	  = ntohs(inet->inet_sport);
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
@@ -2167,23 +2167,22 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 		from_kuid_munged(seq_user_ns(f), sock_i_uid(sp)),
 		0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp,
-		atomic_read(&sp->sk_drops), len);
+		atomic_read(&sp->sk_drops));
 }
 
 int udp4_seq_show(struct seq_file *seq, void *v)
 {
+	seq_setwidth(seq, 127);
 	if (v == SEQ_START_TOKEN)
-		seq_printf(seq, "%-127s\n",
-			   "  sl  local_address rem_address   st tx_queue "
+		seq_puts(seq, "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
 			   "inode ref pointer drops");
 	else {
 		struct udp_iter_state *state = seq->private;
-		int len;
 
-		udp4_format_sock(v, seq, state->bucket, &len);
-		seq_printf(seq, "%*s\n", 127 - len, "");
+		udp4_format_sock(v, seq, state->bucket);
 	}
+	seq_pad(seq, '\n');
 	return 0;
 }
 
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 77e38f7..008214a 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -595,26 +595,25 @@ static void pn_sock_seq_stop(struct seq_file *seq, void *v)
 
 static int pn_sock_seq_show(struct seq_file *seq, void *v)
 {
-	int len;
-
+	seq_setwidth(seq, 127);
 	if (v == SEQ_START_TOKEN)
-		seq_printf(seq, "%s%n", "pt  loc  rem rs st tx_queue rx_queue "
-			"  uid inode ref pointer drops", &len);
+		seq_puts(seq, "pt  loc  rem rs st tx_queue rx_queue "
+			"  uid inode ref pointer drops");
 	else {
 		struct sock *sk = v;
 		struct pn_sock *pn = pn_sk(sk);
 
 		seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu "
-			"%d %pK %d%n",
+			"%d %pK %d",
 			sk->sk_protocol, pn->sobject, pn->dobject,
 			pn->resource, sk->sk_state,
 			sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
 			from_kuid_munged(seq_user_ns(seq), sock_i_uid(sk)),
 			sock_i_ino(sk),
 			atomic_read(&sk->sk_refcnt), sk,
-			atomic_read(&sk->sk_drops), &len);
+			atomic_read(&sk->sk_drops));
 	}
-	seq_printf(seq, "%*s\n", 127 - len, "");
+	seq_pad(seq, '\n');
 	return 0;
 }
 
@@ -785,20 +784,19 @@ static void pn_res_seq_stop(struct seq_file *seq, void *v)
 
 static int pn_res_seq_show(struct seq_file *seq, void *v)
 {
-	int len;
-
+	seq_setwidth(seq, 63);
 	if (v == SEQ_START_TOKEN)
-		seq_printf(seq, "%s%n", "rs   uid inode", &len);
+		seq_puts(seq, "rs   uid inode");
 	else {
 		struct sock **psk = v;
 		struct sock *sk = *psk;
 
-		seq_printf(seq, "%02X %5u %lu%n",
+		seq_printf(seq, "%02X %5u %lu",
 			   (int) (psk - pnres.sk),
 			   from_kuid_munged(seq_user_ns(seq), sock_i_uid(sk)),
-			   sock_i_ino(sk), &len);
+			   sock_i_ino(sk));
 	}
-	seq_printf(seq, "%*s\n", 63 - len, "");
+	seq_pad(seq, '\n');
 	return 0;
 }
 
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index 5ea573b..647396b 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -79,12 +79,13 @@ static sctp_dbg_objcnt_entry_t sctp_dbg_objcnt[] = {
  */
 static int sctp_objcnt_seq_show(struct seq_file *seq, void *v)
 {
-	int i, len;
+	int i;
 
 	i = (int)*(loff_t *)v;
-	seq_printf(seq, "%s: %d%n", sctp_dbg_objcnt[i].label,
-				atomic_read(sctp_dbg_objcnt[i].counter), &len);
-	seq_printf(seq, "%*s\n", 127 - len, "");
+	seq_setwidth(seq, 127);
+	seq_printf(seq, "%s: %d", sctp_dbg_objcnt[i].label,
+				atomic_read(sctp_dbg_objcnt[i].counter));
+	seq_pad(seq, '\n');
 	return 0;
 }
 
-- 
1.7.1
