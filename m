From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 master] bpf: provide fallback defs for __NR_bpf
 when not avail
Date: Thu, 15 Jun 2017 14:49:37 +0200
Message-ID: <59428261.70004@iogearbox.net>
References: <b59b84be59bccbab994072fdd9969b5d8a483f12.1497480167.git.daniel@iogearbox.net>        <20170614155648.4cfd7a73@xeon-e3>        <5941C03A.6010107@iogearbox.net> <20170614163408.4a04c191@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37589 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752397AbdFOMtl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 08:49:41 -0400
In-Reply-To: <20170614163408.4a04c191@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/2017 01:34 AM, Stephen Hemminger wrote:
> On Thu, 15 Jun 2017 01:01:14 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> On 06/15/2017 12:56 AM, Stephen Hemminger wrote:
>>> On Thu, 15 Jun 2017 00:47:15 +0200
>>> Daniel Borkmann <daniel@iogearbox.net> wrote:
>>>
>>>> panji reported that he wasn't able to build iproute2's bpf library
>>>> due to lack of __NR_bpf in his system headers. Providing a fallback
>>>> definition when __NR_bpf is not available in the system lets the
>>>> loader compile just fine, so lets add them for majority of archs.
>>>>
>>>> Reported-by: panji <jpan@live.nl>
>>>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>>>> ---
>>>>    lib/bpf.c | 20 ++++++++++++++++++++
>>>>    1 file changed, 20 insertions(+)
>>>>
>>>> diff --git a/lib/bpf.c b/lib/bpf.c
>>>> index ae4d97d..e1e29cc 100644
>>>> --- a/lib/bpf.c
>>>> +++ b/lib/bpf.c
>>>> @@ -128,6 +128,26 @@ static inline __u64 bpf_ptr_to_u64(const void *ptr)
>>>>    	return (__u64)(unsigned long)ptr;
>>>>    }
>>>>
>>>> +#ifndef __NR_bpf
>>>> +# if defined(__i386__)
>>>> +#  define __NR_bpf 357
>>>> +# elif defined(__x86_64__)
>>>> +#  define __NR_bpf 321
>>>> +# elif defined(__aarch64__)
>>>> +#  define __NR_bpf 280
>>>> +# elif defined(__sparc__)
>>>> +#  define __NR_bpf 349
>>>> +# elif defined(__arm__)
>>>> +#  define __NR_bpf 386
>>>> +# elif defined(__powerpc__)
>>>> +#  define __NR_bpf 361
>>>> +# elif defined(__s390__)
>>>> +#  define __NR_bpf 351
>>>> +# else
>>>> +#  error __NR_bpf not defined. Update kernel headers.
>>>> +# endif
>>>> +#endif
>>>> +
>>>>    static int bpf(int cmd, union bpf_attr *attr, unsigned int size)
>>>>    {
>>>>    #ifdef __NR_bpf
>>>
>>> Sorry this looks like a mess. enumerating architectures in two different
>>> projects is likely to break in future.
>>
>> It says ifndef __NR_bpf, so only used then. And the numbers are uabi,
>> what will break here exactly? libbpf in kernel tree is having a similar
>> approach by the way.
>
> You are defining values in two places (kernel and userspace) which has caused
> lots of mismatch in the past. Why isn't this in a kernel uapi header somewhere?

Well, it is architecture specific uapi in asm/unistd*.h usually, but I
don't think you want to go down that road to pull _that_ into iproute2,
that would be quite a mess for very little gain, imho. I would also be
okay if we drop this patch given it's a (presumably) corner case where
people have old kernel headers installed, running a newer kernel on their
machine and trying to compile iproute2. Worst case they have to pull in
this patch manually from patchwork then, but over time distros eventually
catch up to ship a unistd header with more recent syscall number defines.

Thanks,
Daniel
