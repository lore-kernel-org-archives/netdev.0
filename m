From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: Linux 4.2-rc6 regression: RIP: e030:[<ffffffff8110fb18>]
 [<ffffffff8110fb18>] =?UTF-8?Q?detach=5Fif=5Fpending+=30x=31=38/=30x=38?=
 =?UTF-8?Q?=30?=
Date: Mon, 17 Aug 2015 20:27:42 +0200
Message-ID: <ae0cbd0dc71333ea44e4e756c8a004b3@eikelenboom.it>
References: <7c39e6332aae572372108d5fd68c503b@eikelenboom.it>
 <1439412094.29802.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <0de9f30086ee2e662bdafee61d24b3c1@eikelenboom.it>
 <20150812.144040.1151964094247340464.davem@davemloft.net>
 <b5e9ffc27531e98bc2ac1e28d6a3d0f0@eikelenboom.it>
 <1439419279.29802.25.camel@edumazet-glaptop2.roam.corp.google.com>
 <3b284689aaa1573610c0e388e66e756a@eikelenboom.it>
 <1439591965.7507.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <963062024.20150817110956@eikelenboom.it>
 <1439818633.7258.16.camel@edumazet-glaptop2.roam.corp.google.com>
 <196897465.20150817154802@eikelenboom.it> <55D1E97B.6090309@jons.org>
 <1439821307.7258.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <373726164.20150817162534@eikelenboom.it>
 <1439831928.32680.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Jon Christopherson <jon@jons.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, david.vrabel@citrix.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:51051 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbbHQSd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 14:33:28 -0400
In-Reply-To: <1439831928.32680.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-08-17 19:18, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On Mon, 2015-08-17 at 16:25 +0200, Sander Eikelenboom wrote:
>> Monday, August 17, 2015, 4:21:47 PM, you wrote:
>> 
>> > On Mon, 2015-08-17 at 09:02 -0500, Jon Christopherson wrote:
>> >> This is very similar to the behavior I am seeing in this bug:
>> >>
>> >> https://bugzilla.kernel.org/show_bug.cgi?id=102911
>> 
>> > OK, but have you applied the fix ?
>> 
>> > http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
>> 
>> > It will be part of net iteration from David Miller to Linus Torvald.
>> 
>> 
>> I did have that patch in for my last report.
>> But i don't think he had (looking at the second part of his oops).
>> 
> 
> Then can you try following fix as well ?
> 
> Thanks !

Running now :)


> 
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
>                                   spin_lock_irqsave(&base->lock, 
> *flags);
>                                   if (timer->flags == tf)
>                                        return base; // oops, wrong base
> timer->flags |= base->cpu // too late
> 
> We must write timer->flags in one go, otherwise we can fool other cpus.
> 
> Fixes: bc7a34b8b9eb ("timer: Reduce timer migration overhead if 
> disabled")
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
> @@ -807,8 +807,8 @@ __mod_timer(struct timer_list *timer, unsigned long 
> expires,
>  			spin_unlock(&base->lock);
>  			base = new_base;
>  			spin_lock(&base->lock);
> -			timer->flags &= ~TIMER_BASEMASK;
> -			timer->flags |= base->cpu;
> +			WRITE_ONCE(timer->flags,
> +				   (timer->flags & ~TIMER_BASEMASK) | base->cpu);
>  		}
>  	}
