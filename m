From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Subject: Re: [PATCH net-next 1/2] net: neighbour: Add mcast_resolicit to configure
 the number of multicast resolicitations in PROBE state.
Date: Thu, 19 Mar 2015 15:46:20 +0100
Message-ID: <550AE13C.5080906@ericsson.com>
References: <20150319.224146.893461080038567220.yoshfuji@yoshifuji-H87MS01.miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <Yanjun.Zhu@windriver.com>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:55120 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbbCSOqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 10:46:23 -0400
In-Reply-To: <20150319.224146.893461080038567220.yoshfuji@yoshifuji-H87MS01.miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think it would be good, if the initial value of "mcast_resolicit"
could be specified using Kconfig.

Would make sense to have this for the other <xxx> solicit variables as well.

Removes the need to add extra scripts to enable the functionality

As I mentioned before, I think that for home systems,
it makes sense to have this feature always enabled,
and having it as a compile time parameter would
encourage people to enable the functionality.

Best Regards,
Ulf Samuelsson




On 03/19/2015 02:41 PM, YOSHIFUJI Hideaki wrote:
> We send unicast neighbor (ARP or NDP) solicitations ucast_probes
> times in PROBE state.  Zhu Yanjun reported that some implementation
> does not reply against them and the entry will become FAILED, which
> is undesirable.
>
> We had been dealt with such nodes by sending multicast probes mcast_
> solicit times after unicast probes in PROBE state.  In 2003, I made
> a change not to send them to improve compatibility with IPv6 NDP.
>
> Let's introduce per-protocol per-interface sysctl knob "mcast_
> reprobe" to configure the number of multicast (re)solicitation for
> reconfirmation in PROBE state.  The default is 0, since we have
> been doing so for 10+ years.
>
> Reported-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> CC: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>   include/net/neighbour.h        |  1 +
>   include/uapi/linux/neighbour.h |  1 +
>   net/core/neighbour.c           | 15 +++++++++++----
>   3 files changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/neighbour.h b/include/net/neighbour.h
> index e7bdf51..bd33e66 100644
> --- a/include/net/neighbour.h
> +++ b/include/net/neighbour.h
> @@ -42,6 +42,7 @@ enum {
>   	NEIGH_VAR_MCAST_PROBES,
>   	NEIGH_VAR_UCAST_PROBES,
>   	NEIGH_VAR_APP_PROBES,
> +	NEIGH_VAR_MCAST_REPROBES,
>   	NEIGH_VAR_RETRANS_TIME,
>   	NEIGH_VAR_BASE_REACHABLE_TIME,
>   	NEIGH_VAR_DELAY_PROBE_TIME,
> diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
> index 3873a35..2e35c61 100644
> --- a/include/uapi/linux/neighbour.h
> +++ b/include/uapi/linux/neighbour.h
> @@ -126,6 +126,7 @@ enum {
>   	NDTPA_PROXY_QLEN,		/* u32 */
>   	NDTPA_LOCKTIME,			/* u64, msecs */
>   	NDTPA_QUEUE_LENBYTES,		/* u32 */
> +	NDTPA_MCAST_REPROBES,		/* u32 */
>   	__NDTPA_MAX
>   };
>   #define NDTPA_MAX (__NDTPA_MAX - 1)
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 0e8b32e..3de6542 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -817,10 +817,9 @@ out:
>   static __inline__ int neigh_max_probes(struct neighbour *n)
>   {
>   	struct neigh_parms *p = n->parms;
> -	int max_probes = NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES);
> -	if (!(n->nud_state & NUD_PROBE))
> -		max_probes += NEIGH_VAR(p, MCAST_PROBES);
> -	return max_probes;
> +	return NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES) +
> +	       (n->nud_state & NUD_PROBE ? NEIGH_VAR(p, MCAST_REPROBES) :
> +	        NEIGH_VAR(p, MCAST_PROBES));
>   }
>   
>   static void neigh_invalidate(struct neighbour *neigh)
> @@ -1742,6 +1741,8 @@ static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
>   			NEIGH_VAR(parms, UCAST_PROBES)) ||
>   	    nla_put_u32(skb, NDTPA_MCAST_PROBES,
>   			NEIGH_VAR(parms, MCAST_PROBES)) ||
> +	    nla_put_u32(skb, NDTPA_MCAST_REPROBES,
> +			NEIGH_VAR(parms, MCAST_REPROBES)) ||
>   	    nla_put_msecs(skb, NDTPA_REACHABLE_TIME, parms->reachable_time) ||
>   	    nla_put_msecs(skb, NDTPA_BASE_REACHABLE_TIME,
>   			  NEIGH_VAR(parms, BASE_REACHABLE_TIME)) ||
> @@ -1901,6 +1902,7 @@ static const struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] = {
>   	[NDTPA_APP_PROBES]		= { .type = NLA_U32 },
>   	[NDTPA_UCAST_PROBES]		= { .type = NLA_U32 },
>   	[NDTPA_MCAST_PROBES]		= { .type = NLA_U32 },
> +	[NDTPA_MCAST_REPROBES]		= { .type = NLA_U32 },
>   	[NDTPA_BASE_REACHABLE_TIME]	= { .type = NLA_U64 },
>   	[NDTPA_GC_STALETIME]		= { .type = NLA_U64 },
>   	[NDTPA_DELAY_PROBE_TIME]	= { .type = NLA_U64 },
> @@ -2001,6 +2003,10 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
>   				NEIGH_VAR_SET(p, MCAST_PROBES,
>   					      nla_get_u32(tbp[i]));
>   				break;
> +			case NDTPA_MCAST_REPROBES:
> +				NEIGH_VAR_SET(p, MCAST_REPROBES,
> +					      nla_get_u32(tbp[i]));
> +				break;
>   			case NDTPA_BASE_REACHABLE_TIME:
>   				NEIGH_VAR_SET(p, BASE_REACHABLE_TIME,
>   					      nla_get_msecs(tbp[i]));
> @@ -2987,6 +2993,7 @@ static struct neigh_sysctl_table {
>   		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(MCAST_PROBES, "mcast_solicit"),
>   		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(UCAST_PROBES, "ucast_solicit"),
>   		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(APP_PROBES, "app_solicit"),
> +		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(MCAST_REPROBES, "mcast_resolicit"),
>   		NEIGH_SYSCTL_USERHZ_JIFFIES_ENTRY(RETRANS_TIME, "retrans_time"),
>   		NEIGH_SYSCTL_JIFFIES_ENTRY(BASE_REACHABLE_TIME, "base_reachable_time"),
>   		NEIGH_SYSCTL_JIFFIES_ENTRY(DELAY_PROBE_TIME, "delay_first_probe_time"),
