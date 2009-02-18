From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFT 2/4] Add mod_timer_noact
Date: Wed, 18 Feb 2009 12:01:44 +0100
Message-ID: <20090218110144.GA4100@elte.hu>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com> <20090218092041.GC3294@elte.hu> <20090218.013007.117003889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, kaber@trash.net, rick.jones2@hp.com,
	dada1@cosmosbay.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	gandalf@wlug.westbo.se, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090218.013007.117003889.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 18 Feb 2009 10:20:41 +0100
> 
> > Why dont you use something like this instead:
> > 
> > 	if (del_timer(timer))
> > 		add_timer(timer);
> > 
> > ?
> 
> Why don't you read his commit message?

Uhm, of course i have read this piece of non-info:

| Introduce mod_timer_noact() which for example is to replace 
| the calls to del_timer()/add_timer() in 
| __nf_ct_refresh_acct(). It works like mod_timer() but doesn't 
| activate or modify the timeout of an inactive timer which is 
| the behaviour we want in order to be able to use timers as a 
| means of synchronization in nf_conntrack.

It does not mention the overhead to the regular timer interfaces 
at all, nor does it explain the reasons for this change 
adequately.

And that's why i'm asking, why is the sequence i suggested above 
inadequate? If del_timer(timer) returns 1 it means the timer was 
active - and we call add_timer() only in that case. I.e. we dont 
activate or modify the timeout of an inactive timer.

It can _only_ make a difference in the narrow special case of 
code using the timer list lock as serialization: but that is a 
pretty poor solution in this proposed form as it slows down the 
other 2000 users of timers for no good reason. The changelog was 
completely silent about that overhead aspect (which is small but 
real), and i refuse to believe that this effect was not 
realized.

In other words, the changelog is useless and even borderline 
deceptive. Not a good sign if you are trying to get a patch 
accepted to the kernel.

Furthermore, no performance figures were posted along with this 
modification - it only stated that these are "performance 
improvements". Especially in cases where a change slows down the 
common case the showing of a very substantial performance 
benefit is a must-have, before a patch is considered for 
upstream merging.

You might be aware of that and you might have planned to provide 
such info in the future, but the changelog and the submission 
does not show any realization of this necessity, so i'm asking 
for that here out of caution, to make sure it's done.

In fact, the submission incorrectly stated:

| This patch set is against Patrick's netfilter next tree since
| it is where it should end up.
|      
| git.kernel.org:/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git

This is wrong, the "netfilter next tree" is not where the "Add 
mod_timer_noact" change should end up, and you should ask your 
contributors to submit changes to other subsystems to their 
respective maintainer trees - the timer tree in this case.

> At least show him that much respect if you're going to be 
> against his patch.

Firstly, let me make clear what happened here.

Deep buried inside a networking patchset, Cc:-ed to the netdev 
and netfilter lists only, a core kernel change is embedded that 
in essence modifies 2000 callsites of the generic kernel. The 
patch was not Cc:-ed to lkml.

Secondly, all i'm doing here is reviewing patches of subsystems 
i maintain, so please stop attacking me for doing my job.

I noticed it because i read a lot of lists, but still, this was 
not done transparently at all. Please show minimal respect to 
Linux and post core kernel patches to lkml, and ask your 
sub-maintainers to do likewise. If there's someone here who has 
a moral basis for flaming here it's me, not you.

So, please, at minimum, follow the following well-established 
protocol of contribution:

 - Post timer patches to lkml (the mailing list mentioned in the 
   MAINTAINERS file), just like you expect networking patches to 
   be posted to netdev. It's basic courtesy and not doing so is 
   at minimum a double standard.

 - Declare negative performance impact to the common case very 
   prominently in the changelog, and include analysis about why 
   it's worth paying the price.

 - Include measurements that show clear positive performance
   impact at the new usage site - which offsets the negative 
   micro-costs that every other usage site pays.

 - Require your sub-contributors to write meaningful changelogs,
   that mention every substantial effect of a change, especially 
   when they change core kernel facilities. For example:

      Impact: add new API, slow down old APIs a tiny bit

   Would have alerted people straight away. I had to read the 
   actual patch to figure out this key information.

I'm also utterly puzzled by your apparent desire to flame me. 
This patch is wrong on so many levels that it's not even funny - 
and you as a long-time kernel contributor should have realized 
that straight away. Instead you forced me into wasting time on 
this rather long email (and you also forced the very unnecessary 
public embarrasment of a contributor), for what should have been 
an 'oops, right, will fix' routine matter.

Thanks,

	Ingo
