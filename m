From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 12:25:21 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411181219590.5236-100000@thoron.boston.redhat.com>
References: <Xine.LNX.4.44.0411181158110.5096-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, <netdev@oss.sgi.com>,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <Xine.LNX.4.44.0411181158110.5096-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Updated patch below (with Chris Wright's wrapper idea).

This now fixes both issues.

1) Don't call security_unix_may_send() hook during sendmsg() for 
SOCK_SEQPACKET, and ensure that sendmsg() can only be called on a 
connected socket so as not to bypass the security_unix_stream_connect() 
hook.

2) Return -EINVAL if sendto() is called on SOCK_SEQPACKET with an address 
supplied.

Please review and apply if ok.


Signed-off-by: James Morris <jmorris@redhat.com>

---

 net/unix/af_unix.c |   26 ++++++++++++++++++++++----
 1 files changed, 22 insertions(+), 4 deletions(-)

diff -purN -X dontdiff linux-2.6.10-rc2.o/net/unix/af_unix.c linux-2.6.10-rc2.w2/net/unix/af_unix.c
--- linux-2.6.10-rc2.o/net/unix/af_unix.c	2004-11-15 13:18:56.000000000 -0500
+++ linux-2.6.10-rc2.w2/net/unix/af_unix.c	2004-11-18 12:09:44.255462368 -0500
@@ -466,6 +466,8 @@ static int unix_dgram_recvmsg(struct kio
 			      struct msghdr *, size_t, int);
 static int unix_dgram_connect(struct socket *, struct sockaddr *,
 			      int, int);
+static int unix_seqpacket_sendmsg(struct kiocb *, struct socket *,
+				  struct msghdr *, size_t);
 
 static struct proto_ops unix_stream_ops = {
 	.family =	PF_UNIX,
@@ -524,7 +526,7 @@ static struct proto_ops unix_seqpacket_o
 	.shutdown =	unix_shutdown,
 	.setsockopt =	sock_no_setsockopt,
 	.getsockopt =	sock_no_getsockopt,
-	.sendmsg =	unix_dgram_sendmsg,
+	.sendmsg =	unix_seqpacket_sendmsg,
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
@@ -1354,9 +1356,11 @@ restart:
 	if (other->sk_shutdown & RCV_SHUTDOWN)
 		goto out_unlock;
 
-	err = security_unix_may_send(sk->sk_socket, other->sk_socket);
-	if (err)
-		goto out_unlock;
+	if (sk->sk_type != SOCK_SEQPACKET) {
+		err = security_unix_may_send(sk->sk_socket, other->sk_socket);
+		if (err)
+			goto out_unlock;
+	}
 
 	if (unix_peer(other) != sk &&
 	    (skb_queue_len(&other->sk_receive_queue) >
@@ -1506,6 +1510,20 @@ out_err:
 	return sent ? : err;
 }
 
+static int unix_seqpacket_sendmsg(struct kiocb *kiocb, struct socket *sock,
+				  struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	
+	if (sk->sk_state != TCP_ESTABLISHED)
+		return -ENOTCONN;
+
+	if (msg->msg_name || msg->msg_namelen)
+		return -EINVAL;
+
+	return unix_dgram_sendmsg(kiocb, sock, msg, len);
+}
+                                                                                            
 static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
 {
 	struct unix_sock *u = unix_sk(sk);
