From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [BUG net-next] infamous dev refcnt leak... again.
Date: Fri, 14 Aug 2015 17:19:18 -0600
Message-ID: <55CE7776.5000706@cumulusnetworks.com>
References: <1439586894.7507.5.camel@edumazet-glaptop2.roam.corp.google.com> <1439594063.7507.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33766 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbbHNXT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 19:19:27 -0400
Received: by igfj19 with SMTP id j19so23022667igf.0
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 16:19:26 -0700 (PDT)
In-Reply-To: <1439594063.7507.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/14/15 5:14 PM, Eric Dumazet wrote:
> On Fri, 2015-08-14 at 14:14 -0700, Eric Dumazet wrote:
>> While rebooting host running latest net-next
>>
>>   unregister_netdevice: waiting for eth0 to become free. Usage count = 4
>>
>> Oh well...
>>
>
> It looks like David Ahern recent changes uncover a bug ?
>
> Not clear which commit is at fault.
>
> Maybe 3bfd847203c6d89532f836ad3f5b4ff4ced26dd9 ?
>
> Somehow a down device can be found.

Can you elaborate on what you are doing to see the refcnt leak? I have 
not seen that at all. I have to leave for soccer carpool in 45 minutes 
or so, but can take a look this weekend.

David

>
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index b7f1d20..675a3b6 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -725,10 +725,14 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
>   		nh->nh_dev = dev = FIB_RES_DEV(res);
>   		if (!dev)
>   			goto out;
> -		dev_hold(dev);
>   		if (!netif_carrier_ok(dev))
>   			nh->nh_flags |= RTNH_F_LINKDOWN;
> -		err = (dev->flags & IFF_UP) ? 0 : -ENETDOWN;
> +		if (dev->flags & IFF_UP) {
> +			err = 0;
> +			dev_hold(dev);
> +		} else {
> +			err = -ENETDOWN;
> +		}
>   	} else {
>   		struct in_device *in_dev;
>
>
>
