From: Gal Pressman <galp@mellanox.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Sun, 25 Jun 2017 16:38:44 +0300
Message-ID: <11d024ad-6e09-e475-a448-e79b6eef5654@mellanox.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
 <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vidya.chowdary@gmail.com,
        dustin@cumulusnetworks.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        jeffrey.t.kirsher@intel.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net,
        linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20079.outbound.protection.outlook.com ([40.107.2.79]:46592
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750854AbdFYNiz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Jun 2017 09:38:55 -0400
In-Reply-To: <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> ...
>
> SHOW FEC option:
> root@tor: ethtool --show-fec  swp1
> FEC parameters for swp1:
> Active FEC encodings: RS
> Configured FEC encodings:  RS | BaseR
>
> ETHTOOL DEVNAME output modification:
>
> ethtool devname output:
> root@tor:~# ethtool swp1
> Settings for swp1:
> root@hpe-7712-03:~# ethtool swp18
> Settings for swp18:
>     Supported ports: [ FIBRE ]
>     Supported link modes:   40000baseCR4/Full
>                             40000baseSR4/Full
>                             40000baseLR4/Full
>                             100000baseSR4/Full
>                             100000baseCR4/Full
>                             100000baseLR4_ER4/Full
>     Supported pause frame use: No
>     Supports auto-negotiation: Yes
>     Supported FEC modes: [RS | BaseR | None | Not reported]
>     Advertised link modes:  Not reported
>     Advertised pause frame use: No
>     Advertised auto-negotiation: No
>     Advertised FEC modes: [RS | BaseR | None | Not reported]
> <<<< One or more FEC modes
>     Speed: 100000Mb/s
>     Duplex: Full
>     Port: FIBRE
>     PHYAD: 106
>     Transceiver: internal
>     Auto-negotiation: off
>     Link detected: yes
What is the difference between the information in ethtool DEVNAME and ethtool --show-fec DEVNAME?
I can't find a usage of LINK_MODE_FEC_* bits in downstream patches.

>
> This patch includes following changes
> a) New ETHTOOL_SFECPARAM/SFECPARAM API, handled by
>   the new get_fecparam/set_fecparam callbacks, provides support
>   for configuration of forward error correction modes.
> b) Link mode bits for FEC modes i.e. None (No FEC mode), RS, BaseR/FC
>   are defined so that users can configure these fec modes for supported
>   and advertising fields as part of link autonegotiation.
>
> Signed-off-by: Vidya Sagar Ravipati <vidya.chowdary@gmail.com>
> ---
>  include/linux/ethtool.h      |  4 ++++
>  include/uapi/linux/ethtool.h | 48 +++++++++++++++++++++++++++++++++++++++++++-
>  net/core/ethtool.c           | 34 +++++++++++++++++++++++++++++++
>  3 files changed, 85 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 83cc986..afdbb70 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -374,5 +374,9 @@ struct ethtool_ops {
>  				      struct ethtool_link_ksettings *);
>  	int	(*set_link_ksettings)(struct net_device *,
>  				      const struct ethtool_link_ksettings *);
> +	int	(*get_fecparam)(struct net_device *,
> +				      struct ethtool_fecparam *);
> +	int	(*set_fecparam)(struct net_device *,
> +				      struct ethtool_fecparam *);
>  };
>  #endif /* _LINUX_ETHTOOL_H */
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 7d4a594..9c041da 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1238,6 +1238,47 @@ struct ethtool_per_queue_op {
>  	char	data[];
>  };
>  
> +/**
> + * struct ethtool_fecparam - Ethernet forward error correction(fec) parameters
> + * @cmd: Command number = %ETHTOOL_GFECPARAM or %ETHTOOL_SFECPARAM
> + * @active_fec: FEC mode which is active on porte
port.

> + * @fec: Bitmask of supported/configured FEC modes
> + * @rsvd: Reserved for future extensions. i.e FEC bypass feature.
> + *
> + * Drivers should reject a non-zero setting of @autoneg when
> + * autoneogotiation is disabled (or not supported) for the link.
Which @autoneg?

> + *
> + */
> +struct ethtool_fecparam {
> +	__u32   cmd;
> +	/* bitmask of FEC modes */
> +	__u32   active_fec;
> +	__u32   fec;
> +	__u32   reserved;
> +};
> +
> +/**
> + * enum ethtool_fec_config_bits - flags definition of ethtool_fec_configuration
> + * @ETHTOOL_FEC_NONE: FEC mode configuration is not supported
> + * @ETHTOOL_FEC_AUTO: Default/Best FEC mode provided by driver
> + * @ETHTOOL_FEC_OFF: No FEC Mode
> + * @ETHTOOL_FEC_RS: Reed-Solomon Forward Error Detection mode
> + * @ETHTOOL_FEC_BASER: Base-R/Reed-Solomon Forward Error Detection mode
> + */
> +enum ethtool_fec_config_bits {
> +	ETHTOOL_FEC_NONE_BIT,
> +	ETHTOOL_FEC_AUTO_BIT,
> +	ETHTOOL_FEC_OFF_BIT,
> +	ETHTOOL_FEC_RS_BIT,
> +	ETHTOOL_FEC_BASER_BIT,
> +};
> +
> +#define ETHTOOL_FEC_NONE		(1 << ETHTOOL_FEC_NONE_BIT)
> +#define ETHTOOL_FEC_AUTO		(1 << ETHTOOL_FEC_AUTO_BIT)
> +#define ETHTOOL_FEC_OFF			(1 << ETHTOOL_FEC_OFF_BIT)
> +#define ETHTOOL_FEC_RS			(1 << ETHTOOL_FEC_RS_BIT)
> +#define ETHTOOL_FEC_BASER		(1 << ETHTOOL_FEC_BASER_BIT)
> +
>  /* CMDs currently supported */
>  #define ETHTOOL_GSET		0x00000001 /* DEPRECATED, Get settings.
>  					    * Please use ETHTOOL_GLINKSETTINGS
> @@ -1330,6 +1371,8 @@ struct ethtool_per_queue_op {
>  #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
>  #define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
>  #define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
> +#define ETHTOOL_GFECPARAM	0x00000050 /* Get FEC settings */
> +#define ETHTOOL_SFECPARAM	0x00000051 /* Set FEC settings */
>  
>  /* compatibility with older code */
>  #define SPARC_ETH_GSET		ETHTOOL_GSET
> @@ -1387,6 +1430,9 @@ enum ethtool_link_mode_bit_indices {
>  	ETHTOOL_LINK_MODE_2500baseT_Full_BIT	= 47,
>  	ETHTOOL_LINK_MODE_5000baseT_Full_BIT	= 48,
>  
> +	ETHTOOL_LINK_MODE_FEC_NONE_BIT	= 49,
> +	ETHTOOL_LINK_MODE_FEC_RS_BIT	= 50,
> +	ETHTOOL_LINK_MODE_FEC_BASER_BIT	= 51,
>  
>  	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
>  	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
> @@ -1395,7 +1441,7 @@ enum ethtool_link_mode_bit_indices {
>  	 */
>  
>  	__ETHTOOL_LINK_MODE_LAST
> -	  = ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
> +	  = ETHTOOL_LINK_MODE_FEC_BASER_BIT,
>  };
>  
> ...
