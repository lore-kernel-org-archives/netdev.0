From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/2 nf-next] net: bridge: don't register netfilter
 call_iptables hooks by default
Date: Wed, 17 Sep 2014 14:42:30 +0200
Message-ID: <20140917124230.GJ14006@breakpoint.cc>
References: <1410882457-16641-1-git-send-email-fw@strlen.de>
 <20140917121530.GA3750@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60337 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754061AbaIQMmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 08:42:32 -0400
Content-Disposition: inline
In-Reply-To: <20140917121530.GA3750@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > As its not possible to register hooks from bh context (grabs mutex)
> > its scheduled via workqueue.
> 
> My main concern with this approach is that we may let packets go
> through unfiltered for some little time until the worker thread has
> the chance to register the hooks.

They are supposed to be dropped until hook is there.
However, Nikolay Alexandrov just (correctly...) pointed out to me via irc that this mutex
abuse is against the rules (lock/unlock in different threads!).

So, please toss this series.

> Alternatives that I see for these are:
> * pr_info to indicate the br_netfilter enable by default is
>   deprecated. Similar to your small patch 2/2, but it will take quite
>   some time until we can finally change this to zero.

Right.  I had planned to send a revert for patch 1 at some point,
plus a change to default to 0.

> * I think we can unregister the hooks when we notice that all
>   bridge-nf-call-*tables are zero from the sysctl. We register them if
>   any of them becomes 1 again.

Thats what I thought, but we now also have per-bridge sysfs knobs,
i.e. sysctl could be 0 and someone enabling br42->call_iptables ....

Its doable, but it gets ugly.
I don't think its worth the pain to care about "sometimes
enabled/disabled".
