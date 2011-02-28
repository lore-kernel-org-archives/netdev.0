From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 net-next-2.6] ethtool: Compat handling for struct
 ethtool_rxnfc
Date: Mon, 28 Feb 2011 22:04:25 +0000
Message-ID: <1298930665.2569.26.camel@bwh-desktop>
References: <1298930141.2569.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Kees Cook <kees.cook@canonical.com>
To: Santwona Behera <santwona.behera@sun.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54388 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190Ab1B1WE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 17:04:29 -0500
In-Reply-To: <1298930141.2569.22.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 21:55 +0000, Ben Hutchings wrote:
[...]
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -2588,23 +2588,110 @@ static int dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
>  
>  static int ethtool_ioctl(struct net *net, struct compat_ifreq __user *ifr32)
>  {
> +	struct compat_ethtool_rxnfc __user *compat_rxnfc;
> +	bool convert_in = false, convert_out = false;
> +	size_t buf_size = ALIGN(sizeof(struct ifreq), 8);
> +	struct ethtool_rxnfc __user *rxnfc;
>  	struct ifreq __user *ifr;
> +	u32 rule_cnt = 0;
> +	u32 ethcmd;
>  	u32 data;
> -	void __user *datap;
> +	int ret;
> +
> +	if (get_user(data, &ifr32->ifr_ifru.ifru_data))
> +		return -EFAULT;
>  
> -	ifr = compat_alloc_user_space(sizeof(*ifr));
> +	compat_rxnfc = compat_ptr(data);
>  
> -	if (copy_in_user(&ifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
> +	if (get_user(ethcmd, &compat_rxnfc->cmd))
>  		return -EFAULT;
>  
> -	if (get_user(data, &ifr32->ifr_ifru.ifru_data))
> +	/* Most ethtool structures are defined without padding.
> +	 * Unfortunately struct ethtool_rxnfc is an exception.
> +	 */
> +	switch (ethcmd) {
> +	default:
> +		break;
> +	case ETHTOOL_GRXCLSRLALL:
> +		/* Buffer size is variable */
> +		if (get_user(rule_cnt, &compat_rxnfc->rule_cnt))
> +			return -EFAULT;
> +		if (rule_cnt > KMALLOC_MAX_SIZE / sizeof(u32))
> +			return -ENOMEM;
> +		buf_size += rule_cnt * sizeof(u32);
> +		/* fall through */
> +	case ETHTOOL_GRXRINGS:
> +	case ETHTOOL_GRXCLSRLCNT:
> +	case ETHTOOL_GRXCLSRULE:
> +		convert_out = true;
> +		/* fall through */
> +	case ETHTOOL_SRXCLSRLDEL:
> +	case ETHTOOL_SRXCLSRLINS:
> +		buf_size += sizeof(struct ethtool_rxnfc);
> +		convert_in = true;
> +		break;
> +	}
> +
> +	ifr = compat_alloc_user_space(buf_size);
> +	rxnfc = (void *)ifr + ALIGN(sizeof(struct ifreq), 8);
> +
> +	if (copy_in_user(&ifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
>  		return -EFAULT;
>  
> -	datap = compat_ptr(data);
> -	if (put_user(datap, &ifr->ifr_ifru.ifru_data))
> +	if (put_user(convert_in ? rxnfc : compat_ptr(data),
> +		     &ifr->ifr_ifru.ifru_data))
>  		return -EFAULT;
>  
> -	return dev_ioctl(net, SIOCETHTOOL, ifr);
> +	if (convert_in) {
> +		/* We expect there to be holes between fs.m_u and
> +		 * fs.ring_cookie and at the end of fs, but nowhere else.
> +		 */
> +		BUILD_BUG_ON(offsetof(struct compat_ethtool_rxnfc, fs.m_u) +
> +			     sizeof(compat_rxnfc->fs.m_u) !=
> +			     offsetof(struct ethtool_rxnfc, fs.m_u) +
> +			     sizeof(rxnfc->fs.m_u));
> +		BUILD_BUG_ON(
> +			offsetof(struct compat_ethtool_rxnfc, fs.location) -
> +			offsetof(struct compat_ethtool_rxnfc, fs.ring_cookie) !=
> +			offsetof(struct ethtool_rxnfc, fs.location) -
> +			offsetof(struct ethtool_rxnfc, fs.ring_cookie));
> +
> +		if (copy_in_user(rxnfc, compat_rxnfc,
> +				 (void *)(&rxnfc->fs.m_u + 1) - (void *)rxnfc)
> +		    ||
> +		    copy_in_user(&rxnfc->fs.ring_cookie,
> +				 &compat_rxnfc->fs.ring_cookie,
> +				 (void *)(&rxnfc->fs.location + 1) -
> +				 (void *)&rxnfc->fs.ring_cookie))
[...]

Before testing, please insert:
								   ||
		    copy_in_user(&rxnfc->rule_cnt, &compat_rxnfc->rule_cnt,
				 sizeof(rxnfc->rule_cnt))

before the final closing parenthesis above.  (This got lost in one of
many revisions.)

Ben.


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

