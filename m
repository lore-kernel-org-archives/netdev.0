From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Fri, 19 Nov 2004 11:24:03 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411191122470.10340-100000@thoron.boston.redhat.com>
References: <1100864358.8127.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, <netdev@oss.sgi.com>,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1100864358.8127.5.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Nov 2004, Alan Cox wrote:

> Looks right to me, the ECONNRESET is no longer being lost.

Ok, here is a relative patch for Dave.

Please apply.

Signed-off-by: James Morris <jmorris@redhat.com>

---

diff -purN -X dontdiff linux-2.6.10-rc2.w2/net/unix/af_unix.c linux-2.6.10-rc2.w3/net/unix/af_unix.c
--- linux-2.6.10-rc2.w2/net/unix/af_unix.c	2004-11-18 12:09:44.000000000 -0500
+++ linux-2.6.10-rc2.w3/net/unix/af_unix.c	2004-11-18 21:54:12.000000000 -0500
@@ -1513,13 +1513,18 @@ out_err:
 static int unix_seqpacket_sendmsg(struct kiocb *kiocb, struct socket *sock,
 				  struct msghdr *msg, size_t len)
 {
+	int err;
 	struct sock *sk = sock->sk;
 	
+	err = sock_error(sk);
+	if (err)
+		return err;
+
 	if (sk->sk_state != TCP_ESTABLISHED)
 		return -ENOTCONN;
 
-	if (msg->msg_name || msg->msg_namelen)
-		return -EINVAL;
+	if (msg->msg_namelen)
+		msg->msg_namelen = 0;
 
 	return unix_dgram_sendmsg(kiocb, sock, msg, len);
 }
