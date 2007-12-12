From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] Convert the semaphore to a mutex in
 net/tipc/socket.c
Date: Tue, 11 Dec 2007 16:44:45 -0800
Message-ID: <20071211164445.752431ec.akpm@linux-foundation.org>
References: <20071210011741.039692330@gmail.com>
	<20071210011800.543055487@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com,
	tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, kjwinchester@gmail.com,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Kevin Winchester <kjwinchester@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36972 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751752AbXLLApP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 19:45:15 -0500
In-Reply-To: <20071210011800.543055487@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 09 Dec 2007 21:17:42 -0400
Kevin Winchester <kjwinchester@gmail.com> wrote:

> Note also that in the release method, down_interruptible() was being called
> without checking the return value.  I converted it to mutex_lock_interruptible()
> and made the interrupted case return -ERESTARTSYS, as was done for all other
> calls to down_interruptible() in the file.

That's an outright bug.

static int release(struct socket *sock)
{
	struct tipc_sock *tsock = tipc_sk(sock->sk);
	struct sock *sk = sock->sk;
	int res = TIPC_OK;
	struct sk_buff *buf;

	dbg("sock_delete: %x\n",tsock);
	if (!tsock)
		return 0;
	down_interruptible(&tsock->sem);
	if (!sock->sk) {
		up(&tsock->sem);
		return 0;
	}

	...

	up(&tsock->sem);

	...	
}

So if the calling process has signal_pending(), down_interruptible() will
return without having downed the semaphore and then we merrily proceed to
do up() on it, so a subsequent down() won't actually take the lock and
things will deteriorate from there.

So I'd propose this:

--- a/net/tipc/socket.c~a
+++ a/net/tipc/socket.c
@@ -253,7 +253,7 @@ static int release(struct socket *sock)
 	dbg("sock_delete: %x\n",tsock);
 	if (!tsock)
 		return 0;
-	down_interruptible(&tsock->sem);
+	down(&tsock->sem);
 	if (!sock->sk) {
 		up(&tsock->sem);
 		return 0;
_

as a for-2.6.24 bugfix.  And for 2.6.23.  But someone who knows what
they're doing should take a look at this...

