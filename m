From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 net-next] fix unsafe set_memory_rw from softirq
Date: Fri, 4 Oct 2013 20:00:21 +0200
Message-ID: <20131004180021.GA16564@gmail.com>
References: <1380853446-30537-1-git-send-email-ast@plumgrid.com>
 <20131004075133.GA12313@gmail.com>
 <CAMEtUuy0mpdUHJjztK31mHjNVahnoZ8CHo2sLLyJmt=p5+gq0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, Eric Dumazet <edumazet@google.com>,
 Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>,
 sparclinux@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
 linux-s390@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
 x86@kernel.org, James Morris <jmorris@namei.org>,
 Ingo Molnar <mingo@redhat.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Xi Wang <xi.wang@gmail.com>,
 Matt Evans <matt@ozlabs.org>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, Stelian Nirlu <steliannirlu@gmail.com>,
 Nicolas Schichan <nschichan@freebox.fr>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 Mircea Gherzan
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuy0mpdUHJjztK31mHjNVahnoZ8CHo2sLLyJmt=p5+gq0w@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> >>  #else
> >> +#include <linux/slab.h>
> >
> > Inlines in the middle of header files are generally frowned upon.
> >
> > The standard pattern is to put them at the top, that way it's easier to
> > see the dependencies and there's also less .config dependent inclusion,
> > which makes header hell cleanup work easier.
> 
> Agree. I only followed the style that is already in filter.h 20 lines above.
>
> #ifdef CONFIG_BPF_JIT
> #include <stdarg.h>
> #include <linux/linkage.h>
> #include <linux/printk.h>
> 
> as part of the cleanup can move all of them to the top. In the separate commit?

Yeah, sure, that's fine.

> >>       struct sk_filter *fp;
> >>       unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
> >> +     unsigned int sk_fsize = max_t(u32, fsize, sizeof(struct work_struct))
> >> +             + sizeof(*fp);
> >
> > Using the structure definition I suggested, this could be replaced with
> > the more obvious:
> >
> >         unsigned int sk_fsize = max(fsize, sizeof(*fp));
> 
> with helper function it's even cleaner. Fixed in V4

So my thought was that the helper function is perhaps too trivial and 
somewhat obscures the allocation pattern, but yeah. Either way is fine 
with me.

> > A couple of questions/suggestions:
> >
> > 1)
> >
> > I took a brief look at arch/x86/net/bpf_jit_comp.c while reviewing this
> > patch.
> >
> > You need to split up bpf_jit_compile(), it's an obscenely large, ~600
> > lines long function. We don't do that in modern, maintainable kernel code.
> 
> I had the same thought, therefore in my proposed generalization of bpf:
> http://patchwork.ozlabs.org/patch/279280/
> It is split into two. do_jit() is still a bit large at 400 lines. Can
> split it further.

Yeah, I think as long as you split out the loop iterator into a separate 
function it gets much better.

The actual instruction generation code within the iterator looks good in a 
single chunk - splitting it up further than that might in fact make it 
less readable.

> > 3)
> >
> > It's nice code altogether! Are there any plans to generalize its 
> > interfaces, to allow arbitrary bytecode to be used by other kernel 
> > subsystems as well? In particular tracing filters could make use of 
> > it, but it would also allow safe probe points.
> 
> That was exactly the reasons to generalize bpf as I proposed.

Ok, cool :-)

For the x86 bits:

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo
