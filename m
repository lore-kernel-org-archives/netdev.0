From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] net-driver: Drivers don't set IFF_* flag [Was: [PATCH
 3/3] netdevice: order of synchronization of IFF_PROMISC and IFF_ALLMULTI]
Date: Mon, 23 Jun 2008 22:44:33 +0800
Message-ID: <485FB6D1.7000604@cn.fujitsu.com>
References: <48562F9A.5030509@cn.fujitsu.com> <485631FF.7040509@trash.net> <485634D1.2010603@cn.fujitsu.com> <48563A7F.50309@trash.net> <485716A1.8030401@cn.fujitsu.com> <4857B6DC.5020805@trash.net> <48587295.40705@cn.fujitsu.com> <48587854.8050400@pobox.com> <485BC7BA.60406@cn.fujitsu.com> <485F8332.6010203@trash.net> <485FA635.4090903@cn.fujitsu.com> <485FA962.5060704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>, davies@maniac.ultranet.com,
	grundler@parisc-linux.org, kyle@parisc-linux.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65038 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753692AbYFWOtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 10:49:01 -0400
In-Reply-To: <485FA962.5060704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-6-23 21:47:
>>>> @@ -5528,6 +5529,7 @@ de4x5_ioctl(struct net_device *dev, struct ifreq
>>>> *rq, int cmd)
>>>>      omr &= ~OMR_PR;
>>>>      outl(omr, DE4X5_OMR);
>>>>      dev->flags &= ~IFF_PROMISC;
>>>> +    dev->promiscuity = 0;
>>>>      break;
>>> Shouldn't this be using dev_set_promiscuity().
>>>
> 
> I actually meant dev_change_flags(), sorry.
> 

dev_change_flags() can not completely change flag IFF_PROMISC like
IFF_UP, etc.
So dev_change_flags() has no big difference to dev_set_promiscuity().
I think dev_set_promiscuity() is suitable here.

>> No.
>> 1. dev_set_promiscuity do
>>   a. set/unset IFF_PROMISC
>>   b. promiscuity++/--
>>   c. audit
>>   d. dev_set_rx_mode (upload unicast and multicast list to device)
>>   Here, in ioctl, a & b is enough.
> 
> Auditing should certainly be done if promiscous mode is set.
> Calling dev_set_rx_mode doesn't hurt, even if it does the ioctl
> handler could be changed not to care. Besides this is neither
> taking the rtnl_mutex as required nor sending notifcations
> to userspace.
> 

Agree.

>> 2. dev->flags unset IFF_PROMISC and dev->promiscuity = 0 can not be
>>    replaced by dev_set_promiscuity(). Because, we don't decrease
>>    promiscuity here, but set promiscuity zero for unset IFF_PROMISC.
> 
> And that looks like a bug, the driver shouldn't disable
> promiscuity if something still requires it.
> 

It's hard to say that.
In theory, user-space can require device to disable promisc by driver's
ioctl. 
But OTOH if something else still want device to be promisc, user and
driver have no method to let them decrease the refcnt promiscuity. Because
promiscuity decrement is initiative action from upper layer, drivers don't
know who need promiscuity.

Humm, tired, go to sleep and figure out how to do after refreshing. :)

