From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net-driver: Drivers don't set IFF_* flag [Was: [PATCH
 3/3] netdevice: order of synchronization of IFF_PROMISC and IFF_ALLMULTI]
Date: Mon, 23 Jun 2008 15:47:14 +0200
Message-ID: <485FA962.5060704@trash.net>
References: <48562F9A.5030509@cn.fujitsu.com> <485631FF.7040509@trash.net> <485634D1.2010603@cn.fujitsu.com> <48563A7F.50309@trash.net> <485716A1.8030401@cn.fujitsu.com> <4857B6DC.5020805@trash.net> <48587295.40705@cn.fujitsu.com> <48587854.8050400@pobox.com> <485BC7BA.60406@cn.fujitsu.com> <485F8332.6010203@trash.net> <485FA635.4090903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51294 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbYFWNrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 09:47:20 -0400
In-Reply-To: <485FA635.4090903@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Patrick McHardy said the following on 2008-6-23 19:04:
>> Did you check that these drivers don't use the PROMISC flag they
>> set themselves somewhere? As Jeff said, they might use it to be
>> aware of their hardware programming state.
>>
> 
> Yes. I checked.
> The flag is set but not be used anywhere else.
> All of the drivers set their own state and at the same time
> set IFF_PROMIDC flag.
> I think that by setting IFF_PROMISC the drivers want to inform
> upper layer that they set hardware to promisc although they are
> requested to set ALLMULTI.
> But the driver's redundant action is unneeded.
> Because, if the hardwares have to set promisc mode when they
> required to receive all multicast packets, it's ok, upper layer
> don't need to be informed.
> Only if allmulti and promiscuity all be zero, the promisc mode will be off.

OK, thanks for the explanation.

>>> @@ -5528,6 +5529,7 @@ de4x5_ioctl(struct net_device *dev, struct ifreq
>>> *rq, int cmd)
>>>      omr &= ~OMR_PR;
>>>      outl(omr, DE4X5_OMR);
>>>      dev->flags &= ~IFF_PROMISC;
>>> +    dev->promiscuity = 0;
>>>      break;
>> Shouldn't this be using dev_set_promiscuity().
>>

I actually meant dev_change_flags(), sorry.

> No.
> 1. dev_set_promiscuity do
>   a. set/unset IFF_PROMISC
>   b. promiscuity++/--
>   c. audit
>   d. dev_set_rx_mode (upload unicast and multicast list to device)
>   Here, in ioctl, a & b is enough.

Auditing should certainly be done if promiscous mode is set.
Calling dev_set_rx_mode doesn't hurt, even if it does the ioctl
handler could be changed not to care. Besides this is neither
taking the rtnl_mutex as required nor sending notifcations
to userspace.

> 2. dev->flags unset IFF_PROMISC and dev->promiscuity = 0 can not be
>    replaced by dev_set_promiscuity(). Because, we don't decrease
>    promiscuity here, but set promiscuity zero for unset IFF_PROMISC.

And that looks like a bug, the driver shouldn't disable
promiscuity if something still requires it.

