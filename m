From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_copy_to_user BPF helper
 to be called in tracers (kprobes)
Date: Wed, 20 Jul 2016 12:05:23 +0200
Message-ID: <578F4CE3.50700@iogearbox.net>
References: <20160719093242.GA23753@ircssh.c.rugged-nimbus-611.internal> <578E0C61.6070705@iogearbox.net> <20160719163443.GA57855@ast-mbp.thefacebook.com> <578EB597.2080608@iogearbox.net> <20160720030200.GA70500@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sargun Dhillon <sargun@sargun.me>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55911 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012AbcGTKF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 06:05:26 -0400
In-Reply-To: <20160720030200.GA70500@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2016 05:02 AM, Alexei Starovoitov wrote:
> On Wed, Jul 20, 2016 at 01:19:51AM +0200, Daniel Borkmann wrote:
>> On 07/19/2016 06:34 PM, Alexei Starovoitov wrote:
>>> On Tue, Jul 19, 2016 at 01:17:53PM +0200, Daniel Borkmann wrote:
>>>>> +		return -EINVAL;
>>>>> +
>>>>> +	/* Is this a user address, or a kernel address? */
>>>>> +	if (!access_ok(VERIFY_WRITE, to, size))
>>>>> +		return -EINVAL;
>>>>> +
>>>>> +	return probe_kernel_write(to, from, size);
>>>>
>>>> I'm still worried that this can lead to all kind of hard to find
>>>> bugs or races for user processes, if you make this writable to entire
>>>> user address space (which is the only thing that access_ok() checks
>>>> for). What if the BPF program has bugs and writes to wrong addresses
>>>> for example, introducing bugs in some other, non-intended processes
>>>> elsewhere? Can this be limited to syscalls only? And if so, to the
>>>> passed memory only?
>>>
>>> my understanding that above code will write only to memory of current process,
>>> so impact is contained and in that sense buggy kprobe program is no different
>> >from buggy seccomp prorgram.
>>
>> Compared to seccomp, you might not notice that a race has happened,
>> in seccomp case you might have killed your process, which is visible.
>> But ok, in ptrace() case it might be similar issue perhaps ...
>>
>> The asm-generic version does __access_ok(..) { return 1; } for nommu
>> case, I haven't checked closely enough whether there's actually an arch
>> that uses this, but for example arm nommu with only one addr space would
>> certainly result in access_ok() as 1, and then you could also go into
>> probe_kernel_write(), no?
>
> good point. how arm nommu handles copy_to_user? if there is nommu

Should probably boil down to something similar as plain memcpy().

> then there is no user/kernel mm ? Crazy archs.
> I guess we have to disable this helper on all such archs.
>
>> Don't know that code well enough, but I believe the check would only
>> ensure in normal use-cases that user process doesn't fiddle with kernel
>> address space, but not necessarily guarantee that this really only
>> belongs to the process address space.
>
> why? on x86 that exactly what it does. access_ok=true means
> it's user space address and since we're in _this user context_
> probe_kernel_write can only affect this user.
>
>> x86 code comments this with "note that, depending on architecture,
>> this function probably just checks that the pointer is in the user
>> space range - after calling this function, memory access functions may
>> still return -EFAULT".
>
> Yes. I've read that comment to :)
> Certainly not an expert, but the archs I've looked at, access_ok
> has the same meaning as on x86. They check the space range to
> make sure address doesn't belong to kernel.
> Could I have missed something? Certainly. Please double check :)
>
>> Also, what happens in case of kernel thread?
>
> my understanding if access_ok(addr)=true the addr will never point
> to memory of kernel thread.

If you're coming from user context only, this should be true, it'll
check whether it's some user space pointer.

>> As it stands, it does ...
>>
>> 	if (unlikely(in_interrupt()))
>> 		return -EINVAL;
>> 	if (unlikely(!task || !task->pid))
>> 		return -EINVAL;
>>
>> So up to here, irq/sirq, NULL current and that current is not the 'idle'
>> process is being checked (still fail to see the point for the !task->pid,
>> I believe the intend here is different).
>>
>> 	/* Is this a user address, or a kernel address? */
>> 	if (!access_ok(VERIFY_WRITE, to, size))
>> 		return -EINVAL;
>>
>> Now here. What if it's a kernel thread? You'll have KERNEL_DS segment,
>> task->pid was non-zero as well for the kthread, so access_ok() will
>> pass and you can still execute probe_kernel_write() ...
>
> I think user_addr_max() should be zero for kthread, but
> worth checking for sure.

It's 0xffffffffffffffff, I did a quick test yesterday night with
creating a kthread, so access_ok() should pass for such case.
