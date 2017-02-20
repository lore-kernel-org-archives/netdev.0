From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v4 03/12] net: ethernet: aquantia: Fixes for
 aq_ndev_change_mtu
Date: Mon, 20 Feb 2017 23:31:57 +0100
Message-ID: <eaa8db7c-6595-3269-23f6-65fb832bd35b@gmx.de>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
 <61981e96fb708b1b1b6c4eb1c5ff529f868d98bb.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:54721 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbdBTWcM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 17:32:12 -0500
In-Reply-To: <61981e96fb708b1b1b6c4eb1c5ff529f868d98bb.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 20.02.2017 20:36, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> 1)Removed unnecessary comparsion "old_mtu == new_mtu".
> This check is not needed. Function aq_ndev_change_mtu wont be called
> if mtu has not changed.
> 
> 2)Removed extra assignment ndev->mtu = new_mtu;
> This assignment already done inside __dev_set_mtu().
> 
> 3)Use core MTU checking for min_mtu.
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_main.c | 12 +-----------
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c  |  1 +
>  2 files changed, 2 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> index c17c70a..45c769e 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> @@ -100,20 +100,10 @@ static int aq_ndev_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
>  {
>  	struct aq_nic_s *aq_nic = netdev_priv(ndev);
> -	int err = 0;
> +	int err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);
>  
> -	if (new_mtu == ndev->mtu) {
> -		err = 0;
> -		goto err_exit;
> -	}
> -	if (new_mtu < 68) {
> -		err = -EINVAL;
> -		goto err_exit;
> -	}
> -	err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);
>  	if (err < 0)
>  		goto err_exit;
> -	ndev->mtu = new_mtu;
>  
>  	if (netif_running(ndev)) {
>  		aq_ndev_close(ndev);
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index a153750..4b8d074 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -214,6 +214,7 @@ struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
>  	SET_NETDEV_DEV(ndev, dev);
>  
>  	ndev->if_port = port;
> +	ndev->min_mtu = ETH_MIN_MTU;

ether_setup() (which is called by alloc_etherdev_mq()) now already sets the network devices min mtu 
to ETH_MIN_MTU. So the instruction above can be omitted.

Regards,
Lino
