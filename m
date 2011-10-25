From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Linux 3.1-rc9
Date: Tue, 25 Oct 2011 14:30:50 +0200 (CEST)
Message-ID: <alpine.LFD.2.02.1110251419170.21837@ionos>
References: <alpine.LFD.2.02.1110182146440.3240@ionos> <20111024190203.GA24410@hostway.ca> <CA+55aFwzAM6zhqCYJwoRxCdLJB+h84BDqzhF0RNQ6Jg9SQFjSA@mail.gmail.com> <20111025.050113.1678938946604302787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: torvalds@linux-foundation.org, sim@hostway.ca,
	netdev@vger.kernel.org, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, davej@redhat.com,
	schwidefsky@de.ibm.com, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111025.050113.1678938946604302787.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Oct 2011, David Miller wrote:

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Tue, 25 Oct 2011 09:13:48 +0200
> 
> > Added netdev, because this seems to be a generic networking bug (ABBA
> > between sk_lock and icsk_retransmit_timer if my quick scan looks
> > correct).
> > 
> > Davem?
> 
> I suspect that's all just a side effect of whatever is creating the
> preempt_count imbalance.

Something is holding socket lock and it was acquired in sk_clone()
which does bh_lock_sock() and returns with the lock held, though I got
completely lost in the gazillions of possible callchains ...

While staring at it I found an missing unlock in sk_clone() itself,
but that's not the one which causes the leak. Lockdep would have
complained about that separately :)

Thanks,

	tglx

--------->
Subject: net: Unlock sock before calling sk_free()

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Index: linux-2.6/net/core/sock.c
===================================================================
--- linux-2.6.orig/net/core/sock.c
+++ linux-2.6/net/core/sock.c
@@ -1260,6 +1260,7 @@ struct sock *sk_clone(const struct sock 
 			/* It is still raw copy of parent, so invalidate
 			 * destructor and make plain sk_free() */
 			newsk->sk_destruct = NULL;
+			bh_unlock_sock(newsk);
 			sk_free(newsk);
 			newsk = NULL;
 			goto out;
