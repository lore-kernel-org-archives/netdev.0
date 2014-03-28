From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V12 6/7] net: sxgbe: add ethtool related functions
 support
Date: Fri, 28 Mar 2014 00:47:55 +0000
Message-ID: <1395967675.2898.38.camel@deadeye.wl.decadent.org.uk>
References: <1395737017-16975-1-git-send-email-vipul.pandya@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-41g9Xmebe28x1OEpwqQx"
Cc: bh74.an@samsung.com, netdev@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org, devicetree@vger.kernel.org,
	davem@davemloft.net, ks.giri@samsung.com, siva.kallam@samsung.com,
	ilho215.lee@samsung.com
To: Vipul Pandya <vipul.pandya@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <1395737017-16975-1-git-send-email-vipul.pandya@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-41g9Xmebe28x1OEpwqQx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-25 at 14:13 +0530, Vipul Pandya wrote:
> From: Vipul Pandya <vipul.pandya@samsung.com>
>=20
> --=20

This ('-- ') is a signature separator.  Please don't put that at the top
of a message, as many mailers, including mine, will remove everything
below it from a reply.

[...]
> > [...]
> > > +static int sxgbe_get_coalesce(struct net_device *dev,
> > > +                             struct ethtool_coalesce *ec)
> > > +{
> > > +       struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> > > +
> > > +       if (priv->use_riwt)
> > > +               ec->rx_coalesce_usecs =3D
> sxgbe_riwt2usec(priv->rx_riwt, priv);
> >
> > Also set:
> >
> >       ec->rx_max_coalesced_frames =3D !priv->use_riwt;
> >       ec->tx_coalesce_usecs =3D SXGBE_COAL_TX_TIMER;
> >       ec->tx_max_coalesced_frames =3D SXGBE_TX_FRAMES;
> Support for above additional parameters do not present in the hardware
> controller. So, they are not set.

See the definition of struct ethtool_coalesce, which says you have to
set at least one of each pair to be non-zero.

And if I read the code correctly:

- the driver can decide which TX descriptors will trigger an interrupt
on completion, and does so at intervals of SXGBE_TX_FRAMES
- the hardware does not have a timer for TX interrupt coalescing, but
the driver does have a timer to poll for TX completions

So you have effectively implemented TX interrupt coalescing, and should
describe it through the ethtool API.

> > > +       return 0;
> > > +}
> > > +
> > > +static int sxgbe_set_coalesce(struct net_device *dev,
> > > +                         struct ethtool_coalesce *ec)
> > > +{
> > > +   struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> > > +   unsigned int rx_riwt;
> > > +
> > > +   rx_riwt =3D sxgbe_usec2riwt(ec->rx_coalesce_usecs, priv);
> > > +
> > > +   if ((rx_riwt > SXGBE_MAX_DMA_RIWT) || (rx_riwt <
> SXGBE_MIN_DMA_RIWT))
> > > +           return -EINVAL;
> > > +   else if (!priv->use_riwt)
> > > +           return -EOPNOTSUPP;
> >
> > Please check for attempts to change unsupported parameters:
> >
> >       if (ec->rx_max_coalesced_frames !=3D !rx_riwt ||
> >           ec->tx_coalesce_usecs !=3D SXGBE_COAL_TX_TIMER ||
> >           ec->tx_max_coalesced_frames !=3D SXGBE_TX_FRAMES ||
> >           ec->use_adaptive_rx_coalesce ||
> >           ec->use_adaptive_tx_coalesce)
> >               return -EINVAL;
> There is only one supported parameter so I would rather check if the
> same is set
> or not as shown below:
>=20
> if (!ec->rx_coalesce_usecs)
>         return -EINVAL;

All of those fields are parameters and you should not ignore them.

> > > +   priv->rx_riwt =3D rx_riwt;
> > > +   priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt);
> > > +
> > > +   return 0;
> > > +}
> > [...]
> > > +static int sxgbe_set_rss_hash_opt(struct sxgbe_priv_data *priv,
> > > +                             struct ethtool_rxnfc *cmd)
> > > +{
> > > +   u32 reg_val =3D 0;
> > > +
> > > +   /* RSS does not support anything other than hashing
> > > +    * to queues on src and dst IPs and ports
> > > +    */
> > > +   if (cmd->data & ~(RXH_IP_SRC | RXH_IP_DST |
> > > +                     RXH_L4_B_0_1 | RXH_L4_B_2_3))
> > > +           return -EINVAL;
> > > +
> > > +   switch (cmd->flow_type) {
> > > +   case TCP_V4_FLOW:
> > > +   case TCP_V6_FLOW:
> > > +           if (!(cmd->data & RXH_IP_SRC) ||
> > > +               !(cmd->data & RXH_IP_DST) ||
> > > +               !(cmd->data & RXH_L4_B_0_1) ||
> > > +               !(cmd->data & RXH_L4_B_2_3))
> > > +                   return -EINVAL;
> > > +           reg_val =3D SXGBE_CORE_RSS_CTL_TCP4TE;
> > > +           break;
> > > +   case UDP_V4_FLOW:
> > > +   case UDP_V6_FLOW:
> > > +           if (!(cmd->data & RXH_IP_SRC) ||
> > > +               !(cmd->data & RXH_IP_DST) ||
> > > +               !(cmd->data & RXH_L4_B_0_1) ||
> > > +               !(cmd->data & RXH_L4_B_2_3))
> > > +                   return -EINVAL;
> > > +           reg_val =3D SXGBE_CORE_RSS_CTL_UDP4TE;
> > > +           break;
> > > +   case SCTP_V4_FLOW:
> > > +   case AH_ESP_V4_FLOW:
> > > +   case AH_V4_FLOW:
> > > +   case ESP_V4_FLOW:
> > > +   case AH_ESP_V6_FLOW:
> > > +   case AH_V6_FLOW:
> > > +   case ESP_V6_FLOW:
> > > +   case SCTP_V6_FLOW:
> > > +   case IPV4_FLOW:
> > > +   case IPV6_FLOW:
> > > +           if (!(cmd->data & RXH_IP_SRC) ||
> > > +               !(cmd->data & RXH_IP_DST) ||
> > > +               (cmd->data & RXH_L4_B_0_1) ||
> > > +               (cmd->data & RXH_L4_B_2_3))
> > > +                   return -EINVAL;
> > > +           reg_val =3D SXGBE_CORE_RSS_CTL_IP2TE;
> > > +           break;
> > > +   default:
> > > +           return -EINVAL;
> > > +   }
> >
> > Unless I'm missing something, this only accepts the default values,
> so
> > it's not actually possible to change the configuration.  Why are you
> > implementing this operation at all?
> It is possible to change the configuration. There is a register write
> to the
> SXGBE_CORE_RSS_CTL_REG at the end of the function. I think you might
> have missed
> it.
[...]

I see, but I'm not sure I understand.  Does this mean that only one hash
function can be implemented at a time, i.e. do you have to choose:

(IP packets hashed by address
 OR
 TCP packets hashed by address+port
 OR
 UDP packets hashed by address+port)
AND
all other packets go to single queue

?

Because that's not what this operation is supposed to do at all.  It's
supposed to select *independently* for each flow type, how flows of that
type are hashed.  Most multiqueue controllers can do RX flow hashing
like this:

(TCP packets hashed by port+address OR by address)
AND
(UDP packets hashed by port+address OR by address)
AND
all other IP packets hashed by address
AND
all non-IP packets go to single queue

Then this operation would let you select between the alternative hash
functions for TCP and UDP, while not affecting other flow types.  (Some
hardware is more flexible, hence the large number of flow types
defined.)

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.

--=-41g9Xmebe28x1OEpwqQx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzTGu+e/yOyVhhEJAQrwShAA04cCCekovdPPtmnXQO5vsf3nAsgwdFBL
ueXRcoUE5xAbdFHIzhHsMlFwgWzlPC1Vfs7Z2kq9Y+i5iYmtUtyZSfKKmKZeIOhw
AcrEZEpLSQxtvotuXM7nUH1tkyYI77vk4WrdnIsTiy7goSf4Hh0MAFZ7ADSAfIMF
YhD+eNQoanbudqBHCtIpiAhe46GkIj/J0tdlBGiK/WP82QcaK3A9q0p3ztyu7LbS
dfZLkXep4gktPqanX5BKDFWuqzWSMiUTIJ6kQ4MjOU3n/C8A3jj80EtuZ5fTlxgF
7jYyF79GYdkVN3PTel/Y6gsrLVYRgtsJM13jwDYkXB8e8EdsXl6k3BSd3uQN4VrL
1VerZBrf/UAAiP4/Sr294hKXJRwXLtKmGVzZ8kN+TM2j92d89pdgUuTp5BMkthw/
EYX32rclDpoFTqFburyZuXIgTDKK04l84R57QdYdZk+6/sA0jZFdK+6f6ea+16yh
DgtPjMNKDFFssG8WF5gSocZl5VdrL4T7OzFKgA3kRTNxZA64W2wimhpthZ3KmrZK
hCAv50fTxlu5CS1OiEbeP9xv+5cKUBBK6kgkvvR9cL7p8l0TQ3o1u/fB8M10S2+y
bJxlqTl+PNy0mujdd0c39I8n+/G2AHBuvE7vPnAZ8/4BNvGIr2mLS/pRp/Phu9uc
lLnaqPvGO08=
=6ur1
-----END PGP SIGNATURE-----

--=-41g9Xmebe28x1OEpwqQx--
