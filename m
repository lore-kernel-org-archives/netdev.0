From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Fri, 14 Mar 2014 19:16:00 +0100
Message-ID: <20140314181600.GA2809@localhost>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
 <531EE5A2.7090501@redhat.com>
 <CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
 <20140312091500.GA4638@localhost>
 <CAMEtUuztfWniTr+3u6ttuygvG=xYdp0ANn_w9MGqacQvHrXtWA@mail.gmail.com>
 <20140313122913.GA4898@localhost>
 <CAMEtUuwV2=8sVdmfKSOytC8LKsw2RX+fgfxvucSVV0=L0XEkOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuwV2=8sVdmfKSOytC8LKsw2RX+fgfxvucSVV0=L0XEkOg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 14, 2014 at 08:28:05AM -0700, Alexei Starovoitov wrote:
> On Thu, Mar 13, 2014 at 5:29 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > On Wed, Mar 12, 2014 at 08:29:07PM -0700, Alexei Starovoitov wrote:
> >> On Wed, Mar 12, 2014 at 2:15 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > [...]
> 
> It seems you're assuming that ebpf inherited all the shortcomings
> of bpf and making conclusion based on that. Not your fault.
> I didn't explain it well enough.

Frankly, from the *interface point of view* it is indeed inheriting
all of its shortcomings...

> Technically ebpf is a small evolution of bpf, but applicability made a
> giant leap. I cannot compile C into bpf, but I can do that with ebpf.

Good that we can get better userspace tools, but still the layout of
your instructions is exposed to userspace so it cannot be changed
*ever*. The kernel interface is still an array of binary structures of
fixed size just like BPF does.

Why do we have to have a 32 bits immediate that may be zero most of
the time? Just because:

1) You needed to align your new instruction layout to 64 bits / two 32
bits words.
2) You noticed you get better performance with those changes,
including the new "if" statement that works better with branch
prediction.
3) It's easier for you to make the jit translation.

That means your interface is exposing *all of your internal
implementation decisions* and that's a very bad since we will always
have to come up with smart tricks not to break backward compatibility
if we want to improve the internal implementation.

> I cannot do table lookups in bpf, but I can do that in ebpf.
> I cannot rewrite packet headers in bpf, but I can do that in ebpf, etc.

Sorry, I don't buy this "we get more features" if in the long run we
have restricted extensibility.

> >> The patches don't explain the reasons to do nft socket filtering.
> >
> > OK, some reasons from the interface point of view:
> >
> > 1) It provides an extensible interface to userspace. We didn't
> >    invented a new wheel in that regard, we just reused the
> >    extensibility of TLVs used in netlink as intermediate format
> >    between user and kernelspace, also used many other applications
> >    outthere. The TLV parsing and building is not new code, most that of
> >    that code has been exposed to userspace already through netlink.
> >
> > 2) It shows that, with little generalisation, we can open the door to
> >    one single *classification interface* for the users. Just make some
> >    little googling, you'll find *lots of people* barfing on the fact that
> >    we have that many interfaces to classify packets in Linux. And I'm
> >    *not* talking about the packet classification approach itself, that's a
> >    different debate of course.
> >
> > [...]
> >> Simplicity and performance should be the deciding factor.
> >> imo nft+sock_filter example is not simple.
> >
> > OK, some comments in that regard:
> >
> > 1) Simplicity: With the nft approach you can just use a filter
> > expressed in json, eg.
> >
> > {"rule":
> >  {"expr":[
> >   {"type":"meta","dreg":1,"key":"protocol"},
> >   {"type":"cmp","sreg":1,"op":"eq","cmpdata":{"data_reg":{"type":"value","len":2,"data0":"0x00000008"}}},
> >   {"type":"payload","dreg":1,"offset":9,"len":1,"base":"network"},
> >   {"type":"cmp","sreg":1,"op":"eq","cmpdata":{"data_reg":{"type":"value","len":1,"data0":"0x00000006"}}},
> >   {"type":"immediate","dreg":0,"immediatedata":{"data_reg":{"type":"verdict","verdict":"0xffffffff"}}}]
> >  }
> > }
> 
> sorry. It surely looks simple to you, but I cannot figure out what
> the above snippet suppose to do. Could you please explain.

1) Fetch skb->protocol put it into a register.
2) Compare it to ETHERPROTO_IP. If not matching, break.
3) Fetch payload byte offset 9, only 1 byte.
4) Compare it with IPPROTO_TCP. If not matching, break.
5) If matching, pass the packet to userspace.

> > Which is still more readable and easier to maintain that a BPF
> > snippet. So you just pass it to the json parser in the libnftnl
> > library (or whatever other better minimalistic library we would ever
> > have) which transforms this to TLV format that you can pass to the
> > kernel.  The kernel will do the job to translate this.
> >
> > How are users going to integrate the restricted C's eBPF code
> > infrastructure into their projects? I don't think that will be simple.
> > They will likely include the BPF snippet to avoid all the integration
> > burden, as it already happens in many projects with BPF filters.
> 
> what you're seeing is the counter argument to your 'bpf not-simple'
> statement :) If bpf snippets were hard to understand, people
> wouldn't be including them as-is in their programs.

No, we had no other choice, it was the best thing that we had so far.
People have been just including that "magic code", BPF is quite
unreadable, your extension doesn't make any better.

> One can always do 'tcpdump expression -d' to generate bpf snippet
> or use libpcap in their programs to dynamically generate them.
> libseccomp dynamically generates bpf too.

Autogeneration tools are of course good to have, that can be achieved
with *any* framework. I don't think this is the main point of this
discussion.

> > 2) Performance. Patrick has been doing many progress with the generic
> >    set infrastructure for nft. In that regard, we aim to achieve
> >    performance by arranging data using performance data structures,
> >    *jit is not the only way to boost performance* (although we also
> >    want to have it).
> >
> > Some example:
> >
> >    set type IPv4 address = { N thousands of IPv4 addresses }
> >
> >    reg1 <- payload(network header, offsetof(struct iphdr, daddr), 4)
> >    lookup(reg1, set)
> >    reg0 <- immediate(0xffffffff)
> >
> > Or even better, using dictionaries:
> >
> >    set type IPv4 address = { 1.1.1.1 : accept, 2.2.2.2 : accept, 3.3.3.3 : drop ...}
> >
> >    reg1 <- payload(network header, offsetof(struct iphdr, daddr), 4)
> >    reg0 <- lookup(reg1, set)
> >
> > Where "accept" is an alias of 0xffffffff and "drop" is 0 in the
> > nft-sock case. The verdict part has been generalised so we can adapt
> > nft to the corresponding packet classification engine.
> 
> that example is actually illustrates that nft needs to be continuously
> tweaked to add features like 'set'. We can do better.

No, it just proofs that our framework is extensible and that we can
improve easily.

> Here is the example from V2 series that shows how hash tables can be
> used in C that translates to ebpf, without changing ebpf itself:
> void dropmon(struct kprobe_args *ctx)
> {
>         void *loc;
>         uint64_t *drop_cnt;
>         /* skb:kfree_skb is defined as:
>          * TRACE_EVENT(kfree_skb,
>          *         TP_PROTO(struct sk_buff *skb, void *location),
>          * so ctx->arg2 is 'location'
>          */
>         loc = (void *)ctx->arg2;
> 
>         drop_cnt = bpf_table_lookup(ctx, 0, &loc);

Is there room to extend your framework with any other data structure
which is *not* a hashtable? What are you plans for that?

>         if (drop_cnt) {
>                 __sync_fetch_and_add(drop_cnt, 1);
>         } else {
>                 uint64_t init = 0;
>                 bpf_table_update(ctx, 0, &loc, &init);
>         }
> }
>
> the above C program compiles into ebpf, attaches to kfree_skb() tracepoint
> and counts packet drops at different locations.
> userspace can read the table and print it in user friendly way while
> the tracing filter is running or when it's stopped.
> That's an example of fast drop monitor that is safe to insert into live kernel.
>
> Actually I think it's wrong to even compare nft with ebpf.
> ebpf doesn't dictate a new user interface. At all.
> There is old bpf to write socket filters. It's good enough.
> I'm not planning to hack libpcap just to generate ebpf.
> User interface is orthogonal to kernel implementation.
> We can argue whether C representation of filter is better than json,
> but what kernel runs at the lowest level is independent of that.
> 
> Insisting that user interface and kernel representation must be
> one-to-one is unnecessary restrictive. User interface can and
> should evolve independently of what kernel is doing underneath.
> 
> In case of socket filters tcpdump/libpcap syntax is the user interface.

No, that's not the real interface. That's a wrapper / abstraction over
the kernel interface is exposing.

> old bpf is a kernel-user api. I don't think there is a strong need
> to change either. ebpf is not touching them, but helping to execute
> tcpdump filters faster.
> In case of tracing filters I propose C-like user interface.
> Kernel API for translated C programs is a different matter.
> ebpf in the kernel is just the engine to execute it.
> 1st and 2nd may look completely different after community feedback,
> but in kernel ebpf engine can stay unmodified.

The only different that I see with ebpf is that you provide nice end
user tools, but the design from the kernel interface has exactly the
same problems.

> > Right, you can extend interfaces forever with lots of patchwork and
> > "smart tricks" but that doesn't mean that will look nice...
> 
> I'm not sure what you mean here.

For example, this:

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cf9cd13509a7..e1b979312588 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -273,6 +273,13 @@  static struct ctl_table net_core_table[] = {
        },
 #endif
        {
+               .procname       = "bpf_ext_enable",
+               .data           = &bpf_ext_enable,
+               .maxlen         = sizeof(int),
+               .mode           = 0644,
+               .proc_handler   = proc_dointvec
+       },

This /proc thing seems to me like the last resource we have to avoid
breaking backward compatibility. I have used it as well myself, but
it's like the *pull alarm* when we did a wrong design decision.

What if we need a new ABI breakage for BPF again? Will we need to add
a new /proc interface for that? As far as I can tell from your
patches, the answer is yes.

> > As I said, I believe that having a nice extensible interface is
> > extremely important to make it easier for development. If we have to
> > rearrange the internal representation for some reason, we can do it
> > indeed without bothering about making translations to avoid breaking
> > userspace and having to use ugly tricks (just see sk_decode_filter()
> > or any other translation to support any new way to express a
> > filter...).
> 
> nice that your brought this up :)
> As I mentioned in v4 thread sk_decode_filter() can be removed.
> It was introduced to improve old interpreter performance and now
> this part is obsolete.

What are your plans then? Will you implement that converter in
userspace? You mention that you don't want to enhance libpcap, which
seems to me like the natural way to extend things.

> > [...]
> >> Say you want to translate nft-cmp instruction into sequence of native
> >> comparisons. You'd need to use load from memory, compare and
> >> branch operations. That's ebpf!
> >
> > Nope sorry, that's not ebpf. That's assembler code.
> 
> Well, in my previous email I tried to explain that assembler == ebpf :)

I see, so I was right. You want to expose a pseudo-assembler
interface just because that makes it easier to you to provide the jit
translation.

> Please post x86_64 assembler code that future nft-jit suppose to
> generate and I can post equivalent ebpf code that will be jited
> exactly to your x86_64...

That's possible of course. There are many ways to implement the same
thing, they can provide the same features, but not the same degree of
extensibility.

> > [...]
> >> You can view ebpf as a tool to achieve jiting of nft.
> >> It will save you a lot of time.
> >
> > nft interface is already well-abstracted from the representation, so I
> > don't find a good reason to make a step backward that will force us to
> > represent the instructions using a fixed layout structure that is
> > exposed to userspace, that we won't be able to change once if this
> > gets into mainstream.
> 
> I don't think we're on the same page still.
> To make this more productive, please say what feature you would
> want to see supported and I can show how it is done without
> changing ebpf insn set.
>
> > Probably the nft is not the easiest path, I agree, it's been not so
> > far if you look at the record. But with time and development hours
> > from everyone, I believe we'll enjoy a nice framework.
> 
> No doubt that nftables is a nice framework. Let's keep it going
> and let's make it faster.

We want to make it faster, but I don't like the idea of converting
it to bpf just to get the jit fast.

We are spending quite a lot of time to provide good performance
through arraging data in performance data structures, the jit
microoptimization will be just the cherry on the top of the cake.
