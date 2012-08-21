From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] ethtool: don't overwrite useful bits in advertising
 bitfield
Date: Tue, 21 Aug 2012 16:11:50 +0100
Message-ID: <1345561910.2659.45.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344953745-13208-1-git-send-email-johangu@axis.com>
	 <1345476178.2659.15.camel@bwh-desktop.uk.solarflarecom.com>
	 <A612847CFE53224C91B23E3A5B48BAC7534E8D76AD@xmail3.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mikael Starvik <starvik@axis.com>
To: Johan Gunnarsson <johan.gunnarsson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58935 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754311Ab2HUPLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 11:11:54 -0400
In-Reply-To: <A612847CFE53224C91B23E3A5B48BAC7534E8D76AD@xmail3.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 10:41 +0200, Johan Gunnarsson wrote:
> 
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Ben Hutchings
> > Sent: den 20 augusti 2012 17:23
> > To: Johan Gunnarsson
> > Cc: netdev@vger.kernel.org; Mikael Starvik
> > Subject: Re: [PATCH] ethtool: don't overwrite useful bits in
> > advertising bitfield
> > 
> > On Tue, 2012-08-14 at 16:15 +0200, Johan Gunnarsson wrote:
> > > There are bits in this bitfield that we want to leave untouched
> > (PAUSE
> > > and ASYM_PAUSE bits) when changing other bits (speed and duplex
> > bits.)
> > > Previously, these were always overwritten to zero when running
> > commands
> > > like "ethtool -s eth0 speed 10 duplex full autoneg off".
> > 
> > This is right in principle, but the implementation isn't quite right.
> > 
> > > Signed-off-by: Johan Gunnarsson <johangu@axis.com>
> > > ---
> > >  ethtool.c |   45 +++++++++++++++++++++++++++++++--------------
> > >  1 file changed, 31 insertions(+), 14 deletions(-)
> > >
> > > diff --git a/ethtool.c b/ethtool.c
> > > index e573357..efa12c7 100644
> > > --- a/ethtool.c
> > > +++ b/ethtool.c
> > > @@ -46,6 +46,18 @@
> > >  #define MAX_ADDR_LEN	32
> > >  #endif
> > >
> > > +#define ALL_ADVERTISED_MODES \
> > > +	(ADVERTISED_10baseT_Half | \
> > > +	 ADVERTISED_10baseT_Full | \
> > > +	 ADVERTISED_100baseT_Half | \
> > > +	 ADVERTISED_100baseT_Full | \
> > > +	 ADVERTISED_1000baseT_Half | \
> > > +	 ADVERTISED_1000baseT_Full | \
> > > +	 ADVERTISED_2500baseX_Full | \
> > > +	 ADVERTISED_10000baseT_Full | \
> > > +	 ADVERTISED_20000baseMLD2_Full | \
> > > +	 ADVERTISED_20000baseKR2_Full)
> > 
> > This is missing the new 40G modes (not a regression, I realise).
> 
> I'll add the 40G modes. There is also a bunch of 10G modes missing. Shall I add these too?

Yes please.

> > 
> > [...]
> > > @@ -2405,19 +2421,20 @@ static int do_sset(struct cmd_context *ctx)
> > >  			}
> > >  			if (autoneg_wanted == AUTONEG_ENABLE &&
> > >  			    advertising_wanted == 0) {
> > > -				ecmd.advertising = ecmd.supported &
> > > -					(ADVERTISED_10baseT_Half |
> > > -					 ADVERTISED_10baseT_Full |
> > > -					 ADVERTISED_100baseT_Half |
> > > -					 ADVERTISED_100baseT_Full |
> > > -					 ADVERTISED_1000baseT_Half |
> > > -					 ADVERTISED_1000baseT_Full |
> > > -					 ADVERTISED_2500baseX_Full |
> > > -					 ADVERTISED_10000baseT_Full |
> > > -					 ADVERTISED_20000baseMLD2_Full |
> > > -					 ADVERTISED_20000baseKR2_Full);
> > > +				/* Auto negotation enabled, but with
> > > +				 * unspecified speed and duplex: enable all
> > > +				 * supported speeds and duplexes.
> > > +				 */
> > > +				ecmd.advertising = (ecmd.advertising &
> > > +					~ALL_ADVERTISED_MODES) |
> > > +					(ALL_ADVERTISED_MODES & ecmd.supported);
> > 
> > Perhaps we should also warn if there's a 'supported' flag we don't
> > recognise, because we don't know whether it's a link mode and we might
> > be failing to enable/disable it as requested.
> 
> You mean if ecmd.supported has bits enabled that ALL_ADVERTISED_MODES
> hasn't? I don't think that's a good idea, because that happens very
> often (for example PAUSE bits in my case.)

No, I mean if it has bits enabled that are not defined at all (currently
any of bits 27-31).

> > 
> > >  			} else if (advertising_wanted > 0) {
> > > -				ecmd.advertising = advertising_wanted;
> > > +				/* Enable all requested modes */
> > > +				ecmd.advertising = (ecmd.advertising &
> > > +					~ALL_ADVERTISED_MODES) |
> > > +					(advertising_wanted & ecmd.supported);
> > 
> > I don't think the '& ecmd.supported' here is right.  If an autoneg
> > device supports some new link mode L that is not in
> > ALL_ADVERTISED_MODES, but not link mode M which the user requested,
> > then
> > this can silently fail because the resulting advertising mask will
> > include L but not M.
> > 
> > We should either use advertising_wanted unmasked and let the driver
> > validate it, or report an error if it's not present in the supported
> > mask.  I think we should be consistent with the following case, i.e.
> > let
> > the driver validate it.
> 
> How about remove "& ecmd.supported", but also warn if trying to add an
> unsupported mode? Similar to the previous case.
[...]

I don't think this is similar and I don't think we need to do both.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
