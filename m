From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch net-next 1/2] rtnetlink: allow to register ops without ops->setup set
Date: Wed, 25 Jun 2014 08:55:02 -0700
Message-ID: <87tx79vvah.fsf@x220.int.ebiederm.org>
References: <1403699280-12837-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	cwang@twopensource.com, nicolas.dichtel@6wind.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:49571 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757033AbaFYP6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 11:58:20 -0400
In-Reply-To: <1403699280-12837-1-git-send-email-jiri@resnulli.us> (Jiri
	Pirko's message of "Wed, 25 Jun 2014 14:27:59 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

> So far, it is assumed that ops->setup is filled up. But there might be
> case that ops might make sense even without ->setup. In that case,
> forbid to newlink and dellink.

This patch does not handle all cases of dellink, and so you have created
a way to oops the kernel.  One case that is not handled is
default_device_exit_batch.

Further using !setup to prevent dellink does not make any kind of
logical sense.  Which leads to a maintenance hazard.  Aka how can we
further update this code without running into weird corner cases.

Further you have not given a description why anyone would want to have
something that is almost completely unlike rtnl link operations
implemented with the rtnl link operations.


> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/core/rtnetlink.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 1063996..84affd7 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1777,7 +1777,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
>  		return -ENODEV;
>  
>  	ops = dev->rtnl_link_ops;
> -	if (!ops)
> +	if (!ops || !ops->setup)
>  		return -EOPNOTSUPP;
>  
>  	ops->dellink(dev, &list_kill);
> @@ -2038,6 +2038,9 @@ replay:
>  			return -EOPNOTSUPP;
>  		}
>  
> +		if (!ops->setup)
> +			return -EOPNOTSUPP;
> +
>  		if (!ifname[0])
>  			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);
