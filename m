From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/1] tracing, bpf: Implement function bpf_probe_write
Date: Thu, 14 Jul 2016 22:40:27 -0700
Message-ID: <20160715054025.GA99435@ast-mbp>
References: <CAMp4zn8ygXFg7kvjShm77zmK2dYVMY2zS8i2mUKwhbfXcyVyig@mail.gmail.com>
 <20160713170849.GA76615@ast-mbp.thefacebook.com>
 <alpine.DEB.2.02.1607131230210.19550@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1607131230210.19550@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 13, 2016 at 01:31:57PM -0700, Sargun Dhillon wrote:
> 
> 
> On Wed, 13 Jul 2016, Alexei Starovoitov wrote:
> 
> > On Wed, Jul 13, 2016 at 03:36:11AM -0700, Sargun Dhillon wrote:
> >> Provides BPF programs, attached to kprobes a safe way to write to
> >> memory referenced by probes. This is done by making probe_kernel_write
> >> accessible to bpf functions via the bpf_probe_write helper.
> >
> > not quite :)
> >
> >> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> >> ---
> >>  include/uapi/linux/bpf.h  |  3 +++
> >>  kernel/trace/bpf_trace.c  | 20 ++++++++++++++++++++
> >>  samples/bpf/bpf_helpers.h |  2 ++
> >>  3 files changed, 25 insertions(+)
> >>
> >> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> >> index 406459b..355b565 100644
> >> --- a/include/uapi/linux/bpf.h
> >> +++ b/include/uapi/linux/bpf.h
> >> @@ -313,6 +313,9 @@ enum bpf_func_id {
> >>   */
> >>   BPF_FUNC_skb_get_tunnel_opt,
> >>   BPF_FUNC_skb_set_tunnel_opt,
> >> +
> >> + BPF_FUNC_probe_write, /* int bpf_probe_write(void *dst, void *src,
> >> int size) */
> >> +
> >
> > the patch is against some old kernel.
> > Please always make the patch against net-next tree and cc netdev list.
> >
> Sorry, I did this against Linus's tree, not net-next. Will fix.
> 
> >> +static u64 bpf_probe_write(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> >> +{
> >> + void *dst = (void *) (long) r1;
> >> + void *unsafe_ptr = (void *) (long) r2;
> >> + int  size = (int) r3;
> >> +
> >> + return probe_kernel_write(dst, unsafe_ptr, size);
> >> +}
> >
> > the patch is whitepsace mangled. Please see Documentation/networking/netdev-FAQ.txt
> Also will fix.
> 
> >
> > the main issue though that we cannot simply allow bpf to do probe_write,
> > since it may crash the kernel.
> > What might be ok is to allow writing into memory of current
> > user space process only. This way bpf prog will keep kernel safety guarantees,
> > yet it will be able to modify user process memory when necessary.
> > Since bpf+tracing is root only, it doesn't pose security risk.
> >
> >
> 
> Doesn't probe_write prevent you from writing to protected memory and 
> generate an EFAULT? Or are you worried about the situation where a bpf 
> program writes to some other chunk of kernel memory, or writes bad data 
> to said kernel memory?
> 
> I guess when I meant "safe" -- it's safer than allowing arbitrary memcpy. 
> I don't see a good way to ensure safety otherwise as we don't know 
> which registers point to memory that it's reasonable for probes to 
> manipulate. It's not like skb_store_bytes where we can check the pointer 
> going in is the same pointer that's referenced, and with a super 
> restricted datatype.

exactly. probe_write can write anywhere in the kernel and that
will cause crashes. If we allow that bpf becomes no different than
kernel module.

> Perhaps, it would be a good idea to describe an example where I used this:
> #include <uapi/linux/ptrace.h>
> #include <net/sock.h>
> #include <bcc/proto.h>
> 
> 
> int trace_inet_stream_connect(struct pt_regs *ctx)
> {
> 	if (!PT_REGS_PARM2(ctx)) {
> 		return 0;
> 	}
> 	struct sockaddr uaddr = {};
> 	struct sockaddr_in *addr_in;
> 	bpf_probe_read(&uaddr, sizeof(struct sockaddr), (void *)PT_REGS_PARM2(ctx));
> 	if (uaddr.sa_family == AF_INET) {
> 		// Simple cast causes LLVM weirdness
> 		addr_in = &uaddr;
> 		char fmt[] = "Connecting on port: %d\n";
> 		bpf_trace_printk(fmt, sizeof(fmt), ntohs(addr_in->sin_port));
> 		if (ntohs(addr_in->sin_port) == 80) {
> 			addr_in->sin_port = htons(443);
> 			bpf_probe_write((void *)PT_REGS_PARM2(ctx), &uaddr, sizeof(uaddr));
> 		}
> 	}
>         return 0;
> };
> 
> There are two reasons I want to do this:
> 1) Debugging - sometimes, it makes sense to divert a program's syscalls in 
> order to allow for better debugging
> 2) Network Functions - I wrote a load balancer which intercepts 
> inet_stream_connect & tcp_set_state. We can manipulate the destination 
> address as neccessary at connect time. This also has the nice side effect 
> that getpeername() returns the real IP that a server is connected to, and 
> the performance is far better than doing "network load balancing"
> 
> (I realize this is a total hack, better approaches would be appreciated)

nice. interesting idea.
Have you considered ld_preload hack to do port rewrite?

> If we allowed manipulation of the current task's user memory by exposing 
> copy_to_user, that could also work if I attach the probe to sys_connect, 
> I could overwrite the address there before it gets copied into 
> kernel space, but that could lead to its own weirdness.

we cannot simply call copy_to_user from the bpf either,
but yeah, something semantically equivalent to copy_to_user should
solve your port rewriting case, right?
Could you explain little bit more on 'syscall divert' ideas?
