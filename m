From: Gertjan van Wingerde <gwingerde@home.nl>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 19:46:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D08769.3070106@home.nl>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com>	 <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jkmaline@cc.hut.fi, jt@hpl.hp.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sfeldma@pobox.com
In-Reply-To: <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Scott,

I'm afraid that this isn't enough. I think we have to split up the various settings over
multiple commands. If we add just two commands (one for GET and one for SET) we have to
change the binary ioctl-interface every time a new setting arrives (e.g. see how new
settings will be added due to WPA support. That solution just isn't future-proof.

Jean, Jouni, Jeff: What are your thoughts about this?

Therefore I suggest we combine some of the basic settings in one command, and try to
keep other settings in separate commands (again logically coherent settings should
be combined in 1 command). I'll work on that, but unfortunately I can't hardly do anything
until the weekend. I agree that we should be able to remove the commit command if we are
able to set multiple settings that belong together at the same time.
BTW I agree with most of the points your making. We just have to make sure that we define
an interface that is sane and is future-proof with respect to future changes.

--- Gertjan.

Scott Feldman wrote:
> On Tue, 2004-06-15 at 09:39, Gertjan van Wingerde wrote:
> 
>>Sounds like a good idea. I'll start refactoring my work towards that approach. Please bear
>>with me for a couple of days and I'll post a draft patch for this.
> 
> 
> Gertjan,
> 
> 24 clock: see how this patch looks.  
> 
> It adds just two more ETHTOOL_[G|S]WSET commands to handle the get/set
> of the wireless settings.  This works just like ETHTOOL_[G|S]SET by
> passing in/out a struct ethtool_wx_cmd that holds all of the wireless
> settings.  The idea is the application would get the settings from the
> driver, let the user change one or more of the settings, and send all of
> the settings back to the driver.  The driver just resets all settings in
> one shot.  
> 
> I tried to use the correct type for the various settings based on what
> the drivers did (unwinding the iw_param and iw_point members).  I
> probably missed some details; please help.
> 
> Some observations/opens:
> 
> 1) This is not compatible with the current wireless extensions ioctl, so
> iwconfig must be re-written to use ethtool -w. :(
> 2) Note that wireless stats can just be moved into ETHTOOL_GSTATS.
> 3) iw_range needs another ETHTOOL_GWRANGE, but it looks like there is
> some duplication with ETHTOOL_GWSET, so I'm not sure what's left - would
> you look into this?
> 4) nick is cosmetic, so it's not included here.
> 5) Individual events are not generated for things like setting ESSID and
> NWID.  Since all of these settings are now set in batch, there really is
> just one event: wireless settings changed.  Event needs to come from the
> ethtool_ops->get_wx_settings() so it's generated regardless of UI.  On
> the other hand, is there any practical use for the event in the first
> place?  We don't have events for LAN drivers when speed/duplex change,
> for example, do we?
> 6) The whole commit strategy is useless to us now because settings are
> always set in batch with ETHTOOL_GWSET.  The driver does an implicit
> commit after applying settings.
> 7) We need a driver to prototype this against - I'm using ipw2100, but
> it would be better to use something that's already in the kernel.
> 8) We need ethtool app updates to add a -w option to set wireless
> settings.  
> 9) ethtool DEVNAME would use either get_settings or get_wx_settings,
> depending on which one was implemented in the driver.
> 10) Not sure what to do with get/set scan.
> 
> See if you can make some progress on these open issues.
> 
> -scott
> 
> ----------------
> 
> diff -Naurp linux-2.6.7-rc3-bk1/include/linux/ethtool.h linux-2.6.7-rc3-bk1-ethtool/include/linux/ethtool.h
> --- linux-2.6.7-rc3-bk1/include/linux/ethtool.h	2004-05-09 19:32:26.000000000 -0700
> +++ linux-2.6.7-rc3-bk1-ethtool/include/linux/ethtool.h	2004-06-16 01:09:44.018094360 -0700
> @@ -250,6 +250,49 @@ struct ethtool_stats {
>  	u64	data[0];
>  };
>  
> +enum ethtool_wx_mode {
> +	ETH_WX_MODE_AUTO		= 0,
> +	ETH_WX_MODE_ADHOC,
> +	ETH_WX_MODE_INFRA,
> +	ETH_WX_MODE_MASTER,
> +	ETH_WX_MODE_REPEATER,
> +	ETH_WX_MODE_SECOND,
> +	ETH_WX_MODE_MONITOR,
> +};
> +
> +enum ethtool_wx_sec_mode {
> +	ETH_WX_SEC_MODE_OPEN		= 0,
> +	ETH_WX_SEC_MODE_RESTRICTED,
> +};
> +
> +/* for getting/setting wireless settings */
> +struct ethtool_wx_cmd {
> +	u32	cmd;
> +	u16	nwid;		/* Wireless network ID; 0 = disabled */
> +	struct {
> +		u32	mantissa;
> +		u16	exponent;
> +	} freq;			/* Operating frequency */
> +	u32	mode;		/* Operating mode (ETH_WX_MODE_xxx) */
> +	u16	sens;		/* Sensitivity threshold (-dBm) */
> +	struct sockaddr wap;	/* Register with access point */
> +				/*   auto = 00:00:00:00:00:00 */
> +	char	essid[32];	/* ESSID; any = NULL string */
> +	u32	rate;		/* Bit rate b/s; 0 = auto */
> +	u16	rts;		/* Smallest packet size for which */
> +				/* the node sends RTS; 0 = off */
> +	u16	frag;		/* Maximum fragment size; 0 = no frag */
> +	u16	tx_power;	/* Transmit power in dBm */
> +	struct { /* TODO: thit needs work */
> +		u16	limit;
> +		u32	lifetime;	/* usec */
> +	} retry;		/* MAC retransmission */
> +	u32	sec_mode;	/* Security mode (ETH_WX_SEC_MODE_xxx) */
> +	char	sec_key[32];	/* Security mode encryption key */
> +	/* TODO: add struct power */
> +	u32	reserved[16];
> +};
> +
>  struct net_device;
>  
>  /* Some generic methods drivers may use in their ethtool_ops */
> @@ -293,6 +336,8 @@ int ethtool_op_set_tso(struct net_device
>   * get_strings: Return a set of strings that describe the requested objects 
>   * phys_id: Identify the device
>   * get_stats: Return statistics about the device
> + * get_wx_settings: Get device-specific wireless settings
> + * set_wx_settings: Set device-specific wireless settings
>   *
>   * Description:
>   *
> @@ -351,6 +396,8 @@ struct ethtool_ops {
>  	int	(*phys_id)(struct net_device *, u32);
>  	int	(*get_stats_count)(struct net_device *);
>  	void	(*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
> +	int	(*get_wx_settings)(struct net_device *, struct ethtool_wx_cmd *);
> +	int	(*set_wx_settings)(struct net_device *, struct ethtool_wx_cmd *);
>  };
>  
>  /* CMDs currently supported */
> @@ -386,6 +433,8 @@ struct ethtool_ops {
>  #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
>  #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
>  #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
> +#define ETHTOOL_GWSET		0x00000020 /* Get wireless settings. */
> +#define ETHTOOL_SWSET		0x00000021 /* Set wireless settings. */
>  
>  /* compatibility with older code */
>  #define SPARC_ETH_GSET		ETHTOOL_GSET
> diff -Naurp linux-2.6.7-rc3-bk1/net/core/ethtool.c linux-2.6.7-rc3-bk1-ethtool/net/core/ethtool.c
> --- linux-2.6.7-rc3-bk1/net/core/ethtool.c	2004-06-08 11:13:53.000000000 -0700
> +++ linux-2.6.7-rc3-bk1-ethtool/net/core/ethtool.c	2004-06-16 01:13:52.615301840 -0700
> @@ -645,6 +645,36 @@ static int ethtool_get_stats(struct net_
>  	return ret;
>  }
>  
> +static int ethtool_get_wx_settings(struct net_device *dev, void __user *useraddr)
> +{
> +	struct ethtool_wx_cmd cmd = { ETHTOOL_GWSET };
> +	int err;
> +
> +	if (!dev->ethtool_ops->get_wx_settings)
> +		return -EOPNOTSUPP;
> +
> +	err = dev->ethtool_ops->get_wx_settings(dev, &cmd);
> +	if (err < 0)
> +		return err;
> +
> +	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
> +		return -EFAULT;
> +	return 0;
> +}
> +
> +static int ethtool_set_wx_settings(struct net_device *dev, void __user *useraddr)
> +{
> +	struct ethtool_wx_cmd cmd;
> +
> +	if (!dev->ethtool_ops->set_wx_settings)
> +		return -EOPNOTSUPP;
> +
> +	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
> +		return -EFAULT;
> +
> +	return dev->ethtool_ops->set_wx_settings(dev, &cmd);
> +}
> +
>  /* The main entry point in this file.  Called from net/core/dev.c */
>  
>  int dev_ethtool(struct ifreq *ifr)
> @@ -730,6 +760,10 @@ int dev_ethtool(struct ifreq *ifr)
>  		return ethtool_phys_id(dev, useraddr);
>  	case ETHTOOL_GSTATS:
>  		return ethtool_get_stats(dev, useraddr);
> +	case ETHTOOL_GWSET:
> +		return ethtool_get_wx_settings(dev, useraddr);
> +	case ETHTOOL_SWSET:
> +		return ethtool_set_wx_settings(dev, useraddr);
>  	default:
>  		return -EOPNOTSUPP;
>  	}
> 
> 
> 
