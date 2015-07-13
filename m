From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next v2] ipv6: Do not iterate over all interfaces
 when finding source address on specific interface.
Date: Mon, 13 Jul 2015 22:49:33 +0900
Message-ID: <55A3C1ED.5070304@miraclelinux.com>
References: <559F7B27.6030205@miraclelinux.com>	<20150710.231943.1262522002810525503.davem@davemloft.net>	<CAAedzxpMP-DmKOy-BfQkReGWmbujGqM_JsdmYtcuxVDqAdXNKg@mail.gmail.com>	<55A35B72.2060009@miraclelinux.com>	<CAAedzxp8RAn3VZVZmWA_vLMspEyt_-nWe3RBKXWfsUoFRz97Hg@mail.gmail.com> <m2h9p85ntc.wl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, davem@davemloft.net,
	netdev@vger.kernel.org, hannes@stressinduktion.org,
	lorenzo@google.com
To: Hajime Tazaki <thehajime@gmail.com>, ek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36327 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbbGMNti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 09:49:38 -0400
Received: by pachj5 with SMTP id hj5so32562772pac.3
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 06:49:37 -0700 (PDT)
In-Reply-To: <m2h9p85ntc.wl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hajime Tazaki wrote:
> 
> Yoshifuji-san,
> 
> At Mon, 13 Jul 2015 17:38:48 +0900,
> Erik Kline wrote:
>>
>> On 13 July 2015 at 15:32, YOSHIFUJI Hideaki
>> <hideaki.yoshifuji@miraclelinux.com> wrote:
>>> Hi,
>>>
>>> Erik Kline wrote:
>>>> Hmm, when I run a UML linux with this patch (which, I'm ashamed to
>>>> say, I failed to do before) I get these kinds of errors:
>>>>
>>>>     unregister_netdevice: waiting for <TAPdevice> to become free.
>>>> Usage count = 1
>>>>     unregister_netdevice: waiting for <TAPdevice> to become free.
>>>> Usage count = 1
>>>>
>>>> Perhaps they're unrelated... I'm still investigating.
>>>
>>> Would you test attached patch please?
>>
>> That does look logically correct, so +1 to it regardless, but it does
>> not seem to have fixed the issue I'm seeing.
>>
>> I still haven't produced the smallest possible demo test program.
> 
> sorry to jump-in, but there is a side-effect with this
> patch, which my tcp and dccp tests (ipv6) are failed.
> 
> because newly added function (__ipv6_dev_get_saddr) won't
> update a variable 'hiscore' (it swaps with 'score' in some
> case), the caller (ipv6_dev_get_saddr) can't fill an
> appropriate saddr in the end.
> 
> I don't know if this is a good patch but the following diff
> makes my test happy.

We should update score as well...

> 
> -- Hajime
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 4ab74d5..c4e9416 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1363,7 +1363,8 @@ static void __ipv6_dev_get_saddr(struct net *net,
>  				 unsigned int prefs,
>  				 const struct in6_addr *saddr,
>  				 struct inet6_dev *idev,
> -				 struct ipv6_saddr_score *scores)
> +				 struct ipv6_saddr_score *scores,
> +				 struct ipv6_saddr_score **in_hiscore)
>  {
>  	struct ipv6_saddr_score *score = &scores[0], *hiscore = &scores[1];
>  
> @@ -1424,6 +1425,7 @@ static void __ipv6_dev_get_saddr(struct net *net,
>  				in6_ifa_hold(score->ifa);
>  
>  				swap(hiscore, score);
> +				*in_hiscore = hiscore;
>  
>  				/* restore our iterator */
>  				score->ifa = hiscore->ifa;
> @@ -1480,13 +1482,15 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
>  	}
>  
>  	if (use_oif_addr) {
> -		__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores);
> +		__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev,
> +				     scores, &hiscore);
>  	} else {
>  		for_each_netdev_rcu(net, dev) {
>  			idev = __in6_dev_get(dev);
>  			if (!idev)
>  				continue;
> -			__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores);
> +			__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev,
> +					     scores, &hiscore);
>  		}
>  	}
>  	rcu_read_unlock();
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
