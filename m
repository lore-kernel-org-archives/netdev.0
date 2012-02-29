From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH][RFC] bonding: delete migrated IP addresses from the rlb
 hash table
Date: Wed, 29 Feb 2012 19:49:27 +0100
Message-ID: <20120229184927.GB14467@midget.suse.cz>
References: <20120227173400.GB816@midget.suse.cz>
 <4F4E2F1D.2080302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: WeipingPan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40826 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030449Ab2B2St3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 13:49:29 -0500
Content-Disposition: inline
In-Reply-To: <4F4E2F1D.2080302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 29, 2012 at 09:58:53PM +0800, WeipingPan wrote:
> On 02/28/2012 01:34 AM, Jiri Bohac wrote:
> >Bonding in balance-alb mode records information from ARP packets
> >passing through the bond in a hash table (rx_hashtbl).
> >
> >At certain situations (e.g. link change of a slave),
> >rlb_update_rx_clients() will send out ARP packets to update ARP
> >caches of other hosts on the network to achieve RX load balancing.
> >
> >The problem is that once an IP address is recorded in the hash
> >table, it stays there indefinitely [1]. If this IP address is
> >migrated to a different host in the network, bonding still sends
> >out ARP packets that poison other systems' ARP caches with
> >invalid information.
> I met this problem, too.
> 
> >This patch solves this by looking at all incoming ARP packets,
> >and checking if the source IP address is one of the source
> >addresses stored in the rx_hashtbl. If it is, the corresponding
> >hash table entries are removed. Thus, when an IP address is
> >migrated, the first ARP broadcast by its new owner will purge the
> >offending entries of rx_hashtbl.
> >
> >   (a simpler approach, where bonding would monitor IP address
> >    changes on the local system does not work for setups like:
> >    HostA --- NetworkA --- eth0-bond0-br0 --- NetworkB --- hostB
> >    and an IP address migrating from HostB to HostA)
> Could you explain in detail or step by step how to reproduce your problem ?
> I made a patch but I do not know whether it can fix your problem.

> >    HostA --- NetworkA --- eth0-bond0-br0 --- NetworkB --- hostB


the simplest setup is something like:

                       ---- HostC ------
HostA ----- switch ---|-- eth0 - bond0  |
HostB -----/       \--|-- eth1 -/       |
                       -----------------

HostA has IP address A, HostB has IP address B, HostC has IP
address C).

Set link of eth1 down.

Ping from C to A. This will create the rlb hash table entry with 
ip_src = C and ip_dst = A and tx_slave = eth0.

Delete IP address C from bond0.
Assign IP address C to HostB

Set link of eth1 up.
Set link of eth0 down.


This should cause the hash table to be walked and all clients
(HostA included) "updated" win a unicast ARP REPLY sent by
rlb_update_client(). The reply will claim that IP address C has
the MAC address of eth1.

If at this point HostA communicated with HostB using IP address
C, communication will be broken, because the ARP cache of Host A
will be poisoned.

My patch would delete the bad hash table entry when 
it sees an ARP packet from Host B from IP address C.

Now, this packet is not guaranteed to be broadcast
(imagine HostA sending a broadcast ARP request for IP address C
and HostB replying with an unicast ARP reply.)
But setups that migrate IP addresses from host to hosts often use
gratuitous ARPs to update ARP caches after the IP address
migration and that would make sure the hash table entry is
deleted.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
