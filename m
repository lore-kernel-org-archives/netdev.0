From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] bonding: set device in RLB ARP packet
	handler
Date: Fri, 23 Jul 2010 16:26:48 -0400
Message-ID: <20100723202648.GU7497@gospo.rdu.redhat.com>
References: <20100722195240.GA25359@w-gedwards.lhn.com> <28252.1279915324@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Edwards <greg.edwards@hp.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <28252.1279915324@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 01:02:04PM -0700, Jay Vosburgh wrote:
> 
> From: Greg Edwards <greg.edwards@hp.com>
> 
> After:
> 
> commit 6146b1a4da98377e4abddc91ba5856bef8f23f1e
> Author: Jay Vosburgh <fubar@us.ibm.com>
> Date:   Tue Nov 4 17:51:15 2008 -0800
> 
>     bonding: Fix ALB mode to balance traffic on VLANs
> 
> the dev field in the RLB ARP packet handler was set to NULL to wildcard
> and accommodate balancing VLANs on top of bonds.
> 
> This has the side-effect of the packet handler being called against
> other, non RLB-enabled bonds, and a kernel oops results when it tries to
> dereference rx_hashtbl in rlb_update_entry_from_arp(), which won't be
> set for those bonds, e.g. active-backup.
> 
> With the __netif_receive_skb() changes from:
> 
> commit 1f3c8804acba841b5573b953f5560d2683d2db0d
> Author: Andy Gospodarek <andy@greyhouse.net>
> Date:   Mon Dec 14 10:48:58 2009 +0000
> 
>     bonding: allow arp_ip_targets on separate vlans to use arp validation
> 
> frames received on VLANs correctly make their way to the bond's handler,
> so we no longer need to wildcard the device.
> 
> The oops can be reproduced by:
> 
> modprobe bonding
> 
> echo active-backup > /sys/class/net/bond0/bonding/mode
> echo 100 > /sys/class/net/bond0/bonding/miimon
> ifconfig bond0 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
> echo +eth0 > /sys/class/net/bond0/bonding/slaves
> echo +eth1 > /sys/class/net/bond0/bonding/slaves
> 
> echo +bond1 > /sys/class/net/bonding_masters
> echo balance-alb > /sys/class/net/bond1/bonding/mode
> echo 100 > /sys/class/net/bond1/bonding/miimon
> ifconfig bond1 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
> echo +eth2 > /sys/class/net/bond1/bonding/slaves
> echo +eth3 > /sys/class/net/bond1/bonding/slaves
> 
> Pass some traffic on bond0.  Boom.
> 
> [ Tested, behaves as advertised.  I do not believe a test of the bonding
> mode is necessary, as there is no race between the packet handler and
> the bonding mode changing (the mode can only change when the device is
> closed).  Also updated the log message to include the reproduction and
> full commit ids.  -J ]
> 	
> Signed-off-by: Greg Edwards <greg.edwards@hp.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Acked-by: Andy Gospodarek <andy@greyhouse.net>

> 
> ---
> 
>  drivers/net/bonding/bond_alb.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index df48307..8d7dfd2 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -822,7 +822,7 @@ static int rlb_initialize(struct bonding *bond)
> 
>  	/*initialize packet type*/
>  	pk_type->type = cpu_to_be16(ETH_P_ARP);
> -	pk_type->dev = NULL;
> +	pk_type->dev = bond->dev;
>  	pk_type->func = rlb_arp_recv;
> 
>  	/* register to receive ARPs */
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
