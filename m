From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net-next 0/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Tue, 12 Jan 2016 13:48:10 +0800
Message-ID: <CACVXFVMZRS5fxta6xvehfzQHW37KxWSs630_6MO1s+GRyb0teQ@mail.gmail.com>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
	<CACVXFVNhEOrroAfiEOC32dB3ZV=73WYJxUtNrpqEE94tvY2fXw@mail.gmail.com>
	<20160109004443.GA33292@kafai-mba.local>
	<CACVXFVPbsqBoAvgRjrm7A3S2G0kUrEt=e64FyRpoSqO2ukHncQ@mail.gmail.com>
	<20160110022946.GA50678@kevintjones-mbp.dhcp.thefacebook.com.DHCP.thefacebook.com>
	<CACVXFVNfRLL-TQajPHD1XKnFCgyTvU_dAJQ0+HxwYQX4qC1G8A@mail.gmail.com>
	<20160111223444.GA6742@kafai-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160111223444.GA6742@kafai-mba.dhcp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Martin,

On Tue, Jan 12, 2016 at 6:35 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> Hi Ming,
>
> On Mon, Jan 11, 2016 at 10:20:55AM +0800, Ming Lei wrote:
>> >> - percpu hash can cause huge memory consumption compared with the way
>                                   ~~~~~~~~~~~~~~~~~~
>> >> of key plus cpu_id without obvious performance advantage
>> > If the bpf prog uses the percpu map type, the expectation
>> > is the bpf is tapping some kprobes that most cpus (if not all) will access
>> > the same key.  I would argue that having a bigger key (due to cpu_id),
>>
>> I think you mean the value mapped from the key can be accessed
>> concurrently from most cpus.
>>
>> > and 40 more keys (and linking to 40 buckets) is less efficient.
>>
>> Suppose the key is choosed in this way and may be accessed concurrently
>> from most cpus, the only extra loading for (real_key, cpu_id) is in memcmp(),
>> because key size is increased by sizeof(cpu_id), is it really a big deal?
>>
>> Also in your percpu patch, you add one extra alloc_percpu_gfp(), do you
>> think that it is cheaper than the extra compasion on cpu_id in memcmp()?
> I was referring to your _memory_ consumption comment.  The key is bigger,
> more keys and buckets are needed.

The total memory consumption is still much less than memory consumed
by percpu hash since a new element is only added to hash if the key is run
on that CPU. Most of times, for one key it may touch very few CPUs.

For percpu hash, the memory is always allocated to every CPU no matter
if the key is run from the CPU.

>
> and even for CPU concern, Yes also.  If the key stays long enough for
> aggregation (and atomic operations), is it better to do one alloc_percpu_gfp()
> at the beginning instead of extra memcmp() over and over again during lookup?
> Having said that, I don't think either of the alloc or memcmp cost is
> significant enough to distract the percpu discussion.

In my test, removing the current kmalloc() in update element callback can
improve io thoughput by 10% not mention the percpu ida allocation cost, and
looks it isn't cheap. That is why I don't think it is good to
introduce another new
allocation in the eBPF prog path.

You can find my test in the link below:

       https://patchwork.ozlabs.org/patch/556926/

>
>>
>> >
>> > If the expectation is to have a small numbers of cpu accessing a key (like
>> > biolatency), the bpf prog can stay with the regular bpf map.  The new
>> > percpu map has almost the same interface (except the syscall added in
>> > Patch 3).
>>
>> > Switching between the two map types is easy.
>>
>> No, it isn't easy with your patchset, since we can't look up
>> one key in one specific CPU from eBPF prog, not mention you
>> introduce extra syscall.
> Why would a eBPF prog (bpf_kern.o) want to access value of another CPU?
> Does it defeat the purpose of using percpu value in the first place?

HASH map need to delete element in eBPF prog and it is used a bit
common, so it is reasonable to retrieve the value of the element(need
to access value of other CPUs) before deleting it, isn't it?

>
>> >
>> >> >> For HASH map, it is easy to make cpu id as part of key, then the map
>> >> >> can be thought as percpu too, and atomic op isn't needed in eBPF program.
>> >> > Putting the cpu id as part of the key was indeed the first hack I did
>> >> > to get a sense of potential benefit.
>> >> >
>> >> > However, by extending the real-key with cpu-id, it is not intuitive to
>> >> > use and it is prone to error.  For example, how to delete a real-key for
>> >> > all cpus?  Iterating a particular real-key for all cpu is also tricky.  What
>> >> > does it mean if a real-key exists for cpu#0 but not cpu#1? The real-key
>> >>
>> >> lookup returns NULL if the key(real key plus cpu id) doesn't exist.
>> >>
>> >> > got deleted from all cpu while iterating? or something else?  I believe
>> >> > there are ways to get around but it is better to provide a clean
>> >> > implementation instead.
>> >>
>> >> It might be true, but I hope there is one real example, in which we can
>> >> see the obvious disadvantage of real key plus cpu_id. In the other way,
>> >> we still can improve current hash map to make this case easier to use.
>> > By extend(real_key, cpu_id), the uniqueness property of a real_key (and
>> > it should be as a key for a hashmap) is getting blurry and it is not
>> > ideal.
>> >
>> > The typical use case is for doing a lot of aggregation (which bpf+kprobe
>> > is strong at) on a real_key which will exist for a reasonable long period
>> > of time.  For example, I would like to do some packet statistics on each
>> > IPv6 /64 prefix.  The userspace will iterate the /64 prefix (real_key)
>                           ^^^^^^^^^^^^^^^^^^^^^^
>> > and sum up all values (of each cpu) before reporting for a particular
>> > prefix.
>>
>> Is there any script or ebpf sample code for this case? I appreciate much
>> we can talk with code.
> Sure, a simplified version is at the end.
>
>> >
>> > How to delete a real_key from all cpu? A loop to iterate all
>> > extend(real_key, cpu_id)?
>>
>> Yes.
> That is not ideal then.
>
> Let alone the max_entries of the map also needs to be changed

Why is the max_entries related?

> whenever it is running in another machine with different number
> of cores.

The core number can be get easily, is that a problem?

>
>> >> That sounds not a good result, 40X memory consumption only save %3 CPU,
>> >> and the approach(real_key, cpu_id) still can save %3 without extra memory
>> >> consumption(or much less than percpu MAP)
>> > Another way to look at it, the bpf prog costs 6% CPU and saving 3%
>> > with percpu implemenation.
>>
>> Sorry, I am a bit confused why you say 6% saving, and could explain a bit?
>> Let's see your previous post:
> I meant:
> Without percpu optimization, the bpf_prog costs a total 6% CPU.
> With the percpu optimization, it saves 3% CPU.

OK, I see it. 3% can be a bit small and often in fluctuant range. And why not
make CPU at full loading and see the improvement obviously?

Also you mentioned (real_key, cpu_id) can get similar improvement too.

>
> Thanks,
> -- Martin
>
> Here is a much stripped down version of the bpf_kern and bpf_user:
>
> struct tcp_trace_flow6 {
>         __be32  dst0;
>         __be32  dst1;
> };
>
> struct tcp_stats {
>         u64     segs_in;
>         /* A few more counters... */
> };
>
> /* bpf_kern.c */
> struct bpf_map_def SEC("maps") dst_rack_map6 = {
>         .type = BPF_MAP_TYPE_PERCPU_HASH,
>         .key_size = sizeof(struct tcp_trace_flow6),
>         .value_size = sizeof(struct tcp_stats),
>         .max_entries = 10000,
> };
>
> SEC("kprobe/tcp_rcv_established")
> int trace_rcv_established(struct pt_regs *ctx)
> {
>         struct tcp_stats *tpes;
>         struct sk_buff *skb;
>         struct sock *sk;
>
>         sk = (struct sock *) PT_REGS_PARM1(ctx);
>         skb = (struct sk_buff *) PT_REGS_PARM2(ctx);
>
>         /* tcp_stats_get: A simple map lookup based on the IPv6 /64 prefix.
>          * If it does not exist, insert
>          */
>         tpes = tcp_stats_get(sk);

Where is the above function? Is 'sk' the key? That can't use
(real_key, cpu_id) easily?

Looks your usage is simple, without delete/update elem invovled?

>         if (!tpes)
>                 return 0;
>
>         tpes->segs_in++;
>
>         /* A free more counter++ operations here */
>
>         return 0;
> }
>
> /* bpf_user.c */
> total = 0;
> while (bpf_get_next_key(map_fd, &ttf6, &next_ttf6) == 0) {
>         for (cpu = 0; cpu < nr_cpus; cpu++) {
>                 if (!bpf_lookup_percpu_elem(map_fd,
>                                                 &next_ttf6,
>                                                 &tpes, cpu))
>                         total += tpes.segs_in;
>                 else if (errno != ENXIO)
>                      break;
>         }
>         if (cpu == nr_cpus)
>                 tcp_stats_log6(&next_ttf6, total);
>         ttf6 = next_ttf6;
> }



Thanks,
Ming Lei
