From: Chris Mason <clm@fb.com>
Subject: Re: [PATCH RFC 4/4] xfs: Transmit flow steering
Date: Wed, 31 Aug 2016 14:34:23 -0400
Message-ID: <e4ada2b3-0d55-149f-51a0-6817a7f95446@fb.com>
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
 <1472601634-531498-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60829 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933845AbcHaSel (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 14:34:41 -0400
In-Reply-To: <1472601634-531498-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/30/2016 08:00 PM, Tom Herbert wrote:
> XFS maintains a per device flow table that is indexed by the skbuff
> hash. The XFS table is only consulted when there is no queue saved in
> a transmit socket for an skbuff.
>
> Each entry in the flow table contains a queue index and a queue
> pointer. The queue pointer is set when a queue is chosen using a
> flow table entry. This pointer is set to the head pointer in the
> transmit queue (which is maintained by BQL).
>
> The new function get_xfs_index that looks up flows in the XPS table.
> The entry returned gives the last queue a matching flow used. The
> returned queue is compared against the normal XPS queue. If they
> are different, then we only switch if the tail pointer in the TX
> queue has advanced past the pointer saved in the entry. In this
> way OOO should be avoided when XPS wants to use a different queue.
>

I'd love for Dave Chinner to get some networking bug reports, but maybe 
we shouldn't call it XFS?

At least CONFIG_XFS should be something else.  It doesn't conflict now 
because we have CONFIG_XFS_FS, but even CONFIG_XFS_NET sounds like it's 
related to the filesystem instead of transmit flows.

[ Sorry, four patches in and all I do is complain about the name ]

-chris

> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/Kconfig    |  6 ++++
>  net/core/dev.c | 93 ++++++++++++++++++++++++++++++++++++++++++++++++----------
>  2 files changed, 84 insertions(+), 15 deletions(-)
>
> diff --git a/net/Kconfig b/net/Kconfig
> index 7b6cd34..5e3eddf 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -255,6 +255,12 @@ config XPS
>  	depends on SMP
>  	default y
>
> +config XFS
> +	bool
> +	depends on XPS
> +	depends on BQL
> +	default y
> +
>  config HWBM
>         bool

...

> -static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
> +/* Must be called with RCU read_lock */
> +static int get_xfs_index(struct net_device *dev, struct sk_buff *skb)
>  {
> -	struct sock *sk = skb->sk;
> -	int queue_index = sk_tx_queue_get(sk);
> +#ifdef CONFIG_XFS
> +	struct xps_dev_flow_table *flow_table;
> +	struct xps_dev_flow ent;
> +	int queue_index;
> +	struct netdev_queue *txq;
> +	u32 hash;
