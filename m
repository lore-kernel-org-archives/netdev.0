From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4/6] net/macb: add RX checksum offload feature
Date: Tue, 22 Jul 2014 09:39:15 -0700
Message-ID: <CAGVrzca2YWZkVkUs_c06ApXrE3hdDgbsC7-6x2M4DS-Qn6S0aQ@mail.gmail.com>
References: <cover.1405689937.git.cyrille.pitchen@atmel.com>
 <f29965fee23dc0de99b388373017efeffa1aac10.1405689937.git.cyrille.pitchen@atmel.com>
 <1405697784.10255.99.camel@edumazet-glaptop2.roam.corp.google.com> <53CE9109.9040407@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>, soren.brinkmann@xilinx.com
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53CE9109.9040407@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-07-22 9:27 GMT-07:00 Cyrille Pitchen <cyrille.pitchen@atmel.com>:
> Le 18/07/2014 17:36, Eric Dumazet a =C3=A9crit :
>> On Fri, 2014-07-18 at 16:21 +0200, Cyrille Pitchen wrote:
>>> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
>>> ---
>>>  drivers/net/ethernet/cadence/macb.c | 29 +++++++++++++++++++++++++=
+++-
>>>  drivers/net/ethernet/cadence/macb.h |  2 ++
>>>  2 files changed, 30 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethe=
rnet/cadence/macb.c
>>> index 9bdcd1b..6acd6e2 100644
>>> --- a/drivers/net/ethernet/cadence/macb.c
>>> +++ b/drivers/net/ethernet/cadence/macb.c
>>> @@ -766,6 +766,8 @@ static int gem_rx(struct macb *bp, int budget)
>>>
>>>              skb->protocol =3D eth_type_trans(skb, bp->dev);
>>>              skb_checksum_none_assert(skb);
>>> +            if (bp->dev->features & NETIF_F_RXCSUM)
>>> +                    skb->ip_summed =3D CHECKSUM_UNNECESSARY;
>>>
>>
>>
>> Really ?
>>
>> If this is what you meant, this deserves a big and fat comment.
>>
>>
>>
> Hi Eric,
>
> Isn't it the proper way to do? According to Cadence documentation abo=
ut RX checksum offload:
> "If any of the checksums (IP, TCP or UDP) are verified incorrect by t=
he GEM, the packet is discarded."
>
> If I understand, when RX checksum offload is enabled setting bit 24 o=
f the Network Configuration Register, the driver only receives RX frame=
s with correct checksum. Then it tells the kernel that there's no need =
to verify the checksum again in software. This is done setting skb->ip_=
summed to CHECKSUM_UNNECESSARY. Intel e1000 driver does the same in e10=
00_rx_checksum() function.

This is not the same thing as what the e1000 driver is doing, the
e1000 driver is checking a per-packet status mask which tells it
whether a given packet had its protocol level checksum computed by the
HW.

I think there might be some slight confusion here between the Ethernet
frame Frame Control Checksum which is at the Ethernet level, and will
(with most adapters not supporting RX_FCS_ERR) cause the Ethernet
controller to drop frames at the MAC level, and the higher level
protocol checksums such as the TCP or UDP checksum.

>
> Also bit 24 of the Network Configuration Register is updated by macb_=
open() and macb_set_features() so it always matches the state of NETIF_=
=46_RXCSUM flag in dev->features, once the network interface is up. Tha=
t's why I'd rather read from dev->features than read from register.

I don't think the Cadence GEM Ethernet controller is any different
than other hardware out there, there must be a per-packet status bit
which tells whether the TCP/UDP or other protocol checksum was
successfully validated by the hardware. One of the reason for that, is
that depending on the type of traffic your receive (e.g: ARP), there
might be no protocol-level checksum at all in the packet, and the
hardware should know about that.

>
> Did I make a mistake? Is it the kind of comment you expect to be adde=
d?
>
> Regards,
>
> Cyrille
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



--=20
=46lorian
