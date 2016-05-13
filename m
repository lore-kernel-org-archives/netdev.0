From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error unwinding
Date: Fri, 13 May 2016 14:40:44 -0500
Message-ID: <87a8jtrbk3.fsf@x220.int.ebiederm.org>
References: <1462981273-21676-1-git-send-email-fw@strlen.de>
	<20160512094725.GB1777@salvia> <87twi3qmlf.fsf@x220.int.ebiederm.org>
	<20160512164000.GA9815@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, dale.4d@gmail.com,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:55031 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbcEMTve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 15:51:34 -0400
In-Reply-To: <20160512164000.GA9815@breakpoint.cc> (Florian Westphal's message
	of "Thu, 12 May 2016 18:40:00 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>> > On Wed, May 11, 2016 at 05:41:13PM +0200, Florian Westphal wrote:
>> >> diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
>> >> index 5baa8e2..9722819 100644
>> >> --- a/net/netfilter/nf_queue.c
>> >> +++ b/net/netfilter/nf_queue.c
>> >> @@ -102,6 +102,13 @@ void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops)
>> >>  {
>> >>  	const struct nf_queue_handler *qh;
>> >>  
>> >> +	/* netns wasn't initialized, error unwind in progress.
>> >> +	 * Its possible that the nfq netns init function was not even
>> >> +	 * called, in which case nfq pernetns data is in undefined state.
>> >> +	 */
>> >> +	if (!net->list.next)
>> >> +		return;
>> >
>> > Thanks Florian.
>> >
>> > Question for the netns folks: Is this a stable assumption? My only
>> > concern with this is that it relies on internal the netns
>> > representation, so I'd like to make sure this thing doesn't break
>> > again.
>> >
>> > Let me know, thanks.
>> 
>> Ugh. I got distracted before I finished replying.
>> 
>> I don't think the analysis is correct.
>
> I am afraid it is, see below for example
>
>> The unwind and the netns exit path should maintain the same constraints.
>> If they don't there is a bug, perhaps in initialization ordering.
>
> Since 8405a8fff3f8545c888a872d6e3c0c8eecd4d348 any call to
> nf_unregister_hook invokes nf_queue_nf_hook_drop().
>
> If the nfnetlink_queue module is loaded, that means we call
> nfqnl_nf_hook_drop function via the nf_queue nf_queue_handler struct
> in nf_queue.c .
>
> And since nfqnl_nf_hook_drop() uses net_generic() ...
>
>> Code should be able to count on net_generic() from the beginning of the
>> corresponding .init to the end of the corresponding .fini
>
> ... we cannot count on this.

I guess what I meant was that we should see if we can fix this.

> Example:
> 1. we try to create new netns
> 2. net_namespace.c:ops_init walks the netns op list and calls ->init()
> 3. some of these init hooks register netfilter hooks
> 4. we call init hook for nfnetlink_queue, but this yields -EFOO (alternatively, another ->init handler before this failed)
> 5. netns init code invokes the ->exit() handlers in reverse order for unwinding
> 6. hooks get unregistered, which makes a call into nf_queue_nf_hook_drop
> 7. nf_queue then calls q->nfqnl_nf_hook_drop(net)
> 8. oops as nfnetlink_queue wasn't setup in this net ns and net_generic
> returns some undefined result
>
>> Something like that is not happening and if we can I would like to track
>> down why.
>> 
>> Otherwise we need code like the above all over the place.
>
> AFAICS no other callers do something similar, but yes,
> we'd need this all over the place if there are others.
>
> Maybe we need a saner fix, e.g. by adding bounds check to net_generic(),
> and making sure that net_generic() returns non-NULL only if the per
> netns memory was allocated properly.

As a first approximiation I am thinking we should fix by making
nf_queue_register_handler a per netns operation.

Either that or give nfnetlink_queue it's own dedicated place in
struct net for struct nfnl_queue_net.

Let's sort out the interface so we can't get this wrong.

Eric
