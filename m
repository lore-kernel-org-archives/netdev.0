From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: [PATCH] dm9601: warn on invalid mac address
Date: Wed, 7 Jan 2009 12:52:58 +0800
Message-ID: <20090107045258.GA8071@localhost>
References: <20090106091050.GA19316@localhost> <87zli4u71i.fsf@macbook.be.48ers.dk> <20090106094757.GA19587@localhost> <87r63gu1i3.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:23567 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751859AbZAGExU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 23:53:20 -0500
Content-Disposition: inline
In-Reply-To: <87r63gu1i3.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 12:17:56PM +0100, Peter Korsgaard wrote:
> >>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:
> 
> Hi,
> 
>  Wu> if (is_valid_ether_addr(mac))
>  Wu> memcpy(dev->net->dev_addr, mac, ETH_ALEN);
>  Wu> +	else {
>  Wu> +		DECLARE_MAC_BUF(mac_buf);
>  Wu> +		print_mac(mac_buf, mac);
>  Wu> +		devdbg(dev, "EEPROM reported mac address %s is invalid,"
>  Wu> +				" use the randomly generated one.", mac_buf);
>  >> 
>  >> And this should be a warning.
> 
>  Wu> Then let the warning message appear repeatedly for some devices?
> 
> This is called at probe time - But yes, I think it makes sense to print
> it.
> 
> We should print the random address instead of the ff's though.
> 
>  Wu> Also dev_warn() won't be able to show the device name at that time,
>  Wu> like this:
> 
> Ah yes, that's presumably why I used a raw printk just above.
> 
>  Wu> [28489.062180] : EEPROM reported mac address ff:ff:ff:ff:ff:ff is
>  Wu> invalid, use the randomly generated one.
> 
> I would prefer something like:
> 
> printk(KERN_WARNING "dm9601: No valid MAC address in EEPROM, using %s\n",
>        print_mac(..));

This looks better :-)

> Also, it seems like you're not writing the random address to the
> hardware registers, so you won't be able to receive any unicast -
> You'll need to add a call to dm9601_set_mac_address() or similar.

Good catch. I had wanted to ask why it only works with promisc mode ;-)

Here is the tested patch.

Thanks,
Fengguang
---
dm9601: tell HW about random generated mac address

Otherwise unicast RX will only work in promisc mode.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/net/usb/dm9601.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

--- linux-2.6.orig/drivers/net/usb/dm9601.c
+++ linux-2.6/drivers/net/usb/dm9601.c
@@ -396,6 +396,11 @@ static void dm9601_set_multicast(struct 
 	dm_write_reg_async(dev, DM_RX_CTRL, rx_ctl);
 }
 
+static void __dm9601_set_mac_address(struct usbnet *dev)
+{
+	dm_write_async(dev, DM_PHY_ADDR, ETH_ALEN, dev->net->dev_addr);
+}
+
 static int dm9601_set_mac_address(struct net_device *net, void *p)
 {
 	struct sockaddr *addr = p;
@@ -405,7 +410,7 @@ static int dm9601_set_mac_address(struct
 		return -EINVAL;
 
 	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
-	dm_write_async(dev, DM_PHY_ADDR, net->addr_len, net->dev_addr);
+	__dm9601_set_mac_address(dev);
 
 	return 0;
 }
@@ -449,6 +454,8 @@ static int dm9601_bind(struct usbnet *de
 	 */
 	if (is_valid_ether_addr(mac))
 		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
+	else
+		__dm9601_set_mac_address(dev);
 
 	/* power up phy */
 	dm_write_reg(dev, DM_GPR_CTRL, 1);
