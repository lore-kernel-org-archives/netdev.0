From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH/RFC] net: Don't save mid batch datagram processing error for
 next recvmmsg call
Date: Mon, 21 Jul 2014 16:30:42 -0300
Message-ID: <20140721193042.GA20303@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Content-Transfer-Encoding: 8bit
Cc: Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Friesen <chris.friesen@windriver.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	=?utf-8?B?T25kxZllaiBCw61sa2E=?= <neleai@seznam.cz>,
	Paul Moore <paul@paul-moore.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>,
	Steven Whitehouse <steve@chygwyn.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:39173 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933495AbaGUTaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 15:30:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

	I think this addresses the problems reported by David Laight and
others, where errors saved on a per socket area could be delivered to a
different thread, so I just followed David Laight's suggestion and
stopped saving it, we'll return it only if it happens for the first
datagram, else we return less entries than asked for.

	Steven, IIRC you was the one that suggested using this
mechanism, no? Do you have anything against this move?

- Arnaldo


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="0002-net-Don-t-save-mid-batch-datagram-processing-error-f.patch"
Content-Transfer-Encoding: 8bit

>From 5cf1a5c682c8bb0add9adfb5167a63f269136523 Mon Sep 17 00:00:00 2001
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 21 Jul 2014 12:39:56 -0300
Subject: [PATCH 2/2] net: Don't save mid batch datagram processing error for
 next recvmmsg call
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

When the call to the underlying per protocol recvmsg fails for some
reason and we already have successfully processed at least one datagram
in the batch, we were saving the error for the next recvmmsg (or
recvmsg) call, so the user would eventually get notified of what
happened.

This was found to be fraught with problems, as, for instance, errors
could be notified for a different thread than a faulty one providing
invalid buffers.

So just return the number of datagrams successfully received.

Reported-by: David Laight <David.Laight@ACULAB.COM>
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>
Cc: Chris Friesen <chris.friesen@windriver.com>
Cc: David Laight <David.Laight@ACULAB.COM>
Cc: Elie De Brauwer <eliedebrauwer@gmail.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Ondřej Bílka <neleai@seznam.cz>
Cc: Paul Moore <paul@paul-moore.com>
Cc: Rémi Denis-Courmont <remi@remlab.net>
Cc: Steven Whitehouse <steve@chygwyn.com>
Link: http://lkml.kernel.org/n/net-next-yfgcm0gwo7un6eqf89xw47lo@git.kernel.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/socket.c | 29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 310a50971769..b6836c5fd201 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2436,28 +2436,13 @@ out_put:
 		timeout->tv_nsec = (timeout_hz % HZ) * (NSEC_PER_SEC / HZ);
 	}
 
-	if (err == 0)
-		return datagrams;
-
-	if (datagrams != 0) {
-		/*
-		 * We may return less entries than requested (vlen) if the
-		 * sock is non block and there aren't enough datagrams...
-		 */
-		if (err != -EAGAIN) {
-			/*
-			 * ... or  if recvmsg returns an error after we
-			 * received some datagrams, where we record the
-			 * error to return on the next call or if the
-			 * app asks about it using getsockopt(SO_ERROR).
-			 */
-			sock->sk->sk_err = -err;
-		}
-
-		return datagrams;
-	}
-
-	return err;
+	/*
+	 * We may return less entries than requested (vlen) if the
+	 * sock is non block and there aren't enough datagrams or
+	 * if some problem happened after successfully receiving one
+	 * datagram.
+	 */
+	return datagrams ?: err;
 }
 
 SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
-- 
1.9.3


--y0ulUmNC+osPPQO6--
