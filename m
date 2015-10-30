From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: assert SMI lock
Date: Fri, 30 Oct 2015 16:50:49 -0400
Message-ID: <20151030205048.GA6658@ketchup.mtl.sfl>
References: <1446237342-5109-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20151030204110.GB10053@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151030204110.GB10053@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Oct. Friday 30 (44) 09:41 PM, Andrew Lunn wrote:
> On Fri, Oct 30, 2015 at 04:35:42PM -0400, Vivien Didelot wrote:
> > It's easy to forget to lock the smi_mutex before calling the low-level
> > _mv88e6xxx_reg_{read,write}, so add a assert_smi_lock function in them.
> > 
> > Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> > ---
> >  drivers/net/dsa/mv88e6xxx.c | 31 ++++++++++++++++++-------------
> >  1 file changed, 18 insertions(+), 13 deletions(-)
> > 
> > diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> > index b1b14f5..70a0106 100644
> > --- a/drivers/net/dsa/mv88e6xxx.c
> > +++ b/drivers/net/dsa/mv88e6xxx.c
> > @@ -24,6 +24,16 @@
> >  #include <net/switchdev.h>
> >  #include "mv88e6xxx.h"
> >  
> > +static inline void assert_smi_lock(struct dsa_switch *ds)
> 
> No need for inline. Gcc will automatically inline it, if it thinks it
> is small enough.

OK, I will respin this without the inline keyword then.

> 
> > +{
> > +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> > +
> > +	if (unlikely(!mutex_is_locked(&ps->smi_mutex))) {
> > +		dev_err(ds->master_dev, "SMI lock not held!\n");
> > +		dump_stack();
> > +	}
> > +}
> > +
> 
> > -/* Must be called with SMI mutex held */
> >  static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
> >  {
> > -	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> > +	struct mii_bus *bus;
> >  	int ret;
> >  
> > +	assert_smi_lock(ds);
> > +
> > +	bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> 
> Is this change of when bus is assigned actually required?

No, but I found not necessary to issue this "mdio_bus" lookup if the
lock is not held (see net/dsa/dsa.c:555). Do you prefer not to do that?

Also are you OK with removing all the "Must be called with..." comments,
which I found not necessary too (some function have this comment, some
others don't).

Thanks,
-v
