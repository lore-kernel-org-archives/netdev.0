From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/3] netfilter: ip6_tables: use reasm skb for
 matching
Date: Tue, 5 Nov 2013 21:55:20 +0100
Message-ID: <20131105205520.GD2438@minipsycho.orion>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
 <1383649333-6321-3-git-send-email-jiri@resnulli.us>
 <20131105133205.GC15370@breakpoint.cc>
 <20131105134118.GA5818@macbook.localnet>
 <20131105150115.GB2438@minipsycho.orion>
 <20131105181633.GA7435@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, coreteam@netfilter.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:54077 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755388Ab3KEUzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 15:55:24 -0500
Received: by mail-ea0-f173.google.com with SMTP id g10so4474251eak.4
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 12:55:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131105181633.GA7435@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 05, 2013 at 07:16:33PM CET, kaber@trash.net wrote:
>On Tue, Nov 05, 2013 at 04:01:15PM +0100, Jiri Pirko wrote:
>> Tue, Nov 05, 2013 at 02:41:19PM CET, kaber@trash.net wrote:
>> >On Tue, Nov 05, 2013 at 02:32:05PM +0100, Florian Westphal wrote:
>> >> Jiri Pirko <jiri@resnulli.us> wrote:
>> >> > This patch fixes for example following situation:
>> >> > On HOSTA do:
>> >> > ip6tables -I INPUT -p icmpv6 -j DROP
>> >> > ip6tables -I INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
>> >> 
>> >> untested:
>> >> 
>> >> -A INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
>> >> -A INPUT -p icmpv6 -m conntrack --ctstatus CONFIRMED -j ACCEPT
>> >> -A INPUT -p icmpv6 -j DROP
>> >> 
>> >> > and on HOSTB you do:
>> >> > ping6 HOSTA -s2000    (MTU is 1500)
>> >> > 
>> >> > Incoming echo requests will be filtered out on HOSTA. This issue does
>> >> > not occur with smaller packets than MTU (where fragmentation does not happen).
>> >> 
>> >> Patrick, any reason not to kill the special-casing (ct has assigned helper or
>> >> unconfirmed conntrack) in __ipv6_conntrack_in() ?
>> >> 
>> >> This should make ipv6 frag behaviour consistent; right now its rather
>> >> confusing from ruleset point of view, especially the first packet
>> >> of a connection is always seen as reassembled.
>> >> 
>> >> So with Jiris rules
>> >> 
>> >> -A INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
>> >> -A INPUT -p icmpv6 -j DROP
>> >> 
>> >> ping6 -s $bignum works for the first packet but not for subsequent ones
>> >> which is quite irritating.
>> >
>> >Well, the reason was to avoid unnecessary work doing refragmentation
>> >unless really required. I know its rather complicated, but IPv6 has
>> >always required treating fragments manually or using conntrack state.
>> >
>> >I'm not objecting to changing this, but the patches as they are are
>> >not the way to go. First, moving nfct_frag to struct sk_buff seems
>> 
>> I'm a bit lost. What "nfct_frag" are you reffering to here?
>
>I meant nfct_reasm of course.

The patch is not moving this to struct sk_buff. It is already there.

>
>> >like a real waste of space for this quite rare case. Also, we can't
>> >just use the reassembled packet in ip6tables, when modifying it we
>> >will still output the unchanged fragments. An last of all, we'll be
>> >executing the rules on the reassembled packet multiple times, one
>> >for each fragment.
>> 
>> Reassembled skb would be only used for matching where no changes takes
>> place.
>
>That still doesn't work, our matches are not purely passive.
>
>> End even though, the matching is now done for each fragment skb anyway. The
>> change is only to do it on different skb. I see no erformance or any
>> other problem in that.
>
>Accounting, quota, statistic, limit, ... come to mind. Basically any
>match that keeps state.

Ok. Makes sense.

>
>> >So if someone wants to change this, simply *only* pass the reassembled
>> >packet through the netfilter hooks and drop the fragments, as in IPv4.
>> 
>> This is unfortunatelly not possible because in forwarding use case, the
>> fragments have to be send out as they come in.
>
>No, the IPv6 NAT patches fixed that, we still do proper refragmentation
>and we still respect the original fragment sizes, thus are not responsible
>for potentially exceeding the PMTU on the following path.

Ok. So the plan is to remove net/ipv6/netfilter/nf_conntrack_reasm.c
code entirely and use net/ipv6/reassembly.c code directly from
nf_defrag_ipv6. This would result in very similar code currently ipv4
has. 
