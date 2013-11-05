From: Florian Westphal <fw@strlen.de>
Subject: Re: [patch net-next 2/3] netfilter: ip6_tables: use reasm skb for
 matching
Date: Tue, 5 Nov 2013 14:32:05 +0100
Message-ID: <20131105133205.GC15370@breakpoint.cc>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
 <1383649333-6321-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, coreteam@netfilter.org, fw@strlen.de
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1383649333-6321-3-git-send-email-jiri@resnulli.us>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Pirko <jiri@resnulli.us> wrote:
> This patch fixes for example following situation:
> On HOSTA do:
> ip6tables -I INPUT -p icmpv6 -j DROP
> ip6tables -I INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT

untested:

-A INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
-A INPUT -p icmpv6 -m conntrack --ctstatus CONFIRMED -j ACCEPT
-A INPUT -p icmpv6 -j DROP

> and on HOSTB you do:
> ping6 HOSTA -s2000    (MTU is 1500)
> 
> Incoming echo requests will be filtered out on HOSTA. This issue does
> not occur with smaller packets than MTU (where fragmentation does not happen).

Patrick, any reason not to kill the special-casing (ct has assigned helper or
unconfirmed conntrack) in __ipv6_conntrack_in() ?

This should make ipv6 frag behaviour consistent; right now its rather
confusing from ruleset point of view, especially the first packet
of a connection is always seen as reassembled.

So with Jiris rules

-A INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
-A INPUT -p icmpv6 -j DROP

ping6 -s $bignum works for the first packet but not for subsequent ones
which is quite irritating.

This change would obviously have userspace visibility (e.g. -m frag
won't work anymore when conntrack is on), but so far I couldn't come
up with a scenario where a legitimate ruleset could break.
