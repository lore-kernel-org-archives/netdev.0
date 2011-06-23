From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Thu, 23 Jun 2011 15:29:29 -0700
Message-ID: <20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
References: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55094 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760113Ab1FWWaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 18:30:11 -0400
In-Reply-To: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jun 2011 22:39:52 +0100
Nick Carter <ncarter100@gmail.com> wrote:

> Signed-off-by: Nick Carter <ncarter100@gmail.com>
> 
> This Kconfig option is used to enable a bridge to forward 802.1x
> (EAPOL) Port Access Entity (PAE) frames.  One use of this would be to
> enable 802.1x authentication between a PAE supplicant running inside a
> virtual machine, with the EAPOL frames bridged out to an external PAE
> authenticator.
> 
> If BRIDGE_PAE_FORWARD is not set the behaviour of bridge.ko is unchanged.
> 
> If BRIDGE_PAE_FORWARD is set then by default the only new behaviour is
> that unicast EAPOL frames attempting to traverse the bridge will be
> dropped.  This makes the bridge standards compliant by preventing
> crosstalk (IEEE Std 802.1X-2001 C.3.3).
> 
> Writing a 1 to the new sysfs attribute ../bridge/pae_forward will
> enable the forwarding of EAPOL frames, both unicast and link local
> multicast (01-80-C2-00-00-03).
> 
> diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
> index 6dee7bf..c47a49e 100644
> --- a/net/bridge/Kconfig
> +++ b/net/bridge/Kconfig
> @@ -46,3 +46,22 @@ config BRIDGE_IGMP_SNOOPING
>  	  Say N to exclude this support and reduce the binary size.
> 
>  	  If unsure, say Y.
> +
> +config BRIDGE_PAE_FORWARD
> +	bool "PAE Forwarding"
> +	depends on BRIDGE
> +	default n
> +	---help---
> +	  If you say Y here, then the Ethernet bridge will be able to forward
> +	  802.1x (EAPOL) Port Access Entity (PAE) frames.  One use of this would
> +	  be to enable 802.1x authentication between a PAE supplicant running
> +	  inside a virtual machine, with the EAPOL frames bridged out to an
> +	  external PAE authenticator.
> +
> +	  On a running kernel with this support, enable PAE forwarding by
> +	  writing a '1' to the bridge devices pae_forward attribute.
> +	  e.g. echo 1 > /sys/devices/virtual/net/br73/bridge/pae_forward
> +
> +	  Say N to exclude this support.
> +
> +	  If unsure, say N.
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index d9d1e2b..b493474 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -214,6 +214,9 @@ static struct net_device *new_bridge_dev(struct
> net *net, const char *name)
>  	br->topology_change = 0;
>  	br->topology_change_detected = 0;
>  	br->ageing_time = 300 * HZ;
> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
> +	br->pae_forward = BR_PAE_DEFAULT;
> +#endif
> 
>  	br_netfilter_rtable_init(br);
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 90e985b..183c40f 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -43,6 +43,24 @@ static int br_pass_frame_up(struct sk_buff *skb)
>  		       netif_receive_skb);
>  }
> 
> +static inline bool br_pae_forward(struct net_bridge *br, __be16 proto)
> +{
> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
> +	return br->pae_forward == BR_PAE_FORWARD && proto == htons(ETH_P_PAE);
> +#else
> +	return false;
> +#endif
> +}
> +
> +static inline bool br_pae_drop(struct net_bridge *br, __be16 proto)
> +{
> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
> +	return br->pae_forward == BR_PAE_DEFAULT && proto == htons(ETH_P_PAE);
> +#else
> +	return false;
> +#endif
> +}
> +
>  /* note: already called with rcu_read_lock */
>  int br_handle_frame_finish(struct sk_buff *skb)
>  {
> @@ -98,6 +116,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
>  	}
> 
>  	if (skb) {
> +		/* Prevent Crosstalk (IEEE Std 802.1X-2001 C.3.3) */
> +		if (unlikely(br_pae_drop(br, skb->protocol)))
> +			goto drop;
> +
>  		if (dst)
>  			br_forward(dst->dst, skb, skb2);
>  		else
> @@ -166,6 +188,10 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
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
> index 4e1b620..a523032 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -244,6 +244,13 @@ struct net_bridge
>  	struct timer_list		multicast_query_timer;
>  #endif
> 
> +#ifdef CONFIG_BRIDGE_PAE_FORWARD	
> +	enum {
> +		BR_PAE_DEFAULT,		/* 802.1x frames consumed by bridge */
> +		BR_PAE_FORWARD,		/* 802.1x frames forwarded by bridge */
> +	} pae_forward;
> +#endif
> +
>  	struct timer_list		hello_timer;
>  	struct timer_list		tcn_timer;
>  	struct timer_list		topology_change_timer;
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index 5c1e555..c5ffd97 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -679,6 +679,33 @@ static DEVICE_ATTR(nf_call_arptables, S_IRUGO | S_IWUSR,
>  		   show_nf_call_arptables, store_nf_call_arptables);
>  #endif
> 
> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
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
> +#endif
> +
>  static struct attribute *bridge_attrs[] = {
>  	&dev_attr_forward_delay.attr,
>  	&dev_attr_hello_time.attr,
> @@ -717,6 +744,9 @@ static struct attribute *bridge_attrs[] = {
>  	&dev_attr_nf_call_ip6tables.attr,
>  	&dev_attr_nf_call_arptables.attr,
>  #endif
> +#ifdef CONFIG_BRIDGE_PAE_FORWARD
> +	&dev_attr_pae_forward.attr,
> +#endif
>  	NULL
>  };

Don't make it a config option, users and distros won't get it right.
The bridge already makes special case for multicast, why not add
some smarts and always do it.
