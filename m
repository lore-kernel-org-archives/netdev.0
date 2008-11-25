From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netdev: generate kobject uevent on network state
 transitions
Date: Mon, 24 Nov 2008 20:14:40 -0800
Message-ID: <20081124201440.0e4d61cc@extreme>
References: <20081121234110.22b47154@extreme>
	<ac3eb2510811220608y33662b0bkb66026c2a21b061e@mail.gmail.com>
	<F6B63A37-A69F-4197-B7E5-C9FD9BFA76F6@holtmann.org>
	<20081122223249.4be03e4e@extreme>
	<ac3eb2510811230813s3cb5c248k1e15d9ece581c8ad@mail.gmail.com>
	<20081124114522.1e8de3fe@extreme>
	<1227557174.3162.7.camel@achroite>
	<20081124150347.73050f98@extreme>
	<AAE2573A-3C23-4C61-89E1-3A6F31D7B23E@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Kay Sievers <kay.sievers@vrfy.org>,
	David Miller <davem@davemloft.net>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <AAE2573A-3C23-4C61-89E1-3A6F31D7B23E@holtmann.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Nov 2008 04:51:53 +0100
Marcel Holtmann <marcel@holtmann.org> wrote:

> Hi Stephen,
> 
> > It is easier for some applications to deal with text based interfaces
> > like uevent, rather than using netlink to listen for events.
> >
> > Note, this does not deal with network namespaces but that is a generic
> > problem that already exists with kobjects (see rename events).
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > ---
> > net/core/Makefile |    1
> > net/core/uevent.c |   61 ++++++++++++++++++++++++++++++++++++++++++++ 
> > ++++++++++
> > 2 files changed, 62 insertions(+)
> >
> > --- a/net/core/Makefile	2008-11-24 12:07:18.000000000 -0800
> > +++ b/net/core/Makefile	2008-11-24 12:07:22.000000000 -0800
> > @@ -17,3 +17,4 @@ obj-$(CONFIG_NET_PKTGEN) += pktgen.o
> > obj-$(CONFIG_NETPOLL) += netpoll.o
> > obj-$(CONFIG_NET_DMA) += user_dma.o
> > obj-$(CONFIG_FIB_RULES) += fib_rules.o
> > +obj-$(CONFIG_HOTPLUG) += uevent.o
> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ b/net/core/uevent.c	2008-11-24 12:11:46.000000000 -0800
> > @@ -0,0 +1,55 @@
> > +/*
> > + * Linux network device event notification
> > + *
> > + * Author:
> > + *	Stephen Hemminger <shemminger@vyatta.com>
> > + */
> > +
> > +#include <linux/kernel.h>
> > +#include <linux/netdevice.h>
> > +#include <linux/kobject.h>
> > +#include <linux/notifier.h>
> > +
> > +/*
> > + * Generate uevent in response to network device state changes.
> > + * Other events are already handled by device subsystem.
> > + */
> > +static int netdev_event(struct notifier_block *this, unsigned long  
> > event, void *ptr)
> > +{
> > +	struct net_device *netdev = ptr;
> > +
> > +	switch (event) {
> > +	case NETDEV_UP:
> > +		kobject_uevent(&netdev->dev.kobj, KOBJ_ONLINE);
> > +		break;
> > +
> > +	case NETDEV_DOWN:
> > +		kobject_uevent(&netdev->dev.kobj, KOBJ_OFFLINE);
> > +		break;
> > +
> > +	case NETDEV_CHANGE: {
> > +		char str[64] = "DEVSTATE=UP";
> > +		char *envp[2] = { str, NULL };
> > +
> > +		if (netif_oper_up(netdev))
> > +			strcat(str, ",RUNNING");
> > +		if (netif_carrier_ok(netdev))
> > +			strcat(str, ",LOWER_UP");
> > +		if (netif_dormant(netdev))
> > +			strcat(str, ",DORMANT");
> > +		kobject_uevent_env(&netdev->dev.kobj, KOBJ_CHANGE, envp);
> > +		break;
> 
> do we wanna copy just what ifconfig shows or do we might be a more  
> intelligent and have separate variables like RUNNING=1 etc.?
> 
> Regards
> 
> Marcel

Was arbitrary choice to just use same flags as existing ifconfig.
What ever feels best I guess...

