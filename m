From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [v2 PATCH 1/2] NETFILTER module xt_hmark new target for HASH based fw
Date: Wed, 16 Nov 2011 10:28:42 +0100
Message-ID: <201111161028.43078.hans@schillstrom.com>
References: <b328f1j.5274a2398142147da04eb5e915d63283@obelix.schillstrom.com> <20111109143922.GC24174@1984>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, kaber@trash.net,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw11.han.skanova.net ([81.236.55.20]:34066 "EHLO
	smtp-gw11.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902Ab1KPJ2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 04:28:48 -0500
In-Reply-To: <20111109143922.GC24174@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Pablo
On Wednesday, November 09, 2011 15:39:22 Pablo Neira Ayuso wrote:
> On Tue, Nov 08, 2011 at 04:12:27PM +0100, Hans Schillstrom wrote:
> > >BTW, do you have some number of this running with and without
> > >conntrack? It would be interesting to have.
> > 
> > I didn't save them,  but I can make a new benchmark later on.
> 
> Thanks, I'm interested in them. It can be just xt_HMARK with and
> without conntrack enabled. Also make sure that you use stateful
> rule-set if conntrack is enabled (thus, resulting in hashing only
> once, not every packet). Otherwise, conntrack will not provide
> any improvement.
> 

I have some problems with the generator..., 
so I did some simple iperf tcp test with KVM:s i.e. standart tcp setup

iptables just one rule 
-A PREROUTING -d 10.0.0.10/32 -j HMARK --hmark-mod 0x2 --hmark-offs 0x64

Some typical values shows ~8% degradation with conntrack loaded


a) Without conntrack loaded

 [  3]  0.0-10.0 sec  83.5 MBytes  70.0 Mbits/sec


b) With conntrack loaded (no iptable rules in use --ctstate or -m conntrack)

[  3]  0.0-10.0 sec  78.0 MBytes  65.4 Mbits/sec

c) With iptables rule in use
iptables -t mangle -A PREROUTING -d 10.0.0.10 -m conntrack --ctstate NEW -j HMARK --mod 2 --offs 100
iptables -t mangle -A PREROUTING -d 10.0.0.10 -m conntrack --ctstate ESTABLISHED,RELATED  -j HMARK --mod 2 --offs 100
iptables -t mangle -A PREROUTING -d 10.0.0.10 -m conntrack --ctstate INVALID -j DROP

[  3]  0.0-10.0 sec  77.4 MBytes  64.9 Mbits/sec


A clean KVM with 3.2.0-rc1 kernel with virt-io 
Module                  Size  Used by    Not tainted
nf_conntrack_ipv4      16731  1 
nf_defrag_ipv4         12436  1 nf_conntrack_ipv4
xt_conntrack           12390  1 
xt_hmark               12390  1 
iptable_mangle         12390  1 
ip_tables              20755  1 iptable_mangle
ipip                   16515  0 
tunnel4                12484  1 ipip


/Hans
