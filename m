From: Piotr Wilczek <p.wilczek@samsung.com>
Subject: [PATCH RFC] Send process status in SCM_PROCINFO
Date: Thu, 29 May 2014 13:13:36 +0200
Message-ID: <1401362016-7259-1-git-send-email-p.wilczek@samsung.com>
Cc: netdev@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>,
	Juho Son <juho80.son@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Piotr Wilczek <p.wilczek@samsung.com>,
	Jan Kaluza <jkaluza@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:42409 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756426AbaE2LOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 07:14:16 -0400
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N6C00IXU1VQ1Q40@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 29 May 2014 20:14:14 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces a new SCM type called SCM_PROCINFO to allow the direct
attaching of process status to SCM, which is significantly more
efficient and will reliably avoid the race with the round-trip over
procfs. This is optional and can be turned on by setting SO_PASSPROC.

To achieve that, new struct called unix_skb_parms_scm had to be created,
because otherwise unix_skb_parms would be too big.

scm_get_current_procinfo is inspired by ./fs/proc/base.c and array.c

This patch is reworked version of:
https://lkml.org/lkml/2014/1/13/40

Signed-off-by: Jan Kaluza <jkaluza@redhat.com>
Signed-off-by: Piotr Wilczek <p.wilczek@samsung.com>
---
 arch/alpha/include/uapi/asm/socket.h   |   2 +
 arch/avr32/include/uapi/asm/socket.h   |   2 +
 arch/cris/include/uapi/asm/socket.h    |   2 +
 arch/frv/include/uapi/asm/socket.h     |   2 +
 arch/ia64/include/uapi/asm/socket.h    |   2 +
 arch/m32r/include/uapi/asm/socket.h    |   2 +
 arch/mips/include/uapi/asm/socket.h    |   2 +
 arch/mn10300/include/uapi/asm/socket.h |   2 +
 arch/parisc/include/uapi/asm/socket.h  |   2 +
 arch/powerpc/include/uapi/asm/socket.h |   2 +
 arch/s390/include/uapi/asm/socket.h    |   2 +
 arch/sparc/include/uapi/asm/socket.h   |   2 +
 include/linux/net.h                    |   1 +
 include/linux/socket.h                 |   2 +
 include/net/af_unix.h                  |   9 +
 include/net/scm.h                      |  28 +++
 include/uapi/asm-generic/socket.h      |   2 +
 net/core/scm.c                         | 429 +++++++++++++++++++++++++++++++++
 net/core/sock.c                        |  11 +
 net/unix/af_unix.c                     |  70 ++++++
 20 files changed, 576 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 3de1394..29608f2 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 6e6cd15..a9bbc63 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index ed94e5e..df0c641 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -82,6 +82,8 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index ca2c6e6..3cd9cb1 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -80,5 +80,7 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index a1b49ba..656ba43 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -89,4 +89,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 6c9a24b..758ce55 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index a14baa2..cc7b8f5 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 6aa3ce1..b49368f2 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index fe35cea..b3facfa 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -79,4 +79,6 @@
 
 #define SO_BPF_EXTENSIONS	0x4029
 
+#define SO_PASSPROC		0x402a
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index a9c3e2e..b582047 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index e031332..ffd6fa5 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -86,4 +86,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 54d9608..875353f 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -76,6 +76,8 @@
 
 #define SO_BPF_EXTENSIONS	0x0032
 
+#define SO_PASSPROC		0x0033
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/include/linux/net.h b/include/linux/net.h
index 17d8339..38ad416 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -39,6 +39,7 @@ struct net;
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
 #define SOCK_EXTERNALLY_ALLOCATED 5
+#define SOCK_PASSPROC		6
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8e98297..a5ebf79 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -130,6 +130,8 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
 #define	SCM_RIGHTS	0x01		/* rw: access rights (array of int) */
 #define SCM_CREDENTIALS 0x02		/* rw: struct ucred		*/
 #define SCM_SECURITY	0x03		/* rw: security label		*/
+#define SCM_PROCINFO   0x05		/* rw: comm + cmdline (NULL terminated
+						array of char *) */
 
 struct ucred {
 	__u32	pid;
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index a175ba4..05c7678 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -27,6 +27,13 @@ struct unix_address {
 	struct sockaddr_un name[0];
 };
 
+struct unix_skb_parms_scm {
+	kuid_t loginuid;
+	unsigned int sessionid;
+	char *procinfo;
+	int procinfo_len;
+};
+
 struct unix_skb_parms {
 	struct pid		*pid;		/* Skb credentials	*/
 	kuid_t			uid;
@@ -36,10 +43,12 @@ struct unix_skb_parms {
 	u32			secid;		/* Security ID		*/
 #endif
 	u32			consumed;
+	struct unix_skb_parms_scm *scm;
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms *)&((skb)->cb))
 #define UNIXSID(skb)	(&UNIXCB((skb)).secid)
+#define UNIXSCM(skb)	(*(UNIXCB((skb)).scm))
 
 #define unix_state_lock(s)	spin_lock(&unix_sk(s)->lock)
 #define unix_state_unlock(s)	spin_unlock(&unix_sk(s)->lock)
diff --git a/include/net/scm.h b/include/net/scm.h
index 262532d..cc28cd4 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -24,6 +24,11 @@ struct scm_fp_list {
 	struct file		*fp[SCM_MAX_FD];
 };
 
+struct scm_procinfo {
+	char *procinfo;
+	int len;
+};
+
 struct scm_cookie {
 	struct pid		*pid;		/* Skb credentials */
 	struct scm_fp_list	*fp;		/* Passed files		*/
@@ -31,6 +36,7 @@ struct scm_cookie {
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Passed security ID 	*/
 #endif
+	struct scm_procinfo	procinfo;	/* Skb procinfo */
 };
 
 void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm);
@@ -38,6 +44,8 @@ void scm_detach_fds_compat(struct msghdr *msg, struct scm_cookie *scm);
 int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm);
 void __scm_destroy(struct scm_cookie *scm);
 struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl);
+extern int scm_get_current_procinfo(char **procinfo);
+extern void task_mem(struct seq_file *, struct mm_struct *);
 
 #ifdef CONFIG_SECURITY_NETWORK
 static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_cookie *scm)
@@ -49,6 +57,13 @@ static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_co
 { }
 #endif /* CONFIG_SECURITY_NETWORK */
 
+static inline void scm_set_procinfo(struct scm_cookie *scm,
+				    char *procinfo, int len)
+{
+	scm->procinfo.procinfo = procinfo;
+	scm->procinfo.len = len;
+}
+
 static __inline__ void scm_set_cred(struct scm_cookie *scm,
 				    struct pid *pid, kuid_t uid, kgid_t gid)
 {
@@ -62,6 +77,9 @@ static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
 {
 	put_pid(scm->pid);
 	scm->pid  = NULL;
+	kfree(scm->procinfo.procinfo);
+	scm->procinfo.procinfo = NULL;
+	scm->procinfo.len = 0;
 }
 
 static __inline__ void scm_destroy(struct scm_cookie *scm)
@@ -74,11 +92,18 @@ static __inline__ void scm_destroy(struct scm_cookie *scm)
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
 			       struct scm_cookie *scm, bool forcecreds)
 {
+	char *procinfo;
+	int len;
 	memset(scm, 0, sizeof(*scm));
 	scm->creds.uid = INVALID_UID;
 	scm->creds.gid = INVALID_GID;
 	if (forcecreds)
 		scm_set_cred(scm, task_tgid(current), current_uid(), current_gid());
+	if (test_bit(SOCK_PASSPROC, &sock->flags)) {
+		len = scm_get_current_procinfo(&procinfo);
+		if (len > 0)
+			scm_set_procinfo(scm, procinfo, len);
+	}
 	unix_get_peersec_dgram(sock, scm);
 	if (msg->msg_controllen <= 0)
 		return 0;
@@ -125,6 +150,9 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 		};
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(ucreds), &ucreds);
 	}
+	if (test_bit(SOCK_PASSPROC, &sock->flags))
+		put_cmsg(msg, SOL_SOCKET, SCM_PROCINFO, scm->procinfo.len,
+			 scm->procinfo.procinfo);
 
 	scm_destroy_cred(scm);
 
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index ea0796b..8ce4e94 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -82,4 +82,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_PASSPROC		49
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/scm.c b/net/core/scm.c
index b442e7e..ec6a741 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -28,6 +28,9 @@
 #include <linux/pid.h>
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
+#include <linux/ptrace.h>
+#include <linux/fdtable.h>
+#include <linux/cpuset.h>
 
 #include <asm/uaccess.h>
 
@@ -339,3 +342,429 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
 	return new_fpl;
 }
 EXPORT_SYMBOL(scm_fp_dup);
+
+static inline void task_name(struct seq_file *m, struct task_struct *p)
+{
+	int i;
+	char *buf, *end;
+	char *name;
+	char tcomm[sizeof(p->comm)];
+
+	get_task_comm(tcomm, p);
+
+	seq_puts(m, "Name:\t");
+	end = m->buf + m->size;
+	buf = m->buf + m->count;
+	name = tcomm;
+	i = sizeof(tcomm);
+	while (i && (buf < end)) {
+		unsigned char c = *name;
+
+		name++;
+		i--;
+		*buf = c;
+		if (!c)
+			break;
+		if (c == '\\') {
+			buf++;
+			if (buf < end)
+				*buf++ = c;
+			continue;
+		}
+		if (c == '\n') {
+			*buf++ = '\\';
+			if (buf < end)
+				*buf++ = 'n';
+			continue;
+		}
+		buf++;
+	}
+	m->count = buf - m->buf;
+	seq_putc(m, '\n');
+}
+
+/* The task state array is a strange "bitmap" of
+ * reasons to sleep. Thus "running" is zero, and
+ * you can test for combinations of others with
+ * simple bit tests.
+ */
+static const char * const task_state_array[] = {
+	"R (running)",		/*   0 */
+	"S (sleeping)",		/*   1 */
+	"D (disk sleep)",	/*   2 */
+	"T (stopped)",		/*   4 */
+	"t (tracing stop)",	/*   8 */
+	"Z (zombie)",		/*  16 */
+	"X (dead)",		/*  32 */
+	"x (dead)",		/*  64 */
+	"K (wakekill)",		/* 128 */
+	"W (waking)",		/* 256 */
+	"P (parked)",		/* 512 */
+};
+
+static inline const char *get_task_state(struct task_struct *tsk)
+{
+	unsigned int state = (tsk->state & TASK_REPORT) | tsk->exit_state;
+	const char * const *p = &task_state_array[0];
+
+	BUILD_BUG_ON(1 + ilog2(TASK_STATE_MAX) != ARRAY_SIZE(task_state_array));
+
+	while (state) {
+		p++;
+		state >>= 1;
+	}
+	return *p;
+}
+
+static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
+			      struct pid *pid, struct task_struct *p)
+{
+	struct user_namespace *user_ns = seq_user_ns(m);
+	struct group_info *group_info;
+	int g;
+	struct fdtable *fdt = NULL;
+	const struct cred *cred;
+	pid_t ppid, tpid;
+
+	rcu_read_lock();
+	ppid = pid_alive(p) ?
+		task_tgid_nr_ns(rcu_dereference(p->real_parent), ns) : 0;
+	tpid = 0;
+	if (pid_alive(p)) {
+		struct task_struct *tracer = ptrace_parent(p);
+		if (tracer)
+			tpid = task_pid_nr_ns(tracer, ns);
+	}
+
+	cred = get_task_cred(p);
+	if (cred == NULL || user_ns == NULL)
+		return;
+	seq_printf(m,
+		   "State:\t%s\n"
+		   "Tgid:\t%d\n"
+		   "Pid:\t%d\n"
+		   "PPid:\t%d\n"
+		   "TracerPid:\t%d\n"
+		   "Uid:\t%d\t%d\t%d\t%d\n"
+		   "Gid:\t%d\t%d\t%d\t%d\n",
+		   get_task_state(p),
+		   task_tgid_nr_ns(p, ns),
+		   pid_nr_ns(pid, ns),
+		   ppid, tpid,
+		   from_kuid_munged(user_ns, cred->uid),
+		   from_kuid_munged(user_ns, cred->euid),
+		   from_kuid_munged(user_ns, cred->suid),
+		   from_kuid_munged(user_ns, cred->fsuid),
+		   from_kgid_munged(user_ns, cred->gid),
+		   from_kgid_munged(user_ns, cred->egid),
+		   from_kgid_munged(user_ns, cred->sgid),
+		   from_kgid_munged(user_ns, cred->fsgid));
+
+	task_lock(p);
+	if (p->files)
+		fdt = files_fdtable(p->files);
+	seq_printf(m,
+		   "FDSize:\t%d\n"
+		   "Groups:\t",
+		   fdt ? fdt->max_fds : 0);
+	rcu_read_unlock();
+
+	group_info = cred->group_info;
+	task_unlock(p);
+
+	for (g = 0; g < group_info->ngroups; g++)
+		seq_printf(m, "%d ",
+			   from_kgid_munged(user_ns, GROUP_AT(group_info, g)));
+	put_cred(cred);
+
+	seq_putc(m, '\n');
+}
+
+static void collect_sigign_sigcatch(struct task_struct *p, sigset_t *ign,
+				    sigset_t *catch)
+{
+	struct k_sigaction *k;
+	int i;
+
+	k = p->sighand->action;
+	for (i = 1; i <= _NSIG; ++i, ++k) {
+		if (k->sa.sa_handler == SIG_IGN)
+			sigaddset(ign, i);
+		else if (k->sa.sa_handler != SIG_DFL)
+			sigaddset(catch, i);
+	}
+}
+
+static inline void task_sig(struct seq_file *m, struct task_struct *p)
+{
+	unsigned long flags;
+	sigset_t pending, shpending, blocked, ignored, caught;
+	int num_threads = 0;
+	unsigned long qsize = 0;
+	unsigned long qlim = 0;
+
+	sigemptyset(&pending);
+	sigemptyset(&shpending);
+	sigemptyset(&blocked);
+	sigemptyset(&ignored);
+	sigemptyset(&caught);
+
+	if (lock_task_sighand(p, &flags)) {
+		pending = p->pending.signal;
+		shpending = p->signal->shared_pending.signal;
+		blocked = p->blocked;
+		collect_sigign_sigcatch(p, &ignored, &caught);
+		num_threads = get_nr_threads(p);
+		rcu_read_lock();  /* FIXME: is this correct? */
+		qsize = atomic_read(&__task_cred(p)->user->sigpending);
+		rcu_read_unlock();
+		qlim = task_rlimit(p, RLIMIT_SIGPENDING);
+		unlock_task_sighand(p, &flags);
+	}
+
+	seq_printf(m, "Threads:\t%d\n", num_threads);
+	seq_printf(m, "SigQ:\t%lu/%lu\n", qsize, qlim);
+
+	/* render them all */
+	render_sigset_t(m, "SigPnd:\t", &pending);
+	render_sigset_t(m, "ShdPnd:\t", &shpending);
+	render_sigset_t(m, "SigBlk:\t", &blocked);
+	render_sigset_t(m, "SigIgn:\t", &ignored);
+	render_sigset_t(m, "SigCgt:\t", &caught);
+}
+
+static void render_cap_t(struct seq_file *m, const char *header,
+			 kernel_cap_t *a)
+{
+	unsigned __capi;
+
+	seq_puts(m, header);
+	CAP_FOR_EACH_U32(__capi) {
+		seq_printf(m, "%08x",
+			   a->cap[(_KERNEL_CAPABILITY_U32S-1) - __capi]);
+	}
+	seq_putc(m, '\n');
+}
+
+/* Remove non-existent capabilities */
+#define NORM_CAPS(v) (v.cap[CAP_TO_INDEX(CAP_LAST_CAP)] &= \
+				CAP_TO_MASK(CAP_LAST_CAP + 1) - 1)
+
+static inline void task_cap(struct seq_file *m, struct task_struct *p)
+{
+	const struct cred *cred;
+	kernel_cap_t cap_inheritable, cap_permitted, cap_effective, cap_bset;
+
+	rcu_read_lock();
+	cred = __task_cred(p);
+	cap_inheritable	= cred->cap_inheritable;
+	cap_permitted	= cred->cap_permitted;
+	cap_effective	= cred->cap_effective;
+	cap_bset	= cred->cap_bset;
+	rcu_read_unlock();
+
+	NORM_CAPS(cap_inheritable);
+	NORM_CAPS(cap_permitted);
+	NORM_CAPS(cap_effective);
+	NORM_CAPS(cap_bset);
+
+	render_cap_t(m, "CapInh:\t", &cap_inheritable);
+	render_cap_t(m, "CapPrm:\t", &cap_permitted);
+	render_cap_t(m, "CapEff:\t", &cap_effective);
+	render_cap_t(m, "CapBnd:\t", &cap_bset);
+}
+
+static inline void task_seccomp(struct seq_file *m, struct task_struct *p)
+{
+#ifdef CONFIG_SECCOMP
+	seq_printf(m, "Seccomp:\t%d\n", p->seccomp.mode);
+#endif
+}
+
+static inline void task_context_switch_counts(struct seq_file *m,
+					      struct task_struct *p)
+{
+	seq_printf(m,	"voluntary_ctxt_switches:\t%lu\n"
+			"nonvoluntary_ctxt_switches:\t%lu\n",
+			p->nvcsw,
+			p->nivcsw);
+}
+
+static void task_cpus_allowed(struct seq_file *m, struct task_struct *task)
+{
+	seq_puts(m, "Cpus_allowed:\t");
+	seq_cpumask(m, &task->cpus_allowed);
+	seq_putc(m, '\n');
+	seq_puts(m, "Cpus_allowed_list:\t");
+	seq_cpumask_list(m, &task->cpus_allowed);
+	seq_putc(m, '\n');
+}
+
+static int get_proc_cmdline(struct mm_struct *mm, char *buffer)
+{
+	int res, i;
+	unsigned int len;
+
+	len = mm->arg_end - mm->arg_start;
+
+	if (len > PAGE_SIZE)
+		len = PAGE_SIZE;
+
+	res = access_process_vm(current, mm->arg_start, buffer, len, 0);
+
+	/* If the nul at the end of args has been overwritten, then
+	 * assume application is using setproctitle(3).
+	 */
+	if (res > 0 && buffer[res-1] != '\0' && len < PAGE_SIZE) {
+		len = strnlen(buffer, res);
+		if (len < res) {
+			res = len;
+		} else {
+			len = mm->env_end - mm->env_start;
+			if (len > PAGE_SIZE - res)
+				len = PAGE_SIZE - res;
+			res += access_process_vm(current, mm->env_start,
+						 buffer+res, len, 0);
+			res = strnlen(buffer, res);
+		}
+	}
+
+	for (i = 0; i < res - 1; i++)
+		if (buffer[i] == '\0')
+			buffer[i] = ' ';
+
+	return res;
+}
+
+static char *get_proc_exe(struct mm_struct *mm)
+{
+	struct file *exe_file;
+	struct path exe_path;
+	char tmp[80], *exepathname;
+
+	exe_file = get_mm_exe_file(mm);
+	if (!exe_file)
+		return NULL;
+
+	exe_path = exe_file->f_path;
+	path_get(&exe_file->f_path);
+	fput(exe_file);
+
+	exepathname = d_path(&exe_path, tmp, sizeof(tmp));
+	path_put(&exe_path);
+
+	return exepathname;
+}
+
+static void get_task_status(struct mm_struct *mm, struct task_struct *task,
+			    char *buf, int size)
+{
+	struct seq_file m;
+	struct pid_namespace *ns = task_active_pid_ns(task);
+	struct pid *pid = get_pid(task_tgid(task));
+
+	memset(&m, 0, sizeof(m));
+	m.buf = buf;
+	m.size = size;
+
+	task_name(&m, task);
+	task_state(&m, ns, pid, task);
+
+	if (mm)
+		task_mem(&m, mm);
+
+	task_sig(&m, task);
+	task_cap(&m, task);
+	task_seccomp(&m, task);
+	task_cpus_allowed(&m, task);
+	cpuset_task_status_allowed(&m, task);
+	task_context_switch_counts(&m, task);
+}
+
+int scm_get_current_procinfo(char **procinfo)
+{
+	int res = 0;
+	unsigned int len;
+	char *pos;
+	char *buf_cmdline = NULL;
+	char *buf_status = NULL;
+	struct mm_struct *mm;
+	int comm_len = strlen(current->comm);
+	static char *str_comm = "COMM=";
+	static char *str_cmdline = "CMDLINE=";
+	static char *str_exe = "EXE=";
+	static char *str_status = "STATUS=";
+	char *exepathname;
+
+	*procinfo = NULL;
+
+	buf_cmdline = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf_cmdline)
+		return -ENOMEM;
+
+	buf_status = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf_status) {
+		res = -ENOMEM;
+		goto out;
+	}
+	memset(buf_status, 0, PAGE_SIZE);
+
+	mm = get_task_mm(current);
+	if (!mm)
+		goto out;
+	if (!mm->arg_end)
+		goto out_mm;    /* Shh! No looking before we're done */
+
+	res = get_proc_cmdline(mm, buf_cmdline);
+
+	exepathname = get_proc_exe(mm);
+	if (exepathname == NULL)
+		goto out_mm;
+
+	get_task_status(mm, current, buf_status, PAGE_SIZE);
+
+	/* strlen(comm) + \0 + len of cmdline */
+	len = strlen(str_comm) + comm_len + 1;
+	if (res)
+		len += strlen(str_cmdline) + res + 1;
+	if (!IS_ERR(exepathname))
+		len += strlen(str_exe) + strlen(exepathname) + 1;
+	if (strlen(buf_status) > 0)
+		len += strlen(str_status) + strlen(buf_status);
+
+	*procinfo = kmalloc(len, GFP_KERNEL);
+	if (!*procinfo) {
+		res = -ENOMEM;
+		goto out_mm;
+	}
+
+	pos = *procinfo;
+	pos = strcpy(*procinfo, str_comm) + strlen(str_comm);
+	pos = memcpy(pos, current->comm, comm_len + 1) + comm_len + 1;
+
+	if (res > 0) {
+		pos = strcpy(pos, str_cmdline) + strlen(str_cmdline);
+		pos = memcpy(pos, buf_cmdline, res) + res;
+	}
+
+	if (!IS_ERR(exepathname)) {
+		pos = strcpy(pos, str_exe) + strlen(str_exe);
+		pos = strcpy(pos, exepathname) + strlen(exepathname);
+		pos = strcpy(pos + 1, "") /*+ 1*/;
+	}
+
+	if (strlen(buf_status) > 0) {
+		pos = strcpy(pos, str_status) + strlen(str_status);
+		pos = strcpy(pos, buf_status) + strlen(buf_status);
+	}
+
+	res = len;
+
+out_mm:
+	mmput(mm);
+out:
+	kfree(buf_cmdline);
+	kfree(buf_status);
+	return res;
+}
+EXPORT_SYMBOL(scm_get_current_procinfo);
diff --git a/net/core/sock.c b/net/core/sock.c
index 026e01f..1099e19 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -828,6 +828,13 @@ set_rcvbuf:
 			clear_bit(SOCK_PASSCRED, &sock->flags);
 		break;
 
+	case SO_PASSPROC:
+		if (valbool)
+			set_bit(SOCK_PASSPROC, &sock->flags);
+		else
+			clear_bit(SOCK_PASSPROC, &sock->flags);
+		break;
+
 	case SO_TIMESTAMP:
 	case SO_TIMESTAMPNS:
 		if (valbool)  {
@@ -1142,6 +1149,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = !!test_bit(SOCK_PASSCRED, &sock->flags);
 		break;
 
+	case SO_PASSPROC:
+		v.val = !!test_bit(SOCK_PASSPROC, &sock->flags);
+		break;
+
 	case SO_PEERCRED:
 	{
 		struct ucred peercred;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7b9114e..d524ab0 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1360,9 +1360,15 @@ static void unix_destruct_scm(struct sk_buff *skb)
 	struct scm_cookie scm;
 	memset(&scm, 0, sizeof(scm));
 	scm.pid  = UNIXCB(skb).pid;
+	if (UNIXCB(skb).scm) {
+		scm.procinfo.procinfo = UNIXSCM(skb).procinfo;
+		scm.procinfo.len = UNIXSCM(skb).procinfo_len;
+	}
 	if (UNIXCB(skb).fp)
 		unix_detach_fds(&scm, skb);
 
+	kfree(UNIXCB(skb).scm);
+
 	/* Alas, it calls VFS */
 	/* So fscking what? fput() had been SMP-safe since the last Summer */
 	scm_destroy(&scm);
@@ -1409,6 +1415,13 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 {
 	int err = 0;
 
+	if (!UNIXCB(skb).scm) {
+		UNIXCB(skb).scm = kmalloc(sizeof(struct unix_skb_parms_scm),
+					  GFP_KERNEL);
+		if (!UNIXCB(skb).scm)
+			return -ENOMEM;
+	}
+
 	UNIXCB(skb).pid  = get_pid(scm->pid);
 	UNIXCB(skb).uid = scm->creds.uid;
 	UNIXCB(skb).gid = scm->creds.gid;
@@ -1416,6 +1429,15 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
 
+	UNIXSCM(skb).procinfo = NULL;
+	if (scm->procinfo.procinfo) {
+		UNIXSCM(skb).procinfo_len = scm->procinfo.len;
+		UNIXSCM(skb).procinfo = kmemdup(scm->procinfo.procinfo,
+						scm->procinfo.len, GFP_KERNEL);
+		if (!UNIXSCM(skb).procinfo)
+			return -ENOMEM;
+	}
+
 	skb->destructor = unix_destruct_scm;
 	return err;
 }
@@ -1438,6 +1460,22 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 	}
 }
 
+
+/* Include procinfo if source or destination socket
+ * asserted SOCK_PASSPROC.
+ */
+static void maybe_add_procinfo(struct sk_buff *skb, const struct socket *sock,
+			       const struct sock *other, int len,
+			       char *procinfo)
+{
+	if (test_bit(SOCK_PASSPROC, &sock->flags) ||
+	    !other->sk_socket ||
+	    test_bit(SOCK_PASSPROC, &other->sk_socket->flags)) {
+		UNIXSCM(skb).procinfo_len = len;
+		UNIXSCM(skb).procinfo = procinfo;
+	}
+}
+
 /*
  *	Send AF_UNIX data.
  */
@@ -1459,6 +1497,8 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct scm_cookie tmp_scm;
 	int max_level;
 	int data_len = 0;
+	char *procinfo = NULL;
+	int procinfo_len = 0;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1540,6 +1580,12 @@ restart:
 		goto out_free;
 	}
 
+	if (test_bit(SOCK_PASSPROC, &sock->flags) ||
+	    !other->sk_socket ||
+	    test_bit(SOCK_PASSPROC, &other->sk_socket->flags)) {
+		procinfo_len = scm_get_current_procinfo(&procinfo);
+	}
+
 	unix_state_lock(other);
 	err = -EPERM;
 	if (!unix_may_send(sk, other))
@@ -1600,6 +1646,7 @@ restart:
 	if (sock_flag(other, SOCK_RCVTSTAMP))
 		__net_timestamp(skb);
 	maybe_add_creds(skb, sock, other);
+	maybe_add_procinfo(skb, sock, other, procinfo_len, procinfo);
 	skb_queue_tail(&other->sk_receive_queue, skb);
 	if (max_level > unix_sk(other)->recursion_level)
 		unix_sk(other)->recursion_level = max_level;
@@ -1638,6 +1685,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	bool fds_sent = false;
 	int max_level;
 	int data_len;
+	char *procinfo = NULL;
+	int procinfo_len = 0;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1701,6 +1750,12 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out_err;
 		}
 
+		if (test_bit(SOCK_PASSPROC, &sock->flags) ||
+		    !other->sk_socket ||
+		    test_bit(SOCK_PASSPROC, &other->sk_socket->flags)) {
+			procinfo_len = scm_get_current_procinfo(&procinfo);
+		}
+
 		unix_state_lock(other);
 
 		if (sock_flag(other, SOCK_DEAD) ||
@@ -1708,6 +1763,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto pipe_err_free;
 
 		maybe_add_creds(skb, sock, other);
+		maybe_add_procinfo(skb, sock, other, procinfo_len, procinfo);
 		skb_queue_tail(&other->sk_receive_queue, skb);
 		if (max_level > unix_sk(other)->recursion_level)
 			unix_sk(other)->recursion_level = max_level;
@@ -1837,6 +1893,12 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+	if (UNIXCB(skb).scm && UNIXSCM(skb).procinfo)
+		scm_set_procinfo(siocb->scm,
+				 kmemdup(UNIXSCM(skb).procinfo,
+					 UNIXSCM(skb).procinfo_len,
+					 GFP_KERNEL),
+				 UNIXSCM(skb).procinfo_len);
 	unix_set_secdata(siocb->scm, skb);
 
 	if (!(flags & MSG_PEEK)) {
@@ -2023,6 +2085,14 @@ again:
 			check_creds = 1;
 		}
 
+		if (UNIXCB(skb).scm && UNIXSCM(skb).procinfo) {
+			scm_set_procinfo(siocb->scm,
+					 kmemdup(UNIXSCM(skb).procinfo,
+						 UNIXSCM(skb).procinfo_len,
+						 GFP_KERNEL),
+					 UNIXSCM(skb).procinfo_len);
+		}
+
 		/* Copy address just once */
 		if (sunaddr) {
 			unix_copy_addr(msg, skb->sk);
-- 
1.8.3.2
