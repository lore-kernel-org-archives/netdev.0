From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: fix preparation of a port STP update
Date: Tue, 29 Sep 2015 14:17:24 -0400
Message-ID: <20150929181723.GA25814@ketchup.mtl.sfl>
References: <1443544716-9130-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150929164245.GA3368@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:41705
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965212AbbI2TMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 15:12:10 -0400
Content-Disposition: inline
In-Reply-To: <20150929164245.GA3368@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sep. Tuesday 29 (40) 06:42 PM, Andrew Lunn wrote:
> On Tue, Sep 29, 2015 at 12:38:36PM -0400, Vivien Didelot wrote:
> > Because of the default 0 value of ret in dsa_slave_port_attr_set, a
> > driver may return -EOPNOTSUPP from the commit phase of a STP state,
> > which triggers a WARN() from switchdev.
> > 
> > This happened on a 6185 switch which does not support hardware bridging.
> > 
> > Reported-by: Andrew Lunn <andrew@lunn.ch>
> > Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Acked-by: Andrew Lunn <andrew@lunn.ch>
> Fixes: 3563606258cf ("switchdev: convert STP update to switchdev attr set")
> 
> David:
>   This should be included in the next -rc.

Nope. A new transaction model has been introduced in the meantime and
this code changed. I send a fix based on v4.3-rc3 right away.

Thanks,
-v

> 
> Thanks
> 	Andrew
> 
> > ---
> >  net/dsa/slave.c | 11 ++++++++---
> >  1 file changed, 8 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> > index 0ae427c..02a3af8 100644
> > --- a/net/dsa/slave.c
> > +++ b/net/dsa/slave.c
> > @@ -453,12 +453,17 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
> >  				   struct switchdev_attr *attr,
> >  				   struct switchdev_trans *trans)
> >  {
> > -	int ret = 0;
> > +	struct dsa_slave_priv *p = netdev_priv(dev);
> > +	struct dsa_switch *ds = p->parent;
> > +	int ret;
> >  
> >  	switch (attr->id) {
> >  	case SWITCHDEV_ATTR_PORT_STP_STATE:
> > -		if (switchdev_trans_ph_commit(trans))
> > -			ret = dsa_slave_stp_update(dev, attr->u.stp_state);
> > +		if (switchdev_trans_ph_prepare(trans))
> > +			ret = ds->drv->port_stp_update ? 0 : -EOPNOTSUPP;
> > +		else
> > +			ret = ds->drv->port_stp_update(ds, p->port,
> > +						       attr->u.stp_state);
> >  		break;
> >  	default:
> >  		ret = -EOPNOTSUPP;
> > -- 
> > 2.6.0
> > 
