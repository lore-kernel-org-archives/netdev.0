From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 net-next-2.6] ethtool: Added support for FW dump
Date: Tue, 10 May 2011 19:29:46 +0100
Message-ID: <1305052186.2859.47.camel@bwh-desktop>
References: <1304989352-24810-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1304989352-24810-2-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28124 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab1EJS3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 14:29:49 -0400
In-Reply-To: <1304989352-24810-2-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-09 at 18:02 -0700, Anirban Chakraborty wrote:
> Added code to take FW dump via ethtool. A pair of set and get functions are
> added to configure dump level and fetch dump data from the driver respectively.

I don't understand why you are combining get-flags and get-data in the
driver interface.  I suggested that you could use a single option for
these in the ethtool *utility*, but combining them in the driver
interface just seems to complicate the implementation of the ethtool
core code and the driver.

> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> ---
>  include/linux/ethtool.h |   31 +++++++++++++++++++++++
>  net/core/ethtool.c      |   62 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 93 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index bd0b50b..f2cd7e1 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -601,6 +601,31 @@ struct ethtool_flash {
>  	char	data[ETHTOOL_FLASH_MAX_FILENAME];
>  };
>  
> +/**
> + * struct ethtool_dump - used for retrieving, setting device dump

Missing description of @cmd.

> + * @type: type of operation, get dump settings or data
> + * @version: FW version of the dump
> + * @flag: flag for dump setting
> + * @len: length of dump data
> + * @data: data collected for this command

The kernel-doc needs to describe when the fields are valid - i.e. which
commands use them as input and/or output.

> + */
> +struct ethtool_dump {
> +	__u32	cmd;
> +	__u32	type;
> +	__u32	version;
> +	__u32	flag;
> +	__u32	len;
> +	u8	data[0];
> +};
> +
> +/*
> + * ethtool_dump_op_type - used to determine type of fetch, flag or data
> + */
> +enum ethtool_dump_op_type {
> +	ETHTOOL_DUMP_FLAG	= 0,
> +	ETHTOOL_DUMP_DATA,
> +};
> +
>  /* for returning and changing feature sets */
>  
>  /**
> @@ -853,6 +878,8 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
>   * @get_channels: Get number of channels.
>   * @set_channels: Set number of channels.  Returns a negative error code or
>   *	zero.
> + * @get_dump: Get dump flag indicating current dump settings of the device
> + * @set_dump: Set dump specific flags to the device
>   *
>   * All operations are optional (i.e. the function pointer may be set
>   * to %NULL) and callers must take this into account.  Callers must
> @@ -927,6 +954,8 @@ struct ethtool_ops {
>  				  const struct ethtool_rxfh_indir *);
>  	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
>  	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
> +	int	(*get_dump)(struct net_device *, struct ethtool_dump *, void *);
> +	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
>  
>  };
>  #endif /* __KERNEL__ */
> @@ -998,6 +1027,8 @@ struct ethtool_ops {
>  #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
>  #define ETHTOOL_GCHANNELS	0x0000003c /* Get no of channels */
>  #define ETHTOOL_SCHANNELS	0x0000003d /* Set no of channels */
> +#define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
> +#define ETHTOOL_GET_DUMP	0x0000003f /* Get dump settings */
>  
>  /* compatibility with older code */
>  #define SPARC_ETH_GSET		ETHTOOL_GSET
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index b6f4058..3c3af8b 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1823,6 +1823,62 @@ static noinline_for_stack int ethtool_flash_device(struct net_device *dev,
>  	return dev->ethtool_ops->flash_device(dev, &efl);
>  }
>  
> +static int ethtool_set_dump(struct net_device *dev,
> +			void __user *useraddr)
> +{
> +	struct ethtool_dump dump;
> +
> +	if (!dev->ethtool_ops->set_dump)
> +		return -EOPNOTSUPP;
> +
> +	if (copy_from_user(&dump, useraddr, sizeof(dump)))
> +		return -EFAULT;
> +
> +	return dev->ethtool_ops->set_dump(dev, &dump);
> +}
> +
> +static int ethtool_get_dump(struct net_device *dev,
> +				void __user *useraddr)
> +{
> +	int ret;
> +	void *data = NULL;
> +	struct ethtool_dump dump;
> +	const struct ethtool_ops *ops = dev->ethtool_ops;
> +	enum ethtool_dump_op_type type;
> +
> +	if (!dev->ethtool_ops->get_dump)
> +		return -EOPNOTSUPP;
> +
> +	if (copy_from_user(&dump, useraddr, sizeof(dump)))
> +		return -EFAULT;
> +
> +	type = dump.type;
> +	dump.type = ETHTOOL_DUMP_FLAG;
> +	ret = ops->get_dump(dev, &dump, data);
> +	if (ret)
> +		return ret;
> +	dump.type = type;
> +	if (copy_to_user(useraddr, &dump, sizeof(dump)))
> +		return -EFAULT;
> +	if (type != ETHTOOL_DUMP_DATA)
> +		return 0;
> +
> +	data = vzalloc(dump.len);
> +	if (!data)
> +		return -ENOMEM;
> +	ret = ops->get_dump(dev, &dump, data);
> +	if (ret) {
> +		ret = -EFAULT;

There is no reason to change ret here.  Didn't I already raise this in
version 1?

> +		goto out;
> +	}
> +	useraddr += offsetof(struct ethtool_dump, data);
> +	if (copy_to_user(useraddr, data, dump.len))

The copied length should be the *minimum* of the user's buffer length
and the actual dump length.

Ben.

> +		ret = -EFAULT;
> +out:
> +	vfree(data);
> +	return ret;
> +}
> +
>  /* The main entry point in this file.  Called from net/core/dev.c */
>  
>  int dev_ethtool(struct net *net, struct ifreq *ifr)
> @@ -2039,6 +2095,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
>  	case ETHTOOL_SCHANNELS:
>  		rc = ethtool_set_channels(dev, useraddr);
>  		break;
> +	case ETHTOOL_SET_DUMP:
> +		rc = ethtool_set_dump(dev, useraddr);
> +		break;
> +	case ETHTOOL_GET_DUMP:
> +		rc = ethtool_get_dump(dev, useraddr);
> +		break;
>  	default:
>  		rc = -EOPNOTSUPP;
>  	}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

