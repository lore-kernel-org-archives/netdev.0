From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v2 net-next 3/6] tools/lib/bpf: expose
 bpf_program__set_type()
Date: Sat, 1 Apr 2017 13:32:52 +0800
Message-ID: <f2fb0cf4-50fd-4623-1097-e2a8c42cc910@huawei.com>
References: <20170331044543.4075183-1-ast@fb.com>
 <20170331044543.4075183-4-ast@fb.com>
 <a6aaf1e1-9c4e-ee4e-172e-9e9701aca96e@huawei.com>
 <9bf13cb9-c139-1706-d75e-e6e34d5136f6@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:5290 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750808AbdDAFdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 01:33:31 -0400
In-Reply-To: <9bf13cb9-c139-1706-d75e-e6e34d5136f6@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/4/1 11:18, Alexei Starovoitov wrote:
> On 3/31/17 7:29 PM, Wangnan (F) wrote:
>>
>>
>> On 2017/3/31 12:45, Alexei Starovoitov wrote:
>>> expose bpf_program__set_type() to set program type
>>>
>>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>>> Acked-by: Martin KaFai Lau <kafai@fb.com>
>>> ---
>>>   tools/lib/bpf/libbpf.c | 3 +--
>>>   tools/lib/bpf/libbpf.h | 2 ++
>>>   2 files changed, 3 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
>>> index ac6eb863b2a4..1a2c07eb7795 100644
>>> --- a/tools/lib/bpf/libbpf.c
>>> +++ b/tools/lib/bpf/libbpf.c
>>> @@ -1618,8 +1618,7 @@ int bpf_program__nth_fd(struct bpf_program
>>> *prog, int n)
>>>       return fd;
>>>   }
>>>   -static void bpf_program__set_type(struct bpf_program *prog,
>>> -                  enum bpf_prog_type type)
>>> +void bpf_program__set_type(struct bpf_program *prog, enum
>>> bpf_prog_type type)
>>>   {
>>>       prog->type = type;
>>>   }
>>
>> Since it become a public interface, we need to check if prog is a
>> NULL pointer and check if the value of type is okay, and let it
>> return an errno.
>
> I strongly disagree with such defensive programming. It's a cause
> of bugs for users of this library.
> I think you're trying to mimic c++ setters/getters, but c++
> never checks 'this != null', since passing null into setter
> is a bug of the user of the library and not the library.
> The setters also should have 'void' return type when setters
> cannot fail. That is exactly the case here.
> If, in the future, we decide that this libbpf shouldn't support
> all bpf program types then you'd need to change the prototype
> of this function to return error code and change all places
> where this function is called to check for error code.
> It may or may not be the right approach.
> For example today the only user of bpf_program__set*() methods
> is perf/util/bpf-loader.c and it calls bpf_program__set_kprobe() and
> bpf_program__set_tracepoint() _without_ checking the return value
> which is _correct_ thing to do. Instead the current prototype of
> 'int bpf_program__set_tracepoint(struct bpf_program *prog);
> is not correct and I suggest you to fix it.
>
> You also need to do other cleanup. Like in bpf_object__elf_finish()
> you have:
>         if (!obj_elf_valid(obj))
>                 return;
>
>         if (obj->efile.elf) {
>
> which is redundant. It's another example where mistakes creep in
> due to defensive programming.
>
> Another bug in bpf_object__close() which does:
>         if (!obj)
>                 return;
> again defensive programming strikes, since
> you're not checking IS_ERR(obj) and that's what bpf_object__open()
> returns, so most users of the library (who don't read the source
> code and just using it based on .h) will do
>
> obj = bpf_object__open(...);
> bpf_object__close(obj);
>
> and current 'if (!obj)' won't help and it will segfault.
> I hit this issue will developing this patch set.
>
>>> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
>>> index b30394f9947a..32c7252f734e 100644
>>> --- a/tools/lib/bpf/libbpf.h
>>> +++ b/tools/lib/bpf/libbpf.h
>>> @@ -25,6 +25,7 @@
>>>   #include <stdint.h>
>>>   #include <stdbool.h>
>>>   #include <sys/types.h>  // for size_t
>>> +#include <linux/bpf.h>
>>>     enum libbpf_errno {
>>>       __LIBBPF_ERRNO__START = 4000,
>>> @@ -185,6 +186,7 @@ int bpf_program__set_sched_cls(struct bpf_program
>>> *prog);
>>>   int bpf_program__set_sched_act(struct bpf_program *prog);
>>>   int bpf_program__set_xdp(struct bpf_program *prog);
>>>   int bpf_program__set_perf_event(struct bpf_program *prog);
>>> +void bpf_program__set_type(struct bpf_program *prog, enum
>>> bpf_prog_type type);
>>>
>>
>> The above bpf_program__set_xxx become redundancy. It should be generated
>> using macro as static inline functions.
>>
>>>   bool bpf_program__is_socket_filter(struct bpf_program *prog);
>>>   bool bpf_program__is_tracepoint(struct bpf_program *prog);
>>
>> bpf_program__is_xxx should be updated like bpf_program__set_xxx, since
>> enum bpf_prog_type is not a problem now.
>
> All of these suggestions is a cleanup for your code that you
> need to do yourself. I actually suggest you kill all bpf_program__is*()
> and all but one bpf_program__set*() functions.
> The current user perf/util/bpf-loader.c should be converted
> to using bpf_program__set_type() with _void_ return code that
> I'm introducing here.
>
> Overall, I think, tools/lib/bpf/ is a nice library and it can be used
> by many projects, but I suggest to stop making excuses based on
> your proprietary usage of it.
>
> Also please cc me in the future on changes to the library. It still
> has my copyrights, though a lot has changed, since last time
> I looked at it and it's my fault for not pay attention earlier.
>

OK. Then let your patch be merged first then let me do the code cleanup.

Thank you.
