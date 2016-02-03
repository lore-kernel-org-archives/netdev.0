From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [net-next PATCH 7/7] net: ixgbe: add support for tc_u32 offload
Date: Wed, 3 Feb 2016 12:07:16 +0200
Message-ID: <20160203100716.GA20905@office.Home>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203092959.1356.91778.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ogerlitz@mellanox.com, jiri@resnulli.us, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33457 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbcBCKEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:04:21 -0500
Received: by mail-wm0-f67.google.com with SMTP id r129so6578340wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:04:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160203092959.1356.91778.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2016 at 01:29:59AM -0800, John Fastabend wrote:
> This adds initial support for offloading the u32 tc classifier. This
> initial implementation only implements a few base matches and actions
> to illustrate the use of the infrastructure patches.
> 
> However it is an interesting subset because it handles the u32 next
> hdr logic to correctly map tcp packets from ip headers using the ihl
> and protocol fields. After this is accepted we can extend the match
> and action fields easily by updating the model header file.
> 
> Also only the drop action is supported initially.
> 
> Here is a short test script,
> 
>  #tc qdisc add dev eth4 ingress
>  #tc filter add dev eth4 parent ffff: protocol ip \
> 	u32 ht 800: order 1 \
> 	match ip dst 15.0.0.1/32 match ip src 15.0.0.2/32 action drop
> 
> <-- hardware has dst/src ip match rule installed -->
> 
>  #tc filter del dev eth4 parent ffff: prio 49152
>  #tc filter add dev eth4 parent ffff: protocol ip prio 99 \
> 	handle 1: u32 divisor 1
>  #tc filter add dev eth4 protocol ip parent ffff: prio 99 \
> 	u32 ht 800: order 1 link 1: \
> 	offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 6 ff
>  #tc filter add dev eth4 parent ffff: protocol ip \
> 	u32 ht 1: order 3 match tcp src 23 ffff action drop
> 
> <-- hardware has tcp src port rule installed -->
> 
>  #tc qdisc del dev eth4 parent ffff:
> 
> <-- hardware cleaned up -->
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    6 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  196 ++++++++++++++++++++++
>  3 files changed, 198 insertions(+), 7 deletions(-)
> 

What are you doing w.r.t priorities? Are the filters processed by the
order of the priorities?

[...]

>  
> -static int ixgbe_update_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
> -					   struct ixgbe_fdir_filter *input,
> -					   u16 sw_idx)
> +int ixgbe_update_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
> +				    struct ixgbe_fdir_filter *input,
> +				    u16 sw_idx)
>  {
>  	struct ixgbe_hw *hw = &adapter->hw;
>  	struct hlist_node *node2;
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 03e236c..a1a91bf 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -51,6 +51,7 @@
>  #include <linux/prefetch.h>
>  #include <scsi/fc/fc_fcoe.h>
>  #include <net/vxlan.h>
> +#include <net/pkt_cls.h>
>  
>  #ifdef CONFIG_OF
>  #include <linux/of_net.h>
> @@ -8200,10 +8201,197 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
>  	return 0;
>  }
>  
> +#include <net/tc_act/tc_gact.h>
> +#include "ixgbe_model.h"
Did you leave those #include's in the middle of the file on purpose?

[...]
