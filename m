From: Daniel Turull <daniel.turull@gmail.com>
Subject: Re: [PATCH 2/2] pktgen: receive packets and process incoming rate
Date: Thu, 10 Jun 2010 16:04:48 +0200
Message-ID: <4C10F100.3080503@gmail.com>
References: <4C06453B.1080801@gmail.com> <1275483650.2725.173.camel@edumazet-laptop> <4C065C7C.4000506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, robert@herjulf.net, jens.laas@its.uu.se,
	vorabit@kth.se
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34010 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758970Ab0FJOEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 10:04:43 -0400
Received: by bwz7 with SMTP id 7so77355bwz.19
        for <netdev@vger.kernel.org>; Thu, 10 Jun 2010 07:04:41 -0700 (PDT)
In-Reply-To: <4C065C7C.4000506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've made some modification to the patch. I'll send another email with =
the patch,
but I want to comment some things

Daniel Turull wrote:
> Eric Dumazet wrote:
>> Le mercredi 02 juin 2010 =C3=A0 13:49 +0200, Daniel Turull a =C3=A9c=
rit :
>>> This patch adds receiver part to pktgen taking advantages of SMP sy=
stems
>>> with multiple rx queues:
>>> - Creation of new proc file  /proc/net/pktgen/pgrx to control and d=
isplay the receiver.
>>> - It uses PER-CPU variable to store the results per each CPU.
>>> - Results displayed per CPU and aggregated.
>>> - The packet handler is add in the protocols handlers (dev_Add_pack=
())
>>> - Available statistics: packets and bytes received, work time and r=
ate
>>> - Only process pktgen packets
>>> - It is possible to select the incoming interface=20
>>> - Documentation updated with the new commands to control the receiv=
er part.
>>>
>> Interesting, but does it belongs to pktgen ?
>=20
> Yes, it allows to receive a feedback of pktgen of the traffic receive=
d which comes from pktgen. It is an addition for pktgen. By default is =
disabled.
>=20
>> other comments included :)
>>
>>> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
>>>
>>
>>> =20
>>> +/*Recevier parameters per cpu*/
>>> +struct pktgen_rx {
>>> +	u64 rx_packets;		/*packets arrived*/
>> unsigned long rx_packets ?
> Yes, I used the same type as the number of packets send of the transm=
ission size
> struct pktgen_dev
> 	__u64 sofar;
>=20
>=20
>>> +	u64 rx_bytes;		/*bytes arrived*/
>>> +
>>> +	ktime_t start_time;	/*first time stamp of a packet*/
>>> +	ktime_t last_time;	/*last packet arrival */
>>> +};
>>
>>> +int pktgen_rcv_basic(struct sk_buff *skb, struct net_device *dev,
>>> +			 struct packet_type *pt, struct net_device *orig_dev)
>>> +{
>>> +	/* Check magic*/
>>> +	struct iphdr *iph =3D ip_hdr(skb);
>>> +	struct pktgen_hdr *pgh;
>>> +	void *vaddr;
>> Following code is ... well ... interesting... But ...
>>
>> 1) Is it IPV6 compatable ? pktgen can be ipv6 or ipv4
> It is not IPV6 compatible yet.=20

In order to make it to ipv6 compatible it will be better to create a ne=
w packet=20
handler for the ipv6, because a different struct is need.
>> 2) Is it resistant to malicious packets ? (very small ones)
> I only tried with pktgen traffic

Pktgen is used in experimental environments. In order to start the rece=
iver is necessary=20
to load the module and enable the reception with the proc file system.
>> 3) No checksum ?
> The PKTGEN_MAGIC is checked in order to validate that is a pktgen pac=
ket
>=20
>> I think you should use standard mechanisms... (pskb_may_pull(), ...)
>> Take a look at __netpoll_rx() for an example.
>=20

Now I'm using pskb_may_pull() but the performance is reduced.=20
>>> +	if (skb_is_nonlinear(skb)) {
>>> +		vaddr =3D kmap_skb_frag(&skb_shinfo(skb)->frags[0]);
>>> +		pgh =3D (struct pktgen_hdr *)
>>> +			(vaddr+skb_shinfo(skb)->frags[0].page_offset);
>>> +	} else {
>>> +		pgh =3D (struct pktgen_hdr *)(((char *)(iph)) + 28);
>>> +	}
>>> +
>>> +	if (unlikely(pgh->pgh_magic !=3D PKTGEN_MAGIC_NET))
>>> +		goto end;
>>> +
>>> +	if (unlikely(!__get_cpu_var(pktgen_rx_data).rx_packets))
>>> +		__get_cpu_var(pktgen_rx_data).start_time =3D ktime_now();
>>> +
>>> +	__get_cpu_var(pktgen_rx_data).last_time =3D ktime_now();
>>> +
>> Its a bit suboptimal to use __get_cpu_var several time. Take a look =
at
>> disassembly code :)
>>
>> Use a pointer instead
>=20
> Ok, thanks for the advice. I will redo this part in order to make it =
compatabile with IPV6 and make it more optimal.

Changed.

>>> +	/* Update counter of packets*/
>>> +	__get_cpu_var(pktgen_rx_data).rx_packets++;
>>> +	__get_cpu_var(pktgen_rx_data).rx_bytes +=3D skb->len+14;
>> This +14 seems suspect (what about vlan tags ?)
>> Use ETH_HLEN instead at a very minimum?
>=20
> This was added, in order to add the ethernet header in the bytes in o=
rder to have the same number in tx an rx, but yes I should use ETH_HLEN
>=20

I changed the 14 to ETH_HLEN. The VLAN, mpls overheads are not computed=
 in this statistics because in the transmission, only the packet size i=
ntroduced is counted.
>>> +end:
>>> +	if (skb_is_nonlinear(skb))
>>> +		kunmap_skb_frag(vaddr);
>> Should not recognised packets be allowed to flight in other parts of
>> kernel stack ? This way, we could use ssh to remotely control this
>> pktgen session ;)
>=20
> This handler as a new packet type, but the packets are also delivered=
 to the IP stack.  It is possible to control the session with ssh.
>=20
>>> +	kfree_skb(skb);
>>> +	return 0;
>>> +}
>>> +
>=20

