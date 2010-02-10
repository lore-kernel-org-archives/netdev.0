From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and
 devices (v3)
Date: Wed, 10 Feb 2010 13:20:19 -0600
Message-ID: <20100210192019.GA18879@us.ibm.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
 <1265750713-15749-3-git-send-email-danms@us.ibm.com>
 <87ljf1gemh.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:40428 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751804Ab0BJTU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 14:20:27 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1AJGdPM009197
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 14:16:39 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1AJKLEP137114
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 14:20:21 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1AJKKQ8010040
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 17:20:21 -0200
Content-Disposition: inline
In-Reply-To: <87ljf1gemh.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> Guilt dropped the new checkpoint_dev.c file when I switched to the
> newer branch.  Sorry about that.  Updated patch included below.

(Just a few comments on a cursory look.  Will take a closer look
later)

> +int ckpt_netdev_inet_addrs(struct in_device *indev,
> +			   struct ckpt_netdev_addr *_abuf[])
> +{
> +	struct ckpt_netdev_addr *abuf = NULL;
> +	struct in_ifaddr *addr = indev->ifa_list;
> +	int pages = 0;
> +	int addrs = 0;
> +	int max;
> +
> +	read_lock(&dev_base_lock);
> + retry:
> +	if (++pages > 4) {
> +		addrs = -ENOMEM;
> +		goto out;
> +	}
> +
> +	*_abuf = krealloc(abuf, PAGE_SIZE * pages, GFP_KERNEL);

rw_lockt is effectively a spinlock, so I don't think you can sleep
here.

> +	if (*_abuf == NULL) {
> +		addrs = -ENOMEM;
> +		goto out;
> +	}
> +	abuf = *_abuf;
> +
> +	max = (pages * PAGE_SIZE) / sizeof(*abuf);
> +	while (addr) {
> +		abuf[addrs].type = CKPT_NETDEV_ADDR_IPV4; /* Only IPv4 now */
> +		abuf[addrs].inet4_local = addr->ifa_local;
> +		abuf[addrs].inet4_address = addr->ifa_address;
> +		abuf[addrs].inet4_mask = addr->ifa_mask;
> +		abuf[addrs].inet4_broadcast = addr->ifa_broadcast;
> +
> +		addr = addr->ifa_next;
> +		if (++addrs >= max)
> +			goto retry;
> +	}
> +
> + out:
> +	read_unlock(&dev_base_lock);
> +
> +	if (addrs < 0) {
> +		kfree(abuf);
> +		*_abuf = NULL;
> +	}
> +
> +	return addrs;
> +}
> +
> +struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
> +					 struct net_device *dev,
> +					 struct ckpt_netdev_addr *addrs[])
> +{
> +	struct ckpt_hdr_netdev *h;
> +	int ret;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NETDEV);
> +	if (!h)
> +		return ERR_PTR(-ENOMEM);
> +
> +	ret = ckpt_netdev_hwaddr(dev, h);
> +	if (ret < 0)
> +		goto out;
> +
> +	*addrs = NULL;
> +	ret = h->inet_addrs = ckpt_netdev_inet_addrs(dev->ip_ptr, addrs);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = h->netns_ref = checkpoint_obj(ctx, dev->nd_net, CKPT_OBJ_NET_NS);
> + out:
> +	if (ret < 0) {
> +		ckpt_hdr_put(ctx, h);
> +		h = ERR_PTR(ret);
> +		if (*addrs)
> +			kfree(*addrs);
> +	}
> +
> +	return h;
> +}
> +
> +int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	struct net_device *dev = (struct net_device *)ptr;
> +
> +	if (!dev->netdev_ops->ndo_checkpoint)
> +		return -EINVAL;
> +
> +	ckpt_debug("checkpointing netdev %s\n", dev->name);
> +
> +	return dev->netdev_ops->ndo_checkpoint(ctx, dev);
> +}
> +
> +int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	struct net *net = ptr;
> +	struct net_device *dev;
> +	struct ckpt_hdr_netns *h;
> +	int ret;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NET_NS);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->this_ref = ckpt_obj_lookup(ctx, net, CKPT_OBJ_NET_NS);
> +	BUG_ON(h->this_ref == 0);
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	for_each_netdev(net, dev) {
> +		if (!dev->netdev_ops->ndo_checkpoint)
> +			continue;

Won't the checkpoint_obj() call checkpoint_netdev(), which will return
-EINVAL if ndo_checkpoint is not defined?  But here you skip the
checkpoint_obj() call (which seems wrong to me).  Which do you want to
have happen?

> +		ret = checkpoint_obj(ctx, dev, CKPT_OBJ_NETDEV);
> +		if (ret < 0)
> +			break;
> +	}
> + out:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}
> +
> +static int restore_in_addrs(struct ckpt_ctx *ctx,
> +			    __u32 naddrs,
> +			    struct net *net,
> +			    struct net_device *dev)
> +{
> +	__u32 i;
> +	int ret = 0;
> +	int len = naddrs * sizeof(struct ckpt_netdev_addr);
> +	struct ckpt_netdev_addr *addrs = NULL;
> +
> +	addrs = kmalloc(len, GFP_KERNEL);
> +	if (!addrs)
> +		return -ENOMEM;
> +
> +	ret = _ckpt_read_buffer(ctx, addrs, len);
> +	if (ret < 0)
> +		goto out;
> +
> +	for (i = 0; i < naddrs; i++) {
> +		struct ckpt_netdev_addr *addr = &addrs[i];
> +		struct ifreq req;
> +		struct sockaddr_in *inaddr;
> +
> +		if (addr->type != CKPT_NETDEV_ADDR_IPV4) {
> +			ret = -EINVAL;
> +			ckpt_err(ctx, ret, "Unsupported netdev addr type %i\n",
> +				 addr->type);
> +			break;
> +		}
> +
> +		ckpt_debug("restoring %s: %x/%x/%x\n", dev->name,
> +			   addr->inet4_address,
> +			   addr->inet4_mask,
> +			   addr->inet4_broadcast);
> +
> +		memcpy(req.ifr_name, dev->name, IFNAMSIZ);
> +
> +		inaddr = (struct sockaddr_in *)&req.ifr_addr;
> +		inaddr->sin_addr.s_addr = addr->inet4_address;
> +		inaddr->sin_family = AF_INET;
> +		ret = __kern_devinet_ioctl(net, SIOCSIFADDR, &req);
> +		if (ret < 0) {
> +			ckpt_err(ctx, ret, "Failed to set address\n");
> +			break;
> +		}
> +
> +		inaddr = (struct sockaddr_in *)&req.ifr_addr;
> +		inaddr->sin_addr.s_addr = addr->inet4_mask;
> +		inaddr->sin_family = AF_INET;
> +		ret = __kern_devinet_ioctl(net, SIOCSIFNETMASK, &req);
> +		if (ret < 0) {
> +			ckpt_err(ctx, ret, "Failed to set netmask\n");
> +			break;
> +		}
> +
> +		inaddr = (struct sockaddr_in *)&req.ifr_addr;
> +		inaddr->sin_addr.s_addr = addr->inet4_broadcast;
> +		inaddr->sin_family = AF_INET;
> +		ret = __kern_devinet_ioctl(net, SIOCSIFBRDADDR, &req);
> +		if (ret < 0) {
> +			ckpt_err(ctx, ret, "Failed to set broadcast\n");
> +			break;
> +		}
> +	}
> +
> + out:
> +	kfree(addrs);
> +
> +	return ret;
> +}
> +
> +static int veth_peer_data(struct sk_buff *skb, char *peer_name)
> +{
> +	struct nlattr *linkdata;
> +	struct ifinfomsg ifm;
> +
> +	linkdata = nla_nest_start(skb, IFLA_INFO_DATA);
> +	if (!linkdata)
> +		return -ENOMEM;
> +
> +	nla_put(skb, VETH_INFO_PEER, sizeof(ifm), &ifm);
> +	nla_put_string(skb, IFLA_IFNAME, peer_name);
> +
> +	nla_nest_end(skb, linkdata);
> +
> +	return 0;
> +}
> +
> +static struct sk_buff *new_link_message(char *this_name, char *peer_name)
> +{
> +	int ret = -ENOMEM;
> +	int flags = NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
> +	struct nlmsghdr *nlh;
> +	struct sk_buff *skb;
> +	struct ifinfomsg *ifm;
> +	struct nlattr *linkinfo;
> +
> +	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (!skb)
> +		goto out;
> +
> +	nlh = nlmsg_put(skb, 0, 0, RTM_NEWLINK, sizeof(*ifm), flags);
> +	if (!nlh)
> +		goto out;
> +
> +	ifm = nlmsg_data(nlh);
> +	memset(ifm, 0, sizeof(*ifm));
> +
> +	ret = nla_put_string(skb, IFLA_IFNAME, this_name);
> +	if (ret)
> +		goto out;
> +
> +	ret = -ENOMEM;
> +
> +	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
> +	if (!linkinfo)
> +		goto out;
> +
> +	if (nla_put_string(skb, IFLA_INFO_KIND, "veth") < 0)
> +		goto out;
> +
> +	ret = veth_peer_data(skb, peer_name);

By hard-coding veth stuff into generic-sounding functions in
net/checkpoint_dev.c you seem to be assuming that only veth will
ever be supported for checkpoint/restart?  what about macvlan?
(Not to mention that eventually we intend to support moving
physical nics into containers)

-serge
