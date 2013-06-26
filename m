From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] ipv6,mcast: always hold idev->lock before mca_lock
Date: Thu, 27 Jun 2013 00:58:09 +0200
Message-ID: <20130626225809.GB26180@order.stressinduktion.org>
References: <1367998914-26423-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, dingtianhong <dingtianhong@huawei.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40102 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233Ab3FZW6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:58:11 -0400
Content-Disposition: inline
In-Reply-To: <1367998914-26423-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 08, 2013 at 03:41:54PM +0800, Cong Wang wrote:
> dingtianhong reported the following deadlock detected by lockdep:
> 
>  ======================================================
>  [ INFO: possible circular locking dependency detected ]
>  3.4.24.05-0.1-default #1 Not tainted
>  -------------------------------------------------------
>  ksoftirqd/0/3 is trying to acquire lock:
>   (&ndev->lock){+.+...}, at: [<ffffffff8147f804>] ipv6_get_lladdr+0x74/0x120
> 
>  but task is already holding lock:
>   (&mc->mca_lock){+.+...}, at: [<ffffffff8149d130>] mld_send_report+0x40/0x150
> 
>  which lock already depends on the new lock.
> 
> 
>  the existing dependency chain (in reverse order) is:
> 
>  -> #1 (&mc->mca_lock){+.+...}:
>         [<ffffffff810a8027>] validate_chain+0x637/0x730
>         [<ffffffff810a8417>] __lock_acquire+0x2f7/0x500
>         [<ffffffff810a8734>] lock_acquire+0x114/0x150
>         [<ffffffff814f691a>] rt_spin_lock+0x4a/0x60
>         [<ffffffff8149e4bb>] igmp6_group_added+0x3b/0x120
>         [<ffffffff8149e5d8>] ipv6_mc_up+0x38/0x60
>         [<ffffffff81480a4d>] ipv6_find_idev+0x3d/0x80
>         [<ffffffff81483175>] addrconf_notify+0x3d5/0x4b0
>         [<ffffffff814fae3f>] notifier_call_chain+0x3f/0x80
>         [<ffffffff81073471>] raw_notifier_call_chain+0x11/0x20
>         [<ffffffff813d8722>] call_netdevice_notifiers+0x32/0x60
>         [<ffffffff813d92d4>] __dev_notify_flags+0x34/0x80
>         [<ffffffff813d9360>] dev_change_flags+0x40/0x70
>         [<ffffffff813ea627>] do_setlink+0x237/0x8a0
>         [<ffffffff813ebb6c>] rtnl_newlink+0x3ec/0x600
>         [<ffffffff813eb4d0>] rtnetlink_rcv_msg+0x160/0x310
>         [<ffffffff814040b9>] netlink_rcv_skb+0x89/0xb0
>         [<ffffffff813eb357>] rtnetlink_rcv+0x27/0x40
>         [<ffffffff81403e20>] netlink_unicast+0x140/0x180
>         [<ffffffff81404a9e>] netlink_sendmsg+0x33e/0x380
>         [<ffffffff813c4252>] sock_sendmsg+0x112/0x130
>         [<ffffffff813c537e>] __sys_sendmsg+0x44e/0x460
>         [<ffffffff813c5544>] sys_sendmsg+0x44/0x70
>         [<ffffffff814feab9>] system_call_fastpath+0x16/0x1b
> 
>  -> #0 (&ndev->lock){+.+...}:
>         [<ffffffff810a798e>] check_prev_add+0x3de/0x440
>         [<ffffffff810a8027>] validate_chain+0x637/0x730
>         [<ffffffff810a8417>] __lock_acquire+0x2f7/0x500
>         [<ffffffff810a8734>] lock_acquire+0x114/0x150
>         [<ffffffff814f6c82>] rt_read_lock+0x42/0x60
>         [<ffffffff8147f804>] ipv6_get_lladdr+0x74/0x120
>         [<ffffffff8149b036>] mld_newpack+0xb6/0x160
>         [<ffffffff8149b18b>] add_grhead+0xab/0xc0
>         [<ffffffff8149d03b>] add_grec+0x3ab/0x460
>         [<ffffffff8149d14a>] mld_send_report+0x5a/0x150
>         [<ffffffff8149f99e>] igmp6_timer_handler+0x4e/0xb0
>         [<ffffffff8105705a>] call_timer_fn+0xca/0x1d0
>         [<ffffffff81057b9f>] run_timer_softirq+0x1df/0x2e0
>         [<ffffffff8104e8c7>] handle_pending_softirqs+0xf7/0x1f0
>         [<ffffffff8104ea3b>] __do_softirq_common+0x7b/0xf0
>         [<ffffffff8104f07f>] __thread_do_softirq+0x1af/0x210
>         [<ffffffff8104f1c1>] run_ksoftirqd+0xe1/0x1f0
>         [<ffffffff8106c7de>] kthread+0xae/0xc0
>         [<ffffffff814fff74>] kernel_thread_helper+0x4/0x10
> 
> actually we can just hold idev->lock before taking pmc->mca_lock,
> and avoid taking idev->lock again when iterating idev->addr_list.
> 
> Reported-by: dingtianhong <dingtianhong@huawei.com>
> Cc: dingtianhong <dingtianhong@huawei.com>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Is someone still working on this issue?

> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1448,6 +1448,23 @@ try_nextdev:
>  }
>  EXPORT_SYMBOL(ipv6_dev_get_saddr);
>  
> +int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
> +		      unsigned char banned_flags)
> +{
> +	int err = -EADDRNOTAVAIL;
> +	struct inet6_ifaddr *ifp;
> +
> +	list_for_each_entry(ifp, &idev->addr_list, if_list) {
> +		if (ifp->scope == IFA_LINK &&
> +		    !(ifp->flags & banned_flags)) {
> +			*addr = ifp->addr;
> +			err = 0;
> +			break;
> +		}
> +	}
> +	return err;
> +}
> +

I added this function in net-next commit b7b1bfc ("ipv6: split duplicate
address detection and router solicitation timer"), so a rebase would
be needed (and it should be exported).

> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index bfa6cc3..c3998c2 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1343,8 +1343,9 @@ static void ip6_mc_hdr(struct sock *sk, struct sk_buff *skb,
>  	hdr->daddr = *daddr;
>  }
>  
> -static struct sk_buff *mld_newpack(struct net_device *dev, int size)
> +static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
>  {
> +	struct net_device *dev = idev->dev;
>  	struct net *net = dev_net(dev);
>  	struct sock *sk = net->ipv6.igmp_sk;
>  	struct sk_buff *skb;
> @@ -1369,7 +1370,7 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
>  
>  	skb_reserve(skb, hlen);
>  
> -	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
> +	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
>  		/* <draft-ietf-magma-mld-source-05.txt>:
>  		 * use unspecified address as the source address
>  		 * when a valid link-local address is not available.
> @@ -1465,7 +1466,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
>  	struct mld2_grec *pgr;
>  
>  	if (!skb)
> -		skb = mld_newpack(dev, dev->mtu);
> +		skb = mld_newpack(pmc->idev, dev->mtu);
>  	if (!skb)
>  		return NULL;
>  	pgr = (struct mld2_grec *)skb_put(skb, sizeof(struct mld2_grec));
> @@ -1485,7 +1486,8 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
>  static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
>  	int type, int gdeleted, int sdeleted)
>  {
> -	struct net_device *dev = pmc->idev->dev;
> +	struct inet6_dev *idev = pmc->idev;
> +	struct net_device *dev = idev->dev;
>  	struct mld2_report *pmr;
>  	struct mld2_grec *pgr = NULL;
>  	struct ip6_sf_list *psf, *psf_next, *psf_prev, **psf_list;
> @@ -1514,7 +1516,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
>  		    AVAILABLE(skb) < grec_size(pmc, type, gdeleted, sdeleted)) {
>  			if (skb)
>  				mld_sendpack(skb);
> -			skb = mld_newpack(dev, dev->mtu);
> +			skb = mld_newpack(idev, dev->mtu);
>  		}
>  	}
>  	first = 1;
> @@ -1541,7 +1543,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
>  				pgr->grec_nsrcs = htons(scount);
>  			if (skb)
>  				mld_sendpack(skb);
> -			skb = mld_newpack(dev, dev->mtu);
> +			skb = mld_newpack(idev, dev->mtu);
>  			first = 1;
>  			scount = 0;
>  		}
> @@ -1596,8 +1598,8 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
>  	struct sk_buff *skb = NULL;
>  	int type;
>  
> +	read_lock_bh(&idev->lock);
>  	if (!pmc) {
> -		read_lock_bh(&idev->lock);
>  		for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
>  			if (pmc->mca_flags & MAF_NOREPORT)
>  				continue;
> @@ -1609,7 +1611,6 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
>  			skb = add_grec(skb, pmc, type, 0, 0);
>  			spin_unlock_bh(&pmc->mca_lock);
>  		}
> -		read_unlock_bh(&idev->lock);
>  	} else {
>  		spin_lock_bh(&pmc->mca_lock);
>  		if (pmc->mca_sfcount[MCAST_EXCLUDE])
> @@ -1619,6 +1620,7 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
>  		skb = add_grec(skb, pmc, type, 0, 0);
>  		spin_unlock_bh(&pmc->mca_lock);
>  	}
> +	read_unlock_bh(&idev->lock);
>  	if (skb)
>  		mld_sendpack(skb);
>  }

I do confirm that if this last hunk is applied the idev->addr_list traversal
is safe.

Please let me know if no one is working on this, I would rebase it then.

Thanks,

  Hannes
