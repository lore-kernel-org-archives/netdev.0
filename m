From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup ebpf egress programs
Date: Fri, 23 Sep 2016 15:17:39 +0200
Message-ID: <20160923131739.GA15828@salvia>
References: <20160919203533.GA888@salvia>
 <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
 <20160920142931.GA31438@salvia>
 <6584b975-fa3e-8d98-f0c7-a2c6b194b2b6@zonque.org>
 <20160921154533.GA13656@salvia>
 <20160921184827.GA15732@pox.localdomain>
 <20160922092138.GA12108@salvia>
 <20160922095411.GA5654@pox.localdomain>
 <20160922120554.GA1738@salvia>
 <57E3F4F9.70300@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        htejun-b10kYP2dOMg@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org,
        fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57E3F4F9.70300-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 22, 2016 at 05:12:57PM +0200, Daniel Borkmann wrote:
> On 09/22/2016 02:05 PM, Pablo Neira Ayuso wrote:
[...]
> >Have a look at net/ipv4/netfilter/nft_chain_route_ipv4.c for instance.
> >In your case, you have to add a new chain type:
> >
> >static const struct nf_chain_type nft_chain_bpf = {
> >         .name           = "bpf",
> >         .type           = NFT_CHAIN_T_bpf,
> >         ...
> >         .hooks          = {
> >                 [NF_INET_LOCAL_IN]      = nft_do_bpf,
> >                 [NF_INET_LOCAL_OUT]     = nft_do_bpf,
> >                 [NF_INET_FORWARD]       = nft_do_bpf,
> >                 [NF_INET_PRE_ROUTING]   = nft_do_bpf,
> >                 [NF_INET_POST_ROUTING]  = nft_do_bpf,
> >         },
> >};
> >
> >nft_do_bpf() is the raw netfilter hook that you register, this hook
> >will just execute to iterate over the list of bpf filters and run
> >them.
> >
> >This new chain is created on demand, so no overhead if not needed, eg.
> >
> >nft add table bpf
> >nft add chain bpf input { type bpf hook output priority 0\; }
> >
> >Then, you add a rule for each bpf program you want to run, just like
> >tc+bpf.
> 
> But from a high-level point of view, this sounds like a huge hack to me,
> in the sense that nft as a bytecode engine (from whole architecture I
> mean) calls into another bytecode engine such as bpf as an extension.

nft is not only bytecode engine, it provides a netlink socket
interface to register hooks (from user perspective, these are called
basechain). It is providing the infrastructure that you're lacking
indeed and addressing the concerns I mentioned about the visibility of
the global policy that you want to apply on the packet path.

As I explained you can potentially add any basechain type with
specific semantics. Proposed semantics for this bpf chain would be:

1) You can use any of the existing netfilter hooks.
2) You can only run bpf program from there. No chance for the user
   can mix nftables with bpf VM.

> And bpf code from there isn't using any of the features from nft
> besides being invoked from the hook

I think there's a misunderstading here.

You will not run nft_do_chain(), you don't waste cycles to run what is
specific to nftables. You will just run nft_do_bpf() which will just
do what you want to run for each packet. Thus, you have control on
what nft_do_bpf() does and decide on what that function spend cycles
on.

> [...] I was hoping that nft would try to avoid some of those exotic
> modules we have from xt, I would consider xt_bpf (no offense ;))

This has nothing to do with it. In xt_bpf you waste cycles running
code that is specific to iptables, what I propose would not, just the
generic hook code and then your code.

[...]
> >Benefits are, rewording previous email:
> >
> >* You get access to all of the existing netfilter hooks in one go
> >   to run bpf programs. No need for specific redundant hooks. This
> >   provides raw access to the netfilter hook, you define the little
> >   code that your hook runs before you bpf run invocation. So there
> >   is *no need to bloat the stack with more hooks, we use what we
> >   have.*
> 
> But also this doesn't really address the fundamental underlying problem
> that is discussed here. nft doesn't even have cgroups v2 support.

You don't need native cgroups v2 support in nft, you just run bpf
programs from the native bpf basechain type. So whatever bpf supports,
you can do it.

Instead, if you take this approach, you will get access to all of the
existing hooks to run bpf programs, this includes arp, bridge and
potentially run filters for both ip and ip6 through our inet family.

[...]
> Or would the idea be that the current netfilter hooks would be redone in
> a way that they are generic enough so that any other user could make use
> of it independent of netfilter?

Redone? Why? What do you need, a rename?

Dependencies are very few: CONFIG_NETFILTER for the hooks,
CONFIG_NF_TABLES to obtain the netlink interface to load the bpf
programs and CONFIG_NF_TABLES_BPF to define the bpf basechain type
semantics to run bpf programs from there. It's actually very little
boilerplate code.

Other than that, I can predict where you're going: You will end up
adding a hook just before/after every of the existing netfilter hooks,
and that is really nonsense to me. Why bloat the stack with more
hooks? Use what it is already available.
