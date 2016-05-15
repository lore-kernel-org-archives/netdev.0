From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error unwinding
Date: Sat, 14 May 2016 22:00:09 -0500
Message-ID: <87h9e0do06.fsf@x220.int.ebiederm.org>
References: <1462981273-21676-1-git-send-email-fw@strlen.de>
	<20160512094725.GB1777@salvia> <87twi3qmlf.fsf@x220.int.ebiederm.org>
	<20160512164000.GA9815@breakpoint.cc>
	<87a8jtrbk3.fsf@x220.int.ebiederm.org>
	<20160513200442.GA29941@breakpoint.cc>
	<87zirtofgp.fsf@x220.int.ebiederm.org>
	<20160513212029.GC29941@breakpoint.cc>
	<87k2ixo3pn.fsf@x220.int.ebiederm.org>
	<20160514103309.GD29941@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, dale.4d@gmail.com,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160514103309.GD29941@breakpoint.cc> (Florian Westphal's
	message of "Sat, 14 May 2016 12:33:09 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Westphal <fw@strlen.de> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>> Florian Westphal <fw@strlen.de> writes:
>> 
>> > Eric W. Biederman <ebiederm@xmission.com> wrote:
>> >> Florian could you test and verify this patch fixes your issues?
>> >
>> > Yes, this seems to work.
>> >
>> > Pablo, I'm fine with this patch going into -nf/stable but I do not think
>> > making the pointers per netns is a desireable option in the long term.
>> >
>> >> Unlike the other possibilities that have been discussed this also
>> >> addresses the nf_queue path as well as the nf_queue_hook_drop path.
>> >
>> > The nf_queue path should have been fine, no?
>> >
>> > Or putting it differently: can we start processing skbs before a netns
>> > is fully initialized?
>> 
>> The practical case that worries me is what happens when someone does
>> "rmmod nfnetlink_queue" while the system is running.  It appears to me
>> that today we could free the per netns data during the rcu grace period
>> and cause a similar issue in nfnl_queue_pernet.
>>
>> That looks like it could affect both the nf_queue path and the
>> nf_queue_nf_hook_drop path.
>
> OK, I'll check this again but I seem to recall this was fine (the
> nfqueue module exit path sets the handler to NULL before doing anything
> else).

Good point.

Yes, the nfnetlink_queue module calls nf_unregister_queue_handler()
in the module fini method before it does anything else.  That does
set queue_handler to NULL and calls synchronize_rcu() before anything
else.

So in practice that is not a problem, but being disconnected from
everything else that is not immediately apparent.  Sigh.

> The normal netns exit path should be fine too as exit and free happens
> in two distinct loops, i.e. while (without your change) we can have
> calls to nf_queue_hook_drop after the nfqueue netns exit function was
> called, these calls will always happen before the pernets data is
> freed.

Ouch.  That is a little scary.  Today we only have remove_proc_entry
in nfnl_queue_net_exit.  If we had something more substantial those
calls after .exit (without my change) we could get into nasty to find
oopses.  So I guess I did prevent a possible future issue with my patch.


I am half wondering if we could make everything simpler by simply not
allowing nfnetlink_queue be a module.

Eric
