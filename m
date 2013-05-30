From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 2/2] vxlan: allow specifying multiple default
 destinations
Date: Thu, 30 May 2013 12:09:48 +0100
Message-ID: <20130530110948.GA10532@casper.infradead.org>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40403 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968169Ab3E3LJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 07:09:49 -0400
Content-Disposition: inline
In-Reply-To: <1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks much better, thanks for taking the feedback. Some additional
feedback inlined:

On 05/29/13 at 01:00pm, Mike Rapoport wrote:
> +static int vxlan_remote_add(struct vxlan_dev *vxlan, struct nlattr *attr)
> +{
> +	struct nlattr *i;
> +	__be32 ip = htonl(INADDR_NONE);
> +	__be16 port;
> +	u32 ifindex, vni;
> +	int rem, err = 0;
> +
> +	port = vxlan->dst_port;
> +	vni = vxlan->default_dst.remote_vni;
> +	ifindex = vxlan->default_dst.remote_ifindex;
> +
> +	nla_for_each_nested(i, attr, rem) {
> +		switch (nla_type(i)) {
> +		case IFLA_VXLAN_REMOTE_ADDR:
> +			ip = nla_get_be32(i);
> +			break;
> +		case IFLA_VXLAN_REMOTE_PORT:
> +			port = nla_get_be16(i);
> +			break;
> +		case IFLA_VXLAN_REMOTE_VNI:
> +			vni = nla_get_u32(i);
> +			break;
> +		case IFLA_VXLAN_REMOTE_IFINDEX:
> +			ifindex = nla_get_u32(i);
> +			break;
> +		default:
> +			err = -EINVAL;
> +			break;
> +		};
> +
> +		if (err)
> +			return err;
> +	}

The above construct is not forward compatible. If we want to add
more attributes in the future any older kernel will break with
EINVAL. We typically support partial requests in older kernels.

> @@ -1380,6 +1478,13 @@ static void vxlan_setup(struct net_device *dev)
>  		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
>  }
>  
> +static const struct nla_policy vxlan_remotes_policy[IFLA_VXLAN_REMOTE_MAX + 1] = {
> +	[IFLA_VXLAN_REMOTE_ADDR]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },

I would just make this a u32 for now.

> @@ -1512,6 +1646,46 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
>  	return vs;
>  }
>  
> +static int vxlan_remotes_update(struct vxlan_dev *vxlan, struct nlattr *attr)
> +{
> +	struct nlattr *i;
> +	int rem, err = 0;
> +
> +	nla_for_each_nested(i, attr, rem) {
> +		switch (nla_type(i)) {
> +		case IFLA_VXLAN_REMOTE_NEW:
> +			err = vxlan_remote_add(vxlan, i);
> +			break;
> +		case IFLA_VXLAN_REMOTE_DEL:
> +			err = vxlan_remote_delete(vxlan, i);
> +			break;
> +		default:
> +			err = -EINVAL;
> +			break;

I would return EOPNOTSUPP here

> +static int vxlan_fill_remotes_info(struct sk_buff *skb,
> +				   const struct vxlan_dev *vxlan)
> +{
> +	struct vxlan_rdst *rdst;
> +	struct nlattr *nest, *rdst_nest;
> +	__be32 ip;
> +	int i;
> +
> +	if (vxlan->remote_cnt) {
> +		nest = nla_nest_start(skb, IFLA_VXLAN_REMOTES);
> +		if (nest == NULL)
> +			goto nla_put_failure;
> +
> +		for (rdst = vxlan->default_dst.remote_next, i = 0; rdst;
> +		     rdst = rdst->remote_next, i++) {
> +			ip = rdst->remote_ip;
> +
> +			rdst_nest = nla_nest_start(skb, i);

Attribute type '0' is reserved, please don't use it. Start with '1'.

> +enum {
> +	IFLA_VXLAN_REMOTE_NEW,
> +	IFLA_VXLAN_REMOTE_DEL,
> +};

Same here, attribute type '0' is reserved.
