From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
Date: Thu, 18 Mar 2010 18:22:00 +0100
Message-ID: <4BA26138.6070709@trash.net>
References: <20100316232247.4185.19426.stgit@decadence> <20100316232957.4185.46217.stgit@decadence> <4BA0F4C0.8050901@trash.net> <4BA10095.2030905@netfilter.org> <4BA22463.6050601@trash.net> <4BA25612.3080804@netfilter.org> <4BA258F6.1050909@trash.net> <4BA25C82.7000301@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53029 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458Ab0CRRWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 13:22:03 -0400
In-Reply-To: <4BA25C82.7000301@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>>> Currently, no matter if NETLINK_RECV_NO_ENOBUFS is set or not: if we
>>> fail to allocate the netlink message, then ctnetlink_conntrack_event()
>>> returns 0. Thus, we report ENOBUFS to user-space and we lose the event.
>>>
>>> With my patches, if NETLINK_RECV_NO_ENOBUFS is set and we fail to
>>> allocate the message, we don't report ENOBUFS and we don't lose the event.
>> That last part is what keeps confusing me. With your patch, if the
>> ENOBUFS options is set, we don't report the error to userspace
>> and therefore don't return it to conntrack, thus we *do* loose the
>> event. Which is correct however.
> 
> Sorry, I'm being a bit imprecise myself: we do lose the event anyway.
> However, with my patch, if the NO_ENOBUFS option is set, we keep the
> event in the ctevent cache, so we can try to deliver it again with the
> next packet (this is what I initially meant with "we don't lose the
> event", yes, confusing...).

That still doesn't make sense. The NO_ENOBUFS option *surpresses*
errors, so conntrack assumes success and we *don't* keep it in the
cache. Look:

Patch 1:

> @@ -1104,8 +1104,12 @@ static inline int do_one_set_err(struct sock *sk,
>  	    !test_bit(p->group - 1, nlk->groups))
>  		goto out;
>  
> +	if (p->code == ENOBUFS && nlk->flags & NETLINK_RECV_NO_ENOBUFS)
> +		goto out;
> +
>  	sk->sk_err = p->code;
>  	sk->sk_error_report(sk);
> +	return 1;
>  out:
>  	return 0;
>  }

=> return 0 for NO_ENOBUFS option

Patch 2:

> +	if (nfnetlink_set_err(net, 0, group, -ENOBUFS) > 0)
> +		return -ENOBUFS;
> +
>  	return 0;
>  }

=> return 0 to conntrack. Therefore nf_conntrack_eventmask_report()
assumes success. So if the NO_ENOBUFS option is indeed used for
reliable delivery, this won't work.

Generally the logic seems inverted, you should return an error
to conntrack if userspace wasn't notified of the error.
