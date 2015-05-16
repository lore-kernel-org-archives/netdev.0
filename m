From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] Remove refcounting from unix domain sockets
Date: Sat, 16 May 2015 11:48:09 -0500
Message-ID: <87a8x4o4dy.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Lutomirski <luto@amacapital.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45705 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbEPQxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 12:53:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While thinking about things it occurred to me that by fixing what is
arguably in a bug in the unix domain socket implementation I can
remove the performance penality for credential passing.

That bug is the fact that the cmsg returned on a unix domain socket
is different depending on who calls recvmsg.  Passing file descriptor
should not changes how it operates (oops).

There is a second bug this also fixes, pids are now translated as they
traverse netlink sockets.

By grabbing a reference to the user and pid namespaces on each
unix domain socket, and each netlink socket I can translate the
uids and pids when they are placed on the destination socket and
avoid the need for a reference count.

This patch is still a little rough and needs to be split up and some of
the netlink callers need to be tweaked to pass NULL for the new scm
parameter, but it shows to me at least that the my brainstorm is
workable.

What I really haven't done yet is benchmark anything.  I just know in
principle that the benchmark numbers should be better, as even the pid
refcount goes away (except when we are faking the senders pid).

Does anyone have ideas about benchmarks that would be useful to run?
Does this sound like something that will make unix domain and netlink
sockets faster?
Does refcounting the userns and the pidns from each unix domain or
netlink socket look like it will add problematic overhead?

Eric


---

 include/linux/netlink.h  | 13 ++++---
 include/net/af_unix.h    |  9 +++--
 include/net/netlink.h    |  4 +-
 include/net/scm.h        | 43 +++++++--------------
 net/core/scm.c           | 13 ++++---
 net/netlink/af_netlink.c | 82 ++++++++++++++++++++++++++--------------
 net/netlink/af_netlink.h |  5 +++
 net/unix/af_unix.c       | 98 ++++++++++++++++++++++++++----------------------
 8 files changed, 149 insertions(+), 118 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 6835c1279df7..63279e5c8cee 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -23,7 +23,7 @@ enum netlink_skb_flags {
 };
 
 struct netlink_skb_parms {
-	struct scm_creds	creds;		/* Skb credentials	*/
+	struct ucred		creds;		/* Skb credentials	*/
 	__u32			portid;
 	__u32			dst_group;
 	__u32			flags;
@@ -31,7 +31,6 @@ struct netlink_skb_parms {
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
-#define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
 extern void netlink_table_grab(void);
@@ -68,11 +67,13 @@ extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 					 u32 dst_portid, gfp_t gfp_mask);
-extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
+extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
+			   struct scm_cookie *scm, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
-			     __u32 group, gfp_t allocation);
+			     __u32 group, struct scm_cookie *scm,
+			     gfp_t allocation);
 extern int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb,
-	__u32 portid, __u32 group, gfp_t allocation,
+	__u32 portid, __u32 group, struct scm_cookie *scm, gfp_t allocation,
 	int (*filter)(struct sock *dsk, struct sk_buff *skb, void *data),
 	void *filter_data);
 extern int netlink_set_err(struct sock *ssk, __u32 portid, __u32 group, int code);
@@ -82,7 +83,7 @@ extern int netlink_unregister_notifier(struct notifier_block *nb);
 /* finegrained unicast helpers: */
 struct sock *netlink_getsockbyfilp(struct file *filp);
 int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
-		      long *timeo, struct sock *ssk);
+		      long *timeo, struct sock *ssk, struct scm_cookie *scm);
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index a175ba4a7adb..55c90b4d06cb 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -6,6 +6,9 @@
 #include <linux/mutex.h>
 #include <net/sock.h>
 
+struct pid_namespace;
+struct user_namespace;
+
 void unix_inflight(struct file *fp);
 void unix_notinflight(struct file *fp);
 void unix_gc(void);
@@ -28,10 +31,8 @@ struct unix_address {
 };
 
 struct unix_skb_parms {
-	struct pid		*pid;		/* Skb credentials	*/
-	kuid_t			uid;
-	kgid_t			gid;
 	struct scm_fp_list	*fp;		/* Passed files		*/
+	struct ucred		creds;		/* Skb credentials	*/
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Security ID		*/
 #endif
@@ -63,6 +64,8 @@ struct unix_sock {
 #define UNIX_GC_CANDIDATE	0
 #define UNIX_GC_MAYBE_CYCLE	1
 	struct socket_wq	peer_wq;
+	struct pid_namespace	*pid_ns;
+	struct user_namespace	*user_ns;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 2a5dbcc90d1c..5622d5f65489 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -562,7 +562,7 @@ static inline int nlmsg_multicast(struct sock *sk, struct sk_buff *skb,
 
 	NETLINK_CB(skb).dst_group = group;
 
-	err = netlink_broadcast(sk, skb, portid, group, flags);
+	err = netlink_broadcast(sk, skb, portid, group, NULL, flags);
 	if (err > 0)
 		err = 0;
 
@@ -579,7 +579,7 @@ static inline int nlmsg_unicast(struct sock *sk, struct sk_buff *skb, u32 portid
 {
 	int err;
 
-	err = netlink_unicast(sk, skb, portid, MSG_DONTWAIT);
+	err = netlink_unicast(sk, skb, portid, NULL, MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
 
diff --git a/include/net/scm.h b/include/net/scm.h
index 262532d111f5..857c0dad72a6 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -13,7 +13,7 @@
 #define SCM_MAX_FD	253
 
 struct scm_creds {
-	u32	pid;
+	struct pid *pid;
 	kuid_t	uid;
 	kgid_t	gid;
 };
@@ -25,9 +25,9 @@ struct scm_fp_list {
 };
 
 struct scm_cookie {
-	struct pid		*pid;		/* Skb credentials */
 	struct scm_fp_list	*fp;		/* Passed files		*/
-	struct scm_creds	creds;		/* Skb credentials	*/
+	struct scm_creds	icreds;		/* Skb input credentials */
+	struct ucred		ocreds;		/* Skb output credentials */
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Passed security ID 	*/
 #endif
@@ -49,19 +49,10 @@ static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_co
 { }
 #endif /* CONFIG_SECURITY_NETWORK */
 
-static __inline__ void scm_set_cred(struct scm_cookie *scm,
-				    struct pid *pid, kuid_t uid, kgid_t gid)
-{
-	scm->pid  = get_pid(pid);
-	scm->creds.pid = pid_vnr(pid);
-	scm->creds.uid = uid;
-	scm->creds.gid = gid;
-}
-
 static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
 {
-	put_pid(scm->pid);
-	scm->pid  = NULL;
+	if (scm->icreds.pid != task_tgid(current))
+		put_pid(scm->icreds.pid);
 }
 
 static __inline__ void scm_destroy(struct scm_cookie *scm)
@@ -75,10 +66,12 @@ static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
 			       struct scm_cookie *scm, bool forcecreds)
 {
 	memset(scm, 0, sizeof(*scm));
-	scm->creds.uid = INVALID_UID;
-	scm->creds.gid = INVALID_GID;
-	if (forcecreds)
-		scm_set_cred(scm, task_tgid(current), current_uid(), current_gid());
+	scm->icreds.uid = INVALID_UID;
+	scm->icreds.gid = INVALID_GID;
+	if (forcecreds) {
+		scm->icreds.pid = task_tgid(current);
+		current_uid_gid(&scm->icreds.uid, &scm->icreds.gid);
+	}
 	unix_get_peersec_dgram(sock, scm);
 	if (msg->msg_controllen <= 0)
 		return 0;
@@ -116,17 +109,9 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 		return;
 	}
 
-	if (test_bit(SOCK_PASSCRED, &sock->flags)) {
-		struct user_namespace *current_ns = current_user_ns();
-		struct ucred ucreds = {
-			.pid = scm->creds.pid,
-			.uid = from_kuid_munged(current_ns, scm->creds.uid),
-			.gid = from_kgid_munged(current_ns, scm->creds.gid),
-		};
-		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(ucreds), &ucreds);
-	}
-
-	scm_destroy_cred(scm);
+	if (test_bit(SOCK_PASSCRED, &sock->flags))
+		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS,
+			 sizeof(scm->ocreds), &scm->ocreds);
 
 	scm_passec(sock, msg, scm);
 
diff --git a/net/core/scm.c b/net/core/scm.c
index 3b6899b7d810..78f0ecf39dc3 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -167,15 +167,16 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 			if (err)
 				goto error;
 
-			p->creds.pid = creds.pid;
-			if (!p->pid || pid_vnr(p->pid) != creds.pid) {
+			if (!p->icreds.pid ||
+			    pid_vnr(p->icreds.pid) != creds.pid) {
 				struct pid *pid;
 				err = -ESRCH;
 				pid = find_get_pid(creds.pid);
 				if (!pid)
 					goto error;
-				put_pid(p->pid);
-				p->pid = pid;
+				if (p->icreds.pid != task_tgid(current))
+					put_pid(p->icreds.pid);
+				p->icreds.pid = pid;
 			}
 
 			err = -EINVAL;
@@ -184,8 +185,8 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 			if (!uid_valid(uid) || !gid_valid(gid))
 				goto error;
 
-			p->creds.uid = uid;
-			p->creds.gid = gid;
+			p->icreds.uid = uid;
+			p->icreds.gid = gid;
 			break;
 		}
 		default:
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5e3883bad65a..a8e8b9cdcac5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -62,6 +62,8 @@
 #include <asm/cacheflush.h>
 #include <linux/hash.h>
 #include <linux/genetlink.h>
+#include <linux/pid_namespace.h>
+#include <linux/user_namespace.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -743,7 +745,6 @@ static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
 
 		NETLINK_CB(skb).portid	  = nlk->portid;
 		NETLINK_CB(skb).dst_group = dst_group;
-		NETLINK_CB(skb).creds	  = scm->creds;
 
 		err = security_netlink_send(sk, skb);
 		if (err) {
@@ -754,9 +755,9 @@ static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
 		if (unlikely(dst_group)) {
 			atomic_inc(&skb->users);
 			netlink_broadcast(sk, skb, dst_portid, dst_group,
-					  GFP_KERNEL);
+					  scm, GFP_KERNEL);
 		}
-		err = netlink_unicast(sk, skb, dst_portid,
+		err = netlink_unicast(sk, skb, dst_portid, scm,
 				      msg->msg_flags & MSG_DONTWAIT);
 		if (err < 0)
 			goto out;
@@ -781,8 +782,8 @@ static void netlink_queue_mmaped_skb(struct sock *sk, struct sk_buff *skb)
 	hdr->nm_len	= skb->len;
 	hdr->nm_group	= NETLINK_CB(skb).dst_group;
 	hdr->nm_pid	= NETLINK_CB(skb).creds.pid;
-	hdr->nm_uid	= from_kuid(sk_user_ns(sk), NETLINK_CB(skb).creds.uid);
-	hdr->nm_gid	= from_kgid(sk_user_ns(sk), NETLINK_CB(skb).creds.gid);
+	hdr->nm_uid	= NETLINK_CB(skb).creds.uid;
+	hdr->nm_gid	= NETLINK_CB(skb).creds.gid;
 	netlink_frame_flush_dcache(hdr, hdr->nm_len);
 	netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
 
@@ -811,8 +812,8 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
 	hdr->nm_len	= skb->len;
 	hdr->nm_group	= NETLINK_CB(skb).dst_group;
 	hdr->nm_pid	= NETLINK_CB(skb).creds.pid;
-	hdr->nm_uid	= from_kuid(sk_user_ns(sk), NETLINK_CB(skb).creds.uid);
-	hdr->nm_gid	= from_kgid(sk_user_ns(sk), NETLINK_CB(skb).creds.gid);
+	hdr->nm_uid	= NETLINK_CB(skb).creds.uid;
+	hdr->nm_gid	= NETLINK_CB(skb).creds.gid;
 	netlink_set_status(hdr, NL_MMAP_STATUS_COPY);
 }
 
@@ -870,9 +871,27 @@ static void netlink_skb_destructor(struct sk_buff *skb)
 		sock_rfree(skb);
 }
 
-static void netlink_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
+static void netlink_add_creds(struct sk_buff *skb, struct sock *sk,
+			      struct scm_cookie *scm)
+{
+	if (scm) {
+		struct pid_namespace *pid_ns = nlk_sk(sk)->pid_ns;
+		struct user_namespace *user_ns = nlk_sk(sk)->user_ns;
+		NETLINK_CB(skb).creds.uid = from_kuid(user_ns, scm->icreds.uid);
+		NETLINK_CB(skb).creds.gid = from_kgid(user_ns, scm->icreds.gid);
+		NETLINK_CB(skb).creds.pid = pid_nr_ns(scm->icreds.pid, pid_ns);
+	} else {
+		NETLINK_CB(skb).creds.uid = 0;
+		NETLINK_CB(skb).creds.gid = 0;
+		NETLINK_CB(skb).creds.pid = 0;
+	}
+}
+
+static void netlink_skb_set_owner_r(struct sk_buff *skb, struct sock *sk,
+				    struct scm_cookie *scm)
 {
 	WARN_ON(skb->sk != NULL);
+	netlink_add_creds(skb, sk, scm);
 	skb->sk = sk;
 	skb->destructor = netlink_skb_destructor;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
@@ -905,6 +924,9 @@ static void netlink_sock_destruct(struct sock *sk)
 	}
 #endif /* CONFIG_NETLINK_MMAP */
 
+	put_pid_ns(nlk->pid_ns);
+	put_user_ns(nlk->user_ns);
+
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		printk(KERN_ERR "Freeing alive netlink socket %p\n", sk);
 		return;
@@ -1139,6 +1161,8 @@ static int __netlink_create(struct net *net, struct socket *sock,
 		mutex_init(nlk->cb_mutex);
 	}
 	init_waitqueue_head(&nlk->wait);
+	nlk->pid_ns = get_pid_ns(kern?&init_pid_ns: task_active_pid_ns(current));
+	nlk->user_ns = get_user_ns(kern?&init_user_ns: current_user_ns());
 #ifdef CONFIG_NETLINK_MMAP
 	mutex_init(&nlk->pg_vec_lock);
 #endif
@@ -1650,7 +1674,7 @@ static struct sk_buff *netlink_alloc_large_skb(unsigned int size,
  * 1: repeat lookup - reference dropped while waiting for socket memory.
  */
 int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
-		      long *timeo, struct sock *ssk)
+		      long *timeo, struct sock *ssk, struct scm_cookie *scm)
 {
 	struct netlink_sock *nlk;
 
@@ -1686,7 +1710,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		}
 		return 1;
 	}
-	netlink_skb_set_owner_r(skb, sk);
+	netlink_skb_set_owner_r(skb, sk, scm);
 	return 0;
 }
 
@@ -1749,7 +1773,7 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 }
 
 static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
-				  struct sock *ssk)
+				  struct sock *ssk, struct scm_cookie *scm)
 {
 	int ret;
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -1757,7 +1781,7 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 	ret = -ECONNREFUSED;
 	if (nlk->netlink_rcv != NULL) {
 		ret = skb->len;
-		netlink_skb_set_owner_r(skb, sk);
+		netlink_skb_set_owner_r(skb, sk, scm);
 		NETLINK_CB(skb).sk = ssk;
 		netlink_deliver_tap_kernel(sk, ssk, skb);
 		nlk->netlink_rcv(skb);
@@ -1770,7 +1794,7 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 }
 
 int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
-		    u32 portid, int nonblock)
+		    u32 portid, struct scm_cookie *scm, int nonblock)
 {
 	struct sock *sk;
 	int err;
@@ -1786,7 +1810,7 @@ retry:
 		return PTR_ERR(sk);
 	}
 	if (netlink_is_kernel(sk))
-		return netlink_unicast_kernel(sk, skb, ssk);
+		return netlink_unicast_kernel(sk, skb, ssk, scm);
 
 	if (sk_filter(sk, skb)) {
 		err = skb->len;
@@ -1795,7 +1819,7 @@ retry:
 		return err;
 	}
 
-	err = netlink_attachskb(sk, skb, &timeo, ssk);
+	err = netlink_attachskb(sk, skb, &timeo, ssk, scm);
 	if (err == 1)
 		goto retry;
 	if (err)
@@ -1891,13 +1915,14 @@ int netlink_has_listeners(struct sock *sk, unsigned int group)
 }
 EXPORT_SYMBOL_GPL(netlink_has_listeners);
 
-static int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
+static int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb,
+				     struct scm_cookie *scm)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
 	    !test_bit(NETLINK_CONGESTED, &nlk->state)) {
-		netlink_skb_set_owner_r(skb, sk);
+		netlink_skb_set_owner_r(skb, sk, scm);
 		__netlink_sendskb(sk, skb);
 		return atomic_read(&sk->sk_rmem_alloc) > (sk->sk_rcvbuf >> 1);
 	}
@@ -1907,6 +1932,7 @@ static int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
 struct netlink_broadcast_data {
 	struct sock *exclude_sk;
 	struct net *net;
+	struct scm_cookie *scm;
 	u32 portid;
 	u32 group;
 	int failure;
@@ -1965,7 +1991,7 @@ static void do_one_broadcast(struct sock *sk,
 	} else if (sk_filter(sk, p->skb2)) {
 		kfree_skb(p->skb2);
 		p->skb2 = NULL;
-	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
+	} else if ((val = netlink_broadcast_deliver(sk, p->skb2, p->scm)) < 0) {
 		netlink_overrun(sk);
 		if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
 			p->delivery_failure = 1;
@@ -1978,7 +2004,7 @@ static void do_one_broadcast(struct sock *sk,
 }
 
 int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid,
-	u32 group, gfp_t allocation,
+	u32 group, struct scm_cookie *scm, gfp_t allocation,
 	int (*filter)(struct sock *dsk, struct sk_buff *skb, void *data),
 	void *filter_data)
 {
@@ -1990,6 +2016,7 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
 
 	info.exclude_sk = ssk;
 	info.net = net;
+	info.scm = scm;
 	info.portid = portid;
 	info.group = group;
 	info.failure = 0;
@@ -2029,10 +2056,10 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
 EXPORT_SYMBOL(netlink_broadcast_filtered);
 
 int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 portid,
-		      u32 group, gfp_t allocation)
+		      u32 group, struct scm_cookie *scm, gfp_t allocation)
 {
-	return netlink_broadcast_filtered(ssk, skb, portid, group, allocation,
-		NULL, NULL);
+	return netlink_broadcast_filtered(ssk, skb, portid, group, scm,
+		allocation, NULL, NULL);
 }
 EXPORT_SYMBOL(netlink_broadcast);
 
@@ -2331,7 +2358,6 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	NETLINK_CB(skb).portid	= nlk->portid;
 	NETLINK_CB(skb).dst_group = dst_group;
-	NETLINK_CB(skb).creds	= scm.creds;
 	NETLINK_CB(skb).flags	= netlink_skb_flags;
 
 	err = -EFAULT;
@@ -2348,9 +2374,9 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	if (dst_group) {
 		atomic_inc(&skb->users);
-		netlink_broadcast(sk, skb, dst_portid, dst_group, GFP_KERNEL);
+		netlink_broadcast(sk, skb, dst_portid, dst_group, &scm, GFP_KERNEL);
 	}
-	err = netlink_unicast(sk, skb, dst_portid, msg->msg_flags&MSG_DONTWAIT);
+	err = netlink_unicast(sk, skb, dst_portid, &scm, msg->msg_flags&MSG_DONTWAIT);
 
 out:
 	scm_destroy(&scm);
@@ -2423,7 +2449,7 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		netlink_cmsg_recv_pktinfo(msg, skb);
 
 	memset(&scm, 0, sizeof(scm));
-	scm.creds = *NETLINK_CREDS(skb);
+	scm.ocreds = NETLINK_CB(skb).creds;
 	if (flags & MSG_TRUNC)
 		copied = data_skb->len;
 
@@ -2662,7 +2688,7 @@ static int netlink_dump(struct sock *sk)
 					GFP_KERNEL);
 	if (!skb)
 		goto errout_skb;
-	netlink_skb_set_owner_r(skb, sk);
+	netlink_skb_set_owner_r(skb, sk, NULL);
 
 	len = cb->dump(skb, cb);
 
@@ -2809,7 +2835,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
 	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(*nlh));
-	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
+	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, NULL, MSG_DONTWAIT);
 }
 EXPORT_SYMBOL(netlink_ack);
 
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 89008405d6b4..d34fd96c1e31 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -5,6 +5,9 @@
 #include <linux/atomic.h>
 #include <net/sock.h>
 
+struct pid_namespace;
+struct user_namespace;
+
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
 #define NLGRPLONGS(x)	(NLGRPSZ(x)/sizeof(unsigned long))
 
@@ -43,6 +46,8 @@ struct netlink_sock {
 	int			(*netlink_bind)(struct net *net, int group);
 	void			(*netlink_unbind)(struct net *net, int group);
 	struct module		*module;
+	struct pid_namespace	*pid_ns;
+	struct user_namespace	*user_ns;
 #ifdef CONFIG_NETLINK_MMAP
 	struct mutex		pg_vec_lock;
 	struct netlink_ring	rx_ring;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 941b3d26e3bf..2d0d2de8720f 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -117,6 +117,8 @@
 #include <net/checksum.h>
 #include <linux/security.h>
 #include <linux/freezer.h>
+#include <linux/pid_namespace.h>
+#include <linux/user_namespace.h>
 
 struct hlist_head unix_socket_table[2 * UNIX_HASH_SIZE];
 EXPORT_SYMBOL_GPL(unix_socket_table);
@@ -374,6 +376,8 @@ static void unix_sock_destructor(struct sock *sk)
 	if (u->addr)
 		unix_release_addr(u->addr);
 
+	put_pid_ns(u->pid_ns);
+	put_user_ns(u->user_ns);
 	atomic_long_dec(&unix_nr_socks);
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
@@ -643,6 +647,8 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 	u	  = unix_sk(sk);
 	u->path.dentry = NULL;
 	u->path.mnt = NULL;
+	u->pid_ns = get_pid_ns(kern?&init_pid_ns: task_active_pid_ns(current));
+	u->user_ns = get_user_ns(kern?&init_user_ns: current_user_ns());
 	spin_lock_init(&u->lock);
 	atomic_long_set(&u->inflight, 0);
 	INIT_LIST_HEAD(&u->link);
@@ -1354,7 +1360,6 @@ static void unix_destruct_scm(struct sk_buff *skb)
 {
 	struct scm_cookie scm;
 	memset(&scm, 0, sizeof(scm));
-	scm.pid  = UNIXCB(skb).pid;
 	if (UNIXCB(skb).fp)
 		unix_detach_fds(&scm, skb);
 
@@ -1397,22 +1402,8 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 		for (i = scm->fp->count - 1; i >= 0; i--)
 			unix_inflight(scm->fp->fp[i]);
 	}
-	return max_level;
-}
-
-static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool send_fds)
-{
-	int err = 0;
-
-	UNIXCB(skb).pid  = get_pid(scm->pid);
-	UNIXCB(skb).uid = scm->creds.uid;
-	UNIXCB(skb).gid = scm->creds.gid;
-	UNIXCB(skb).fp = NULL;
-	if (scm->fp && send_fds)
-		err = unix_attach_fds(scm, skb);
-
 	skb->destructor = unix_destruct_scm;
-	return err;
+	return max_level;
 }
 
 /*
@@ -1421,15 +1412,27 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
  * asserted SOCK_PASSCRED.
  */
 static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
-			    const struct sock *other)
-{
-	if (UNIXCB(skb).pid)
-		return;
-	if (test_bit(SOCK_PASSCRED, &sock->flags) ||
-	    !other->sk_socket ||
-	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
-		UNIXCB(skb).pid  = get_pid(task_tgid(current));
-		current_uid_gid(&UNIXCB(skb).uid, &UNIXCB(skb).gid);
+			    const struct sock *other, struct scm_cookie *scm)
+{
+	if (scm->icreds.pid) {
+		struct pid_namespace *pid_ns = unix_sk(other)->pid_ns;
+		struct user_namespace *user_ns = unix_sk(other)->user_ns;
+		UNIXCB(skb).creds.uid = from_kuid(user_ns, scm->icreds.uid);
+		UNIXCB(skb).creds.gid = from_kgid(user_ns, scm->icreds.gid);
+		UNIXCB(skb).creds.pid = pid_nr_ns(scm->icreds.pid, pid_ns);
+	}
+	else if (test_bit(SOCK_PASSCRED, &sock->flags) ||
+		 !other->sk_socket ||
+		 test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
+		struct pid_namespace *pid_ns = unix_sk(other)->pid_ns;
+		struct user_namespace *user_ns = unix_sk(other)->user_ns;
+		kuid_t uid;
+		kgid_t gid;
+
+		current_uid_gid(&uid, &gid);
+		UNIXCB(skb).creds.uid = from_kuid(user_ns, uid);
+		UNIXCB(skb).creds.gid = from_kgid(user_ns, gid);
+		UNIXCB(skb).creds.pid = pid_nr_ns(task_tgid(current),  pid_ns);
 	}
 }
 
@@ -1451,7 +1454,7 @@ static int unix_dgram_sendmsg(struct socket *sock, struct msghdr *msg,
 	struct sk_buff *skb;
 	long timeo;
 	struct scm_cookie scm;
-	int max_level;
+	int max_level = 1;
 	int data_len = 0;
 
 	wait_for_unix_gc();
@@ -1499,10 +1502,12 @@ static int unix_dgram_sendmsg(struct socket *sock, struct msghdr *msg,
 	if (skb == NULL)
 		goto out;
 
-	err = unix_scm_to_skb(&scm, skb, true);
-	if (err < 0)
-		goto out_free;
-	max_level = err + 1;
+	if (scm.fp) {
+		err = unix_attach_fds(&scm, skb);
+		if (err < 0)
+			goto out_free;
+		max_level = err + 1;
+	}
 	unix_get_secdata(&scm, skb);
 
 	skb_put(skb, len - data_len);
@@ -1591,7 +1596,7 @@ restart:
 
 	if (sock_flag(other, SOCK_RCVTSTAMP))
 		__net_timestamp(skb);
-	maybe_add_creds(skb, sock, other);
+	maybe_add_creds(skb, sock, other, &scm);
 	skb_queue_tail(&other->sk_receive_queue, skb);
 	if (max_level > unix_sk(other)->recursion_level)
 		unix_sk(other)->recursion_level = max_level;
@@ -1627,7 +1632,7 @@ static int unix_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 	int sent = 0;
 	struct scm_cookie scm;
 	bool fds_sent = false;
-	int max_level;
+	int max_level = 1;
 	int data_len;
 
 	wait_for_unix_gc();
@@ -1672,13 +1677,15 @@ static int unix_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 			goto out_err;
 
 		/* Only send the fds in the first buffer */
-		err = unix_scm_to_skb(&scm, skb, !fds_sent);
-		if (err < 0) {
-			kfree_skb(skb);
-			goto out_err;
+		if (scm.fp && !fds_sent) {
+			err = unix_attach_fds(&scm, skb);
+			if (err < 0) {
+				kfree_skb(skb);
+				goto out_err;
+			}
+			fds_sent = true;
+			max_level = err + 1;
 		}
-		max_level = err + 1;
-		fds_sent = true;
 
 		skb_put(skb, size - data_len);
 		skb->data_len = data_len;
@@ -1695,7 +1702,7 @@ static int unix_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 		    (other->sk_shutdown & RCV_SHUTDOWN))
 			goto pipe_err_free;
 
-		maybe_add_creds(skb, sock, other);
+		maybe_add_creds(skb, sock, other, &scm);
 		skb_queue_tail(&other->sk_receive_queue, skb);
 		if (max_level > unix_sk(other)->recursion_level)
 			unix_sk(other)->recursion_level = max_level;
@@ -1817,7 +1824,7 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 
 	memset(&scm, 0, sizeof(scm));
 
-	scm_set_cred(&scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+	scm.ocreds = UNIXCB(skb).creds;
 	unix_set_secdata(&scm, skb);
 
 	if (!(flags & MSG_PEEK)) {
@@ -1989,13 +1996,16 @@ again:
 
 		if (check_creds) {
 			/* Never glue messages from different writers */
-			if ((UNIXCB(skb).pid  != scm.pid) ||
-			    !uid_eq(UNIXCB(skb).uid, scm.creds.uid) ||
-			    !gid_eq(UNIXCB(skb).gid, scm.creds.gid))
+			if ((UNIXCB(skb).creds.pid == 0) ||
+			    (UNIXCB(skb).creds.pid != scm.ocreds.pid) ||
+			    (UNIXCB(skb).creds.uid == (uid_t)-1) ||
+			    (UNIXCB(skb).creds.uid != scm.ocreds.uid) ||
+			    (UNIXCB(skb).creds.gid == (gid_t)-1) ||
+			    (UNIXCB(skb).creds.gid != scm.ocreds.gid))
 				break;
 		} else if (test_bit(SOCK_PASSCRED, &sock->flags)) {
 			/* Copy credentials */
-			scm_set_cred(&scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+			scm.ocreds = UNIXCB(skb).creds;
 			check_creds = 1;
 		}
 
