From: David Miller <davem@davemloft.net>
Subject: Re: rndis_wlan netdev ops
Date: Wed, 25 Mar 2009 00:04:06 -0700 (PDT)
Message-ID: <20090325.000406.207637897.davem@davemloft.net>
References: <20090323.134318.106371116.davem@davemloft.net>
	<20090323140057.0f05c103@nehalam>
	<20090323.143119.121196854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754223AbZCYHES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 03:04:18 -0400
In-Reply-To: <20090323.143119.121196854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 23 Mar 2009 14:31:19 -0700 (PDT)

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 23 Mar 2009 14:00:57 -0700
> 
> > On Mon, 23 Mar 2009 13:43:18 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > Probably what we'll have to do for this case is allocate a
> > > netdev_ops copy so that the ->set_multicast_list can be set
> > > to a new value.  But that defeats the whole purpose of netdev
> > > ops so I assume you have other plans :-)
> > 
> > Why not just turn off the multicast bit in the device, or maybe
> > the hardware developer can implement set_multicast_list
> 
> We could just import the parent OPS into a local const netdevice_ops
> instance, that's how we handle this everywhere else.
> 
> To prevent changes in the parent being lost in the rndis driver we can
> encapsulate the ops assignments into a macro used by both.  Taking the
> set_multicast_list as an arg.
> 
> Alternatively the parent can provide a hook function pointer for this
> multicast operation, which the parent runs when non-NULL.

Here is how I ended up fixing this:

rndis_wlan: Fix build with netdev_ops compat disabled.

Instead of storing a private ->set_multicast_list, just
have a private netdev ops.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/rndis_wlan.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 82af21e..db91db7 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -2524,6 +2524,17 @@ static int bcm4320_early_init(struct usbnet *usbdev)
 	return 0;
 }
 
+/* same as rndis_netdev_ops but with local multicast handler */
+static const struct net_device_ops rndis_wext_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_multicast_list	= rndis_wext_set_multicast_list,
+};
+
 
 static int rndis_wext_bind(struct usbnet *usbdev, struct usb_interface *intf)
 {
@@ -2559,7 +2570,8 @@ static int rndis_wext_bind(struct usbnet *usbdev, struct usb_interface *intf)
 	 * rndis_host wants to avoid all OID as much as possible
 	 * so do promisc/multicast handling in rndis_wext.
 	 */
-	usbdev->net->set_multicast_list = rndis_wext_set_multicast_list;
+	usbdev->net->netdev_ops = &rndis_wext_netdev_ops;
+
 	tmp = RNDIS_PACKET_TYPE_DIRECTED | RNDIS_PACKET_TYPE_BROADCAST;
 	retval = rndis_set_oid(usbdev, OID_GEN_CURRENT_PACKET_FILTER, &tmp,
 								sizeof(tmp));
-- 
1.6.2.1.222.g570cc

