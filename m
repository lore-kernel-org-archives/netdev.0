From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] (1/11) Irda dongle module owner support
Date: Thu, 2 Oct 2003 16:33:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002233335.GA7945@bougret.hpl.hp.com>
References: <20031002152026.4bfd2c67.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031002152026.4bfd2c67.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 02, 2003 at 03:20:26PM -0700, Stephen Hemminger wrote:
>
> IRDA dongle interface needed to be converted to have an owner field
> to avoid races on module unload.

	Yep, this code was broken. At this point, we were supposed to
use the new dongle stuff of Martin, wich I think is correct, but it
didn't happened.

> Eliminated the use of hashbin locking because the dongle control
> code needed to do it's own locking to avoid races.   This also closed
> the race between find and insert. 

	Yep, that's the right approach.

> The find/insert hashbin race may be a general problem with all the IRDA
> hashbin stuff.

	This is clearly commented in the hashbin code (big block of
comments). Note that this problem is not a problem of hashbin
themselves, because there is only so much you can do there, but more
about how you use hashbins.
	This is why over the last year a lot of critical IrDA code has
migrated to HB_NOLOCK or/and use external locking, and therefore the
situation is not as bad as it looks. Do a "grep hb_spinlock *" to
confirm this (or check my web page) ;-)
	For the reason mentionned above, the dongle code and the task
code were not upgraded.

> IMHO the hashbin stuff should be replaced, it is full
> of dead incomplete code and done better by the list macros.

	I somehow agree with that (check my comments on
hashbin.c). However, as the majority of locking issues have been
addressed during 2.5.X, it's not as critical, and as long as it
works...

> +static spinlock_t dongle_lock = SPIN_LOCK_UNLOCKED;

	The usual IrDA convention is to reuse &dongle->hb_spinlock
rather than adding a new variable. Less bloat.

> +	spin_lock(&dongle_lock);

	I wonder if you need to lock BH as well. I'm not sure if all
the dongles call are guaranteed to come from user space. You don't want to introduce nasty deadlocks ;-)

> -	ASSERT(!in_interrupt(), return NULL;);

	Hum... My recollections is that calling request_module with
interrupt disable was guaranteed to crash. But that was with the "old"
module code.
	I would prefer if you leave this stuff in, it helps debugging.

	Have fun...

	Jean
