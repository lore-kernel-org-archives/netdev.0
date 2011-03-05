From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 5/8] bonding: get rid of IFF_SLAVE_INACTIVE
 netdev->priv_flag
Date: Sat, 05 Mar 2011 15:18:11 +0100
Message-ID: <4D724623.5040500@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-6-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57033 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab1CEOSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 09:18:15 -0500
Received: by wwb22 with SMTP id 22so3636316wwb.1
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 06:18:14 -0800 (PST)
In-Reply-To: <1299320969-7951-6-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 11:29, Jiri Pirko a =E9crit :
> Since bond-related code was moved from net/core/dev.c into bonding,
> IFF_SLAVE_INACTIVE is no longer needed. Replace is with flag "inactiv=
e"
> stored in slave structure
>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

> ---
>   drivers/net/bonding/bond_main.c  |    6 ++----
>   drivers/net/bonding/bond_sysfs.c |    4 ++--
>   drivers/net/bonding/bonding.h    |   14 ++++++++++----
>   include/linux/if.h               |   19 +++++++++----------
>   4 files changed, 23 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 62020a7..dbe182c 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1474,7 +1474,7 @@ static bool bond_should_deliver_exact_match(str=
uct sk_buff *skb,
>   					    struct slave *slave,
>   					    struct bonding *bond)
>   {
> -	if (slave->dev->priv_flags&  IFF_SLAVE_INACTIVE) {
> +	if (bond_is_slave_inactive(slave)) {
>   		if (slave_do_arp_validate(bond, slave)&&
>   		skb->protocol =3D=3D __cpu_to_be16(ETH_P_ARP))
>   			return false;
> @@ -2131,7 +2131,7 @@ int bond_release(struct net_device *bond_dev, s=
truct net_device *slave_dev)
>
>   	dev_set_mtu(slave_dev, slave->original_mtu);
>
> -	slave_dev->priv_flags&=3D ~(IFF_SLAVE_INACTIVE | IFF_BONDING);
> +	slave_dev->priv_flags&=3D ~IFF_BONDING;
>
>   	kfree(slave);
>
> @@ -2242,8 +2242,6 @@ static int bond_release_all(struct net_device *=
bond_dev)
>   			dev_set_mac_address(slave_dev,&addr);
>   		}
>
> -		slave_dev->priv_flags&=3D ~IFF_SLAVE_INACTIVE;
> -
>   		kfree(slave);
>
>   		/* re-acquire the lock before getting the next slave */
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/b=
ond_sysfs.c
> index 344d23f..5161183 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -1581,9 +1581,9 @@ static ssize_t bonding_store_slaves_active(stru=
ct device *d,
>   	bond_for_each_slave(bond, slave, i) {
>   		if (!bond_is_active_slave(slave)) {
>   			if (new_value)
> -				slave->dev->priv_flags&=3D ~IFF_SLAVE_INACTIVE;
> +				slave->inactive =3D 0;
>   			else
> -				slave->dev->priv_flags |=3D IFF_SLAVE_INACTIVE;
> +				slave->inactive =3D 1;
>   		}
>   	}
>   out:
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bond=
ing.h
> index 8a3718b..8f78166 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -190,8 +190,9 @@ struct slave {
>   	unsigned long last_arp_rx;
>   	s8     link;    /* one of BOND_LINK_XXXX */
>   	s8     new_link;
> -	u8     backup;	/* indicates backup slave. Value corresponds with
> -			   BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
> +	u8     backup:1,   /* indicates backup slave. Value corresponds wit=
h
> +			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
> +	       inactive:1; /* indicates inactive slave */
>   	u32    original_mtu;
>   	u32    link_failure_count;
>   	u8     perm_hwaddr[ETH_ALEN];
> @@ -374,13 +375,18 @@ static inline void bond_set_slave_inactive_flag=
s(struct slave *slave)
>   	if (!bond_is_lb(bond))
>   		bond_set_backup_slave(slave);
>   	if (!bond->params.all_slaves_active)
> -		slave->dev->priv_flags |=3D IFF_SLAVE_INACTIVE;
> +		slave->inactive =3D 1;
>   }
>
>   static inline void bond_set_slave_active_flags(struct slave *slave)
>   {
>   	bond_set_active_slave(slave);
> -	slave->dev->priv_flags&=3D ~IFF_SLAVE_INACTIVE;
> +	slave->inactive =3D 0;
> +}
> +
> +static inline bool bond_is_slave_inactive(struct slave *slave)
> +{
> +	return slave->inactive;
>   }
>
>   struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan=
_entry *curr);
> diff --git a/include/linux/if.h b/include/linux/if.h
> index 2fdd47a..0da7991 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -59,18 +59,17 @@
>   /* Private (from user) interface flags (netdevice->priv_flags). */
>   #define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.     =
     */
>   #define IFF_EBRIDGE	0x2		/* Ethernet bridging device.	*/
> -#define IFF_SLAVE_INACTIVE	0x4	/* bonding slave not the curr. active=
 */
> -#define IFF_BONDING	0x8		/* bonding master or slave	*/
> -#define IFF_ISATAP	0x10		/* ISATAP interface (RFC4214)	*/
> -#define IFF_WAN_HDLC	0x20		/* WAN HDLC device		*/
> -#define IFF_XMIT_DST_RELEASE 0x40	/* dev_hard_start_xmit() is allowe=
d to
> +#define IFF_BONDING	0x4		/* bonding master or slave	*/
> +#define IFF_ISATAP	0x8		/* ISATAP interface (RFC4214)	*/
> +#define IFF_WAN_HDLC	0x10		/* WAN HDLC device		*/
> +#define IFF_XMIT_DST_RELEASE 0x20	/* dev_hard_start_xmit() is allowe=
d to
>   					 * release skb->dst
>   					 */
> -#define IFF_DONT_BRIDGE 0x80		/* disallow bridging this ether dev */
> -#define IFF_DISABLE_NETPOLL	0x100	/* disable netpoll at run-time */
> -#define IFF_MACVLAN_PORT	0x200	/* device used as macvlan port */
> -#define IFF_BRIDGE_PORT	0x400		/* device used as bridge port */
> -#define IFF_OVS_DATAPATH	0x800	/* device used as Open vSwitch
> +#define IFF_DONT_BRIDGE 0x40		/* disallow bridging this ether dev */
> +#define IFF_DISABLE_NETPOLL	0x80	/* disable netpoll at run-time */
> +#define IFF_MACVLAN_PORT	0x100	/* device used as macvlan port */
> +#define IFF_BRIDGE_PORT	0x200		/* device used as bridge port */
> +#define IFF_OVS_DATAPATH	0x400	/* device used as Open vSwitch
>   					 * datapath port */
>
>   #define IF_GET_IFACE	0x0001		/* for querying only */

