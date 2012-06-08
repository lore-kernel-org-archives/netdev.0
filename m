From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG (?) multicast loopback (IP6SKB_FORWARDED)
Date: Fri, 08 Jun 2012 19:23:42 +0200
Message-ID: <1339176222.6001.131.camel@edumazet-glaptop>
References: <7813214.2267681339174116704.JavaMail.defaultUser@defaultHost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "maxd@inwind.it" <maxd@inwind.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:42684 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157Ab2FHRXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 13:23:47 -0400
Received: by wgbdr13 with SMTP id dr13so1100886wgb.1
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 10:23:46 -0700 (PDT)
In-Reply-To: <7813214.2267681339174116704.JavaMail.defaultUser@defaultHost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-08 at 18:48 +0200, maxd@inwind.it wrote:
> Hi guys,
> I found a probably wrong behaviour while doing some tests with multicast 
> routing on IPv6 with kernel 2.6.29. I will try to describe what's wrong in the 
> code in the following. I will use the latest kernel sources (3.5-rc1)
> as reference source code (line numbers are taken there).
> Let's assume a scenario with a node with two network interfaces acting as a 
> multicast router. The router receives the message on one interface and needs to 
> forward it on the other interface. Looking at the packet flow inside the 
> kernel, we notice that
> 
> in ip6mr.c, line 2282, a flag is set:
> IP6CB(skb)->flags |= IP6SKB_FORWARDED;
> 
> After this, a multicast packet can be looped back (see line 124 in ip6_output.
> c where function ip6_dev_loopback_xmit is called). 
> The packet is hence reinjected in the stack.
> 
> The packet is processed by function ipv6_rcv (ip6_input.c), and then by 
> ipv6_mc_input (ip6_input.c).
> 
> In ipv6_rcv, line 82, the previously set flag is cleared
> memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
> 
> In ipv6_mc_input, , line 268, the flag is checked to determine if the packet 
> has been already forwarded. Since the flag has been cleared, the kernel cannot 
> determine that the packet has been looped back, and will hence try to forward 
> it again.
> 
> Trying to forward a looped back packet determines a wrong behaviour of the 
> multicast routing protocol (PIM): the kernel believes that a multicast message 
> has been received from a wrong interface (line 1993 in ip6mr.c), discard the 
> message (this explains why the packet does not loop forever) and triggers the 
> transmission of an ASSERT message. Basically, the node ends up sending an 
> ASSERT message because of a looped back packet. 
> 
> WDYT? Is my analysis correct? Which is the best way to fix this issue?

I guess your analysis is correct, try to revert commit
6b7fdc3ae18a0598a999156b62d55ea55220e00f ([IPV6]: Clean skb cb on IPv6
input) ?
