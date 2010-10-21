From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v2 07/14] ethtool: Add support for vlan accleration.
Date: Wed, 20 Oct 2010 20:27:28 -0700
Message-ID: <4CBFB320.2060703@intel.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com> <1287618974-4714-8-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23729 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757277Ab0JUD13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Oct 2010 23:27:29 -0400
In-Reply-To: <1287618974-4714-8-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2010 4:56 PM, Jesse Gross wrote:
> Now that vlan acceleration is handled consistently regardless of usage,
> it is possible to enable and disable it at will.  This adds support for
> Ethtool operations that change the offloading status for debugging
> purposes, similar to other forms of hardware acceleration.
> 

Jesse,

Not sure if this is enough to get dynamic toggling like this
dev->hard_header_len is set depending on offloads at init time in
vlan_dev_init(). By changing this LL_RESERVED_SPACE won't work
correctly and we end up having to call pskb_expand_head(). I think
this might end up hurting performance.

That said I think I can probably get this working by fixing up the
header_ops in vlan_dev.c.  And while I'm at it add a vlan_header_cache
and vlan_header_cache_update routines. I'll try to get something out
tomorrow in the meantime nothing too bad is happening.

Thanks,
John.

> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>  include/linux/ethtool.h |    2 ++
>  net/core/ethtool.c      |    3 ++-
>  2 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 8a3338c..6628a50 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -309,6 +309,8 @@ struct ethtool_perm_addr {
>   * flag differs from the read-only value.
>   */
>  enum ethtool_flags {
> +	ETH_FLAG_TXVLAN		= (1 << 7),	/* TX VLAN offload enabled */
> +	ETH_FLAG_RXVLAN		= (1 << 8),	/* RX VLAN offload enabled */
>  	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
>  	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
>  	ETH_FLAG_RXHASH		= (1 << 28),
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 685c700..956a9f4 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -132,7 +132,8 @@ EXPORT_SYMBOL(ethtool_op_set_ufo);
>   * NETIF_F_xxx values in include/linux/netdevice.h
>   */
>  static const u32 flags_dup_features =
> -	(ETH_FLAG_LRO | ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH);
> +	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
> +	 ETH_FLAG_RXHASH);
>  
>  u32 ethtool_op_get_flags(struct net_device *dev)
>  {

