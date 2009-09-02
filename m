From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc: Fix unitialized kernel memory leak
Date: Wed, 2 Sep 2009 12:05:40 -0700
Message-ID: <20090902120540.34e2a198@nehalam>
References: <4A9E67A9.7090205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54659 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296AbZIBTFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 15:05:43 -0400
In-Reply-To: <4A9E67A9.7090205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Sep 2009 14:40:09 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Three bytes of uninitialized kernel memory are currently leaked to user
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 24d17ce..fdb694e 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -1456,6 +1456,8 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
>  	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
>  	tcm = NLMSG_DATA(nlh);
>  	tcm->tcm_family = AF_UNSPEC;
> +	tcm->tcm__pad1 = 0;
> +	tcm->tcm__pad2 = 0;
>  	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
>  	tcm->tcm_parent = q->handle;
>  	tcm->tcm_handle = q->handle;

Perhaps __nlmsg_put should just always call memset() for the whole
added chunk. It is not like it is critical path in any way, and
avoid any of this possible class of errors.
