From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6 net-next] inet: reset tb->fastreuseport when adding
 a reuseport sk
Date: Fri, 23 Dec 2016 14:00:21 -0500 (EST)
Message-ID: <20161223.140021.2268153215775836066.davem@davemloft.net>
References: <1482441998-28359-1-git-send-email-jbacik@fb.com>
        <1482441998-28359-7-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, kraigatgoog@gmail.com,
        eric.dumazet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48470 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932640AbcLWTAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 14:00:23 -0500
In-Reply-To: <1482441998-28359-7-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Thu, 22 Dec 2016 16:26:38 -0500

> @@ -74,12 +74,16 @@ struct inet_ehash_bucket {
>   * users logged onto your box, isn't it nice to know that new data
>   * ports are created in O(1) time?  I thought so. ;-)	-DaveM
>   */
> +#define FASTREUSEPORT_ANY	1
> +#define FASTREUSEPORT_STRICT	2
> +
>  struct inet_bind_bucket {
>  	possible_net_t		ib_net;
>  	unsigned short		port;
>  	signed char		fastreuse;
>  	signed char		fastreuseport;
>  	kuid_t			fastuid;
> +	struct sock_common	fastsock;
>  	int			num_owners;
>  	struct hlist_node	node;
>  	struct hlist_head	owners;

I understand why you did this fastsock thing, it's the easiest way out.

But it is so wasteful, but in space and time.  You have to store an entire fake
socket here, but there is not need for anything other than the recv saddr
member(s).

And you have to copy the whole thing to store the state, which again
is almost entirely unnecessary.

You really just need to store only the required state, and abstract the
AF specific bits properly.
