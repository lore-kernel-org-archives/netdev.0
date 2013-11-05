From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next 2/3] netfilter: ip6_tables: use reasm skb for
 matching
Date: Tue, 5 Nov 2013 13:41:19 +0000
Message-ID: <20131105134118.GA5818@macbook.localnet>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
 <1383649333-6321-3-git-send-email-jiri@resnulli.us>
 <20131105133205.GC15370@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, coreteam@netfilter.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131105133205.GC15370@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 05, 2013 at 02:32:05PM +0100, Florian Westphal wrote:
> Jiri Pirko <jiri@resnulli.us> wrote:
> > This patch fixes for example following situation:
> > On HOSTA do:
> > ip6tables -I INPUT -p icmpv6 -j DROP
> > ip6tables -I INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
> 
> untested:
> 
> -A INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
> -A INPUT -p icmpv6 -m conntrack --ctstatus CONFIRMED -j ACCEPT
> -A INPUT -p icmpv6 -j DROP
> 
> > and on HOSTB you do:
> > ping6 HOSTA -s2000    (MTU is 1500)
> > 
> > Incoming echo requests will be filtered out on HOSTA. This issue does
> > not occur with smaller packets than MTU (where fragmentation does not happen).
> 
> Patrick, any reason not to kill the special-casing (ct has assigned helper or
> unconfirmed conntrack) in __ipv6_conntrack_in() ?
> 
> This should make ipv6 frag behaviour consistent; right now its rather
> confusing from ruleset point of view, especially the first packet
> of a connection is always seen as reassembled.
> 
> So with Jiris rules
> 
> -A INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
> -A INPUT -p icmpv6 -j DROP
> 
> ping6 -s $bignum works for the first packet but not for subsequent ones
> which is quite irritating.

Well, the reason was to avoid unnecessary work doing refragmentation
unless really required. I know its rather complicated, but IPv6 has
always required treating fragments manually or using conntrack state.

I'm not objecting to changing this, but the patches as they are are
not the way to go. First, moving nfct_frag to struct sk_buff seems
like a real waste of space for this quite rare case. Also, we can't
just use the reassembled packet in ip6tables, when modifying it we
will still output the unchanged fragments. An last of all, we'll be
executing the rules on the reassembled packet multiple times, one
for each fragment.

So if someone wants to change this, simply *only* pass the reassembled
packet through the netfilter hooks and drop the fragments, as in IPv4.
