From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] net: make ->ndo_get_phys_port_name accept 32-bit len
Date: Sun, 8 Oct 2017 18:25:45 -0700
Message-ID: <20171008182545.171498a2@cakuba.netronome.com>
References: <20171007221917.GA2467@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        michael.chan@broadcom.com, saeedm@mellanox.com,
        simon.horman@netronome.com, jiri@mellanox.com,
        ecree@solarflare.com, vivien.didelot@savoirfairelinux.com
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:56098 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752185AbdJIBZu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 21:25:50 -0400
Received: by mail-qt0-f174.google.com with SMTP id x54so40444744qth.12
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 18:25:49 -0700 (PDT)
In-Reply-To: <20171007221917.GA2467@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 8 Oct 2017 01:19:17 +0300, Alexey Dobriyan wrote:
> Buffer length passed into this hook is always IFNAMSIZ which is 16.
> 
> Code savings on x86_64:
> 
> 	add/remove: 0/0 grow/shrink: 1/9 up/down: 2/-45 (-43)
> 	function                                     old     new   delta
> 	rocker_cmd_get_port_settings_phys_name_proc     179     181      +2
> 	rocker_port_get_phys_port_name                62      61      -1
> 	mlxsw_sx_port_get_phys_port_name              54      50      -4
> 	mlx5e_rep_get_phys_port_name                  61      57      -4
> 	efx_get_phys_port_name                        50      46      -4
> 	dsa_slave_get_phys_port_name                  54      50      -4
> 	bnxt_vf_rep_get_phys_port_name                69      65      -4
> 	bnxt_get_phys_port_name                       70      65      -5
> 	mlxsw_sp_port_get_phys_port_name             116     107      -9
> 	nfp_port_get_phys_port_name                  180     170     -10
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I don't think the gains justify the additional burden on backports.

> --- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
> @@ -139,8 +139,8 @@ struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port)
>  	return __nfp_port_get_eth_port(port);
>  }
>  
> -int
> -nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
> +int nfp_port_get_phys_port_name(struct net_device *netdev,
> +				char *name, unsigned int len)

Line break between name and len, please.

>  {
>  	struct nfp_eth_table_port *eth_port;
>  	struct nfp_port *port;
> --- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
> @@ -127,8 +127,7 @@ nfp_port_from_id(struct nfp_pf *pf, enum nfp_port_type type, unsigned int id);
>  struct nfp_eth_table_port *__nfp_port_get_eth_port(struct nfp_port *port);
>  struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port);
>  
> -int
> -nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len);
> +int nfp_port_get_phys_port_name(struct net_device *netdev, char *name, unsigned int len);

This line is now longer than 80 characters.

>  int nfp_port_configure(struct net_device *netdev, bool configed);
>  
>  struct nfp_port *

> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1292,7 +1292,7 @@ struct net_device_ops {
>  	int			(*ndo_get_phys_port_id)(struct net_device *dev,
>  							struct netdev_phys_item_id *ppid);
>  	int			(*ndo_get_phys_port_name)(struct net_device *dev,
> -							  char *name, size_t len);
> +							  char *name, unsigned int len);

And so is this one.

>  	void			(*ndo_udp_tunnel_add)(struct net_device *dev,
>  						      struct udp_tunnel_info *ti);
>  	void			(*ndo_udp_tunnel_del)(struct net_device *dev,
