From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] net/fec: call netif_carrier_off when not having link
Date: Fri, 26 Jul 2013 11:06:06 +0100
Message-ID: <CAGVrzcZMg28Cj=KncE=qDq8qLKY1WkiH5PiwrJECTYdBOe16sA@mail.gmail.com>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20130725090352.574b874d@nehalam.linuxnetplumber.net> <9848F2DB572E5649BA045B288BE08FBE015C9315@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	Hector Palacios <hector.palacios@digi.com>,
	Tim Sander <tim.sander@hbm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:58404 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab3GZKGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 06:06:47 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so2765856pdj.14
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 03:06:47 -0700 (PDT)
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE015C9315@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

2013/7/26 Duan Fugang-B38611 <B38611@freescale.com>:
> On Fir, 26 Jul 2013 12:04, Stephen Hemminger wrote:
>>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>>> b/drivers/net/ethernet/freescale/fec_main.c
>>> index 0642006..631bd5a 100644
>>> --- a/drivers/net/ethernet/freescale/fec_main.c
>>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>>> @@ -280,11 +280,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>>>      unsigned short  status;
>>>      unsigned int index;
>>>
>>> -    if (!fep->link) {
>>> -            /* Link is down or auto-negotiation is in progress. */
>>> -            return NETDEV_TX_BUSY;
>>> -    }
>>> -
>>
>>That is a bug anyway. Since it would cause spin loop in transmit code (even without -rt).
>>If the driver cared to test it (most drivers just let hardware deal with this situation),
>>then it should free packet and return TX_OK.
>
> When link is down, the logic is
>         - call netif_stop_queue() to stop queue
>         - and then notify there have no link using netif_carrier_off().

netif_carrier_off() is handled by the PHY library before calling the
adjust_link callback in FEC.

>
> But the flow must be handled in fec_enet_adjust_link() function, not in xmit().

What is special about this hardware that fec_restart() needs to do all
that work? Can't you just update the duplex/speed/pause settings
directly without doing a full hardware re-init? Also the comment above
it is wrong, fec_restart() is not just called when the duplex changes,
it is called when the link/speed/duplex settings changed and when the
workqueue is scheduled from fec_timeout().
