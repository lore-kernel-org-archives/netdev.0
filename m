From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Thu, 13 Mar 2014 13:29:13 +0100
Message-ID: <20140313122913.GA4898@localhost>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
 <531EE5A2.7090501@redhat.com>
 <CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
 <20140312091500.GA4638@localhost>
 <CAMEtUuztfWniTr+3u6ttuygvG=xYdp0ANn_w9MGqacQvHrXtWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>, kaber@trash.net,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuztfWniTr+3u6ttuygvG=xYdp0ANn_w9MGqacQvHrXtWA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 08:29:07PM -0700, Alexei Starovoitov wrote:
> On Wed, Mar 12, 2014 at 2:15 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
[...]
> The patches don't explain the reasons to do nft socket filtering.

OK, some reasons from the interface point of view:

1) It provides an extensible interface to userspace. We didn't
   invented a new wheel in that regard, we just reused the
   extensibility of TLVs used in netlink as intermediate format
   between user and kernelspace, also used many other applications
   outthere. The TLV parsing and building is not new code, most that of
   that code has been exposed to userspace already through netlink.

2) It shows that, with little generalisation, we can open the door to
   one single *classification interface* for the users. Just make some
   little googling, you'll find *lots of people* barfing on the fact that
   we have that many interfaces to classify packets in Linux. And I'm
   *not* talking about the packet classification approach itself, that's a
   different debate of course.

[...]
> Simplicity and performance should be the deciding factor.
> imo nft+sock_filter example is not simple.

OK, some comments in that regard:

1) Simplicity: With the nft approach you can just use a filter
expressed in json, eg.

{"rule":
 {"expr":[
  {"type":"meta","dreg":1,"key":"protocol"},
  {"type":"cmp","sreg":1,"op":"eq","cmpdata":{"data_reg":{"type":"value","len":2,"data0":"0x00000008"}}},
  {"type":"payload","dreg":1,"offset":9,"len":1,"base":"network"},
  {"type":"cmp","sreg":1,"op":"eq","cmpdata":{"data_reg":{"type":"value","len":1,"data0":"0x00000006"}}},
  {"type":"immediate","dreg":0,"immediatedata":{"data_reg":{"type":"verdict","verdict":"0xffffffff"}}}]
 }
}

Which is still more readable and easier to maintain that a BPF
snippet. So you just pass it to the json parser in the libnftnl
library (or whatever other better minimalistic library we would ever
have) which transforms this to TLV format that you can pass to the
kernel.  The kernel will do the job to translate this.

How are users going to integrate the restricted C's eBPF code
infrastructure into their projects? I don't think that will be simple.
They will likely include the BPF snippet to avoid all the integration
burden, as it already happens in many projects with BPF filters.

2) Performance. Patrick has been doing many progress with the generic
   set infrastructure for nft. In that regard, we aim to achieve
   performance by arranging data using performance data structures,
   *jit is not the only way to boost performance* (although we also
   want to have it).

Some example:

   set type IPv4 address = { N thousands of IPv4 addresses }

   reg1 <- payload(network header, offsetof(struct iphdr, daddr), 4)
   lookup(reg1, set)
   reg0 <- immediate(0xffffffff)

Or even better, using dictionaries:

   set type IPv4 address = { 1.1.1.1 : accept, 2.2.2.2 : accept, 3.3.3.3 : drop ...}

   reg1 <- payload(network header, offsetof(struct iphdr, daddr), 4)
   reg0 <- lookup(reg1, set)

Where "accept" is an alias of 0xffffffff and "drop" is 0 in the
nft-sock case. The verdict part has been generalised so we can adapt
nft to the corresponding packet classification engine.

This part just needs a follow-up patch to add set-based filtering for
nft-sockets. See this for more information about ongoing efforts on
the nft set infrastructure: http://patchwork.ozlabs.org/patch/326368/
that will also integrate into nft-sock.

[...]
> > +struct sock_filter_ext {
> > +       __u8    code;    /* opcode */
> > +       __u8    a_reg:4; /* dest register */
> > +       __u8    x_reg:4; /* source register */
> > +       __s16   off;     /* signed offset */
> > +       __s32   imm;     /* signed immediate constant */
> > +};
> >
> > If I didn't miss anything from your patchset, that structure is again
> > exposed to userspace, so we won't be able to change it ever unless we
> > add a new binary interface.
> >
> > From the user interface perspective, our nft approach is quite
> > different, from userspace you express the filter using TLVs (like in
> > the payload of the netlink message). Then, nf_tables core
> > infrastructure parses this and transforms it to the kernel
> > representation. It's very flexible since you don't expose the internal
> > representation to userspace, which means that we can change the
> > internal layout anytime, thus, highly extensible.
> 
> bpf/ebpf is an instruction set. Arguing about fixed vs non-fixed
> insn size is like arguing x86 variable encoding vs sparc fixed.
> Both are infinitely flexible.

Right, you can extend interfaces forever with lots of patchwork and
"smart tricks" but that doesn't mean that will look nice...

As I said, I believe that having a nice extensible interface is
extremely important to make it easier for development. If we have to
rearrange the internal representation for some reason, we can do it
indeed without bothering about making translations to avoid breaking
userspace and having to use ugly tricks (just see sk_decode_filter()
or any other translation to support any new way to express a
filter...).

[...]
> Say you want to translate nft-cmp instruction into sequence of native
> comparisons. You'd need to use load from memory, compare and
> branch operations. That's ebpf!

Nope sorry, that's not ebpf. That's assembler code.

[...]
> You can view ebpf as a tool to achieve jiting of nft.
> It will save you a lot of time.

nft interface is already well-abstracted from the representation, so I
don't find a good reason to make a step backward that will force us to
represent the instructions using a fixed layout structure that is
exposed to userspace, that we won't be able to change once if this
gets into mainstream.

Probably the nft is not the easiest path, I agree, it's been not so
far if you look at the record. But with time and development hours
from everyone, I believe we'll enjoy a nice framework.
