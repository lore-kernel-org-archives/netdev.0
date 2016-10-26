From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Wed, 26 Oct 2016 10:33:54 +0200
Message-ID: <58106A72.4050306@iogearbox.net>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com> <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com> <580FEA98.1090809@iogearbox.net> <660435c4-6cea-9648-0106-afb3ab6910fc@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@zonque.org, ast@fb.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56828 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752666AbcJZId7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 04:33:59 -0400
In-Reply-To: <660435c4-6cea-9648-0106-afb3ab6910fc@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2016 04:05 AM, David Ahern wrote:
> On 10/25/16 5:28 PM, Daniel Borkmann wrote:
>>> +BPF_CALL_3(bpf_sock_store_u32, struct sock *, sk, u32, offset, u32, val)
>>> +{
>>> +    u8 *ptr = (u8 *)sk;
>>> +
>>> +    if (unlikely(offset > sizeof(*sk)))
>>> +        return -EFAULT;
>>> +
>>> +    *((u32 *)ptr) = val;
>>> +
>>> +    return 0;
>>> +}
>>
>> Seems strange to me. So, this helper allows to overwrite arbitrary memory
>> of a struct sock instance. Potentially we could crash the kernel.
>>
>> And in your sock_filter_convert_ctx_access(), you already implement inline
>> read/write for the context ...
>>
>> Your demo code does in pseudocode:
>>
>>    r1 = sk
>>    r2 = offsetof(struct bpf_sock, bound_dev_if)
>>    r3 = idx
>>    r1->sk_bound_dev_if = idx
>>    sock_store_u32(r1, r2, r3) // updates sk_bound_dev_if again to idx
>>    return 1
>>
>> Dropping that helper from the patch, the only thing a program can do here
>> is to read/write the sk_bound_dev_if helper per cgroup. Hmm ... dunno. So
>> this really has to be for cgroups v2, right?
>
> Showing my inexperience with the bpf code. The helper can be dropped. I'll do that for v2.
>
> Yes, Daniel's patch set provides the infra for this one and it has a cgroups v2 limitation.

Sure, I understand that, and I know it was brought up at netconf, I'm
just still wondering in general if BPF is a good fit here in the sense
that what the program can do is just really really limited (at least
right now). Hmm, just trying to understand where this would go long term.
Probably okay'ish, if it's guaranteed that it can also integrate various
other use cases as well for the new program type like the ones proposed
by Anoop from net cgroup.

If that would reuse BPF_PROG_TYPE_CGROUP_SOCK from not only sk_alloc()
hook, programs can thus change sk_bound_dev_if also from elsewhere since
it's a fixed part of the context, and attaching to the cgroup comes after
program was verified and returned a program fd back to the user. I guess
it might be expected, right?

I mean non-cooperative processes in that cgroup could already overwrite
the policy set in sk_alloc() anyway with SO_BINDTODEVICE, no? What is the
expectation if processes are moved from one cgroup to another one? Is it
expected that also sk_bound_dev_if updates (not yet seeing how that would
work from a BPF program)? If sk_bound_dev_if is enforced from cgroup side,
should that lock out processes from changing it (maybe similar to what we
do in SOCK_FILTER_LOCKED)?
