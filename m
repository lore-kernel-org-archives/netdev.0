From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 04/14] tipc: add sock dump to new netlink api
Date: Fri, 12 Sep 2014 17:10:38 -0400 (EDT)
Message-ID: <20140912.171038.1165432718811920305.davem@davemloft.net>
References: <1410424167-17427-1-git-send-email-richard.alpe@ericsson.com>
	<1410424167-17427-5-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbaILVKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 17:10:40 -0400
In-Reply-To: <1410424167-17427-5-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Thu, 11 Sep 2014 10:29:17 +0200

> +	list_for_each_entry_from(p, &tsk->publications, pport_list) {
> +		publ = nla_nest_start(skb, TIPC_NLA_SOCK_PUBL);
> +		if (nla_put_u32(skb, TIPC_NLA_PUBL_TYPE, p->type))
> +			goto msg_full;
> +		if (nla_put_u32(skb, TIPC_NLA_PUBL_LOWER, p->lower))
> +			goto msg_full;
> +		if (nla_put_u32(skb, TIPC_NLA_PUBL_UPPER, p->upper))
> +			goto msg_full;
> +		nla_nest_end(skb, publ);
> +	}
> +
> +	*prev_publ = 0;
> +
> +	return 0;
> +
> +msg_full:
> +	*prev_publ = p->key;
> +	nla_nest_cancel(skb, publ);

This restart mechanism is broken.

You can't public nested information this way.

What happens in your code is that if we hit the limit in the middle of
adding the publications, the next time we'll put the same socket into
the netlink message and then the rest of the nested publications.
That's malformed.

You can't just say sometimes you'll partially list the set of nested
attributes in an object, you must public the entire object fully in
the netlink message or skip the object entirely.

I would suggest that you instead size the amount of space you'll
need for at least the first socket being listed, and if NLMSG_GOODSIZE
is insufficient, allocate as much as you will actually need.

Then you put full socket netlink blobs in there, including all nested
attributes, and then stop and reset back the the most recent full socket
published if you run out of space.
