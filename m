From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 1/1] net: Fix use after free in the recvmmsg exit path
Date: Mon, 14 Mar 2016 09:56:35 -0300
Message-ID: <1457960195-4302-2-git-send-email-acme@kernel.org>
References: <1457960195-4302-1-git-send-email-acme@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54670 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965141AbcCNM4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 08:56:55 -0400
In-Reply-To: <1457960195-4302-1-git-send-email-acme@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>

The syzkaller fuzzer hit the following use-after-free:

  Call Trace:
   [<ffffffff8175ea0e>] __asan_report_load8_noabort+0x3e/0x40 mm/kasan/report.c:295
   [<ffffffff851cc31a>] __sys_recvmmsg+0x6fa/0x7f0 net/socket.c:2261
   [<     inline     >] SYSC_recvmmsg net/socket.c:2281
   [<ffffffff851cc57f>] SyS_recvmmsg+0x16f/0x180 net/socket.c:2270
   [<ffffffff86332bb6>] entry_SYSCALL_64_fastpath+0x16/0x7a
  arch/x86/entry/entry_64.S:185

And, as Dmitry rightly assessed, that is because we can drop the
reference and then touch it when the underlying recvmsg calls return
some packets and then hit an error, which will make recvmmsg to set
sock->sk->sk_err, oops, fix it.

Reported-and-Tested-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Fixes: a2e2725541fa ("net: Introduce recvmmsg socket syscall")
http://lkml.kernel.org/r/20160122211644.GC2470@redhat.com
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/socket.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index c044d1e8508c..db13ae893dce 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2240,31 +2240,31 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		cond_resched();
 	}
 
-out_put:
-	fput_light(sock->file, fput_needed);
-
 	if (err == 0)
-		return datagrams;
+		goto out_put;
 
-	if (datagrams != 0) {
+	if (datagrams == 0) {
+		datagrams = err;
+		goto out_put;
+	}
+
+	/*
+	 * We may return less entries than requested (vlen) if the
+	 * sock is non block and there aren't enough datagrams...
+	 */
+	if (err != -EAGAIN) {
 		/*
-		 * We may return less entries than requested (vlen) if the
-		 * sock is non block and there aren't enough datagrams...
+		 * ... or  if recvmsg returns an error after we
+		 * received some datagrams, where we record the
+		 * error to return on the next call or if the
+		 * app asks about it using getsockopt(SO_ERROR).
 		 */
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
+		sock->sk->sk_err = -err;
 	}
+out_put:
+	fput_light(sock->file, fput_needed);
 
-	return err;
+	return datagrams;
 }
 
 SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
-- 
2.5.0
