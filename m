From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 03 Sep 2010 11:00:52 +0300
Message-ID: <4C80AB34.20501@fs.uni-ruse.bg>
References: <4LwrqITm-eJ.A.r8G.eFueMB@chimera>	 <4AUWBNzTkbD.A.ey.cGueMB@chimera> <courier.4C7C99F2.00001F74@fs.ru.acad.bg>	 <20100831192659.GA3093@del.dom.local> <1283338251.2556.124.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:44776 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753457Ab0ICIA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 04:00:56 -0400
In-Reply-To: <1283338251.2556.124.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 01.9.2010 =D0=B3. 13:50, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> Plamen, could you test following patch ?
>
> I reproduced problem on a dev machine and following patch cured it.
>
> Thanks
>
> [PATCH] gro: fix different skb headrooms
>
> packets entering GRO might have different headrooms, even for a given
> flow (because of implementation details in drivers, like copybreak).
> We cant force drivers to deliver packets with a fixed headroom.
>
> 1) fix skb_segment()
>
> skb_segment() makes the false assumption headrooms of fragments are s=
ame
> than the head. When CHECKSUM_PARTIAL is used, this can give csum_star=
t
> errors, and crash later in skb_copy_and_csum_dev()
>
> 2) allocate a minimal skb for head of frag_list
>
> skb_gro_receive() uses netdev_alloc_skb(headroom + skb_gro_offset(p))=
 to
> allocate a fresh skb. This adds NET_SKB_PAD to a padding already
> provided by netdevice, depending on various things, like copybreak.
>
> Use alloc_skb() to allocate an exact padding, to reduce cache line
> needs:
> NET_SKB_PAD + NET_IP_ALIGN
>
> bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=3D16626
>
> Many thanks to Plamen Petrov, testing many debugging patches !
> With help of Jarek Poplawski.
>
> Reported-by: Plamen Petrov<pvp-lsts@fs.uni-ruse.bg>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> CC: Jarek Poplawski<jarkao2@gmail.com>
> ---
> patch against linux-2.6 current tree
>
>   net/core/skbuff.c |    8 ++++++--
>   1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3a2513f..26396ff 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2573,6 +2573,10 @@ struct sk_buff *skb_segment(struct sk_buff *sk=
b, int features)
>   		__copy_skb_header(nskb, skb);
>   		nskb->mac_len =3D skb->mac_len;
>
> +		/* nskb and skb might have different headroom */
> +		if (nskb->ip_summed =3D=3D CHECKSUM_PARTIAL)
> +			nskb->csum_start +=3D skb_headroom(nskb) - headroom;
> +
>   		skb_reset_mac_header(nskb);
>   		skb_set_network_header(nskb, skb->mac_len);
>   		nskb->transport_header =3D (nskb->network_header +
> @@ -2702,8 +2706,8 @@ int skb_gro_receive(struct sk_buff **head, stru=
ct sk_buff *skb)
>   	} else if (skb_gro_len(p) !=3D pinfo->gso_size)
>   		return -E2BIG;
>
> -	headroom =3D skb_headroom(p);
> -	nskb =3D netdev_alloc_skb(p->dev, headroom + skb_gro_offset(p));
> +	headroom =3D NET_SKB_PAD + NET_IP_ALIGN;
> +	nskb =3D alloc_skb(headroom + skb_gro_offset(p), GFP_ATOMIC);
>   	if (unlikely(!nskb))
>   		return -ENOMEM;
>
>
>

I confirm that the above patch applied on top of v2.6.36-rc3 does not
show the problems that all the kernels since v2.6.35 (both stable
and Linus' tree) had.

My problematic machine has been running the patched 36-rc3 for 36 hours=
,=20
and couning, with "generic receive offload" enabled only my tg3 nic.

Thank you very much for the wonderful job, Eric!
Thanks to you, too, Jarek!

Plamen Petrov
