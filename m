From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: fix multicast router rlist endless loop
Date: Tue, 9 Jun 2015 17:52:36 +0200
Message-ID: <CABQ03vGsy_LfBJsVg1hmc64WUmZ0LXaG4p6sCy1hggvPK_9kfg@mail.gmail.com>
References: <1433842349-28089-1-git-send-email-nikolay@cumulusnetworks.com>
	<20150609151250.GA15284@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Nikolay Aleksandrov <razor@blackwall.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35640 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbbFIPwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 11:52:37 -0400
Received: by igbzc4 with SMTP id zc4so15710515igb.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 08:52:36 -0700 (PDT)
In-Reply-To: <20150609151250.GA15284@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 9, 2015 at 5:12 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Jun 09, 2015 at 02:32:28AM -0700, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <razor@blackwall.org>
>>
>> Since the addition of sysfs multicast router support if one set
>> multicast_router to "2" more than once, then the port would be added to the
>> hlist every time and could end up linking to itself and thus causing an
>> endless loop for rlist walkers.
>> So to reproduce just do:
>> echo 2 > multicast_router; echo 2 > multicast_router;
>> in a bridge port and let some igmp traffic flow, for me it hangs up
>> in br_multicast_flood().
>> Fix this by removing the "val < 2" check, and just do the hlist_del
>> always.
>> We can remove the "!hlist_unhashed" check because it's already done by
>> hlist_del_init_rcu(), in fact this can also be done for
>> br_multicast_disable_port() but that is net-next material.
>> The reason this didn't happen before the addition of multicast_router
>> sysfs entries is because there's a !hlist_unhashed check that prevents
>> it.
>>
>> Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
>> Fixes: 0909e11758bd ("bridge: Add multicast_router sysfs entries")
>
> Good catch!
>
>> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
>> index 22fd0419b314..ecdd13512320 100644
>> --- a/net/bridge/br_multicast.c
>> +++ b/net/bridge/br_multicast.c
>> @@ -1993,8 +1993,7 @@ int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val)
>>               p->multicast_router = val;
>>               err = 0;
>>
>> -             if (val < 2 && !hlist_unhashed(&p->rlist))
>> -                     hlist_del_init_rcu(&p->rlist);
>> +             hlist_del_init_rcu(&p->rlist);
>
> This should work but removing it and readding seems strange.
>
> How about moving the hlist_unhashed test that's currently in
> br_multicast_mark_router into br_multicast_add_router instead?
>
> Thanks,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

Ah yes, I can see how that will simplify the code. I like it and will re-spin.
Thanks for the suggestion.

Cheers,
 Nik
