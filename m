From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH] bpf: fix range arithmetic for bpf map access
Date: Fri, 11 Nov 2016 14:09:11 -0500
Message-ID: <abd28bc8-c6ab-49c0-3050-4dabee9f2516@fb.com>
References: <CAG48ez0DyDoySPEkNqYnSEZpTXuuP2xheSuc_EQ+ZzmSwOGy6Q@mail.gmail.com>
 <1478823492-7335-1-git-send-email-jbacik@fb.com>
 <CAG48ez1c_s-S8dh=37Pj5XOCUbQ1C3SyJGWd7dXhEA2D2+ps9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jann Horn <jannh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43403 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934591AbcKKTJi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 14:09:38 -0500
In-Reply-To: <CAG48ez1c_s-S8dh=37Pj5XOCUbQ1C3SyJGWd7dXhEA2D2+ps9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2016 11:36 AM, Jann Horn wrote:
> On Fri, Nov 11, 2016 at 1:18 AM, Josef Bacik <jbacik@fb.com> wrote:
>> ---
>> Sorry Jann, I saw your response last night and then promptly forgot about it,
>> here's the git-send-email version.
>> ---
>
> A note: This doesn't seem to apply cleanly to current net-next (or I'm
> too stupid to
> use "git am"), so I'm applying it on f41cd11d64b2b21012eb4abffbe579bc0b90467f,
> which is net-next from a few days ago.
>

Yeah Dave pulled in a cleanup fix like right after I rebased onto net-next, I'll 
rebase again before I send the next patch.

>
>> I made some invalid assumptions with BPF_AND and BPF_MOD that could result in
>> invalid accesses to bpf map entries.  Fix this up by doing a few things
>>
>> 1) Kill BPF_MOD support.  This doesn't actually get used by the compiler in real
>> life and just adds extra complexity.
>
> Yay! As a security person, I am very much in favor of killing unused features.
>

I almost dropped AND but thought better of it ;).

>
>> 2) Fix the logic for BPF_AND.  If the min value is negative then that is the new
>> minimum, otherwise it is unconditionally 0.
>>
>> 3) Don't do operations on the ranges if they are set to the limits, as they are
>> by definition undefined, and allowing arithmetic operations on those values
>> could make them appear valid when they really aren't.
>>
>> This fixes the testcase provided by Jann as well as a few other theoretical
>> problems.
>>
>> Reported-by: Jann Horn <jannh@google.com>
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>
> A nit: check_mem_access() still has an explicit cast of reg->min_value to s64, I
> think that's not necessary anymore?

Yup just missed that, I'll fix it.

>
>>         case BPF_AND:
>> -               /* & is special since it could end up with 0 bits set. */
>> -               dst_reg->min_value &= min_val;
>> +               /* & is special since it's could be any value within our range,
>> +                * including 0.  But if the thing we're AND'ing against is
>> +                * negative and we're negative then that's the minimum value,
>> +                * otherwise the minimum will always be 0.
>> +                */
>> +               if (min_val < 0 && dst_reg->min_value < 0)
>> +                       dst_reg->min_value = min_t(s64, dst_reg->min_value,
>> +                                                  min_val);
>> +               else
>> +                       dst_reg->min_value = 0;
>>                 dst_reg->max_value = max_val;
>
> I'm not sure whether this is correct when dealing with signed numbers.
> Let's say I have -2 and -3 (as u32: 0xfffffffe and 0xfffffffd) and AND them
> together. The result is 0xfffffffc, or -4, right? So if I just compute
> the AND of
> constant numbers -2 and -3 (known to the verifier), the verifier would
> compute minimum -3 while the actual value is -4, right?
>
> If I am correct about this, I think it might make sense to just reset
> the state to
> unknown in the `min_val < 0 && dst_reg->min_value < 0` case. That shouldn't
> occur in legitimate programs, right?
>

Yeah actually I think you are right, we'll just assume that AND'ing negative 
values means you did something wrong and set it to the RANGE_MIN value.  Thanks!

Josef
