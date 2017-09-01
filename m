From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Thu, 31 Aug 2017 20:27:56 -0700
Message-ID: <20170901032754.ogqmgqaqp3dwfdbw@ast-mbp>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <20170826024957.m5ita6usxihywmdd@ast-mbp>
 <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
 <20170831142201.GB1599492@devbig577.frc2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
        daniel@iogearbox.net, ast@kernel.org, davem@davemloft.net
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35468 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdIAD17 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 23:27:59 -0400
Received: by mail-pg0-f67.google.com with SMTP id r133so936344pgr.2
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 20:27:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170831142201.GB1599492@devbig577.frc2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 07:22:01AM -0700, Tejun Heo wrote:
> Hello, David, Alexei.
> 
> Sorry about late reply.
> 
> On Sun, Aug 27, 2017 at 08:49:23AM -0600, David Ahern wrote:
> > On 8/25/17 8:49 PM, Alexei Starovoitov wrote:
> > > 
> > >> +	if (prog && curr_recursive && !new_recursive)
> > >> +		/* if a parent has recursive prog attached, only
> > >> +		 * allow recursive programs in descendent cgroup
> > >> +		 */
> > >> +		return -EINVAL;
> > >> +
> > >>  	old_prog = cgrp->bpf.prog[type];
> > > 
> > > ... I'm struggling to completely understand how it interacts
> > > with BPF_F_ALLOW_OVERRIDE.
> > 
> > The 2 flags are completely independent. The existing override logic is
> > unchanged. If a program can not be overridden, then the new recursive
> > flag is irrelevant.
> 
> I'm not sure all four combo of the two flags makes sense.  Can't we
> have something simpler like the following?
> 
> 1. None: No further bpf programs allowed in the subtree.
> 
> 2. Overridable: If a sub-cgroup installs the same bpf program, this
>    one yields to that one.
> 
> 3. Recursive: If a sub-cgroup installs the same bpf program, that
>    cgroup program gets run in addition to this one.
> 
> Note that we can have combinations of overridables and recursives -
> both allow further programs in the sub-hierarchy and the only
> distinction is whether that specific program behaves when that
> happens.

If I understand the proposal correctly in case of:
A (with recurs) -> B (with override) -> C (with recurse) -> D (with override)
when something happens in D, you propose to run D,C,A  ?

With the order of execution from children to parent?
That's a bit a different then what I was proposing with 'multi-prog' flag,
but the more I think about it the more I like it.
In your case detach is sort of transparent to everything around.
And you would also allow to say 'None' to one of the substrees too, right?
So something like:
A (with recurs) -> B (with override) -> C (with recurse) -> D (None) -> E
would mean that E cannot attach anything and events in E will
call D->C->A, right?
I will work on a patch for the above and see how it looks.
