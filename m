From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/8] af_unix: Allow SO_PEERCRED to work across namespaces.
Date: Sun, 13 Jun 2010 06:30:14 -0700
Message-ID: <m1r5kbgivt.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38378 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab0FMNaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 09:30:19 -0400
In-Reply-To: <m1hbl7hxo3.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 13 Jun 2010 06\:25\:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use struct pid and struct cred to store the peer credentials on struct
sock.  This gives enough information to convert the peer credential
information to a value relative to whatever namespace the socket is in
at the time.

This removes nasty surprises when using SO_PEERCRED on socket
connetions where the processes on either side are in different pid and
user namespaces.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/sock.h |    3 ++-
 net/core/sock.c    |   18 ++++++++++++------
 net/unix/af_unix.c |   37 ++++++++++++++++++++++++++++---------
 3 files changed, 42 insertions(+), 16 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 56df440..5b1eb7d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -290,7 +290,8 @@ struct sock {
 	unsigned short		sk_ack_backlog;
 	unsigned short		sk_max_ack_backlog;
 	__u32			sk_priority;
-	struct ucred		sk_peercred;
+	struct pid		*sk_peer_pid;
+	const struct cred	*sk_peer_cred;
 	long			sk_rcvtimeo;
 	long			sk_sndtimeo;
 	struct sk_filter      	*sk_filter;
diff --git a/net/core/sock.c b/net/core/sock.c
index 9e229d8..9d197a6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -900,11 +900,15 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_PEERCRED:
-		if (len > sizeof(sk->sk_peercred))
-			len = sizeof(sk->sk_peercred);
-		if (copy_to_user(optval, &sk->sk_peercred, len))
+	{
+		struct ucred peercred;
+		if (len > sizeof(peercred))
+			len = sizeof(peercred);
+		cred_to_ucred(sk->sk_peer_pid, sk->sk_peer_cred, &peercred);
+		if (copy_to_user(optval, &peercred, len))
 			return -EFAULT;
 		goto lenout;
+	}
 
 	case SO_PEERNAME:
 	{
@@ -1105,6 +1109,9 @@ static void __sk_free(struct sock *sk)
 		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
 		       __func__, atomic_read(&sk->sk_omem_alloc));
 
+	if (sk->sk_peer_cred)
+		put_cred(sk->sk_peer_cred);
+	put_pid(sk->sk_peer_pid);
 	put_net(sock_net(sk));
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
@@ -1927,9 +1934,8 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_sndmsg_page	=	NULL;
 	sk->sk_sndmsg_off	=	0;
 
-	sk->sk_peercred.pid 	=	0;
-	sk->sk_peercred.uid	=	-1;
-	sk->sk_peercred.gid	=	-1;
+	sk->sk_peer_pid 	=	NULL;
+	sk->sk_peer_cred	=	NULL;
 	sk->sk_write_pending	=	0;
 	sk->sk_rcvlowat		=	1;
 	sk->sk_rcvtimeo		=	MAX_SCHEDULE_TIMEOUT;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3d9122e..028fa25 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -449,11 +449,31 @@ static int unix_release_sock(struct sock *sk, int embrion)
 	return 0;
 }
 
+static void init_peercred(struct sock *sk)
+{
+	put_pid(sk->sk_peer_pid);
+	if (sk->sk_peer_cred)
+		put_cred(sk->sk_peer_cred);
+	sk->sk_peer_pid  = get_pid(task_tgid(current));
+	sk->sk_peer_cred = get_current_cred();
+}
+
+static void copy_peercred(struct sock *sk, struct sock *peersk)
+{
+	put_pid(sk->sk_peer_pid);
+	if (sk->sk_peer_cred)
+		put_cred(sk->sk_peer_cred);
+	sk->sk_peer_pid  = get_pid(peersk->sk_peer_pid);
+	sk->sk_peer_cred = get_cred(peersk->sk_peer_cred);
+}
+
 static int unix_listen(struct socket *sock, int backlog)
 {
 	int err;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
+	struct pid *old_pid = NULL;
+	const struct cred *old_cred = NULL;
 
 	err = -EOPNOTSUPP;
 	if (sock->type != SOCK_STREAM && sock->type != SOCK_SEQPACKET)
@@ -469,12 +489,14 @@ static int unix_listen(struct socket *sock, int backlog)
 	sk->sk_max_ack_backlog	= backlog;
 	sk->sk_state		= TCP_LISTEN;
 	/* set credentials so connect can copy them */
-	sk->sk_peercred.pid	= task_tgid_vnr(current);
-	current_euid_egid(&sk->sk_peercred.uid, &sk->sk_peercred.gid);
+	init_peercred(sk);
 	err = 0;
 
 out_unlock:
 	unix_state_unlock(sk);
+	put_pid(old_pid);
+	if (old_cred)
+		put_cred(old_cred);
 out:
 	return err;
 }
@@ -1139,8 +1161,7 @@ restart:
 	unix_peer(newsk)	= sk;
 	newsk->sk_state		= TCP_ESTABLISHED;
 	newsk->sk_type		= sk->sk_type;
-	newsk->sk_peercred.pid	= task_tgid_vnr(current);
-	current_euid_egid(&newsk->sk_peercred.uid, &newsk->sk_peercred.gid);
+	init_peercred(newsk);
 	newu = unix_sk(newsk);
 	newsk->sk_sleep		= &newu->peer_wait;
 	otheru = unix_sk(other);
@@ -1156,7 +1177,7 @@ restart:
 	}
 
 	/* Set credentials */
-	sk->sk_peercred = other->sk_peercred;
+	copy_peercred(sk, other);
 
 	sock->state	= SS_CONNECTED;
 	sk->sk_state	= TCP_ESTABLISHED;
@@ -1198,10 +1219,8 @@ static int unix_socketpair(struct socket *socka, struct socket *sockb)
 	sock_hold(skb);
 	unix_peer(ska) = skb;
 	unix_peer(skb) = ska;
-	ska->sk_peercred.pid = skb->sk_peercred.pid = task_tgid_vnr(current);
-	current_euid_egid(&skb->sk_peercred.uid, &skb->sk_peercred.gid);
-	ska->sk_peercred.uid = skb->sk_peercred.uid;
-	ska->sk_peercred.gid = skb->sk_peercred.gid;
+	init_peercred(ska);
+	init_peercred(skb);
 
 	if (ska->sk_type != SOCK_DGRAM) {
 		ska->sk_state = TCP_ESTABLISHED;
-- 
1.6.5.2.143.g8cc62

