From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH v4 3/5] netdev: add tracepoints to netdev layer
Date: Fri, 27 Aug 2010 08:38:15 -0400
Message-ID: <20100827123815.GC17607@hmsreliant.think-freely.org>
References: <4C4FCDA1.3000803@jp.fujitsu.com>
 <4C4FCEB5.5040706@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41363 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab0H0Mid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 08:38:33 -0400
Content-Disposition: inline
In-Reply-To: <4C4FCEB5.5040706@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 28, 2010 at 03:31:17PM +0900, Koki Sanagi wrote:
> CHANGE-LOG since v3:
>    -add tracepoint to netif_rx.
> 
> 
> This patch adds tracepoint to dev_queue_xmit, dev_hard_start_xmit, netif_rx and
> netif_receive_skb. These tracepoints help you to monitor network driver's
> input/output.
> 
>           <idle>-0     [001] 112447.902030: netif_rx: dev=eth1 skbaddr=f3ef0900 len=84
>           <idle>-0     [001] 112447.902039: netif_receive_skb: dev=eth1 skbaddr=f3ef0900 len=84
>             sshd-6828  [000] 112447.903257: net_dev_queue: dev=eth4 skbaddr=f3fca538 len=226
>             sshd-6828  [000] 112447.903260: net_dev_xmit: dev=eth4 skbaddr=f3fca538 len=226 rc=0
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> ---
>  include/trace/events/net.h |   82 ++++++++++++++++++++++++++++++++++++++++++++
>  net/core/dev.c             |    6 +++
>  net/core/net-traces.c      |    1 +
>  3 files changed, 89 insertions(+), 0 deletions(-)
> 
> diff --git a/include/trace/events/net.h b/include/trace/events/net.h
> new file mode 100644
> index 0000000..5f247f5
> --- /dev/null
> +++ b/include/trace/events/net.h
> @@ -0,0 +1,82 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM net
> +
> +#if !defined(_TRACE_NET_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_NET_H
> +
> +#include <linux/skbuff.h>
> +#include <linux/netdevice.h>
> +#include <linux/ip.h>
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(net_dev_xmit,
> +
> +	TP_PROTO(struct sk_buff *skb,
> +		 int rc),
> +
> +	TP_ARGS(skb, rc),
> +
> +	TP_STRUCT__entry(
> +		__field(	void *,		skbaddr		)
> +		__field(	unsigned int,	len		)
> +		__field(	int,		rc		)
> +		__string(	name,		skb->dev->name	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->skbaddr = skb;
> +		__entry->len = skb->len;
> +		__entry->rc = rc;
> +		__assign_str(name, skb->dev->name);
> +	),
> +
> +	TP_printk("dev=%s skbaddr=%p len=%u rc=%d",
> +		__get_str(name), __entry->skbaddr, __entry->len, __entry->rc)
> +);
> +
> +DECLARE_EVENT_CLASS(net_dev_template,
> +
> +	TP_PROTO(struct sk_buff *skb),
> +
> +	TP_ARGS(skb),
> +
> +	TP_STRUCT__entry(
> +		__field(	void *,		skbaddr		)
> +		__field(	unsigned int,	len		)
> +		__string(	name,		skb->dev->name	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->skbaddr = skb;
> +		__entry->len = skb->len;
> +		__assign_str(name, skb->dev->name);
> +	),
> +
> +	TP_printk("dev=%s skbaddr=%p len=%u",
> +		__get_str(name), __entry->skbaddr, __entry->len)
> +)
> +
> +DEFINE_EVENT(net_dev_template, net_dev_queue,
> +
> +	TP_PROTO(struct sk_buff *skb),
> +
> +	TP_ARGS(skb)
> +);
> +
> +DEFINE_EVENT(net_dev_template, netif_receive_skb,
> +
> +	TP_PROTO(struct sk_buff *skb),
> +
> +	TP_ARGS(skb)
> +);
> +
> +DEFINE_EVENT(net_dev_template, netif_rx,
> +
> +	TP_PROTO(struct sk_buff *skb),
> +
> +	TP_ARGS(skb)
> +);
> +#endif /* _TRACE_NET_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6e1b437..9ea9c1e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -130,6 +130,7 @@
>  #include <linux/jhash.h>
>  #include <linux/random.h>
>  #include <trace/events/napi.h>
> +#include <trace/events/net.h>
>  #include <linux/pci.h>
>  
>  #include "net-sysfs.h"
> @@ -1981,6 +1982,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  		}
>  
>  		rc = ops->ndo_start_xmit(skb, dev);
> +		trace_net_dev_xmit(skb, rc);
>  		if (rc == NETDEV_TX_OK)
>  			txq_trans_update(txq);
>  		return rc;
> @@ -2001,6 +2003,7 @@ gso:
>  			skb_dst_drop(nskb);
>  
>  		rc = ops->ndo_start_xmit(nskb, dev);
> +		trace_net_dev_xmit(nskb, rc);
>  		if (unlikely(rc != NETDEV_TX_OK)) {
>  			if (rc & ~NETDEV_TX_MASK)
>  				goto out_kfree_gso_skb;
> @@ -2189,6 +2192,7 @@ int dev_queue_xmit(struct sk_buff *skb)
>  #ifdef CONFIG_NET_CLS_ACT
>  	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
>  #endif
> +	trace_net_dev_queue(skb);
>  	if (q->enqueue) {
>  		rc = __dev_xmit_skb(skb, q, dev, txq);
>  		goto out;
> @@ -2515,6 +2519,7 @@ int netif_rx(struct sk_buff *skb)
>  	if (netdev_tstamp_prequeue)
>  		net_timestamp_check(skb);
>  
> +	trace_netif_rx(skb);
>  #ifdef CONFIG_RPS
>  	{
>  		struct rps_dev_flow voidflow, *rflow = &voidflow;
> @@ -2829,6 +2834,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
>  	if (!netdev_tstamp_prequeue)
>  		net_timestamp_check(skb);
>  
> +	trace_netif_receive_skb(skb);
>  	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
>  		return NET_RX_SUCCESS;
>  
> diff --git a/net/core/net-traces.c b/net/core/net-traces.c
> index afa6380..7f1bb2a 100644
> --- a/net/core/net-traces.c
> +++ b/net/core/net-traces.c
> @@ -26,6 +26,7 @@
>  
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/skb.h>
> +#include <trace/events/net.h>
>  #include <trace/events/napi.h>
>  
>  EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
