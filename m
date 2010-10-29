From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 23:05:48 +0200
Message-ID: <1288386348.2680.25.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	 <1288380431.2680.3.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1010291306390.8517@davide-lnx1>
	 <alpine.DEB.2.00.1010291339180.8517@davide-lnx1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1010291339180.8517@davide-lnx1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following patch solves the problem for me, and its only a start, I am
pretty sure we can optimize more than that.

What I did is to move "struct poll_wqueues table;" out of do_select()
in its caller. This structure is highly modified by an other cpu in
Alban workload, and this slow down do_select() because many accesses to
some of its local variables (normally, private ones !) hit a false
sharing.

Before :

# time /root/uclient connected
The performance problem will be triggered
select: begin
select: end: 3 seconds

real	0m3.101s
user	0m0.000s
sys	0m6.104s

After :

# time /root/uclient connected
The performance problem will be triggered
select: begin
select: end: 1 seconds

real	0m1.041s
user	0m0.004s
sys	0m2.040s


Impressive no ?

Reported-by: Alban Crequy <alban.crequy@collabora.co.uk>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 fs/compat.c          |    3 ++-
 fs/select.c          |   19 ++++++++++---------
 include/linux/poll.h |    3 ++-
 3 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index ff66c0d..3c3c3d3 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -1704,6 +1704,7 @@ int compat_core_sys_select(int n, compat_ulong_t __user *inp,
 	int size, max_fds, ret = -EINVAL;
 	struct fdtable *fdt;
 	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
+	struct poll_wqueues table;
 
 	if (n < 0)
 		goto out_nofds;
@@ -1744,7 +1745,7 @@ int compat_core_sys_select(int n, compat_ulong_t __user *inp,
 	zero_fd_set(n, fds.res_out);
 	zero_fd_set(n, fds.res_ex);
 
-	ret = do_select(n, &fds, end_time);
+	ret = do_select(n, &fds, end_time, &table);
 
 	if (ret < 0)
 		goto out;
diff --git a/fs/select.c b/fs/select.c
index b7b10aa..ed054f5 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -393,10 +393,10 @@ static inline void wait_key_set(poll_table *wait, unsigned long in,
 	}
 }
 
-int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
+int do_select(int n, fd_set_bits *fds, struct timespec *end_time,
+	      struct poll_wqueues *table)
 {
 	ktime_t expire, *to = NULL;
-	struct poll_wqueues table;
 	poll_table *wait;
 	int retval, i, timed_out = 0;
 	unsigned long slack = 0;
@@ -409,8 +409,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 		return retval;
 	n = retval;
 
-	poll_initwait(&table);
-	wait = &table.pt;
+	poll_initwait(table);
+	wait = &table->pt;
 	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
 		wait = NULL;
 		timed_out = 1;
@@ -482,8 +482,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 		wait = NULL;
 		if (retval || timed_out || signal_pending(current))
 			break;
-		if (table.error) {
-			retval = table.error;
+		if (table->error) {
+			retval = table->error;
 			break;
 		}
 
@@ -497,12 +497,12 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 			to = &expire;
 		}
 
-		if (!poll_schedule_timeout(&table, TASK_INTERRUPTIBLE,
+		if (!poll_schedule_timeout(table, TASK_INTERRUPTIBLE,
 					   to, slack))
 			timed_out = 1;
 	}
 
-	poll_freewait(&table);
+	poll_freewait(table);
 
 	return retval;
 }
@@ -528,6 +528,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 	struct fdtable *fdt;
 	/* Allocate small arguments on the stack to save memory and be faster */
 	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
+	struct poll_wqueues table;
 
 	ret = -EINVAL;
 	if (n < 0)
@@ -570,7 +571,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 	zero_fd_set(n, fds.res_out);
 	zero_fd_set(n, fds.res_ex);
 
-	ret = do_select(n, &fds, end_time);
+	ret = do_select(n, &fds, end_time, &table);
 
 	if (ret < 0)
 		goto out;
diff --git a/include/linux/poll.h b/include/linux/poll.h
index 56e76af..54ba625 100644
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -130,7 +130,8 @@ void zero_fd_set(unsigned long nr, unsigned long *fdset)
 
 #define MAX_INT64_SECONDS (((s64)(~((u64)0)>>1)/HZ)-1)
 
-extern int do_select(int n, fd_set_bits *fds, struct timespec *end_time);
+extern int do_select(int n, fd_set_bits *fds, struct timespec *end_time,
+		     struct poll_wqueues *table);
 extern int do_sys_poll(struct pollfd __user * ufds, unsigned int nfds,
 		       struct timespec *end_time);
 extern int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
