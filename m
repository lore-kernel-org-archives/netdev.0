From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_copy_to_user BPF helper to
 be called in tracers (kprobes)
Date: Tue, 19 Jul 2016 20:08:56 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1607191801140.3582@ircssh.c.rugged-nimbus-611.internal>
References: <20160719093242.GA23753@ircssh.c.rugged-nimbus-611.internal> <578E0C61.6070705@iogearbox.net> <20160719163443.GA57855@ast-mbp.thefacebook.com> <578EB597.2080608@iogearbox.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <578EB597.2080608@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 20 Jul 2016, Daniel Borkmann wrote:

> On 07/19/2016 06:34 PM, Alexei Starovoitov wrote:
>> On Tue, Jul 19, 2016 at 01:17:53PM +0200, Daniel Borkmann wrote:
>>>> +		return -EINVAL;
>>>> +
>>>> +	/* Is this a user address, or a kernel address? */
>>>> +	if (!access_ok(VERIFY_WRITE, to, size))
>>>> +		return -EINVAL;
>>>> +
>>>> +	return probe_kernel_write(to, from, size);
>>> 
>>> I'm still worried that this can lead to all kind of hard to find
>>> bugs or races for user processes, if you make this writable to entire
>>> user address space (which is the only thing that access_ok() checks
>>> for). What if the BPF program has bugs and writes to wrong addresses
>>> for example, introducing bugs in some other, non-intended processes
>>> elsewhere? Can this be limited to syscalls only? And if so, to the
>>> passed memory only?
>> 
>> my understanding that above code will write only to memory of current 
>> process,
>> so impact is contained and in that sense buggy kprobe program is no 
>> different
>> from buggy seccomp prorgram.
>
> Compared to seccomp, you might not notice that a race has happened,
> in seccomp case you might have killed your process, which is visible.
> But ok, in ptrace() case it might be similar issue perhaps ...
>
> The asm-generic version does __access_ok(..) { return 1; } for nommu
> case, I haven't checked closely enough whether there's actually an arch
> that uses this, but for example arm nommu with only one addr space would
> certainly result in access_ok() as 1, and then you could also go into
> probe_kernel_write(), no?
>
> Don't know that code well enough, but I believe the check would only
> ensure in normal use-cases that user process doesn't fiddle with kernel
> address space, but not necessarily guarantee that this really only
> belongs to the process address space.
>
You're right, it doesn't gaurantee that the memory being written to is the 
user, but only the current process should be mapped into that chunk of 
memory that is being operated at in the point in time. I think it'd be 
fairly difficult to write to another process' memory to corrupt it.

It also might make sense to me to call access_ok with a known kernel 
address, and either deny access to the bpf helper, or warn in dmesg saying 
that it is running in an environment without any protection.
-- I'm not sure if there is a preferred kernel address to check? What do 
you think?


> x86 code comments this with "note that, depending on architecture,
> this function probably just checks that the pointer is in the user
> space range - after calling this function, memory access functions may
> still return -EFAULT".
>
> Also, what happens in case of kernel thread?
It seems fairly reasonable to me to check task->flags & PF_KTHREAD in 
order to prevent this scenario since there is no memory to copy_to_user 
to.

>
> As it stands, it does ...
>
> 	if (unlikely(in_interrupt()))
> 		return -EINVAL;
> 	if (unlikely(!task || !task->pid))
> 		return -EINVAL;
>
> So up to here, irq/sirq, NULL current and that current is not the 'idle'
> process is being checked (still fail to see the point for the !task->pid,
> I believe the intend here is different).
>
> 	/* Is this a user address, or a kernel address? */
> 	if (!access_ok(VERIFY_WRITE, to, size))
> 		return -EINVAL;
>
> Now here. What if it's a kernel thread? You'll have KERNEL_DS segment,
> task->pid was non-zero as well for the kthread, so access_ok() will
> pass and you can still execute probe_kernel_write() ...
>
>> Limiting this to syscalls will make it too limited.
>> I'm in favor of this change, because it allows us to experiment
>> with restartable sequences and lock-free algorithms that need ultrafast
>> access to cpuid without burdening the kernel with stable abi.
>> 
>>> Have you played around with ptrace() to check whether you could
>>> achieve similar functionality (was thinking about things like [1],
>>> PTRACE_PEEK{TEXT,DATA} / PTRACE_POKE{TEXT,DATA}). If not, why can't
>>> this be limited to a similar functionality for only the current task.
>>> ptrace() utilizes helpers like access_process_vm(), maybe this can
>>> similarly be adapted here, too (under the circumstances that sleeping
>>> is not allowed)?
>> 
>> If we hack access_process_vm I think at the end it will look like
>> probe_kernel_write. Walking mm requires semaphore, so we would only
>> be able to do it in task_work and there we can do normal copy_to_user
>> just as well, but it will complicate the programs quite a bit, since
>> writes will be asynchronous and batched.
>> Looks like with access_ok+probe_write we can achieve the same
>> with a lot less code.
>
> I believe it may not quite be the same as it currently stands. No
> fundamental objection, just that this needs to be made "safe" to the
> limits you state above yourself. ;)
>
At least for my current use cases, doing this asynchronously could prove 
to be unworkable.

>> As far as races between user and bpf program, yeah, if process
>> is multithreaded, the other threads may access the same mem that
>> bpf is writing to, but that's no different from reading.
>> For tracing we walk complex datastructures and pointers. They
>> can be changed by user space on the fly and bpf will see garbage.
>> Like we have uprobe+bpf that walks clang c++ internal datastructures
>> to figure out how long it takes clang to process .h headers.
>> There is a lot of fragility in the bpf script, yet it's pretty
>> useful to quickly analyze compile times.
>> I see bpf_copy_to_user to be hugely valuable too, not as a stable
>> interface, but rather as a tool to quickly debug and experiment.
>
> Right, so maybe there should be a warn once to the dmesg log that this
> is just experimental?
>
> Thanks,
> Daniel
>
It seems reasonable to me to give people a heads up, that they have bpf 
programs that can modify user memory. I can add a warn once with along 
the lines of:
pr_warn_once("bpf_copy_to_user in use: Experimental feature, may 
corrupt memory");
--- I think that should scare people away to the downsides.

That warning along with verifying that the access_ok function is doing
useful things on their platform, and warning if it isn't seems to be a 
strong enough signal to people that might accidentally abuse it.
