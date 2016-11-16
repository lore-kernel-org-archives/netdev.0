From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] net: dsa: fix fixed-link-phy device leaks
Date: Wed, 16 Nov 2016 18:11:45 +0100
Message-ID: <20161116171145.GE4864@localhost>
References: <1479307664-32428-1-git-send-email-johan@kernel.org>
 <42af57ed-df84-f628-659d-c982d30da7d5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <42af57ed-df84-f628-659d-c982d30da7d5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2016 at 09:06:26AM -0800, Florian Fainelli wrote:
> On 11/16/2016 06:47 AM, Johan Hovold wrote:
> > Make sure to drop the reference taken by of_phy_find_device() when
> > registering and deregistering the fixed-link PHY-device.
> > 
> > Note that we need to put both references held at deregistration.
> > 
> > Fixes: 39b0c705195e ("net: dsa: Allow configuration of CPU & DSA port
> > speeds/duplex")
> > Signed-off-by: Johan Hovold <johan@kernel.org>
> > ---
> > 
> > Hi,
> > 
> > This is one has been compile tested only, but fixes a couple of leaks
> > similar to one that was found in the cpsw driver for which I just posted
> > a patch.
> > 
> > It turns out all drivers but DSA fail to deregister the fixed-link PHYs
> > registered by of_phy_register_fixed_link(). Due to the way this
> > interface was designed, deregistering such a PHY is a bit cumbersome and
> > looks like it would benefit from a common helper.
> > 
> > However, perhaps the interface should instead be changed so that the PHY
> > device is returned so that drivers do not need to use
> > of_phy_find_device() when they need to access properties of the fixed
> > link (e.g. as in dsu_cpu_dsa_setup below).
> > 
> > Thoughts?
> > 
> > Thanks,
> > Johan
> > 
> > 
> >  net/dsa/dsa.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> > index a6902c1e2f28..798a6a776a5f 100644
> > --- a/net/dsa/dsa.c
> > +++ b/net/dsa/dsa.c
> > @@ -233,6 +233,8 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
> >  		genphy_read_status(phydev);
> >  		if (ds->ops->adjust_link)
> >  			ds->ops->adjust_link(ds, port, phydev);
> > +
> > +		phy_device_free(phydev);	/* of_phy_find_device */
> >  	}
> >  
> >  	return 0;
> > @@ -509,8 +511,12 @@ void dsa_cpu_dsa_destroy(struct device_node *port_dn)
> >  	if (of_phy_is_fixed_link(port_dn)) {
> >  		phydev = of_phy_find_device(port_dn);
> >  		if (phydev) {
> > -			phy_device_free(phydev);
> >  			fixed_phy_unregister(phydev);
> > +			/* Put references taken by of_phy_find_device() and
> > +			 * of_phy_register_fixed_link().
> > +			 */
> > +			phy_device_free(phydev);
> > +			phy_device_free(phydev);
> 
> Double free, this looks bogus here. Actually would not this mean a
> triple free since you already free in dsa_cpu_dsa_setup() which is
> paired with dsa_cpu_dsa_destroy()?

The naming of phy_device_free() is unfortunate when it's really a put():

void phy_device_free(struct phy_device *phydev)
{
	put_device(&phydev->mdio.dev);
}

which may need to be called multiple times, specifically after a call to
of_phy_find_device() which takes another reference.

With this patch the refcounts are properly balanced.

Johan
