From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: Support to take FW dump
Date: Tue, 3 May 2011 17:29:38 -0700
Message-ID: <2941C562-0D47-40DF-B2C0-6292381097AE@qlogic.com>
References: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1304378957-24123-2-git-send-email-anirban.chakraborty@qlogic.com>
 <1304466797.2873.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.185]:15675
	"EHLO CH1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755018Ab1EDAat convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 20:30:49 -0400
In-Reply-To: <1304466797.2873.38.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 3, 2011, at 4:53 PM, Ben Hutchings wrote:

> On Mon, 2011-05-02 at 16:29 -0700, anirban.chakraborty@qlogic.com wrote:
>> From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>> 
>> Added code to take FW dump via ethtool. A pair of set and get functions are
>> added to configure dump level and fetch it from the driver respectively. A
>> third function is added to retrieve the dumped FW data from the driver.
>> 
>> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>> ---
>> include/linux/ethtool.h |   20 ++++++++++++
>> net/core/ethtool.c      |   76 +++++++++++++++++++++++++++++++++++++++++++++++
>> 2 files changed, 96 insertions(+), 0 deletions(-)
>> 
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index 9de3127..3dd91a5 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -595,6 +595,19 @@ struct ethtool_flash {
>> 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
>> };
>> 
>> +/**
>> + * struct ethtool_dump - used for retrieving, setting device dump
>> + * @flag: flag for dump setting
>> + * @len: length of dump data
>> + * @data: data collected for this command
>> + */
>> +struct ethtool_dump {
>> +	__u32	cmd;
>> +	__u32	flag;
>> +	__u32	len;
>> +	u8	data[0];
>> +};
>> +
> 
> What are the legal values of flags?  Are they expected to be entirely
> driver-dependent?
Yes, the flag could be completely driver dependent. For example, in the qlcnic
driver this would indicate the level of the dump that the driver should take. Also,
by specifying a magic key via the flag, the driver could be instructed to take a FW dump
forcibly.

> 
> Shouldn't there be a version field, as for register dumps?
I was thinking that the dump data itself could contain the version field specifying the FW version. However,
we can have an additional field if that turns out to be useful. 

> 
>> /* for returning and changing feature sets */
>> 
>> /**
>> @@ -926,6 +939,10 @@ struct ethtool_ops {
>> 				  const struct ethtool_rxfh_indir *);
>> 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
>> 	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
>> +	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
>> +	int	(*get_dump)(struct net_device *, struct ethtool_dump *);
>> +	int	(*get_dump_data)(struct net_device *,
>> +				struct ethtool_dump *, void *);
> 
> These need to be properly documented in the header comment.
WIll do.

> 
>> };
>> #endif /* __KERNEL__ */
>> @@ -997,6 +1014,9 @@ struct ethtool_ops {
>> #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
>> #define ETHTOOL_GCHANNELS	0x0000003c /* Get no of channels */
>> #define ETHTOOL_SCHANNELS	0x0000003d /* Set no of channels */
>> +#define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
>> +#define ETHTOOL_GET_DUMP	0x0000003f /* Get dump settings */
>> +#define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
>> 
>> /* compatibility with older code */
>> #define SPARC_ETH_GSET		ETHTOOL_GSET
>> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>> index d8b1a8d..dce547c 100644
>> --- a/net/core/ethtool.c
>> +++ b/net/core/ethtool.c
>> @@ -1827,6 +1827,73 @@ static noinline_for_stack int ethtool_flash_device(struct net_device *dev,
>> 	return dev->ethtool_ops->flash_device(dev, &efl);
>> }
>> 
>> +static int ethtool_set_dump(struct net_device *dev,
>> +			void __user *useraddr)
>> +{
>> +	struct ethtool_dump dump;
>> +
>> +	if (!dev->ethtool_ops->set_dump)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (copy_from_user(&dump, useraddr, sizeof(dump)))
>> +		return -EFAULT;
>> +
>> +	return dev->ethtool_ops->set_dump(dev, &dump);
>> +}
>> +
>> +static int ethtool_get_dump(struct net_device *dev,
>> +			void __user *useraddr)
>> +{
>> +	struct ethtool_dump dump;
>> +	const struct ethtool_ops *ops = dev->ethtool_ops;
>> +
>> +	if (!dev->ethtool_ops->get_dump)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (copy_from_user(&dump, useraddr, sizeof(dump)))
>> +		return -EFAULT;
>> +
>> +	if (ops->get_dump(dev, &dump))
>> +		return -EFAULT;
> 
> Why does this change the error code?
It should not. Will fix.

> 
>> +	if (copy_to_user(useraddr, &dump, sizeof(dump)))
>> +		return -EFAULT;
>> +	return 0;
>> +}
>> +
>> +static int ethtool_get_dump_data(struct net_device *dev,
>> +				void __user *useraddr)
>> +{
>> +	int ret;
>> +	void *data;
>> +	struct ethtool_dump dump;
>> +	const struct ethtool_ops *ops = dev->ethtool_ops;
>> +
>> +	if (!dev->ethtool_ops->get_dump_data)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (copy_from_user(&dump, useraddr, sizeof(dump)))
>> +		return -EFAULT;
>> +	data = vzalloc(dump.len);
> 
> I think we ought to query the driver to find out the maximum dump
> length, rather than using the length passed by the user (up to 4GB).  We
> already check that the user has the CAP_NET_ADMIN capability but that
> should not mean the ability to evade memory limits.
That's right. The user makes a call to get_dump (ETHTOOL_GET_DUMP)
first to get the size of the collected dump data for the current
dump level (flag). Then it makes the call to get the dump data (ETHTOOL_GET_DUMP_DATA),
as in above where it specifies the dump size.
The patch ref-ed below demonstrated that.
http://patchwork.ozlabs.org/patch/93729/  

> 
>> +	if (!data)
>> +		return -ENOMEM;
>> +	ret = ops->get_dump_data(dev, &dump, data);
>> +	if (ret) {
>> +		ret = -EFAULT;
> 
> Why does this change the error code?
Will fix it.

> 
>> +		goto out;
>> +	}
>> +	if (copy_to_user(useraddr, &dump, sizeof(dump))) {
>> +		ret = -EFAULT;
>> +		goto out;
>> +	}
>> +	useraddr += offsetof(struct ethtool_dump, data);
>> +	if (copy_to_user(useraddr, data, dump.len))
>> +		ret = -EFAULT;
>> +out:
>> +	vfree(data);
>> +	return ret;
>> +}
>> +
>> /* The main entry point in this file.  Called from net/core/dev.c */
>> 
>> int dev_ethtool(struct net *net, struct ifreq *ifr)
>> @@ -2043,6 +2110,15 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
>> 	case ETHTOOL_SCHANNELS:
>> 		rc = ethtool_set_channels(dev, useraddr);
>> 		break;
>> +	case ETHTOOL_SET_DUMP:
>> +		rc = ethtool_set_dump(dev, useraddr);
>> +		break;
>> +	case ETHTOOL_GET_DUMP:
>> +		rc = ethtool_get_dump(dev, useraddr);
>> +		break;
>> +	case ETHTOOL_GET_DUMP_DATA:
>> +		rc = ethtool_get_dump_data(dev, useraddr);
>> +		break;
>> 	default:
>> 		rc = -EOPNOTSUPP;
>> 	}
> 

Thanks for your feedback. I'll respin the patch incorporating your comments and submit it again.

-Anirban



