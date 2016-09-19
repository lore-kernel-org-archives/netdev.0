From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Mon, 19 Sep 2016 13:13:27 -0700
Message-ID: <20160919201322.GA84770@ast-mbp.thefacebook.com>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
 <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160919191910.GA984@salvia>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2016 at 09:19:10PM +0200, Pablo Neira Ayuso wrote:
> On Mon, Sep 19, 2016 at 06:44:00PM +0200, Daniel Mack wrote:
> > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> > index 6001e78..5dc90aa 100644
> > --- a/net/ipv6/ip6_output.c
> > +++ b/net/ipv6/ip6_output.c
> > @@ -39,6 +39,7 @@
> >  #include <linux/module.h>
> >  #include <linux/slab.h>
> >  
> > +#include <linux/bpf-cgroup.h>
> >  #include <linux/netfilter.h>
> >  #include <linux/netfilter_ipv6.h>
> >  
> > @@ -143,6 +144,7 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
> >  {
> >  	struct net_device *dev = skb_dst(skb)->dev;
> >  	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
> > +	int ret;
> >  
> >  	if (unlikely(idev->cnf.disable_ipv6)) {
> >  		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
> > @@ -150,6 +152,12 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
> >  		return 0;
> >  	}
> >  
> > +	ret = cgroup_bpf_run_filter(sk, skb, BPF_CGROUP_INET_EGRESS);
> > +	if (ret) {
> > +		kfree_skb(skb);
> > +		return ret;
> > +	}
> 
> 1) If your goal is to filter packets, why so late? The sooner you
>    enforce your policy, the less cycles you waste.
> 
> Actually, did you look at Google's approach to this problem?  They
> want to control this at socket level, so you restrict what the process
> can actually bind. That is enforcing the policy way before you even
> send packets. On top of that, what they submitted is infrastructured
> so any process with CAP_NET_ADMIN can access that policy that is being
> applied and fetch a readable policy through kernel interface.
> 
> 2) This will turn the stack into a nightmare to debug I predict. If
>    any process with CAP_NET_ADMIN can potentially attach bpf blobs
>    via these hooks, we will have to include in the network stack

a process without CAP_NET_ADMIN can attach bpf blobs to
system calls via seccomp. bpf is already used for security and policing.

>    traveling documentation something like: "Probably you have to check
>    that your orchestrator is not dropping your packets for some
>    reason". So I wonder how users will debug this and how the policy that
>    your orchestrator applies will be exposed to userspace.

as far as bpf debuggability/visibility there are various efforts on the way:
for kernel side:
- ksym for jit-ed programs
- hash sum for prog code
- compact type information for maps and various pretty printers
- data flow analysis of the programs
for user space:
- from bpf asm reconstruct the program in the high level language
  (there is p4 to bpf, this effort is about bpf to p4)
