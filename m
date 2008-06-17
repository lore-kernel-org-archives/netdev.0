From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: Killing sk->sk_callback_lock (was Re: [PATCH]
	net/core/sock.c remove extra wakeup)
Date: Mon, 16 Jun 2008 19:38:23 -0600
Message-ID: <4856C12F020000C700039679@lucius.provo.novell.com>
References: <484F43A3020000760003F543@lucius.provo.novell.com>
 <4856C12F020000C700039679@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <herbert@gondor.apana.org.au>,
	"Gregory Haskins" <GHaskins@novell.com>, <chuck.lever@oracle.com>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucius.provo.novell.com ([137.65.248.127]:11688 "EHLO
	lucius.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbYFQBia convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 21:38:30 -0400
In-Reply-To: <4856C12F020000C700039679@lucius.provo.novell.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-11 at 02:16 -0700, David Miller wrote: 
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 11 Jun 2008 16:46:12 +1000
> 
> > Anyway, you've lost me with this scenario.  The patch is stopping
> > wake-ups on the write path yet you're talking about the read path.
> > So my question is why are you getting the extra wake-up on that
> > write path when you receive a packet?
> 
> During a short discussion on IRC with Herbert I explained
> that indeed it's the write wakeup path that's causing the
> issue here and we both agreed that the cost is likely
> simply from the sk->sk_callback_lock and not the wakeups
> themselves.  Once the first wakeup happens, the wait
> queues should be inactive and the task awake already.

I don't follow but I wasn't part of the IRC discussion. :-) Please
send me a note out of band if you would like to discuss again on IRC.
I agree that the sk_callback_lock may be significant overhead
(although lockstat is not showing it to be highly contended).
Our testing consists of parallel netperf tasks, one per cpu, with
test runs utilizing rt priority and others that do not.

The overhead I was trying to address was scheduler overhead.
In  short, I think I have a new patch that solves the race issues
and addresses the unneeded wake up. See below.

Something that is worth pointing out about the approach
taken is that SOCK_NOSPACE gets cleared after a task wakes from
a sleep due to wmem exceeded. I was actually surprised that this
was not currently done(once a udp socket sets this flag it is
not cleared for the life of the socket as far as I have seen). I
am not sure that there are any unintended side-effects but none
have been observed in the code or while running so far. 

I think the elimination of the sk_callback_lock would be great. I
can see it having significant impact on this testing. However, a 
patch to address the extra wake and flags behavior will provide
some improvement.


From: Patrick Mullaney <pmullaney@novell.com>

    Remove extra wake up on receive caused by write space
    cleanup(below wmem highwater threshold).

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
---

diff --git a/net/core/sock.c b/net/core/sock.c
index 1a394d0..a26d223 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1159,7 +1159,6 @@ static long sock_wait_for_wmem(struct sock * sk, long timeo)
 			break;
 		if (signal_pending(current))
 			break;
-		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf)
 			break;
@@ -1167,9 +1166,11 @@ static long sock_wait_for_wmem(struct sock * sk, long timeo)
 			break;
 		if (sk->sk_err)
 			break;
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		timeo = schedule_timeout(timeo);
 	}
 	finish_wait(sk->sk_sleep, &wait);
+	clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 	return timeo;
 }
 
@@ -1467,6 +1468,10 @@ static void sock_def_readable(struct sock *sk, int len)
 
 static void sock_def_write_space(struct sock *sk)
 {
+	/* don't wake unless writer is waiting */
+	if(!test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
+		return;
+
 	read_lock(&sk->sk_callback_lock);
 
 	/* Do not wake up a writer until he can make "significant"


> 

