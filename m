From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [RFC net-next] bpf: taint loading !is_gpl programs
Date: Wed, 05 Apr 2017 22:59:49 -0400
Message-ID: <f7tpogqmeai.fsf@redhat.com>
References: <20170404183354.8579-1-aconole@bytheb.org>
        <58E40C2B.7040802@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58E40C2B.7040802@iogearbox.net> (Daniel Borkmann's message of
        "Tue, 04 Apr 2017 23:12:11 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

Daniel Borkmann <daniel@iogearbox.net> writes:

> On 04/04/2017 08:33 PM, Aaron Conole wrote:
>> The eBPF framework is used for more than just socket level filtering.  It
>> can also provide tracing, and even change the way packets coming into the
>> system look.  Most of the eBPF callable symbols are available to non-gpl
>> programs, and this includes helper functions which modify packets.  This
>> allows proprietary eBPF code to link to the kernel and make decisions
>> which can negatively impact network performance.
>>
>> Since the sources for these programs are only available under a proprietary
>> license, it seems better to treat them the same as other proprietary
>> modules: set the system taint flag.  An exemption is made for socket-level
>> filters, since they do not really impact networking for the whole kernel.
>>
>> Signed-off-by: Aaron Conole <aconole@bytheb.org>
>> ---
>
> Nacked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks so much for looking at the patch!

> This is proposal completely unreasonable; what the purpose of .gpl_only
> flags is agreed upon since the beginning is that some of the helpers
> are only available if the program is loaded as gpl, f.e. bpf_ktime_get_ns(),
> bpf_probe_read(), bpf_probe_write_user(), bpf_trace_printk(),
> bpf_skb_event_output(), etc.

This behavior isn't changing with this patch.

> Now, suddenly switching from one kernel
> version to another, existing programs would out of a sudden taint the
> kernel, which by itself is unacceptable.

I'm not sure what you mean here.  The kernel should still be usable.  This
basically says that if someone runs non-GPL eBPF code, they are tainting
the kernel.  More below.

> There are also many other
> subsystems that can modify packets, or affect system performance
> negatively if configured wrongly and which in addition *don't require* a
> hard capable(CAP_SYS_ADMIN) restriction like such eBPF programs already
> do, perhaps should we taint them as well?

This is a good point that there are other methods of doing damage to the
network.  I think it means my commit message wasn't clear enough to
describe why I wanted the change.  The reason I propose this isn't
because someone can theoretically damage things.  It's because eBPF
really is a way of writing specialized kernel modules.

I am really making the distinction here that eBPF code (except for the
case of user-space socket filter) is a kernel module.  I realize that
may not be something folks have considered.  Never-the-less, it is code
which runs in the context of the kernel, out lives the lifetime of user
space, and modifies kernel behavior.  These are the main reasons I
believe this is a kernel module.  And since it is a kernel module, it
shouldn't bypass the existing taint flag that says 'someone is running
non-gpl code in kernel space.'  Do you disagree?  This is also why I
exempt socket filter code.  That really is something which I would
consider running as part of a user-space application.

> Plus tracing programs are
> attached to passively monitor systems performance, not even modifying
> data structures

Tracing code, afaict, must be gpl_only = true to be useful.  So I don't see
how it enters into the equation.  Did I misread something?  Most, if not
all of the networking functions, are gpl_only = false.  This means the
community will have a difficult time supporting reports from this
system.  After all, there's no way to know exactly how this eBPF program
has changed packets in the network without a license to the code.

> ... The current purpose of .gpl_only is fine as-is, and
> there's work in progress for a generic dump mechanism that works with
> all program types to improve introspection aspect if that's what you're
> after, starting to taint is, in a way, breaking existing applications
> and this is not acceptable.

I don't see how this breaks applications.  They continue to run fine.
This patch does not restrict functionality.  Again, did I misunderstand
something?

I'm not sure how a dumping mechanism changes anything either.  I agree
such a utility is very useful.  However, if the poor user who is running
a non-gpl eBPF program is asked to provide a dump of that eBPF program,
they may be barred from doing so by licensing.  How can those cases be
supported?
