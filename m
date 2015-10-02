From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v2] net: Add support for filtering neigh dump by master device
Date: Fri, 02 Oct 2015 12:18:51 -0500
Message-ID: <87h9m9tchw.fsf@x220.int.ebiederm.org>
References: <1443544323-13242-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54521 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbbJBR0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 13:26:19 -0400
In-Reply-To: <1443544323-13242-1-git-send-email-dsa@cumulusnetworks.com>
	(David Ahern's message of "Tue, 29 Sep 2015 09:32:03 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> Add support for filtering neighbor dumps by master device by adding
> the NDA_MASTER attribute to the dump request. A new netlink flag,
> NLM_F_DUMP_FILTERED, is added to indicate the kernel supports the
> request and output is filtered as requested.

*Scratches my head*

I thought you only wanted L3 functionality, and that you did not want a
network namespace.

What is the thinking here because it sure looks like you are busily
adding layer two functionality you swore you did not want.

Eric

> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - added NLM_F_DUMP_FILTERED flag for userspace feedback that request is
>   supported
>
> This method works for other filters as well and other dump commands.
> Works fine for all combinations of new and old kernel and new and old ip:
> 1. new ip command on old kernel, NDA_MASTER attribute is ignored
> 2. old ip command on new kernel, NDA_MASTER attribute is not present
> 3. new ip on new kernel ... goodness ensues by limiting data to
>    only what user wants
>
>  include/uapi/linux/netlink.h |  1 +
>  net/core/neighbour.c         | 32 +++++++++++++++++++++++++++++++-
>  2 files changed, 32 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
> index 6f3fe16cd22a..f095155d8749 100644
> --- a/include/uapi/linux/netlink.h
> +++ b/include/uapi/linux/netlink.h
> @@ -54,6 +54,7 @@ struct nlmsghdr {
>  #define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
>  #define NLM_F_ECHO		8	/* Echo this request 		*/
>  #define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
> +#define NLM_F_DUMP_FILTERED	32	/* Dump was filtered as requested */
>  
>  /* Modifiers to GET request */
>  #define NLM_F_ROOT	0x100	/* specify tree	root	*/
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 2b515ba7e94f..8c57fdf4d68e 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -2235,14 +2235,42 @@ static void neigh_update_notify(struct neighbour *neigh)
>  	__neigh_notify(neigh, RTM_NEWNEIGH, 0);
>  }
>  
> +static bool neigh_master_filtered(struct net_device *dev, int master_idx)
> +{
> +	struct net_device *master;
> +
> +	if (!master_idx)
> +		return false;
> +
> +	master = netdev_master_upper_dev_get(dev);
> +	if (!master || master->ifindex != master_idx)
> +		return true;
> +
> +	return false;
> +}
> +
>  static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
>  			    struct netlink_callback *cb)
>  {
>  	struct net *net = sock_net(skb->sk);
> +	const struct nlmsghdr *nlh = cb->nlh;
> +	struct nlattr *tb[NDA_MAX + 1];
>  	struct neighbour *n;
>  	int rc, h, s_h = cb->args[1];
>  	int idx, s_idx = idx = cb->args[2];
>  	struct neigh_hash_table *nht;
> +	int filter_master_idx = 0;
> +	unsigned int flags = NLM_F_MULTI;
> +	int err;
> +
> +	err = nlmsg_parse(nlh, sizeof(struct ndmsg), tb, NDA_MAX, NULL);
> +	if (!err) {
> +		if (tb[NDA_MASTER])
> +			filter_master_idx = nla_get_u32(tb[NDA_MASTER]);
> +
> +		if (filter_master_idx)
> +			flags |= NLM_F_DUMP_FILTERED;
> +	}
>  
>  	rcu_read_lock_bh();
>  	nht = rcu_dereference_bh(tbl->nht);
> @@ -2255,12 +2283,14 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
>  		     n = rcu_dereference_bh(n->next)) {
>  			if (!net_eq(dev_net(n->dev), net))
>  				continue;
> +			if (neigh_master_filtered(n->dev, filter_master_idx))
> +				continue;
>  			if (idx < s_idx)
>  				goto next;
>  			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
>  					    cb->nlh->nlmsg_seq,
>  					    RTM_NEWNEIGH,
> -					    NLM_F_MULTI) < 0) {
> +					    flags) < 0) {
>  				rc = -1;
>  				goto out;
>  			}
