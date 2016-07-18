From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 23:51:14 +0200
Message-ID: <1468878674.1778899.669950273.69750E32@webmail.messagingengine.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc>
 <20160718154512.GK5871@two.firstfloor.org>
 <7a03a353-4c1e-2bb4-2550-f84fc4cc79ac@stressinduktion.org>
 <20160718194357.GL5871@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, kan.liang@intel.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:48737 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752099AbcGRVvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 17:51:16 -0400
In-Reply-To: <20160718194357.GL5871@two.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Jul 18, 2016, at 21:43, Andi Kleen wrote:
> > I wonder if this can be attacked from a different angle. What would be
> > missing to add support for this in user space? The first possibility
> > that came to my mind is to just multiplex those hints in the kernel.
> 
> "just" is the handwaving part here -- you're proposing a micro kernel
> approach where part of the multiplexing job that the kernel is doing
> is farmed out to a message passing user space component.
> 
> I suspect this would be far more complicated to get right and
> perform well than a straight forward monolithic kernel subsystem --
> which is traditionally how Linux has approached things.

At the same time having any kind of policy in the kernel was also always
avoided.

> The daemon would always need to work with out of date state
> compared to the latest, because it cannot do any locking with the
> kernel state.  So you end up with a complex distributed system with
> multiple
> agents "fighting" with each other, and the tuning agent
> never being able to keep up with the actual work.

But you don't want to have the tuning agents in the fast path? If you
really try to synchronously update all queue mappings/irqs during socket
creation or connect time this would add rtnl lock to basically socket
creation, as drivers require that. This would slow down basic socket
operations a lot and synchronize them with the management interface.

Even dst_entries are not synchronously updated anymore nowadays as that
would require too much locking overhead in the kernel.

> Also of course it would be fundamentally less efficient than
> kernel code doing that, just because of the additional context
> switches needed.

Synchronizing or configuring any kind of queues already requires
rtnl_mutex. I didn't test it but acquiring rtnl mutex in inet_recvmsg is
unlikely to fly performance wise and might even be very dangerous under
DoS attacks (like I see in 24/30).

Bye,
Hannes
