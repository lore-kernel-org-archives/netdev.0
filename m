From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net-next 0/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Mon, 11 Jan 2016 10:20:55 +0800
Message-ID: <CACVXFVNfRLL-TQajPHD1XKnFCgyTvU_dAJQ0+HxwYQX4qC1G8A@mail.gmail.com>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
	<CACVXFVNhEOrroAfiEOC32dB3ZV=73WYJxUtNrpqEE94tvY2fXw@mail.gmail.com>
	<20160109004443.GA33292@kafai-mba.local>
	<CACVXFVPbsqBoAvgRjrm7A3S2G0kUrEt=e64FyRpoSqO2ukHncQ@mail.gmail.com>
	<20160110022946.GA50678@kevintjones-mbp.dhcp.thefacebook.com.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f194.google.com ([209.85.160.194]:34340 "EHLO
	mail-yk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757711AbcAKCU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 21:20:56 -0500
In-Reply-To: <20160110022946.GA50678@kevintjones-mbp.dhcp.thefacebook.com.DHCP.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

On Sun, Jan 10, 2016 at 10:30 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> Hi Ming,
>
> On Sat, Jan 09, 2016 at 05:39:16PM +0800, Ming Lei wrote:
>> On Sat, Jan 9, 2016 at 8:44 AM, Martin KaFai Lau <kafai@fb.com> wrote:
>> > On Fri, Jan 08, 2016 at 02:55:32PM +0800, Ming Lei wrote:
>> >> On Fri, Jan 8, 2016 at 6:35 AM, Martin KaFai Lau <kafai@fb.com> wrote:
>> >> > This patchset adds BPF_MAP_TYPE_PERCPU_HASH map type which allows
>> >> > percpu value.
>> >>
>> >> I am also thinking about using percpu variable to ebpf map, but IMO it
>> >> should be better for ARRAY map instead of HASH map, then we can
>> >> avoid the atomic op in eBPF program, see example of tracex3, sockex1
>> >> and sockex3 in sample/bpf/ of kernel tree.  Also looks the ARRAY map
>> >> usage in bcc is wrong, strictly speaking.
>> > array and hash are two different use cases. May be we should have percpu
>> > value for array map too.
>>
>> Atomic operations are definitely expensive, which should have been avoided
>> in eBPF prog by percpu way. I think ARRAY map does need percpu way more, :-)
>>
>> But for hash map, I am still not 100% sure if percpu is needed:
>>
>> - key plus cpu_id is ok
>> - key often can be chosed so that the mapped value is accessed without
>> race(such as, req is used as key in biolatency, ...)
>> - percpu hash can cause huge memory consumption compared with the way
>> of key plus cpu_id without obvious performance advantage
> If the bpf prog uses the percpu map type, the expectation
> is the bpf is tapping some kprobes that most cpus (if not all) will access
> the same key.  I would argue that having a bigger key (due to cpu_id),

I think you mean the value mapped from the key can be accessed
concurrently from most cpus.

> and 40 more keys (and linking to 40 buckets) is less efficient.

Suppose the key is choosed in this way and may be accessed concurrently
from most cpus, the only extra loading for (real_key, cpu_id) is in memcmp(),
because key size is increased by sizeof(cpu_id), is it really a big deal?

Also in your percpu patch, you add one extra alloc_percpu_gfp(), do you
think that it is cheaper than the extra compasion on cpu_id in memcmp()?

>
> If the expectation is to have a small numbers of cpu accessing a key (like
> biolatency), the bpf prog can stay with the regular bpf map.  The new
> percpu map has almost the same interface (except the syscall added in
> Patch 3).

> Switching between the two map types is easy.

No, it isn't easy with your patchset, since we can't look up
one key in one specific CPU from eBPF prog, not mention you
introduce extra syscall.

>
>> >> For HASH map, it is easy to make cpu id as part of key, then the map
>> >> can be thought as percpu too, and atomic op isn't needed in eBPF program.
>> > Putting the cpu id as part of the key was indeed the first hack I did
>> > to get a sense of potential benefit.
>> >
>> > However, by extending the real-key with cpu-id, it is not intuitive to
>> > use and it is prone to error.  For example, how to delete a real-key for
>> > all cpus?  Iterating a particular real-key for all cpu is also tricky.  What
>> > does it mean if a real-key exists for cpu#0 but not cpu#1? The real-key
>>
>> lookup returns NULL if the key(real key plus cpu id) doesn't exist.
>>
>> > got deleted from all cpu while iterating? or something else?  I believe
>> > there are ways to get around but it is better to provide a clean
>> > implementation instead.
>>
>> It might be true, but I hope there is one real example, in which we can
>> see the obvious disadvantage of real key plus cpu_id. In the other way,
>> we still can improve current hash map to make this case easier to use.
> By extend(real_key, cpu_id), the uniqueness property of a real_key (and
> it should be as a key for a hashmap) is getting blurry and it is not
> ideal.
>
> The typical use case is for doing a lot of aggregation (which bpf+kprobe
> is strong at) on a real_key which will exist for a reasonable long period
> of time.  For example, I would like to do some packet statistics on each
> IPv6 /64 prefix.  The userspace will iterate the /64 prefix (real_key)
> and sum up all values (of each cpu) before reporting for a particular
> prefix.

Is there any script or ebpf sample code for this case? I appreciate much
we can talk with code.

>
> When the userspace prog can find extend(real_key, cpu0) but not
> extend(real_key, cpu1).  What does it mean?
> It means the real_key has been deleted from all cpu and probably
> not making sense to continue reporting?
> or cpu1 has not inserted the real_key yet and I should
> continue with cpu2?

I am wondering why your above concern can't be covered by
the following code?

        key.key = KEY;
        key.cpu_id = smp_processor_id();
        value = bpf_map_lookup_elem(&hash_map, &key);
        if (value) {
                *value->packets = *value->packets + 1;
        } else {
                val.packet = 1;
                bpf_map_update_elem(&hash_map, &key, &val, BPF_ANY);
        }

>
> How to delete a real_key from all cpu? A loop to iterate all
> extend(real_key, cpu_id)?

Yes.

>
>> That sounds not a good result, 40X memory consumption only save %3 CPU,
>> and the approach(real_key, cpu_id) still can save %3 without extra memory
>> consumption(or much less than percpu MAP)
> Another way to look at it, the bpf prog costs 6% CPU and saving 3%
> with percpu implemenation.

Sorry, I am a bit confused why you say 6% saving, and could explain a bit?
Let's see your previous post:

> In my test (bpf+kprobe at tcp_rcv_established()), both this patchset and
> extend(real_key, cpu_id) approach save ~3% CPU while receiving ~4Mpps
> in a 40cores machine.



-- 
Ming Lei
