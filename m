From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: change spinlocks and remove timers in favor of workqueues
Date: Thu, 30 Nov 2006 15:15:55 -0500
Message-ID: <bdfc5d6e0611301215o3e3e0c73wb22156b57ba7ed0f@mail.gmail.com>
References: <20061130162322.GA8772@gospo.rdu.redhat.com>
	 <200611301938.kAUJchgv020451@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:14222 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1031375AbWK3UP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 15:15:59 -0500
Received: by ug-out-1314.google.com with SMTP id 44so2226138uga
        for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 12:15:58 -0800 (PST)
To: "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <200611301938.kAUJchgv020451@death.nxdomain.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
>
> Andy Gospodarek <andy@greyhouse.net> wrote:
> >The main purpose of this patch is to clean-up the bonding code so that
> >several important operations are not done in the incorrect (softirq)
> >context. Whenever a kernel is compiled with CONFIG_DEBUG_SPINLOCK_SLEEP
> >all sorts of backtraces are spewed to the log since might_sleep will
> >kindly remind us we are doing something in a atomic context when we
> >probably should not.
> [...]
>
>         I'll look at the patch in detail in a bit (and I have 802.3ad
> switches to test on), but on first glance, does this not still hold a
> lock during failover operations in balance-alb mode?  I.e., this doesn't
> change the locking model, it just moves the timers to workqueues and
> relaxes the _bh locking.

Jay,

Thanks for the response.  You are correct.  This patch really doesn't
change functionality -- in fact that was one of goals of this patch.
I wanted to simply start the conversion since it seemed like 'the
right way' to do things going forward.

>
>         The really problematic case calls dev_set_mac_address() with a
> lock held, and I don't see that this patch changes that behavior.  Do
> you still get the lock warnings during link fail / recovery in
> balance-alb mode?

I no longer get lock warnings indicating that I'm taking a lock in an
invalid context, but lately I've been seeing rtnl lock assertion
failures when in balance-alb mode and whenever a call to
dev_set_mac_address is made.  It seems to be expected that the rtnl
lock is taken and that isn't the case anymore.

>
>         Also, on an CONFIG_PREEMPT kernel, it'll still get the sleep
> warnings, since in_atomic() will trip __might_sleep() for any lock (if
> I'm reading things correctly).

Based on my reading you will still only get these warnings if
CONFIG_DEBUG_SPINLOCK_SLEEP=y and CONFIG_PREEMPT=y.  Since most never
try with CONFIG_DEBUG_SPINLOCK_SLEEP=y they don't see these.

>         Don't get me wrong, this (switching to workqueues, etc) needs to
> be done, but I don't think this patch really resolves the underlying
> problem that causes the warnings.

Agreed.  I didn't want to tackle too many of the issues with one giant
patch.  Doing them in smallish steps seemed like a better way to go.

>
>         Let me see if I can dust off the extensive patch that does
> change the locking model; I'll see if I can bring it up to the current
> git and post it.
>

It would seem ideal if we could combine the two into one big patch.

-andy

>         -J
>
> ---
>         -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
