From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Linux 4.2-rc6 regression: RIP: e030:[<ffffffff8110fb18>]
 [<ffffffff8110fb18>] detach_if_pending+0x18/0x80
Date: Mon, 17 Aug 2015 21:13:35 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1508172112370.3873@nanos>
References: <7c39e6332aae572372108d5fd68c503b@eikelenboom.it>  <1439412094.29802.21.camel@edumazet-glaptop2.roam.corp.google.com>  <0de9f30086ee2e662bdafee61d24b3c1@eikelenboom.it>  <20150812.144040.1151964094247340464.davem@davemloft.net>
 <b5e9ffc27531e98bc2ac1e28d6a3d0f0@eikelenboom.it>  <1439419279.29802.25.camel@edumazet-glaptop2.roam.corp.google.com>  <3b284689aaa1573610c0e388e66e756a@eikelenboom.it>  <1439591965.7507.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <963062024.20150817110956@eikelenboom.it>  <1439818633.7258.16.camel@edumazet-glaptop2.roam.corp.google.com>  <196897465.20150817154802@eikelenboom.it> <55D1E97B.6090309@jons.org>  <1439821307.7258.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <373726164.20150817162534@eikelenboom.it> <1439831928.32680.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Jon Christopherson <jon@jons.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, david.vrabel@citrix.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439831928.32680.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Aug 2015, Eric Dumazet wrote:
> [PATCH] timer: fix a race in __mod_timer()
> 
> lock_timer_base() can not catch following :
> 
> CPU1 ( in __mod_timer()
> timer->flags |= TIMER_MIGRATING;
> spin_unlock(&base->lock);
> base = new_base;
> spin_lock(&base->lock);
> timer->flags &= ~TIMER_BASEMASK;
>                                   CPU2 (in lock_timer_base())
>                                   see timer base is cpu0 base
>                                   spin_lock_irqsave(&base->lock, *flags);
>                                   if (timer->flags == tf)
>                                        return base; // oops, wrong base
> timer->flags |= base->cpu // too late
> 
> We must write timer->flags in one go, otherwise we can fool other cpus.
> 
> Fixes: bc7a34b8b9eb ("timer: Reduce timer migration overhead if disabled")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> ---
>  kernel/time/timer.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/time/timer.c b/kernel/time/timer.c
> index 5e097fa9faf7..84190f02b521 100644
> --- a/kernel/time/timer.c
> +++ b/kernel/time/timer.c
> @@ -807,8 +807,8 @@ __mod_timer(struct timer_list *timer, unsigned long expires,
>  			spin_unlock(&base->lock);
>  			base = new_base;
>  			spin_lock(&base->lock);
> -			timer->flags &= ~TIMER_BASEMASK;
> -			timer->flags |= base->cpu;
> +			WRITE_ONCE(timer->flags,
> +				   (timer->flags & ~TIMER_BASEMASK) | base->cpu);

Duh, yes. Picking it up for timers/urgent.

Thanks for spotting it.

       tglx
