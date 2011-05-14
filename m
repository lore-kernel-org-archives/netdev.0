From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-2.6] ethtool: Remove fallback to old ethtool
 operations for ETHTOOL_SFEATURES
Date: Sat, 14 May 2011 21:08:08 +0100
Message-ID: <1305403688.4065.464.camel@localhost>
References: <1305335142.2851.70.camel@bwh-desktop>
	 <20110514095457.GA31970@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48624 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754142Ab1ENUIR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 16:08:17 -0400
In-Reply-To: <20110514095457.GA31970@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Sending this from my home address as solarflare.com mail is under
maintenance and SPF prevents me using that address entirely.]

On Sat, 2011-05-14 at 11:54 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Sat, May 14, 2011 at 02:05:42AM +0100, Ben Hutchings wrote:
> > ethtool_set_feature_compat() squashes the feature mask into a boole=
an,
> > which is not correct for ethtool_ops::set_flags.
> >=20
> > We could fix this, but the fallback code for ETHTOOL_SFEATURES actu=
ally
> > makes things more complicated for the ethtool utility and any other
> > application using the ethtool API.  They will still need to fall ba=
ck to
> > the old offload control commands in order to support older kernel
> > versions.  The fallback code in the kernel adds a third possibility=
 for
> > them to handle.  So make ETHTOOL_SFEATURES fail when the driver
> > implements the old offload control operations, and let userland do =
the
> > fallback.
> >=20
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>=20
> This will disable SFEATURES for drivers which implement changing newe=
r
> features that have no old ethtool ops (e.g.  NETIF_F_LOOPBACK), but a=
re
> not converted, yet. This might matter when bisecting.
>=20
> It's easy to fix this.

Yes, I realise that.

> The code is going away for 2.6.40, though.
> Do you want to get rid of ETHTOOL_F_COMPAT bit before 2.6.39?

Right, I don't want this to ever be in a stable release.

> BTW, what are the complications for userspace?

With 2.6.38 and earlier, ETHTOOL_SFEATURES will fail; ethtool -K will
fall back to the individual operations can can report which of them
failed and why.

With 2.6.39 and a converted driver, ethtool -K can find out exactly
which features are changeable and report whether any of the individual
changes are not supported at all.  If there's something wrong with the
combination of features then ETHTOOL_SFEATURES will return
ETHTOOL_F_WISH and it can report that the combination is not supported.

With 2.6.39 and an unconverted driver, ETHTOOL_SFEATURES can return
ETHTOOL_F_COMPAT which just tells us some change failed, but not why.
We can try to guess what went wrong by reading back the features, but
it's unclear.  This is particularly problematic with set_flags (again)
where the ethtool core can't tell which flags are settable in an
unconverted driver.

I would much prefer not to have this third case existing in a single
stable release.

> This change misses ethtool_get_features_compat() setting available bi=
ts.

Yes, but that is less of a problem in practice.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
