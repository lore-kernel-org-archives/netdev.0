From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 net-next-2.6] ethtool: Added support for FW dump
Date: Thu, 12 May 2011 18:04:59 +0100
Message-ID: <1305219899.5214.26.camel@bwh-desktop>
References: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1305154448-9687-2-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20148 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757988Ab1ELRFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 13:05:02 -0400
In-Reply-To: <1305154448-9687-2-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-11 at 15:54 -0700, Anirban Chakraborty wrote:
> Added code to take FW dump via ethtool. Dump level can be controlled via setting the
> dump flag. A get function is provided to query the current setting of the dump flag.
> Dump data is obtained from the driver via a separate get function.
> 
> Changes from v2:
> Provided separate commands for get flag and data.
> Check for minimum of the two buffer length obtained via ethtool and driver and
> use that for dump buffer
> Pass up the driver return error codes up to the caller.
> Added kernel doc comments.
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> ---
>  include/linux/ethtool.h |   28 +++++++++++++++
>  net/core/ethtool.c      |   88 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 116 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index bd0b50b..5ac7e18 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -601,6 +601,24 @@ struct ethtool_flash {
>  	char	data[ETHTOOL_FLASH_MAX_FILENAME];
>  };
>  
> +/**
> + * struct ethtool_dump - used for retrieving, setting device dump
> + * @cmd: Command number - %ETHTOOL_GET_DUMP_FLAG, %ETHTOOL_GET_DUMP_DATA, or
> + * 	%ETHTOOL_SET_DUMP
> + * @version: FW version of the dump, filled in by driver
> + * @flag: driver dependent flag for dump setting, filled in by driver during
> + * 	  get and filled in by ethtool for set operation
> + * @len: length of dump data, returned by driver for get operation

This is also used as the length of the user buffer on entry to
ETHTOOL_GET_DUMP_DATA.

> + * @data: data collected for get dump data operation
> + */
> +struct ethtool_dump {
> +	__u32	cmd;
> +	__u32	version;
> +	__u32	flag;
> +	__u32	len;
> +	u8	data[0];
> +};
> +
>  /* for returning and changing feature sets */
>  
>  /**
> @@ -853,6 +871,9 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
>   * @get_channels: Get number of channels.
>   * @set_channels: Set number of channels.  Returns a negative error code or
>   *	zero.
> + * @get_dump_flag: Get dump flag indicating current dump settings of the device.

This operation must also provide the dump length.

> + * @get_dump_data: Get dump data.
> + * @set_dump: Set dump specific flags to the device.
>   *
>   * All operations are optional (i.e. the function pointer may be set
>   * to %NULL) and callers must take this into account.  Callers must
> @@ -927,6 +948,10 @@ struct ethtool_ops {
>  				  const struct ethtool_rxfh_indir *);
>  	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
>  	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
> +	int	(*get_dump_flag)(struct net_device *, struct ethtool_dump *);
> +	int	(*get_dump_data)(struct net_device *,
> +				 struct ethtool_dump *, void *);
> +	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
>  
>  };
>  #endif /* __KERNEL__ */
[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
[...]
> +static int ethtool_get_dump_data(struct net_device *dev,
> +				void __user *useraddr)
> +{
> +	int ret;
> +	__u32 len;
> +	struct ethtool_dump dump, tmp;
> +	const struct ethtool_ops *ops = dev->ethtool_ops;
> +	void *data = NULL;
> +
> +	if (!dev->ethtool_ops->get_dump_data ||
> +		!dev->ethtool_ops->get_dump_flag)
> +		return -EOPNOTSUPP;
> +
> +	if (copy_from_user(&dump, useraddr, sizeof(dump)))
> +		return -EFAULT;
> +
> +	memset(&tmp, 0, sizeof(tmp));
> +	tmp.cmd = dump.cmd;

tmp.cmd should be ETHTOOL_GET_DUMP_FLAG.

> +	ret = ops->get_dump_flag(dev, &tmp);
> +	if (ret)
> +		return ret;
> +
> +	len = (tmp.len > dump.len) ? dump.len : tmp.len;
> +
> +	data = vzalloc(len);
> +	if (!data)
> +		return -ENOMEM;
[...]

The kernel buffer size must be tmp.len, otherwise the driver may overrun
the buffer.

'len' is the minimum of the two buffer sizes and should only be used as
the size copied to user space (which you have done).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

