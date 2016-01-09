From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net-next 0/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Sat, 9 Jan 2016 17:39:16 +0800
Message-ID: <CACVXFVPbsqBoAvgRjrm7A3S2G0kUrEt=e64FyRpoSqO2ukHncQ@mail.gmail.com>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
	<CACVXFVNhEOrroAfiEOC32dB3ZV=73WYJxUtNrpqEE94tvY2fXw@mail.gmail.com>
	<20160109004443.GA33292@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160109004443.GA33292@kafai-mba.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Martin,

On Sat, Jan 9, 2016 at 8:44 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Fri, Jan 08, 2016 at 02:55:32PM +0800, Ming Lei wrote:
>> On Fri, Jan 8, 2016 at 6:35 AM, Martin KaFai Lau <kafai@fb.com> wrote:
>> > This patchset adds BPF_MAP_TYPE_PERCPU_HASH map type which allows
>> > percpu value.
>>
>> I am also thinking about using percpu variable to ebpf map, but IMO it
>> should be better for ARRAY map instead of HASH map, then we can
>> avoid the atomic op in eBPF program, see example of tracex3, sockex1
>> and sockex3 in sample/bpf/ of kernel tree.  Also looks the ARRAY map
>> usage in bcc is wrong, strictly speaking.
> array and hash are two different use cases. May be we should have percpu
> value for array map too.

Atomic operations are definitely expensive, which should have been avoided
in eBPF prog by percpu way. I think ARRAY map does need percpu way more, :-)

But for hash map, I am still not 100% sure if percpu is needed:

- key plus cpu_id is ok
- key often can be chosed so that the mapped value is accessed without
race(such as, req is used as key in biolatency, ...)
- percpu hash can cause huge memory consumption compared with the way
of key plus cpu_id without obvious performance advantage

>
>>
>> For HASH map, it is easy to make cpu id as part of key, then the map
>> can be thought as percpu too, and atomic op isn't needed in eBPF program.
> Putting the cpu id as part of the key was indeed the first hack I did
> to get a sense of potential benefit.
>
> However, by extending the real-key with cpu-id, it is not intuitive to
> use and it is prone to error.  For example, how to delete a real-key for
> all cpus?  Iterating a particular real-key for all cpu is also tricky.  What
> does it mean if a real-key exists for cpu#0 but not cpu#1? The real-key

lookup returns NULL if the key(real key plus cpu id) doesn't exist.

> got deleted from all cpu while iterating? or something else?  I believe
> there are ways to get around but it is better to provide a clean
> implementation instead.

It might be true, but I hope there is one real example, in which we can
see the obvious disadvantage of real key plus cpu_id. In the other way,
we still can improve current hash map to make this case easier to use.

Also in reality, it is often true that the mapped value from chosed key
can't be accessed concurrently from other CPUs, so percpu isn't needed.

>
>> Given it is always related with performance, could you provide some data
>> about the improvement? Also you can compare this patchset with the
>> approach of providing cpu id as hash key.
> In my test (bpf+kprobe at tcp_rcv_established()), both this patchset and
> extend(real_key, cpu_id) approach save ~3% CPU while receiving ~4Mpps
> in a 40cores machine.  The bpf is mostly bumping some counters for
> each received packet.

That sounds not a good result, 40X memory consumption only save %3 CPU,
and the approach(real_key, cpu_id) still can save %3 without extra memory
consumption(or much less than percpu MAP)


-- 
Ming Lei
