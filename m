From: Scot Doyle <lkml@scotdoyle.com>
Subject: Re: Kernel panic when using bridge
Date: Mon, 11 Apr 2011 18:48:00 -0500
Message-ID: <4DA39330.2030102@scotdoyle.com>
References: <4D9E62D9.5010400@scotdoyle.com>	<20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com> <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sebastian Nickel <Sebastian.Nickel@hetzner.de>,
	Pallai Roland <pallair@magex.hu>
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.scotdoyle.com ([74.207.249.244]:47617 "EHLO
	smtp.scotdoyle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab1DKXsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 19:48:01 -0400
In-Reply-To: <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2011 02:19 AM, Hiroaki SHIMODA wrote:
>
> It seems that the bug trap is occurred in ip_options_compile() due to
> rt is NULL.
>
> 	8b 96 cc 00 00 00       mov    0xcc(%rsi),%edx
> rsi is rt, and 0xcc means rt->rt_spec_dst. So I think below code hit
> the bug trap.
>
> 332	if (skb) {
> 333		memcpy(&optptr[optptr[2]-1],&rt->rt_spec_dst, 4);<- here
> 334		opt->is_changed = 1;
> 335	}
>
> And call trace seems as follows.
>    __netif_receive_skb()
>      ->  br_handle_frame()
>           ->  NF_HOOK()
>                ->  br_nf_pre_routing()
>                     ->  br_parse_ip_options()
>                          ->  ip_options_compile()
>
> br_parse_ip_options() was introduced at 462fb2a (bridge : Sanitize
> skb before it enters the IP stack) but ip_options_compile() or
> ip_options_rcv_srr() seems to be called with no rt info.

Thanks to a tip from Sebastian, I can now reproduce this panic by 
running "IP Stack Integrity Checker v0.07" from another machine on the 
same subnet with command "icmpsic -s x.y.z.a -d x.y.z.b" where "x.y.z.a" 
is IP address of the other machine and "x.y.z.b" is the IP address of 
the target. When I enable iptables logging on the target machine, no 
panic occurs. When I disable iptables logging (but otherwise leave the 
same iptables rules) a panic occurs within a few seconds.

Thanks Hiroaki for the analysis of the kernel panic output. I've 
confirmed that you are correct by placing a printk just before those two 
lines. In every panic, the printk was triggered on line 333 of 
net/ipv4/ip_options.c

The kernel panic does not occur after applying the following patch.

# diff net/ipv4/ip_options.c.original net/ipv4/ip_options.c.fix
332c332
<                 if (skb) {
---
 >                 if (skb && rt) {
374c374
<                     if (skb) {
---
 >                     if (skb && rt) {

What do you all think? Will it cause other problems?
