From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 03:27:42 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411180305060.3192-100000@thoron.boston.redhat.com>
References: <Xine.LNX.4.44.0411180257300.3144-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>,
	lkml <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261781AbUKRI15@vger.kernel.org>
To: Ross Kendall Axe <ross.axe@blueyonder.co.uk>
In-Reply-To: <Xine.LNX.4.44.0411180257300.3144-100000@thoron.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's a fix for the SELinux related problem.

What's happening is that mixing stream and dgram ops for SEQPACKET is
having some unfortunate side effects.

One of these is that there is a race between client sendmsg() and server
accept().  The server child socket is attached via sock_graft() after the 
client has entered unix_dgram_sendmsg() and called 

	security_unix_may_send(sk->sk_socket, other->sk_socket);

other->sk_socket will thus be null, causing the oops in SELinux and any 
other LSM which tries to dereference the pointer.

The fix is a combination of some of Ross's ideas:

1) SOCK_SEQPACKET is connection oriented, and there no need to call 
security_unix_may_send() for each packet.  security_unix_stream_connect() 
is sufficient.

2) Ensure that unix_dgram_sendmsg() fails for SOCK_SEQPACKET sockets which
are not connected, otherwise someone could bypass LSM by sending on an
unconnected socket.

Note that this only solves the problem for the LSM hook.

Patch below, please review.

The other issue discussed -- server goes into a hard loop (and/or various
lock/refcount related bugs) when the client sends a message via sendto()
with an address supplied -- needs to be resolved separately.

---

 net/unix/af_unix.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff -purN -X dontdiff linux-2.6.10-rc2.o/net/unix/af_unix.c linux-2.6.10-rc2.w/net/unix/af_unix.c
--- linux-2.6.10-rc2.o/net/unix/af_unix.c	2004-11-15 13:18:56.000000000 -0500
+++ linux-2.6.10-rc2.w/net/unix/af_unix.c	2004-11-18 02:54:03.283777544 -0500
@@ -1261,6 +1261,9 @@ static int unix_dgram_sendmsg(struct kio
 	long timeo;
 	struct scm_cookie tmp_scm;
 
+	if (sk->sk_type == SOCK_SEQPACKET && sk->sk_state != TCP_ESTABLISHED)
+		return -ENOTCONN;
+
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
 	err = scm_send(sock, msg, siocb->scm);
@@ -1354,9 +1357,11 @@ restart:
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
