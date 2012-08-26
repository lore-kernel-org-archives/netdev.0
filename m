From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 05/15] userns: Convert ipc to use kuid and kgid where appropriate
Date: Sat, 25 Aug 2012 17:00:40 -0700
Message-ID: <87sjbafro7.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- Store the ipc owner and creator with a kuid
- Store the ipc group and the crators group with a kgid.
- Add error handling to ipc_update_perms, allowing it to
  fail if the uids and gids can not be converted to kuids
  or kgids.
- Modify the proc files to display the ipc creator and
  owner in the user namespace of the opener of the proc file.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/ipc.h |    9 +++++----
 init/Kconfig        |    1 -
 ipc/msg.c           |   14 +++++++++-----
 ipc/sem.c           |   13 ++++++++-----
 ipc/shm.c           |   19 +++++++++++--------
 ipc/util.c          |   35 +++++++++++++++++++++--------------
 ipc/util.h          |    2 +-
 7 files changed, 55 insertions(+), 38 deletions(-)

diff --git a/include/linux/ipc.h b/include/linux/ipc.h
index 30e8161..ca833fd 100644
--- a/include/linux/ipc.h
+++ b/include/linux/ipc.h
@@ -79,6 +79,7 @@ struct ipc_kludge {
 
 #ifdef __KERNEL__
 #include <linux/spinlock.h>
+#include <linux/uidgid.h>
 
 #define IPCMNI 32768  /* <= MAX_INT limit for ipc arrays (including sysctl changes) */
 
@@ -89,10 +90,10 @@ struct kern_ipc_perm
 	int		deleted;
 	int		id;
 	key_t		key;
-	uid_t		uid;
-	gid_t		gid;
-	uid_t		cuid;
-	gid_t		cgid;
+	kuid_t		uid;
+	kgid_t		gid;
+	kuid_t		cuid;
+	kgid_t		cgid;
 	umode_t		mode; 
 	unsigned long	seq;
 	void		*security;
diff --git a/init/Kconfig b/init/Kconfig
index 28715ec..4daf449 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -925,7 +925,6 @@ config UIDGID_CONVERTED
 
 	# List of kernel pieces that need user namespace work
 	# Features
-	depends on SYSVIPC = n
 	depends on IMA = n
 	depends on EVM = n
 	depends on AUDIT = n
diff --git a/ipc/msg.c b/ipc/msg.c
index 7385de2..a71af5a 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -443,9 +443,12 @@ static int msgctl_down(struct ipc_namespace *ns, int msqid, int cmd,
 			goto out_unlock;
 		}
 
+		err = ipc_update_perm(&msqid64.msg_perm, ipcp);
+		if (err)
+			goto out_unlock;
+
 		msq->q_qbytes = msqid64.msg_qbytes;
 
-		ipc_update_perm(&msqid64.msg_perm, ipcp);
 		msq->q_ctime = get_seconds();
 		/* sleeping receivers might be excluded by
 		 * stricter permissions.
@@ -922,6 +925,7 @@ out:
 #ifdef CONFIG_PROC_FS
 static int sysvipc_msg_proc_show(struct seq_file *s, void *it)
 {
+	struct user_namespace *user_ns = seq_user_ns(s);
 	struct msg_queue *msq = it;
 
 	return seq_printf(s,
@@ -933,10 +937,10 @@ static int sysvipc_msg_proc_show(struct seq_file *s, void *it)
 			msq->q_qnum,
 			msq->q_lspid,
 			msq->q_lrpid,
-			msq->q_perm.uid,
-			msq->q_perm.gid,
-			msq->q_perm.cuid,
-			msq->q_perm.cgid,
+			from_kuid_munged(user_ns, msq->q_perm.uid),
+			from_kgid_munged(user_ns, msq->q_perm.gid),
+			from_kuid_munged(user_ns, msq->q_perm.cuid),
+			from_kgid_munged(user_ns, msq->q_perm.cgid),
 			msq->q_stime,
 			msq->q_rtime,
 			msq->q_ctime);
diff --git a/ipc/sem.c b/ipc/sem.c
index 5215a81..58d31f1 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -1104,7 +1104,9 @@ static int semctl_down(struct ipc_namespace *ns, int semid,
 		freeary(ns, ipcp);
 		goto out_up;
 	case IPC_SET:
-		ipc_update_perm(&semid64.sem_perm, ipcp);
+		err = ipc_update_perm(&semid64.sem_perm, ipcp);
+		if (err)
+			goto out_unlock;
 		sma->sem_ctime = get_seconds();
 		break;
 	default:
@@ -1677,6 +1679,7 @@ void exit_sem(struct task_struct *tsk)
 #ifdef CONFIG_PROC_FS
 static int sysvipc_sem_proc_show(struct seq_file *s, void *it)
 {
+	struct user_namespace *user_ns = seq_user_ns(s);
 	struct sem_array *sma = it;
 
 	return seq_printf(s,
@@ -1685,10 +1688,10 @@ static int sysvipc_sem_proc_show(struct seq_file *s, void *it)
 			  sma->sem_perm.id,
 			  sma->sem_perm.mode,
 			  sma->sem_nsems,
-			  sma->sem_perm.uid,
-			  sma->sem_perm.gid,
-			  sma->sem_perm.cuid,
-			  sma->sem_perm.cgid,
+			  from_kuid_munged(user_ns, sma->sem_perm.uid),
+			  from_kgid_munged(user_ns, sma->sem_perm.gid),
+			  from_kuid_munged(user_ns, sma->sem_perm.cuid),
+			  from_kgid_munged(user_ns, sma->sem_perm.cgid),
 			  sma->sem_otime,
 			  sma->sem_ctime);
 }
diff --git a/ipc/shm.c b/ipc/shm.c
index 00faa05..dff40c9 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -758,7 +758,9 @@ static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 		do_shm_rmid(ns, ipcp);
 		goto out_up;
 	case IPC_SET:
-		ipc_update_perm(&shmid64.shm_perm, ipcp);
+		err = ipc_update_perm(&shmid64.shm_perm, ipcp);
+		if (err)
+			goto out_unlock;
 		shp->shm_ctim = get_seconds();
 		break;
 	default:
@@ -893,10 +895,10 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 		audit_ipc_obj(&(shp->shm_perm));
 
 		if (!ns_capable(ns->user_ns, CAP_IPC_LOCK)) {
-			uid_t euid = current_euid();
+			kuid_t euid = current_euid();
 			err = -EPERM;
-			if (euid != shp->shm_perm.uid &&
-			    euid != shp->shm_perm.cuid)
+			if (!uid_eq(euid, shp->shm_perm.uid) &&
+			    !uid_eq(euid, shp->shm_perm.cuid))
 				goto out_unlock;
 			if (cmd == SHM_LOCK && !rlimit(RLIMIT_MEMLOCK))
 				goto out_unlock;
@@ -1220,6 +1222,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 #ifdef CONFIG_PROC_FS
 static int sysvipc_shm_proc_show(struct seq_file *s, void *it)
 {
+	struct user_namespace *user_ns = seq_user_ns(s);
 	struct shmid_kernel *shp = it;
 	unsigned long rss = 0, swp = 0;
 
@@ -1242,10 +1245,10 @@ static int sysvipc_shm_proc_show(struct seq_file *s, void *it)
 			  shp->shm_cprid,
 			  shp->shm_lprid,
 			  shp->shm_nattch,
-			  shp->shm_perm.uid,
-			  shp->shm_perm.gid,
-			  shp->shm_perm.cuid,
-			  shp->shm_perm.cgid,
+			  from_kuid_munged(user_ns, shp->shm_perm.uid),
+			  from_kgid_munged(user_ns, shp->shm_perm.gid),
+			  from_kuid_munged(user_ns, shp->shm_perm.cuid),
+			  from_kgid_munged(user_ns, shp->shm_perm.cgid),
 			  shp->shm_atim,
 			  shp->shm_dtim,
 			  shp->shm_ctim,
diff --git a/ipc/util.c b/ipc/util.c
index eb07fd3..72fd078 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -249,8 +249,8 @@ int ipc_get_maxid(struct ipc_ids *ids)
  
 int ipc_addid(struct ipc_ids* ids, struct kern_ipc_perm* new, int size)
 {
-	uid_t euid;
-	gid_t egid;
+	kuid_t euid;
+	kgid_t egid;
 	int id, err;
 
 	if (size > IPCMNI)
@@ -606,14 +606,14 @@ void ipc_rcu_putref(void *ptr)
  
 int ipcperms(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp, short flag)
 {
-	uid_t euid = current_euid();
+	kuid_t euid = current_euid();
 	int requested_mode, granted_mode;
 
 	audit_ipc_obj(ipcp);
 	requested_mode = (flag >> 6) | (flag >> 3) | flag;
 	granted_mode = ipcp->mode;
-	if (euid == ipcp->cuid ||
-	    euid == ipcp->uid)
+	if (uid_eq(euid, ipcp->cuid) ||
+	    uid_eq(euid, ipcp->uid))
 		granted_mode >>= 6;
 	else if (in_group_p(ipcp->cgid) || in_group_p(ipcp->gid))
 		granted_mode >>= 3;
@@ -643,10 +643,10 @@ int ipcperms(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp, short flag)
 void kernel_to_ipc64_perm (struct kern_ipc_perm *in, struct ipc64_perm *out)
 {
 	out->key	= in->key;
-	out->uid	= in->uid;
-	out->gid	= in->gid;
-	out->cuid	= in->cuid;
-	out->cgid	= in->cgid;
+	out->uid	= from_kuid_munged(current_user_ns(), in->uid);
+	out->gid	= from_kgid_munged(current_user_ns(), in->gid);
+	out->cuid	= from_kuid_munged(current_user_ns(), in->cuid);
+	out->cgid	= from_kgid_munged(current_user_ns(), in->cgid);
 	out->mode	= in->mode;
 	out->seq	= in->seq;
 }
@@ -747,12 +747,19 @@ int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids,
  * @in:  the permission given as input.
  * @out: the permission of the ipc to set.
  */
-void ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out)
+int ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out)
 {
-	out->uid = in->uid;
-	out->gid = in->gid;
+	kuid_t uid = make_kuid(current_user_ns(), in->uid);
+	kgid_t gid = make_kgid(current_user_ns(), in->gid);
+	if (!uid_valid(uid) || !gid_valid(gid))
+		return -EINVAL;
+
+	out->uid = uid;
+	out->gid = gid;
 	out->mode = (out->mode & ~S_IRWXUGO)
 		| (in->mode & S_IRWXUGO);
+
+	return 0;
 }
 
 /**
@@ -777,7 +784,7 @@ struct kern_ipc_perm *ipcctl_pre_down(struct ipc_namespace *ns,
 				      struct ipc64_perm *perm, int extra_perm)
 {
 	struct kern_ipc_perm *ipcp;
-	uid_t euid;
+	kuid_t euid;
 	int err;
 
 	down_write(&ids->rw_mutex);
@@ -793,7 +800,7 @@ struct kern_ipc_perm *ipcctl_pre_down(struct ipc_namespace *ns,
 					 perm->gid, perm->mode);
 
 	euid = current_euid();
-	if (euid == ipcp->cuid || euid == ipcp->uid  ||
+	if (uid_eq(euid, ipcp->cuid) || uid_eq(euid, ipcp->uid)  ||
 	    ns_capable(ns->user_ns, CAP_SYS_ADMIN))
 		return ipcp;
 
diff --git a/ipc/util.h b/ipc/util.h
index 850ef3e..c8fe2f7 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -125,7 +125,7 @@ struct kern_ipc_perm *ipc_lock(struct ipc_ids *, int);
 
 void kernel_to_ipc64_perm(struct kern_ipc_perm *in, struct ipc64_perm *out);
 void ipc64_perm_to_ipc_perm(struct ipc64_perm *in, struct ipc_perm *out);
-void ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out);
+int ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out);
 struct kern_ipc_perm *ipcctl_pre_down(struct ipc_namespace *ns,
 				      struct ipc_ids *ids, int id, int cmd,
 				      struct ipc64_perm *perm, int extra_perm);
-- 
1.7.5.4
