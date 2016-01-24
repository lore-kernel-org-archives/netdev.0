From: Willy Tarreau <w@1wt.eu>
Subject: Re: Mis-backport in af_unix patch for Linux 3.10.95
Date: Sun, 24 Jan 2016 09:31:42 +0100
Message-ID: <20160124083142.GA14045@1wt.eu>
References: <CAJLwaKa3vMzRnTt+JL7msQ33HZk_Jp+xMjOteBYCad46u15hKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Cc: stable@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Sultan Qasim <sultanqasim@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJLwaKa3vMzRnTt+JL7msQ33HZk_Jp+xMjOteBYCad46u15hKg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

On Sun, Jan 24, 2016 at 12:10:35AM -0500, Sultan Qasim wrote:
> Hello all,
> 
> I'm an outsider to the Linux kernel community, so I apologize if this
> is not the right channel to mention this.

The simple fact that you participate, inspect the code and report bugs
makes you part of this community :-)  It's indeed the right place.
Usually when reporting an issue with a commit, we also CC the whole
signed-off-by / CC chain of that commit (which I'm doing now). For
bugs related to networking, we usually CC the netdev list as well.

> I noticed that the
> backported version of the patch "af_unix: Revert 'lock_interruptible'
> in stream receive code" in Linux 3.10.95 seems to have removed the
> mutex_lock_interruptible from the wrong function.
>
> Here is the backported patch:
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=3a57e783016bf43ab9326172217f564941b85b17
> 
> Here is the original:
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/net/unix/af_unix.c?id=3822b5c2fc62e3de8a0f33806ff279fb7df92432
> 
> Was it not meant to be removed from unix_stream_recvmsg instead of
> unix_dgram_recvmsg?

You're absolutely right, good catch! Similar controls were added to
both functions resulting in the same code appearing there, which
confused the patch process, causing the change to be applied to the
wrong location. This happens from time to time in such circumstances
when backporting to older kernels.

> Also, the variable called "noblock" needs to be
> removed from the function being changed to prevent unused variable
> warnings.

If you mean this variable in function unix_dgram_recvmsg(), it would
indeed report a warning but only due to the patch being mis-applied.
In unix_stream_recvmsg(), it's still used as well.

Does the attached patch seem better to you (not compile-tested) ?

Greg/Ben, both 3.2.76 and 3.14.59 are OK regarding this, it seems
like only 3.10.95 was affected.

Thanks,
Willy


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-af_unix-fix-incorrect-revert-of-lock_interruptible-i.patch"

>From 77f6e82adf349cbccf7e2ec7601b25c994e0b483 Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Sun, 24 Jan 2016 09:19:57 +0100
Subject: af_unix: fix incorrect revert of 'lock_interruptible' in stream
 receive code

As reported by Sultan Qasim, commit 3822b5c ("af_unix: Revert
'lock_interruptible' in stream receive code") was accidently applied
at the wrong place in the backport that appeared in 3.10.95, it
affected unix_dgram_recvmsg() instead of unix_stream_recvmsg() due
to now similar code sections there. The dgram part needs to remain
but the stream part needs to be removed.

Reported-By: Sultan Qasim <sultanqasim@gmail.com>
Fixes: 3a57e78 (3.10.95)
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 net/unix/af_unix.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f934e7b..0061d00 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1934,7 +1934,14 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (flags&MSG_OOB)
 		goto out;
 
-	mutex_lock(&u->readlock);
+	err = mutex_lock_interruptible(&u->readlock);
+	if (unlikely(err)) {
+		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
+		 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
+		 */
+		err = noblock ? -EAGAIN : -ERESTARTSYS;
+		goto out;
+	}
 
 	skip = sk_peek_offset(sk, flags);
 
@@ -2083,14 +2090,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 
-	err = mutex_lock_interruptible(&u->readlock);
-	if (unlikely(err)) {
-		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
-		 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
-		 */
-		err = noblock ? -EAGAIN : -ERESTARTSYS;
-		goto out;
-	}
+	mutex_lock(&u->readlock);
 
 	do {
 		int chunk;
-- 
1.7.12.2.21.g234cd45.dirty


--9jxsPFA5p3P2qPhR--
