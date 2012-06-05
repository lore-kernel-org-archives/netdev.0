From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next PATCH 1/3] Added kernel support in EEE Ethtool commands
Date: Tue, 05 Jun 2012 10:00:58 +0200
Message-ID: <4FCDBCBA.8040306@st.com>
References: <1338878342-24586-1-git-send-email-yuvalmin@broadcom.com> <1338878342-24586-2-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:58052 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757595Ab2FEIBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 04:01:20 -0400
In-Reply-To: <1338878342-24586-2-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Yuval,

On 6/5/2012 8:39 AM, Yuval Mintz wrote:
> This patch extends the kernel's ethtool interface by adding support
> for 2 new EEE commands - get_eee and set_eee.
> 
> Thanks goes to Giuseppe Cavallaro for his original patch adding this support.

Thank to you for having re-worked/re-stored the code I had proposed and
sorry if I was not able to post my patches in time.
Indeed, I had already done some progresses on EEE so I could re-base it
against your work as soon as reviewed.

For example, I could especially contribute on the eee get/set for the
PHY part. I had already sent the patches for phy_device.c (Ben's already
helped me on these) and I am happy to rework them.

Then I could test and verify all (ethtool + phy + user-space
application) with the stmmac d.d. on my platforms.

[snip]

> +	__u32	tx_lpi_enabled;
> +	__u32	tx_lpi_timer;

Is the tx_lpi_timer field for the MAC driver as we discussed in the
past? If yes, so I can use it for the stmmac too.

Peppe

> +	__u32	reserved[2];
> +};
> +
>  /**
>   * struct ethtool_modinfo - plugin module eeprom information
>   * @cmd: %ETHTOOL_GMODULEINFO
> @@ -945,6 +958,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
>   * @get_module_info: Get the size and type of the eeprom contained within
>   *	a plug-in module.
>   * @get_module_eeprom: Get the eeprom information from the plug-in module
> + * @get_eee: Get Energy-Efficient (EEE) supported and status.
> + * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
>   *
>   * All operations are optional (i.e. the function pointer may be set
>   * to %NULL) and callers must take this into account.  Callers must
> @@ -1011,6 +1026,8 @@ struct ethtool_ops {
>  				   struct ethtool_modinfo *);
>  	int     (*get_module_eeprom)(struct net_device *,
>  				     struct ethtool_eeprom *, u8 *);
> +	int	(*get_eee)(struct net_device *, struct ethtool_eee *);
> +	int	(*set_eee)(struct net_device *, struct ethtool_eee *);
>  
>  
>  };
> @@ -1089,6 +1106,8 @@ struct ethtool_ops {
>  #define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
>  #define ETHTOOL_GMODULEINFO	0x00000042 /* Get plug-in module information */
>  #define ETHTOOL_GMODULEEEPROM	0x00000043 /* Get plug-in module eeprom */
> +#define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
> +#define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
>  
>  /* compatibility with older code */
>  #define SPARC_ETH_GSET		ETHTOOL_GSET
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 9c2afb4..7940bd3 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -729,6 +729,34 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
>  	return dev->ethtool_ops->set_wol(dev, &wol);
>  }
>  
> +static int ethtool_get_eee(struct net_device *dev, char __user *useraddr)
> +{
> +	struct ethtool_eee edata;
> +
> +	if (!dev->ethtool_ops->get_eee)
> +		return -EOPNOTSUPP;
> +
> +	dev->ethtool_ops->get_eee(dev, &edata);
> +
> +	if (copy_to_user(useraddr, &edata, sizeof(edata)))
> +		return -EFAULT;
> +
> +	return 0;
> +}
> +
> +static int ethtool_set_eee(struct net_device *dev, char __user *useraddr)
> +{
> +	struct ethtool_eee edata;
> +
> +	if (!dev->ethtool_ops->get_eee)
> +		return -EOPNOTSUPP;
> +
> +	if (copy_from_user(&edata, useraddr, sizeof(edata)))
> +		return -EFAULT;
> +
> +	return dev->ethtool_ops->set_eee(dev, &edata);
> +}
> +
>  static int ethtool_nway_reset(struct net_device *dev)
>  {
>  	if (!dev->ethtool_ops->nway_reset)
> @@ -1471,6 +1499,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
>  		rc = ethtool_set_value_void(dev, useraddr,
>  				       dev->ethtool_ops->set_msglevel);
>  		break;
> +	case ETHTOOL_GEEE:
> +		rc = ethtool_get_eee(dev, useraddr);
> +		break;
> +	case ETHTOOL_SEEE:
> +		rc = ethtool_set_eee(dev, useraddr);
> +		break;
>  	case ETHTOOL_NWAY_RST:
>  		rc = ethtool_nway_reset(dev);
>  		break;
