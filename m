From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: warn on invalid mac address
Date: Tue, 06 Jan 2009 10:18:17 +0100
Message-ID: <87zli4u71i.fsf@macbook.be.48ers.dk>
References: <20090106091050.GA19316@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wu Fengguang <wfg@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:63902 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbZAFJSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 04:18:22 -0500
Received: by ewy10 with SMTP id 10so8329702ewy.13
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2009 01:18:20 -0800 (PST)
In-Reply-To: <20090106091050.GA19316@localhost> (Wu Fengguang's message of "Tue\, 6 Jan 2009 17\:10\:50 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:

Hi,

 Wu> Add warnings on invalid mac address to help disclose/debug problems.
 Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
 Wu> ---
 Wu>  drivers/net/usb/dm9601.c |   12 +++++++++++-
 Wu>  1 file changed, 11 insertions(+), 1 deletion(-)

 Wu> --- linux-2.6.orig/drivers/net/usb/dm9601.c
 Wu> +++ linux-2.6/drivers/net/usb/dm9601.c
 Wu> @@ -401,8 +401,12 @@ static int dm9601_set_mac_address(struct
 Wu>  	struct sockaddr *addr = p;
 Wu>  	struct usbnet *dev = netdev_priv(net);
 
 Wu> -	if (!is_valid_ether_addr(addr->sa_data))
 Wu> +	if (!is_valid_ether_addr(addr->sa_data)) {
 Wu> +		DECLARE_MAC_BUF(mac_buf);
 Wu> +		print_mac(mac_buf, addr->sa_data);
 Wu> +		dev_warn(&net->dev, "not setting invalid mac address %s\n", mac_buf);

This should be an error and not a warning.
Notice that print_mac returns the string, so you can do:

dev_err(&net->dev, "... %s", print_mac(mac_buf, addr->sa_data));
 
 Wu>  	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
 Wu>  	dm_write_async(dev, DM_PHY_ADDR, net->addr_len, net->dev_addr);
 Wu> @@ -449,6 +453,12 @@ static int dm9601_bind(struct usbnet *de
 Wu>  	 */
 Wu>  	if (is_valid_ether_addr(mac))
 Wu>  		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
 Wu> +	else {
 Wu> +		DECLARE_MAC_BUF(mac_buf);
 Wu> +		print_mac(mac_buf, mac);
 Wu> +		devdbg(dev, "EEPROM reported mac address %s is invalid,"
 Wu> +				" use the randomly generated one.", mac_buf);

And this should be a warning.

-- 
Bye, Peter Korsgaard
