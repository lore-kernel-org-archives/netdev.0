From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] net: fix OF fixed-link property handling on Freescale
 network device drivers
Date: Tue, 7 Jul 2009 19:12:41 +0400
Message-ID: <20090707151241.GA26831@oksana.dev.rtsoft.ru>
References: <20090703221851.23909.923.stgit@localhost.localdomain>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, leoli@freescale.com, afleming@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:43579 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751356AbZGGPMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 11:12:42 -0400
Content-Disposition: inline
In-Reply-To: <20090703221851.23909.923.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

fs_enet this time...

[..]
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
> index b892c3a..39244b2 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -722,8 +722,6 @@ static void generic_adjust_link(struct  net_device *dev)
>  	} else if (fep->oldlink) {
>  		new_state = 1;
>  		fep->oldlink = 0;
> -		fep->oldspeed = 0;
> -		fep->oldduplex = -1;
>  	}
>  
>  	if (new_state && netif_msg_link(fep))
> @@ -749,25 +747,21 @@ static void fs_adjust_link(struct net_device *dev)
>  static int fs_init_phy(struct net_device *dev)
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
> -	struct phy_device *phydev;
>  
> -	fep->oldlink = 0;
> -	fep->oldspeed = 0;
> -	fep->oldduplex = -1;
> +	/* If a link is already flagged, then set up initial state */
> +	if (fep->oldlink) {
> +		netif_carrier_on(dev);
> +		fep->ops->restart(dev);

->restart() will dereference phydev, which is NULL.

grep for 'phydev' in fs_enet/mac-*.c.

Unable to handle kernel paging request for data at address 0x000000d0
Faulting instruction address: 0xc01842cc
Oops: Kernel access of bad area, sig: 11 [#1]
[...]
NIP [c01842cc] restart+0x3ac/0x434
LR [c0184260] restart+0x340/0x434
Call Trace:               
[c3825e60] [c0184260] restart+0x340/0x434 (unreliable)
[c3825e80] [c018231c] fs_init_phy+0x3c/0xbc
[c3825e90] [c01838a4] fs_enet_open+0x110/0x1cc
[c3825eb0] [c01b19b0] dev_open+0xcc/0x130
[c3825ed0] [c01b0100] dev_change_flags+0xb8/0x18c
[c3825ef0] [c030c4e4] ic_open_devs+0x188/0x284
[c3825f30] [c030d770] ip_auto_config+0x7c/0x278
[c3825f60] [c000393c] do_one_initcall+0x58/0x19c
[c3825fd0] [c02f62e4] do_initcalls+0x30/0x50
[c3825fe0] [c02f6374] kernel_init+0x38/0x94
[c3825ff0] [c0010824] kernel_thread+0x4c/0x68
Instruction dump:         
901e0004 801c0060 2f800000 419e0020 7c0004ac 801e0004 0c000000 4c00012c
64000002 7c0004ac 901e0004 813d0110 <800900d0> 2f800000 419e0024 7c0004ac
---[ end trace 1ae193a95823d5e4 ]---


And the same comment regarding link speed/duplex reporting for
userspace:

# ethtool eth1
Settings for eth1:
Cannot get device settings: No such device
        Current message level: 0x00000000 (0)
        Link detected: yes


Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
