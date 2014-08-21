From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next v2 2/2] xfrm: configure policy hash table
 thresholds by netlink
Date: Thu, 21 Aug 2014 08:09:44 +0200
Message-ID: <20140821060944.GC6390@secunet.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
 <1406884348-12423-1-git-send-email-christophe.gouault@6wind.com>
 <1406884348-12423-3-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52727 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbaHUGJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2014 02:09:57 -0400
Content-Disposition: inline
In-Reply-To: <1406884348-12423-3-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 01, 2014 at 11:12:28AM +0200, Christophe Gouault wrote:
> diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
> index 41902a8..9da7982 100644
> --- a/include/net/netns/xfrm.h
> +++ b/include/net/netns/xfrm.h
> @@ -19,6 +19,15 @@ struct xfrm_policy_hash {
>  	u8			sbits6;
>  };
>  
> +struct xfrm_policy_hthresh {
> +	struct work_struct	work;
> +	seqlock_t		lock;

This newly introduced lock is not initialized. It triggers an
inconsistent lock state warning when acquired for the first time.

>  
> +static void xfrm_hash_rebuild(struct work_struct *work)
> +{
> +	struct net *net = container_of(work, struct net,
> +				       xfrm.policy_hthresh.work);
> +	unsigned int hmask;
> +	struct xfrm_policy *pol;
> +	struct xfrm_policy *policy;
> +	struct hlist_head *chain;
> +	struct hlist_head *odst;
> +	struct hlist_node *newpos;
> +	int i;
> +	int dir;
> +	unsigned seq;
> +	u8 lbits4, rbits4, lbits6, rbits6;
> +
> +	mutex_lock(&hash_resize_mutex);
> +
> +	/* read selector prefixlen thresholds */
> +	do {
> +		seq = read_seqbegin(&net->xfrm.policy_hthresh.lock);
> +
> +		lbits4 = net->xfrm.policy_hthresh.lbits4;
> +		rbits4 = net->xfrm.policy_hthresh.rbits4;
> +		lbits6 = net->xfrm.policy_hthresh.lbits6;
> +		rbits6 = net->xfrm.policy_hthresh.rbits6;
> +	} while (read_seqretry(&net->xfrm.policy_hthresh.lock, seq));
> +
> +	write_lock_bh(&net->xfrm.xfrm_policy_lock);
> +
> +	pr_info("rebuilding SPD hash table: thresholds (%u,%u)(%u,%u)\n",
> +		lbits4, rbits4, lbits6, rbits6);

Do we really need to print this?

> +
> +	/* reset the bydst and inexact table in all directions */
> +	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
> +		INIT_HLIST_HEAD(&net->xfrm.policy_inexact[dir]);
> +		hmask = net->xfrm.policy_bydst[dir].hmask;
> +		odst = net->xfrm.policy_bydst[dir].table;
> +		for (i = hmask; i >= 0; i--)
> +			INIT_HLIST_HEAD(odst + i);
> +		if ((dir & XFRM_POLICY_MASK) == XFRM_POLICY_OUT) {
> +			/* dir out => dst = remote, src = local */
> +			net->xfrm.policy_bydst[dir].dbits4 = rbits4;
> +			net->xfrm.policy_bydst[dir].sbits4 = lbits4;
> +			net->xfrm.policy_bydst[dir].dbits6 = rbits6;
> +			net->xfrm.policy_bydst[dir].sbits6 = lbits6;
> +		} else {
> +			/* dir in/fwd => dst = local, src = remote */
> +			net->xfrm.policy_bydst[dir].dbits4 = lbits4;
> +			net->xfrm.policy_bydst[dir].sbits4 = rbits4;
> +			net->xfrm.policy_bydst[dir].dbits6 = lbits6;
> +			net->xfrm.policy_bydst[dir].sbits6 = rbits6;
> +		}
> +	}
> +
> +	/* re-insert all policies by order of creation */
> +	list_for_each_entry_reverse(policy, &net->xfrm.policy_all, walk.all) {
> +		newpos = NULL;
> +		chain = policy_hash_bysel(net, &policy->selector,
> +					  policy->family,
> +					  xfrm_policy_id2dir(policy->index));
> +		hlist_for_each_entry(pol, chain, bydst) {
> +			if (policy->priority >= pol->priority)
> +				newpos = &pol->bydst;
> +			else
> +				break;
> +		}
> +		if (newpos)
> +			hlist_add_after(newpos, &policy->bydst);

hlist_add_after() does not exist any more, it was replaced by
hlist_add_behind() recently.

>  
> +static int xfrm_set_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
> +			    struct nlattr **attrs)
> +{
> +	struct net *net = sock_net(skb->sk);
> +	struct sk_buff *r_skb;
> +	u32 *flags = nlmsg_data(nlh);
> +	u32 sportid = NETLINK_CB(skb).portid;
> +	u32 seq = nlh->nlmsg_seq;
> +	struct xfrmu_spdhthresh *thresh4 = NULL;
> +	struct xfrmu_spdhthresh *thresh6 = NULL;
> +
> +	/* selector prefixlen thresholds to hash policies */
> +	if (attrs[XFRMA_SPD_IPV4_HTHRESH]) {
> +		struct nlattr *rta = attrs[XFRMA_SPD_IPV4_HTHRESH];
> +
> +		if (nla_len(rta) < sizeof(*thresh4))
> +			return -EINVAL;
> +		thresh4 = nla_data(rta);
> +		if (thresh4->lbits > 32 || thresh4->rbits > 32)
> +			return -EINVAL;
> +	}
> +	if (attrs[XFRMA_SPD_IPV6_HTHRESH]) {
> +		struct nlattr *rta = attrs[XFRMA_SPD_IPV6_HTHRESH];
> +
> +		if (nla_len(rta) < sizeof(*thresh6))
> +			return -EINVAL;
> +		thresh6 = nla_data(rta);
> +		if (thresh6->lbits > 128 || thresh6->rbits > 128)
> +			return -EINVAL;
> +	}
> +
> +	if (thresh4 || thresh6) {
> +		write_seqlock(&net->xfrm.policy_hthresh.lock);
> +		if (thresh4) {
> +			net->xfrm.policy_hthresh.lbits4 = thresh4->lbits;
> +			net->xfrm.policy_hthresh.rbits4 = thresh4->rbits;
> +		}
> +		if (thresh6) {
> +			net->xfrm.policy_hthresh.lbits6 = thresh6->lbits;
> +			net->xfrm.policy_hthresh.rbits6 = thresh6->rbits;
> +		}
> +		write_sequnlock(&net->xfrm.policy_hthresh.lock);
> +
> +		xfrm_policy_hash_rebuild(net);
> +	}
> +
> +	r_skb = nlmsg_new(xfrm_spdinfo_msgsize(), GFP_ATOMIC);
> +	if (r_skb == NULL)
> +		return -ENOMEM;
> +
> +	if (build_spdinfo(r_skb, net, sportid, seq, *flags) < 0)
> +		BUG();
> +
> +	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);

Why do you send these informations to userspace? This is a set
operation, not get.


The rest looks quite good, thanks!
