From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Mon, 28 Aug 2017 20:22:31 -0600
Message-ID: <32706501-5fc3-7f59-9210-1898e896d384@gmail.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <20170826024957.m5ita6usxihywmdd@ast-mbp>
 <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
 <20170828235653.jq62menrcfrh5rco@ast-mbp>
 <45102738-365f-d08b-f3cf-9a81683956c4@gmail.com>
 <20170829011213.suddt5hkptaxd4rp@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net, luto@amacapital.net,
        "David Ahern (gmail)" <dsahern@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38100 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751209AbdH2CWe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 22:22:34 -0400
Received: by mail-pf0-f195.google.com with SMTP id r187so1403963pfr.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 19:22:34 -0700 (PDT)
In-Reply-To: <20170829011213.suddt5hkptaxd4rp@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/28/17 7:12 PM, Alexei Starovoitov wrote:
>>>> To consider what happens on doubling back and changing programs in the
>>>> hierarchy, start with $MNT/a/b/c from 3 above (non-recursive on 'a',
>>>> recursive on 'b' and recursive on 'c') for each of the following cases:
>>>>
>>>> 1. Program attached to 'b' is detached, recursive flag is reset in the
>>>> request. Attempt fails EINVAL because the recursion flag has to be set.
>>>
>>> didn't get this point. you mean 'detach' will fail?
>>
>> Yes, because it tried to reset the flag in the process.
>>
>> This is something we can make user friendly - the detach succeeds, but
>> the recurse flag is ignored and the recurse flag in the group is not
>> reset unless it is the base group with the recurse flag (i.e., the
>> parent is marked non-recurse).
> 
> if we don't reset group flags to default it will be even more difficult
> for users to use, since attach with recursive flag + immediate detach sets
> some internal flag on the cgroup and user space has no way of
> either querying this flag or deleting it.

We have discussed this before -- the need to know which cgroup has a
program and now what is the status of flags. That need is a different
problem than this patch set.

I'll address the reset of the flags below to keep that discussion together.

> 
>>>
>>>> 2. Program attached to 'b' is detached, recursive flag is set. Allowed.
>>>
>>> meaing that detach from 'b' has to pass recurse flag to be detached?
>>> That's also odd.
>>> imo detach should always succeed and the process doing detach
>>> shouldn't need to know what flags were used in attach.
>>
>> Then, we agree to make it user friendly and handle resetting the recurse
>> flag automatically.
> 
> in that sense yes attach/delete pair should be side-effect free.
> 
>>>> Process in 'b' opens a socket. No program attached to 'b' so no program
>>>> is run. Recursive flag is set to program from 'a' is run. Stop.
>>>>
>>>> We should allow the recursive flag to be reset if the parent is not
>>>> recursive allowing an unwind of settings applied. I'll add that change.
>>>
>>> I don't get this part.
>>> Anyway looking forward to the next patch set with tests and comments like above.
>>
>> Per above discussion, you don't want 'a' run since it is not marked
>> recurse. My last sentence is the user friendly part in resetting the
>> flag in the cgroup.
> 
> I'm still not grasping fully the semantics of what you're proposing.
> You keep saying that override and recurse flags are indepedent, but
> the more we talk the more it's clear that there is a complicated
> relationship between them. Like no_override overrules everything, etc.

yes, I have said that a few times. Override should block everything in
terms of installing programs. If it is not enabled, the status of the
recurse flag is not relevant at attach / detach time as the call should
fail. So installing a program with the recurse flag only works if
override is allowed.


> I'm looking for the simplest to use logic. Not implementation.
> Implementation can be complex, but uapi should be as simple to
> explain and as simple to understand as possible.
> So how about allowing recurse+overide combination only?
> All descendents must be recurse+override too and
> no program allowed to be set on parent unless it's recurse+override
> as well. Then detach anywhere is simple, since all programs in
> such chain are always recurse+override.


Let's walk through examples based on the new ground rule - recursion
stops at last cgroup with flag set.

Assuming override is allowed ...

${MNT}/a/b/c/d

- 'a' has no program

- 'b' has a program, override allowed, recurse set

- 'c' and 'd' inherit the program from 'b' by recursion, not inheritance
(ie., bpf.effective is not updated with the program from 'b', but the
recurse flag is set on 'c' and 'd').

At this point 'c' and 'd' can ONLY take programs that are recursive.

- 'c' gets a program installed
- 'd' gets a program installed.


Process in 'd' has programs run in this order: 'd', 'c', 'b'


Now, program 'c' is detached. It is in the middle of the recursive set.
It MUST keep the recurse flag set as it inherited the restriction from
'b'. The recurse flag on 'c' can ONLY be reset when the program is
detached from 'b' as it is the start of the recursive chain.

I'll stop here to make sure we agree on the above. Considering all
permutations is a maze.

###

Also, let's agree on this intention. Based on the new ground rule, I
want to point out this example:

If 'a' gets a program installed with no recurse flag set, ONLY processes
in 'a' have the 'a' program run. Processes in groups 'b', 'c' and 'd'
all stop at cgroup 'b' program.

To me this is counterintuitive and why I said programs are run up to the
first parent without the recurse flag. They are all part of the same tree.
