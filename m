From: David Miller <davem@davemloft.net>
Subject: Re: appletalk oops.
Date: Thu, 31 Mar 2011 18:58:23 -0700 (PDT)
Message-ID: <20110331.185823.232755679.davem@davemloft.net>
References: <20110331200525.GA17516@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55168
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752464Ab1DAB7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 21:59:02 -0400
In-Reply-To: <20110331200525.GA17516@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Thu, 31 Mar 2011 16:05:26 -0400

> Just hit this on current git head while fuzzing syscalls.
> I suspect we need to check somewhere for null sock's being passed in from userspace
> I'm not sure yet this is appletalk specific, or it belongs somewhere further up
> in accept.

Turns out atalk_release() is completely awesome after the
lock_kernel() conversion.

It grabs a reference to a socket, then checks if that socket is NULL,
right afterwards!

And this NULL socket case is exactly what happens if you try to do an
accept() on an Appletalk socket, since it hooks up sock_no_accept().

This is the second regression in this function due to commit
60d9f461a20ba59219fdcdc30cbf8e3a4ad3f625 ("appletalk: remove the
BKL"):

--------------------
appletalk: Fix OOPS in atalk_release().

Commit 60d9f461a20ba59219fdcdc30cbf8e3a4ad3f625 ("appletalk: remove
the BKL") added a dereference of "sk" before checking for NULL in
atalk_release().

Guard the code block completely, rather than partially, with the
NULL check.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 206e771..956a530 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1051,16 +1051,17 @@ static int atalk_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	sock_hold(sk);
-	lock_sock(sk);
 	if (sk) {
+		sock_hold(sk);
+		lock_sock(sk);
+
 		sock_orphan(sk);
 		sock->sk = NULL;
 		atalk_destroy_socket(sk);
-	}
-	release_sock(sk);
-	sock_put(sk);
 
+		release_sock(sk);
+		sock_put(sk);
+	}
 	return 0;
 }
 
