From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH v3 3/5] netdev: add tracepoints to netdev layer
Date: Tue, 20 Jul 2010 07:41:52 -0400
Message-ID: <20100720114152.GC1995@hmsreliant.think-freely.org>
References: <4C44F12F.5090908@jp.fujitsu.com>
 <4C44F23F.6050800@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C44F23F.6050800@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 20, 2010 at 09:47:59AM +0900, Koki Sanagi wrote:
> This patch adds tracepoint to dev_queue_xmit, dev_hard_start_xmit and
> netif_receive_skb. These tracepoints help you to monitor network driver's
> input/output.
> 
>             sshd-4445  [001] 241367.066046: net_dev_queue: dev=eth3 skbaddr=dd6b2538 len=114
>             sshd-4445  [001] 241367.066047: net_dev_xmit: dev=eth3 skbaddr=dd6b2538 len=114 rc=0
>           <idle>-0     [001] 241367.067472: net_dev_receive: dev=eth3 skbaddr=f5e59000 len=52
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>  include/trace/events/net.h |   75 ++++++++++++++++++++++++++++++++++++++++++++
>  net/core/dev.c             |    5 +++
>  net/core/net-traces.c      |    1 +
>  3 files changed, 81 insertions(+), 0 deletions(-)
> 
> diff --git a/include/trace/events/net.h b/include/trace/events/net.h
> new file mode 100644
> index 0000000..8a21361
> --- /dev/null
> +++ b/include/trace/events/net.h
> @@ -0,0 +1,75 @@
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
> +DEFINE_EVENT(net_dev_template, net_dev_receive,
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
> index 93b8929..4acfec6 100644
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
> @@ -1955,6 +1956,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  		}
>  
>  		rc = ops->ndo_start_xmit(skb, dev);
> +		trace_net_dev_xmit(skb, rc);
>  		if (rc == NETDEV_TX_OK)
>  			txq_trans_update(txq);
>  		return rc;
> @@ -1975,6 +1977,7 @@ gso:
>  			skb_dst_drop(nskb);
>  
>  		rc = ops->ndo_start_xmit(nskb, dev);
> +		trace_net_dev_xmit(nskb, rc);
>  		if (unlikely(rc != NETDEV_TX_OK)) {
>  			if (rc & ~NETDEV_TX_MASK)
>  				goto out_kfree_gso_skb;
> @@ -2165,6 +2168,7 @@ int dev_queue_xmit(struct sk_buff *skb)
>  #ifdef CONFIG_NET_CLS_ACT
>  	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
>  #endif
> +	trace_net_dev_queue(skb);
>  	if (q->enqueue) {
>  		rc = __dev_xmit_skb(skb, q, dev, txq);
>  		goto out;
> @@ -2939,6 +2943,7 @@ int netif_receive_skb(struct sk_buff *skb)
>  	if (netdev_tstamp_prequeue)
>  		net_timestamp_check(skb);
>  
> +	trace_net_dev_receive(skb);

I imagine for completeness you'll want to make a call to this in netif_rx and
netif_rx_ni as well.
