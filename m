From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCHv3 net-next] ipv6: allow routes to be configured with
 expire values
Date: Wed, 16 Dec 2015 11:03:52 -0600
Message-ID: <1450285432.23793.12.camel@redhat.com>
References: <3b977653c7ade52e180d754eb660ec66af212e94.1450259411.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753701AbbLPRD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 12:03:56 -0500
In-Reply-To: <3b977653c7ade52e180d754eb660ec66af212e94.1450259411.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 17:50 +0800, Xin Long wrote:
> Add the support for adding expire value to routes,  requested by
> Tom Gundersen <teg@jklm.no> for systemd-networkd, and NetworkManager
> wants it too.
> 
> implement it by adding the new RTNETLINK attribute RTA_EXPIRES.

Could you also add bits to send RTA_EXPIRES back to userspace in the
route dump in rt6_fill_node(), so that userspace can figure out when
RTA_EXPIRES is supported or not?

(obviously having it there isn't foolproof as if there are no routes on
the system yet userspace can't figure out support, but it's better than
nothing...)

Thanks!
Dan

> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/uapi/linux/rtnetlink.h |  1 +
>  net/ipv6/route.c               | 10 ++++++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/include/uapi/linux/rtnetlink.h
> b/include/uapi/linux/rtnetlink.h
> index 123a5af..ca764b5 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -311,6 +311,7 @@ enum rtattr_type_t {
>  	RTA_PREF,
>  	RTA_ENCAP_TYPE,
>  	RTA_ENCAP,
> +	RTA_EXPIRES,
>  	__RTA_MAX
>  };
>  
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index c83b6a5..3c8834b 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2709,6 +2709,7 @@ static const struct nla_policy
> rtm_ipv6_policy[RTA_MAX+1] = {
>  	[RTA_PREF]              = { .type = NLA_U8 },
>  	[RTA_ENCAP_TYPE]	= { .type = NLA_U16 },
>  	[RTA_ENCAP]		= { .type = NLA_NESTED },
> +	[RTA_EXPIRES]		= { .type = NLA_U32 },
>  };
>  
>  static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr
> *nlh,
> @@ -2809,6 +2810,15 @@ static int rtm_to_fib6_config(struct sk_buff
> *skb, struct nlmsghdr *nlh,
>  	if (tb[RTA_ENCAP_TYPE])
>  		cfg->fc_encap_type =
> nla_get_u16(tb[RTA_ENCAP_TYPE]);
>  
> +	if (tb[RTA_EXPIRES]) {
> +		unsigned long timeout =
> addrconf_timeout_fixup(nla_get_u32(tb[RTA_EXPIRES]), HZ);
> +
> +		if (addrconf_finite_timeout(timeout)) {
> +			cfg->fc_expires = jiffies_to_clock_t(timeout
> * HZ);
> +			cfg->fc_flags |= RTF_EXPIRES;
> +		}
> +	}
> +
>  	err = 0;
>  errout:
>  	return err;
