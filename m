From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 05:11:40 +0200
Message-ID: <20150430031138.GA8950@acer.localdomain>
References: <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
 <55417545.30103@iogearbox.net>
 <20150430003019.GE7025@acer.localdomain>
 <55417A3A.50405@iogearbox.net>
 <20150430004839.GG7025@acer.localdomain>
 <20150430011633.GA12674@Alexeis-MBP.westell.com>
 <20150430013452.GA7956@acer.localdomain>
 <554191F9.3010301@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <554191F9.3010301@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.04, Jamal Hadi Salim wrote:
> >>You're right that for 10 years no one cared about performance
> >>of ingress qdisc, but that doesn't mean it's a wrong abstraction
> >>and wrong architecture. Now I care about its performance and
> >>I hope other people will do too.
> >
> 
> Well, even if you didnt touch tc and got rid of the lock
> it will still be about a magnitude faster than netfilter ;->
> How about i call netfilter crap Patrick? It is slower than
> molasses. For more than 10+ years no-one has found good ways
> to bring it up to speed.

Quite frankly, that is ridiculous. I realize we turn in circles
in this discussion, so we will provide the numbers. Give us a test
case if you want, something you think is hard.

> For sure the attempt to re-use netfilter code from tc has failed.

Agreed.

> I think thats what you keep probably repeating as something that will
> crash.

*Everything* except the purely passive ones as the policer will crash.
Everything. Its well known. No point in repeating it.

> Apart from some help from Pablo in recent times - this re-use
> has been a disaster even when linking in user space (from lack of
> backward incompatibilities mostly).
> It seems to me we may just have to drop support for ipt and anything
> netfilter from tc.
> And at some point we are going to need those features, we'll just need
> to write faster versions of them. ebpf maybe helpful.

I stopped caring about TC a long time ago, basically when actions were
merged over my head, despite me being the only person actually taking
care of TC. You might remember, I spent multiple months cleaning up the
action mess when it was merged, and that was only the *really* bad bugs.
Magic numbers in the APIs, lists limited to more magic numbers etc,
I didn't care. Today I do not think its about individual problems anymore,
the entire thing is broken. Egress has some shared problems with ingress,
such as horrible userspace code, horrible error reporting, no way to use it
even for me without looking at both TC and kernel code as the same time, but
ingress is worse in the sense that the supermajority of it will actually
crash in very likely cases, and its not about ipt, its everything touching
a packet in the presence of a tap, like 2/3 of all actions. The qdiscs are
mostly (except integration of classifiers) fine, everything else is crap.

> >The wrong abstraction is using a qdisc for ingress. An abstraction
> >is not about performance. Why do you thing ingress exists? For
> >queueing? Or as providing a hooking point for a bunch of broken
> >(at ingress) actions? You're (one of) the one who painfully realized
> >how broken any kind of packet mangling at that point is. The
> >infrastructure is simply crap and always has been.
> 
> What abstraction is broken? The ingress expects L3 headers. The egress
> expects L2 headers. I dont think there is disagreement that the ingress
> should see L2 headers. The view is that it will be a bit of work.
> Discussion is ongoing to resolve this without penalizing performance.
> You dont care about performance - netfilter is all about how to have
> nice usability. I care about usability but not as much as i do
> about performance.

The abstraction is *wrong*. There is no queueing, hence using a qdisc
is the wrong abstraction. Why are we arguing about that? Its a
mechanism to invoke classifiers and actions. What is the qdisc actually
used for? It certainly doesn't queue anything, the only thing it's
doing is imposing the worst locking imaginable on the entire path.

If that's not enough, look at the actions. I mean, you're not classifying
for the sake of it, there are not even classes on ingress, its purely
done for the actions. And they are, as stated, almost completely
broken. We can do policing. That actually works. Maybe one or two more.
Except policing, none of those is even remotely related to QoS.
So let me ask again, in what sense is the abstraction actually right?

> >>So please leave ingress qdisc alone, this 'generalization'
> >>is too costly.
> >
> >Sorry, we are of the opinion that TC classifiers suck, so we will
> >not leave that path alone :) You're numbers are well appreciated,
> >we will fix this and return with better numbers.
> >
> >>That doesn't mean that netfilter shouldn't have its own hook
> >>on ingress. Without patch 6, the set looks good.
> >
> >I don't agree. It would be preferable to optimize the single hook
> >case not only for ingress's sake, but for all the already existing
> >hooks.
> >
> 
> And i strongly disagree. Netfilter is slow as a boring hot day.
> Please dont enforce it on us. I thought you were kidding when you said
> you want to move the ingress back to netfilter. We run away from there
> years ago.

Quite frankly, talking about netfilter at all is so wrong that there
isn't even a possibility to respond. Netfilter is a mechanism - a hook
to receive a packet. And even that kicks your single threaded ingress
qdiscs ass every packet of the day. What we're talking about are the
things built on top. There's no question we also win on hardware that's
not 1975 there, because people are actually using it.
