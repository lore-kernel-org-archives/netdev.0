From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 11/20] net: packetengines: slight optimization
 of addr
Date: Mon, 30 Dec 2013 10:39:51 +0800
Message-ID: <52C0DCF7.6040402@huawei.com>
References: <52BE6D0D.9050301@huawei.com>	 <52BED8ED.2040908@cogentembedded.com> <52BEEBD5.1040301@gmail.com> <1388251380.24123.15.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, Ding Tianhong <dthxman@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388251380.24123.15.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/12/29 1:23, Joe Perches wrote:
> On Sat, 2013-12-28 at 23:18 +0800, Ding Tianhong wrote:
>> =E4=BA=8E 2013/12/28 21:58, Sergei Shtylyov =E5=86=99=E9=81=93:
>>> Hello.
>>>
>>> On 28-12-2013 10:17, Ding Tianhong wrote:
>>>
>>>> Use possibly more efficient ether_addr_equal
>>>> to instead of memcmp.
>>>
>>>> Cc: "David S. Miller" <davem@davemloft.net>
>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>> ---
>>>>   drivers/net/ethernet/packetengines/yellowfin.c |   12 ++++++----=
--
>>>>   1 files changed, 6 insertions(+), 6 deletions(-)
>>>
>>>> diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/driv=
ers/net/ethernet/packetengines/yellowfin.c
>>>> index d28593b..b83ac0e 100644
>>>> --- a/drivers/net/ethernet/packetengines/yellowfin.c
>>>> +++ b/drivers/net/ethernet/packetengines/yellowfin.c
>>>> @@ -1097,12 +1097,12 @@ static int yellowfin_rx(struct net_device =
*dev)
>>>>               if (status2 & 0x80) dev->stats.rx_dropped++;
>>>>   #ifdef YF_PROTOTYPE        /* Support for prototype hardware err=
ata. */
>>>>           } else if ((yp->flags & HasMACAddrBug)  &&
>>>> -            memcmp(le32_to_cpu(yp->rx_ring_dma +
>>>> -                entry*sizeof(struct yellowfin_desc)),
>>>> -                dev->dev_addr, 6) !=3D 0 &&
>>>> -            memcmp(le32_to_cpu(yp->rx_ring_dma +
>>>> -                entry*sizeof(struct yellowfin_desc)),
>>>> -                "\377\377\377\377\377\377", 6) !=3D 0) {
>>>> +            !ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
>>>> +                              entry * sizeof(struct yellowfin_des=
c)),
>>>> +                              dev->dev_addr) &&
>>>
>>>    Previous line was aligned correctly, the above line should start=
 under le32_to_cpu.
>>>
>>>> +            !ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
>>>> +                              entry * sizeof(struct yellowfin_des=
c)),
>>>
>>>    Start the continuation lines under 'yp', please.
>>>
>>>> +                              "\377\377\377\377\377\377")) {
>>>
>>>    This line should start under le32_to_cpu.
>>>
>>> WBR, Sergei
>>>
>>
>> Hi sergei:
>> you mean this way?
>> 	!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
>> 				      entry * sizeof(struct yellowfin_desc)),
>> 			  dev->dev_addr) &&
>>
>> 	!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
>> 				      entry * sizeof(struct yellowfin_desc)),
>> 			  "\377\377\377\377\377\377")) {
>=20
> Does this really matter?
> Does anyone have a packetengine NIC anymore?
>=20
> \377 octal is 0xff, so this is matching a broadcast address.
> is_broadcast_ether_addr(addr) would be appropriate.
>=20
> So would using a temporary address.
>=20
> u8 *addr =3D (u8 *)(unsigned long)le32_to_cpu(etc)
>=20
> but the whole thing looks very suspect as an le32
> value could not be added to correctly on a
> big-endian arch anyway.
>=20
> My guess is this was tested only on an x86 and
> it should be:
>=20
> 	u8 *addr =3D (u8 *)(unsigned long)(le32_to_cpu(yp->rx_ring_dma) +
> 					 entry * sizeof(struct yellowfin_desc));
>=20
> It maybe better just to leave these two alone.
>=20

Hi Joe:

I don't understand packetengine NIC anymore, But I think the change is =
clearly,
as your said, the broadcast check is enough here, did you mean that?

	!is_broadcast_ether_addr((u8 *)(le32_to_cpu(yp->rx_ring_dma) +
						    entry * sizeof(struct yellowfin_desc)))

Thanks

Regards
Ding

>=20
> .
>=20
