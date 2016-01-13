From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] bpf: bpf_htab: Add syscall to iterate
 percpu value of a key
Date: Tue, 12 Jan 2016 21:23:42 -0800
Message-ID: <20160113052341.GB37858@ast-mbp.thefacebook.com>
References: <1452586852-1575604-1-git-send-email-kafai@fb.com>
 <1452586852-1575604-4-git-send-email-kafai@fb.com>
 <CACVXFVPAR52e01vVqtZ5LF5j7zscjAVgOccW1erj-a2VYScJrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACVXFVPAR52e01vVqtZ5LF5j7zscjAVgOccW1erj-a2VYScJrg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 10:42:49AM +0800, Ming Lei wrote:
> 
> So I don't think it is good to retrieve value from one CPU via one
> single system call, and accumulate them finally in userspace.
> 
> One approach I thought of is to define the function(or sort of)
> 
>  handle_cpu_value(u32 cpu, void *val_cpu, void *val_total)
> 
> in bpf kernel code for collecting value from each cpu and
> accumulating them into 'val_total', and most of situations, the
> function can be implemented without loop most of situations.
> kernel can call this function directly, and the total value can be
> return to userspace by one single syscall.
> 
> Alexei and anyone, could you comment on this draft idea for
> perpcu map?

I'm not sure how you expect user space to specify such callback.
Kernel cannot execute user code.
Also syscall/malloc/etc is a noise comparing to ipi and it
will still be there, so
for(all cpus) { syscall+ipi;} will have the same speed.
I think in this use case the overhead of ipi is justified,
since user space needs to read accurate numbers otherwise
the whole per-cpu is not very useful. One can just use
normal hash map and do normal increment. All cpus will race
and the counter may contain complete garbage, but in some
cases such rough counters are actually good enough.
Here per-cpu hash gives fast performance and _accurate_
numbers to userspace.
Having said that if you see a way to avoid ipi and still
get correct numbers to user space, it would be great.
