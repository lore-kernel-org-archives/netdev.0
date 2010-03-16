From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Tue, 16 Mar 2010 16:50:33 +0200
Message-ID: <20100316145033.GA3332@swordfish.minsk.epam.com>
References: <20100307192305.GA598@elte.hu>
 <20100308125122.GA11242@redhat.com>
 <1268686865.2824.4.camel@edumazet-laptop>
 <1268699602.2824.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="u3/rZRmxL6MmkK24"
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1268699602.2824.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

Eric, I did pktgen testing (3 times).

sudo cat /proc/net/pktgen/eth0=20
Params: count 1000000000  min_pkt_size: 42  max_pkt_size: 42
     frags: 0  delay: 0  clone_skb: 4000000  ifname: eth0
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 10.6.22.59  dst_max:=20
        src_min:   src_max:=20
     src_mac: 00:1a:92:c9:a0:68 dst_mac: 00:1a:92:c9:a0:68
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:=20
Current:
     pkts-sofar: 1000000000  errors: 0
     started: 9957912410us  stopped: 16682620361us idle: 1231us
     seq_num: 1000000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x3b16060a  cur_daddr: 0x3b16060a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 6724707951(c6724706719+d1231) nsec, 1000000000 (42byte,0frags)
  148705pps 49Mb/sec (49964880bps) errors: 0


Without any errors from the r8169 side. Can we consider testing successful?
If so, fell free to add Tested-by: Sergey Senozhatsky <sergey.senozhatsky@g=
mail.com>


	Sergey



On (03/16/10 01:33), Eric Dumazet wrote:
> > Yes, this is wrong. In this context (process context, not softirq), we
> > should use netif_rx() or just drop frames if we are in reset phase.
> >=20
>=20
> Sergey,
>=20
> Here is a compiled but untested patch (I dont have the hardware), could
> you please test it ?
>=20
> Thanks
>=20
> [PATCH] r8169: Fix rtl8169_rx_interrupt()
>=20
> In case a reset is performed, rtl8169_rx_interrupt() is called from
> process context instead of softirq context. Special care must be taken
> to call appropriate network core services (netif_rx() instead of
> netif_receive_skb()). VLAN handling also corrected.
>=20
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Diagnosed-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 9d3ebf3..d873639 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1038,14 +1038,14 @@ static void rtl8169_vlan_rx_register(struct net_d=
evice *dev,
>  }
> =20
>  static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc=
 *desc,
> -			       struct sk_buff *skb)
> +			       struct sk_buff *skb, int polling)
>  {
>  	u32 opts2 =3D le32_to_cpu(desc->opts2);
>  	struct vlan_group *vlgrp =3D tp->vlgrp;
>  	int ret;
> =20
>  	if (vlgrp && (opts2 & RxVlanTag)) {
> -		vlan_hwaccel_receive_skb(skb, vlgrp, swab16(opts2 & 0xffff));
> +		__vlan_hwaccel_rx(skb, vlgrp, swab16(opts2 & 0xffff), polling);
>  		ret =3D 0;
>  	} else
>  		ret =3D -1;
> @@ -1062,7 +1062,7 @@ static inline u32 rtl8169_tx_vlan_tag(struct rtl816=
9_private *tp,
>  }
> =20
>  static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc=
 *desc,
> -			       struct sk_buff *skb)
> +			       struct sk_buff *skb, int polling)
>  {
>  	return -1;
>  }
> @@ -4429,12 +4429,20 @@ out:
>  	return done;
>  }
> =20
> +/*
> + * Warning : rtl8169_rx_interrupt() might be called :
> + * 1) from NAPI (softirq) context
> + *	(polling =3D 1 : we should call netif_receive_skb())
> + * 2) from process context (rtl8169_reset_task())
> + *	(polling =3D 0 : we must call netif_rx() instead)
> + */	=09
>  static int rtl8169_rx_interrupt(struct net_device *dev,
>  				struct rtl8169_private *tp,
>  				void __iomem *ioaddr, u32 budget)
>  {
>  	unsigned int cur_rx, rx_left;
>  	unsigned int delta, count;
> +	int polling =3D (budget !=3D ~(u32)0) ? 1 : 0;
> =20
>  	cur_rx =3D tp->cur_rx;
>  	rx_left =3D NUM_RX_DESC + tp->dirty_rx - cur_rx;
> @@ -4496,8 +4504,12 @@ static int rtl8169_rx_interrupt(struct net_device =
*dev,
>  			skb_put(skb, pkt_size);
>  			skb->protocol =3D eth_type_trans(skb, dev);
> =20
> -			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
> -				netif_receive_skb(skb);
> +			if (rtl8169_rx_vlan_skb(tp, desc, skb, polling) < 0) {
> +				if (likely(polling))
> +					netif_receive_skb(skb);
> +				else
> +					netif_rx(skb);
> +			}
> =20
>  			dev->stats.rx_bytes +=3D pkt_size;
>  			dev->stats.rx_packets++;
>=20
>=20

--u3/rZRmxL6MmkK24
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkufmrkACgkQfKHnntdSXjT0zgP/eycACnlxJzjDlrNqyFgb9hC/
HOgxTL2+eVi7wqgrurxIwCDMiHmuyRd86Yrwk3xo5rRyAl3UbE/ysCriozw59Kwk
Ag1LYov18AY//sEzSvWOE3veR0JGMymwEUBdnv8HxpDnyPXgp4ddQZFGHhGGzFp3
SDgLfrU/yP8yzaefORk=
=TrtZ
-----END PGP SIGNATURE-----

--u3/rZRmxL6MmkK24--
