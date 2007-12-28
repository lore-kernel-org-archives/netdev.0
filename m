From: Pidoux <f6bvp@free.fr>
Subject: Re: [ROSE] [AX25] possible circular locking
Date: Fri, 28 Dec 2007 22:30:23 +0100
Message-ID: <47756AEF.8040206@free.fr>
References: <47664A0C.4060903@free.fr> <20071218135202.GA2023@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:33418 "EHLO smtp3-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbXL1Vac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2007 16:30:32 -0500
In-Reply-To: <20071218135202.GA2023@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote :
> On Mon, Dec 17, 2007 at 11:06:04AM +0100, Bernard Pidoux F6BVP wrote:
>   
>> Hi,
>>
>>
>> When I killall kissattach I can see the following message.
>>
>> This happens on kernel 2.6.24-rc5 already patched with the 6 previously
>> patches I sent recently.
>>
>>
>> =======================================================
>> [ INFO: possible circular locking dependency detected ]
>> 2.6.23.9 #1
>> -------------------------------------------------------
>> kissattach/2906 is trying to acquire lock:
>>  (linkfail_lock){-+..}, at: [<d8bd4603>] ax25_link_failed+0x11/0x39 [ax25]
>>
>> but task is already holding lock:
>>  (ax25_list_lock){-+..}, at: [<d8bd7c7c>] ax25_device_event+0x38/0x84
>> [ax25]
>>
>> which lock already depends on the new lock.
>>
>>
>> the existing dependency chain (in reverse order) is:
>>     
> ...
>
> It seems, lockdep is warried about the different order here:
>
> #1 (rose_neigh_list_lock){-+..}:
> #3 (ax25_list_lock){-+..}:
>
> #0 (linkfail_lock){-+..}:
> #1 (rose_neigh_list_lock){-+..}:
>
> #3 (ax25_list_lock){-+..}:
> #0 (linkfail_lock){-+..}:
>
> So, ax25_list_lock could be taken before and after linkfail_lock. 
> I don't know if this three-thread clutch is very probable (or
> possible at all), but it seems this other bug nearby reported by
> Bernard ("[...] system impossible to reboot with linux-2.6.24-rc5")
> could have similar source - namely ax25_list_lock held by
> ax25_kill_by_device() during ax25_disconnect(). It looks like the
> only place which calls ax25_disconnect() this way, so I guess, it
> isn't necessary. But, since I don't know AX25 & ROSE at all, this
> should be necessarily verified by somebody who knows these things.
>
> I attach here my very experimental proposal with breaking the lock
> for ax25_disconnect(), with some failsafe and debugging because of
> this, but, if in this special case the lock is required for some
> other reasons, then this patch should be dumped, of course.
>
> Regards,
> Jarek P.
>
> WARNING:
> not tested, not even compiled, needs some ack before testing!
>
> ---
>
> diff -Nurp linux-2.6.24-rc5-/net/ax25/af_ax25.c linux-2.6.24-rc5+/net/ax25/af_ax25.c
> --- linux-2.6.24-rc5-/net/ax25/af_ax25.c	2007-12-17 13:29:19.000000000 +0100
> +++ linux-2.6.24-rc5+/net/ax25/af_ax25.c	2007-12-18 13:36:05.000000000 +0100
> @@ -87,10 +87,19 @@ static void ax25_kill_by_device(struct n
>  		return;
>  
>  	spin_lock_bh(&ax25_list_lock);
> +again:
>  	ax25_for_each(s, node, &ax25_list) {
>  		if (s->ax25_dev == ax25_dev) {
> +			struct hlist_node *nn = node->next;
> +
>  			s->ax25_dev = NULL;
> +			spin_unlock_bh(&ax25_list_lock);
>  			ax25_disconnect(s, ENETUNREACH);
> +			spin_lock_bh(&ax25_list_lock);
> +			if (nn != node->next) {
> +				WARN_ON_ONCE(1);
> +				goto again;
> +			}
>  		}
>  	}
>  	spin_unlock_bh(&ax25_list_lock);
>
>
>   
After a few days of observation and a number of reboot for test purpose, 
I confirm that your patch is doing very well.
I have no more problems rebooting and the AX25 applications are running 
fine.

I hope this patch, with or without warning, could be applied in next 
kernel release.

Thanks again Jarek.

Regards from Bernard P.
f6bvp

