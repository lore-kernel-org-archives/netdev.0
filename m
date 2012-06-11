From: "maxd@inwind.it" <maxd@inwind.it>
Subject: R: Re: BUG (?) multicast loopback (IP6SKB_FORWARDED)
Date: Mon, 11 Jun 2012 12:09:18 +0200 (CEST)
Message-ID: <3948604.8447911339409358263.JavaMail.defaultUser@defaultHost>
Reply-To: "maxd@inwind.it" <maxd@inwind.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outrelay02.libero.it ([212.52.84.102]:37949 "EHLO
	outrelay02.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab2FKKJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 06:09:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
thanks for the quick reply. It seems that reverting the patch fixes the issue, 
and I have not observed any unintended behaviour so far.
Do you know what was the motivation for the patch?

Regards,
Massimiliano

>----Messaggio originale----
>Da: eric.dumazet@gmail.com
>Data: 08/06/2012 19.23
>A: "maxd@inwind.it"<maxd@inwind.it>
>Cc: <netdev@vger.kernel.org>
>Ogg: Re: BUG (?) multicast loopback (IP6SKB_FORWARDED)
>
>On Fri, 2012-06-08 at 18:48 +0200, maxd@inwind.it wrote:
>> Hi guys,
>> I found a probably wrong behaviour while doing some tests with multicast 
>> routing on IPv6 with kernel 2.6.29. I will try to describe what's wrong in 
the 
>> code in the following. I will use the latest kernel sources (3.5-rc1)
>> as reference source code (line numbers are taken there).
>> Let's assume a scenario with a node with two network interfaces acting as 
a 
>> multicast router. The router receives the message on one interface and 
needs to 
>> forward it on the other interface. Looking at the packet flow inside the 
>> kernel, we notice that
>> 
>> in ip6mr.c, line 2282, a flag is set:
>> IP6CB(skb)->flags |= IP6SKB_FORWARDED;
>> 
>> After this, a multicast packet can be looped back (see line 124 in 
ip6_output.
>> c where function ip6_dev_loopback_xmit is called). 
>> The packet is hence reinjected in the stack.
>> 
>> The packet is processed by function ipv6_rcv (ip6_input.c), and then by 
>> ipv6_mc_input (ip6_input.c).
>> 
>> In ipv6_rcv, line 82, the previously set flag is cleared
>> memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
>> 
>> In ipv6_mc_input, , line 268, the flag is checked to determine if the 
packet 
>> has been already forwarded. Since the flag has been cleared, the kernel 
cannot 
>> determine that the packet has been looped back, and will hence try to 
forward 
>> it again.
>> 
>> Trying to forward a looped back packet determines a wrong behaviour of the 
>> multicast routing protocol (PIM): the kernel believes that a multicast 
message 
>> has been received from a wrong interface (line 1993 in ip6mr.c), discard 
the 
>> message (this explains why the packet does not loop forever) and triggers 
the 
>> transmission of an ASSERT message. Basically, the node ends up sending an 
>> ASSERT message because of a looped back packet. 
>> 
>> WDYT? Is my analysis correct? Which is the best way to fix this issue?
>
>I guess your analysis is correct, try to revert commit
>6b7fdc3ae18a0598a999156b62d55ea55220e00f ([IPV6]: Clean skb cb on IPv6
>input) ?
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
