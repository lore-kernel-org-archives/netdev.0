From: Dan Streetman <dan.streetman@canonical.com>
Subject: Re: xfrm4_garbage_collect reaching limit
Date: Mon, 14 Sep 2015 23:14:59 -0400
Message-ID: <CAOZ2QJPAb4PfoBybPuhMokh9jhRFY0XSNMajf75Mgx=3=KXfUg@mail.gmail.com>
References: <CAOZ2QJPt=3YmLG=S2Zf70yNPwLf-dbWtiyWJNbfYMRrQ5C6EZg@mail.gmail.com>
 <20150911094808.GI25499@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Streetman <ddstreet@ieee.org>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36178 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbbIODPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 23:15:39 -0400
Received: by igcrk20 with SMTP id rk20so6338446igc.1
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 20:15:39 -0700 (PDT)
In-Reply-To: <20150911094808.GI25499@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2015 at 5:48 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> Hi Dan.
>
> On Thu, Sep 10, 2015 at 05:01:26PM -0400, Dan Streetman wrote:
>> Hi Steffen,
>>
>> I've been working with Jay on a ipsec issue, which I believe he
>> discussed with you.
>
> Yes, we talked about this at the LPC.
>
>> In this case the xfrm4_garbage_collect is
>> returning error because the number of xfrm4 dst entries has exceeded
>> twice the gc_thresh, which causes new allocations of xfrm4 dst objects
>> to fail, thus making the ipsec connection unusable (until dst objects
>> are removed/freed).
>>
>> The main reason the count gets to the limit is because the
>> xfrm4_policy_afinfo.garbage_collect function - which points to
>> flow_cache_flush (indirectly) - doesn't actually guarantee any xfrm4
>> dst will get cleaned up, it only cleans up unused entries.
>>
>> The flow cache hashtable size limit watermark does restrict how many
>> flow cache entries exist (by shrinking the per-cpu hashtable once it
>> has 4k entries), and therefore indirectly controls the total number of
>> xfrm4 dst objects.  However, there's a mismatch between the default
>> xfrm4 gc_thresh - of 32k objects (which sets a 64k max of xfrm4 dst
>> objects) - and the flow cache hashtable limit of 4k objects per cpu.
>> Any system with 16 or less cpus will have a total limit of 64k (or
>> less) flow cache entries, so the 64k xfrm4 dst entry limit will never
>> be reached.  However for any system with more than 16 cpus, the flow
>> cache limit is greater than the xfrm4 dst limit, and so the xfrm4 dst
>> allocation can fail, rendering the ipsec connection unusable.
>>
>> The most obvious solution is for the system admin to increase the
>> xfrm4_gc_thresh value, although it's not really an obvious solution to
>> the end-user what value they should set it to :-)
>
> Yes, a static gc threshold is always wrong for some workloads. So
> the user needs to adjust it to his needs, even if the right value
> is not obvious.
>
>> Possibly the
>> default value of xfrm4_gc_thresh could be set proportional to
>> num_online_cpus(), but that doesn't help when cpus are onlined after
>> boot.
>
> This could be an option, we could change the xfrm4_gc_thresh value with
> a cpu notifier callback if more cpus come up after boot.

the issue there is, if the value is changed by the user, does a cpu
hotplug reset it back to default...

>
>> Also, a warning message indicating the xfrm4_gc_thresh limit
>> was reached, and a suggestion to increase the limit, may help anyone
>> who hits the issue.

what do you think about this?  it's the simplest option; something like

pr_warn_ratelimited("xfrm4_gc_limit exceeded\n");

or with a suggestion...

pr_warn_ratelimited("xfrm4_gc_limit exceeded, you may want to increase
to %d or more",
  2048 * num_online_cpus());

>>
>> I'm not sure if something more aggressive is appropriate, like
>> removing active entries during garbage collection.
>
> It would not make too much sense to push an active flow out of the
> fastpath just to add some other flow. If the number of active
> entries is to high, there is no other option than increasing the
> gc threshold.
>
> You could try to reduce the number of active entries by shutting
> down stale security associations frequently.
>
>> Or, removing the
>> failure condition from xfrm4_garbage_collect so xfrm4 dst_ops can
>> always be allocated,
>
> This would open doors for DOS attacks, we can't do this.
>
>> or just increasing it from gc_thresh * 2 up to *
>> 4 or more.
>
> This would just defer the problem, so not a real solution.
>
> That said, whatever we do, we just paper over the real problem,
> that is the flowcache itself. Everything that need this kind
> of garbage collecting is fundamentally broken. But as long as
> nobody volunteers to work on a replacement, we have to live
> with this situation somehow.
>
