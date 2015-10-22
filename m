From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v4 1/2] mpls: multipath route support
Date: Thu, 22 Oct 2015 11:24:10 +0100
Message-ID: <5628B94A.5010903@brocade.com>
References: <1445217645-42885-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ebiederm@xmission.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:34522 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757072AbbJVKYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 06:24:25 -0400
In-Reply-To: <1445217645-42885-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/10/15 02:20, Roopa Prabhu wrote:
> @@ -159,6 +137,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>   	struct net *net = dev_net(dev);
>   	struct mpls_shim_hdr *hdr;
>   	struct mpls_route *rt;
> +	struct mpls_nh *nh;
>   	struct mpls_entry_decoded dec;
>   	struct net_device *out_dev;
>   	struct mpls_dev *mdev;
> @@ -166,6 +145,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>   	unsigned int new_header_size;
>   	unsigned int mtu;
>   	int err;
> +	int nhidx;

nhidx looks to be unused. Remove?

>
>   	/* Careful this entire function runs inside of an rcu critical section */
>
> @@ -196,8 +176,12 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>   	if (!rt)
>   		goto drop;
>
> +	nh = mpls_select_multipath(rt);
> +	if (!nh)
> +		goto drop;
> +
>   	/* Find the output device */
> -	out_dev = rcu_dereference(rt->rt_dev);
> +	out_dev = rcu_dereference(nh->nh_dev);
>   	if (!mpls_output_possible(out_dev))
>   		goto drop;
>
> @@ -212,7 +196,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>   	dec.ttl -= 1;
>
>   	/* Verify the destination can hold the packet */
> -	new_header_size = mpls_rt_header_size(rt);
> +	new_header_size = mpls_nh_header_size(nh);
>   	mtu = mpls_dev_mtu(out_dev);
>   	if (mpls_pkt_too_big(skb, mtu - new_header_size))
>   		goto drop;
> @@ -240,13 +224,14 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>   		/* Push the new labels */
>   		hdr = mpls_hdr(skb);
>   		bos = dec.bos;
> -		for (i = rt->rt_labels - 1; i >= 0; i--) {
> -			hdr[i] = mpls_entry_encode(rt->rt_label[i], dec.ttl, 0, bos);
> +		for (i = nh->nh_labels - 1; i >= 0; i--) {
> +			hdr[i] = mpls_entry_encode(nh->nh_label[i],
> +						   dec.ttl, 0, bos);
>   			bos = false;
>   		}
>   	}
>
> -	err = neigh_xmit(rt->rt_via_table, out_dev, rt->rt_via, skb);
> +	err = neigh_xmit(nh->nh_via_table, out_dev, nh->nh_via, skb);
>   	if (err)
>   		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
>   				    __func__, err);

>   	return dev;
>   }
>
> +static int mpls_nh_assign_dev(struct net *net, struct mpls_nh *nh, int oif)
> +{
> +	struct net_device *dev = NULL;
> +	int err = -ENODEV;
> +
> +	dev = find_outdev(net, nh, oif);
> +	if (IS_ERR(dev)) {
> +		err = PTR_ERR(dev);
> +		dev = NULL;
> +		goto errout;
> +	}
> +
> +	/* Ensure this is a supported device */
> +	err = -EINVAL;
> +	if (!mpls_dev_get(dev))
> +		goto errout;
> +
> +	/* For now just support ethernet devices */
> +	if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
> +		goto errout;
> +
> +	RCU_INIT_POINTER(nh->nh_dev, dev);
> +	dev_put(dev);

If it's safe to not keep a reference to dev (i.e. because the device 
cannot go away while a netlink message is being processed), then why not 
just change find_outdev to use __dev_get_by_index? If the dev can go 
away during this, then we could end up adding an mpls route that points 
to a freed interface, because until we've added the route to the label 
table mpls_ifdown won't find it.

> +
> +	return 0;
> +
> +errout:
> +	if (dev)
> +		dev_put(dev);
> +	return err;
> +}
> +

>   }
>   EXPORT_SYMBOL_GPL(nla_get_labels);
>
> +int nla_get_via(const struct nlattr *nla, u8 *via_alen,
> +		u8 *via_table, u8 via_addr[])
> +{
> +	struct rtvia *via = nla_data(nla);
> +	int err = -EINVAL;
> +	u8 alen;

This should be an int to avoid nexthop address lengths > 255 wrapping 
and possibly accepted instead of rejected.

> +
> +	if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
> +		goto errout;
> +	alen = nla_len(nla) -
> +			offsetof(struct rtvia, rtvia_addr);
> +	if (alen > MAX_VIA_ALEN)
> +		goto errout;
> +
> +	/* Validate the address family */
> +	switch(via->rtvia_family) {
> +	case AF_PACKET:
> +		*via_table = NEIGH_LINK_TABLE;
> +		break;
> +	case AF_INET:
> +		*via_table = NEIGH_ARP_TABLE;
> +		if (alen != 4)
> +			goto errout;
> +		break;
> +	case AF_INET6:
> +		*via_table = NEIGH_ND_TABLE;
> +		if (alen != 16)
> +			goto errout;
> +		break;
> +	default:
> +		/* Unsupported address family */
> +		goto errout;
> +	}
> +
> +	memcpy(via_addr, via->rtvia_addr, alen);
> +	*via_alen = alen;
> +	err = 0;
> +
> +errout:
> +	return err;
> +}
> +
>   static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>   			       struct mpls_route_config *cfg)
>   {


Otherwise, looks good.

Thanks,
Rob
