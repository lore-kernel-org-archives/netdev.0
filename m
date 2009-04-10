From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 1/1] Tell linkwatch about new interfaces
Date: Thu, 9 Apr 2009 17:48:04 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0904091128270.6048@jbrandeb-desk1.amr.corp.intel.com>
References: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>  <20090404.170539.148727646.davem@davemloft.net> <cb0375e10904042100o1a203512l593021ee66cb591d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Andrew Lutomirski <amluto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29458 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764816AbZDJAsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2009 20:48:05 -0400
In-Reply-To: <cb0375e10904042100o1a203512l593021ee66cb591d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 4 Apr 2009, Andrew Lutomirski wrote:
> On Sat, Apr 4, 2009 at 8:05 PM, David Miller <davem@davemloft.net> wrote:
> > From: Andrew Lutomirski <amluto@gmail.com>
> > Date: Wed, 1 Apr 2009 11:40:06 -0400
> >
> >> When a network driver registers a new interface, linkwatch will not notice,
> >> and hence not set the rfc2863 operstate, until netif_carrier_on gets called.
> >> If the new interface has no carrier when it is connected, then a status of
> >> "unknown" is reported to userspace, which confuses various tools
> >> (NetworkManager, for example).
> >>
> >> This fires a linkwatch event for all new interfaces, so that operstate
> >> gets set reasonably quickly.
> >>
> >> Signed-off-by: Andrew Lutomirski <amluto@gmail.com>
> >
> > The default assumed state for a freshly registered network
> > device is that the link is up.
> >
> > If that disagrees from reality, the driver should make the
> > appropriate netif_carrier_off() call.
> >
> > I'm sure you'll find that the e1000 driver is not doing this
> > and that is what causes the bug you are seeing.
> >

Dave, if we move the netif_carrier_off call to our dev->open like tg3 has, 
do you think this is sufficient?

I note that we were calling netif_tx_stop_all_queues here, but I'm curious 
if davem thinks we need to lock out our tx routine until dev->open 
completes or whether the starting state of the netdev is sufficient.

> Nope.  The end of e1000_probe (in e1000e) is:
> 
>         /* tell the stack to leave us alone until e1000_open() is called */
>         netif_carrier_off(netdev);
>         netif_tx_stop_all_queues(netdev);
> 
>         strcpy(netdev->name, "eth%d");
>         err = register_netdev(netdev);
>         if (err)
>                 goto err_register;
> 
>         e1000_print_device_info(adapter);
> 
> netif_carrier_off does:
> 
> void netif_carrier_off(struct net_device *dev)
> {
>         if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
>                 if (dev->reg_state == NETREG_UNINITIALIZED)
>                         return;
>                 linkwatch_fire_event(dev);
>         }
> }
> 
> So, either it should be illegal to call netif_carrier_off on an
> unregistered net_device (and there should be a WARN() in
> netif_carrier_off), or it should work correctly, and
> register_netdevice should do the right thing when there is no carrier
> (i.e. something like my patch).

does this patch also fix the issue?

===== begin =====

e1000e: indicate link down at load

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

same kind of patch as e1000, let driver explicitly push link state
once link comes up.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000e/netdev.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index fb78278..6a0411e 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3072,6 +3072,8 @@ static int e1000_open(struct net_device *netdev)
 	if (test_bit(__E1000_TESTING, &adapter->state))
 		return -EBUSY;
 
+	netif_carrier_off(netdev);
+
 	/* allocate transmit descriptors */
 	err = e1000e_setup_tx_resources(adapter);
 	if (err)
@@ -5006,10 +5008,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (!(adapter->flags & FLAG_HAS_AMT))
 		e1000_get_hw_control(adapter);
 
-	/* tell the stack to leave us alone until e1000_open() is called */
-	netif_carrier_off(netdev);
-	netif_tx_stop_all_queues(netdev);
-
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
