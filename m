From: Hector Palacios <hector.palacios@digi.com>
Subject: Re: [PATCH] net/fec: infinite spin on sirq-net-tx on real-time
Date: Mon, 6 Feb 2012 12:03:55 +0100
Message-ID: <4F2FB39B.9010205@digi.com>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com> <1328522191.2220.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"jgq516@gmail.com" <jgq516@gmail.com>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	"tim.sander@hbm.com" <tim.sander@hbm.com>,
	"u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	Zeng Zhaoming <b32542@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201.messagelabs.com ([216.82.254.211]:40806 "EHLO
	mail201.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab2BFLWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 06:22:01 -0500
In-Reply-To: <1328522191.2220.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2012 10:56 AM, Eric Dumazet wrote:
> Le lundi 06 f=C3=A9vrier 2012 =C3=A0 10:33 +0100, Hector Palacios a =C3=
=A9crit :
>> If softirqd is a real time task, an inifinite spin is hit
>> if the FEC driver tries to send a packet before the autonegotiation
>> with the PHY has completed.
>>
>> This was seen when booting the platform with DHCP on. The driver
>> sends the DHCP request before the PHY has completed autonegotiation.
>> As a consequence, the driver's dev_hard_start_xmit returns NETDEV_TX=
_BUSY.
>> NETDEV_TX_BUSY is part of NET_TX_MASK thus the packet is requeued (t=
he
>> skb->next =3D nskb) in dev_hard_start_xmit(). And the NETDEV_TX_BUSY=
 is
>> passed back to sch_derect_xmit() which calls dev_requeue_skb() which
>> then calls __netif_schedule(q) which will call __netif_reschedule(q)
>> which will then do raise_softirq_irqoff(NET_TX_SOFTIRQ).
>>
>> Thus, as soon as ksoftirq exits this routine, it will restart the
>> process over again. As the fec driver never finished with its
>> negotiations, the process starts over again and we never move forwar=
d.
>>
>> Newsgroup reference: linux-rt-users http://www.spinics.net/lists/lin=
ux-rt-users/msg07551.html
>>
>> Signed-off-by: Zeng Zhaoming<b32542@freescale.com>
>> Signed-off-by: Frank Li<Frank.Li@freescale.com>
>> Signed-off-by: Hector Palacios<hector.palacios@digi.com>
>> ---
>>   drivers/net/ethernet/freescale/fec.c |    3 +++
>>   1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethe=
rnet/freescale/fec.c
>> index c136230..3fa7d3b 100644
>> --- a/drivers/net/ethernet/freescale/fec.c
>> +++ b/drivers/net/ethernet/freescale/fec.c
>> @@ -284,6 +284,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct =
net_device *ndev)
>>
>>   	if (!fep->link) {
>>   		/* Link is down or autonegotiation is in progress. */
>> +		netif_stop_queue(dev);
>
> This seems odd.
>
> IMHO, NETDEV_TX_BUSY should be avoided as much as possible.
>
> Its part of the old driver API.
>
> If queue was stopped, you would not have to test fep->link at all in
> fast path, and Qdisc would not have to requeue a packet eventually.
>
>>   		return NETDEV_TX_BUSY;
>>   	}
>>
>> @@ -530,6 +531,7 @@ fec_stop(struct net_device *ndev)
>>   	udelay(10);
>>   	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>>   	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
>> +	fep->link =3D 0;
>
>
> Why not call netif_stop_queue(dev) here ?
>
>>
>>   	/* We have to keep ENET enabled to have MII interrupt stay workin=
g */
>>   	if (id_entry->driver_data&  FEC_QUIRK_ENET_MAC)
>> @@ -866,6 +868,7 @@ static void fec_enet_adjust_link(struct net_devi=
ce *ndev)
>>   	if (phy_dev->link) {
>>   		if (fep->full_duplex !=3D phy_dev->duplex) {
>>   			fec_restart(ndev, phy_dev->duplex);
>> +			netif_wake_queue(dev);
>>   			status_change =3D 1;
>>   		}
>>   	}
>
>

I'm no network driver expert so I'll leave it up to others to comment. =
I just forward=20
ported a patch I came across in Freescale's BSP which solves the proble=
m in mainline=20
and in RT.
--=20
H=C3=A9ctor Palacios
