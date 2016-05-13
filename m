From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error
 unwinding
Date: Fri, 13 May 2016 23:07:09 +0200
Message-ID: <20160513210709.GB29941@breakpoint.cc>
References: <1462981273-21676-1-git-send-email-fw@strlen.de>
 <20160512094725.GB1777@salvia>
 <87twi3qmlf.fsf@x220.int.ebiederm.org>
 <20160512164000.GA9815@breakpoint.cc>
 <87a8jtrbk3.fsf@x220.int.ebiederm.org>
 <20160513200442.GA29941@breakpoint.cc>
 <87h9e1puuz.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, dale.4d@gmail.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43377 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753326AbcEMVHP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 17:07:15 -0400
Content-Disposition: inline
In-Reply-To: <87h9e1puuz.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:
> Florian Westphal <fw@strlen.de> writes:
> 
> > Eric W. Biederman <ebiederm@xmission.com> wrote:
> >> > AFAICS no other callers do something similar, but yes,
> >> > we'd need this all over the place if there are others.
> >> >
> >> > Maybe we need a saner fix, e.g. by adding bounds check to net_generic(),
> >> > and making sure that net_generic() returns non-NULL only if the per
> >> > netns memory was allocated properly.
> >> 
> >> As a first approximiation I am thinking we should fix by making
> >> nf_queue_register_handler a per netns operation.
> >
> > We can do that but then we'd end up storing the very same address
> > for each namespace which I think isn't nice either.
> 
> Sort of.  At the same time we fundamentally need a per namespace
> variable to ask if things were initialized.  So using the address as
> that variable changes the equation not at all, and keeps the code
> simpler.

We already do this for nf_conntrack_event_cb and nf_expect_event_cb so
we store 16 byte per netns where one bit would suffice.

> >> Either that or give nfnetlink_queue it's own dedicated place in
> >> struct net for struct nfnl_queue_net.
> >
> > That would work too, but then I don't see why that is preferrable
> > to this proposed patch. We could add a helper for this so that
> > we have something like

Addendum: its also a non-starter as nfqueue data is quite big
and the module won't be loaded in most configurations.

Looking at 70e9942f17a6193e9172a804e6569a8806633d6b again it seems
the problem is somewhat related to this one, although not identical.

Perhaps we should consider adding

nf_netns_feature_ok(struct net *, enum nfnet_feature);

enum nfnet_feature {
	NFNET_QUEUE,
	NFNET_EVENT,
};

and then set/unset that from the netns init/exit handlers.

nf_netns_feature_ok would then just need one bit in struct nf_net
to store wheter whatever feature we care about is available.

We could then de-netnsify those pointers again.

> > static bool netns_was_inited(const struct net *n)
> > {
> > 	return net->list.next != NULL;
> > }
> 
> That does not work because the real question were the things this piece
> of code cares about initialized.

Hmm, AFAIU we can't have packets queued without the netns being on
the list, no?

> Very much no.
> 
> I believe that changing net_generic to return a value so that
> nfqnl_nf_hook_drop can detect if the timing is wrong is an error.

Well, I don't see how this is fixable without having some means of
detecting wheter 'timing' is wrong...

You could say that making calls that end up in nfnetlink_queue
without a successful ->init() is illegal but in that case you
will need some condition by which the netfilter core can know
wheter that call is ok in the first place.

So I do not think that detecting it within nfnetlink_queue is worse
than detecting this in the caller, in fact, detecting it in callee
is better since the caller can't forget the test...

> I also don't think your changes to net_generic will work as the number
> of pointers should have been allocted properly from the start.

As I said I did not test it.
I only saw that net_assign_generic() can expand this array so I
figured one has to check if ptr->[id] is useable.

> Your proposed change is just papering over the problem and fixing it at
> the wrong level.  (The obvious level yes) but still the wrong level.

Well, I have no more ideas.

Looking at the number of function pointers used within netfilter
I'm worried that we will end up pushing more and more redundant info
into struct net to solve this "problem".
