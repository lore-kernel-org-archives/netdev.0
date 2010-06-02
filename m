From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] pktgen: receive packets and process incoming rate
Date: Wed, 02 Jun 2010 15:00:50 +0200
Message-ID: <1275483650.2725.173.camel@edumazet-laptop>
References: <4C06453B.1080801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, robert@herjulf.net, jens.laas@its.uu.se
To: Daniel Turull <daniel.turull@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:45229 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756305Ab0FDUzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 16:55:43 -0400
Received: by wwb28 with SMTP id 28so1192781wwb.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 13:55:42 -0700 (PDT)
In-Reply-To: <4C06453B.1080801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 13:49 +0200, Daniel Turull a =C3=A9crit=
 :
> This patch adds receiver part to pktgen taking advantages of SMP syst=
ems
> with multiple rx queues:
> - Creation of new proc file  /proc/net/pktgen/pgrx to control and dis=
play the receiver.
> - It uses PER-CPU variable to store the results per each CPU.
> - Results displayed per CPU and aggregated.
> - The packet handler is add in the protocols handlers (dev_Add_pack()=
)
> - Available statistics: packets and bytes received, work time and rat=
e
> - Only process pktgen packets
> - It is possible to select the incoming interface=20
> - Documentation updated with the new commands to control the receiver=
 part.
>=20

Interesting, but does it belongs to pktgen ?

other comments included :)

> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
>=20


> =20
> +/*Recevier parameters per cpu*/
> +struct pktgen_rx {
> +	u64 rx_packets;		/*packets arrived*/

unsigned long rx_packets ?

> +	u64 rx_bytes;		/*bytes arrived*/
> +
> +	ktime_t start_time;	/*first time stamp of a packet*/
> +	ktime_t last_time;	/*last packet arrival */
> +};


> +int pktgen_rcv_basic(struct sk_buff *skb, struct net_device *dev,
> +			 struct packet_type *pt, struct net_device *orig_dev)
> +{
> +	/* Check magic*/
> +	struct iphdr *iph =3D ip_hdr(skb);
> +	struct pktgen_hdr *pgh;
> +	void *vaddr;

=46ollowing code is ... well ... interesting... But ...

1) Is it IPV6 compatable ? pktgen can be ipv6 or ipv4
2) Is it resistant to malicious packets ? (very small ones)
3) No checksum ?

I think you should use standard mechanisms... (pskb_may_pull(), ...)
Take a look at __netpoll_rx() for an example.

> +	if (skb_is_nonlinear(skb)) {
> +		vaddr =3D kmap_skb_frag(&skb_shinfo(skb)->frags[0]);
> +		pgh =3D (struct pktgen_hdr *)
> +			(vaddr+skb_shinfo(skb)->frags[0].page_offset);
> +	} else {
> +		pgh =3D (struct pktgen_hdr *)(((char *)(iph)) + 28);
> +	}
> +
> +	if (unlikely(pgh->pgh_magic !=3D PKTGEN_MAGIC_NET))
> +		goto end;
> +
> +	if (unlikely(!__get_cpu_var(pktgen_rx_data).rx_packets))
> +		__get_cpu_var(pktgen_rx_data).start_time =3D ktime_now();
> +
> +	__get_cpu_var(pktgen_rx_data).last_time =3D ktime_now();
> +

Its a bit suboptimal to use __get_cpu_var several time. Take a look at
disassembly code :)

Use a pointer instead


> +	/* Update counter of packets*/
> +	__get_cpu_var(pktgen_rx_data).rx_packets++;
> +	__get_cpu_var(pktgen_rx_data).rx_bytes +=3D skb->len+14;

This +14 seems suspect (what about vlan tags ?)
Use ETH_HLEN instead at a very minimum?

> +end:
> +	if (skb_is_nonlinear(skb))
> +		kunmap_skb_frag(vaddr);

Should not recognised packets be allowed to flight in other parts of
kernel stack ? This way, we could use ssh to remotely control this
pktgen session ;)

> +	kfree_skb(skb);
> +	return 0;
> +}
> +

