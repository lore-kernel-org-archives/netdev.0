From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Slow OOM in netif_RX function
Date: Fri, 25 Jan 2008 14:21:08 +0100
Message-ID: <p73tzl282ij.fsf@bingen.suse.de>
References: <4798CAA9.1080005@obs.bg> <4798E32E.6080003@cosmosbay.com>
	<20080124211810.3E24A46E9A@smtp.obs.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Ivan H. Dichev" <idichev@obs.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:40706 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237AbYAYNVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 08:21:12 -0500
In-Reply-To: <20080124211810.3E24A46E9A@smtp.obs.bg> (Ivan H. Dichev's message of "Thu\, 24 Jan 2008 23\:18\:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Ivan H. Dichev" <idichev@obs.bg> writes:
>
> What could happen if I put different Lan card in every slot?
> In ex. to-private -> 3com
>       to-inet    -> VIA
>       to-dmz     -> rtl8139
> And then to look which RX function is consuming the memory.
> (boomerang_rx, rtl8139_rx, ... etc) 

The problem is unlikely to be in the driver (these are both
well tested ones) but more likely your complicated iptables setup somehow
triggers a skb leak.

There are unfortunately no shrink wrapped debug mechanisms in the kernel
for leaks like this (ok you could enable CONFIG_NETFILTER_DEBUG 
and see if it prints something interesting, but that's a long shot).

If you wanted to write a custom debugging patch I would do something like this:

- Add two new integer fields to struct sk_buff: a time stamp and a integer field
- Fill the time stamp with jiffies in alloc_skb and clear the integer field
- In __kfree_skb clear the time stamp
- For all the ipt target modules in net/ipv4/netfilter/*.c you use change their 
->target functions to put an unique value into the integer field you added.
- Do the same for the pkt_to_tuple functions for all conntrack modules

Then when you observe the leak take a crash dump using kdump on the router 
and then use crash to dump all the slab objects for the sk_head_cache.
Then look for any that have an old time stamp and check what value they
have in the integer field. Then the netfilter function who set that unique value 
likely triggered the leak somehow.

-Andi
