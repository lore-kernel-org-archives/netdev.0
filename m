From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: Fix sid connector (was: Badness at kernel/softirq.c:143...)
Date: Tue, 29 Sep 2009 18:07:18 +0400
Message-ID: <20090929140718.GA23858@ioremap.net>
References: <200909251123.03482.borntraeger@de.ibm.com> <fbbbe0a028fa.4ac1f1c0@2ka.mipt.ru> <20090929132415.GB4538@redhat.com> <200909291547.21528.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	Evgeny Polyakov <johnpol@2ka.mipt.ru>,
	Scott James Remnant <scott@ubuntu.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752602AbZI2OHS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200909291547.21528.borntraeger@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 29, 2009 at 03:47:21PM +0200, Christian Borntraeger (borntraeger@de.ibm.com) wrote:
> Ok,  can confirm that this patch fixes my problem, but I am not sure if the
> intended behaviour is still working as expected.

Your patch breaks assumption that task_session(current->group_leader) is
not equal to new session id, but to check task_session() we need either
rcu or task lock. Also setsid() return value is not zero or negative
error, but new session ID or negative error, so I believe attached patch
is a proper fix, although it looks rather ugly.

Also proc_sid_connector() uses GFP_KERNEL allocation which is way too
wrong to use under any locks.

Something like this (not tested :)

diff --git a/kernel/exit.c b/kernel/exit.c
index 5859f59..1565baf 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -359,10 +359,8 @@ void __set_special_pids(struct pid *pid)
 {
 	struct task_struct *curr = current->group_leader;
 
-	if (task_session(curr) != pid) {
+	if (task_session(curr) != pid)
 		change_pid(curr, PIDTYPE_SID, pid);
-		proc_sid_connector(curr);
-	}
 
 	if (task_pgrp(curr) != pid)
 		change_pid(curr, PIDTYPE_PGID, pid);
diff --git a/kernel/sys.c b/kernel/sys.c
index 255475d..b852a8b 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1090,6 +1090,7 @@ SYSCALL_DEFINE0(setsid)
 	struct pid *sid = task_pid(group_leader);
 	pid_t session = pid_vnr(sid);
 	int err = -EPERM;
+	int send_cn = 0;
 
 	write_lock_irq(&tasklist_lock);
 	/* Fail if I am already a session leader */
@@ -1104,12 +1105,18 @@ SYSCALL_DEFINE0(setsid)
 
 	group_leader->signal->leader = 1;
 	__set_special_pids(sid);
+	if (task_session(group_leader) != sid)
+		send_cn = 1;
 
 	proc_clear_tty(group_leader);
 
 	err = session;
 out:
 	write_unlock_irq(&tasklist_lock);
+
+	if (send_cn)
+		proc_sid_connector(group_leader);
+
 	return err;
 }
 

-- 
	Evgeniy Polyakov
