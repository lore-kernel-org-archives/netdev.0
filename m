From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] af_unix: dont send SCM_CREDENTIALS by default
Date: Mon, 19 Sep 2011 17:52:27 +0200
Message-ID: <1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315473888.2301.21.camel@schen9-mobl>
	 <1315544777.5410.19.camel@edumazet-laptop>
	 <20110918.210758.2207266633127640132.davem@davemloft.net>
	 <1316406528.2521.15.camel@edumazet-laptop>
	 <1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tim.c.chen@linux.intel.com, zheng.z.yan@intel.com,
	yanzheng@21cn.com, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	jirislaby@gmail.com, sedat.dilek@gmail.com, alex.shi@intel.com,
	Valdis.Kletnieks@vt.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50241 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab1ISPwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 11:52:19 -0400
Received: by bkbzt4 with SMTP id zt4so5409008bkb.19
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 08:52:17 -0700 (PDT)
In-Reply-To: <1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 7361c36c5224 (af_unix: Allow credentials to work across
user and pid namespaces) af_unix performance dropped a lot.

This is because we now take a reference on pid and cred in each write(),
and release them in read(), usually done from another process,
eventually from another cpu. This triggers false sharing.

# Events: 154K cycles
#
# Overhead  Command       Shared Object        Symbol
# ........  .......  ..................  .........................
#
    10.40%  hackbench  [kernel.kallsyms]   [k] put_pid
     8.60%  hackbench  [kernel.kallsyms]   [k] unix_stream_recvmsg
     7.87%  hackbench  [kernel.kallsyms]   [k] unix_stream_sendmsg
     6.11%  hackbench  [kernel.kallsyms]   [k] do_raw_spin_lock
     4.95%  hackbench  [kernel.kallsyms]   [k] unix_scm_to_skb
     4.87%  hackbench  [kernel.kallsyms]   [k] pid_nr_ns
     4.34%  hackbench  [kernel.kallsyms]   [k] cred_to_ucred
     2.39%  hackbench  [kernel.kallsyms]   [k] unix_destruct_scm
     2.24%  hackbench  [kernel.kallsyms]   [k] sub_preempt_count
     1.75%  hackbench  [kernel.kallsyms]   [k] fget_light
     1.51%  hackbench  [kernel.kallsyms]   [k]
__mutex_lock_interruptible_slowpath
     1.42%  hackbench  [kernel.kallsyms]   [k] sock_alloc_send_pskb


This patch includes SCM_CREDENTIALS information in a af_unix message/skb
only if requested by the sender, [man 7 unix for details how to include
ancillary data using sendmsg() system call]

Note: This might break buggy applications that expected SCM_CREDENTIAL
from an unaware write() system call, and receiver not using SO_PASSCRED
socket option.

If SOCK_PASSCRED is set on source or destination socket, we still
include credentials for mere write() syscalls.

Performance boost in hackbench : more than 50% gain on a 16 thread
machine (2 quad-core cpus, 2 threads per core)

hackbench 20 thread 2000

4.228 sec instead of 9.102 sec

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netlink/af_netlink.c net/unix/af_unix.c|diffstat -p1 -w70
 include/net/scm.h        |    5 ++---
 net/core/scm.c           |   10 ++++++----
 net/netlink/af_netlink.c |    5 ++---
 net/unix/af_unix.c       |   24 +++++++++++++++++++++++--
 4 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 745460f..d456f4c 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -49,7 +49,7 @@ static __inline__ void scm_set_cred(struct scm_cookie *scm,
 				    struct pid *pid, const struct cred *cred)
 {
 	scm->pid  = get_pid(pid);
-	scm->cred = get_cred(cred);
+	scm->cred = cred ? get_cred(cred) : NULL;
 	cred_to_ucred(pid, cred, &scm->creds);
 }
 
@@ -73,8 +73,7 @@ static __inline__ void scm_destroy(struct scm_cookie *scm)
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
 			       struct scm_cookie *scm)
 {
-	scm_set_cred(scm, task_tgid(current), current_cred());
-	scm->fp = NULL;
+	memset(scm, 0, sizeof(*scm));
 	unix_get_peersec_dgram(sock, scm);
 	if (msg->msg_controllen <= 0)
 		return 0;
diff --git a/net/core/scm.c b/net/core/scm.c
index 811b53f..ff52ad0 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -173,7 +173,7 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 			if (err)
 				goto error;
 
-			if (pid_vnr(p->pid) != p->creds.pid) {
+			if (!p->pid || pid_vnr(p->pid) != p->creds.pid) {
 				struct pid *pid;
 				err = -ESRCH;
 				pid = find_get_pid(p->creds.pid);
@@ -183,8 +183,9 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 				p->pid = pid;
 			}
 
-			if ((p->cred->euid != p->creds.uid) ||
-				(p->cred->egid != p->creds.gid)) {
+			if (!p->cred ||
+			    (p->cred->euid != p->creds.uid) ||
+			    (p->cred->egid != p->creds.gid)) {
 				struct cred *cred;
 				err = -ENOMEM;
 				cred = prepare_creds();
@@ -193,7 +194,8 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 
 				cred->uid = cred->euid = p->creds.uid;
 				cred->gid = cred->egid = p->creds.gid;
-				put_cred(p->cred);
+				if (p->cred)
+					put_cred(p->cred);
 				p->cred = cred;
 			}
 			break;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4330db9..1201b6d 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1324,10 +1324,9 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (msg->msg_flags&MSG_OOB)
 		return -EOPNOTSUPP;
 
-	if (NULL == siocb->scm) {
+	if (NULL == siocb->scm)
 		siocb->scm = &scm;
-		memset(&scm, 0, sizeof(scm));
-	}
+
 	err = scm_send(sock, msg, siocb->scm);
 	if (err < 0)
 		return err;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ec68e1c..466fbcc 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1381,8 +1381,10 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool send_fds)
 {
 	int err = 0;
+
 	UNIXCB(skb).pid  = get_pid(scm->pid);
-	UNIXCB(skb).cred = get_cred(scm->cred);
+	if (scm->cred)
+		UNIXCB(skb).cred = get_cred(scm->cred);
 	UNIXCB(skb).fp = NULL;
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
@@ -1392,6 +1394,24 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 }
 
 /*
+ * Some apps rely on write() giving SCM_CREDENTIALS
+ * We include credentials if source or destination socket
+ * asserted SOCK_PASSCRED.
+ */
+static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
+			    const struct sock *other)
+{
+	if (UNIXCB(skb).cred)
+		return;
+	if (test_bit(SOCK_PASSCRED, &sock->flags) ||
+	    !other->sk_socket ||
+	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
+		UNIXCB(skb).pid  = get_pid(task_tgid(current));
+		UNIXCB(skb).cred = get_current_cred();
+	}
+}
+
+/*
  *	Send AF_UNIX data.
  */
 
@@ -1538,6 +1558,7 @@ restart:
 
 	if (sock_flag(other, SOCK_RCVTSTAMP))
 		__net_timestamp(skb);
+	maybe_add_creds(skb, sock, other);
 	skb_queue_tail(&other->sk_receive_queue, skb);
 	if (max_level > unix_sk(other)->recursion_level)
 		unix_sk(other)->recursion_level = max_level;
@@ -1652,6 +1673,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		    (other->sk_shutdown & RCV_SHUTDOWN))
 			goto pipe_err_free;
 
+		maybe_add_creds(skb, sock, other);
 		skb_queue_tail(&other->sk_receive_queue, skb);
 		if (max_level > unix_sk(other)->recursion_level)
 			unix_sk(other)->recursion_level = max_level;
