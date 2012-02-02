From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Thu, 2 Feb 2012 23:42:44 +0200
Message-ID: <CAJZOPZJQo5+CDP3GQY-HMGP4sHCv9NTYY7+FtW7_nfZ4JeYAug@mail.gmail.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	<alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	<CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
	<4F264A6C.3070706@mellanox.com>
	<1327910672.2891.12.camel@edumazet-laptop>
	<20120130081849.GA7848@gondor.apana.org.au>
	<1327913583.2288.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120130085742.GA8262@gondor.apana.org.au>
	<CAJZOPZJb1HvcS0XXKLvoDuoi1EfYTY-awwY2g0aHWoS=4qmdyQ@mail.gmail.com>
	<20120201083837.GA7081@gondor.apana.org.au>
	<CAJZOPZJVAQoy0B30zqkROOBp_-bF6=EdU2L9V025fJgTexVuFQ@mail.gmail.com>
	<1328105262.2595.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4F2A974B.209@mellanox.com>
	<1328193495.2279.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328193865.2279.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-rdma <linux-rdma@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:40309 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932158Ab2BBVmo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 16:42:44 -0500
In-Reply-To: <1328193865.2279.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2012 at 4:44 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> > I guess changing hard_header_len might be difficult (for you).
> > Adding gro_mac_header_len sounds the easy way.
> > [ You'll need to set it in your device setup() ]

> Something like :

Hi Eric,

I will test this patch along with setting gro_mac_header_len in ipoib
and let you know

Or.

>
> =A0include/linux/netdevice.h | =A0 =A02 +-
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 +++++++++--
> =A02 files changed, 10 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0eac07c..99b12c4 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1095,7 +1095,7 @@ struct net_device {
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0mtu; =A0 =A0/* int=
erface MTU value =A0 =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0unsigned short =A0 =A0 =A0 =A0 =A0type; =A0 /* interfa=
ce hardware type =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0unsigned short =A0 =A0 =A0 =A0 =A0hard_header_len; =A0=
 =A0 =A0 =A0/* hardware hdr length =A0*/
> -
> + =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0gro_mac_header_len;
> =A0 =A0 =A0 =A0/* extra head- and tailroom the hardware may need, but=
 not in all cases
> =A0 =A0 =A0 =A0 * can this be guaranteed, especially tailroom. Some c=
ases also use
> =A0 =A0 =A0 =A0 * LL_MAX_HEADER instead to allocate the skb.
> diff --git a/net/core/dev.c b/net/core/dev.c
> index f124947..a3af7bc 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3491,14 +3491,20 @@ static inline gro_result_t
> =A0__napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0struct sk_buff *p;
> + =A0 =A0 =A0 unsigned int maclen =3D skb->dev->gro_mac_header_len;
>
> =A0 =A0 =A0 =A0for (p =3D napi->gro_list; p; p =3D p->next) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long diffs;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0diffs =3D (unsigned long)p->dev ^ (uns=
igned long)skb->dev;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0diffs |=3D p->vlan_tci ^ skb->vlan_tci=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 diffs |=3D compare_ether_header(skb_mac=
_header(p),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 skb_gro_mac_header(skb));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (maclen =3D=3D ETH_HLEN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 diffs |=3D compare_ethe=
r_header(skb_mac_header(p),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_gro_mac_header(skb));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (!diffs)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 diffs =3D memcmp(skb_ma=
c_header(p),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 skb_gro_mac_header(skb),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 maclen);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NAPI_GRO_CB(p)->same_flow =3D !diffs;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NAPI_GRO_CB(p)->flush =3D 0;
> =A0 =A0 =A0 =A0}
> @@ -5962,6 +5968,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_=
priv, const char *name,
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&dev->unreg_list);
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&dev->link_watch_list);
> =A0 =A0 =A0 =A0dev->priv_flags =3D IFF_XMIT_DST_RELEASE;
> + =A0 =A0 =A0 dev->gro_mac_header_len =3D ETH_HLEN;
> =A0 =A0 =A0 =A0setup(dev);
>
> =A0 =A0 =A0 =A0dev->num_tx_queues =3D txqs;
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
