From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Fri, 23 Aug 2013 09:20:32 +0200
Message-ID: <1377242432.14021.2.camel@jlt4.sipsolutions.net>
References: <1377206736-18357-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:38011 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350Ab3HWHUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 03:20:40 -0400
In-Reply-To: <1377206736-18357-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> @@ -572,15 +594,29 @@ static int genl_family_rcv_msg(struct
> genl_family *family,
>                 return -EPERM;
>  
>         if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
> -               struct netlink_dump_control c = {
> -                       .dump = ops->dumpit,
> -                       .done = ops->done,
> -               };
> +               struct netlink_dump_control c;
> +               int rc;
>  
>                 if (ops->dumpit == NULL)
>                         return -EOPNOTSUPP;
>  
> -               return netlink_dump_start(net->genl_sock, skb, nlh,
> &c);
> +               memset(&c, 0, sizeof(c));
> +               if (!family->parallel_ops) {
> +                       genl_unlock();
> +                       c.data = ops;
> +                       c.dump = genl_lock_dumpit;
> +                       if (ops->done)
> +                               c.done = genl_lock_done;
> +               } else {
> +                       c.dump = ops->dumpit;
> +                       c.done = ops->done;
> +               }
> +
> +               rc = netlink_dump_start(net->genl_sock, skb, nlh, &c);
> +               if (!family->parallel_ops)
> +                       genl_lock();
> +               return rc;
> +

I think this piece would be easier to read if you call
netlink_dump_start() separately in the two branches. If you also move
the "c" variable into the branches then you can keep initializing it
with an explicit initializer which would also be more readable IMHO.

Either way, this seems fine. I still think that not assigning cb_mutex
wasn't the smartest idea, but I'll reply over in the other thread.

johannes
