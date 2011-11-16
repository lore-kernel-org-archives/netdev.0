From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v2 PATCH 1/2] NETFILTER module xt_hmark new target for HASH
 based fw
Date: Wed, 16 Nov 2011 11:50:05 +0100
Message-ID: <20111116105005.GA10353@1984>
References: <b328f1j.5274a2398142147da04eb5e915d63283@obelix.schillstrom.com>
 <20111109143922.GC24174@1984>
 <201111161028.43078.hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, kaber@trash.net,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60427 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755881Ab1KPKuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 05:50:09 -0500
Content-Disposition: inline
In-Reply-To: <201111161028.43078.hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2011 at 10:28:42AM +0100, Hans Schillstrom wrote:
> I have some problems with the generator...,
> so I did some simple iperf tcp test with KVM:s i.e. standart tcp setup

I have some simple http traffic generator in case that you want to use
it:

http://1984.lsi.us.es/git/?p=http-client-benchmark/.git;a=summary

You have to use it with willy tarreau's httpterm in the server side.
Iperf is fine, I just wanted to share with you what I use it for
generating traffic.

It allows more interesting evaluation like making experiments with
very short flows and long ones. I think iperf doesn't allow that?
Well, I didn't look at it since long time ago but I remember that it
didn't fit with my needs. Evaluating only throught was not enough for
me. Sessions per seconds are also an interesting value to take into
account in my case.

> iptables just one rule 
> -A PREROUTING -d 10.0.0.10/32 -j HMARK --hmark-mod 0x2 --hmark-offs 0x64
> 
> Some typical values shows ~8% degradation with conntrack loaded
> 
> 
> a) Without conntrack loaded
> 
>  [  3]  0.0-10.0 sec  83.5 MBytes  70.0 Mbits/sec
> 
> 
> b) With conntrack loaded (no iptable rules in use --ctstate or -m conntrack)
> 
> [  3]  0.0-10.0 sec  78.0 MBytes  65.4 Mbits/sec
> 
> c) With iptables rule in use
> iptables -t mangle -A PREROUTING -d 10.0.0.10 -m conntrack --ctstate NEW -j HMARK --mod 2 --offs 100
> iptables -t mangle -A PREROUTING -d 10.0.0.10 -m conntrack --ctstate ESTABLISHED,RELATED  -j HMARK --mod 2 --offs 100
> iptables -t mangle -A PREROUTING -d 10.0.0.10 -m conntrack --ctstate INVALID -j DROP

You have to use connmark so we can skip the hashing in the
established case, otherwise conntrack is a clear loser :-). The point
of this experiment is to see if hashing every single packet is more
performance than hashing only the first one and using the ctmark for
established connections (so we only hash once!).

Eric Leblond wrote a nice documentation on connmark in his blog:

http://home.regit.org/netfilter-en/netfilter-connmark/

BTW, that related in the NEW rule. related is similar to New but for
the first packet of a related connection.

> [  3]  0.0-10.0 sec  77.4 MBytes  64.9 Mbits/sec
> 
> 
> A clean KVM with 3.2.0-rc1 kernel with virt-io 
> Module                  Size  Used by    Not tainted
> nf_conntrack_ipv4      16731  1 
> nf_defrag_ipv4         12436  1 nf_conntrack_ipv4
> xt_conntrack           12390  1 
> xt_hmark               12390  1 
> iptable_mangle         12390  1 
> ip_tables              20755  1 iptable_mangle
> ipip                   16515  0 
> tunnel4                12484  1 ipip

Thanks for taking the time to evaluate this. If you can repeat the
experiments with my comments, we can get interesting conclusions like
demystifying the fact that at conntrack is not that bad in terms of
throughput if you take advantage appropriately of what it provides ;-)
