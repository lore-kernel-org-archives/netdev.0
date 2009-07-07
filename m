From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] net: fix OF fixed-link property handling on Freescale
	network device drivers
Date: Tue, 7 Jul 2009 18:35:02 +0400
Message-ID: <20090707143231.GA10813@oksana.dev.rtsoft.ru>
References: <20090703221851.23909.923.stgit@localhost.localdomain>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com, afleming@freescale.com,
	davem@davemloft.net, linuxppc-dev@ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20090703221851.23909.923.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 03, 2009 at 04:20:19PM -0600, Grant Likely wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> 
> The MDIO rework patches broke the handling of fixed MII links.
[...]
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
> Anton, can you please review, comment and test?  I've tested it on an
> mpc8349 board, but that is the only hardware that I have.  I've also
> probably made mistakes and it needs to be split up into separate patches,
> but this is probably a sufficient form for first review.  I'll also give
> it another once over tomorrow when after I've had a decent night sleep.

Did some tests for ucc geth...

Will get to fs_enet a bit later.

> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 40c6eba..c216cd5 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -1443,6 +1443,53 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
>  	return 0;
>  }
>  
> +static void ugeth_set_link(struct net_device *dev)
> +{
> +	struct ucc_geth_private *ugeth = netdev_priv(dev);
> +	struct phy_device *phydev = ugeth->phydev;
> +	struct ucc_geth __iomem *ug_regs = ugeth->ug_regs;
> +	struct ucc_fast __iomem *uf_regs = ugeth->uccf->uf_regs;

In fixed-link case you'll call set_link() before ucc_struct_init,
so these *_regs are NULL, following oops pops up:

Unable to handle kernel paging request for data at address 0x00000004
Faulting instruction address: 0xc01d6228
Oops: Kernel access of bad area, sig: 11 [#1]
[...]
NIP [c01d6228] ugeth_set_link+0x20/0x158
LR [c01d723c] init_phy+0xa8/0xdc
Call Trace:          
[cf831e40] [84042028] 0x84042028 (unreliable)
[cf831e60] [c01d723c] init_phy+0xa8/0xdc
[cf831e80] [c01d8fb8] ucc_geth_open+0x2c/0x2b0
[cf831ea0] [c02040a8] dev_open+0xfc/0x134
[cf831ec0] [c0202670] dev_change_flags+0x84/0x1ac
[cf831ee0] [c03b0cfc] ic_open_devs+0x168/0x2cc
[cf831f20] [c03b20f8] ip_auto_config+0x90/0x2a4
[cf831f60] [c0003894] do_one_initcall+0x34/0x1a8
[cf831fd0] [c03922f8] do_initcalls+0x38/0x58
[cf831fe0] [c0392388] kernel_init+0x38/0x98
[cf831ff0] [c0011b78] kernel_thread+0x4c/0x68

> +	u32 tempval = in_be32(&ug_regs->maccfg2);
> +	u32 upsmr = in_be32(&uf_regs->upsmr);
[...]
> +	default:
> +		if (netif_msg_link(ugeth))
> +			ugeth_warn("%s: Ack!  Speed (%d) is not 10/100/1000!",
> +				   dev->name, phydev->speed);

You may dereference NULL here.

> +		break;
> +	}
> +
> +	out_be32(&ug_regs->maccfg2, tempval);

(while you're at it, maybe s/tempval/maccfg2/ ?)

> +	out_be32(&uf_regs->upsmr, upsmr);
> +}
> +

[...]
> @@ -3708,15 +3710,19 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
>  
>  	ug_info->uf_info.regs = res.start;
>  	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
> -	fixed_link = of_get_property(np, "fixed-link", NULL);
> -	if (fixed_link) {
> -		phy = NULL;
> -	} else {
> -		phy = of_parse_phandle(np, "phy-handle", 0);
> -		if (phy == NULL)
> -			return -ENODEV;
> +
> +	/* Setup the initial link state */
> +	prop = of_get_property(np, "fixed-link", &prop_sz);
> +	if (prop && prop_sz >= sizeof(*prop) * 3) {
> +		ugeth->oldlink = 1;

'ugeth' is NULL at this point, causes this:

Unable to handle kernel paging request for data at address 0x000002c4
Faulting instruction address: 0xc01da0d8
Oops: Kernel access of bad area, sig: 11 [#1]
[...]
NIP [c01da0d8] ucc_geth_probe+0x218/0x530
LR [c01da0c0] ucc_geth_probe+0x200/0x530
Call Trace:             
[cf831e00] [c01da0c0] ucc_geth_probe+0x200/0x530 (unreliable)
[cf831e60] [c01eddc4] of_platform_device_probe+0x5c/0x84
[cf831e80] [c019bfd4] really_probe+0x78/0x1a0
[cf831ea0] [c019c1c4] __driver_attach+0xa4/0xa8
[cf831ec0] [c019b3ec] bus_for_each_dev+0x60/0x9c
[cf831ef0] [c019be18] driver_attach+0x24/0x34
[cf831f00] [c019badc] bus_add_driver+0xb4/0x1c4

> +		ugeth->oldduplex = prop[1];
> +		ugeth->oldspeed = prop[2];
>  	}
> -	ug_info->phy_node = phy;
> +
> +	/* Find the phy.  Bail if there is no phy and no initial link speed */
> +	ug_info->phy_node = of_parse_phandle(np, "phy-handle", 0);
> +	if (!ug_info->phy_node && !ugeth->oldlink)
> +		return -ENODEV;
>  
>  	/* Find the TBI PHY node.  If it's not there, we don't support SGMII */
>  	ug_info->tbi_node = of_parse_phandle(np, "tbi-handle", 0);
> @@ -3725,7 +3731,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
>  	prop = of_get_property(np, "phy-connection-type", NULL);
>  	if (!prop) {
>  		/* handle interface property present in old trees */
> -		prop = of_get_property(phy, "interface", NULL);
> +		prop = of_get_property(ug_info->phy_node, "interface", NULL);
>  		if (prop != NULL) {
>  			phy_interface = enet_to_phy_interface[*prop];
>  			max_speed = enet_to_speed[*prop];
> 

There is another oops, if interface is down:

# ethtool -S eth1
Unable to handle kernel paging request for data at address 0x00000180
Faulting instruction address: 0xc01da7f4
Oops: Kernel access of bad area, sig: 11 [#1]
[...]
NIP [c01da7f4] uec_get_ethtool_stats+0x3c/0x14c
LR [c0207484] ethtool_get_stats+0xfc/0x23c
Call Trace:
[cfb2ddf0] [c0207464] ethtool_get_stats+0xdc/0x23c (unreliable)
[cfb2de30] [c0207b24] dev_ethtool+0x324/0x5a8
[cfb2de60] [c0204ad4] dev_ioctl+0x290/0x320
[cfb2deb0] [c01ef9ac] sock_ioctl+0x80/0x2f4
[cfb2ded0] [c0090814] vfs_ioctl+0x34/0x98
[cfb2dee0] [c009103c] do_vfs_ioctl+0x84/0x2cc
[cfb2df10] [c00912c4] sys_ioctl+0x40/0x74
[cfb2df40] [c0011d54] ret_from_syscall+0x0/0x38
--- Exception: c01 at 0xff64820
    LR = 0xffec848
Instruction dump:
80c901b8 70c00001 41820058 8123004c 7cab2b78 39000000 38000000 38e90180
39200012 7d2903a6 5400103a 7c0004ac <7d27002e> 0c090000 4c00012c 7d2a4b78
---[ end trace 7b7ae7cbafe6f2ba ]---
Segmentation fault


Also, now userspace has no chance to know link speed:

# ifconfig eth1 up
# ethtool eth1
Settings for eth1:
Cannot get device settings: No such device
        Current message level: 0x0000003f (63)
        Link detected: yes
# 

(You need to tech *_ethtool.c to report speed/duplex for fixed-link
cases).


Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
