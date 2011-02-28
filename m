From: Kees Cook <kees.cook@canonical.com>
Subject: Re: [PATCHv2 net-next-2.6] ethtool: Compat handling for struct
 ethtool_rxnfc
Date: Mon, 28 Feb 2011 15:51:57 -0800
Message-ID: <20110228235157.GG4669@outflux.net>
References: <1298930141.2569.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Santwona Behera <santwona.behera@sun.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.outflux.net ([198.145.64.163]:36449 "EHLO smtp.outflux.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754861Ab1B1XwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 18:52:04 -0500
Content-Disposition: inline
In-Reply-To: <1298930141.2569.22.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Mon, Feb 28, 2011 at 09:55:41PM +0000, Ben Hutchings wrote:
> I'm not sure whether more checks on rule_cnt are required for security
> or whether compat_alloc_user_space() and copy_in_user() can be relied on
> to limit any buffer overrun to the user process's own memory.  It looks
> like this is safe on x86.

I'm less familiar with the compat world, but it looks sane to me. All the
copy_in_user() calls are calculated based on structure sizes, right? Except
for the rule_cnt one, which was already bounds-checked for output. AFAIK,
reading beyond the end of &rxnfc->rule_locs[0] should be contained to
userspace memory due to the access_ok() check in copy_in_user().

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
> ...
> +	if (convert_out) {
> ...
> +		if (ethcmd == ETHTOOL_GRXCLSRLALL) {
> +			if (get_user(rule_cnt, &compat_rxnfc->rule_cnt) ||
> +			    copy_in_user(&compat_rxnfc->rule_locs[0],
> +					 &rxnfc->rule_locs[0],
> +					 rule_cnt * sizeof(u32)))
> +				return -EFAULT;

-Kees

-- 
Kees Cook
Ubuntu Security Team
