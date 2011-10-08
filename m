From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH V2 1/2] net/core/ethtool: New Commands to Configure
 IOV features
Date: Sat, 08 Oct 2011 01:37:30 +0100
Message-ID: <1318034250.2771.158.camel@bwh-desktop>
References: <20110922213522.26654.59301.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20435 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab1JHAhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 20:37:33 -0400
In-Reply-To: <20110922213522.26654.59301.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-22 at 14:35 -0700, Greg Rose wrote:
> The only currently supported method of configuring the number of VFs
> is through the max_vfs module parameter.  This method is inadequate to
> support scenarios in which the user might wish to have varying numbers
> of VFs per PF.  There is additional support for drivers that want to
> partition some driver resources to additional net devices and for
> configuring the number of Tx/Rx queue pairs per VF.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> ---
> 
>  include/linux/ethtool.h |   30 +++++++++++++++++++++++++++++-
>  net/core/ethtool.c      |   38 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 67 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 45f00b6..448730f 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -720,6 +720,27 @@ enum ethtool_sfeatures_retval_bits {
>  #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
>  #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
>  
> +enum ethtool_iov_modes {
> +	ETHTOOL_IOV_MODE_NONE,
> +	ETHTOOL_IOV_MODE_SRIOV,
> +	ETHTOOL_IOV_MODE_NETDEVS,
> +};
> +
> +#define	ETHTOOL_IOV_CMD_CONFIGURE_SRIOV		1
> +#define	ETHTOOL_IOV_CMD_CONFIGURE_NETDEVS	2
> +#define	ETHTOOL_IOV_CMD_CONFIGURE_VF_QUEUES	3
> +
> +struct ethtool_iov_set_cmd {
> +	__u32 cmd;
> +	__u32 set_cmd;
> +	__u32 cmd_param;
> +};

Why introduce sub-commands?

> +struct ethtool_iov_get_cmd {
> +	__u32 cmd;
> +	__u32 mode;
> +};

Why is it only possible to get the mode?

It really seems to make more sense to group these three parameters
together and get/set them all at once.  But if you can justify making
them separate then struct ethtool_value is the type to use.

In any case, any new types or macros need comments.

[...]
> +static int ethtool_iov_get_command(struct net_device *dev,
> +				  void __user *useraddr)
> +{
> +	int ret;
> +	struct ethtool_iov_get_cmd iov_cmd;
> +
> +	if (!dev->ethtool_ops->iov_get_cmd)
> +		return -EOPNOTSUPP;
> +	if (copy_from_user(&iov_cmd, useraddr, sizeof(iov_cmd)))
> +		return -EFAULT;
> +
> +	ret = dev->ethtool_ops->iov_get_cmd(dev, &iov_cmd);
> +	if (!ret)
> +		ret = copy_to_user(useraddr, &iov_cmd, sizeof(iov_cmd));

	if (!ret && copy_to_user(...))
		ret = -EFAULT;

> +	return ret;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
