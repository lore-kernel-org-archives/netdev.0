From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: net: af_packet: skb_orphan should be avoided in TX path.
Date: Mon, 6 Sep 2010 13:35:05 +0300
Message-ID: <20100906103505.GA15254@redhat.com>
References: <AANLkTi=oXDgEhEjt7V+Z4Pk8kv9X4Z8aCg2yAJDzuJ1J@mail.gmail.com>
 <1283708635.3402.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43941 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858Ab0IFKlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 06:41:06 -0400
Content-Disposition: inline
In-Reply-To: <1283708635.3402.100.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 05, 2010 at 07:43:55PM +0200, Eric Dumazet wrote:
> Le lundi 06 septembre 2010 =E0 01:18 +0800, Changli Gao a =E9crit :
> > af_packet uses tpacket_destruct_skb() to notify its user a frame is
> > sent out through NIC, and the memory for that frame is available fo=
r
> > the others. If the driver calls skb_orphan() before the frame is se=
nt
> > out successfully, and the user may fill other data into the space f=
or
> > this frame, this frame will be corrupted. It became more likely aft=
er
> > skb_try_orphan() was added into dev_hard_start_xmit().
> >=20
> > Am I correct?
> >=20
>=20
> Yes good catch. We might add a :
>=20
> SKBTX_NO_EARLY_ORPHAN =3D 1 << 4,
>=20
> so that skb_orphan_try() do not early orphan this kind of skb
>=20

I think there are bigger issues here.  As was pointed out, drivers migh=
t
orphan skbs before they transmit them.
And at least for tun, the reason is that we might hang on
to skbs indefinitely because userspace is not reading them.

So in that case, if you just prevent tun from orphaning skbs, the socke=
t
will be prevented from sending any more packets out even if they are fo=
r
a completely unrelated destinations, right?
=46urther, module can't get unloaded and I think socket can not get
closed, so user can't kill the task which has the socket?

And thinking about this, I think I see
another issue related to the use of the destructor callback:

static void tpacket_destruct_skb(struct sk_buff *skb)
{
        struct packet_sock *po =3D pkt_sk(skb->sk);
        void *ph;

        BUG_ON(skb =3D=3D NULL);

        if (likely(po->tx_ring.pg_vec)) {
                ph =3D skb_shinfo(skb)->destructor_arg;
                BUG_ON(__packet_get_status(po, ph) !=3D TP_STATUS_SENDI=
NG);
                BUG_ON(atomic_read(&po->tx_ring.pending) =3D=3D 0);
                atomic_dec(&po->tx_ring.pending);
                __packet_set_status(po, ph, TP_STATUS_AVAILABLE);
        }

        sock_wfree(skb);

<-----
at this point we still have to execute instructions
in this function to return from it. However
socket and thus module reference count
got already dropped to 0, so I think module could get unloaded
and these instructions could get overwritten.

}

I conclude that destructor callback should never point to a function re=
siding
in a module, always to a function that is guaranteed to be builtin, thi=
s
function must be the one that drops the last module reference.

Comments?


> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index f900ffc..9c1a480 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -176,6 +176,9 @@ enum {
> =20
>  	/* ensure the originating sk reference is available on driver level=
 */
>  	SKBTX_DRV_NEEDS_SK_REF =3D 1 << 3,
> +
> +	/* dont early orphan this skb in skb_orphan_try() */
> +	SKBTX_NO_EARLY_ORPHAN =3D 1 << 4,
>  };
> =20
>  /* This data is invariant across clones and lives at
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 3616f27..306795d 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1029,6 +1029,7 @@ static int tpacket_snd(struct packet_sock *po, =
struct msghdr *msg)
>  		}
> =20
>  		skb->destructor =3D tpacket_destruct_skb;
> +		skb_shinfo(skb)->tx_flags |=3D SKBTX_NO_EARLY_ORPHAN;
>  		__packet_set_status(po, ph, TP_STATUS_SENDING);
>  		atomic_inc(&po->tx_ring.pending);
> =20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
