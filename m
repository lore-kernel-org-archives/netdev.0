From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Fri, 24 Jun 2011 12:08:59 -0700
Message-ID: <20110624120859.3c43bbcb@nehalam.ftrdhcpuser.net>
References: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
	<20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
	<BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40911 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754661Ab1FXTJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 15:09:36 -0400
In-Reply-To: <BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Jun 2011 19:29:41 +0100
Nick Carter <ncarter100@gmail.com> wrote:

> New diffs below with the Kconfig option removed as requested.
> 
> Now all users and distro's will get the correct 802.1x bridge
> behaviour by default.  That is EAPOL frames attempting to traverse the
> bridge will be dropped (IEEE Std 802.1X-2001 C.3.3).
> 
> Users or distro's who want the non-standard behaviour of forwarding
> EAPOL frames, can use a simple runtime configuration change to the
> sysfs bridge/pae_forward attribute.

This is much better, thanks.
See the comments for how to make the code more compact and tighter.

> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index d9d1e2b..91c1b71 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -214,6 +214,7 @@ static struct net_device *new_bridge_dev(struct
> net *net, const char *name)
>  	br->topology_change = 0;
>  	br->topology_change_detected = 0;
>  	br->ageing_time = 300 * HZ;
> +	br->pae_forward = BR_PAE_DEFAULT;

It is just a boolean, why the verbose enum values?
 
>  	br_netfilter_rtable_init(br);
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 90e985b..edeb92d 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -43,6 +43,16 @@ static int br_pass_frame_up(struct sk_buff *skb)
>  		       netif_receive_skb);
>  }
> 
> +static inline bool br_pae_forward(struct net_bridge *br, __be16 proto)
> +{
> +	return br->pae_forward == BR_PAE_FORWARD && proto == htons(ETH_P_PAE);
> +}
> +
> +static inline bool br_pae_drop(struct net_bridge *br, __be16 proto)
> +{
> +	return br->pae_forward == BR_PAE_DEFAULT && proto == htons(ETH_P_PAE);
> +}

Since only used one place, the extra wrappers aren't helping.

>  /* note: already called with rcu_read_lock */
>  int br_handle_frame_finish(struct sk_buff *skb)
>  {
> @@ -98,6 +108,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
>  	}
> 
>  	if (skb) {
> +		/* Prevent Crosstalk (IEEE Std 802.1X-2001 C.3.3) */
> +		if (unlikely(br_pae_drop(br, skb->protocol)))
> +			goto drop;
> +

Referencing standard is good, but perhaps explaining what that means.
Since these are multicast frames, will it ever reach this point.
This point is reached for unicast frames that are not local.
And won't this change existing behavior since before this 802.1x unicast
frames would be forwarded.

>  		if (dst)
>  			br_forward(dst->dst, skb, skb2);
>  		else
> @@ -166,6 +180,10 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
>  		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
>  			goto forward;
> 
> +		/* Check if PAE frame should be forwarded */
> +		if (br_pae_forward(p->br, skb->protocol))
> +			goto forward;
> +
>  		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
>  			    NULL, br_handle_local_finish))
>  			return NULL;	/* frame consumed by filter */
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 4e1b620..683c057 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -244,6 +244,11 @@ struct net_bridge
>  	struct timer_list		multicast_query_timer;
>  #endif
> 
> +	enum {
> +		BR_PAE_DEFAULT,		/* 802.1x frames consumed by bridge */
> +		BR_PAE_FORWARD,		/* 802.1x frames forwarded by bridge */
> +	} pae_forward;
> +
>  	struct timer_list		hello_timer;
>  	struct timer_list		tcn_timer;
>  	struct timer_list		topology_change_timer;
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index 5c1e555..9bdbc84 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -679,6 +679,31 @@ static DEVICE_ATTR(nf_call_arptables, S_IRUGO | S_IWUSR,
>  		   show_nf_call_arptables, store_nf_call_arptables);
>  #endif
> 
> +static ssize_t show_pae_forward(struct device *d, struct
> device_attribute *attr,
> +				char *buf)
> +{
> +	struct net_bridge *br = to_bridge(d);
> +	return sprintf(buf, "%d\n", br->pae_forward);
> +}
> +
> +static int set_pae_forward(struct net_bridge *br, unsigned long val)
> +{
> +	if (val > BR_PAE_FORWARD)
> +		return -EINVAL;
> +
> +	br->pae_forward = val;
> +	return 0;
> +}
> +
> +static ssize_t store_pae_forward(struct device *d,
> +				 struct device_attribute *attr, const char *buf,
> +				 size_t len)
> +{
> +	return store_bridge_parm(d, buf, len, set_pae_forward);
> +}
> +static DEVICE_ATTR(pae_forward, S_IRUGO | S_IWUSR, show_pae_forward,
> +		   store_pae_forward);
> +
>  static struct attribute *bridge_attrs[] = {
>  	&dev_attr_forward_delay.attr,
>  	&dev_attr_hello_time.attr,
> @@ -698,6 +723,7 @@ static struct attribute *bridge_attrs[] = {
>  	&dev_attr_gc_timer.attr,
>  	&dev_attr_group_addr.attr,
>  	&dev_attr_flush.attr,
> +	&dev_attr_pae_forward.attr,
>  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
>  	&dev_attr_multicast_router.attr,
>  	&dev_attr_multicast_snooping.attr,

