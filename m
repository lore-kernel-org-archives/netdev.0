From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] bpf: bpf_htab: Add syscall to iterate
 percpu value of a key
Date: Wed, 13 Jan 2016 17:24:34 -0800
Message-ID: <20160114012433.GB43324@ast-mbp.thefacebook.com>
References: <1452586852-1575604-1-git-send-email-kafai@fb.com>
 <1452586852-1575604-4-git-send-email-kafai@fb.com>
 <CACVXFVPAR52e01vVqtZ5LF5j7zscjAVgOccW1erj-a2VYScJrg@mail.gmail.com>
 <20160113052341.GB37858@ast-mbp.thefacebook.com>
 <CACVXFVMMPkekaNvo+ByNGcryB7Mum91xT7nR1YkK+kKu-J1-5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35680 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182AbcANBYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 20:24:37 -0500
Content-Disposition: inline
In-Reply-To: <CACVXFVMMPkekaNvo+ByNGcryB7Mum91xT7nR1YkK+kKu-J1-5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2016 at 11:43:50PM +0800, Ming Lei wrote:
> On Wed, Jan 13, 2016 at 1:23 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Wed, Jan 13, 2016 at 10:42:49AM +0800, Ming Lei wrote:
> >>
> >> So I don't think it is good to retrieve value from one CPU via one
> >> single system call, and accumulate them finally in userspace.
> >>
> >> One approach I thought of is to define the function(or sort of)
> >>
> >>  handle_cpu_value(u32 cpu, void *val_cpu, void *val_total)
> >>
> >> in bpf kernel code for collecting value from each cpu and
> >> accumulating them into 'val_total', and most of situations, the
> >> function can be implemented without loop most of situations.
> >> kernel can call this function directly, and the total value can be
> >> return to userspace by one single syscall.
> >>
> >> Alexei and anyone, could you comment on this draft idea for
> >> perpcu map?
> >
> > I'm not sure how you expect user space to specify such callback.
> > Kernel cannot execute user code.
> 
> I mean the above callback function can be built into bpf code and then
> run from kernel after loading like in packet filter case by tcpdump, maybe
> one new prog type is needed. It is doable in theroy. I need to investigate
> a bit to understand how it can be called from kernel, and it might be OK
> to call it via kprobe, but not elegent just for accumulating value from each
> CPU.

that would be a total overkill.

> > Also syscall/malloc/etc is a noise comparing to ipi and it
> > will still be there, so
> > for(all cpus) { syscall+ipi;} will have the same speed.
> 
> In the syscall path, lots of slow things, and finally the accumulated
> value is often stale and may not reprensent accurate number at any
> time, and can be thought as invalid.

no. stale != invalid.
Some analytics/monitor applications are good with ball park numbers
and for them regular hash map with non-atomic increment is good enough,
but others need accurate numbers. Even though they may be seconds stale.
