From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] skb_free_datagram() doing something expensive ?
Date: Wed, 05 Nov 2008 00:02:22 +0100
Message-ID: <4910D47E.4030004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:57385 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbYKDXCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 18:02:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

I noticed high contention on udp_memory_allocated on a typical VOIP application.

(Now that oprofile correctly runs on my machine :) )

I can see that skb_free_datagram() is :

void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
{
        kfree_skb(skb);
        sk_mem_reclaim(sk);
}

So each time an UDP packet is received, we must touch udp_memory_allocated

Each time application reads a packet, we call sk_mem_reclaim() and touch again udp_memory_allocated.

Surely this cannot be correct ?

If this is correct, time is to resurrect a patch to make proto->memory_allocated a percpu_counter
or something to have a percpu reserve of say 64 or 128 pages to avoid cache line trashing...

tcp_memory_allocated do not have this problem, since tcp carefully calls sk_mem_reclaim(sk) only on
selected paths, not on fast path.

Thanks

