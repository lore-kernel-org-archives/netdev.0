From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: switchdev: Clear forward mark when
 transmitting packet
Date: Fri, 1 Sep 2017 14:45:15 +0300
Message-ID: <0384baf6-0786-2d07-8919-fdd1ca5d88eb@cumulusnetworks.com>
References: <20170901092225.31597-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org, jiri@mellanox.com,
        yotamg@mellanox.com, mlxsw@mellanox.com,
        bridge@lists.linux-foundation.org
To: Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35134 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdIALpT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 07:45:19 -0400
Received: by mail-wm0-f52.google.com with SMTP id v2so2284072wmf.0
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 04:45:19 -0700 (PDT)
In-Reply-To: <20170901092225.31597-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/17 12:22, Ido Schimmel wrote:
> Commit 6bc506b4fb06 ("bridge: switchdev: Add forward mark support for
> stacked devices") added the 'offload_fwd_mark' bit to the skb in order
> to allow drivers to indicate to the bridge driver that they already
> forwarded the packet in L2.
> 
> In case the bit is set, before transmitting the packet from each port,
> the port's mark is compared with the mark stored in the skb's control
> block. If both marks are equal, we know the packet arrived from a switch
> device that already forwarded the packet and it's not re-transmitted.
> 
> However, if the packet is transmitted from the bridge device itself
> (e.g., br0), we should clear the 'offload_fwd_mark' bit as the mark
> stored in the skb's control block isn't valid.
> 
> This scenario can happen in rare cases where a packet was trapped during
> L3 forwarding and forwarded by the kernel to a bridge device.
> 
> Fixes: 6bc506b4fb06 ("bridge: switchdev: Add forward mark support for stacked devices")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Yotam Gigi <yotamg@mellanox.com>
> Tested-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/bridge/br_device.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index 861ae2a165f4..5a7be3bddfa9 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -53,6 +53,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>  	brstats->tx_bytes += skb->len;
>  	u64_stats_update_end(&brstats->syncp);
>  
> +#ifdef CONFIG_NET_SWITCHDEV
> +	skb->offload_fwd_mark = 0;
> +#endif
>  	BR_INPUT_SKB_CB(skb)->brdev = dev;
>  
>  	skb_reset_mac_header(skb);
> 

Good catch, just one minor nit since there is already an ifdef
switchdev/else in br_private.h, why not make this a helper and avoid the
ifdef/endif in here ? Currently there is no ifdef switchdev anywhere else.

Thanks,
 Nik
