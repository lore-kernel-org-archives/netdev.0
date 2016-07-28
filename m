From: Florian Westphal <fw@strlen.de>
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
Date: Thu, 28 Jul 2016 16:48:32 +0200
Message-ID: <20160728144832.GA26237@breakpoint.cc>
References: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"edumazet@google.com" <edumazet@google.com>
To: Brandon Cazander <brandon.cazander@multapplied.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:37784 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932437AbcG1PPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 11:15:14 -0400
Content-Disposition: inline
In-Reply-To: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandon Cazander <brandon.cazander@multapplied.net> wrote:
> Hopefully that's enough detail to replicate this issue. I have the full environment set up for both working and non-working kernel versions, so please let me know if there's anything else I can provide.

No need, this reproduces easily with this two-line ruleset:

-t nat -A PREROUTING -d 192.168.7.20/32 -i eth0 -j DNAT --to-destination 192.168.8.1
-t mangle -A PREROUTING -p tcp -m tcp --dport 8080 -j TPROXY --on-port 9876 --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1

AFAIU the problem is this:

SYN:
1. -j TPROXY finds listen sk, redirects to it
2. DNAT takes place (iphdr(skb)->daddr is mangled).
3. tcp stack puts request sk into ehash table.

Note that the ehash entry uses the updated/dnatted address.

ACK:
1. -j TPROXY finds no established or request socket
since it uses iph->daddr but ehash contains dnatted-to address
... so we redirect to the listener socket.

Before the ehash change, for skb to listen sk the kernel
used to search both the listener socket request queue and
the ehash table, using the iphdr daddr (which at this point
is the DNAT'ed address).  So this used to work because this
returns the request sk.

After the ehash change we only check syn cookie and will then
emit a reset.

Eric, AFAICS the only solution for this is to extend
TPROXY and obtain the lookup saddr/daddr info from the conntrack
entry instead of the ip headers, which should make this work again.

Do you agree?
Any other suggestions?

Thanks!
