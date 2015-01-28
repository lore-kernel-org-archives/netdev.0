From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 0/2] netns: audit netdevice creation with IFLA_NET_NS_[PID|FD]
Date: Wed, 28 Jan 2015 10:37:21 +0100
Message-ID: <54C8ADD1.4050203@6wind.com>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com> <20150127093425.GA2698@omega> <54C7694C.2060709@6wind.com> <20150127122340.GA4338@omega> <54C7928F.9010002@6wind.com> <20150127140620.GA8941@omega> <54C7A5B7.60103@6wind.com> <20150127202617.GA13654@omega>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, arvid.brodin@alten.se,
	linux-wpan@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:61868 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761729AbbA1Uo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:44:58 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so6099685wib.1
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 12:44:57 -0800 (PST)
In-Reply-To: <20150127202617.GA13654@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/01/2015 21:26, Alexander Aring a =C3=A9crit :
> On Tue, Jan 27, 2015 at 03:50:31PM +0100, Nicolas Dichtel wrote:
>> Le 27/01/2015 15:06, Alexander Aring a =C3=A9crit :
>>> Hi,
>>>
>>> On Tue, Jan 27, 2015 at 02:28:47PM +0100, Nicolas Dichtel wrote:
>>> ...
>> [snip]
>>>>
>>>> I don't know how wpan0 is created and if this interface can be cre=
ated directly
>>>> in another netns than init_net.
>>>>
>>>
>>> no it can't. The wpan0 interface can be created via the 802.15.4
>>> userspace tools and we don't have such option for namespaces. It
>>> should be always to init_net while creation.
>> Even with 'ip netns exec foo iwpan ...'?
>>
>
> I did a quick test:
>
> diff --git a/net/mac802154/iface.c b/net/mac802154/iface.c
> index 6fb6bdf..df55b42 100644
> --- a/net/mac802154/iface.c
> +++ b/net/mac802154/iface.c
> @@ -590,6 +590,11 @@ ieee802154_if_add(struct ieee802154_local *local=
, const char *name,
>          list_add_tail_rcu(&sdata->list, &local->interfaces);
>          mutex_unlock(&local->iflist_mtx);
>
> +       if (net_eq(dev_net(ndev), &init_net))
> +               printk(KERN_INFO "it's init_net\n");
> +       else
> +               printk(KERN_INFO "it's not init_net\n");
>
> With this patch and running:
>
> ip netns exec foo iwpan phy phy0 interface add bar%d type node
>
> I got a:
>
> [   52.032956] it's init_net
>
> It's also init_net when I run with "ip netns exec foo iwpan ..."
Ok. After looking at the code, it's right that no netns is set in
ieee802154_if_add(), thus the interface is in the default netns (init_n=
et).

[snip]
>>
>> But I still wonder if we should add a check about dev_net(dev) !=3D =
init_net in
>> net/ieee802154/6lowpan/core.c.
>> If my understanding is correct:
>>   - wpan can be created directly in a netns !=3D init_net
>>   - 6lowpan must be in the same netns than wpan
>>   - code under net/ieee802154 only works in init_net, thus 6lowpan o=
nly works
>>     in init_net.
>>
>> Do you agree?
>
> yes. I will put the last item on my ToDo list if we can do more netns
> stuff there.
Cool.

>
>> What about this (based on net-next)?
>>
>
> There are some little issues, see below.
>
>>  From 5ca1c46c68e4e4381b2f7e284f5dadeb28a53b2f Mon Sep 17 00:00:00 2=
001
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Tue, 27 Jan 2015 11:26:20 +0100
>> Subject: [PATCH] wpan/6lowpan: fix netns settings
>>
>
> use "ieee802154:" instead "wpan/6lowpan:".
Ok.

>
> Can you rebase this patch on bluetooth-next?
Will do.

[snip]
>> --- a/net/mac802154/iface.c
>> +++ b/net/mac802154/iface.c
>> @@ -475,6 +475,7 @@ static void ieee802154_if_setup(struct net_devic=
e *dev)
>>   	dev->mtu		=3D IEEE802154_MTU;
>>   	dev->tx_queue_len	=3D 300;
>>   	dev->flags		=3D IFF_NOARP | IFF_BROADCAST;
>> +	dev->features		|=3D NETIF_F_NETNS_LOCAL;
>
> We should set this inside the cfg802154_netdev_notifier_call function
> and NETDEV_REGISTER case. This can be found in "net/ieee802154/core.c=
". [0]
>
> The branch "net/mac802154" affects 802.15.4 SoftMAC interfaces only. =
We
> currently support SoftMAC only, but further we support HardMAC driver=
s.
> The HardMAC drivers doesn't use the "net/mac802154" branch and call
> netdev_register in driver layer.
>
> When we do it in cfg802154_netdev_notifier_call then this will be set
> for SoftMAC and HardMAC drivers (when we have a HardMAC driver). The
> same behaviour can also be found in wireless implementation. [1]
Ok.


Regards,
Nicolas
