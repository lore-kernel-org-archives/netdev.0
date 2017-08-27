From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Sun, 27 Aug 2017 08:49:23 -0600
Message-ID: <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <20170826024957.m5ita6usxihywmdd@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net,
        "David Ahern (gmail)" <dsahern@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34872 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdH0OtY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 10:49:24 -0400
Received: by mail-pf0-f181.google.com with SMTP id c15so8808887pfm.2
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2017 07:49:24 -0700 (PDT)
In-Reply-To: <20170826024957.m5ita6usxihywmdd@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/17 8:49 PM, Alexei Starovoitov wrote:
> 
>> +	if (prog && curr_recursive && !new_recursive)
>> +		/* if a parent has recursive prog attached, only
>> +		 * allow recursive programs in descendent cgroup
>> +		 */
>> +		return -EINVAL;
>> +
>>  	old_prog = cgrp->bpf.prog[type];
> 
> ... I'm struggling to completely understand how it interacts
> with BPF_F_ALLOW_OVERRIDE.

The 2 flags are completely independent. The existing override logic is
unchanged. If a program can not be overridden, then the new recursive
flag is irrelevant.

> By default we shouldn't allow overriding, so if default prog attached
> to a root, what happens if we try to attach F_RECURSIVE to a descendent?
> If I'm reading the code correctly it will not succeed, which is good.
> Could you add such scenario as test to test_cgrp2_attach2.c ?

Patch 7 adds test cases to cover scenarios. I will add more tests per
comments below and rename to convey it tests the recursive flag.

> 
> Now say we attach overridable and !recursive to a root, another
> recursive prog will not be attached to a descedent, which is correct.

yes

> 
> But if we attach !overridable + recursive to a root we cannot attach
> anything to a descendent right? Then why allow such combination at all?

Sure, we can not allow that combination to prevent the inefficiency of
recursively running through cgroups to run the base program.

> So only overridable + recursive combination makes sense, right?
> 
> I think all these combinations must be documented and tests must be
> added. Sooner or later people will build security sensitive environment
> with it and we have to meticulous now.

Intentions below. I'll add more test cases to verify intentions agree
with code.

> 
> Do you think it would make sense to split this patch out and
> push patches 2 and 3 with few tests in parallel, while we're review
> this change?

I thought about that but decided no. The 'ip vrf exec' use case would
break right of the gate if the other settings were used.

> 
> Tejun needs to take a deep look into this patch as well.
> 

This is the intended behavior:

The override flag is independent of the recursive flag. If the override
flag does not allow an override, the attempt to add a new program fails.
The recursive flag brings an additional constraint: once a cgroup has a
program with the recursive flag set it is inherited by all descendant
groups. Attempts to insert a program that changes that flag fails EINVAL.

Start with the root group at $MNT. No program is attached. By default
override is allowed and recursive is not set.

1. Group $MNT/a is created.

i. Default settings from $MNT are inherited; 'a' has override enabled
and recursive disabled.

ii. Program is attached. Override flag is set, recursive flag is not set.

iii. Process in 'a' opens a socket, program attached to 'a' is run.


2. $MNT/a/b is created

i. 'b' inherits the program and settings of 'a' (override enabled,
recursive disabled).

ii. Process in 'b' opens a socket. Program inherited from 'a' is run.

iii. Non-interesting case for this patch set: attaching a non-recursive
program to 'b' overrides the inherited one. process opens a socket only
the 'b' program is run.

iv. Program is attached to 'b', override flag set, recursive flag set.

v. Process in 'b' opens a socket. Program attached to 'b' is run and
then program from 'a' is run. Recursion stops here since 'a' does not
have the recursion flag set.


3. $MNT/a/b/c is created

i. 'c' inherits the settings of 'b' (override is allowed, recursive flag
is set)

ii. Process in 'c' opens a socket. No program from 'c' exists, so
nothing is run. Recursion flag is set, so program from 'b' is run, then
program from 'a' is run. Stop (recursive flag not set on 'a').

iii. Attaching a non-recursive program to 'c' fails because it inherited
the recursive flag from 'b' and that can not be reset by a descendant.

iv. Recursive program is attached to 'c'

v. Process in 'c' opens a socket. Program attached to 'c' is run, then
the program from 'b' and the program from 'a'. Stop.

etc.

To consider what happens on doubling back and changing programs in the
hierarchy, start with $MNT/a/b/c from 3 above (non-recursive on 'a',
recursive on 'b' and recursive on 'c') for each of the following cases:

1. Program attached to 'b' is detached, recursive flag is reset in the
request. Attempt fails EINVAL because the recursion flag has to be set.


2. Program attached to 'b' is detached, recursive flag is set. Allowed.

Process in 'b' opens a socket. No program attached to 'b' so no program
is run. Recursive flag is set to program from 'a' is run. Stop.

We should allow the recursive flag to be reset if the parent is not
recursive allowing an unwind of settings applied. I'll add that change.
