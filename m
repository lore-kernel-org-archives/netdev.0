From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf: avoid copying junk bytes in
 bpf_get_current_comm()
Date: Fri, 11 Mar 2016 09:20:04 -0800
Message-ID: <56E2FE44.7040904@fb.com>
References: <1457582553-395600-1-git-send-email-ast@fb.com>
 <56E29CDA.5010004@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tobias Waldekranz <tobias@waldekranz.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E29CDA.5010004@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/11/16 2:24 AM, Daniel Borkmann wrote:
> On 03/10/2016 05:02 AM, Alexei Starovoitov wrote:
>> Lots of places in the kernel use memcpy(buf, comm, TASK_COMM_LEN); but
>> the result is typically passed to print("%s", buf) and extra bytes
>> after zero don't cause any harm.
>> In bpf the result of bpf_get_current_comm() is used as the part of
>> map key and was causing spurious hash map mismatches.
>> Use strlcpy() to guarantee zero-terminated string.
>> bpf verifier checks that output buffer is zero-initialized,
>
> Sorry for late reply, more below:
>
>> so even for short task names the output buffer don't have junk bytes.
>> Note it's not a security concern, since kprobe+bpf is root only.
>>
>> Fixes: ffeedafbf023 ("bpf: introduce current->pid, tgid, uid, gid,
>> comm accessors")
>> Reported-by: Tobias Waldekranz <tobias@waldekranz.com>
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> [...]
>> diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
>> index 4504ca66118d..50da680c479f 100644
>> --- a/kernel/bpf/helpers.c
>> +++ b/kernel/bpf/helpers.c
>> @@ -166,7 +166,7 @@ static u64 bpf_get_current_comm(u64 r1, u64 size,
>> u64 r3, u64 r4, u64 r5)
>>       if (!task)
>>           return -EINVAL;
>>
>> -    memcpy(buf, task->comm, min_t(size_t, size, sizeof(task->comm)));
>> +    strlcpy(buf, task->comm, min_t(size_t, size, sizeof(task->comm)));
>
> If I see this correctly, __set_task_comm() makes sure comm is always zero
> terminated, so that seems good, but isn't it already sufficient when
> switching
> to strlcpy() to simply use:
>
>      strlcpy(buf, task->comm, size);
>
> The min_t() seems unnecessary work to me, why do we still need it? size
> is guaranteed to be > 0 through the eBPF verifier, so strlcpy() should take
> care of the rest.

that's one clever optimization. yep. we can drop min_t.
btw I wanted to add memset to __set_task_comm, keep memcpy in
bpf_get_current_comm and optimize perf_event_comm_event
(which doing: memset+strlcpy and can be replaced with memcpy),
but figured that such 'fix' is not suitable for stable.
I guess we can do in the next cycle? strlen is not cheap.
Especially since it turned out that bpf_get_current_comm() is
used very often in the hot path in bcc/tools.

Also for the next cycle I'm planning to extend verifier to
allow uninitialized stack to be passed to functions like
bpf_get_current_comm() and they would have to zero it in
error cases. Then we can save few more cycles from the programs.
