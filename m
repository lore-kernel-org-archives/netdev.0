From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v5 07/10] ipc: add new SEM_SET command for sys_semctl() call
Date: Wed, 19 Sep 2012 20:06:05 +0400
Message-ID: <20120919160604.11254.72994.stgit@localhost6.localdomain6>
References: <20120919160430.11254.86848.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org, will.deacon@arm.com,
	linux-kernel@vger.kernel.org, cmetcalf@tilera.com,
	jmorris@namei.org, linux-driver@qlogic.com,
	linux-security-module@vger.kernel.org, hughd@google.com,
	ron.mercer@qlogic.com, viro@zeniv.linux.org.uk,
	james.l.morris@oracle.com, catalin.marinas@arm.com,
	casey@schaufler-ca.com, eparis@parisplace.org, sds@tycho.nsa.gov,
	jitendra.kalsaria@qlogic.com, devel@openvz.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120919160430.11254.86848.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New SEM_SET command will be interpreted exactly as IPC_SET, but also will
update key, cuid and cgid values. IOW, it allows to change existent key value.
The fact, that key is not used is checked before update. Otherwise -EEXIST is
returned.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 include/linux/sem.h        |    1 +
 ipc/compat.c               |    1 +
 ipc/sem.c                  |   10 ++++++++--
 security/selinux/hooks.c   |    1 +
 security/smack/smack_lsm.c |    1 +
 5 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/sem.h b/include/linux/sem.h
index 10d6b22..c74b9b5 100644
--- a/include/linux/sem.h
+++ b/include/linux/sem.h
@@ -18,6 +18,7 @@
 /* ipcs ctl cmds */
 #define SEM_STAT 18
 #define SEM_INFO 19
+#define SEM_SET  20
 
 /* Obsolete, used only for backwards compatibility and libc5 compiles */
 struct semid_ds {
diff --git a/ipc/compat.c b/ipc/compat.c
index 9c70f9a..84d8efd 100644
--- a/ipc/compat.c
+++ b/ipc/compat.c
@@ -290,6 +290,7 @@ static long do_compat_semctl(int first, int second, int third, u32 pad)
 		break;
 
 	case IPC_SET:
+	case SEM_SET:
 		if (version == IPC_64) {
 			err = get_compat_semid64_ds(&s64, compat_ptr(pad));
 		} else {
diff --git a/ipc/sem.c b/ipc/sem.c
index e89b90c..b4f80082 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -1085,12 +1085,13 @@ static int semctl_down(struct ipc_namespace *ns, int semid,
 	struct semid64_ds semid64;
 	struct kern_ipc_perm *ipcp;
 
-	if(cmd == IPC_SET) {
+	if (cmd == IPC_SET || cmd == SEM_SET) {
 		if (copy_semid_from_user(&semid64, arg.buf, version))
 			return -EFAULT;
 	}
 
-	ipcp = ipcctl_pre_down(ns, &sem_ids(ns), semid, cmd,
+	ipcp = ipcctl_pre_down(ns, &sem_ids(ns), semid,
+			       (cmd != SEM_SET) ? cmd : IPC_SET,
 			       &semid64.sem_perm, 0);
 	if (IS_ERR(ipcp))
 		return PTR_ERR(ipcp);
@@ -1105,6 +1106,10 @@ static int semctl_down(struct ipc_namespace *ns, int semid,
 	case IPC_RMID:
 		freeary(ns, ipcp);
 		goto out_up;
+	case SEM_SET:
+		err = ipc_update_key(&sem_ids(ns), &semid64.sem_perm, ipcp);
+		if (err)
+			break;
 	case IPC_SET:
 		ipc_update_perm(&semid64.sem_perm, ipcp);
 		sma->sem_ctime = get_seconds();
@@ -1150,6 +1155,7 @@ SYSCALL_DEFINE(semctl)(int semid, int semnum, int cmd, union semun arg)
 		return err;
 	case IPC_RMID:
 	case IPC_SET:
+	case SEM_SET:
 		err = semctl_down(ns, semid, cmd, version, arg);
 		return err;
 	default:
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 8269286..a23a7d6 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -5164,6 +5164,7 @@ static int selinux_sem_semctl(struct sem_array *sma, int cmd)
 		perms = SEM__DESTROY;
 		break;
 	case IPC_SET:
+	case SEM_SET:
 		perms = SEM__SETATTR;
 		break;
 	case IPC_STAT:
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 193e147..fea40cf 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -2274,6 +2274,7 @@ static int smack_sem_semctl(struct sem_array *sma, int cmd)
 	case SETALL:
 	case IPC_RMID:
 	case IPC_SET:
+	case SEM_SET:
 		may = MAY_READWRITE;
 		break;
 	case IPC_INFO:
