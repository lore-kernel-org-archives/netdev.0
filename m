From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Bug in net/ipv6/ip6_fib.c:fib6_dump_table()
Date: Sun, 24 Jun 2012 00:55:46 +0400
Message-ID: <20120623205546.GA15964@ms2.inr.ac.ru>
References: <1340353746.4604.9502.camel@edumazet-glaptop> <4FE476A6.1050209@akamai.com> <1340388785.4604.11442.camel@edumazet-glaptop> <20120622.170237.1504103690155447356.davem@davemloft.net> <1340429851.4604.11942.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johunt@akamai.com,
	kaber@trash.net, dbavatar@gmail.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, pekkas@netcore.fi,
	linux-kernel@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340429851.4604.11942.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 23, 2012 at 07:37:31AM +0200, Eric Dumazet wrote:
> All other /proc/net files don't have a such sophisticated walkers aware
> mechanism

I can explain why.

IPv6 routing table has a capital management drawback: core policy rules are mixed
with dynamic cache and addrconf routes in one structure.
(BTW it is one of reasons why I did not want to integrate routing cache to fib for IPv4)

Do you see the problem? F.e. when you do iptables-save, you do not expect
that it can occasionally miss some rules (unless you mess with it in parallel, of course)
The same is here. When you dump routing table, you are allowed to miss some cache routes,
but if you have a chance to miss at least one of important routes just because
unimportant dynamic part is alway under change, it is fatal.

There are a lot of ways to solve the problem, all of them have some flaws.
F.e. I can remember:
* atomic dump like bsd sysctl.
* keeping administrative routes in a separate list, which can be walked using skip/count
etc.

This way with walkers I chose because it looked quite optimal and because
it was an exciting little task for brains . :-)


> (easily DOSable by the way, if some guy opens 10.000 handles
> and suspend in the middle the dumps).

This is true. The easiest way to fix this is just to limit amount of readers,
putting them on hold.

Alexey
