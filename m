From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v4] ipvlan: Initial check-in of the IPVLAN driver.
Date: Wed, 26 Nov 2014 22:55:23 -0800
Message-ID: <CAF2d9jiTCmYU5sGK4SdZyPw=vyYenwwmjM3NEJcHi8rduE-xBw@mail.gmail.com>
References: <1416812866-13401-1-git-send-email-maheshb@google.com>
 <54757631.8090604@lab.ntt.co.jp> <CAF2d9jgZkgk4kOyS7K959vEq_55DuEnkVdxzKPdmPiTxFfPvsg@mail.gmail.com>
 <5476859E.609@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:59425 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaK0Gzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 01:55:44 -0500
Received: by mail-oi0-f47.google.com with SMTP id v63so3101758oia.6
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 22:55:43 -0800 (PST)
In-Reply-To: <5476859E.609@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 5:59 PM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> On 2014/11/27 2:05, Mahesh Bandewar wrote:
>> On Tue, Nov 25, 2014 at 10:41 PM, Toshiaki Makita
>> <makita.toshiaki@lab.ntt.co.jp> wrote:
>>> Hi Mahesh,
>>>
>>> I found that deleting the last ipvlan device triggers WARN_ON() in
>>> rtmsg_ifinfo().
>>> ipvlan_nl_fillinfo() seems to return -EINVAL in that case.
>>>
>>>> +static int ipvlan_nl_fillinfo(struct sk_buff *skb,
>>>> +                           const struct net_device *dev)
>>>> +{
>>>> +     struct ipvl_dev *ipvlan = netdev_priv(dev);
>>>> +     struct ipvl_port *port = ipvlan_port_get_rtnl(ipvlan->phy_dev);
>>>> +     int ret = -EINVAL;
>>>> +
>>>> +     if (!port)
>>>> +             goto err;
>>>> +
>>>> +     ret = -EMSGSIZE;
>>>> +     if (nla_put_u16(skb, IFLA_IPVLAN_MODE, port->mode))
>>>> +             goto err;
>>>> +
>>>> +     return 0;
>>>> +
>>>> +err:
>>>> +     return ret;
>>>> +}
>>>
>>> rollback_registered_many() calls rtmsg_ifinfo() after calling ndo_uninit().
>>> ndo_uninit() (ipvlan_uninit() -> ipvlan_port_destroy() ->
>>> netdev_rx_handler_unregister()) sets rx_handler_data into NULL.
>>> So, we cannot dereference "port" in ipvlan_nl_fillinfo().
>>>
>> Calling fillinfo() after calling uninit() seems pointless on any
>> device.
>
> bonding needs calling rtmsg_ifinfo() after calling ndo_uninit().
> 56bfa7ee7c88 ("unregister_netdevice : move RTM_DELLINK to until after
> ndo_uninit")
>
Thanks I'll take a look.

>> But how are you hitting this case? Can you share the command
>> sequence with me?
>
> # ip link add link eth0 name ipvl0 type ipvlan
> # ip link del ipvl0
>
Yes, I could reproduce the issue when the master device is a bond.

> Thanks,
> Toshiaki Makita
>
>>
>> Thanks,
>> --mahesh..
>>
>>> Maybe "mode" should belong to struct ipvl_dev?
>>>
>>> Thanks,
>>> Toshiaki Makita
>
