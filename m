From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 1/3] net: sendmmsg should only return an error if no messages were sent
Date: Fri, 05 Aug 2011 10:07:38 +1000
Message-ID: <20110805000822.240895823@samba.org>
References: <20110805000737.743684961@samba.org>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp, davem@davemloft.net,
	eparis@parisplace.org, casey@schaufler-ca.com, mjt@tls.msk.ru
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline; filename=sendmmsg_errno
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sendmmsg uses a similar error return strategy as recvmmsg but it
turns out to be a confusing way to communicate errors.

The current code stores the error code away and returns it on the next
sendmmsg call. This means a call with completely valid arguments could
get an error from a previous call.

Change things so we only return an error if no datagrams could be sent.
If less than the requested number of messages were sent, the application
must retry starting at the first failed one and if the problem is
persistent the error will be returned.

This matches the behaviour of other syscalls like read/write - it
is not an error if less than the requested number of elements are sent.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: stable <stable@kernel.org> [3.0+]
---

Index: linux-net/net/socket.c
===================================================================
--- linux-net.orig/net/socket.c	2011-08-04 20:37:53.959996025 +1000
+++ linux-net/net/socket.c	2011-08-05 09:31:11.724704078 +1000
@@ -2005,12 +2005,9 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	if (!sock)
 		return err;
 
-	err = sock_error(sock->sk);
-	if (err)
-		goto out_put;
-
 	entry = mmsg;
 	compat_entry = (struct compat_mmsghdr __user *)mmsg;
+	err = 0;
 
 	while (datagrams < vlen) {
 		/*
@@ -2037,29 +2034,11 @@ int __sys_sendmmsg(int fd, struct mmsghd
 		++datagrams;
 	}
 
-out_put:
 	fput_light(sock->file, fput_needed);
 
-	if (err == 0)
-		return datagrams;
-
-	if (datagrams != 0) {
-		/*
-		 * We may send less entries than requested (vlen) if the
-		 * sock is non blocking...
-		 */
-		if (err != -EAGAIN) {
-			/*
-			 * ... or if sendmsg returns an error after we
-			 * send some datagrams, where we record the
-			 * error to return on the next call or if the
-			 * app asks about it using getsockopt(SO_ERROR).
-			 */
-			sock->sk->sk_err = -err;
-		}
-
+	/* We only return an error if no datagrams were able to be sent */
+	if (datagrams != 0)
 		return datagrams;
-	}
 
 	return err;
 }


