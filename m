From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Slow OOM in netif_RX function
Date: Fri, 1 Feb 2008 15:29:46 +0100
Message-ID: <20080201142946.GA16630@one.firstfloor.org>
References: <4798CAA9.1080005@obs.bg> <4798E32E.6080003@cosmosbay.com> <20080124211810.3E24A46E9A@smtp.obs.bg> <p73tzl282ij.fsf@bingen.suse.de> <20080125141204.GA25510@ghostprotocols.net> <47A315DC.3070101@obs.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Ivan Dichev <idichev@obs.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33704 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbYBANzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 08:55:18 -0500
Content-Disposition: inline
In-Reply-To: <47A315DC.3070101@obs.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2008 at 02:51:40PM +0200, Ivan Dichev wrote:
> Arnaldo Carvalho de Melo wrote:
> > Em Fri, Jan 25, 2008 at 02:21:08PM +0100, Andi Kleen escreveu:
> >   
> >> "Ivan H. Dichev" <idichev@obs.bg> writes:
> >>     
> >>> What could happen if I put different Lan card in every slot?
> >>> In ex. to-private -> 3com
> >>>       to-inet    -> VIA
> >>>       to-dmz     -> rtl8139
> >>> And then to look which RX function is consuming the memory.
> >>> (boomerang_rx, rtl8139_rx, ... etc) 
> >>>       
> >> The problem is unlikely to be in the driver (these are both
> >> well tested ones) but more likely your complicated iptables setup somehow
> >> triggers a skb leak.
> >>
> >> There are unfortunately no shrink wrapped debug mechanisms in the kernel
> >> for leaks like this (ok you could enable CONFIG_NETFILTER_DEBUG 
> >> and see if it prints something interesting, but that's a long shot).
> >>
> >> If you wanted to write a custom debugging patch I would do something like this:
> >>
> >> - Add two new integer fields to struct sk_buff: a time stamp and a integer field
> >> - Fill the time stamp with jiffies in alloc_skb and clear the integer field
> >> - In __kfree_skb clear the time stamp
> >> - For all the ipt target modules in net/ipv4/netfilter/*.c you use change their 
> >> ->target functions to put an unique value into the integer field you added.
> >> - Do the same for the pkt_to_tuple functions for all conntrack modules
> >>
> >> Then when you observe the leak take a crash dump using kdump on the router 
> >> and then use crash to dump all the slab objects for the sk_head_cache.
> >> Then look for any that have an old time stamp and check what value they
> >> have in the integer field. Then the netfilter function who set that unique value 
> >> likely triggered the leak somehow.
> >>     
> >
> > I wrote some systemtap scripts that do parts of what you suggest, and at
> > least for the timestamp there was no need to add a new field to struct
> > sk_buff, I just reuse skb->timestamp, as it is only used when we use a
> > packet sniffer. Here it is for reference, but it needs some tapsets I
> > wrote, so I'll publish this git repo in git.kernel.org, perhaps it can
> > be useful in this case as a starting point. Find another unused field
> > (hint: I know that at least 4 bytes on 64 bits is present as a hole) and
> > you're done, no need to rebuild the kernel :)
> >
> > http://git.kernel.org/?p=linux/kernel/git/acme/nettaps.git
> >
> > - Arnaldo
> >   
> Thanks to everyone for the given ideas.
> I am not kernel guru so writing patch is difficult. This is a production
> server and it is quite difficult to debug (only at night)
> I removed some iptables exotics -  recent , ulog, string , but no effect.
> Since we can reach OOM most of the memory is going to be filled with the
> leak, and we are thinking to try to dump and analyze it.

You could perhaps use crash to look for leaked packets and then 
see if you can see a pattern, as in what types of packets they are.

Still I expect without modifying the kernel to add some more
netfilter tracing it will be difficult to diagnose this.

I suppose it would be possible to write a suitable systemtap script
to also trace this without modifying the kernel, although it will be 
probably not easy and more complicated than just changing the C code.

-Andi
