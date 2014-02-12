From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Wed, 12 Feb 2014 11:03:37 +0100
Message-ID: <52FB46F9.5050304@6wind.com>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>	 <20140211014535.GA11150@order.stressinduktion.org>	 <CAHA+R7N2rxt5vyF+i8mi04dJaLk5bCgMAZOCexOLULLcQ-mT6w@mail.gmail.com>	 <20140211024009.GD11150@order.stressinduktion.org>	 <1392092120.6615.64.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAHA+R7MhHuOPaT5oAF_S-a3u1_2mt=Vqd5HCdi9r3JV-fK-6Pw@mail.gmail.com>	 <1392096087.6615.72.camel@edumazet-glaptop2.roam.corp.google.com>	 <1392097032.6615.73.camel@edumazet-glaptop2.roam.corp.google.com> <1392097099.6615.74.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:50395 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaBLKDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 05:03:40 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so4164129eei.35
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 02:03:39 -0800 (PST)
In-Reply-To: <1392097099.6615.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/02/2014 06:38, Eric Dumazet a =C3=A9crit :
> On Mon, 2014-02-10 at 21:37 -0800, Eric Dumazet wrote:
>
>>
>> Simple patch would be :
>>
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index 048dc8d183aa..31bbba34fd1e 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -963,6 +963,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb,=
 struct net_device *dev,
>>   	    nla_put_u32(skb, IFLA_NUM_RX_QUEUES, dev->num_rx_queues) ||
>>   #endif
>>   	    (dev->ifindex !=3D dev->iflink &&
>> +	     __dev_get_by_index(dev_net(dev), dev->iflink) &&
>>   	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
>>   	    (upper_dev &&
>>   	     nla_put_u32(skb, IFLA_MASTER, upper_dev->ifindex)) ||
>>
>
> Hmm, not enough.
>
> We probably need to keep a pointer to iflink net structure.
This is also used in ip tunnels, but when i/o device is not in the same=
 netns
that the tunnel device, the userland can not interpret that IFLA_LINK a=
ttribute
(userland don't have necessary information to access another netns, may=
be they
will be able to do it in the future ;-)).

The goal of your patch was to avoid filling this attribute when iflink =
is
into a netns !=3D from dev_net(dev)?

If yes, I agree that we need to keep a pointer to the net structure of =
iflink.
This information is already available in ip tunnels (struct ip_tunnel->=
net,
struct ip6_tnl->net) but is not generic. Maybe we can move it to struct
net_device?
