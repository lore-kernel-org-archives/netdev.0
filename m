From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] vrf: Add ip rules at vrf device create
Date: Tue, 8 Dec 2015 12:54:50 +0100
Message-ID: <5666C50A.5080409@cumulusnetworks.com>
References: <1449546920-8617-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:33183 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932632AbbLHLyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 06:54:53 -0500
Received: by wmec201 with SMTP id c201so208868982wme.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 03:54:52 -0800 (PST)
In-Reply-To: <1449546920-8617-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
On 12/08/2015 04:55 AM, David Ahern wrote:
[snip]
>  
> +static inline size_t vrf_fib_rule_nl_size(bool have_pref)
> +{
> +	size_t sz;
> +
> +	sz = NLMSG_ALIGN(sizeof(struct fib_rule_hdr))
> +			 + nla_total_size(IFNAMSIZ) /* FRA_{I,O}IFNAME */
> +			 + nla_total_size(4); /* FRA_TABLE, u32 */
directly use sizeof(u32) and remove it from the comment ?

> +
> +	if (have_pref)
> +		sz += nla_total_size(4); /* FRA_PRIORITY, u32 */
Why not always add this to the size and remove the whole have_pref and sz ?

> +
> +	return sz;
> +}
> +
> +static int vrf_fib_rule(struct net_device *dev, __u8 family, int if_type,
> +			bool add_it)
I think dev can be constified.

> +{
> +	struct net_vrf *vrf = netdev_priv(dev);
vrf is only read and can be const

> +	struct fib_rule_hdr *frh;
> +	struct nlmsghdr *nlh;
> +	struct sk_buff *skb;
> +	int err;
> +
> +	skb = nlmsg_new(vrf_fib_rule_nl_size(!!vrf->pref), GFP_KERNEL);
> +	if (!skb)
> +		return -ENOMEM;
> +
> +	nlh = nlmsg_put(skb, 0, 0, 0, sizeof(*frh), 0);
> +	if (!nlh)
> +		return -EMSGSIZE;
Looks like the skb will be leaked here because nlmsg_put() doesn't free it.
In fact I can see this error in other places throughout the stack (probably
c&p errors), good that it's not supposed to happen. :-)

> +
> +	frh = nlmsg_data(nlh);
> +	memset(frh, 0, sizeof(*frh));
> +	frh->family = family;
> +	frh->action = FR_ACT_TO_TBL;
> +
> +	if (nla_put_u32(skb, FRA_TABLE, vrf->tb_id))
> +		goto nla_put_failure;
> +
> +	if (nla_put_string(skb, if_type, dev->name))
> +		goto nla_put_failure;
> +
> +	if (vrf->pref) {
> +		if (nla_put_u32(skb, FRA_PRIORITY, vrf->pref))
> +			goto nla_put_failure;
> +	}
> +
> +	nlmsg_end(skb, nlh);
> +
> +	/* fib_nl_{new,del}rule handling looks for net from skb->sk */
> +	skb->sk = dev_net(dev)->rtnl;
> +	if (add_it) {
> +		err = fib_nl_newrule(skb, nlh);
> +	} else {
> +		err = fib_nl_delrule(skb, nlh);
> +		if (err == -ENOENT)
> +			err = 0;
> +	}
> +
> +	kfree_skb(skb);
minor nit: instead of kfree_skb(), you can use nlmsg_free() which currently
does the same, but would be clearer that this is the nlmsg skb.

> +
> +	return err;
> +
> +nla_put_failure:
> +	nlmsg_cancel(skb, nlh);

Here you'll leak the skb, nlmsg_cancel() only trims it and removes
the message, but doesn't free the skb.

> +	return -EMSGSIZE;
> +}
> +
> +static void vrf_del_fib_rules(struct net_device *dev)
Same here for dev (const)

> +{
> +	if (vrf_fib_rule(dev, AF_INET,  FRA_IIFNAME, 0) ||
> +	    vrf_fib_rule(dev, AF_INET,  FRA_OIFNAME, 0) ||
> +	    vrf_fib_rule(dev, AF_INET6, FRA_IIFNAME, 0) ||
> +	    vrf_fib_rule(dev, AF_INET6, FRA_OIFNAME, 0)) {
> +		netdev_err(dev, "Failed to delete FIB rules for %s\n",
> +			   dev->name);

I've seen this use of netdev_err() elsewhere in vrf, too. I was going to
send a patch to change it because you get messages like:
<dev name>: Failed to add FIB rules for <dev name>
which is pointless. You can just drop the extra dev->name.

> +	}
> +}
> +
> +static int vrf_add_fib_rules(struct net_device *dev)
Same here for dev (const)

> +{
> +	int err;
> +
> +	err = vrf_fib_rule(dev, AF_INET,  FRA_IIFNAME, 1);
> +	if (err < 0)
> +		goto out_err;
> +
> +	err = vrf_fib_rule(dev, AF_INET,  FRA_OIFNAME, 1);
> +	if (err < 0)
> +		goto out_err;
> +
> +	err = vrf_fib_rule(dev, AF_INET6, FRA_IIFNAME, 1);
> +	if (err < 0)
> +		goto out_err;
> +
> +	err = vrf_fib_rule(dev, AF_INET6, FRA_OIFNAME, 1);
> +	if (err < 0)
> +		goto out_err;
> +
> +	return 0;
> +out_err:
> +	netdev_err(dev, "Failed to add FIB rules for %s\n", dev->name);
Same here for dev->name

> +	vrf_del_fib_rules(dev);
> +	return err;
> +}
> +
[snip]
