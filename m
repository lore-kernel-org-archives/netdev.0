From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: iptables very slow after commit
 784544739a25c30637397ace5489eeb6e15d7d49
Date: Fri, 10 Apr 2009 18:39:18 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com> <20090410095246.4fdccb56@s6510> <20090410.182507.140306636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@vyatta.com, jeff.chua.linux@gmail.com,
	dada1@cosmosbay.com, jengelh@medozas.de, kaber@trash.net,
	r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53371 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751115AbZDKBrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 21:47:47 -0400
In-Reply-To: <20090410.182507.140306636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 10 Apr 2009, David Miller wrote:
> 
> [ CC:'ing netfilter-devel and netdev... ]

I wonder if we should bring in the RCU people too, for them to tell you 
that the networking people are beign silly, and should not synchronize 
with the very heavy-handed

	synchronize_net()

but instead of doing synchronization (which is probably why adding a few 
hundred rules then takes several seconds - each synchronizes and that 
takes a timer tick or so), add the rules to be free'd on some rcu-freeing 
list for later freeing.

Or whatever. Paul? synchronize_net() just calls synchronize_rcu(), and 
with that knowledge and a simple

	git show 784544739a25c30637397ace5489eeb6e15d7d49

I bet you can already tell people how to fix their performance issue.

		Linus

---
> > On Fri, 10 Apr 2009 17:15:52 +0800 (SGT)
> > Jeff Chua <jeff.chua.linux@gmail.com> wrote:
> >> 
> >> Adding 200 records in iptables took 6.0sec in 2.6.30-rc1 compared to 
> >> 0.2sec in 2.6.29. I've bisected down this commit.
> >> 
> >> There are a few patches on top of the original patch. When I reverted the 
> >> original commit + changing rcu_read() to rcu_read_bh(), it speeds up the 
> >> inserts back to .2sec again.
> >> 
> >> I'm loading all the firewall rules during boot-up and this 6 secs slowness 
> >> is really not very nice to wait for.
> > 
> > The performance benefit during operation is more important. The load
> > time is fixable. The problem is probably generic to any set of rules,
> > but could you post some info about your configuration (like the rule
> > set), and the system configuration (# of cpu's, config etc).
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 
