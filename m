From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Sat, 04 Sep 2010 18:31:54 +0900
Message-ID: <201009040931.o849VstI061086@www262.sakura.ne.jp>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp> <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com> <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp> <1283370450.2484.19.camel@edumazet-laptop> <201009040658.o846wxnU028775@www262.sakura.ne.jp> <1283584269.3402.9.camel@edumazet-laptop> <201009040740.o847eB4f040772@www262.sakura.ne.jp> <1283588647.3402.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:57680 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab0IDJb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 05:31:57 -0400
In-Reply-To: <1283588647.3402.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Quite frankly, given __unix_find_socket_byname() can take quite a long
> time with one million entries in table, we should just remove
> 
> if (whatever)
> 	yield();
> 
> and use a more friendly :
> 
> cond_resched();
> 
I see. What about this one?
----------------------------------------
>From 5c11dcc7dd5063584bc3fbdb059ecdaf12aa38ce Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 4 Sep 2010 18:02:26 +0900
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
This patch adds a loop counter in order to give up after 1048576 attempts.

Calling yield() for once per 256 attempts may not be sufficient when many names
are already in use, for __unix_find_socket_byname() can take long time under
such circumstance. Therefore, this patch also adds cond_resched() call.

Note that currently a local user can consume 2GB of kernel memory if the user
is allowed to create and autobind 1048576 UNIX domain sockets. We should
consider adding some restriction for autobind operation.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/unix/af_unix.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4414a18..1ef37ca 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -692,6 +692,7 @@ static int unix_autobind(struct socket *sock)
 	static u32 ordernum = 1;
 	struct unix_address *addr;
 	int err;
+	unsigned int retries = 0;
 
 	mutex_lock(&u->readlock);
 
@@ -717,9 +718,17 @@ retry:
 	if (__unix_find_socket_byname(net, addr->name, addr->len, sock->type,
 				      addr->hash)) {
 		spin_unlock(&unix_table_lock);
-		/* Sanity yield. It is unusual case, but yet... */
-		if (!(ordernum&0xFF))
-			yield();
+		/*
+		 * __unix_find_socket_byname() may take long time if many names
+		 * are already in use.
+		 */
+		cond_resched();
+		/* Give up if all names seems to be in use. */
+		if (retries++ == 0xFFFFF) {
+			err = -ENOMEM;
+			kfree(addr);
+			goto out;
+		}
 		goto retry;
 	}
 	addr->hash ^= sk->sk_type;
-- 
1.6.1

