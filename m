From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Fri, 14 Mar 2014 08:28:05 -0700
Message-ID: <CAMEtUuwV2=8sVdmfKSOytC8LKsw2RX+fgfxvucSVV0=L0XEkOg@mail.gmail.com>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
	<531EE5A2.7090501@redhat.com>
	<CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
	<20140312091500.GA4638@localhost>
	<CAMEtUuztfWniTr+3u6ttuygvG=xYdp0ANn_w9MGqacQvHrXtWA@mail.gmail.com>
	<20140313122913.GA4898@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140313122913.GA4898@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 13, 2014 at 5:29 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Wed, Mar 12, 2014 at 08:29:07PM -0700, Alexei Starovoitov wrote:
>> On Wed, Mar 12, 2014 at 2:15 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> [...]

It seems you're assuming that ebpf inherited all the shortcomings
of bpf and making conclusion based on that. Not your fault.
I didn't explain it well enough.
Technically ebpf is a small evolution of bpf, but applicability made a
giant leap. I cannot compile C into bpf, but I can do that with ebpf.
I cannot do table lookups in bpf, but I can do that in ebpf.
I cannot rewrite packet headers in bpf, but I can do that in ebpf, etc.

>> The patches don't explain the reasons to do nft socket filtering.
>
> OK, some reasons from the interface point of view:
>
> 1) It provides an extensible interface to userspace. We didn't
>    invented a new wheel in that regard, we just reused the
>    extensibility of TLVs used in netlink as intermediate format
>    between user and kernelspace, also used many other applications
>    outthere. The TLV parsing and building is not new code, most that of
>    that code has been exposed to userspace already through netlink.
>
> 2) It shows that, with little generalisation, we can open the door to
>    one single *classification interface* for the users. Just make some
>    little googling, you'll find *lots of people* barfing on the fact that
>    we have that many interfaces to classify packets in Linux. And I'm
>    *not* talking about the packet classification approach itself, that's a
>    different debate of course.
>
> [...]
>> Simplicity and performance should be the deciding factor.
>> imo nft+sock_filter example is not simple.
>
> OK, some comments in that regard:
>
> 1) Simplicity: With the nft approach you can just use a filter
> expressed in json, eg.
>
> {"rule":
>  {"expr":[
>   {"type":"meta","dreg":1,"key":"protocol"},
>   {"type":"cmp","sreg":1,"op":"eq","cmpdata":{"data_reg":{"type":"value","len":2,"data0":"0x00000008"}}},
>   {"type":"payload","dreg":1,"offset":9,"len":1,"base":"network"},
>   {"type":"cmp","sreg":1,"op":"eq","cmpdata":{"data_reg":{"type":"value","len":1,"data0":"0x00000006"}}},
>   {"type":"immediate","dreg":0,"immediatedata":{"data_reg":{"type":"verdict","verdict":"0xffffffff"}}}]
>  }
> }

sorry. It surely looks simple to you, but I cannot figure out what
the above snippet suppose to do. Could you please explain.

> Which is still more readable and easier to maintain that a BPF
> snippet. So you just pass it to the json parser in the libnftnl
> library (or whatever other better minimalistic library we would ever
> have) which transforms this to TLV format that you can pass to the
> kernel.  The kernel will do the job to translate this.
>
> How are users going to integrate the restricted C's eBPF code
> infrastructure into their projects? I don't think that will be simple.
> They will likely include the BPF snippet to avoid all the integration
> burden, as it already happens in many projects with BPF filters.

what you're seeing is the counter argument to your 'bpf not-simple'
statement :) If bpf snippets were hard to understand, people
wouldn't be including them as-is in their programs.
One can always do 'tcpdump expression -d' to generate bpf snippet
or use libpcap in their programs to dynamically generate them.
libseccomp dynamically generates bpf too.

> 2) Performance. Patrick has been doing many progress with the generic
>    set infrastructure for nft. In that regard, we aim to achieve
>    performance by arranging data using performance data structures,
>    *jit is not the only way to boost performance* (although we also
>    want to have it).
>
> Some example:
>
>    set type IPv4 address = { N thousands of IPv4 addresses }
>
>    reg1 <- payload(network header, offsetof(struct iphdr, daddr), 4)
>    lookup(reg1, set)
>    reg0 <- immediate(0xffffffff)
>
> Or even better, using dictionaries:
>
>    set type IPv4 address = { 1.1.1.1 : accept, 2.2.2.2 : accept, 3.3.3.3 : drop ...}
>
>    reg1 <- payload(network header, offsetof(struct iphdr, daddr), 4)
>    reg0 <- lookup(reg1, set)
>
> Where "accept" is an alias of 0xffffffff and "drop" is 0 in the
> nft-sock case. The verdict part has been generalised so we can adapt
> nft to the corresponding packet classification engine.

that example is actually illustrates that nft needs to be continuously
tweaked to add features like 'set'. We can do better.

Here is the example from V2 series that shows how hash tables can be
used in C that translates to ebpf, without changing ebpf itself:
void dropmon(struct kprobe_args *ctx)
{
        void *loc;
        uint64_t *drop_cnt;
        /* skb:kfree_skb is defined as:
         * TRACE_EVENT(kfree_skb,
         *         TP_PROTO(struct sk_buff *skb, void *location),
         * so ctx->arg2 is 'location'
         */
        loc = (void *)ctx->arg2;

        drop_cnt = bpf_table_lookup(ctx, 0, &loc);
        if (drop_cnt) {
                __sync_fetch_and_add(drop_cnt, 1);
        } else {
                uint64_t init = 0;
                bpf_table_update(ctx, 0, &loc, &init);
        }
}
the above C program compiles into ebpf, attaches to kfree_skb() tracepoint
and counts packet drops at different locations.
userspace can read the table and print it in user friendly way while
the tracing filter is running or when it's stopped.
That's an example of fast drop monitor that is safe to insert into live kernel.

Actually I think it's wrong to even compare nft with ebpf.
ebpf doesn't dictate a new user interface. At all.
There is old bpf to write socket filters. It's good enough.
I'm not planning to hack libpcap just to generate ebpf.

User interface is orthogonal to kernel implementation.
We can argue whether C representation of filter is better than json,
but what kernel runs at the lowest level is independent of that.

Insisting that user interface and kernel representation must be
one-to-one is unnecessary restrictive. User interface can and
should evolve independently of what kernel is doing underneath.

In case of socket filters tcpdump/libpcap syntax is the user interface.
old bpf is a kernel-user api. I don't think there is a strong need
to change either. ebpf is not touching them, but helping to execute
tcpdump filters faster.
In case of tracing filters I propose C-like user interface.
Kernel API for translated C programs is a different matter.
ebpf in the kernel is just the engine to execute it.
1st and 2nd may look completely different after community feedback,
but in kernel ebpf engine can stay unmodified.

>
> Right, you can extend interfaces forever with lots of patchwork and
> "smart tricks" but that doesn't mean that will look nice...

I'm not sure what you mean here.

> As I said, I believe that having a nice extensible interface is
> extremely important to make it easier for development. If we have to
> rearrange the internal representation for some reason, we can do it
> indeed without bothering about making translations to avoid breaking
> userspace and having to use ugly tricks (just see sk_decode_filter()
> or any other translation to support any new way to express a
> filter...).

nice that your brought this up :)
As I mentioned in v4 thread sk_decode_filter() can be removed.
It was introduced to improve old interpreter performance and now
this part is obsolete.

> [...]
>> Say you want to translate nft-cmp instruction into sequence of native
>> comparisons. You'd need to use load from memory, compare and
>> branch operations. That's ebpf!
>
> Nope sorry, that's not ebpf. That's assembler code.

Well, in my previous email I tried to explain that assembler == ebpf :)
Please post x86_64 assembler code that future nft-jit suppose to
generate and I can post equivalent ebpf code that will be jited
exactly to your x86_64...

> [...]
>> You can view ebpf as a tool to achieve jiting of nft.
>> It will save you a lot of time.
>
> nft interface is already well-abstracted from the representation, so I
> don't find a good reason to make a step backward that will force us to
> represent the instructions using a fixed layout structure that is
> exposed to userspace, that we won't be able to change once if this
> gets into mainstream.

I don't think we're on the same page still.
To make this more productive, please say what feature you would
want to see supported and I can show how it is done without
changing ebpf insn set.

> Probably the nft is not the easiest path, I agree, it's been not so
> far if you look at the record. But with time and development hours
> from everyone, I believe we'll enjoy a nice framework.

No doubt that nftables is a nice framework. Let's keep it going
and let's make it faster.

Regards,
Alexei
