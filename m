From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next 1/2] qdisc:  Allow qdiscs to provide backpressure up
 the stack.
Date: Wed, 25 Aug 2010 13:44:52 -0700
Message-ID: <20100825134452.5aac9dfb@nehalam>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60085 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063Ab0HYUo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 16:44:56 -0400
In-Reply-To: <1282762851-3612-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Aug 2010 12:00:50 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Some qdiscs, in some instances, can reliably detect when they
> are about to drop a packet in the dev_queue_xmit path.  In
> this case, it would be nice to provide backpressure up the
> stack, and NOT free the skb in the qdisc logic.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 59962db... 20be932... M	include/linux/netdevice.h
> :100644 100644 3c8728a... 146a97a... M	include/net/sch_generic.h
> :100644 100644 859e30f... f360a9b... M	net/core/dev.c
> :100644 100644 2aeb3a4... 0692717... M	net/sched/sch_generic.c
>  include/linux/netdevice.h |    7 +++++++
>  include/net/sch_generic.h |   19 +++++++++++++++++++
>  net/core/dev.c            |   19 ++++++++++++++-----
>  net/sched/sch_generic.c   |   20 ++++++++++++++++++++
>  4 files changed, 60 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 59962db..20be932 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -97,6 +97,7 @@ struct wireless_dev;
>  #define NET_XMIT_DROP		0x01	/* skb dropped			*/
>  #define NET_XMIT_CN		0x02	/* congestion notification	*/
>  #define NET_XMIT_POLICED	0x03	/* skb is shot by police	*/
> +#define NET_XMIT_BUSY	  	0x04	/* congestion, but skb was NOT freed */
>  #define NET_XMIT_MASK		0x0f	/* qdisc flags in net/sch_generic.h */
>  
>  /* NET_XMIT_CN is special. It does not guarantee that this packet is lost. It
> @@ -1296,6 +1297,12 @@ extern int		dev_open(struct net_device *dev);
>  extern int		dev_close(struct net_device *dev);
>  extern void		dev_disable_lro(struct net_device *dev);
>  extern int		dev_queue_xmit(struct sk_buff *skb);
> +
> +/* Similar to dev_queue_xmit, but if try_no_consume != 0,
> + * it may return NET_XMIT_BUSY and NOT free the skb if it detects congestion
> + */
> +extern int		try_dev_queue_xmit(struct sk_buff *skb, int try_no_consume);
> +
>  extern int		register_netdevice(struct net_device *dev);
>  extern void		unregister_netdevice_queue(struct net_device *dev,
>  						   struct list_head *head);
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 3c8728a..146a97a 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -43,6 +43,7 @@ struct qdisc_size_table {
>  
>  struct Qdisc {
>  	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
> +	int 			(*try_enqueue)(struct sk_buff *, struct Qdisc *dev); /* May return NET_XMIT_BUSY and NOT free skb. */
>


There aren't that many qdisc modules; just fix them all and change
semantics of enqueue.  How do you expect to handle the retry? Spinning
at the higher level is a bad idea and there is no non-racy way to get
a callback to make forward progress.
