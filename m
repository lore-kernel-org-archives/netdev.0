From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Fri, 14 Nov 2008 09:41:12 +0300
Message-ID: <20081114064112.GA2376@x200.localdomain>
References: <b6fcc0a0811131521h69419b4an102a0cee98841a83@mail.gmail.com> <491D003F.7060605@cosmosbay.com> <20081113.204025.162228911.davem@davemloft.net> <491D0482.1030706@cosmosbay.com> <20081114061452.GA2227@x200.localdomain> <491D18D9.1050708@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:42167 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbYKNGhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 01:37:43 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1562043ugf.37
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 22:37:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <491D18D9.1050708@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2008 at 07:21:13AM +0100, Eric Dumazet wrote:
> Alexey Dobriyan a =E9crit :
>> On Fri, Nov 14, 2008 at 05:54:26AM +0100, Eric Dumazet wrote:
>>> David Miller a =E9crit :
>>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>>> Date: Fri, 14 Nov 2008 05:36:15 +0100
>>>>
>>>>> This is better because :
>>>>>
>>>>> 1) No #ifdef CONFIG_NET_NS
>>>>>
>>>>> 2) The magic about &init_net is not duplicated in ten different i=
nclude files, but
>>>>>    centralized in the right file : include/net/net_namespace.h
>>>> I %100 agree.
>>> Speaking of those functions, what do you think of this one ?
>>>
>>> static inline
>>> void dev_net_set(struct net_device *dev, struct net *net)
>>> {
>>> #ifdef CONFIG_NET_NS
>>>        release_net(dev->nd_net);
>>>        dev->nd_net =3D hold_net(net);
>>> #endif
>>> }
>>>
>>> I believe that its safer to hold a reference on "new" *before*
>>> releasing reference on "old" object.
>>>
>>> Also, release_net() and hold_net() can be defined to do
>>> the use_count refcounting regardless of CONFIG_NET_NS
>>> (Its a different NETNS_REFCNT_DEBUG #ifdef)
>>
>> NETNS_REFCNT_DEBUG makes sense only with NET_NS=3Dy because init_net
>> is never freed.
>
> It makes sense when you want to debug things, without full NET_NS

It doesn't work without NET_NS at all.

Check triggers right before netns is freed, and init_net is never freed=
=2E
You can move the check (interesting, to where?) or watch usecount live
somehow.

> Check CONFIG_PROVE_LOCKING or other debugging stuff
>
> CONFIG_SMP can be unset, still we are able to check spinlocks are
> lock()/unlock() are correctly paired
>
>>
>>> Yet another example where read_pnet() and write_pnet()
>>> are the right answer : Its cleaner and fixes *bugs*.
>>
>> pnet stuff by definition can't fix bugs :-)
>
> It will, I bet it.
>
> Cant you see difference between
>
> #ifdef CONFIG_NET_NS
> 	ptr->net =3D expression;
> #endif
>
> and
>
> write_pnet(&ptr->net, expression);
>
> Answer : In the 2nd case, (expression) is evaluated.
>
> In case its evaluation has side effects (like... refcounting), it mak=
es a huge difference.

We don't do such tricky thing with netns pointers. It either comes from=
 somewhere (netdevice)
and you use it as is or it's &init_net.

It's almost a cookie, nobody evaluates cookies. Such code should reject=
ed.
