From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] mv643xx_eth: hook up skb recycling
Date: Thu, 04 Sep 2008 06:50:22 +0200
Message-ID: <48BF690E.7090501@cosmosbay.com>
References: <1220450101-21317-1-git-send-email-buytenh@wantstofly.org> <1220450101-21317-3-git-send-email-buytenh@wantstofly.org> <48BE9E5E.2010702@cosmosbay.com> <20080904042005.GA27272@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dale@farnsworth.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([80.12.242.26]:32754 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261AbYIDEvG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 00:51:06 -0400
In-Reply-To: <20080904042005.GA27272@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek a =E9crit :
> On Wed, Sep 03, 2008 at 04:25:34PM +0200, Eric Dumazet wrote:
>=20
>>> This increases the maximum loss-free packet forwarding rate in
>>> routing workloads by typically about 25%.
>>>
>>> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
>> Interesting...
>>
>>> 	refilled =3D 0;
>>> 	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size=
) {
>>> 		struct sk_buff *skb;
>>> 		int unaligned;
>>> 		int rx;
>>>
>>> -		skb =3D dev_alloc_skb(skb_size + dma_get_cache_alignment() -=20
>>> 1);
>>> +		skb =3D __skb_dequeue(&mp->rx_recycle);
>> Here you take one skb at the head of queue
>>
>>> +		if (skb =3D=3D NULL)
>>> +			skb =3D dev_alloc_skb(mp->skb_size +
>>> +					    dma_get_cache_alignment() - 1);
>>> +
>>> 		if (skb =3D=3D NULL) {
>>> 			mp->work_rx_oom |=3D 1 << rxq->index;
>>> 			goto oom;
>>> @@ -600,8 +591,8 @@ static int rxq_refill(struct rx_queue *rxq, int=
 budget)
>>> 			rxq->rx_used_desc =3D 0;
>>>
>>> 		rxq->rx_desc_area[rx].buf_ptr =3D dma_map_single(NULL,=20
>>> 		skb->data,
>>> -						skb_size, DMA_FROM_DEVICE);
>>> -		rxq->rx_desc_area[rx].buf_size =3D skb_size;
>>> +						mp->skb_size,=20
>>> DMA_FROM_DEVICE);
>>> +		rxq->rx_desc_area[rx].buf_size =3D mp->skb_size;
>>> 		rxq->rx_skb[rx] =3D skb;
>>> 		wmb();
>>> 		rxq->rx_desc_area[rx].cmd_sts =3D BUFFER_OWNED_BY_DMA |
>>> @@ -905,8 +896,13 @@ static int txq_reclaim(struct tx_queue *txq, i=
nt=20
>>> budget, int force)
>>> 		else
>>> 			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
>>>
>>> -		if (skb)
>>> -			dev_kfree_skb(skb);
>>> +		if (skb !=3D NULL) {
>>> +			if (skb_queue_len(&mp->rx_recycle) < 1000 &&
>>> +			    skb_recycle_check(skb, mp->skb_size))
>>> +				__skb_queue_tail(&mp->rx_recycle, skb);
>>> +			else
>>> +				dev_kfree_skb(skb);
>>> +		}
>> Here you put a skb at the head of queue. So you use a FIFO mode.

Here, I meant "tail of queue", you obviously already corrected this :)=20

>>
>> To have best performance (cpu cache hot), you might try to use a LIF=
O mode=20
>> (use __skb_queue_head()) ?
>=20
> That sounds like a good idea.  I'll try that, thanks.
>=20
>=20
>> Could you give us your actual bench results (number of packets recei=
ved per=20
>> second, number of transmited packets per second), and your machine s=
etup.
>=20
> mv643xx_eth isn't your typical PCI network adapter, it's a silicon
> block that is found in PPC/MIPS northbridges and in ARM System-on-Chi=
ps
> (SoC =3D CPU + peripherals integrated in one chip).
>=20
> The particular platform I did these tests on is a wireless access
> point.  It has an ARM SoC running at 1.2 GHz, with relatively small
> (16K/16K) L1 caches, 256K of L2 cache, and DDR2-400 memory, and a
> hardware switch chip.  Networking is hooked up as follows:
>=20
> 	+-----------+       +-----------+
> 	|           |       |           |
> 	|           |       |           +------ 1000baseT MDI ("WAN")
> 	|           | RGMII |  6-port   +------ 1000baseT MDI ("LAN1")
> 	|    CPU    +-------+  ethernet +------ 1000baseT MDI ("LAN2")
> 	|           |       |  switch   +------ 1000baseT MDI ("LAN3")
> 	|           |       |  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> 	|           |       |           |
> 	+-----------+       +-----------+
>=20
> The protocol that the ethernet switch speaks is called DSA
> ("Distributed Switch Architecture"), which is basically just ethernet
> with a header that's inserted between the ethernet header and the dat=
a
> (just like 802.1q VLAN tags) telling the switch what to do with the
> packet.  (I hope to submit the DSA driver I am writing soon.)  But fo=
r
> these purposes of this test, the switch chip is in pass-through mode,
> where DSA tagging is not used and the switch behaves like an ordinary
> 6-port ethernet chip.
>=20
> The network benchmarks are done with a Smartbits 600B traffic
> generator/measurement device.  What it does is a bisection search of
> sending traffic at different packet-per-second rates to pin down the
> maximum loss-free forwarding rate, i.e. the maximum packet rate at
> which there is still no packet loss.
>=20
> My notes say that before recycling (i.e. with all the mv643xx_eth
> patches I posted yesterday), the typical rate was 191718 pps, and
> after, 240385 pps.  The 2.6.27 version of the driver gets ~130kpps.
> (The different injection rates are achieved by varying the inter-pack=
et
> gap at byte granularities, so you don't get nice round numbers.)
>=20
> Those measurements were made more than a week ago, though, and my
> mv643xx_eth patch stack has seen a lot of splitting and reordering an=
d
> recombining and rewriting since then, so I'm not sure if those number=
s
> are accurate anymore.  I'll do some more benchmarks when I get access
> to the smartbits again.  Also, I'll get TX vs. RX curves if you care
> about those.
>=20
> (The same hardware has been seen to do ~300 kpps or ~380 kpps or ~850
> kpps depending on how much of the networking stack you bypass, but I'=
m
> trying to find ways to optimise the routing throughput without
> bypassing the stack, i.e. while retaining full functionality.)

Thanks a lot for this detailed informations, definitly usefull !

As a slide note, you have an arbitrary long limit on rx_recycle queue l=
ength (1000),
maybe you could use rx_ring_size instead.




