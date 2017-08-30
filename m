From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Tue, 29 Aug 2017 19:58:51 -0700
Message-ID: <20170830025850.wlp2hp7d4kreodif@ast-mbp>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <20170826024957.m5ita6usxihywmdd@ast-mbp>
 <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
 <20170828235653.jq62menrcfrh5rco@ast-mbp>
 <45102738-365f-d08b-f3cf-9a81683956c4@gmail.com>
 <20170829011213.suddt5hkptaxd4rp@ast-mbp>
 <32706501-5fc3-7f59-9210-1898e896d384@gmail.com>
 <20170829041118.m6bsjvif2bxwtk6g@ast-mbp>
 <ab9b2874-fadc-5ab6-7710-2ccb1d65bb2c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net, luto@amacapital.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38025 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751861AbdH3C6y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 22:58:54 -0400
Received: by mail-pf0-f195.google.com with SMTP id r187so3455820pfr.5
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 19:58:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ab9b2874-fadc-5ab6-7710-2ccb1d65bb2c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 07:03:43PM -0600, David Ahern wrote:
> On 8/28/17 10:11 PM, Alexei Starovoitov wrote:
> > 
> > Agree on the above, but you're mixing semantics of the new recurse
> > flag and implementation of it. Ex: we don't have to copy this flag
> > from prog->attr into cgroup. So this reset or non-reset discussion
> > only makes sense in the context of your current implementation.
> > We can implement the logic differently. Like don't copy that flag
> > at all and at attach time walk parent->parent->parent and see
> > what programs are attached. All of them should have prog->attr & recurse_bit set
> > In such implementation detach from 'b' is a nop from reset/non-reset
> > point of view. When socket creation in 'c' is invoked the program
> > 'c' is called first then the code keeps walking parents until root
> > invoking 'a' along the way.
> 
> So you are suggesting there is no recursive flag per cgroup? How do you
> know you need to walk cgroups? How do you know when to stop running
> programs?

you're talking about implementation, right?
My 'proposed' implemenation of walking from cgroup all the way to the root
is just an example. It's not efficient. More below...

> > I'm not saying it will be an efficient implementation. The point
> > is to discuss UAPI independent of implementation.
> > 
> >> ###
> >>
> >> Also, let's agree on this intention. Based on the new ground rule, I
> >> want to point out this example:
> >>
> >> If 'a' gets a program installed with no recurse flag set, ONLY processes
> >> in 'a' have the 'a' program run. Processes in groups 'b', 'c' and 'd'
> >> all stop at cgroup 'b' program.
> > 
> > I'm proposing that such situation should not be allowed to happen.
> > In a->b->c->d cgroup scenario if override+recurse prog attached to 'b'
> > then only the same override+recurse can be attached to c, d, a.
> > So at detach time there can be gaps (like only 'b' and 'd' have
> > override+recurse progs), but walking up until root from any point
> > will guarantee that only override+recurse programs are seen.
> > 
> 
> That seems very limiting to me. Seems like you are suggesting the entire
> cgroup tree is recursive or non-recursive, but never a mix.

Entire cgroup subtree. Yes. It's the simplest uapi I could think of.
Easy to understand and argue about and I think it's solving your use case.
It's also easily extendable. New combination and features won't break
the users. It feels you're in rush to get this stuff for this merge
window, therefore I want to agree on something that is simple,
non-controversial and extensible.
If you're not in rush (I'm not), we can come up with more flexible uapi.
For example: another way of thinking about your 'recursive' requirement
is to think that all 'program to be run' should be present as a link list
in a given cgroup. So no walking a chain of parents.
Instead of 'recursive' let's call this new flag 'multiprog'.
Now in a->b->c->d scenario. We can install 'multiprog' prog in 'b'.
The kernel will automatically propage it (like it does right now
with css_for_each_descendant_pre() loop) to 'c' and to 'd'.
Now we allow users to attach another 'multiprog' program to 'c'.
The kernel will maintain a link list of programs in every cgroup,
so there will be a link list of two programs in 'c' and 'd'
and invocation of the programs will be faster than walking
cgroup->parent->parent and checking some flags at every step,
since there will be less pointer dereferences and no flags to check.
Just invoke all programs in the current cgroup. Kernel took care
of ordering at the time of attach/detach.
I believe Andy proposed something like this back in Jan/Feb.
