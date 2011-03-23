From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] net: Allow no-cache copy from user on transmit
Date: Wed, 23 Mar 2011 12:25:44 -0700
Message-ID: <20110323122544.032fb543@nehalam>
References: <alpine.DEB.2.00.1103231003120.16608@pokey.mtv.corp.google.com>
	<AANLkTi=Tg4jW7hZZ43E71GNi+d8JWMJQcv3ExZA6zJQW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36320 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756578Ab1CWTZt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 15:25:49 -0400
In-Reply-To: <AANLkTi=Tg4jW7hZZ43E71GNi+d8JWMJQcv3ExZA6zJQW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Mar 2011 19:42:20 +0100
Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:

> 2011/3/23 Tom Herbert <therbert@google.com>:
> > This patch uses __copy_from_user_nocache (from skb_copy_to_page)
> > on transmit to bypass data cache for a performance improvement.
> > This functionality is configurable per device using ethtool, the
> > device must also be doing TX csum offload to enable. =C2=A0It seems
> > reasonable to set this when the netdevice does not copy or
> > otherwise touch the data.
> >
> > This patch was tested using 200 instances of netperf TCP_RR with
> > 1400 byte request and one byte reply. =C2=A0Platform is 16 core AMD=
 x86.
> >
> > No-cache copy disabled:
> > =C2=A0 672703 tps, 97.13% utilization
> > =C2=A0 50/90/99% latency:244.31 484.205 1028.41
> >
> > No-cache copy enabled:
> > =C2=A0 702113 tps, 96.16% utilization,
> > =C2=A0 50/90/99% latency 238.56 467.56 956.955
> >
> > Using 14000 byte request and response sizes demonstrate the
> > effects more dramatically:
> >
> > No-cache copy disabled:
> > =C2=A0 79571 tps, 34.34 %utlization
> > =C2=A0 50/90/95% latency 1584.46 2319.59 5001.76
> >
> > No-cache copy enabled:
> > =C2=A0 83856 tps, 34.81% utilization
> > =C2=A0 50/90/95% latency 2508.42 2622.62 2735.88
> >
> > Note especially the effect on tail latency (95th percentile).
> >
> > This seems to provide a nice performance improvement and is
> > consistent in the tests I ran. =C2=A0Presumably, this would provide
> > the greatest benfits in the presence of an application workload
> > stressing the cache and a lot of transmit data happening. =C2=A0I d=
on't
> > yet see a downside to using this.
> >
> > Signed-off-by: Tom Herbert <therbert@google.com>
> > ---
> > =C2=A0include/linux/netdevice.h | =C2=A0 10 ++++++++--
> > =C2=A0include/net/sock.h =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A0=
5 +++++
> > =C2=A0net/core/dev.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A02 +-
> > =C2=A0net/core/ethtool.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A0=
2 +-
> > =C2=A04 files changed, 15 insertions(+), 4 deletions(-)
> >
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 5eeb2cd..52d444f 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1066,6 +1066,7 @@ struct net_device {
> > =C2=A0#define NETIF_F_NTUPLE =C2=A0 =C2=A0 =C2=A0 =C2=A0 (1 << 27) =
/* N-tuple filters supported */
> > =C2=A0#define NETIF_F_RXHASH =C2=A0 =C2=A0 =C2=A0 =C2=A0 (1 << 28) =
/* Receive hashing offload */
> > =C2=A0#define NETIF_F_RXCSUM =C2=A0 =C2=A0 =C2=A0 =C2=A0 (1 << 29) =
/* Receive checksumming offload */
> > +#define NETIF_F_NOCACHE_COPY =C2=A0 (1 << 30) /* Use no-cache copy=
fromuser */
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Segmentation offload features */
> > =C2=A0#define NETIF_F_GSO_SHIFT =C2=A0 =C2=A0 =C2=A016
> > @@ -1081,7 +1082,7 @@ struct net_device {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* =3D all defined minus driver/device-c=
lass-related */
> > =C2=A0#define NETIF_F_NEVER_CHANGE =C2=A0 (NETIF_F_HIGHDMA | NETIF_=
=46_VLAN_CHALLENGED | \
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0NETIF_F_LLTX | NETIF_F=
_NETNS_LOCAL)
> > -#define NETIF_F_ETHTOOL_BITS =C2=A0 (0x3f3fffff & ~NETIF_F_NEVER_C=
HANGE)
> > +#define NETIF_F_ETHTOOL_BITS =C2=A0 (0x7f3fffff & ~NETIF_F_NEVER_C=
HANGE)
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* List of features with software fallba=
cks. */
> > =C2=A0#define NETIF_F_GSO_SOFTWARE =C2=A0 (NETIF_F_TSO | NETIF_F_TS=
O_ECN | \
> > @@ -1108,7 +1109,12 @@ struct net_device {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NETIF_F_FRAGLIST)
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* changeable features with no special h=
ardware requirements */
> > -#define NETIF_F_SOFT_FEATURES =C2=A0(NETIF_F_GSO | NETIF_F_GRO)
> > +#define NETIF_F_SOFT_FEATURES =C2=A0(NETIF_F_GSO | NETIF_F_GRO | =C2=
=A0 =C2=A0\
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0NETIF_F_NOCACHE_COPY)
> > +
> > + =C2=A0 =C2=A0 =C2=A0 /* soft features automatically enabled */
> > +#define NETIF_F_SOFT_FEAT_ENAB (NETIF_F_GSO | NETIF_F_GRO)
> > +
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Interface index. Unique device identi=
fier =C2=A0 =C2=A0*/
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ifindex;
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index da0534d..74ce586 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -1401,6 +1401,11 @@ static inline int skb_copy_to_page(struct so=
ck *sk, char __user *from,
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return err;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb->csum =3D=
 csum_block_add(skb->csum, csum, skb->len);
> > + =C2=A0 =C2=A0 =C2=A0 } else if (sk->sk_route_caps & NETIF_F_NOCAC=
HE_COPY) {
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!access_ok(V=
ERIFY_READ, from, copy) ||
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __=
copy_from_user_nocache(page_address(page) + off,
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 from, copy))
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return -EFAULT;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (copy_from_user(page_address(p=
age) + off, from, copy))
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EFAU=
LT;
> >
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 0b88eba..c3ed95e 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -5435,7 +5435,7 @@ int register_netdevice(struct net_device *dev=
)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * software offloads (GSO and GRO).
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->hw_features |=3D NETIF_F_SOFT_FEATU=
RES;
> > - =C2=A0 =C2=A0 =C2=A0 dev->features |=3D NETIF_F_SOFT_FEATURES;
> > + =C2=A0 =C2=A0 =C2=A0 dev->features |=3D NETIF_F_SOFT_FEAT_ENAB;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->wanted_features =3D dev->features &=
 dev->hw_features;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Avoid warning from netdev_fix_feature=
s() for GSO without SG */
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index c1a71bb..40b6fe0 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> > @@ -344,7 +344,7 @@ static const char netdev_features_strings[ETHTO=
OL_DEV_FEATURE_WORDS * 32][ETH_GS
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_NTUPLE */ =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0"rx-ntuple-filter",
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_RXHASH */ =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0"rx-hashing",
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* NETIF_F_RXCSUM */ =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0"rx-checksum",
> > - =C2=A0 =C2=A0 =C2=A0 "",
> > + =C2=A0 =C2=A0 =C2=A0 /* NETIF_F_NOCACHE_COPY */ =C2=A0 =C2=A0"tx-=
nocache-copy"
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0"",
> > =C2=A0};
>=20
> I would rather see it enabled by default, including "hacks" in
> register_netdev() like for GSO. Otherwise not much people will test
> this. There should also be constraints for it in
> netdev_fix_features().
>=20
> BTW, what happens if this is used on e.g. bridge device or veth and
> later packet ends up going to device which needs to do checksumming i=
n
> software?

The configuration via device and ethtool seems problematic for general =
use
in a distro. Nice for testing, but not really matching the architecture
issues.

Isn't nocache DMA a function of the I/O architecture not a function
of the device driver? Shouldn't it be handled at PCI level somehow
with considerations of CPU arch and quirks? Doesn't it make sense for
non-network traffic as well.

Hate to hold up a good optimization while waiting for a general
solution, but commiting to an API prematurely would be bad as well.



--=20
