From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 2/2] vxlan: allow specifying multiple default
 destinations
Date: Tue, 28 May 2013 12:43:23 +0100
Message-ID: <20130528114323.GA1726@casper.infradead.org>
References: <1369729878-9690-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1369729878-9690-3-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59160 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932878Ab3E1LnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 07:43:24 -0400
Content-Disposition: inline
In-Reply-To: <1369729878-9690-3-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/13 at 11:31am, Mike Rapoport wrote:
> +/* Add remote to default destinations list */
> +static int vxlan_remote_add(struct vxlan_dev *vxlan, struct nlattr *attr)
> +{
> +	struct nlattr *i;
> +	__be32 ip;
> +	__be16 port;
> +	u32 ifindex, vni;
> +	int rem, err = 0;
> +	bool addr_set = false;
> +
> +	port = vxlan->dst_port;
> +	vni = vxlan->default_dst.remote_vni;
> +	ifindex = vxlan->default_dst.remote_ifindex;
> +
> +	nla_for_each_nested(i, attr, rem) {
> +		switch (nla_type(i)) {
> +		case IFLA_VXLAN_REMOTE_ADDR:
> +			ip = nla_get_be32(i);
> +			addr_set = true;
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
> +
> +	if (!addr_set)
> +		return -EINVAL;
> +
> +	err = vxlan_rdst_append(&vxlan->default_dst, ip, port, vni, ifindex);
> +	if (err < 0)
> +		return err;

You must be seeing a warning about a possible use of uninitialized
data here. 'ip' could be uninitialized.

In fact you are using these Netlink attributes blindy without
validation. You need to extend vxlan_validate() and verify the
type and length of each attribute. User space is not guaranteed
to send the data you expect.

> +	netdev_dbg(vxlan->dev, "dstadd %pI4\n", &ip);

This doesn't look suitable for inclusion.

> @@ -1513,6 +1601,27 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
>  	return vs;
>  }
>  
> +static int vxlan_changelink(struct net_device *dev,
> +			    struct nlattr *tb[], struct nlattr *data[])
> +{
> +	struct vxlan_dev *vxlan = netdev_priv(dev);
> +	int err;
> +
> +	if (data[IFLA_VXLAN_REMOTE_ADD]) {
> +		err = vxlan_remote_add(vxlan, data[IFLA_VXLAN_REMOTE_ADD]);
> +		if (err)
> +			return err;
> +	}
> +
> +	if (data[IFLA_VXLAN_REMOTE_DEL]) {
> +		err = vxlan_remote_delete(vxlan, data[IFLA_VXLAN_REMOTE_DEL]);
> +		if (err)
> +			return err;
> +	}

First of all please use NEW and DEL because that is what we use
everywhere in Netlink and everyone is used to it.

I would also make both of these a list of nested attribute to allow
for multiple additions and deletions in the future. And please use
the same format for NEW and DEL. Using a u32 directly for deletions
sets the format in stone and we can't extend it in the future.

Using attributes as you do in the addition case allows to support
IPv6 addresses in the future.

Why not make it even more generic and encode changes like this:

enum {
  IFLA_VXLAN_REMOTE_NEW,
  IFLA_VXLAN_REMOTE_DEL,
};

IFLA_VXLAN_REMOTES = {
  [IFLA_VXLAN_REMOTE_NEW] = {
    [IFLA_VXLAN_REMOTE_PORT] = ...,
    [IFLA_VXLAN_REMOTE_ADDR] = ...,
  },
  [IFLA_VXLAN_REMOTE_NEW] = {
    ...,
  },
  [IFLA_VXLAN_REMOTE_DEL] = {
    [IFLA_VXLAN_REMOTE_ADDR] = ...,
  },
}

> @@ -1707,6 +1838,24 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
>  	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
>  		goto nla_put_failure;
>  
> +	if (vxlan->remote_cnt) {
> +		struct vxlan_rdst *rdst;
> +		struct nlattr *nest;
> +
> +		nest = nla_nest_start(skb, IFLA_VXLAN_REMOTE_LST);
> +		if (nest == NULL)
> +			goto nla_put_failure;
> +
> +		for (rdst = vxlan->default_dst.remote_next; rdst;
> +		     rdst = rdst->remote_next) {
> +			__be32 ip = rdst->remote_ip;
> +			if (nla_put_be32(skb, IFLA_VXLAN_REMOTE_ADDR, ip))
> +				goto nla_put_failure;


Are you sure that you never want to extend this in the future? What
about providing IFLA_VXLAN_REMOTE_PORT in the future?

I suggest to encode it as:

IFLA_VXLAN_REMOTES = {
  [0] = {
    [IFLA_VXLAN_REMOTE_ADDR] = <ADDR1>
  },
  [1] = {
    [IFLA_VXLAN_REMOTE_ADDR] = <ADDR2>
  }
},

Allowing to extend it to further attributes in the future.

> +enum {
> +	IFLA_VXLAN_REMOTE_UNSPEC,
> +	IFLA_VXLAN_REMOTE_ADDR,
> +	IFLA_VXLAN_REMOTE_IFINDEX,
> +	IFLA_VXLAN_REMOTE_PORT,
> +	IFLA_VXLAN_REMOTE_VNI,
> +	__IFLA_VXLAN_REMOTE_MAX
> +};
> +
> +#define IFLA_VXLAN_REMOTE_MAX	(__IFLA_VXLAN_REMOTE_MAX - 1)

Each of these new attributes must have an struct nla_policy
entry that is enforced.
