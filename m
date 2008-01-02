From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 2.6.23.12] net/bonding: option to specify initial bond
 interface number
Date: Wed, 2 Jan 2008 13:55:54 -0800
Message-ID: <20080102135554.65f86364.randy.dunlap@oracle.com>
References: <413FEEF1743111439393FB76D0221E4809790942@leopard.zoo.q9networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Jari Takkala" <Jari.Takkala@Q9.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62339 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbYABV4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 16:56:06 -0500
In-Reply-To: <413FEEF1743111439393FB76D0221E4809790942@leopard.zoo.q9networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jan 2008 16:20:48 -0500 Jari Takkala wrote:

> Allow the user to specify an initial interface number when loading the bonding driver. This is useful when loading multiple instances of the bonding driver and you want to control the interface number assignment. For example, if the user wishes to create a bond5 interface they can type 'modprobe -o bond5 bonding ifnum=5'. It also works with the max_bonds option.
> 
> Signed-off-by: Jari Takkala <jari.takkala@q9.com>
> ---
> diff -ruN linux-2.6.23.12.orig/drivers/net/bonding/bond_main.c linux-2.6.23.12/drivers/net/bonding/bond_main.c
> --- linux-2.6.23.12.orig/drivers/net/bonding/bond_main.c	2007-12-18 16:55:57.000000000 -0500
> +++ linux-2.6.23.12/drivers/net/bonding/bond_main.c	2008-01-02 14:49:37.000000000 -0500
> @@ -85,6 +85,7 @@
>  #define BOND_LINK_MON_INTERV	0
>  #define BOND_LINK_ARP_INTERV	0
>  
> +static int ifnum	= BOND_DEFAULT_IFNUM;
>  static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
>  static int miimon	= BOND_LINK_MON_INTERV;
>  static int updelay	= 0;
> @@ -99,6 +100,8 @@
>  static char *arp_validate = NULL;
>  struct bond_params bonding_defaults;
>  
> +module_param(ifnum, int, 0);

You could (should) make <ifnum> be unsigned int and then use
module_param(ifnum, uint, 0);
and then ...

> +MODULE_PARM_DESC(ifnum, "Initial interface number to assign");
>  module_param(max_bonds, int, 0);
>  MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
>  module_param(miimon, int, 0);
> @@ -4388,6 +4391,14 @@
>  		}
>  	}

then this block is mostly useless since ifnum cannot be < 0.
And how could it ever be > INT_MAX (when ifnum was an int)?

If <ifnum> is unsigned int but you want to limit it to INT_MAX,
then half of this if-test would be OK.

> +	if (ifnum < 0 || ifnum > INT_MAX) {
> +		printk(KERN_WARNING DRV_NAME
> +		       ": Warning: ifnum (%d) not in range %d-%d, so it "
> +		       "was reset to BOND_DEFAULT_IFNUM (%d)\n",
> +		       ifnum, 0, INT_MAX, BOND_DEFAULT_IFNUM);
> +		ifnum = BOND_DEFAULT_IFNUM;
> +	}
> +
>  	if (max_bonds < 1 || max_bonds > INT_MAX) {
>  		printk(KERN_WARNING DRV_NAME
>  		       ": Warning: max_bonds (%d) not in range %d-%d, so it "


---
~Randy
desserts:  http://www.xenotime.net/linux/recipes/
