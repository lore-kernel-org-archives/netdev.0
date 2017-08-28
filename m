From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Mon, 28 Aug 2017 16:56:55 -0700
Message-ID: <20170828235653.jq62menrcfrh5rco@ast-mbp>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <20170826024957.m5ita6usxihywmdd@ast-mbp>
 <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net, luto@amacapital.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33755 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbdH1X47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 19:56:59 -0400
Received: by mail-pf0-f194.google.com with SMTP id c28so1227893pfe.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 16:56:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 27, 2017 at 08:49:23AM -0600, David Ahern wrote:
> 
> The override flag is independent of the recursive flag. If the override
> flag does not allow an override, the attempt to add a new program fails.
> The recursive flag brings an additional constraint: once a cgroup has a
> program with the recursive flag set it is inherited by all descendant
> groups. Attempts to insert a program that changes that flag fails EINVAL.
> 
> Start with the root group at $MNT. No program is attached. By default
> override is allowed and recursive is not set.

The above explanation is the reason we need tests for this logic.
The default is the opposite! By default override is _not_ allowed.

> 1. Group $MNT/a is created.
> 
> i. Default settings from $MNT are inherited; 'a' has override enabled
> and recursive disabled.

not true, but say the user attached a prog wih override on...

> ii. Program is attached. Override flag is set, recursive flag is not set.
> 
> iii. Process in 'a' opens a socket, program attached to 'a' is run.
> 
> 
> 2. $MNT/a/b is created
> 
> i. 'b' inherits the program and settings of 'a' (override enabled,
> recursive disabled).
> 
> ii. Process in 'b' opens a socket. Program inherited from 'a' is run.
> 
> iii. Non-interesting case for this patch set: attaching a non-recursive
> program to 'b' overrides the inherited one. process opens a socket only
> the 'b' program is run.
>
> iv. Program is attached to 'b', override flag set, recursive flag set.
> 
> v. Process in 'b' opens a socket. Program attached to 'b' is run and
> then program from 'a' is run. Recursion stops here since 'a' does not
> have the recursion flag set.

isn't this the problem? Override+non_recurse was set on 'a'.
Now we attached override+recurse on 'b' and suddenly 'a'
will be run like it was 'recursive'?
imo that is counter intuitive to the owner of 'a'.
I think there can be two options:
- if recurse is not set on 'a', all of it descendents should not be allowed
  to use recurse flag
- if recurse is not set on 'a', it should not be run

imo the former is cleaner and avoids issues with detach in the middle

> 3. $MNT/a/b/c is created
> 
> i. 'c' inherits the settings of 'b' (override is allowed, recursive flag
> is set)
> 
> ii. Process in 'c' opens a socket. No program from 'c' exists, so
> nothing is run. Recursion flag is set, so program from 'b' is run, then
> program from 'a' is run. Stop (recursive flag not set on 'a').

also doesn't make sense to me. Both 'b' and 'c' were attached as
override+recurse while 'a' as non-recurse why would it run?
The owner of 'a' attached it as override in the first place,
so it assumed that if descendent wants to override it it can
and the prog 'a' won't be running.

> iii. Attaching a non-recursive program to 'c' fails because it inherited
> the recursive flag from 'b' and that can not be reset by a descendant.

that part makes sense

> iv. Recursive program is attached to 'c'
> 
> v. Process in 'c' opens a socket. Program attached to 'c' is run, then
> the program from 'b' and the program from 'a'. Stop.
> 
> etc.
> 
> To consider what happens on doubling back and changing programs in the
> hierarchy, start with $MNT/a/b/c from 3 above (non-recursive on 'a',
> recursive on 'b' and recursive on 'c') for each of the following cases:
> 
> 1. Program attached to 'b' is detached, recursive flag is reset in the
> request. Attempt fails EINVAL because the recursion flag has to be set.

didn't get this point. you mean 'detach' will fail?

> 2. Program attached to 'b' is detached, recursive flag is set. Allowed.

meaing that detach from 'b' has to pass recurse flag to be detached?
That's also odd.
imo detach should always succeed and the process doing detach
shouldn't need to know what flags were used in attach.

> Process in 'b' opens a socket. No program attached to 'b' so no program
> is run. Recursive flag is set to program from 'a' is run. Stop.
> 
> We should allow the recursive flag to be reset if the parent is not
> recursive allowing an unwind of settings applied. I'll add that change.

I don't get this part.
Anyway looking forward to the next patch set with tests and comments like above.

Also adding Andy to cc. I'd really like both Andy and Tejun to review this logic.
