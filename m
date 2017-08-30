From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Tue, 29 Aug 2017 19:03:43 -0600
Message-ID: <ab9b2874-fadc-5ab6-7710-2ccb1d65bb2c@gmail.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <20170826024957.m5ita6usxihywmdd@ast-mbp>
 <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
 <20170828235653.jq62menrcfrh5rco@ast-mbp>
 <45102738-365f-d08b-f3cf-9a81683956c4@gmail.com>
 <20170829011213.suddt5hkptaxd4rp@ast-mbp>
 <32706501-5fc3-7f59-9210-1898e896d384@gmail.com>
 <20170829041118.m6bsjvif2bxwtk6g@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net, luto@amacapital.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35643 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdH3BDv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 21:03:51 -0400
Received: by mail-pf0-f195.google.com with SMTP id g13so3328273pfm.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 18:03:51 -0700 (PDT)
In-Reply-To: <20170829041118.m6bsjvif2bxwtk6g@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/28/17 10:11 PM, Alexei Starovoitov wrote:
> 
> Agree on the above, but you're mixing semantics of the new recurse
> flag and implementation of it. Ex: we don't have to copy this flag
> from prog->attr into cgroup. So this reset or non-reset discussion
> only makes sense in the context of your current implementation.
> We can implement the logic differently. Like don't copy that flag
> at all and at attach time walk parent->parent->parent and see
> what programs are attached. All of them should have prog->attr & recurse_bit set
> In such implementation detach from 'b' is a nop from reset/non-reset
> point of view. When socket creation in 'c' is invoked the program
> 'c' is called first then the code keeps walking parents until root
> invoking 'a' along the way.

So you are suggesting there is no recursive flag per cgroup? How do you
know you need to walk cgroups? How do you know when to stop running
programs?

> I'm not saying it will be an efficient implementation. The point
> is to discuss UAPI independent of implementation.
> 
>> ###
>>
>> Also, let's agree on this intention. Based on the new ground rule, I
>> want to point out this example:
>>
>> If 'a' gets a program installed with no recurse flag set, ONLY processes
>> in 'a' have the 'a' program run. Processes in groups 'b', 'c' and 'd'
>> all stop at cgroup 'b' program.
> 
> I'm proposing that such situation should not be allowed to happen.
> In a->b->c->d cgroup scenario if override+recurse prog attached to 'b'
> then only the same override+recurse can be attached to c, d, a.
> So at detach time there can be gaps (like only 'b' and 'd' have
> override+recurse progs), but walking up until root from any point
> will guarantee that only override+recurse programs are seen.
> 

That seems very limiting to me. Seems like you are suggesting the entire
cgroup tree is recursive or non-recursive, but never a mix.
