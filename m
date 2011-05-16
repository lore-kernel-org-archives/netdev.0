From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Mon, 16 May 2011 23:09:35 +0100
Message-ID: <1305583775.2885.65.camel@bwh-desktop>
References: <20110516121339.GA1094@rere.qmqm.pl>
	 <1305335142.2851.70.camel@bwh-desktop> <20110514103539.GA5214@rere.qmqm.pl>
	 <1305513923.19966.20.camel@localhost>
	 <20110516132807.1A89F13A6A@rere.qmqm.pl>
	 <1305553066.19966.32.camel@localhost> <20110516142340.GA2980@rere.qmqm.pl>
	 <1305557597.2885.5.camel@bwh-desktop> <20110516205137.GA7667@rere.qmqm.pl>
	 <1305580139.2885.47.camel@bwh-desktop> <20110516215034.GA8463@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:3088 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860Ab1EPWJi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 18:09:38 -0400
In-Reply-To: <20110516215034.GA8463@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-16 at 23:50 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Mon, May 16, 2011 at 10:08:59PM +0100, Ben Hutchings wrote:
> > On Mon, 2011-05-16 at 22:51 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > > On Mon, May 16, 2011 at 03:53:17PM +0100, Ben Hutchings wrote:
> > > > On Mon, 2011-05-16 at 16:23 +0200, Micha=C5=82 Miros=C5=82aw wr=
ote:
> > > > > On Mon, May 16, 2011 at 02:37:46PM +0100, Ben Hutchings wrote=
:
> > > > > > On Mon, 2011-05-16 at 15:28 +0200, Micha=C5=82 Miros=C5=82a=
w wrote:
> > > > > > > Remove NETIF_F_COMPAT since it's redundant and will be un=
used after
> > > > > > > all drivers are converted to fix/set_features.
> > > > > > >=20
> > > > > > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere=
=2Eqmqm.pl>
> > > > > > > ---
> > > > > > >=20
> > > > > > > For net as we don't want to have ETHTOOL_F_COMPAT hit sta=
ble release.
> > > > > > [...]
> > > > > > ETHTOOL_F_WISH means that the requested features could not =
all be
> > > > > > enabled, *but are remembered*.  ETHTOOL_F_COMPAT means they=
 were not
> > > > > > remembered.
> > > > > Hmm. So, lets just revert 39fc0ce5710c53bad14aaba1a789eec810c=
556f9
> > > > > (net: Implement SFEATURES compatibility for not updated drive=
rs).
> > > > That's also problematic because it means we can't make any use =
of the
> > > > 'available' masks from ETHTOOL_GFEATURES.
> > > >=20
> > > > The patch I sent is actually tested with a modified ethtool.  T=
he
> > > > fallback works.  I don't think you've tested whether any of you=
r
> > > > proposals can actually practically be used by ethtool.
> > >=20
> > > While reading your patches I noted some differences in the way we=
 see
> > > the new [GS]FEATURES ops.
> > >=20
> > > First, you make NETIF_F_* flags part of the ethtool ABI. In my ap=
proach
> > > feature names become an ABI instead. That's what ETH_SS_FEATURES =
string
> > > set is for, and that's what comments in kernel's <linux/ethtool.h=
>
> > > include say.
> >=20
> > We've been through this before.  I can't use those names in ethtool
> > because they aren't the same as ethtool used previously.  I could m=
ake
> > it map strings to strings, but I don't see the point.
> >=20
> > > dev->features are exposed directly by kernel only in two ways:
> > >  1. /sys/class/net/*/features - since NETIF_F_* flags are not exp=
orted
> > >     in headers for userspace, this should be treated like a debug=
ging
> > >     facility and not an ABI
> > >  2. ETHTOOL_[GS]FLAGS - these export 5 flags (LRO, VLAN offload, =
NTuple,
> > >     and RX hashing) that are renamed to ETH_FLAG_* - only those c=
onstants
> > >     are in the ABI and only in relation with ETHTOOL_[GS]FLAGS
> > >=20
> > > Second, you reimplement 'ethtool -K' using ETHTOOL_SFEATURES. Doe=
s this mean
> > > that we want to get rid of ETHTOOL_[GS]{FLAGS,SG,...} from kernel=
?
> > We must not.
>=20
> So what's the point in reimplementing old options via ETHTOOL_SFEATUR=
ES?

Where, in ethtool?  The benefits include:
- Kernel remembers all the features the user wants on, even if the
combination is impossible.  Turning TX checksumming off and on no longe=
r
forces TSO off.
- ethtool can distinguish and report whether a feature is unsupported o=
r
its dependencies are not met.

> > > The
> > > assumptions in those calls are a bit different from ETHTOOL_[GS]F=
EATURES
> > > but there is an conversion layer in kernel that allows old binari=
es to
> > > work correctly in the common case. (-EOPNOTSUPP is still returned=
 for
> > > drivers which can't change particular feature. The difference is =
seen
> > > only in that disabling and enabling e.g. checksumming won't disab=
le other
> > > dependent features in the result.)
> > >=20
> > > Right now we already agree that NETIF_F_COMPAT should go.
> > >=20
> > > I'll send my idea of the ethtool code using ETHTOOL_[GS]FEATURES =
and
> > > keeping NETIF_F_* flags internal to the kernel. It adds new modes=
 (-w/-W).
> > > This might be made even more useful by adding simple wildcard mat=
ching.
> > I've explained before that I do not want to add new options to do
> > (mostly) the same thing.  Users should have not have to use a diffe=
rent
> > command depending on the kernel version.
>=20
> We can avoid new option by checking feature-strings for unrecognised
> arguments to -K. This way, we will have the old options which work
> regardless of kernel version ('tx', 'rx', 'sg', etc.) and new options
> which need recent kernel anyway (separated 'tx-checksum-*', 'loopback=
',
> others coming in for 2.6.40).

This is just too subtle a distinction.  It will mostly confuse users.

> Also, this way fallbacks in userspace are avoided.

No, ethtool will be supporting kernels <2.6.40 for many years yet.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

