From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net-driver: Drivers don't set IFF_* flag [Was: [PATCH
 3/3] netdevice: order of synchronization of IFF_PROMISC and IFF_ALLMULTI]
Date: Mon, 23 Jun 2008 13:04:18 +0200
Message-ID: <485F8332.6010203@trash.net>
References: <48562F9A.5030509@cn.fujitsu.com> <485631FF.7040509@trash.net> <485634D1.2010603@cn.fujitsu.com> <48563A7F.50309@trash.net> <485716A1.8030401@cn.fujitsu.com> <4857B6DC.5020805@trash.net> <48587295.40705@cn.fujitsu.com> <48587854.8050400@pobox.com> <485BC7BA.60406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45385 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbYFWLEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:04:23 -0400
In-Reply-To: <485BC7BA.60406@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Jeff Garzik said the following on 2008-6-18 10:52:
>> Drivers should not be setting IFF_* flags in set_multicast_list().
>>
>> The normal logic is that a driver interprets the request implied in
>> set_multicast_list ("promisc, all-multi, or select multi?"), and then
>> programs the hardware based on that.
>>
>> On some hardware, IFF_ALLMULTI requires that the hardware receive all
>> packets (promisc).  Even for that case, the driver should -not- be
>> setting the IFF_PROMISC flag.  It should be aware of its own hardware
>> programming state through some other method.
>>
> 
> Subject: [PATCH] net-driver: Drivers don't set IFF_* flag
> 
> Some hardware set promisc when they are requested to set IFF_ALLMULTI flag.
> It's ok, but if drivers set IFF_PROMISC flag when they set promisc,
> it will broken upper layer handle for promisc and allmulti.
> In addition, drivers can use their own hardware programming to make it.
> So do not allow drivers to set IFF_* flags.
> 
> This is a general driver fix, so I didn't split it to pieces and send
> to specific driver maintainers.

Did you check that these drivers don't use the PROMISC flag they
set themselves somewhere? As Jeff said, they might use it to be
aware of their hardware programming state.

> diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
> index bc30c6e..df22589 100644
> --- a/drivers/net/tulip/de4x5.c
> +++ b/drivers/net/tulip/de4x5.c
> @@ -5520,6 +5520,7 @@ de4x5_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  	omr |= OMR_PR;
>  	outl(omr, DE4X5_OMR);
>  	dev->flags |= IFF_PROMISC;
> +	dev->promiscuity++;
>  	break;
>  
>      case DE4X5_CLR_PROM:             /* Clear Promiscuous Mode */
> @@ -5528,6 +5529,7 @@ de4x5_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  	omr &= ~OMR_PR;
>  	outl(omr, DE4X5_OMR);
>  	dev->flags &= ~IFF_PROMISC;
> +	dev->promiscuity = 0;
>  	break;

Shouldn't this be using dev_set_promiscuity().


