From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: [PATCH] dm9601: warn on invalid mac address
Date: Wed, 7 Jan 2009 12:55:05 +0800
Message-ID: <20090107045505.GB8071@localhost>
References: <20090106091050.GA19316@localhost> <87zli4u71i.fsf@macbook.be.48ers.dk> <1231242755.3789.9.camel@deadeye.i.decadent.org.uk> <20090106.105226.58880881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, jacmet@sunsite.dk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:44757 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752394AbZAGEz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 23:55:27 -0500
Content-Disposition: inline
In-Reply-To: <20090106.105226.58880881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 10:52:26AM -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 06 Jan 2009 11:52:35 +0000
> 
> > On Tue, 2009-01-06 at 10:18 +0100, Peter Korsgaard wrote:
> > > >>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:
> > > 
> > > Hi,
> > > 
> > >  Wu> Add warnings on invalid mac address to help disclose/debug problems.
> > >  Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > >  Wu> ---
> > >  Wu>  drivers/net/usb/dm9601.c |   12 +++++++++++-
> > >  Wu>  1 file changed, 11 insertions(+), 1 deletion(-)
> > > 
> > >  Wu> --- linux-2.6.orig/drivers/net/usb/dm9601.c
> > >  Wu> +++ linux-2.6/drivers/net/usb/dm9601.c
> > >  Wu> @@ -401,8 +401,12 @@ static int dm9601_set_mac_address(struct
> > >  Wu>  	struct sockaddr *addr = p;
> > >  Wu>  	struct usbnet *dev = netdev_priv(net);
> > >  
> > >  Wu> -	if (!is_valid_ether_addr(addr->sa_data))
> > >  Wu> +	if (!is_valid_ether_addr(addr->sa_data)) {
> > >  Wu> +		DECLARE_MAC_BUF(mac_buf);
> > >  Wu> +		print_mac(mac_buf, addr->sa_data);
> > >  Wu> +		dev_warn(&net->dev, "not setting invalid mac address %s\n", mac_buf);
> > > 
> > > This should be an error and not a warning.
> > > Notice that print_mac returns the string, so you can do:
> > > 
> > > dev_err(&net->dev, "... %s", print_mac(mac_buf, addr->sa_data));
> > 
> > print_mac() is already obsolete; use %pM in the format string instead.
> 
> Yep, please fix this.

Thanks for the tip. Here is the updated patch.

Thanks,
Fengguang
---
dm9601: warn on invalid mac address

Add warnings on invalid mac address to help disclose/debug problems.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/net/usb/dm9601.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

--- linux-2.6.orig/drivers/net/usb/dm9601.c
+++ linux-2.6/drivers/net/usb/dm9601.c
@@ -406,8 +406,11 @@ static int dm9601_set_mac_address(struct
 	struct sockaddr *addr = p;
 	struct usbnet *dev = netdev_priv(net);
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!is_valid_ether_addr(addr->sa_data)) {
+		dev_err(&net->dev, "not setting invalid mac address %pM\n",
+								addr->sa_data);
 		return -EINVAL;
+	}
 
 	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
 	__dm9601_set_mac_address(dev);
@@ -454,8 +457,12 @@ static int dm9601_bind(struct usbnet *de
 	 */
 	if (is_valid_ether_addr(mac))
 		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
-	else
+	else {
+		printk(KERN_WARNING
+			"dm9601: No valid MAC address in EEPROM, using %pM\n",
+			dev->net->dev_addr);
 		__dm9601_set_mac_address(dev);
+	}
 
 	/* power up phy */
 	dm_write_reg(dev, DM_GPR_CTRL, 1);
