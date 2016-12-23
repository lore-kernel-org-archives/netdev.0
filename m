From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6 net-next] inet: don't check for bind conflicts
 twice when searching for a port
Date: Fri, 23 Dec 2016 13:58:06 -0500 (EST)
Message-ID: <20161223.135806.971883501286823222.davem@davemloft.net>
References: <1482441998-28359-1-git-send-email-jbacik@fb.com>
        <1482441998-28359-5-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, kraigatgoog@gmail.com,
        eric.dumazet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48270 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932478AbcLWS6J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 13:58:09 -0500
In-Reply-To: <1482441998-28359-5-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Thu, 22 Dec 2016 16:26:36 -0500

> This is just wasted time, we've already found a tb that doesn't have a bind
> conflict, and we don't drop the head lock so scanning again isn't going to give
> us a different answer.  Instead move the tb->reuse setting logic outside of the
> found_tb path and put it in the success: path.  Then make it so that we don't
> goto again if we find a bind conflict in the found_tb path as we won't reach
> this anymore when we are scanning for an ephemeral port.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
 ...
> @@ -220,8 +219,10 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
>  		spin_lock_bh(&head->lock);
>  		inet_bind_bucket_for_each(tb, &head->chain)
>  			if (net_eq(ib_net(tb), net) && tb->port == port) {
> +				if (hlist_empty(&tb->owners))
> +					goto success;

I am not sure that this condition can ever trigger.

The only time we will see an alive 'tb' with an empty owners list
is when we allocate one in this function.  And when that allocation
succeeds, we go straight through the rest of this function without
ever jumping out for errors or anything like that.

So we should never drop the allocated fresh 'tb', leave it with
an empty owners list, and branch back up to this part of the
function.
