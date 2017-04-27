From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 6/6] bpf: show bpf programs
Date: Thu, 27 Apr 2017 15:22:49 +0200
Message-ID: <5b1f23e3-86a7-69aa-91e2-1dc72125f22b@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
 <20170426182419.14574-7-hannes@stressinduktion.org>
 <590112BE.7040902@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:38977 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935050AbdD0NWv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 09:22:51 -0400
In-Reply-To: <590112BE.7040902@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.04.2017 23:35, Daniel Borkmann wrote:
> On 04/26/2017 08:24 PM, Hannes Frederic Sowa wrote:
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>>   include/uapi/linux/bpf.h | 32 +++++++++++++++++++-------------
>>   kernel/bpf/core.c        | 30 +++++++++++++++++++++++++++++-
>>   2 files changed, 48 insertions(+), 14 deletions(-)
>>
>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>> index e553529929f683..d6506e320953d5 100644
>> --- a/include/uapi/linux/bpf.h
>> +++ b/include/uapi/linux/bpf.h
>> @@ -101,20 +101,26 @@ enum bpf_map_type {
>>       BPF_MAP_TYPE_HASH_OF_MAPS,
>>   };
>>
>> +#define BPF_PROG_TYPES            \
>> +    X(BPF_PROG_TYPE_UNSPEC),    \
>> +    X(BPF_PROG_TYPE_SOCKET_FILTER),    \
>> +    X(BPF_PROG_TYPE_KPROBE),    \
>> +    X(BPF_PROG_TYPE_SCHED_CLS),    \
>> +    X(BPF_PROG_TYPE_SCHED_ACT),    \
>> +    X(BPF_PROG_TYPE_TRACEPOINT),    \
>> +    X(BPF_PROG_TYPE_XDP),        \
>> +    X(BPF_PROG_TYPE_PERF_EVENT),    \
>> +    X(BPF_PROG_TYPE_CGROUP_SKB),    \
>> +    X(BPF_PROG_TYPE_CGROUP_SOCK),    \
>> +    X(BPF_PROG_TYPE_LWT_IN),    \
>> +    X(BPF_PROG_TYPE_LWT_OUT),    \
>> +    X(BPF_PROG_TYPE_LWT_XMIT),
>> +
>> +
>>   enum bpf_prog_type {
>> -    BPF_PROG_TYPE_UNSPEC,
>> -    BPF_PROG_TYPE_SOCKET_FILTER,
>> -    BPF_PROG_TYPE_KPROBE,
>> -    BPF_PROG_TYPE_SCHED_CLS,
>> -    BPF_PROG_TYPE_SCHED_ACT,
>> -    BPF_PROG_TYPE_TRACEPOINT,
>> -    BPF_PROG_TYPE_XDP,
>> -    BPF_PROG_TYPE_PERF_EVENT,
>> -    BPF_PROG_TYPE_CGROUP_SKB,
>> -    BPF_PROG_TYPE_CGROUP_SOCK,
>> -    BPF_PROG_TYPE_LWT_IN,
>> -    BPF_PROG_TYPE_LWT_OUT,
>> -    BPF_PROG_TYPE_LWT_XMIT,
>> +#define X(type) type
> 
> Defining X in uapi could clash easily with other headers e.g.
> from application side.

I think that X-macros are so much used that code review should catch
that no X macro is leaked beyond its scope.

I certainly can use some other macro names, maybe something along the
line from bpf_types.h.

> 
>> +    BPF_PROG_TYPES
>> +#undef X
>>   };
>>
>>   enum bpf_attach_type {
>> diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
>> index 3ba175a24e971a..685c1d0f31e029 100644
>> --- a/kernel/bpf/core.c
>> +++ b/kernel/bpf/core.c
>> @@ -536,13 +536,41 @@ static void ebpf_proc_stop(struct seq_file *s,
>> void *v)
>>       rcu_read_unlock();
>>   }
>>
>> +static const char *bpf_type_string(enum bpf_prog_type type)
>> +{
>> +    static const char *bpf_type_names[] = {
>> +#define X(type) #type
>> +        BPF_PROG_TYPES
>> +#undef X
>> +    };
>> +
>> +    if (type >= ARRAY_SIZE(bpf_type_names))
>> +        return "<unknown>";
>> +
>> +    return bpf_type_names[type];
>> +}
>> +
>>   static int ebpf_proc_show(struct seq_file *s, void *v)
>>   {
>> +    struct bpf_prog *prog;
>> +    struct bpf_prog_aux *aux;
>> +    char prog_tag[sizeof(prog->tag) * 2 + 1] = { };
>> +
>>       if (v == SEQ_START_TOKEN) {
>> -        seq_printf(s, "# tag\n");
>> +        seq_printf(s, "# tag\t\t\ttype\t\t\truntime\tcap\tmemlock\n");
>>           return 0;
>>       }
>>
>> +    aux = v;
>> +    prog = aux->prog;
>> +
>> +    bin2hex(prog_tag, prog->tag, sizeof(prog->tag));
>> +    seq_printf(s, "%s\t%s\t%s\t%s\t%llu\n", prog_tag,
>> +           bpf_type_string(prog->type),
>> +           prog->jited ? "jit" : "int",
>> +           prog->priv_cap_sys_admin ? "priv" : "unpriv",
>> +           prog->pages * 1ULL << PAGE_SHIFT);
> 
> Yeah, so that would be quite similar to what we dump in
> bpf_prog_show_fdinfo() modulo the priv bit.

And, additionally, that you don't need to have a file descriptor handy
to do so, which is my main point.

> I generally agree that a facility for dumping all progs is needed
> and it was also on the TODO list after the bpf(2) cmd for dumping
> program insns back to user space.

I think this is orthogonal.

> I think the procfs interface has pro and cons: the upside is that
> you can use it with tools like cat to inspect it, but what you still
> cannot do is to say that you want to see the prog insns for, say,
> prog #4 from that list. If we could iterate over that list through fds
> via bpf(2) syscall, you could i) present the same info you have above
> via fdinfo already and ii) also dump the BPF insns from that specific
> program through a BPF_PROG_DUMP bpf(2) command. Once that dump also
> supports maps in progs, you could go further and fetch related map
> fds for inspection, etc.

Sure, that sounds super. But so far Linux and most (maybe I should write
all) subsystems always provided some easy way to get the insights of the
kernel without having to code or rely on special tools so far. And I
very much enjoyed that part on Linux. FreeBSD did very often abstract
some details behind shared libraries and commands that has no easy
pedant to use for with cat and grep.

> Such option of iterating through that would need a new BPF syscall
> cmd aka BPF_PROG_GET_NEXT which returns the first prog from the list
> and you would walk the next one by passing the current fd, which can
> later also be closed as not needed anymore. We could restrict that
> dump to capable(CAP_SYS_ADMIN), and the kernel tree would need to
> ship a tool e.g. under tools/bpf/ that can be used for inspection.
> 
Martin already posted his patches which add a bpf_prog_id to ebpf
programs. I will have alook at those and will comment over there.

Thansk for the review,
Hannes
