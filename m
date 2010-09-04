From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Sat, 04 Sep 2010 16:40:11 +0900
Message-ID: <201009040740.o847eB4f040772@www262.sakura.ne.jp>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp> <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com> <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp> <1283370450.2484.19.camel@edumazet-laptop> <201009040658.o846wxnU028775@www262.sakura.ne.jp> <1283584269.3402.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:51247 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab0IDHkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 03:40:15 -0400
In-Reply-To: <1283584269.3402.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Sorry, this wont work very well if you have many processes using
> autobind(). Some of them will loop many time before hitting
> "stop_ordernum".

I see. Then, we should use local counter rather than global counter for yield()
checking in case there are multiple threads hitting this loop.
----------------------------------------
>From 57a49c7b5a39de58d4538b85c60c758be3d2ce4f Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 4 Sep 2010 16:23:46 +0900
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
This patch adds a loop counter in order to give up after 1048576 attempts and
use the loop counter in order to count yield() interval more reliably when
there are many threads hitting this loop.

Note that currently a local user can consume 2GB of kernel memory if the user
is allowed to create and autobind 1048576 UNIX domain sockets. We should
consider adding some restriction for autobind operation.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/unix/af_unix.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4414a18..eedfe50 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -692,6 +692,7 @@ static int unix_autobind(struct socket *sock)
 	static u32 ordernum = 1;
 	struct unix_address *addr;
 	int err;
+	unsigned int retries = 0;
 
 	mutex_lock(&u->readlock);
 
@@ -717,8 +718,14 @@ retry:
 	if (__unix_find_socket_byname(net, addr->name, addr->len, sock->type,
 				      addr->hash)) {
 		spin_unlock(&unix_table_lock);
+		/* Give up if all names seems to be in use. */
+		if (retries++ == 0xFFFFF) {
+			err = -ENOMEM;
+			kfree(addr);
+			goto out;
+		}
 		/* Sanity yield. It is unusual case, but yet... */
-		if (!(ordernum&0xFF))
+		if (!(retries & 0xFF))
 			yield();
 		goto retry;
 	}
-- 
1.6.1

