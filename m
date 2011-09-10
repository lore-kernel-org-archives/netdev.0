From: Lin Ming <ming.m.lin@intel.com>
Subject: Re: [PATCH -next] drivers/net: Makefile, fix netconsole link order
Date: Sat, 10 Sep 2011 10:43:32 +0800
Message-ID: <1315622612.2425.16.camel@hp6530s>
References: <1315298129.16061.24.camel@snb>
	 <20110909170027.c4bf6151.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110909170027.c4bf6151.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-09-10 at 08:00 +0800, Andrew Morton wrote:
> On Tue, 06 Sep 2011 16:35:29 +0800
> Lin Ming <ming.m.lin@intel.com> wrote:
> 
> > Commit 88491d8(drivers/net: Kconfig & Makefile cleanup) causes a
> > regression that netconsole does not work if netconsole and network
> > device driver are build into kernel, because netconsole is linked before
> > network device driver.
> > 
> > Fixes it by moving netconsole.o after network device driver.
> > 
> > Signed-off-by: Lin Ming <ming.m.lin@intel.com>
> > ---
> >  drivers/net/Makefile |    7 ++++++-
> >  1 files changed, 6 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> > index fa877cd..ec15311 100644
> > --- a/drivers/net/Makefile
> > +++ b/drivers/net/Makefile
> > @@ -14,7 +14,6 @@ obj-$(CONFIG_MACVTAP) += macvtap.o
> >  obj-$(CONFIG_MII) += mii.o
> >  obj-$(CONFIG_MDIO) += mdio.o
> >  obj-$(CONFIG_NET) += Space.o loopback.o
> > -obj-$(CONFIG_NETCONSOLE) += netconsole.o
> >  obj-$(CONFIG_PHYLIB) += phy/
> >  obj-$(CONFIG_RIONET) += rionet.o
> >  obj-$(CONFIG_TUN) += tun.o
> > @@ -66,3 +65,9 @@ obj-$(CONFIG_USB_USBNET)        += usb/
> >  obj-$(CONFIG_USB_ZD1201)        += usb/
> >  obj-$(CONFIG_USB_IPHETH)        += usb/
> >  obj-$(CONFIG_USB_CDC_PHONET)   += usb/
> > +
> > +#
> > +# If netconsole and network device driver are build-in,
> > +# netconsole must be linked after network device driver
> > +#
> > +obj-$(CONFIG_NETCONSOLE) += netconsole.o
> 
> It would be preferable to fix this with initcall ordering.  Perhaps by
> switching init_netconsole() to subsys_initcall.

subsys_initcall is defined as __define_initcall("4",fn,4).
In !MODULE case, device driver module_int() is defined as
__define_initcall("6",fn,6)

If we use subsys_initcall for init_netconsole, it will still be called
before network device driver is initialized.

How about late_initcall?

(Not tested yet)

>From 11f4f035e96ff430192d0a75552dd715acb5f3b8 Mon Sep 17 00:00:00 2001
From: Lin Ming <ming.m.lin@intel.com>
Date: Sat, 10 Sep 2011 10:36:10 +0800
Subject: [PATCH] drivers/net: Makefile, fix netconsole link order

Commit 88491d8(drivers/net: Kconfig & Makefile cleanup) causes a
regression that netconsole does not work if netconsole and network
device driver are build into kernel, because netconsole is linked before
network device driver.

Fixes it by switching init_netconsole() to late_initcall if it's
build-in.

Signed-off-by: Lin Ming <ming.m.lin@intel.com>
---
 drivers/net/netconsole.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index dfc8272..914be29 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -799,5 +799,9 @@ static void __exit cleanup_netconsole(void)
 	}
 }
 
+#ifdef MODULE
 module_init(init_netconsole);
 module_exit(cleanup_netconsole);
+#else
+late_initcall(init_netconsole);
+#endif /* !MODULE */
-- 
1.7.2.3
