From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] net: dsa: fix fixed-link-phy device leaks
Date: Thu, 17 Nov 2016 17:47:34 +0100
Message-ID: <20161117164734.GC10490@localhost>
References: <1479307664-32428-1-git-send-email-johan@kernel.org>
 <42af57ed-df84-f628-659d-c982d30da7d5@gmail.com>
 <20161116171145.GE4864@localhost>
 <8387696c-813a-4c88-5f10-7d2e5fdae6b8@gmail.com>
 <20161117095225.GC21237@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34785 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932790AbcKQQ7Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 11:59:24 -0500
Content-Disposition: inline
In-Reply-To: <20161117095225.GC21237@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2016 at 10:52:25AM +0100, Johan Hovold wrote:
> On Wed, Nov 16, 2016 at 10:14:10AM -0800, Florian Fainelli wrote:
> > On 11/16/2016 09:11 AM, Johan Hovold wrote:
> > > On Wed, Nov 16, 2016 at 09:06:26AM -0800, Florian Fainelli wrote:
> > >> On 11/16/2016 06:47 AM, Johan Hovold wrote:
> > >>> Make sure to drop the reference taken by of_phy_find_device() when
> > >>> registering and deregistering the fixed-link PHY-device.
> > >>>
> > >>> Note that we need to put both references held at deregistration.
> > >>>
> > >>> Fixes: 39b0c705195e ("net: dsa: Allow configuration of CPU & DSA port
> > >>> speeds/duplex")
> > >>> Signed-off-by: Johan Hovold <johan@kernel.org>
> > >>> ---
> > >>>
> > >>> Hi,
> > >>>
> > >>> This is one has been compile tested only, but fixes a couple of leaks
> > >>> similar to one that was found in the cpsw driver for which I just posted
> > >>> a patch.
> > >>>
> > >>> It turns out all drivers but DSA fail to deregister the fixed-link PHYs
> > >>> registered by of_phy_register_fixed_link(). Due to the way this
> > >>> interface was designed, deregistering such a PHY is a bit cumbersome and
> > >>> looks like it would benefit from a common helper.
> > >>>
> > >>> However, perhaps the interface should instead be changed so that the PHY
> > >>> device is returned so that drivers do not need to use
> > >>> of_phy_find_device() when they need to access properties of the fixed
> > >>> link (e.g. as in dsu_cpu_dsa_setup below).
> > >>>
> > >>> Thoughts?
> > >>>
> > >>> Thanks,
> > >>> Johan
> > >>>
> > >>>
> > >>>  net/dsa/dsa.c | 8 +++++++-
> > >>>  1 file changed, 7 insertions(+), 1 deletion(-)
> > >>>
> > >>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> > >>> index a6902c1e2f28..798a6a776a5f 100644
> > >>> --- a/net/dsa/dsa.c
> > >>> +++ b/net/dsa/dsa.c
> > >>> @@ -233,6 +233,8 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
> > >>>  		genphy_read_status(phydev);
> > >>>  		if (ds->ops->adjust_link)
> > >>>  			ds->ops->adjust_link(ds, port, phydev);
> > >>> +
> > >>> +		phy_device_free(phydev);	/* of_phy_find_device */
> > >>>  	}
> > >>>  
> > >>>  	return 0;
> > >>> @@ -509,8 +511,12 @@ void dsa_cpu_dsa_destroy(struct device_node *port_dn)
> > >>>  	if (of_phy_is_fixed_link(port_dn)) {
> > >>>  		phydev = of_phy_find_device(port_dn);
> > >>>  		if (phydev) {
> > >>> -			phy_device_free(phydev);
> > >>>  			fixed_phy_unregister(phydev);
> > >>> +			/* Put references taken by of_phy_find_device() and
> > >>> +			 * of_phy_register_fixed_link().
> > >>> +			 */
> > >>> +			phy_device_free(phydev);
> > >>> +			phy_device_free(phydev);
> > >>
> > >> Double free, this looks bogus here. Actually would not this mean a
> > >> triple free since you already free in dsa_cpu_dsa_setup() which is
> > >> paired with dsa_cpu_dsa_destroy()?
> > > 
> > > The naming of phy_device_free() is unfortunate when it's really a put():
> > > 
> > > void phy_device_free(struct phy_device *phydev)
> > > {
> > > 	put_device(&phydev->mdio.dev);
> > > }
> > 
> > Indeed, should have looked a little harder.
> > 
> > > 
> > > which may need to be called multiple times, specifically after a call to
> > > of_phy_find_device() which takes another reference.
> > > 
> > > With this patch the refcounts are properly balanced.
> > 
> > The intent of your patch is good, but it still feels like having to
> > double imbalance the refcount is symptomatic of a larger issue here, it
> > does not seem like having several refcounts are necessary, so we may
> > really want to rework the API.
> 
> I'll cook something up for -next, but how about using
> 
> 	put_device(&phydev->mdio.dev)
> 
> for the reference taken by of_phy_find_device() (as some driver
> already do) to fix the immediate leaks?
> 
> Then deregistration would look like:
> 
> 	phydev = of_phy_find_device(port_dn);
> 	if (phydev) {
> -			phy_device_free(phydev);
> 			fixed_phy_unregister(phydev);
> +			put_device(&phydev->mdio.dev)
> +			phy_device_free(phydev);

On second thought, I suggest just renaming the phy_device_free() as
phy_device_put() to reflect what it really does these days. There can
never be a guarantee that the phy is freed on a call to
phy_device_free() anyway.

The OF interface can still be modified to return a pointer later.

Johan
