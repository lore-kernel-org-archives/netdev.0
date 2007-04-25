From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 13:15:12 -0700 (PDT)
Message-ID: <alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org>
References: <20070425183856.GA6028@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: davem@davemloft.net, security@kernel.org, greg@kroah.com,
	netdev@vger.kernel.org, jaco@kroon.co.za
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:41838 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2993062AbXDYUSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:18:16 -0400
In-Reply-To: <20070425183856.GA6028@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 25 Apr 2007, Alexey Kuznetsov wrote:
> 
> Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
> which resulted in infinite recursion and stack overflow.

So I assume it's this line that actually _fixes_ it:

> -	pid = nlh->nlmsg_pid;           /*pid of sending process */
> +	pid = NETLINK_CB(skb).pid;       /* pid of sending process */
>  	NETLINK_CB(skb).pid = 0;         /* from kernel */
>  	NETLINK_CB(skb).dst_group = 0;  /* unicast */
>  	netlink_unicast(sk, skb, pid, MSG_DONTWAIT);

No?

If so, shouldn't we also have some safety-net to make sure it doesn't 
still get routed back forever, ie adding something like

	if (!pid) {
		skb_free(skb);
		return -EINVAL;
	}

or similar? I don't know the netlink layer from a dolphin, but if the old 
code could cause infinite recursion, it sounds like the new code could too 
with the right pid, since the only change is the choice of pid.

Yes/No/This is why Linus is a dickweed and doesn't understand the problem?

		Linus
