From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v3 09/15] net: dsa: Add support for switch EEPROM access
Date: Thu, 30 Oct 2014 15:39:51 -0700
Message-ID: <20141030223951.GA19489@roeck-us.net>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
 <1414604707-22407-10-git-send-email-linux@roeck-us.net>
 <20141030211131.GB32139@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141030211131.GB32139@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 30, 2014 at 10:11:31PM +0100, Andrew Lunn wrote:
> > +static int dsa_slave_get_eeprom_len(struct net_device *dev)
> > +{
> > +	struct dsa_slave_priv *p = netdev_priv(dev);
> > +	struct dsa_switch *ds = p->parent;
> > +
> > +	if (ds->pd->eeprom_len)
> > +		return ds->pd->eeprom_len;
> > +
> > +	if (ds->drv->get_eeprom_len)
> > +		return ds->drv->get_eeprom_len(ds);
> > +
> > +	return 0;
> > +}
> > +
> 
> Hi Guenter
> 
> I just started doing some testing with this patchset. A bit late since
> David just accepted it, but...
> 
> root@dir665:~# ethtool -e lan4
> Cannot get EEPROM data: Invalid argument
> root@dir665:~# ethtool -e eth0
> Cannot get EEPROM data: Operation not supported
> 
> There is no eeprom for the hardware i'm testing. Operation not
> supported seems like a better error code and Invalid argument, and is
> what other network drivers i tried returned.
> 
Hi Andrew,

I think the problem is that the infrastructure code (net/core/ethtool.c)
does not accept an error from the get_eeprom_len function, but instead
assumes that reporting eeprom data is supported if a driver provides
the access functions. The get_eeprom_len function returns 0 in your case,
which in ethtool_get_any_eeprom() translates to -EINVAL because user space
either requests no data or more data than available. I wonder why user
space requests anything in the first place; I would have assumed that it
reads the driver information first and is told that the eeprom length is 0,
but I guess that is a different question.

I quickly browsed through a couple of other drivers supporting get_eprom_len,
and they all return 0 if there is no eeprom. Doesn't that mean that they all
end up reporting -EINVAL if an attempt is made to read the eeprom ?

The only solution that comes to my mind would be to have the infrastructure
code check the return value from get_eeprom_len and return -EOPNOTSUPP
if the reported eeprom length is 0. That would be an infrastructure change,
though. Does that sound reasonable, or do you have a better idea ?

In parallel, I'll have a look into the ethtool command to see why it
requests eeprom data even though the reported eeprom length is 0.

Thanks,
Guenter
