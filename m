From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [PATCH net-next] ax25: Stop using magic neighbour cache operations.
Date: Sat, 14 Mar 2015 00:33:00 +0000
Message-ID: <550381BC.7040001@redhat.com>
References: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org>	<20150302.164426.494515497595921630.davem@davemloft.net>	<874mq22imc.fsf_-_@x220.int.ebiederm.org>	<20150303.144509.1694022322984204895.davem@davemloft.net>	<87mw3tzv8u.fsf@x220.int.ebiederm.org> <54F82C9F.5050307@redhat.com> <87twxx7t5y.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ralf@linux-mips.org, linux-hams@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbbCNAdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 20:33:10 -0400
In-Reply-To: <87twxx7t5y.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 06/03/15 20:44, Eric W. Biederman wrote:
> Steven Whitehouse <swhiteho@redhat.com> writes:
>
>> Hi,
>
>>> We can almost universally use the same procedures for generating
>>> link layer headers from neighbour table entries now.  I had hoped
>>> to optimized things by removing function pointers.
>>>
>>> The big hold out is DECnet that sets src_mac based on the DECnet source
>>> address.
>> That is a requirement of DECnet I'm afraid - DECnet does not have an exact
>> equivalent of ARP/ndisc and many hosts will refuse to communicate if the MAC
>> address is not the expected one based on the DECnet address. This is one bit of
>> DECnet that is being used (to the best of my knowledge) and working.
> Having a mac address that matches the DECnet address completely makes
> sense.  Sourcing packets with a different mac address than the devices
> default mac address make sense.  This latter case doesn't usually happen
> for IP packets but we force it with the macvlan driver for example.
The history is that when DECnet was being written, it was not generally 
reliable to have a different MAC to that of the ethernet card - it 
worked for some cards, but by no means all of them. So it is something 
that would be done slightly differently with modern cards.

>>> Which leads me to the conclusion that since DECnet has a different
>>> algorithm for setting the src_mac than everything else in the kernel
>>> DECnet neighbour table entries can not be used for nexthops for other
>>> protocols :(
>>>
>>> DECnet also abuses neigh->output to select by output device which kind
>>> of DECnet header to put on the packets.  But that is easily fixable.
>> One way to fix it would be to drop support for non-broadcast devices. We don't
>> have an implementation of DDCMP currently. Ethernet is the only working DECnet
>> device at the moment. PPP could also potentially work, with a bit of tweeking,
>> but strangely PPP is a broadcast device so far as DECnet is concerned,
> What I wound up doing was just doing a shuffle of which function was in
> the neigh->output method.  Which meant there was no need to disable any
> of the current code.
>
> That should fix interactions between DECnet and drivers like sch_teql
> and the netfilter bridge code which after a packet has already been
> output turn around and do:
>
> 	dst = skb_dst(skb);
> 	neigh = n = dst_neigh_lookup_skb(dst, skb);
>          if (dst->dev != dev)
>          	neigh = __neigh_lookup_errno(n->tbl, n->primary_key, dev);
> 	neigh->output(neigh, skb);
>
> Which I think if the DECnet code hit one of those code paths today would
> result in double DECnet headers.  :(
>
> When looking at the DECnet code there is a flag that enables phase3
> support but I don't seeing it set anywhere.  Should DECnet phase3
> support actually work?
>
> Eric

Ok. That sounds reasonable to me. The phase 3 stuff is another stub 
really... most of what is needed is there, but not all of it. Phase 3 is 
basically the same as Phase IV but without areas and broadcast devices, 
so in order to make Phase 3 devices reachable on a Phase IV network, the 
Phase IV router has to add an area and forward the packet on, and remove 
the area when sending to the Phase 3 node. However since we don't have 
non-broadcast DECnet devices, there is no point in having Phase3 support 
really. At least it is one area on which the spec is quite useful 
though, as this is fairly well described,

Steve.
