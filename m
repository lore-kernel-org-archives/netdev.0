From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Mon, 19 Sep 2016 22:35:33 +0200
Message-ID: <20160919203533.GA888@salvia>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
 <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2016 at 09:30:02PM +0200, Daniel Mack wrote:
> On 09/19/2016 09:19 PM, Pablo Neira Ayuso wrote:
> > On Mon, Sep 19, 2016 at 06:44:00PM +0200, Daniel Mack wrote:
> >> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> >> index 6001e78..5dc90aa 100644
> >> --- a/net/ipv6/ip6_output.c
> >> +++ b/net/ipv6/ip6_output.c
> >> @@ -39,6 +39,7 @@
> >>  #include <linux/module.h>
> >>  #include <linux/slab.h>
> >>  
> >> +#include <linux/bpf-cgroup.h>
> >>  #include <linux/netfilter.h>
> >>  #include <linux/netfilter_ipv6.h>
> >>  
> >> @@ -143,6 +144,7 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
> >>  {
> >>  	struct net_device *dev = skb_dst(skb)->dev;
> >>  	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
> >> +	int ret;
> >>  
> >>  	if (unlikely(idev->cnf.disable_ipv6)) {
> >>  		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
> >> @@ -150,6 +152,12 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
> >>  		return 0;
> >>  	}
> >>  
> >> +	ret = cgroup_bpf_run_filter(sk, skb, BPF_CGROUP_INET_EGRESS);
> >> +	if (ret) {
> >> +		kfree_skb(skb);
> >> +		return ret;
> >> +	}
> > 
> > 1) If your goal is to filter packets, why so late? The sooner you
> >    enforce your policy, the less cycles you waste.
> > 
> > Actually, did you look at Google's approach to this problem?  They
> > want to control this at socket level, so you restrict what the process
> > can actually bind. That is enforcing the policy way before you even
> > send packets. On top of that, what they submitted is infrastructured
> > so any process with CAP_NET_ADMIN can access that policy that is being
> > applied and fetch a readable policy through kernel interface.
> 
> Yes, I've seen what they propose, but I want this approach to support
> accounting, and so the code has to look at each and every packet in
> order to count bytes and packets. Do you know of any better place to put
> the hook then?

Accounting is part of the usecase that fits into the "network
introspection" idea that has been mentioned here, so you can achieve
this by adding a hook that returns no verdict, so this becomes similar
to the tracing infrastructure.

> That said, I can well imagine more hooks types that also operate at port
> bind time. That would be easy to add on top.

Filtering packets with cgroups is braindead.

You have the means to ensure that processes send no packets via
restricting port binding, there is no reason to do this any later for
locally generated traffic.
