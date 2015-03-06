From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] ax25: Stop using magic neighbour cache operations.
Date: Fri, 06 Mar 2015 14:44:09 -0600
Message-ID: <87twxx7t5y.fsf@x220.int.ebiederm.org>
References: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
	<20150302.164426.494515497595921630.davem@davemloft.net>
	<874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org> <54F82C9F.5050307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ralf@linux-mips.org, linux-hams@vger.kernel.org
To: Steven Whitehouse <swhiteho@redhat.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <54F82C9F.5050307@redhat.com> (Steven Whitehouse's message of
	"Thu, 05 Mar 2015 10:14:55 +0000")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steven Whitehouse <swhiteho@redhat.com> writes:

> Hi,


>> We can almost universally use the same procedures for generating
>> link layer headers from neighbour table entries now.  I had hoped
>> to optimized things by removing function pointers.
>>
>> The big hold out is DECnet that sets src_mac based on the DECnet source
>> address.
> That is a requirement of DECnet I'm afraid - DECnet does not have an exact
> equivalent of ARP/ndisc and many hosts will refuse to communicate if the MAC
> address is not the expected one based on the DECnet address. This is one bit of
> DECnet that is being used (to the best of my knowledge) and working.

Having a mac address that matches the DECnet address completely makes
sense.  Sourcing packets with a different mac address than the devices
default mac address make sense.  This latter case doesn't usually happen
for IP packets but we force it with the macvlan driver for example.

>> Which leads me to the conclusion that since DECnet has a different
>> algorithm for setting the src_mac than everything else in the kernel
>> DECnet neighbour table entries can not be used for nexthops for other
>> protocols :(
>>
>> DECnet also abuses neigh->output to select by output device which kind
>> of DECnet header to put on the packets.  But that is easily fixable.
> One way to fix it would be to drop support for non-broadcast devices. We don't
> have an implementation of DDCMP currently. Ethernet is the only working DECnet
> device at the moment. PPP could also potentially work, with a bit of tweeking,
> but strangely PPP is a broadcast device so far as DECnet is concerned,

What I wound up doing was just doing a shuffle of which function was in
the neigh->output method.  Which meant there was no need to disable any
of the current code.

That should fix interactions between DECnet and drivers like sch_teql
and the netfilter bridge code which after a packet has already been
output turn around and do:

	dst = skb_dst(skb);
	neigh = n = dst_neigh_lookup_skb(dst, skb);
        if (dst->dev != dev)
        	neigh = __neigh_lookup_errno(n->tbl, n->primary_key, dev);
	neigh->output(neigh, skb);

Which I think if the DECnet code hit one of those code paths today would
result in double DECnet headers.  :(

When looking at the DECnet code there is a flag that enables phase3
support but I don't seeing it set anywhere.  Should DECnet phase3
support actually work?

Eric
