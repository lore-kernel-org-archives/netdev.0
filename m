From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Mon, 16 May 2011 22:51:37 +0200
Message-ID: <20110516205137.GA7667@rere.qmqm.pl>
References: <20110516121339.GA1094@rere.qmqm.pl>
 <1305335142.2851.70.camel@bwh-desktop>
 <20110514103539.GA5214@rere.qmqm.pl>
 <1305513923.19966.20.camel@localhost>
 <20110516132807.1A89F13A6A@rere.qmqm.pl>
 <1305553066.19966.32.camel@localhost>
 <20110516142340.GA2980@rere.qmqm.pl>
 <1305557597.2885.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43164 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754049Ab1EPUvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 16:51:39 -0400
Content-Disposition: inline
In-Reply-To: <1305557597.2885.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 03:53:17PM +0100, Ben Hutchings wrote:
> On Mon, 2011-05-16 at 16:23 +0200, Micha=B3 Miros=B3aw wrote:
> > On Mon, May 16, 2011 at 02:37:46PM +0100, Ben Hutchings wrote:
> > > On Mon, 2011-05-16 at 15:28 +0200, Micha=B3 Miros=B3aw wrote:
> > > > Remove NETIF_F_COMPAT since it's redundant and will be unused a=
fter
> > > > all drivers are converted to fix/set_features.
> > > >=20
> > > > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > > > ---
> > > >=20
> > > > For net as we don't want to have ETHTOOL_F_COMPAT hit stable re=
lease.
> > > [...]
> > > ETHTOOL_F_WISH means that the requested features could not all be
> > > enabled, *but are remembered*.  ETHTOOL_F_COMPAT means they were =
not
> > > remembered.
> > Hmm. So, lets just revert 39fc0ce5710c53bad14aaba1a789eec810c556f9
> > (net: Implement SFEATURES compatibility for not updated drivers).
> That's also problematic because it means we can't make any use of the
> 'available' masks from ETHTOOL_GFEATURES.
>=20
> The patch I sent is actually tested with a modified ethtool.  The
> fallback works.  I don't think you've tested whether any of your
> proposals can actually practically be used by ethtool.

While reading your patches I noted some differences in the way we see
the new [GS]FEATURES ops.

=46irst, you make NETIF_F_* flags part of the ethtool ABI. In my approa=
ch
feature names become an ABI instead. That's what ETH_SS_FEATURES string
set is for, and that's what comments in kernel's <linux/ethtool.h>
include say.

dev->features are exposed directly by kernel only in two ways:
 1. /sys/class/net/*/features - since NETIF_F_* flags are not exported
    in headers for userspace, this should be treated like a debugging
    facility and not an ABI
 2. ETHTOOL_[GS]FLAGS - these export 5 flags (LRO, VLAN offload, NTuple=
,
    and RX hashing) that are renamed to ETH_FLAG_* - only those constan=
ts
    are in the ABI and only in relation with ETHTOOL_[GS]FLAGS

Second, you reimplement 'ethtool -K' using ETHTOOL_SFEATURES. Does this=
 mean
that we want to get rid of ETHTOOL_[GS]{FLAGS,SG,...} from kernel? The
assumptions in those calls are a bit different from ETHTOOL_[GS]FEATURE=
S
but there is an conversion layer in kernel that allows old binaries to
work correctly in the common case. (-EOPNOTSUPP is still returned for
drivers which can't change particular feature. The difference is seen
only in that disabling and enabling e.g. checksumming won't disable oth=
er
dependent features in the result.)

Right now we already agree that NETIF_F_COMPAT should go.

I'll send my idea of the ethtool code using ETHTOOL_[GS]FEATURES and
keeping NETIF_F_* flags internal to the kernel. It adds new modes (-w/-=
W).
This might be made even more useful by adding simple wildcard matching.

Best Regards,
Micha=B3 Miros=B3aw
