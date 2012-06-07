From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [v4 net-next PATCH 1/3] Added kernel support in EEE Ethtool
 commands
Date: Thu, 7 Jun 2012 17:28:03 +0100
Message-ID: <1339086483.2770.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339038788-3447-1-git-send-email-yuvalmin@broadcom.com>
	 <1339038788-3447-2-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eilong@broadcom.com>, <peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44551 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751617Ab2FGQ2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 12:28:10 -0400
In-Reply-To: <1339038788-3447-2-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-07 at 06:13 +0300, Yuval Mintz wrote:
> This patch extends the kernel's ethtool interface by adding support
> for 2 new EEE commands - get_eee and set_eee.
> 
> Thanks goes to Giuseppe Cavallaro for his original patch adding this support.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  include/linux/ethtool.h |   35 +++++++++++++++++++++++++++++++++++
>  net/core/ethtool.c      |   40 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 75 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index e17fa71..a518361 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -137,6 +137,35 @@ struct ethtool_eeprom {
>  };
>  
>  /**
> + * struct ethtool_eee - Energy Efficient Ethernet information
> + * @cmd: ETHTOOL_{G,S}EEE
> + * @supported: Mask of %SUPPORTED_* flags for the speed/duplex combinations
> + *	for which there is EEE support.
> + * @advertised: Mask of %ADVERTISED_* flags for the speed/duplex combinations
> + *	advertised as eee capable.
> + * @lp_advertised: Mask of %ADVERTISED_* flags for the speed/duplex
> + *	combinations advertised by the link partner as eee capable.
> + * @eee_active: Result of the eee auto negotiation.
> + * @eee_enabled: EEE configured mode (enabled/disabled).
> + * @tx_lpi_enabled: Whether the interface should assert its tx lpi, given
> + *	that eee was negotiated.
> + * @tx_lpi_timer: Time in microseconds the interface delays prior to asserting
> + *	its tx lpi (after reaching 'idle' state). Effective only when eee
> + *	was negotiated and tx_lpi_enabled was set.
> + */
> +struct ethtool_eee {
> +	__u32	cmd;
> +	__u32	supported;
> +	__u32	advertised;
> +	__u32	lp_advertised;
> +	__u32	eee_active;
> +	__u32	eee_enabled;
> +	__u32	tx_lpi_enabled;
> +	__u32	tx_lpi_timer;
> +	__u32	reserved[2];
> +};
> +
> +/**
>   * struct ethtool_modinfo - plugin module eeprom information
>   * @cmd: %ETHTOOL_GMODULEINFO
>   * @type: Standard the module information conforms to %ETH_MODULE_SFF_xxxx
> @@ -945,6 +974,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
>   * @get_module_info: Get the size and type of the eeprom contained within
>   *	a plug-in module.
>   * @get_module_eeprom: Get the eeprom information from the plug-in module
> + * @get_eee: Get Energy-Efficient (EEE) supported and status.
> + * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
>   *
>   * All operations are optional (i.e. the function pointer may be set
>   * to %NULL) and callers must take this into account.  Callers must
> @@ -1011,6 +1042,8 @@ struct ethtool_ops {
>  				   struct ethtool_modinfo *);
>  	int     (*get_module_eeprom)(struct net_device *,
>  				     struct ethtool_eeprom *, u8 *);
> +	int	(*get_eee)(struct net_device *, struct ethtool_eee *);
> +	int	(*set_eee)(struct net_device *, struct ethtool_eee *);
>  
> 
>  };
> @@ -1089,6 +1122,8 @@ struct ethtool_ops {
>  #define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
>  #define ETHTOOL_GMODULEINFO	0x00000042 /* Get plug-in module information */
>  #define ETHTOOL_GMODULEEEPROM	0x00000043 /* Get plug-in module eeprom */
> +#define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
> +#define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
>  
>  /* compatibility with older code */
>  #define SPARC_ETH_GSET		ETHTOOL_GSET
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 9c2afb4..5a582da 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -729,6 +729,40 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
>  	return dev->ethtool_ops->set_wol(dev, &wol);
>  }
>  
> +static int ethtool_get_eee(struct net_device *dev, char __user *useraddr)
> +{
> +	struct ethtool_eee edata;
> +	int rc;
> +
> +	if (!dev->ethtool_ops->get_eee)
> +		return -EOPNOTSUPP;
> +
> +	memset(&edata, 0, sizeof(struct ethtool_eee));
> +	edata.cmd = ETHTOOL_GEEE;
> +	rc = dev->ethtool_ops->get_eee(dev, &edata);
> +
> +	if (rc)
> +		return rc;
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
> +	if (!dev->ethtool_ops->set_eee)
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
> @@ -1471,6 +1505,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
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

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
