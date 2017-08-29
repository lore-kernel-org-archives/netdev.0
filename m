From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Mon, 28 Aug 2017 18:12:15 -0700
Message-ID: <20170829011213.suddt5hkptaxd4rp@ast-mbp>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <20170826024957.m5ita6usxihywmdd@ast-mbp>
 <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
 <20170828235653.jq62menrcfrh5rco@ast-mbp>
 <45102738-365f-d08b-f3cf-9a81683956c4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net, luto@amacapital.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33086 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751236AbdH2BMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 21:12:18 -0400
Received: by mail-pf0-f196.google.com with SMTP id c28so1317927pfe.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 18:12:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <45102738-365f-d08b-f3cf-9a81683956c4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 06:43:42PM -0600, David Ahern wrote:
> On 8/28/17 5:56 PM, Alexei Starovoitov wrote:
> > On Sun, Aug 27, 2017 at 08:49:23AM -0600, David Ahern wrote:
> >>
> >> The override flag is independent of the recursive flag. If the override
> >> flag does not allow an override, the attempt to add a new program fails.
> >> The recursive flag brings an additional constraint: once a cgroup has a
> >> program with the recursive flag set it is inherited by all descendant
> >> groups. Attempts to insert a program that changes that flag fails EINVAL.
> >>
> >> Start with the root group at $MNT. No program is attached. By default
> >> override is allowed and recursive is not set.
> > 
> > The above explanation is the reason we need tests for this logic.
> > The default is the opposite! By default override is _not_ allowed.
> 
> yes, I got that backwards. It's how my programs work since I always add
> the OVERRIDE flag ATM.
> 
> > 
> >> 1. Group $MNT/a is created.
> >>
> >> i. Default settings from $MNT are inherited; 'a' has override enabled
> >> and recursive disabled.
> > 
> > not true, but say the user attached a prog wih override on...
> 
> exactly.
> 
> > 
> >> ii. Program is attached. Override flag is set, recursive flag is not set.
> >>
> >> iii. Process in 'a' opens a socket, program attached to 'a' is run.
> >>
> >>
> >> 2. $MNT/a/b is created
> >>
> >> i. 'b' inherits the program and settings of 'a' (override enabled,
> >> recursive disabled).
> >>
> >> ii. Process in 'b' opens a socket. Program inherited from 'a' is run.
> >>
> >> iii. Non-interesting case for this patch set: attaching a non-recursive
> >> program to 'b' overrides the inherited one. process opens a socket only
> >> the 'b' program is run.
> >>
> >> iv. Program is attached to 'b', override flag set, recursive flag set.
> >>
> >> v. Process in 'b' opens a socket. Program attached to 'b' is run and
> >> then program from 'a' is run. Recursion stops here since 'a' does not
> >> have the recursion flag set.
> > 
> > isn't this the problem? Override+non_recurse was set on 'a'.
> > Now we attached override+recurse on 'b' and suddenly 'a'
> > will be run like it was 'recursive'?
> 
> Without 'b', 'a' is run. With 'b' and the recurse flag I am suggesting
> the user is saying I want 'b' and then 'a'. ie., the first parent group
> without the flag is where we stop.
> 
> > imo that is counter intuitive to the owner of 'a'.
> > I think there can be two options:
> > - if recurse is not set on 'a', all of it descendents should not be allowed
> >   to use recurse flag
> > - if recurse is not set on 'a', it should not be run
> 
> If 'a' can be overridden then I don't agree with the first suggestion.
> Which means you are suggesting we stop at the last group with the
> recursive flag set. That is fine too.
> 
> > 
> > imo the former is cleaner and avoids issues with detach in the middle
> > 
> >> 3. $MNT/a/b/c is created
> >>
> >> i. 'c' inherits the settings of 'b' (override is allowed, recursive flag
> >> is set)
> >>
> >> ii. Process in 'c' opens a socket. No program from 'c' exists, so
> >> nothing is run. Recursion flag is set, so program from 'b' is run, then
> >> program from 'a' is run. Stop (recursive flag not set on 'a').
> > 
> > also doesn't make sense to me. Both 'b' and 'c' were attached as
> > override+recurse while 'a' as non-recurse why would it run?
> > The owner of 'a' attached it as override in the first place,
> > so it assumed that if descendent wants to override it it can
> > and the prog 'a' won't be running.
> 
> same argument as above - the question is where do we stop. My suggestion
> and implementation is stopping at the first group without the flag.
> 
> As stated all along, descendant groups inherit programs of the parent
> marked recurse - not by copying them into the group but by recursion.
> 
> 
> > 
> >> iii. Attaching a non-recursive program to 'c' fails because it inherited
> >> the recursive flag from 'b' and that can not be reset by a descendant.
> > 
> > that part makes sense
> > 
> >> iv. Recursive program is attached to 'c'
> >>
> >> v. Process in 'c' opens a socket. Program attached to 'c' is run, then
> >> the program from 'b' and the program from 'a'. Stop.
> >>
> >> etc.
> >>
> >> To consider what happens on doubling back and changing programs in the
> >> hierarchy, start with $MNT/a/b/c from 3 above (non-recursive on 'a',
> >> recursive on 'b' and recursive on 'c') for each of the following cases:
> >>
> >> 1. Program attached to 'b' is detached, recursive flag is reset in the
> >> request. Attempt fails EINVAL because the recursion flag has to be set.
> > 
> > didn't get this point. you mean 'detach' will fail?
> 
> Yes, because it tried to reset the flag in the process.
> 
> This is something we can make user friendly - the detach succeeds, but
> the recurse flag is ignored and the recurse flag in the group is not
> reset unless it is the base group with the recurse flag (i.e., the
> parent is marked non-recurse).

if we don't reset group flags to default it will be even more difficult
for users to use, since attach with recursive flag + immediate detach sets
some internal flag on the cgroup and user space has no way of
either querying this flag or deleting it.

> > 
> >> 2. Program attached to 'b' is detached, recursive flag is set. Allowed.
> > 
> > meaing that detach from 'b' has to pass recurse flag to be detached?
> > That's also odd.
> > imo detach should always succeed and the process doing detach
> > shouldn't need to know what flags were used in attach.
> 
> Then, we agree to make it user friendly and handle resetting the recurse
> flag automatically.

in that sense yes attach/delete pair should be side-effect free.

> >> Process in 'b' opens a socket. No program attached to 'b' so no program
> >> is run. Recursive flag is set to program from 'a' is run. Stop.
> >>
> >> We should allow the recursive flag to be reset if the parent is not
> >> recursive allowing an unwind of settings applied. I'll add that change.
> > 
> > I don't get this part.
> > Anyway looking forward to the next patch set with tests and comments like above.
> 
> Per above discussion, you don't want 'a' run since it is not marked
> recurse. My last sentence is the user friendly part in resetting the
> flag in the cgroup.

I'm still not grasping fully the semantics of what you're proposing.
You keep saying that override and recurse flags are indepedent, but
the more we talk the more it's clear that there is a complicated
relationship between them. Like no_override overrules everything, etc.
I'm looking for the simplest to use logic. Not implementation.
Implementation can be complex, but uapi should be as simple to
explain and as simple to understand as possible.
So how about allowing recurse+overide combination only?
All descendents must be recurse+override too and
no program allowed to be set on parent unless it's recurse+override
as well. Then detach anywhere is simple, since all programs in
such chain are always recurse+override.
