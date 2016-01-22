From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: net: use-after-free in recvmmsg
Date: Fri, 22 Jan 2016 19:16:44 -0200
Message-ID: <20160122211644.GC2470@redhat.com>
References: <CACT4Y+YUobBGeFiq5d-==TBB7F2am+wjH6CKVz0uCvw4KuM1dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>, acme@kernel.org
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+YUobBGeFiq5d-==TBB7F2am+wjH6CKVz0uCvw4KuM1dg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Fri, Jan 22, 2016 at 09:39:53PM +0100, Dmitry Vyukov escreveu:
> While running syzkaller fuzzer I've hit the following use-after-free:

<SNIP>
 
> Call Trace:
>  [<ffffffff8175ea0e>] __asan_report_load8_noabort+0x3e/0x40
> mm/kasan/report.c:295
>  [<ffffffff851cc31a>] __sys_recvmmsg+0x6fa/0x7f0 net/socket.c:2261
>  [<     inline     >] SYSC_recvmmsg net/socket.c:2281
>  [<ffffffff851cc57f>] SyS_recvmmsg+0x16f/0x180 net/socket.c:2270
>  [<ffffffff86332bb6>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185
> ==================================================================
> 
> I cannot reproduce it, but looking at __sys_recvmmsg code, it seems
> that sock is not necessary live after fput_light:
> 
> out_put:
>     fput_light(sock->file, fput_needed);
> 
>     if (err == 0)
>         return datagrams;
> 
>     if (datagrams != 0) {
>         /*
>          * We may return less entries than requested (vlen) if the
>          * sock is non block and there aren't enough datagrams...
>          */
>         if (err != -EAGAIN) {
>             /*
>              * ... or  if recvmsg returns an error after we
>              * received some datagrams, where we record the
>              * error to return on the next call or if the
>              * app asks about it using getsockopt(SO_ERROR).
>              */
>             sock->sk->sk_err = -err;
>         }
> 
>         return datagrams;
>     }
> 
>     return err;
> }
> 
> I am on commit 30f05309bde49295e02e45c7e615f73aa4e0ccc2 (Jan 20).
> Seems to be added in commit a2e2725541fad72416326798c2d7fa4dafb7d337
> (Oct 2009).

Maybe this helps? Compile testing now...


diff --git a/net/socket.c b/net/socket.c
index 91c2de6f5020..03e57ad7ec9f 100644
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
