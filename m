From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] ipv6: addrconf: validate new MTU before applying it
Date: Sat, 21 Feb 2015 16:54:07 +0100
Message-ID: <20150221155407.GA16874@kria>
References: <60cde83b718e88aa7fcae7239a3aac704e048efc.1424456163.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:24257 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbbBUPyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2015 10:54:12 -0500
Content-Disposition: inline
In-Reply-To: <60cde83b718e88aa7fcae7239a3aac704e048efc.1424456163.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2015-02-20, 16:24:06 -0200, Marcelo Ricardo Leitner wrote:

> [...]

> ---
>  net/ipv6/addrconf.c | 32 +++++++++++++++++++++++++++++++-
>  1 file changed, 31 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index f7c8bbeb27b704c0106f714d5a0677c27d3346e0..38892228ccacfe8b67b182784723cc0b67ce572b 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -4863,6 +4863,36 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
>  	return ret;
>  }
>  
> +static
> +int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
> +			void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	int *valp = ctl->data;
> +	int val = *valp;
> +	loff_t pos = *ppos;
> +	struct ctl_table lctl;
> +	int ret;
> +
> +	/* ctl->data points to idev->cnf.mtu6
> +	 */
> +	lctl = *ctl;
> +	lctl.data = &val;
> +
> +	ret = proc_dointvec(&lctl, write, buffer, lenp, ppos);
> +
> +	if (write) {
> +		struct inet6_dev *idev = ctl->extra1;
> +
> +		if (val >= IPV6_MIN_MTU && val <= idev->dev->mtu)

"all" and "default" don't have an idev, so you need a check here:

    if (val >= IPV6_MIN_MTU && (!idev || val <= idev->dev->mtu))


> +			*valp = val;
> +		else
> +			ret = -EINVAL;
> +	}
> +	if (ret)
> +		*ppos = pos;
> +	return ret;
> +}
> +


You could call proc_dointvec_minmax to do the checks.  Something like:

static
int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
			void __user *buffer, size_t *lenp, loff_t *ppos)
{
	struct inet6_dev *idev = ctl->extra1;
	int min_mtu = IPV6_MIN_MTU;
	struct ctl_table lctl;

	lctl = *ctl;
	lctl.extra1 = &min_mtu;
	lctl.extra2 = idev ? &idev->dev->mtu : NULL;

	return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
}



Thanks,

-- 
Sabrina
