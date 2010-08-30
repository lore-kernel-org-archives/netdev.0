From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Mon, 30 Aug 2010 22:27:08 +0900
Message-ID: <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
	<AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:65167 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab0H3N1L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 09:27:11 -0400
Received: from CLAMP (p3029-ipbf4202marunouchi.tokyo.ocn.ne.jp [123.224.228.29])
	by smtp.wine.ocn.ne.jp (Postfix) with ESMTP id E43B554B0
	for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 22:27:09 +0900 (JST)
In-Reply-To: <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried to create and autobind 1048576 UNIX domain sockets using
http://I-love.SAKURA.ne.jp/tmp/unixloop.asm on 2.6.18-194.11.1.el5.x86_64,
and found that it needs about 2GB of RAM. Thus, on systems where
/proc/sys/fs/file-max is larger than 1048576, a local user can create and
autobind 1048576 UNIX domain sockets in order to let applications fall into

  while (1)
  	yield();

loop. Below is the patch (only compile tested) to avoid falling into this loop.
Is there any reason a name has to be '\0' + 5 letters?
Shoud I give up after checking 1048576 names rather than after checking
4294967296 names?
----------------------------------------
 From 703b0677bf03afda19665f05fae4850ecf88afe3 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 30 Aug 2010 22:07:13 +0900
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

This patch changes unix_autobind() to check 4294967296 names and also give up
unix_autobind() if all names are in use.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/unix/af_unix.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4414a18..1271e98 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -692,6 +692,7 @@ static int unix_autobind(struct socket *sock)
 	static u32 ordernum = 1;
 	struct unix_address *addr;
 	int err;
+	u32 loop = 0;
 
 	mutex_lock(&u->readlock);
 
@@ -700,7 +701,7 @@ static int unix_autobind(struct socket *sock)
 		goto out;
 
 	err = -ENOMEM;
-	addr = kzalloc(sizeof(*addr) + sizeof(short) + 16, GFP_KERNEL);
+	addr = kzalloc(sizeof(*addr) + sizeof(short) + 19, GFP_KERNEL);
 	if (!addr)
 		goto out;
 
@@ -708,11 +709,11 @@ static int unix_autobind(struct socket *sock)
 	atomic_set(&addr->refcnt, 1);
 
 retry:
-	addr->len = sprintf(addr->name->sun_path+1, "%05x", ordernum) + 1 + sizeof(short);
+	addr->len = sprintf(addr->name->sun_path+1, "%08x", ordernum) + 1 + sizeof(short);
 	addr->hash = unix_hash_fold(csum_partial(addr->name, addr->len, 0));
 
 	spin_lock(&unix_table_lock);
-	ordernum = (ordernum+1)&0xFFFFF;
+	ordernum++;
 
 	if (__unix_find_socket_byname(net, addr->name, addr->len, sock->type,
 				      addr->hash)) {
@@ -720,6 +721,12 @@ retry:
 		/* Sanity yield. It is unusual case, but yet... */
 		if (!(ordernum&0xFF))
 			yield();
+		/* Give up if all names are in use. */
+		if (unlikely(!++loop)) {
+			err = -EAGAIN;
+			kfree(addr);
+			goto out;
+		}
 		goto retry;
 	}
 	addr->hash ^= sk->sk_type;
-- 
1.6.1
