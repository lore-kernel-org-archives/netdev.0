From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] e1000: Dump the eeprom when a user encounters a bad
 checksum
Date: Fri, 14 Dec 2007 17:08:25 -0800
Message-ID: <20071214170825.91fc4861.randy.dunlap@oracle.com>
References: <20071214233530.27189.89810.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	john.ronciak@intel.com, jesse.brandeburg@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:29313 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502AbXLOBJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 20:09:27 -0500
In-Reply-To: <20071214233530.27189.89810.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2007 15:35:30 -0800 Auke Kok wrote:

> To help supporting users with a bad eeprom checksum, dump the
> eeprom info when such a situation is encountered by a user.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   90 +++++++++++++++++++++++++++++++++++-----
>  1 files changed, 79 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index efd8c2d..2dab1a6 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -817,6 +817,69 @@ e1000_reset(struct e1000_adapter *adapter)
>  }
>  
>  /**
> + *  Dump the eeprom for users having checksum issues
> + **/
> +void e1000_dump_eeprom(struct e1000_adapter *adapter)
> +{
> +	struct net_device *netdev = adapter->netdev;
> +	struct ethtool_eeprom eeprom;
> +	const struct ethtool_ops *ops = netdev->ethtool_ops;
> +	u8 *data;
> +	int i;
> +	u16 csum_old, csum_new = 0;
> +
> +	eeprom.len = ops->get_eeprom_len(netdev);
> +	eeprom.offset = 0;
> +
> +	data = kmalloc(eeprom.len, GFP_KERNEL);
> +	if (!data) {
> +		printk(KERN_ERR "Unable to allocate memory to dump EEPROM"
> +		       " data\n");
> +		return;
> +	}
> +
> +	ops->get_eeprom(netdev, &eeprom, data);
> +
> +	csum_old = (data[EEPROM_CHECKSUM_REG * 2]) +
> +		   (data[EEPROM_CHECKSUM_REG * 2 + 1] << 8);
> +	for (i = 0; i < EEPROM_CHECKSUM_REG * 2; i += 2)
> +		csum_new += data[i] + (data[i + 1] << 8);
> +	csum_new = EEPROM_SUM - csum_new;
> +
> +	printk(KERN_ERR "/*********************/\n");
> +	printk(KERN_ERR "Current EEPROM: 0x%04x\nCalculated    : 0x%04x\n",
> +	       csum_old, csum_new);

add the word "checksum" in that line somewhere?

> +	printk(KERN_ERR "Offset   Values\n");
> +	printk(KERN_ERR "======   ======\n");
> +	for (i = 0; i < eeprom.len; i += 16)
> +		printk(KERN_ERR "0x%04x   "
> +		       "%02x %02x %02x %02x %02x %02x %02x %02x "
> +		       "%02x %02x %02x %02x %02x %02x %02x %02x\n",
> +		       i, data[i], data[i + 1], data[i + 2], data[i + 3],
> +		       data[i + 4], data[i + 5], data[i + 6], data[i + 7],
> +		       data[i + 8], data[i + 9], data[i + 10], data[i + 11],
> +		       data[i + 12], data[i + 13], data[i + 14], data[i + 15]);

how about:

	for (i = 0; i < eeprom.len; i += 16)
		print_hex_dump(KERN_ERR, "data:", DUMP_PREFIX_OFFSET,
			16, 1, data + i, 16, 0);


> +	printk(KERN_ERR "Include this output when contacting your support "
> +	       "provider.\n\nThis is not a software error! Something bad "
> +	       "happened to your hardware or\nEEPROM image. Ignoring this "
> +	       "problem could result in further problems,\npossibly loss "
> +	       "of data, corruption or system hangs!\n\n");
> +	printk(KERN_ERR "The MAC Address will be reset to 00:00:00:00:00:00, "
> +	       "which is invalid\nand requires you to set the proper MAC "
> +	       "address manually before continuing\nto enable this network "
> +	       "device.\n\n");
> +	printk(KERN_ERR "Please inspect the EEPROM dump and report the issue "
> +	       "to your hardware vendor\nor Intel Customer Support: "
> +	       "linux-nics@intel.com\n");
> +
> +	printk(KERN_ERR "/*********************/\n");
> +
> +	kfree(data);
> +}



---
~Randy
