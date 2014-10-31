From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v3 09/15] net: dsa: Add support for switch EEPROM access
Date: Thu, 30 Oct 2014 18:00:39 -0700
Message-ID: <20141031010039.GA29492@roeck-us.net>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
 <1414604707-22407-10-git-send-email-linux@roeck-us.net>
 <20141030211131.GB32139@lunn.ch>
 <20141030223951.GA19489@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:51809 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaJaBBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 21:01:21 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1Xk0aA-0021Mo-M3
	for netdev@vger.kernel.org; Fri, 31 Oct 2014 01:00:50 +0000
Content-Disposition: inline
In-Reply-To: <20141030223951.GA19489@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2014 at 03:39:51PM -0700, Guenter Roeck wrote:
> On Thu, Oct 30, 2014 at 10:11:31PM +0100, Andrew Lunn wrote:
> > > +static int dsa_slave_get_eeprom_len(struct net_device *dev)
> > > +{
> > > +	struct dsa_slave_priv *p = netdev_priv(dev);
> > > +	struct dsa_switch *ds = p->parent;
> > > +
> > > +	if (ds->pd->eeprom_len)
> > > +		return ds->pd->eeprom_len;
> > > +
> > > +	if (ds->drv->get_eeprom_len)
> > > +		return ds->drv->get_eeprom_len(ds);
> > > +
> > > +	return 0;
> > > +}
> > > +
> > 
> > Hi Guenter
> > 
> > I just started doing some testing with this patchset. A bit late since
> > David just accepted it, but...
> > 
> > root@dir665:~# ethtool -e lan4
> > Cannot get EEPROM data: Invalid argument
> > root@dir665:~# ethtool -e eth0
> > Cannot get EEPROM data: Operation not supported
> > 
> > There is no eeprom for the hardware i'm testing. Operation not
> > supported seems like a better error code and Invalid argument, and is
> > what other network drivers i tried returned.
> > 
> Hi Andrew,
> 
> I think the problem is that the infrastructure code (net/core/ethtool.c)
> does not accept an error from the get_eeprom_len function, but instead
> assumes that reporting eeprom data is supported if a driver provides
> the access functions. The get_eeprom_len function returns 0 in your case,
> which in ethtool_get_any_eeprom() translates to -EINVAL because user space
> either requests no data or more data than available. I wonder why user
> space requests anything in the first place; I would have assumed that it
> reads the driver information first and is told that the eeprom length is 0,
> but I guess that is a different question.
> 
> I quickly browsed through a couple of other drivers supporting get_eprom_len,
> and they all return 0 if there is no eeprom. Doesn't that mean that they all
> end up reporting -EINVAL if an attempt is made to read the eeprom ?
> 
> The only solution that comes to my mind would be to have the infrastructure
> code check the return value from get_eeprom_len and return -EOPNOTSUPP
> if the reported eeprom length is 0. That would be an infrastructure change,
> though. Does that sound reasonable, or do you have a better idea ?
> 
> In parallel, I'll have a look into the ethtool command to see why it
> requests eeprom data even though the reported eeprom length is 0.
> 
As suspected, ethtool will attempt to read a zero-length eeprom.

The following patch should solve the problem. Not sure if it is worth it,
though, since this will change behavior for existing drivers.

Thanks,
Guenter

---
From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 30 Oct 2014 17:51:34 -0700
Subject: [RFC PATCH] net: ethtool: Return -EOPNOTSUPP if user space tries to read
 EEPROM with lengh 0

If a driver supports reading EEPROM but no EEPROM is installed in the system,
the driver's get_eeprom_len function will return 0. ethtool will subsequently
try to read that zero-length EEPROM anyway. If the driver does not support
EEPROM access at all, this operation will return -EOPNOTSUPP. If the driver
does support EEPROM access but no EEPROM is installed, the operation will
return -EINVAL. Return -EOPNOTSUPP in both cases for consistency.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 net/core/ethtool.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1600aa2..06dfb29 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1036,7 +1036,8 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 
-	if (!ops->get_eeprom || !ops->get_eeprom_len)
+	if (!ops->get_eeprom || !ops->get_eeprom_len ||
+	    !ops->get_eeprom_len(dev))
 		return -EOPNOTSUPP;
 
 	return ethtool_get_any_eeprom(dev, useraddr, ops->get_eeprom,
@@ -1052,7 +1053,8 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 	u8 *data;
 	int ret = 0;
 
-	if (!ops->set_eeprom || !ops->get_eeprom_len)
+	if (!ops->set_eeprom || !ops->get_eeprom_len ||
+	    !ops->get_eeprom_len(dev))
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&eeprom, useraddr, sizeof(eeprom)))
-- 
1.9.1
