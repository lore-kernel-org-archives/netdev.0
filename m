From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] Re: [PATCH 2/5] net: Make rtnetlink infrastructure network namespace aware
Date: Mon, 01 Oct 2007 02:45:07 -0600
Message-ID: <m13awv6x64.fsf@ebiederm.dsl.xmission.com>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com>
	<m1hcle9td8.fsf@ebiederm.dsl.xmission.com>
	<46FE72E3.3000402@trash.net>
	<m1tzpd8lfh.fsf@ebiederm.dsl.xmission.com>
	<46FE8FD3.2030308@trash.net>
	<m1myv56vb3.fsf@ebiederm.dsl.xmission.com>
	<46FFC34A.3020701@trash.net> <4700AF4C.6020509@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:43670 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbXJAIqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 04:46:33 -0400
In-Reply-To: <4700AF4C.6020509@sw.ru> (Denis V. Lunev's message of "Mon, 01
	Oct 2007 12:26:52 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Denis V. Lunev" <den@sw.ru> writes:

> The presence of the message in the queue during rtnl_unlock is quite
> possible as normal user->kernel message processing path for rtnl is the
> following:
>
> netlink_sendmsg
>    netlink_unicast
>       netlink_sendskb
>           skb_queue_tail
>           netlink_data_ready
>               rtnetlink_rcv
>                   mutex_lock(&rtnl_mutex);
>                   netlink_run_queue(sk, qlen, &rtnetlink_rcv_msg);
>                   mutex_unlock(&rtnl_mutex);
>
> so, the presence of the packet in the rtnl queue on rtnl_unlock is
> normal race with a rtnetlink_rcv for me.

Yes.  That is what I saw in practice as well.
Thanks for confirming this.

It happened to reproducible because I had a dhcp client asking
for a list of links in parallel with the actual link coming up
during boot.

Looking at netlink_unicast and netlink_broadcast I am generally
convinced that we can remove the call of sk_data_ready in
rtnl_unlock.   I think those are the only two possible paths
through there and I don't see how we could miss a processing a
packet on the way through there.

What would be nice is if we could figure out how to eliminate
this race.  As that would allow netlink packets to be processed
synchronously and we could actually use current for security
checks, and for getting the context of the calling process.

Right now we are 99% of the way there but because of the above
race the code must all be written as if netlink packets were coming
in completely asynchronously.  Which is unfortunate and a pain.

Eric
