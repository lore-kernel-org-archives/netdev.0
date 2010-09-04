From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Sat, 04 Sep 2010 15:58:59 +0900
Message-ID: <201009040658.o846wxnU028775@www262.sakura.ne.jp>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp> <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com> <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp> <1283370450.2484.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:65477 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750Ab0IDG7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 02:59:03 -0400
In-Reply-To: <1283370450.2484.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From a67ccbb8033993df29f26bde9944e37bffe4fc1b Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 4 Sep 2010 15:22:22 +0900
Subject: [PATCH] UNIX: Do not loop forever at unix_autobind().

We assumed that unix_autobind() never fails if kzalloc() succeeded.
But unix_autobind() allows only 1048576 names. If /proc/sys/fs/file-max is
larger than 1048576 (e.g. systems with more than 10GB of RAM), a local user can
consume all names using fork()/socket()/bind().

If all names are in use, those who call bind() with addr_len == sizeof(short)
or connect()/sendmsg() with setsockopt(SO_PASSCRED) will continue

  while (1)
  	yield();

loop at unix_autobind() till a name becomes available.
This patch changes unix_autobind() to fail if all names are in use.

Note that currently a local user can consume 2GB of kernel memory if the user
is allowed to create and autobind 1048576 UNIX domain sockets. We should
consider adding some restriction for autobind operation.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/unix/af_unix.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4414a18..46fc6b2 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -692,6 +692,7 @@ static int unix_autobind(struct socket *sock)
 	static u32 ordernum = 1;
 	struct unix_address *addr;
 	int err;
+	u32 stop_ordernum;
 
 	mutex_lock(&u->readlock);
 
@@ -706,6 +707,7 @@ static int unix_autobind(struct socket *sock)
 
 	addr->name->sun_family = AF_UNIX;
 	atomic_set(&addr->refcnt, 1);
+	stop_ordernum = ordernum;
 
 retry:
 	addr->len = sprintf(addr->name->sun_path+1, "%05x", ordernum) + 1 + sizeof(short);
@@ -720,6 +722,12 @@ retry:
 		/* Sanity yield. It is unusual case, but yet... */
 		if (!(ordernum&0xFF))
 			yield();
+		/* Give up if all names are in use. */
+		if (ordernum == stop_ordernum) {
+			err = -ENOMEM;
+			kfree(addr);
+			goto out;
+		}
 		goto retry;
 	}
 	addr->hash ^= sk->sk_type;
-- 
1.6.1

