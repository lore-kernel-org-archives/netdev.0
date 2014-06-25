From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch net-next v2 1/2] rtnetlink: allow to register ops without ops->setup set
Date: Wed, 25 Jun 2014 10:16:59 -0700
Message-ID: <87ha38vrhw.fsf@x220.int.ebiederm.org>
References: <1403715503-9059-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	cwang@twopensource.com, nicolas.dichtel@6wind.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:55087 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757441AbaFYRUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 13:20:14 -0400
In-Reply-To: <1403715503-9059-1-git-send-email-jiri@resnulli.us> (Jiri Pirko's
	message of "Wed, 25 Jun 2014 18:58:22 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

> So far, it is assumed that ops->setup is filled up. But there might be
> case that ops might make sense even without ->setup. In that case,
> forbid to newlink and dellink.
>
> This allows to register simple rtnl link ops containing only ->kind.
> That allows consistent way of passing device kind (either device-kind or
> slave-kind) to userspace.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

This is absolutely unmaintainable.  You can't even write the patch
correctly when specific problems are pointed out I can't imagine anyone
else will be able to cope.

As it happens default_device_exit_batch is more broken with this version
of your patch.

> ---
>
> v1->v2: included comments from Eric fixing default_device_exit_batch,
> 	not checking setup in dellink and added hopefully clearer description
> 	and comment.
>
>  net/core/rtnetlink.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 1063996..27acaf7 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -299,7 +299,12 @@ int __rtnl_link_register(struct rtnl_link_ops *ops)
>  	if (rtnl_link_ops_get(ops->kind))
>  		return -EEXIST;
>  
> -	if (!ops->dellink)
> +	/* The check for setup is here because if ops
> +	 * does not have that filled up, it is not possible
> +	 * to use the ops for creating device. So do not
> +	 * fill up dellink as well. That disables rtnl_dellink.
> +	 */
> +	if (ops->setup && !ops->dellink)
>  		ops->dellink = unregister_netdevice_queue;
>  
>  	list_add_tail(&ops->list, &link_ops);
> @@ -1777,7 +1782,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
>  		return -ENODEV;
>  
>  	ops = dev->rtnl_link_ops;
> -	if (!ops)
> +	if (!ops || !ops->dellink)
>  		return -EOPNOTSUPP;
>  
>  	ops->dellink(dev, &list_kill);
> @@ -2038,6 +2043,9 @@ replay:
>  			return -EOPNOTSUPP;
>  		}
>  
> +		if (!ops->setup)
> +			return -EOPNOTSUPP;
> +
>  		if (!ifname[0])
>  			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);
