From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 17:28:02 +0200
Message-ID: <20100416152802.GB18855@one.firstfloor.org>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com> <87r5mf8va9.fsf@basil.nowhere.org> <1271424726.4606.42.camel@bigi> <20100416134236.GA18855@one.firstfloor.org> <1271426715.4606.97.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Andi Kleen <andi@halobates.de>,
	Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37985 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757123Ab0DPP2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 11:28:08 -0400
Content-Disposition: inline
In-Reply-To: <1271426715.4606.97.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 10:05:15AM -0400, jamal wrote:
> On Fri, 2010-04-16 at 15:42 +0200, Andi Kleen wrote:
> > On Fri, Apr 16, 2010 at 09:32:06AM -0400, jamal wrote:
> > > How are you going to schedule the net softirq on an empty queue if you
> > > do this?
> > 
> > Sorry don't understand the question? 
> > 
> > You can always do the flow as if rps was not there.
> 
> Meaning you schedule the other side netrx softirq if queue is empty?

You handle the packet like if rps wasn't enabled. softirq on current
CPU and it queues it on the socket.

> > I meant an IPI to a sibling is not useful. You send it to the IPI
> > to get cache locality in the target, but if the target has the same
> > cache locality as you you can as well avoid the cost of the IPI
> > and process directly.
> > 
> 
> Isnt the purpose of the IPI to signal remote side that theres something
> for it to do? 

The current CPU can queue on that socket as well.

The whole point of the IPI is to do it with cache locality.
But if cache locality is already there on the current CPU you don't
need the IPI.

> Does it also sync the remote cache?

No, the caches are always coherent.

> 
> > For thread sibling I'm pretty sure it's useless. Not full sure about
> > socket sibling. Maybe.
> > 
> 
> Agreed, the SMT threads share L2. All the cores share L3. And it is
> inclusive, so if it is missing it is in L1 of one thread it must be
> present in L2 of shared cache as well as L3. Across the QPI i dont think
> that is true.
> But if you speacial case this - arent you being specific to Nehalem?

Other CPUs have SMT too (Niagara, POWER 6/7, mips, ...). It should
be the same there.

Assuming L3 affinity helps it might need to be a CPU specific tunable
yes. The scheduler has some information about this.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
