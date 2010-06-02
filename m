From: Daniel Turull <daniel.turull@gmail.com>
Subject: Re: [PATCH 2/2] pktgen: receive packets and process incoming rate
Date: Wed, 02 Jun 2010 15:28:28 +0200
Message-ID: <4C065C7C.4000506@gmail.com>
References: <4C06453B.1080801@gmail.com> <1275483650.2725.173.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, robert@herjulf.net, jens.laas@its.uu.se
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38193 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754989Ab0FBN21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:28:27 -0400
Received: by fxm8 with SMTP id 8so1849145fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 06:28:26 -0700 (PDT)
In-Reply-To: <1275483650.2725.173.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mercredi 02 juin 2010 =C3=A0 13:49 +0200, Daniel Turull a =C3=A9cr=
it :
>> This patch adds receiver part to pktgen taking advantages of SMP sys=
tems
>> with multiple rx queues:
>> - Creation of new proc file  /proc/net/pktgen/pgrx to control and di=
splay the receiver.
>> - It uses PER-CPU variable to store the results per each CPU.
>> - Results displayed per CPU and aggregated.
>> - The packet handler is add in the protocols handlers (dev_Add_pack(=
))
>> - Available statistics: packets and bytes received, work time and ra=
te
>> - Only process pktgen packets
>> - It is possible to select the incoming interface=20
>> - Documentation updated with the new commands to control the receive=
r part.
>>
>=20
> Interesting, but does it belongs to pktgen ?

Yes, it allows to receive a feedback of pktgen of the traffic received =
which comes from pktgen. It is an addition for pktgen. By default is di=
sabled.

> other comments included :)
>=20
>> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
>>
>=20
>=20
>> =20
>> +/*Recevier parameters per cpu*/
>> +struct pktgen_rx {
>> +	u64 rx_packets;		/*packets arrived*/
>=20
> unsigned long rx_packets ?
Yes, I used the same type as the number of packets send of the transmis=
sion size
struct pktgen_dev
	__u64 sofar;


>> +	u64 rx_bytes;		/*bytes arrived*/
>> +
>> +	ktime_t start_time;	/*first time stamp of a packet*/
>> +	ktime_t last_time;	/*last packet arrival */
>> +};
>=20
>=20
>> +int pktgen_rcv_basic(struct sk_buff *skb, struct net_device *dev,
>> +			 struct packet_type *pt, struct net_device *orig_dev)
>> +{
>> +	/* Check magic*/
>> +	struct iphdr *iph =3D ip_hdr(skb);
>> +	struct pktgen_hdr *pgh;
>> +	void *vaddr;
>=20
> Following code is ... well ... interesting... But ...
>=20
> 1) Is it IPV6 compatable ? pktgen can be ipv6 or ipv4
It is not IPV6 compatible yet.=20
> 2) Is it resistant to malicious packets ? (very small ones)
I only tried with pktgen traffic
> 3) No checksum ?
The PKTGEN_MAGIC is checked in order to validate that is a pktgen packe=
t

> I think you should use standard mechanisms... (pskb_may_pull(), ...)
> Take a look at __netpoll_rx() for an example.

>> +	if (skb_is_nonlinear(skb)) {
>> +		vaddr =3D kmap_skb_frag(&skb_shinfo(skb)->frags[0]);
>> +		pgh =3D (struct pktgen_hdr *)
>> +			(vaddr+skb_shinfo(skb)->frags[0].page_offset);
>> +	} else {
>> +		pgh =3D (struct pktgen_hdr *)(((char *)(iph)) + 28);
>> +	}
>> +
>> +	if (unlikely(pgh->pgh_magic !=3D PKTGEN_MAGIC_NET))
>> +		goto end;
>> +
>> +	if (unlikely(!__get_cpu_var(pktgen_rx_data).rx_packets))
>> +		__get_cpu_var(pktgen_rx_data).start_time =3D ktime_now();
>> +
>> +	__get_cpu_var(pktgen_rx_data).last_time =3D ktime_now();
>> +
>=20
> Its a bit suboptimal to use __get_cpu_var several time. Take a look a=
t
> disassembly code :)
>=20
> Use a pointer instead

Ok, thanks for the advice. I will redo this part in order to make it co=
mpatabile with IPV6 and make it more optimal.
>=20
>> +	/* Update counter of packets*/
>> +	__get_cpu_var(pktgen_rx_data).rx_packets++;
>> +	__get_cpu_var(pktgen_rx_data).rx_bytes +=3D skb->len+14;
>=20
> This +14 seems suspect (what about vlan tags ?)
> Use ETH_HLEN instead at a very minimum?

This was added, in order to add the ethernet header in the bytes in ord=
er to have the same number in tx an rx, but yes I should use ETH_HLEN

>> +end:
>> +	if (skb_is_nonlinear(skb))
>> +		kunmap_skb_frag(vaddr);
>=20
> Should not recognised packets be allowed to flight in other parts of
> kernel stack ? This way, we could use ssh to remotely control this
> pktgen session ;)

This handler as a new packet type, but the packets are also delivered t=
o the IP stack.  It is possible to control the session with ssh.

>> +	kfree_skb(skb);
>> +	return 0;
>> +}
>> +
>=20

