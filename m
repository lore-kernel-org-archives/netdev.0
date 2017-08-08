From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH] Allow passing tid or pid in SCM_CREDENTIALS without CAP_SYS_ADMIN
Date: Mon,  7 Aug 2017 17:07:10 -0700
Message-ID: <1502150830-3964-1-git-send-email-prakash.sangappa@oracle.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
        prakash.sangappa@oracle.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently passing tid(gettid(2)) of a thread in struct ucred in
SCM_CREDENTIALS message requires CAP_SYS_ADMIN capability otherwise
it fails with EPERM error. Some applications deal with thread id
of a thread(tid) and so it would help to allow tid in SCM_CREDENTIALS
message. Basically, either tgid(pid of the process) or the tid of
the thread should be allowed without the need for CAP_SYS_ADMIN capability.

SCM_CREDENTIALS will be used to determine the global id of a process or
a thread running inside a pid namespace.

This patch adds necessary check to accept tid in SCM_CREDENTIALS
struct ucred.

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
---
 net/core/scm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/scm.c b/net/core/scm.c
index b1ff8a4..9274197 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -55,6 +55,7 @@ static __inline__ int scm_check_creds(struct ucred *creds)
 		return -EINVAL;
 
 	if ((creds->pid == task_tgid_vnr(current) ||
+	     creds->pid == task_pid_vnr(current) ||
 	     ns_capable(task_active_pid_ns(current)->user_ns, CAP_SYS_ADMIN)) &&
 	    ((uid_eq(uid, cred->uid)   || uid_eq(uid, cred->euid) ||
 	      uid_eq(uid, cred->suid)) || ns_capable(cred->user_ns, CAP_SETUID)) &&
-- 
2.7.4
