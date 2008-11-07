From: Andre Schwarz <andre.schwarz@matrix-vision.de>
Subject: Re: Questions on kernel skb send / netdev queue monitoring
Date: Fri, 07 Nov 2008 10:39:05 +0100
Message-ID: <49140CB9.3000203@matrix-vision.de>
References: <2009170231@web.de> <4911E661.6030701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixvision.de ([217.160.213.229]:3043 "EHLO
	p15137414.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbYKGJjJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 04:39:09 -0500
In-Reply-To: <4911E661.6030701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

thanks for your reply, but there are still open questions.


Eric Dumazet schrieb:
> Andre Schwarz a =E9crit :
>> Hi,
>>
>> we're running 2.6.27 on a MPC8343 based board.
>> The board is working as a camera and is supposed to stream image dat=
a
>> over 1000M Ethernet.
>>
>> Ethernet is connected via 2x Vitesse VSC8601 RGMII PHY, i.e. "eth0" =
and
>> "eth1" present.
>>
>> Basically the system is running fine for quite some time - starting =
with
>> kernel 2.6.19.
>> Lately I have some trouble regarding performance and errors.
>>
>> Obviously I'm doing something wrong ... hopefully someone can
>> enlighten me.
>>
>>
>> How the system works :
>>
>> - Kernel driver allocates static list of skb to hold a complete imag=
e.
>> This can be up to 4k skb depending on mtu.
>> - Imaging device (FPGA @ PCI) initiates DMA into skb.
>> - driver sends the skb out.
>>
>>
>> 1. Sending
>>
>> This is my "inner loop" send function and is called for every skb in=
 the
>> list.
>>
>> static inline int gevss_send_get_ehdr(TGevStream *gevs, struct
>> sk_buff *skb)
>> {
>>         int result;
>>         struct sk_buff *slow_skb =3D skb_clone(skb, GFP_ATOMIC);
>>
>>         atomic_inc(&slow_skb->users);
>>         result =3D gevs->rt->u.dst.output(slow_skb);
>>         kfree_skb(slow_skb);
>>
>>         return result;
>> }
>>
>> Is there really any need for cloning each skb before sending ?
>> I'd really like to send the static skb without consuming it. How can
>> this be done ?
>>
>
> You have replied to yourself... you clone skb because you want to kee=
p
> skb.
>
As long as this is the fastest way. Wouldn't be a simple use count
increment better ?
Why is incrementing the user count before sending not working ?
>> Is "gevs->rt->u.dst.output(slow_skb)" reasonable ?
>> What about "hard_start_xmit" and/or "dev_queue_xmit" inside netdev ?
>> Are these functions supposed to be used by other drivers ?
>>
>> What result can I expect if there's a failure, i.e. the HW-queue is
>> full ?
>> How should this be handled ? retry,i.e. send again after a while ?
>> Can I query the xmit queue size/usage ?
>>
>> Actually I'm checking for NETDEV_TX_OK and NETDEV_TX_BUSY.
>> Is this reasonable ?
>>
>>
>> 2. "overruns"
>>
>> I've never seen that before. The overrun counter is incrementing qui=
te
>> fast even during proper operation.
>> Looks like this is also an issue with not throttling the sender when=
 the
>> xmit queue is full ...  :-( How can I avoid this ?
>>
>> eth0      Link encap:Ethernet  HWaddr 00:0C:8D:30:40:25
>>           inet addr:192.168.65.55  Bcast:192.168.65.255=20
>> Mask:255.255.255.0
>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>           RX packets:929 errors:0 dropped:0 overruns:0 frame:0
>>           TX packets:180937 errors:0 dropped:0 overruns:54002
>> carrier:0             collisions:0 txqueuelen:1000
>>           RX bytes:65212 (63.6 KiB)  TX bytes:262068658 (249.9 MiB)
>>           Base address:0xa000
>
> If your driver has to push 4096 skb at once, and you dont want to
> handle overruns,
> you might need to change eth0 settings
>
> ifconfig eth0 txqueuelen 5000
>
ok - but I definitely want to handle overruns or at least get notified
when the queue is almost full.
Querying the queue status would be fine, also.

Since I have data sources capable of delivering much more than 125MB
_any_ queue will overflow sooner or later without some kind of flow con=
trol.
Can you tell me how the txqueue can be monitored ?


regards,
Andre



MATRIX VISION GmbH, Talstra=DFe 16, DE-71570 Oppenweiler  - Registerger=
icht: Amtsgericht Stuttgart, HRB 271090
Gesch=E4ftsf=FChrer: Gerhard Thullner, Werner Armingeon, Uwe Furtner
