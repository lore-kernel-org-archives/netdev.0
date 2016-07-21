From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_copy_to_user BPF helper
 to be called in tracers (kprobes)
Date: Thu, 21 Jul 2016 13:30:14 +0200
Message-ID: <5790B246.6020905@iogearbox.net>
References: <20160719093242.GA23753@ircssh.c.rugged-nimbus-611.internal> <578E0C61.6070705@iogearbox.net> <20160719163443.GA57855@ast-mbp.thefacebook.com> <578EB597.2080608@iogearbox.net> <20160720030200.GA70500@ast-mbp.thefacebook.com> <alpine.DEB.2.02.1607200133350.13397@ircssh.c.rugged-nimbus-611.internal> <579002A3.3090406@iogearbox.net> <20160721104705.GA3446@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160721104705.GA3446@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/21/2016 12:47 PM, Sargun Dhillon wrote:
> On Thu, Jul 21, 2016 at 01:00:51AM +0200, Daniel Borkmann wrote:
[...]
>> I don't really like couple of things, your ifdef CONFIG_MMU might not be
>> needed I think, couple of these checks seem redundant, (I'm not yet sure
>> about the task->mm != task->active_mm thingy), the helper should definitely
>> be gpl_only and ARG_PTR_TO_RAW_STACK is just buggy. Also, this should be
>> a bit analogue to bpf_probe_read we have. How about something roughly along
>> the lines of below diff (obviously needs extensive testing ...)? This
>> can still do all kind of ugly crap to the user process, but limited to
>> the cap_sys_admin to shoot himself in the foot.
> * You're right about CONFIG_MMU. We don't need it, all of the nommu platforms
> properly deal with it from my research.

The segment_eq() test should generically catch this from what I see.

> It was always ARG_PTR_TO_STACK? Or are you saying ARG_PTR_TO_STACK is buggy and
> we should make it ARG_PTR_TO_RAW_STACK?

No, in your patch, you had '+    .arg2_type    = ARG_PTR_TO_RAW_STACK,',
which is not correct as it means you don't need to initialize the memory
you pass in for your *src pointer. I believe you took this over from
probe_read(), but there it's correct. ARG_PTR_TO_STACK means the verifier
checks that it's initialized with data.

> I originally named the function bpf_probe_write. Upon further thought I don't
> think that makes sense. The reason is because bpf_probe_read is analogous to
> probe_kernel_read. If we had bpf_probe_write, I think people might reason it to
> be equivalent to probe_kernel_write, and be confused when they can't write to
> kernel space.

I still think that bpf_probe_write is the more appropriate name, and that
the -EPERM are also better than -EINVAL. For user space, you'll have the
bpf_probe_read() / bpf_probe_write() pair you can use, which is the more
intuitive complement, also since people might already use bpf_probe_read(),
so they kind of can infer its meaning. It's just that the kernel doesn't
give you _permission_ to mess with kernel memory, hence due to not being
allowed -EPERM to make this absolutely clear to the user that this is illegal.
-EINVAL usually means one of the function arguments might be wrong, I think
-EPERM is a better / more clear fit in this case, imho.

> I tried to make the external facing documentaion close to copy_to_user. That's
> how people should use it, not like _write. Therefor I think it makes sense to
> keep that the name.

But still, you *probe* to write somewhere to the process' address space,
so it can still fail with -EFAULT. Other than that, see comment above.

> I added a check for (!task) -- It seems to be spattered throughou the eBPF
> helper code. Alexei mentioned earlier that it can be null, but I'm not sure of
> the case

Well, the test of unlikely(in_interrupt() || (task->flags & PF_KTHREAD))
will cover these cases. It makes sure that you're neither in hardirq (NULL
here) nor softirq and that you're not in a kthread.

> RE: task->mm != task->active_mm -- There are a couple scenarios where kthreads
> do this, and the only user call that should hit this is execve. There's only a
> brief period where this can be true and I don't think it's worth dealing with
> that case -- I'm not really sure you can plant a kprobe at the right site either

But if kthreads do this, wouldn't this already be covered by task->flags &
PF_KTHREAD test for such case?

> Did some minimal testing with tracex7 and others.

Ok, great!

> I was able to copy memory into other process's space while certain
> syscalls were going on. I don't think that there are a reasonable set of
> protections.

Right, it doesn't prevent that syscalls going on in parallel.

> I'll do more testing. Any suggestions of what might break? I've looked at
> writing to unitialized memory, Memory out of bounds, etc... Do you know of any
> "weak spots"?

Well, you could write into text/data, stack, etc for the user process so
quite a bit. ;) Or do you mean wrt kernel space? If someone runs some binary
installing such a proglet, I think it would also make sense to print a message
(rate-limited) to the klog with current->comm, task_pid_nr(current) for the
process installing this, from verifier side I mean. Maybe makes more sense
than the print-once from the helper side.

Thanks,
Daniel
