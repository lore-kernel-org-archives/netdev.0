From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] ethtool: don't overwrite useful bits in advertising
 bitfield
Date: Tue, 21 Aug 2012 18:03:02 +0100
Message-ID: <1345568582.2659.53.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344953745-13208-1-git-send-email-johangu@axis.com>
	 <1345476178.2659.15.camel@bwh-desktop.uk.solarflarecom.com>
	 <A612847CFE53224C91B23E3A5B48BAC7534E8D76AD@xmail3.se.axis.com>
	 <1345561910.2659.45.camel@bwh-desktop.uk.solarflarecom.com>
	 <A612847CFE53224C91B23E3A5B48BAC7534E8D7809@xmail3.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mikael Starvik <starvik@axis.com>
To: Johan Gunnarsson <johan.gunnarsson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41742 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758022Ab2HURDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 13:03:05 -0400
In-Reply-To: <A612847CFE53224C91B23E3A5B48BAC7534E8D7809@xmail3.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 18:45 +0200, Johan Gunnarsson wrote:
[...]
> > > > > @@ -2405,19 +2421,20 @@ static int do_sset(struct cmd_context
> > *ctx)
> > > > >  			}
> > > > >  			if (autoneg_wanted == AUTONEG_ENABLE &&
> > > > >  			    advertising_wanted == 0) {
> > > > > -				ecmd.advertising = ecmd.supported &
> > > > > -					(ADVERTISED_10baseT_Half |
> > > > > -					 ADVERTISED_10baseT_Full |
> > > > > -					 ADVERTISED_100baseT_Half |
> > > > > -					 ADVERTISED_100baseT_Full |
> > > > > -					 ADVERTISED_1000baseT_Half |
> > > > > -					 ADVERTISED_1000baseT_Full |
> > > > > -					 ADVERTISED_2500baseX_Full |
> > > > > -					 ADVERTISED_10000baseT_Full |
> > > > > -					 ADVERTISED_20000baseMLD2_Full |
> > > > > -					 ADVERTISED_20000baseKR2_Full);
> > > > > +				/* Auto negotation enabled, but with
> > > > > +				 * unspecified speed and duplex: enable
> > all
> > > > > +				 * supported speeds and duplexes.
> > > > > +				 */
> > > > > +				ecmd.advertising = (ecmd.advertising &
> > > > > +					~ALL_ADVERTISED_MODES) |
> > > > > +					(ALL_ADVERTISED_MODES &
> > ecmd.supported);
> > > >
> > > > Perhaps we should also warn if there's a 'supported' flag we don't
> > > > recognise, because we don't know whether it's a link mode and we
> > might
> > > > be failing to enable/disable it as requested.
> > >
> > > You mean if ecmd.supported has bits enabled that ALL_ADVERTISED_MODES
> > > hasn't? I don't think that's a good idea, because that happens very
> > > often (for example PAUSE bits in my case.)
> > 
> > No, I mean if it has bits enabled that are not defined at all
> > (currently
> > any of bits 27-31).
> 
> Not totally sure I follow. Care to show me?
[...]

<linux/ethtool.h> or ethtool-copy.h currently defines the meanings of
bits 0-26 in the supported field.  You define ALL_ADVERTISED_MODES to
include all of those that are link modes.  But some time in the future,
the remaining bits will be assigned to new capabilities.

If today's ethtool is used with a newer driver that sets bit 27 in its
supported field, ethtool can't tell whether that represents a new link
mode that should be included in ALL_ADVERTISED_MODES, or some other kind
of capability.  So it may not be able to set the driver's advertising
mask correctly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
