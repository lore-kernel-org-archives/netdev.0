From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 8 Aug 2011 04:15:22 -0500
Message-ID: <20110808091522.GR4926@sgi.com>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>
	<1312641270-6018-6-git-send-email-holt@sgi.com>
	<4E3FA066.3020301@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E3FA066.3020301-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 08, 2011 at 10:37:58AM +0200, Wolfgang Grandegger wrote:
> On 08/06/2011 04:34 PM, Robin Holt wrote:
> > flexcan driver needs the clk_get, clk_get_rate, etc functions
> > to work.  This patch provides the minimum functionality.
> 
> This needs some more general thoughts... apart from the question where
> the code should go.
> 
> Like for the MSCAN on the MPC5200, the user should be *able* to select
> an appropriate clock source and divider via DTS node properties.
> Currently it seems, that the DTS properties must match some
> pre-configured values, most likely set by the boot loader. Please
> correct me if I'm wrong. For me this is generic and should go into the
> Flexcan driver. From there, a platform specific function, e.g.
> flexcan_set_clock() might be called.

The P1010 really only supports the system bus clock for a source.  I was
wrong last week when I said it supported either.  That was a confusion
I have because of a task I was assigned a couple months ago.

It can select different divider values.

Robin

> 
> 
> > Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> > To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> > To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> > Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> > Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > ---
> >  arch/powerpc/platforms/85xx/p1010rdb.c |   78 ++++++++++++++++++++++++++++++++
> >  1 files changed, 78 insertions(+), 0 deletions(-)
> > 
> > diff --git a/arch/powerpc/platforms/85xx/p1010rdb.c b/arch/powerpc/platforms/85xx/p1010rdb.c
> > index 3540a88..8f78ddd 100644
> > --- a/arch/powerpc/platforms/85xx/p1010rdb.c
> > +++ b/arch/powerpc/platforms/85xx/p1010rdb.c
> > @@ -28,6 +28,7 @@
> >  #include <asm/udbg.h>
> >  #include <asm/mpic.h>
> >  #include <asm/swiotlb.h>
> > +#include <asm/clk_interface.h>
> >  
> >  #include <sysdev/fsl_soc.h>
> >  #include <sysdev/fsl_pci.h>
> > @@ -164,6 +165,82 @@ static void __init p1010_rdb_setup_arch(void)
> >  	printk(KERN_INFO "P1010 RDB board from Freescale Semiconductor\n");
> >  }
> >  
> > +/*
> > + * p1010rdb needs to provide a clock source for the flexcan driver.
> > + */
> > +struct clk {
> > +	unsigned long rate;
> > +} p1010rdb_system_clk;
> > +
> > +static struct clk *p1010_rdb_clk_get(struct device *dev, const char *id)
> > +{
> 
> I persoanlly don't like the
> 
> > +	struct clk *clk;
> > +	u32 *of_property;
> > +	unsigned long clock_freq, clock_divider;
> > +	const char *dev_init_name;
> > +
> > +	if (!dev)
> > +		return ERR_PTR(-ENOENT);
> > +
> > +	/*
> > +	 * The can devices are named ffe1c000.can0 and ffe1d000.can1 on
> > +	 * the p1010rdb.  Check for the "can" portion of that name before
> > +	 * returning a clock source.
> > +	 */
> > +	dev_init_name = dev_name(dev);
> > +	if (strlen(dev_init_name) != 13)
> > +		return ERR_PTR(-ENOENT);
> > +	dev_init_name += 9;
> > +	if (strncmp(dev_init_name, "can", 3))
> > +		return ERR_PTR(-ENOENT);
> 
> There are dedicated functions to find the of node. But with my above
> proposal we do not need to provide p1010_rdb_clk_get().
> 
> More comments on the other patches soon...
> 
> Wolfgang.
