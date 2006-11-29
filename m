From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH] lockdep: fix sk->sk_callback_lock locking
Date: Wed, 29 Nov 2006 12:42:24 +0100
Message-ID: <1164800544.6588.118.camel@twins>
References: <E1GpKC4-0005Vc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org, mingo@elte.hu,
	gandalf@wlug.westbo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:53171 "EHLO
	amsfep12-int.chello.nl") by vger.kernel.org with ESMTP
	id S966410AbWK2LsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 06:48:14 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GpKC4-0005Vc-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-29 at 18:49 +1100, Herbert Xu wrote:
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > =========================================================
> > [ INFO: possible irq lock inversion dependency detected ]
> > 2.6.19-rc6 #4
> > ---------------------------------------------------------
> > nc/1854 just changed the state of lock:
> > (af_callback_keys + sk->sk_family#2){-.-?}, at: [<c0268a7f>] sock_def_error_report+0x1f/0x90
> > but this lock was taken by another, soft-irq-safe lock in the past:
> > (slock-AF_INET){-+..}
> > 
> > and interrupts could create inverse lock ordering between them.
> 
> I think this is bogus.  The slock is not a standard lock.  When we
> hold it in process context we don't actually hold the spin lock part
> of it.  However, it does prevent the softirq path from running in
> critical sections which also prevents any attempt to grab the
> callback lock from softirq context.
> 
> If you still think there is a problem, please show an actual scenario
> where it dead locks.

process context does lock_sock(sk) which is basically a sleeping lock
and sets an owner field when acquired.

BH context does bh_lock_sock(sk); which spins on the spinlock protecting
the owner field; and checks for an owner under this lock. When an owner
is found it will stick the skb on a queue for later processing.

This scheme does indeed seem to avoid the reported deadlock scenario -
although I didn't audit all code paths.

However I'm not quite sure yet how to teach lockdep about this. The
proposed patch will shut it up though.

