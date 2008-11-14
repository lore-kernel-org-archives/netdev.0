From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Fri, 14 Nov 2008 09:14:53 +0300
Message-ID: <20081114061452.GA2227@x200.localdomain>
References: <b6fcc0a0811131521h69419b4an102a0cee98841a83@mail.gmail.com> <491D003F.7060605@cosmosbay.com> <20081113.204025.162228911.davem@davemloft.net> <491D0482.1030706@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:38785 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbYKNGLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 01:11:25 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1559466ugf.37
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 22:11:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <491D0482.1030706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2008 at 05:54:26AM +0100, Eric Dumazet wrote:
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Fri, 14 Nov 2008 05:36:15 +0100
>>
>>> This is better because :
>>>
>>> 1) No #ifdef CONFIG_NET_NS
>>>
>>> 2) The magic about &init_net is not duplicated in ten different inc=
lude files, but
>>>    centralized in the right file : include/net/net_namespace.h
>>
>> I %100 agree.
>
> Speaking of those functions, what do you think of this one ?
>
> static inline
> void dev_net_set(struct net_device *dev, struct net *net)
> {
> #ifdef CONFIG_NET_NS
>        release_net(dev->nd_net);
>        dev->nd_net =3D hold_net(net);
> #endif
> }
>
> I believe that its safer to hold a reference on "new" *before*
> releasing reference on "old" object.
>
> Also, release_net() and hold_net() can be defined to do
> the use_count refcounting regardless of CONFIG_NET_NS
> (Its a different NETNS_REFCNT_DEBUG #ifdef)

NETNS_REFCNT_DEBUG makes sense only with NET_NS=3Dy because init_net
is never freed.

> Yet another example where read_pnet() and write_pnet()
> are the right answer : Its cleaner and fixes *bugs*.

pnet stuff by definition can't fix bugs :-)

Ask from where new net comes?

If from current, nsproxy refcount is at least 1, so netns refcount is a=
t least 1,
so shutdown sequence can't start.

If from userspace socket, there is task in netns -- see #1

If from netdevice on which ioctl is done, some task did ioctl -- see #1=
=2E

And so on.

But this is peanuts, because your race matters only when netns is almos=
t freed
(in kmem_cache_free sense), so you're stashing dangling pointer somewhe=
re else
which is a bug by itself.

> static inline
> void dev_net_set(struct net_device *dev, struct net *net)
> {
> 	hold_net(net);
> 	release_net(read_pnet(&dev->nd_net);
>        write_pnet(&dev->nd_net, net);
> }
