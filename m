From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [held lock freed] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 15:50:10 +0100
Message-ID: <201103211550.10694.arnd@arndb.de>
References: <20110320.195156.226769634.davem@davemloft.net> <20110321125320.GA23490@elte.hu> <1300714346.2884.284.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300714346.2884.284.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 21 March 2011, Eric Dumazet wrote:
> [PATCH] ipx: fix ipx_release()
> 
> Commit b0d0d915d1d1a0 (remove the BKL) added a regression, because
> sock_put() can free memory while we are going to use it later.
> 
> Fix is to delay sock_put() after release_sock().
> 
> Reported-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

Your fix looks good, thanks Eric!

Acked-by: Arnd Bergmann <arnd@arndb.de>

I believe I made the same mistake in atalk_release and x25_release:

8<------------
net: fix atalk_release and x25_release

The recent BKL removal has introduced a use-after-free problem
in multiple network protocols. This fixes the problem in appletalk
and x25 by ensuring that we call the final sock_put() after
releasing the socket lock.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 3d4f4b0..206e771 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1051,6 +1051,7 @@ static int atalk_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
+	sock_hold(sk);
 	lock_sock(sk);
 	if (sk) {
 		sock_orphan(sk);
@@ -1058,6 +1059,8 @@ static int atalk_release(struct socket *sock)
 		atalk_destroy_socket(sk);
 	}
 	release_sock(sk);
+	sock_put(sk);
+
 	return 0;
 }
 
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 4680b1e..b2cf1db 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -669,8 +669,8 @@ static int x25_release(struct socket *sock)
 
 	sock_orphan(sk);
 out:
-	release_sock(sk);
 	sock_put(sk);
+	release_sock(sk);
 	return 0;
 }
 
