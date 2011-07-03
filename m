From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH 1/2] dcbnl: Aggregated CEE GET operation
Date: Sun, 03 Jul 2011 11:09:00 -0700
Message-ID: <4E10B03C.1070803@intel.com>
References: <1309624423.15528.43.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57501 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751857Ab1GCSJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jul 2011 14:09:01 -0400
In-Reply-To: <1309624423.15528.43.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/2011 9:33 AM, Shmulik Ravid wrote:
> The following couple of patches add dcbnl an unsolicited notification of
> the the DCB configuration for the CEE flavor of the DCBX protocol. This
> is useful when the user-mode DCB client is not responsible for
> conducting and resolving the DCBX negotiation (either because the DCBX
> stack is embedded in the HW or the negotiation is handled by another
> agent in he host), but still needs to get the negotiated parameters.
> This functionality already exists for the IEEE flavor of the DCBX
> protocol and these patches add it to the older CEE flavor.
> 
> The first patch extends the CEE attribute GET operation to include not
> only the peer information, but also all the pertinent local
> configuration (negotiated parameters). The second patch adds and export
> a CEE specific notification routine.
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
> ---
>  include/linux/dcbnl.h |   20 ++++++-
>  net/dcb/dcbnl.c       |  156 ++++++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 168 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
> index 66a6723..c875244 100644
> --- a/include/linux/dcbnl.h
> +++ b/include/linux/dcbnl.h
> @@ -333,15 +333,26 @@ enum ieee_attrs_app {
>  #define DCB_ATTR_IEEE_APP_MAX (__DCB_ATTR_IEEE_APP_MAX - 1)
>  
>  /**
> - * enum cee_attrs - CEE DCBX get attributes
> + * enum cee_attrs - CEE DCBX get attributes. An aggregated collection of the
> + * cee std negotiated parameters
>   *
>   * @DCB_ATTR_CEE_UNSPEC: unspecified
> + * @DCB_ATTR_CEE_FEAT: DCBX features flags (DCB_CMD_GFEATCFG)
> + * @DCB_ATTR_CEE_RX_PG: RX PG configuration (DCB_CMD_PGRX_GCFG)
> + * @DCB_ATTR_CEE_TX_PG: TX PG configuration (DCB_CMD_PGTX_GCFG)
> + * @DCB_ATTR_CEE_PFC: PFC configuration (DCB_CMD_PFC_GCFG)
> + * @DCB_ATTR_CEE_APP_TABLE: APP configuration (multi DCB_CMD_GAPP)
>   * @DCB_ATTR_CEE_PEER_PG: peer PG configuration - get only
>   * @DCB_ATTR_CEE_PEER_PFC: peer PFC configuration - get only
>   * @DCB_ATTR_CEE_PEER_APP: peer APP tlv - get only
>   */
>  enum cee_attrs {
>  	DCB_ATTR_CEE_UNSPEC,
> +	DCB_ATTR_CEE_TX_PG,
> +	DCB_ATTR_CEE_RX_PG,
> +	DCB_ATTR_CEE_PFC,
> +	DCB_ATTR_CEE_APP_TABLE,
> +	DCB_ATTR_CEE_FEAT,
>  	DCB_ATTR_CEE_PEER_PG,
>  	DCB_ATTR_CEE_PEER_PFC,
>  	DCB_ATTR_CEE_PEER_APP_TABLE,

PEER_PG, PEER_PFC, and PEER_APP_TABLE are already in kernel and user
space. So we shouldn't change their enum'd value. Put the new values
below them.

> @@ -357,6 +368,13 @@ enum peer_app_attr {
>  };
>  #define DCB_ATTR_CEE_PEER_APP_MAX (__DCB_ATTR_CEE_PEER_APP_MAX - 1)
>  
> +enum cee_attrs_app {
> +	DCB_ATTR_CEE_APP_UNSPEC,
> +	DCB_ATTR_CEE_APP,
> +	__DCB_ATTR_CEE_APP_MAX
> +};
> +#define DCB_ATTR_CEE_APP_MAX (__DCB_ATTR_CEE_APP_MAX - 1)
> +
>  /**
>   * enum dcbnl_pfc_attrs - DCB Priority Flow Control user priority nested attrs
>   *
> diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
> index fc56e85..5b75ed7 100644
> --- a/net/dcb/dcbnl.c
> +++ b/net/dcb/dcbnl.c
> @@ -1642,6 +1642,58 @@ err:
>  	return ret;
>  }
>  
> +static int dcbnl_cee_pg_fill(struct sk_buff *skb, struct net_device *dev,
> +			     int dir)

Why the 'dir'? Could you just pack both tx and rx together? It looks like all
cases pack TX then pack RX. Did I miss something?

> +{
> +	u8 pgid, up_map, prio, tc_pct;
> +	const struct dcbnl_rtnl_ops *ops = dev->dcbnl_ops;
> +	int i = dir ? DCB_ATTR_CEE_TX_PG : DCB_ATTR_CEE_RX_PG;
> +	struct nlattr *pg = nla_nest_start(skb, i);

I believe its preferred to put an empty line here. At least I prefer it.

> +	if (!pg)
> +		goto nla_put_failure;
> +
> +	for (i = DCB_PG_ATTR_TC_0; i <= DCB_PG_ATTR_TC_7; i++) {
> +		struct nlattr *tc_nest = nla_nest_start(skb, i);

same here.

> +		if (!tc_nest)
> +			goto nla_put_failure;
> +
> +		pgid = DCB_ATTR_VALUE_UNDEFINED;
> +		prio = DCB_ATTR_VALUE_UNDEFINED;
> +		tc_pct = DCB_ATTR_VALUE_UNDEFINED;
> +		up_map = DCB_ATTR_VALUE_UNDEFINED;
> +
> +		if (!dir)
> +			ops->getpgtccfgrx(dev, i - DCB_PG_ATTR_TC_0,
> +					  &prio, &pgid, &tc_pct, &up_map);
> +		else
> +			ops->getpgtccfgtx(dev, i - DCB_PG_ATTR_TC_0,
> +					  &prio, &pgid, &tc_pct, &up_map);
> +


Thanks for doing this. We should be able to get firmware CEE DCBX agents
working correctly with this.

//John
