From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] driver: vrf: Fix one possible use-after-free
 issue
Date: Tue, 09 May 2017 14:37:36 -0400 (EDT)
Message-ID: <20170509.143736.1436700294491473750.davem@davemloft.net>
References: <1494325653-39885-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com, fw@strlen.de,
        netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59710 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750805AbdEIShi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 14:37:38 -0400
In-Reply-To: <1494325653-39885-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Tue,  9 May 2017 18:27:33 +0800

> @@ -989,6 +989,7 @@ static u32 vrf_fib_table(const struct net_device *dev)
>  
>  static int vrf_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
>  {
> +	kfree_skb(skb);
>  	return 0;
>  }
>  
> @@ -998,7 +999,7 @@ static struct sk_buff *vrf_rcv_nfhook(u8 pf, unsigned int hook,
>  {
>  	struct net *net = dev_net(dev);
>  
> -	if (NF_HOOK(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) < 0)
> +	if (nf_hook(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) != 1)
>  		skb = NULL;    /* kfree_skb(skb) handled by nf code */
>  
>  	return skb;

Indeed, this fixes the immediate problem with NF_STOLEN.

Making NF_STOLEN fully functional is another story, we'd need to stack
this all together properly:

static int __ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
{
 ...
}

static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
{
	return l3mdev_ip_rcv(skb, __ip_rcv_finish);
}
...
static inline
struct sk_buff *l3mdev_ip_rcv(struct sk_buff *skb,
			      int (*okfn)(struct net *, struct sock *, struct sk_buff *))
{
	return l3mdev_l3_rcv(skb, okfn, AF_INET);
}

etc. but that's going to really add a kink to the receive path,
microbenchmark wise.
