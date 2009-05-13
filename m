From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next] net: remove needless (now buggy) & from	dev->dev_addr
Date: Wed, 13 May 2009 09:20:25 +0800
Message-ID: <4A0A2059.8040607@cn.fujitsu.com>
References: <20090512093714.GD3399@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfr@canb.auug.org.au,
	sachinp@in.ibm.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64493 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752053AbZEMBXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2009 21:23:51 -0400
In-Reply-To: <20090512093714.GD3399@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Patch fixes issues with dev->dev_addr changing from array to pointer.
> Hopefully there are no others.
>
> Compile tested only.
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 8c2e5ab..06009dc 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -1845,9 +1845,10 @@ static u16 aggregator_identifier;
>   * Can be called only after the mac address of the bond is set.
>   */
>  void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast)
> -{                         
> +{
>  	// check that the bond is not initialized yet
> -	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr), &(bond->dev->dev_addr))) {
> +	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr),
> +				bond->dev->dev_addr)) {
>  
>  		aggregator_identifier = 0;
>  
> diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
> index 7902e5e..53af71a 100644
> --- a/drivers/net/ibmveth.c
> +++ b/drivers/net/ibmveth.c
> @@ -1374,8 +1374,8 @@ static void ibmveth_proc_unregister_driver(void)
>  static int ibmveth_show(struct seq_file *seq, void *v)
>  {
>  	struct ibmveth_adapter *adapter = seq->private;
> -	char *current_mac = ((char*) &adapter->netdev->dev_addr);
> -	char *firmware_mac = ((char*) &adapter->mac_addr) ;
> +	char *current_mac = (char *) adapter->netdev->dev_addr;
> +	char *firmware_mac = (char *) &adapter->mac_addr;
>  
>  	seq_printf(seq, "%s %s\n\n", ibmveth_driver_string, ibmveth_driver_version);
>  
> diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
> index 3dad1cf..ff9b5c8 100644
> --- a/drivers/net/wireless/hostap/hostap_hw.c
> +++ b/drivers/net/wireless/hostap/hostap_hw.c
> @@ -1423,7 +1423,7 @@ static int prism2_hw_init2(struct net_device *dev, int initial)
>  		prism2_check_sta_fw_version(local);
>  
>  		if (hfa384x_get_rid(dev, HFA384X_RID_CNFOWNMACADDR,
> -				    &dev->dev_addr, 6, 1) < 0) {
> +				    dev->dev_addr, 6, 1) < 0) {
>  			printk("%s: could not get own MAC address\n",
>  			       dev->name);
>  		}
> diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
> index fa90d1d..22e7185 100644
> --- a/drivers/net/wireless/ray_cs.c
> +++ b/drivers/net/wireless/ray_cs.c
> @@ -892,7 +892,7 @@ static int ray_dev_init(struct net_device *dev)
>  #endif /* RAY_IMMEDIATE_INIT */
>  
>  	/* copy mac and broadcast addresses to linux device */
> -	memcpy(&dev->dev_addr, &local->sparm.b4.a_mac_addr, ADDRLEN);
> +	memcpy(dev->dev_addr, &local->sparm.b4.a_mac_addr, ADDRLEN);
>  	memset(dev->broadcast, 0xff, ETH_ALEN);
>  
>  	DEBUG(2, "ray_dev_init ending\n");
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index d994c55..af256d4 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1100,8 +1100,8 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
>  	struct ip6_tnl_parm *p = &t->parms;
>  	struct flowi *fl = &t->fl;
>  
> -	memcpy(&dev->dev_addr, &p->laddr, sizeof(struct in6_addr));
> -	memcpy(&dev->broadcast, &p->raddr, sizeof(struct in6_addr));
> +	memcpy(dev->dev_addr, &p->laddr, sizeof(struct in6_addr));
> +	memcpy(dev->broadcast, &p->raddr, sizeof(struct in6_addr));
>  
>  	/* Set up flowi template */
>  	ipv6_addr_copy(&fl->fl6_src, &p->laddr);
> diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
> index f72ba77..524ba56 100644
> --- a/net/tipc/eth_media.c
> +++ b/net/tipc/eth_media.c
> @@ -167,7 +167,7 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
>  	tb_ptr->mtu = dev->mtu;
>  	tb_ptr->blocked = 0;
>  	tb_ptr->addr.type = htonl(TIPC_MEDIA_TYPE_ETH);
> -	memcpy(&tb_ptr->addr.dev_addr, &dev->dev_addr, ETH_ALEN);
> +	memcpy(&tb_ptr->addr.dev_addr, dev->dev_addr, ETH_ALEN);
>  	return 0;
>  }
>   
missing this one:

diff -u -p a/llc/af_llc.c b/llc/af_llc.c
--- a/llc/af_llc.c 2009-03-28 04:06:16.000000000 +0800
+++ b/llc/af_llc.c 2009-05-12 16:36:26.000000000 +0800
@@ -935,7 +935,7 @@ static int llc_ui_getname(struct socket 
 
 		if (llc->dev) {
 			sllc.sllc_arphrd = llc->dev->type;
-			memcpy(&sllc.sllc_mac, &llc->dev->dev_addr,
+			memcpy(&sllc.sllc_mac, llc->dev->dev_addr,
 			       IFHWADDRLEN);
 		}
 	}


