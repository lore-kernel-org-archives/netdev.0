From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Wed, 13 Jan 2010 04:50:12 -0500
Message-ID: <4B4D9754.9070902@gmail.com>
References: <4B49D001.4000302@gmail.com> <4B4C4962.8040207@gmail.com> <4B4C52EA.6070705@gmail.com> <4B4CAD45.5080606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755287Ab0AMJuS@vger.kernel.org>
In-Reply-To: <4B4CAD45.5080606@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson wrote:
> Eric Dumazet wrote:
>> Seems fine, but :
>>
>> 1) What means the "Transformed ?" you wrote several times ?
>>
> The only reason that I've been able to figure out for having the
> skb->len test in those places is the preceding xfrm4_policy_check()
> or xfrm6_policy_check() must be able to shrink the skb->len?
> 
> When I did the original transform stuff in other code circa 1995, I'd
> envisioned IP length or link layer (PPP) length shrinking (removing
> padding after block ciphers) -- and apparently this implementation
> extended that concept to transport layer, too.
> 
> Personally, I'd prefer that a single test be placed in the appropriate
> spot in the xfrm* functions, instead.  Anybody know where?
> 
I've spent another day staring at the xfrm* functions.  Since nobody
familiar with them has answered my recent questions, it seems I'm on my
own....  So, here are my conclusions:

The current xfrm* code shouldn't change the TCP header.  If anything did,
the current tests wouldn't work anyway.  For example:

tcp_ipv4:
tcp_v4_rcv()
...
1645 no_tcp_socket:
1646         if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
1647                 goto discard_it;
1648
1649         if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {

This code depends on the *th pointer remaining unchanged.  A pullup or
skb clone could make the pointer invalid.

Likewise, the checksum occurs after the xfrm* code.  Thus, the xfrm*
cannot alter, decrypt, or tunnel the input data.

Therefore, I'll remove those existing extraneous skb->len tests.  And
I'll add these criteria to the include/net/xfrm.h for future reference.
