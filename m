From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] netlink: add missing length check of rtnl msg
Date: Mon, 25 Mar 2013 23:12:04 +0000
Message-ID: <20130325231204.GC27194@casper.infradead.org>
References: <1364232143-16754-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49028 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab3CYXMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 19:12:07 -0400
Content-Disposition: inline
In-Reply-To: <1364232143-16754-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/13 at 01:22am, Hong Zhiguo wrote:
>  	protocol = TC_H_MIN(t->tcm_info);
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 0bbce22..b30a988 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -977,7 +977,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
>  	struct tcmsg *tcm = nlmsg_data(n);
>  	struct nlattr *tca[TCA_MAX + 1];
>  	struct net_device *dev;
> -	u32 clid = tcm->tcm_parent;
> +	u32 clid;
>  	struct Qdisc *q = NULL;
>  	struct Qdisc *p = NULL;
>  	int err;
> @@ -985,6 +985,9 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
>  	if ((n->nlmsg_type != RTM_GETQDISC) && !capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  
> +	if (nlmsg_len(n) < sizeof(*tcm))
> +		return -EINVAL;
> +
>  	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
>  	if (!dev)
>  		return -ENODEV;

What do you think about moving the nlmsg_parse() call from below here
to before __dev_get_by_index()? It also verifies the header length and
it's how other netlink code verifies the message type specific header
as well.

>  	if (err < 0)
> @@ -1051,6 +1055,9 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
>  	if (!capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  
> +	if (nlmsg_len(n) < sizeof(*tcm))
> +		return -EINVAL;
> +

Same here.

>  replay:
>  	/* Reinit, just in case something touches this. */
>  	tcm = nlmsg_data(n);
> @@ -1382,14 +1389,17 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
>  	const struct Qdisc_class_ops *cops;
>  	unsigned long cl = 0;
>  	unsigned long new_cl;
> -	u32 portid = tcm->tcm_parent;
> -	u32 clid = tcm->tcm_handle;
> -	u32 qid = TC_H_MAJ(clid);
> +	u32 portid;
> +	u32 clid;
> +	u32 qid;
>  	int err;
>  
>  	if ((n->nlmsg_type != RTM_GETTCLASS) && !capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  
> +	if (nlmsg_len(n) < sizeof(*tcm))
> +		return -EINVAL;
> +
>  	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
>  	if (!dev)
>  		return -ENODEV;

And here.
