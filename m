From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error unwinding
Date: Fri, 13 May 2016 15:26:44 -0500
Message-ID: <87h9e1puuz.fsf@x220.int.ebiederm.org>
References: <1462981273-21676-1-git-send-email-fw@strlen.de>
	<20160512094725.GB1777@salvia> <87twi3qmlf.fsf@x220.int.ebiederm.org>
	<20160512164000.GA9815@breakpoint.cc>
	<87a8jtrbk3.fsf@x220.int.ebiederm.org>
	<20160513200442.GA29941@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, dale.4d@gmail.com,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58627 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128AbcEMUkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 16:40:25 -0400
In-Reply-To: <20160513200442.GA29941@breakpoint.cc> (Florian Westphal's
	message of "Fri, 13 May 2016 22:04:42 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>> > AFAICS no other callers do something similar, but yes,
>> > we'd need this all over the place if there are others.
>> >
>> > Maybe we need a saner fix, e.g. by adding bounds check to net_generic(),
>> > and making sure that net_generic() returns non-NULL only if the per
>> > netns memory was allocated properly.
>> 
>> As a first approximiation I am thinking we should fix by making
>> nf_queue_register_handler a per netns operation.
>
> We can do that but then we'd end up storing the very same address
> for each namespace which I think isn't nice either.

Sort of.  At the same time we fundamentally need a per namespace
variable to ask if things were initialized.  So using the address as
that variable changes the equation not at all, and keeps the code
simpler.

>> Either that or give nfnetlink_queue it's own dedicated place in
>> struct net for struct nfnl_queue_net.
>
> That would work too, but then I don't see why that is preferrable
> to this proposed patch. We could add a helper for this so that
> we have something like
>
> static bool netns_was_inited(const struct net *n)
> {
> 	return net->list.next != NULL;
> }

That does not work because the real question were the things this piece
of code cares about initialized.

> Another alternative is this patch (not even compile tested, just to
> illustrate the idea):

Very much no.

I believe that changing net_generic to return a value so that
nfqnl_nf_hook_drop can detect if the timing is wrong is an error.

I also don't think your changes to net_generic will work as the number
of pointers should have been allocted properly from the start.  

Your proposed change is just papering over the problem and fixing it at
the wrong level.  (The obvious level yes) but still the wrong level.

> What do you think?

Eric
