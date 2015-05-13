From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: sched: use counter to break reclassify loops
Date: Wed, 13 May 2015 13:29:58 +0200
Message-ID: <20150513112958.GA6179@breakpoint.cc>
References: <1431366641-24735-1-git-send-email-fw@strlen.de>
 <5551E62D.5040507@mojatatu.com>
 <20150512130029.GA22387@breakpoint.cc>
 <55533321.302@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42868 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753955AbbEMLaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 07:30:00 -0400
Content-Disposition: inline
In-Reply-To: <55533321.302@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 05/12/15 09:00, Florian Westphal wrote:
> >Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> >>Florian,
> >>In general i am in support of removing this - since the use case never
> >>materialized as being useful. However, this is not the same logic that
> >>was there before. To get equivalency you need to pass the limit into
> >>tc_classify_compat() so i can be reset.
> >
> >AFAICS this re-set only happens when we return something other
> >than RECLASSIFY which means the caller will not check the limit.
> >
> >So in fact it should be ok to remove this since the counter will always
> >start from 0 on next tc_classify() invocation.
> >
> 
> Florian, consider the following scenario:
> Assume X is the max allowed reclassified before bells start ringing.
> If we see upto X back-to-back reclassify - we are very much likely in
> a loop. We should see fire trucks arrive and bail out.
> If we see X-1  "reclassify" followed by a "pipe" followed by
> X-1 "reclassify" followed by "ok" then that looks like a healthy
> policy. But that is a a total of 2X-2 reclassifies. You will
> bail out at X reclassifies; what i am saying is you shouldnt.
> And existing logic doesnt. Does that make sense?

Yes, but, if we use your example above then:

tc_classify called
  limit 0
    tc_classify_compat called, ret RECLASSIFY
  limit 1
    tc_classify_compat called, ret RECLASSIFY
  limit 2
    tc_classify_compat called, ret PIPE (== 3)
  tc_classify returns 3
tc_classify called
  limit 0
  ...

So we don't toss skb since any return value other than RECLASSIFY
will make tc_classify() return to its caller, and when caller invokes
tc_classify again the limit variable is set to 0 again.

Does that make sense to you?

Thanks Jamal.
