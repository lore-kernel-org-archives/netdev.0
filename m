From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: [patch net-2.6] bonding: fix rx_handler locking
Date: Wed, 23 Mar 2011 10:07:10 +0800
Message-ID: <4D8955CE.7040808@gmail.com>
References: <1300797492-16128-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, fubar@us.ibm.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:50791 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755575Ab1CWCMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 22:12:31 -0400
Received: by iwn34 with SMTP id 34so8085463iwn.19
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 19:12:30 -0700 (PDT)
In-Reply-To: <1300797492-16128-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/2011 08:38 PM, Jiri Pirko wrote:
> This prevents possible race between bond_enslave and bond_handle_fram=
e
> as reported by Nicolas by moving rx_handler register/unregister.
> slave->bond is added to hold pointer to master bonding sructure. That
> way dev->master is no longer used in bond_handler_frame.
> Also, this removes "BUG: scheduling while atomic" message
>
> Reported-by: Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
> ---
>   drivers/net/bonding/bond_main.c |   56 +++++++++++++++++++++-------=
----------
>   drivers/net/bonding/bonding.h   |    1 +
>   2 files changed, 32 insertions(+), 25 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 338bea1..16d6fe9 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1482,21 +1482,16 @@ static rx_handler_result_t bond_handle_frame(=
struct sk_buff **pskb)
>   {
>   	struct sk_buff *skb =3D *pskb;
>   	struct slave *slave;
> -	struct net_device *bond_dev;
>   	struct bonding *bond;
>
> -	slave =3D bond_slave_get_rcu(skb->dev);
> -	bond_dev =3D ACCESS_ONCE(slave->dev->master);
> -	if (unlikely(!bond_dev))
> -		return RX_HANDLER_PASS;
> -
>   	skb =3D skb_share_check(skb, GFP_ATOMIC);
>   	if (unlikely(!skb))
>   		return RX_HANDLER_CONSUMED;
>
>   	*pskb =3D skb;
>
> -	bond =3D netdev_priv(bond_dev);
> +	slave =3D bond_slave_get_rcu(skb->dev);
> +	bond =3D slave->bond;
>
>   	if (bond->params.arp_interval)
>   		slave->dev->last_rx =3D jiffies;
> @@ -1505,10 +1500,10 @@ static rx_handler_result_t bond_handle_frame(=
struct sk_buff **pskb)
>   		return RX_HANDLER_EXACT;
>   	}
>
> -	skb->dev =3D bond_dev;
> +	skb->dev =3D bond->dev;
>
>   	if (bond->params.mode =3D=3D BOND_MODE_ALB&&
> -	    bond_dev->priv_flags&  IFF_BRIDGE_PORT&&
> +	    bond->dev->priv_flags&  IFF_BRIDGE_PORT&&
>   	skb->pkt_type =3D=3D PACKET_HOST) {
>
>   		if (unlikely(skb_cow_head(skb,
> @@ -1516,7 +1511,7 @@ static rx_handler_result_t bond_handle_frame(st=
ruct sk_buff **pskb)
>   			kfree_skb(skb);
>   			return RX_HANDLER_CONSUMED;
>   		}
> -		memcpy(eth_hdr(skb)->h_dest, bond_dev->dev_addr, ETH_ALEN);
> +		memcpy(eth_hdr(skb)->h_dest, bond->dev->dev_addr, ETH_ALEN);
>   	}
>
>   	return RX_HANDLER_ANOTHER;
> @@ -1698,20 +1693,15 @@ int bond_enslave(struct net_device *bond_dev,=
 struct net_device *slave_dev)
>   		pr_debug("Error %d calling netdev_set_bond_master\n", res);
>   		goto err_restore_mac;
>   	}
> -	res =3D netdev_rx_handler_register(slave_dev, bond_handle_frame,
> -					 new_slave);
> -	if (res) {
> -		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
> -		goto err_unset_master;
> -	}
>
>   	/* open the slave since the application closed it */
>   	res =3D dev_open(slave_dev);
>   	if (res) {
>   		pr_debug("Opening slave %s failed\n", slave_dev->name);
> -		goto err_unreg_rxhandler;
> +		goto err_unset_master;
>   	}
>
> +	new_slave->bond =3D bond;
>   	new_slave->dev =3D slave_dev;
>   	slave_dev->priv_flags |=3D IFF_BONDING;
>
> @@ -1907,6 +1897,13 @@ int bond_enslave(struct net_device *bond_dev, =
struct net_device *slave_dev)
>   	if (res)
>   		goto err_close;
>
> +	res =3D netdev_rx_handler_register(slave_dev, bond_handle_frame,
> +					 new_slave);
> +	if (res) {
> +		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
> +		goto err_dest_symlinks;
> +	}
> +
>   	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
>   		bond_dev->name, slave_dev->name,
>   		bond_is_active_slave(new_slave) ? "n active" : " backup",
> @@ -1916,13 +1913,12 @@ int bond_enslave(struct net_device *bond_dev,=
 struct net_device *slave_dev)
>   	return 0;
>
>   /* Undo stages on error */
> +err_dest_symlinks:
> +	bond_destroy_slave_symlinks(bond_dev, slave_dev);
> +
>   err_close:
>   	dev_close(slave_dev);
>
> -err_unreg_rxhandler:
> -	netdev_rx_handler_unregister(slave_dev);
> -	synchronize_net();
> -
>   err_unset_master:
>   	netdev_set_bond_master(slave_dev, NULL);
>
> @@ -1988,6 +1984,14 @@ int bond_release(struct net_device *bond_dev, =
struct net_device *slave_dev)
>   		return -EINVAL;
>   	}
>
> +	/* unregister rx_handler early so bond_handle_frame wouldn't be cal=
led
> +	 * for this slave anymore.
> +	 */
> +	netdev_rx_handler_unregister(slave_dev);
> +	write_unlock_bh(&bond->lock);
> +	synchronize_net();
> +	write_lock_bh(&bond->lock);
> +
>   	if (!bond->params.fail_over_mac) {
>   		if (!compare_ether_addr(bond_dev->dev_addr, slave->perm_hwaddr)&&
>   		bond->slave_cnt>  1)
> @@ -2104,8 +2108,6 @@ int bond_release(struct net_device *bond_dev, s=
truct net_device *slave_dev)
>   		netif_addr_unlock_bh(bond_dev);
>   	}
>
> -	netdev_rx_handler_unregister(slave_dev);
> -	synchronize_net();
>   	netdev_set_bond_master(slave_dev, NULL);
>
>   	slave_disable_netpoll(slave);
> @@ -2186,6 +2188,12 @@ static int bond_release_all(struct net_device =
*bond_dev)
>   		 */
>   		write_unlock_bh(&bond->lock);
>
> +		/* unregister rx_handler early so bond_handle_frame wouldn't
> +		 * be called for this slave anymore.
> +		 */
> +		netdev_rx_handler_unregister(slave_dev);
> +		synchronize_net();
> +
>   		if (bond_is_lb(bond)) {
>   			/* must be called only after the slave
>   			 * has been detached from the list
> @@ -2217,8 +2225,6 @@ static int bond_release_all(struct net_device *=
bond_dev)
>   			netif_addr_unlock_bh(bond_dev);
>   		}
>
> -		netdev_rx_handler_unregister(slave_dev);
> -		synchronize_net();
>   		netdev_set_bond_master(slave_dev, NULL);
>
>   		slave_disable_netpoll(slave);
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bond=
ing.h
> index 6b26962..90736cb 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -187,6 +187,7 @@ struct slave {
>   	struct net_device *dev; /* first - useful for panic debug */
>   	struct slave *next;
>   	struct slave *prev;
> +	struct bonding *bond; /* our master */
>   	int    delay;
>   	unsigned long jiffies;
>   	unsigned long last_arp_rx;
Hi,
I test this patch with VirtualBox, no kernel panic occurs.
git log 08351fc6a75731226e1112fc7254542bd3a2912e

[root@localhost ~]# vboxmanage showvminfo server |grep ^NIC
NIC 1:           MAC: 0800273A4DBD, Attachment: Bridged Interface=20
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 2:           MAC: 080027B5FCD1, Attachment: Bridged Interface=20
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 3:           MAC: 080027C77BFC, Attachment: Bridged Interface=20
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 4:           MAC: 080027261BDB, Attachment: Bridged Interface=20
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 5:           disabled
NIC 6:           disabled
NIC 7:           disabled
NIC 8:           disabled


Here is my test case.

#! /bin/sh
ifconfig eth9 down
NUM=3D0
for i in {1..100}
do
     modprobe -r bonding
     modprobe bonding max_bonds=3D0
     echo +bond0 > /sys/class/net/bonding_masters
     echo +bond1 > /sys/class/net/bonding_masters
     echo +eth9 > /sys/class/net/bond1/bonding/slaves
     echo $i " PASS"
     (( NUM +=3D 1))
done

echo $NUM " PASS"

Hope it will be useful for you.
thanks
Weiping Pan


