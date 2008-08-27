From: David Howells <dhowells@redhat.com>
Subject: [PATCH 56/59] CRED: Wrap task credential accesses in the networking
	subsystem
Date: Wed, 27 Aug 2008 14:50:31 +0100
Message-ID: <20080827135031.19980.72505.stgit@warthog.procyon.org.uk>
References: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	David Howells <dhowells@redhat.com>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46650 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760224AbYH0OCA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 10:02:00 -0400
In-Reply-To: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap access to task credentials so that they can be separated more easily from
the task_struct during the introduction of COW creds.

Change most current->(|e|s|fs)[ug]id to current_(|e|s|fs)[ug]id().

Change some task->e?[ug]id to task_e?[ug]id().  In some places it makes more
sense to use RCU directly rather than a convenient wrapper; these will be
addressed by later patches.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: James Morris <jmorris@namei.org>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Cc: netdev@vger.kernel.org
---

 include/net/scm.h |    4 ++--
 net/core/dev.c    |    8 ++++++--
 net/core/scm.c    |    8 ++++----
 net/socket.c      |    4 ++--
 4 files changed, 14 insertions(+), 10 deletions(-)


diff --git a/include/net/scm.h b/include/net/scm.h
index 06df126..f160116 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -54,8 +54,8 @@ static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
 			       struct scm_cookie *scm)
 {
 	struct task_struct *p = current;
-	scm->creds.uid = p->uid;
-	scm->creds.gid = p->gid;
+	scm->creds.uid = current_uid();
+	scm->creds.gid = current_gid();
 	scm->creds.pid = task_tgid_vnr(p);
 	scm->fp = NULL;
 	scm->seq = 0;
diff --git a/net/core/dev.c b/net/core/dev.c
index 447aff0..b0a1ee8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2914,6 +2914,8 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 static int __dev_set_promiscuity(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
+	uid_t uid;
+	gid_t gid;
 
 	ASSERT_RTNL();
 
@@ -2938,15 +2940,17 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 		printk(KERN_INFO "device %s %s promiscuous mode\n",
 		       dev->name, (dev->flags & IFF_PROMISC) ? "entered" :
 							       "left");
-		if (audit_enabled)
+		if (audit_enabled) {
+			current_uid_gid(&uid, &gid);
 			audit_log(current->audit_context, GFP_ATOMIC,
 				AUDIT_ANOM_PROMISCUOUS,
 				"dev=%s prom=%d old_prom=%d auid=%u uid=%u gid=%u ses=%u",
 				dev->name, (dev->flags & IFF_PROMISC),
 				(old_flags & IFF_PROMISC),
 				audit_get_loginuid(current),
-				current->uid, current->gid,
+				uid, gid,
 				audit_get_sessionid(current));
+		}
 
 		if (dev->change_rx_flags)
 			dev->change_rx_flags(dev, IFF_PROMISC);
diff --git a/net/core/scm.c b/net/core/scm.c
index 10f5c65..4681d8f 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -45,10 +45,10 @@
 static __inline__ int scm_check_creds(struct ucred *creds)
 {
 	if ((creds->pid == task_tgid_vnr(current) || capable(CAP_SYS_ADMIN)) &&
-	    ((creds->uid == current->uid || creds->uid == current->euid ||
-	      creds->uid == current->suid) || capable(CAP_SETUID)) &&
-	    ((creds->gid == current->gid || creds->gid == current->egid ||
-	      creds->gid == current->sgid) || capable(CAP_SETGID))) {
+	    ((creds->uid == current_uid()   || creds->uid == current_euid() ||
+	      creds->uid == current_suid()) || capable(CAP_SETUID)) &&
+	    ((creds->gid == current_gid()   || creds->gid == current_egid() ||
+	      creds->gid == current_sgid()) || capable(CAP_SETGID))) {
 	       return 0;
 	}
 	return -EPERM;
diff --git a/net/socket.c b/net/socket.c
index 77990d3..58f9c51 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -491,8 +491,8 @@ static struct socket *sock_alloc(void)
 	sock = SOCKET_I(inode);
 
 	inode->i_mode = S_IFSOCK | S_IRWXUGO;
-	inode->i_uid = current->fsuid;
-	inode->i_gid = current->fsgid;
+	inode->i_uid = current_fsuid();
+	inode->i_gid = current_fsgid();
 
 	get_cpu_var(sockets_in_use)++;
 	put_cpu_var(sockets_in_use);

