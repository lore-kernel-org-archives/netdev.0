From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: ehea: fix wrongly-reported supported modes
Date: Wed, 04 May 2011 18:59:26 -0300
Message-ID: <1304546366.28342.14.camel@dream>
References: <1304451745.6899.15.camel@dream>
	 <1304453775.2873.17.camel@bwh-desktop>
	 <1304458460.2873.18.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:48061 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069Ab1EDV7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 17:59:47 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <klebers@linux.vnet.ibm.com>;
	Wed, 4 May 2011 18:59:43 -0300
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p44M0fI83428476
	for <netdev@vger.kernel.org>; Wed, 4 May 2011 19:00:42 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p44LxVOW027629
	for <netdev@vger.kernel.org>; Wed, 4 May 2011 18:59:31 -0300
In-Reply-To: <1304458460.2873.18.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-03 at 22:34 +0100, Ben Hutchings wrote:
> On Tue, 2011-05-03 at 21:16 +0100, Ben Hutchings wrote:
> > On Tue, 2011-05-03 at 16:42 -0300, Kleber Sacilotto de Souza wrote:
> > > Currently EHEA reports to ethtool as supporting 10000baseT_Full and
> > > FIBRE independent of the hardware configuration. However, these
> > > capabilities should be reported only if the physical port and
> > > the medium support them, which is the case where the physical port
> > > is connected at 10Gb.
> > >
> > > Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
> > > ---
> > >  drivers/net/ehea/ehea_ethtool.c |   21 ++++++++++++++-------
> > >  1 files changed, 14 insertions(+), 7 deletions(-)
> > > 
> > > diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
> > > index 3e2e734..04716c2 100644
> > > --- a/drivers/net/ehea/ehea_ethtool.c
> > > +++ b/drivers/net/ehea/ehea_ethtool.c
> > > @@ -55,15 +55,22 @@ static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> > >  		cmd->duplex = -1;
> > >  	}
> > > 
> > > -	cmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_1000baseT_Full
> > > -		       | SUPPORTED_100baseT_Full |  SUPPORTED_100baseT_Half
> > > -		       | SUPPORTED_10baseT_Full | SUPPORTED_10baseT_Half
> > > -		       | SUPPORTED_Autoneg | SUPPORTED_FIBRE);
> > > +	cmd->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full
> > > +		       | SUPPORTED_100baseT_Half | SUPPORTED_10baseT_Full
> > > +		       | SUPPORTED_10baseT_Half | SUPPORTED_Autoneg);
> > > 
> > > -	cmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_Autoneg
> > > -			 | ADVERTISED_FIBRE);
> > > +	cmd->advertising = ADVERTISED_Autoneg;
> > > +
> > > +	if (cmd->speed == SPEED_10000) {
> > > +		cmd->supported |= (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
> > > +		cmd->advertising |= (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
> > > +		cmd->port = PORT_FIBRE;
> > > +	} else {
> > > +		cmd->supported |= SUPPORTED_TP;
> > > +		cmd->advertising |= (ADVERTISED_1000baseT_Full | ADVERTISED_TP);
> > > +		cmd->port = PORT_TP;
> > > +	}
> > 
> > This doesn't make any sense.  If the current speed is 10G, then the
> > driver also claims to support speeds of 10M, 100M, 1G and 10G.  But then
>                                                                ^
>                                                            on fibre
> 
> > if the speed actually is <10G, the driver claims to support TP.  What's
> > going on here?

You are right. This patch was based on very vague hardware specs that
wasn't making much sense. I have more details about the hardware now, I
will send another patch soon.

> > 
> > (Also, claiming to support BASE-T modes on non-TP media is bogus, though
> > I understand why people are doing it.)
> > 
> > Ben.
> > 
> > > -	cmd->port = PORT_FIBRE;
> > >  	cmd->autoneg = port->autoneg == 1 ? AUTONEG_ENABLE : AUTONEG_DISABLE;
> > > 
> > >  	return 0;
> > 
> 

-- 
Kleber S. Souza
IBM Linux Technology Center

