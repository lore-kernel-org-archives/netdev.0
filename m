From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Thu, 22 Sep 2016 14:05:54 +0200
Message-ID: <20160922120554.GA1738@salvia>
References: <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
 <20160919203533.GA888@salvia>
 <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
 <20160920142931.GA31438@salvia>
 <6584b975-fa3e-8d98-f0c7-a2c6b194b2b6@zonque.org>
 <20160921154533.GA13656@salvia>
 <20160921184827.GA15732@pox.localdomain>
 <20160922092138.GA12108@salvia>
 <20160922095411.GA5654@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160922095411.GA5654-4EA/1caXOu0mYvmMESoHnA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 22, 2016 at 11:54:11AM +0200, Thomas Graf wrote:
> On 09/22/16 at 11:21am, Pablo Neira Ayuso wrote:
> > I have a hard time to buy this new specific hook, I think we should
> > shift focus of this debate, this is my proposal to untangle this:
> >
> > You add a net/netfilter/nft_bpf.c expression that allows you to run
> > bpf programs from nf_tables. This expression can either run bpf
> > programs in a similar fashion to tc+bpf or run the bpf program that
> > you have attached to the cgroup.
>
> So for every packet processed, you want to require the user to load
> and run a (unJITed) nft program acting as a wrapper to run a JITed
> BPF program? What it the benefit of this model compared to what Daniel
> is proposing? The hooking point is the same. This only introduces
> additional per packet overhead in the fast path. Am I missing
> something?

Have a look at net/ipv4/netfilter/nft_chain_route_ipv4.c for instance.
In your case, you have to add a new chain type:

static const struct nf_chain_type nft_chain_bpf = {
        .name           = "bpf",
        .type           = NFT_CHAIN_T_BPF,
        ...
        .hooks          = {
                [NF_INET_LOCAL_IN]      = nft_do_bpf,
                [NF_INET_LOCAL_OUT]     = nft_do_bpf,
                [NF_INET_FORWARD]       = nft_do_bpf,
                [NF_INET_PRE_ROUTING]   = nft_do_bpf,
                [NF_INET_POST_ROUTING]  = nft_do_bpf,
        },
};

nft_do_bpf() is the raw netfilter hook that you register, this hook
will just execute to iterate over the list of bpf filters and run
them.

This new chain is created on demand, so no overhead if not needed, eg.

nft add table bpf
nft add chain bpf input { type bpf hook output priority 0\; }

Then, you add a rule for each bpf program you want to run, just like
tc+bpf.

Benefits are, rewording previous email:

* You get access to all of the existing netfilter hooks in one go
  to run bpf programs. No need for specific redundant hooks. This
  provides raw access to the netfilter hook, you define the little
  code that your hook runs before you bpf run invocation. So there
  is *no need to bloat the stack with more hooks, we use what we
  have.*

* This is consistent to what we offer via tc+bpf, similar design idea.
  Users are already familiar with this approach.

* It becomes easily visible to the user that a bpf program is running
  from whenever in the packet path, so from a sysadmin perspective is
  is easy to dump the configuration via netlink interface using the
  existing tooling in case that troubleshooting is required.
