From: Olof Johansson <olof@lixom.net>
Subject: Re: [Pasemi-linux] [patch 1/6] pasemi_mac: Move RX/TX section
	enablement to dma_lib
Date: Wed, 5 Mar 2008 12:21:00 -0600
Message-ID: <20080305182100.GA8411@lixom.net>
References: <20080221025753.903665000@lixom.net> <20080221025929.082348000@lixom.net> <1204026366.7203.9.camel@concordia> <20080226141420.GA22572@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pasemi-linux@ozlabs.org, jgarzik@pobox.com,
	linuxppc-dev@ozlabs.org
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:52627 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754826AbYCESPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 13:15:37 -0500
Content-Disposition: inline
In-Reply-To: <20080226141420.GA22572@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2008 at 08:14:20AM -0600, Olof Johansson wrote:
> Hi,
> 
> On Tue, Feb 26, 2008 at 10:46:06PM +1100, Michael Ellerman wrote:
> > On Wed, 2008-02-20 at 20:57 -0600, Olof Johansson wrote:
> > > +	i = 1000;
> > > +	pasemi_write_dma_reg(PAS_DMA_COM_RXCMD, 0);
> > > +	while ((i > 0) && (pasemi_read_dma_reg(PAS_DMA_COM_RXSTA) & 1))
> > > +		i--;
> > > +	if (i < 0)
> > > +		printk(KERN_INFO "Warning: Could not disable RX section\n");
> > > +
> > > +	i = 1000;
> > > +	pasemi_write_dma_reg(PAS_DMA_COM_TXCMD, 0);
> > > +	while ((i > 0) && (pasemi_read_dma_reg(PAS_DMA_COM_TXSTA) & 1))
> > > +		i--;
> > 
> > This kind of caught my eye, is it still going to work when the next core
> > is twice as fast?
> 
> Actually, I added the variable right before posting, I used to have an
> infinite loop there while testing the patch. I've never seen it do more
> than a few rounds, so I'm not that worried.
> 
> We already have a similar loop in the channel shutdown code, but it runs
> a bit longer. I might bring that over instead. Thanks for pointing it
> out.

FYI; I've commited in this change, rest of the patch is identical.

diff --git a/arch/powerpc/platforms/pasemi/dma_lib.c b/arch/powerpc/platforms/pasemi/dma_lib.c
index c529d8d..48cb7c9 100644
--- a/arch/powerpc/platforms/pasemi/dma_lib.c
+++ b/arch/powerpc/platforms/pasemi/dma_lib.c
@@ -17,6 +17,7 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
  */
 
+#include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/pci.h>
@@ -410,6 +411,7 @@ int pasemi_dma_init(void)
 	struct resource res;
 	struct device_node *dn;
 	int i, intf, err = 0;
+	unsigned long timeout;
 	u32 tmp;
 
 	if (!machine_is(pasemi))
@@ -478,6 +480,34 @@ int pasemi_dma_init(void)
 	for (i = 0; i < MAX_RXCH; i++)
 		__set_bit(i, rxch_free);
 
+	timeout = jiffies + HZ;
+	pasemi_write_dma_reg(PAS_DMA_COM_RXCMD, 0);
+	while (pasemi_read_dma_reg(PAS_DMA_COM_RXSTA) & 1) {
+		if (time_after(jiffies, timeout)) {
+			pr_warning("Warning: Could not disable RX section\n");
+			break;
+		}
+	}
+
+	timeout = jiffies + HZ;
+	pasemi_write_dma_reg(PAS_DMA_COM_TXCMD, 0);
+	while (pasemi_read_dma_reg(PAS_DMA_COM_TXSTA) & 1) {
+		if (time_after(jiffies, timeout)) {
+			pr_warning("Warning: Could not disable TX section\n");
+			break;
+		}
+	}
