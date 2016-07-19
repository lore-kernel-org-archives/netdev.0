From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_copy_to_user BPF helper to
 be called in tracers (kprobes)
Date: Tue, 19 Jul 2016 10:13:16 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1607190950470.29512@ircssh.c.rugged-nimbus-611.internal>
References: <20160719093242.GA23753@ircssh.c.rugged-nimbus-611.internal> <578E0C61.6070705@iogearbox.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <578E0C61.6070705@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 19 Jul 2016, Daniel Borkmann wrote:

> Hi Sargun,
>
> On 07/19/2016 11:32 AM, Sargun Dhillon wrote:
>> This allows user memory to be written to during the course of a kprobe.
>> It shouldn't be used to implement any kind of security mechanism
>> because of TOC-TOU attacks, but rather to debug, divert, and
>> manipulate execution of semi-cooperative processes.
>> 
>> Although it uses probe_kernel_write, we limit the address space
>> the probe can write into by checking the space with access_ok.
>> This call shouldn't sleep on any architectures based on review.
>> 
>> It was tested with the tracex7 program on x86-64.
>> 
>> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
>> Cc: Alexei Starovoitov <ast@kernel.org>
> [...]
>> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
>> index ebfbb7d..45878f3 100644
>> --- a/kernel/trace/bpf_trace.c
>> +++ b/kernel/trace/bpf_trace.c
>> @@ -81,6 +81,35 @@ static const struct bpf_func_proto bpf_probe_read_proto 
>> = {
>>   	.arg3_type	= ARG_ANYTHING,
>>   };
>> 
>> +static u64 bpf_copy_to_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
>> +{
>> +	void *to = (void *) (long) r1;
>> +	void *from = (void *) (long) r2;
>> +	int  size = (int) r3;
>
> Nit: you have two spaces here?
>
>> +	struct task_struct *task = current;
>> +
>> +	/* check if we're in a user context */
>> +	if (unlikely(in_interrupt()))
>> +		return -EINVAL;
>> +	if (unlikely(!task || !task->pid))
>
> Why !task->pid is needed? Can you point to the code where this is
> set up as such? I'd assume if that's the case, there's a generic
> helper for it to determine that the task_struct is a kernel task?
>

One example of precedent:
http://lxr.free-electrons.com/source/arch/x86/kernel/process.c#L270

Also, while testing this out, I instrumented ip_route_output_flow,
and I found that there were cases that were invoked from the kernel
there current was not NULL, but task->pid was reliably 0.

>> +		return -EINVAL;
>> +
>> +	/* Is this a user address, or a kernel address? */
>> +	if (!access_ok(VERIFY_WRITE, to, size))
>> +		return -EINVAL;
>> +
>> +	return probe_kernel_write(to, from, size);
>
> I'm still worried that this can lead to all kind of hard to find
> bugs or races for user processes, if you make this writable to entire
> user address space (which is the only thing that access_ok() checks
> for). What if the BPF program has bugs and writes to wrong addresses
> for example, introducing bugs in some other, non-intended processes
> elsewhere? Can this be limited to syscalls only? And if so, to the
> passed memory only?
>
> Have you played around with ptrace() to check whether you could
> achieve similar functionality (was thinking about things like [1],
> PTRACE_PEEK{TEXT,DATA} / PTRACE_POKE{TEXT,DATA}). If not, why can't
> this be limited to a similar functionality for only the current task.
> ptrace() utilizes helpers like access_process_vm(), maybe this can
> similarly be adapted here, too (under the circumstances that sleeping
> is not allowed)?
>
>  [1] https://code.google.com/archive/p/ptrace-parasite/
>
I agree that this can get really complicated if it clashes with memory
that a task is currently manipulating while we do the copy_to_user.
I highlighted that in one of the commit messages not to rely on this
behaviour for anything "real" because TOC-TOU.

We could limit the use to be within syscalls and uprobes if you think
that's the best idea. Is there an easy way to find out, but I think
it's somewhat difficult to restrict it to passed memory only. In the
example app there's only one level of indirection that occurs,
and without some new rules in the verifier, I don't how to handle
this. A simple, problematic example is dealing with iovecs, and 
process_vm_readv, and process_vm_writev, where to find the actual buffer 
content I need to dereference once to get the list of iovecs, and then 
again, to find the buffer the iovec points to.

We looked at using ptrace, but our software is often working with blackbox 
code that sometimes does not like to ptrace'd. ptrace is kinda also a pain 
to work with, and has the same potential for data races you highlighted 
earlier. In fact, we have a demo of tracex7 that uses ptrace + 
process_vm_writev + seccomp, and it's much more complicated and fragile.

Just casually poking around, it looks like access_process_vm sleeps, 
resulting in a whole new set of complexities that Alexei highlighted 
earlier.

>> +}
>> +
>> +static const struct bpf_func_proto bpf_copy_to_user_proto = {
>> +	.func = bpf_copy_to_user,
>> +	.gpl_only = false,
>> +	.ret_type = RET_INTEGER,
>> +	.arg1_type = ARG_ANYTHING,
>> +	.arg2_type = ARG_PTR_TO_RAW_STACK,
>> +	.arg3_type = ARG_CONST_STACK_SIZE,
>
> Nit: please tab-align '=' like we have in the other *_proto cases in
> bpf_trace.
>
>> +};
>> +
>>   /*
>>    * limited trace_printk()
>>    * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers 
>> allowed
>
> Thanks,
> Daniel
>
Thanks for the review. Unless there's any other input, I'll go ahead and 
resubmit the patchset with the formatting nits fixed.
