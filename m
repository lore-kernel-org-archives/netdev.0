From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v8 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Fri, 18 Nov 2016 18:44:05 +0100
Message-ID: <20161118174405.GA9678@salvia>
References: <1479407229-14861-1-git-send-email-daniel@zonque.org>
 <1479407229-14861-6-git-send-email-daniel@zonque.org>
 <20161118123732.GA10400@salvia>
 <20161118171715.GA56632@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161118171715.GA56632-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 18, 2016 at 09:17:18AM -0800, Alexei Starovoitov wrote:
> On Fri, Nov 18, 2016 at 01:37:32PM +0100, Pablo Neira Ayuso wrote:
> > On Thu, Nov 17, 2016 at 07:27:08PM +0100, Daniel Mack wrote:
> > [...]
> > > @@ -312,6 +314,12 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
> > >  	skb->dev = dev;
> > >  	skb->protocol = htons(ETH_P_IP);
> > >  
> > > +	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
> > > +	if (ret) {
> > > +		kfree_skb(skb);
> > > +		return ret;
> > > +	}
> > > +
> > >  	/*
> > >  	 *	Multicasts are looped back for other local users
> > >  	 */
> > > @@ -364,12 +372,19 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
> > >  int ip_output(struct net *net, struct sock *sk, struct sk_buff *skb)
> > >  {
> > >  	struct net_device *dev = skb_dst(skb)->dev;
> > > +	int ret;
> > >  
> > >  	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
> > >  
> > >  	skb->dev = dev;
> > >  	skb->protocol = htons(ETH_P_IP);
> > >  
> > > +	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
> > > +	if (ret) {
> > > +		kfree_skb(skb);
> > > +		return ret;
> > > +	}
> > > +
> > >  	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
> > >  			    net, sk, skb, NULL, dev,
> > >  			    ip_finish_output,
> > 
> > Please, place this after the netfilter hook.
> > 
> > Since this new hook may mangle output packets, any mangling
> > potentially interfers and breaks conntrack.
> 
> actually this hook cannot mangle the packets, so no conntrack
> concerns.  Also this was brought up by Lorenzo earlier and consensus
> was that it's cleaner to leave it in this order.

Not yet probably, but this could be used to implement snat at some
point, you have potentially the infrastructure to do so in place
already.

> My reply:
> http://www.spinics.net/lists/cgroups/msg16675.html
> and Daniel's:
> http://www.spinics.net/lists/cgroups/msg16677.html
> and the rest of that thread.

Please place this afterwards since I don't want to update Netfilter
documentation to indicate that there is a new spot to debug before
POSTROUTING that may drop packets. People are used to debugging things
in a certain way, if packets are dropped after POSTROUTING, then
netfilter tracing will indicate the packet has successfully left our
framework and people will notice that packets are dropped somewhere
else, so they have a clue probably is this new layer.

Actually I remember you mentioned in a previous email that this hook
can be placed anywhere, and that they don't really need a fixed
location, if so, then it should not be much of a problem to change
this.

I can live with this new scenario where the kernel becomes a place
where everyone can push bpf blobs everywhere and your "code decides"
submission policy if others do as well, even if I frankly don't like
it. No problem. But please don't use the word "consensus" to justify
this, because this was not exactly what it was shown during Netconf.

So just send a v9 with this change I'm requesting and you have my word
I will not intefer anymore on this submission.

Thank you.
