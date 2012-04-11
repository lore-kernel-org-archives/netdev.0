From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] rtnetlink & bonding: change args got get_tx_queues
Date: Wed, 11 Apr 2012 11:13:35 -0700
Message-ID: <4576.1334168015@death.nxdomain>
References: <20120409132756.32daeaa6@nehalam.linuxnetplumber.net> <1334009344.7150.268.camel@deadeye> <20120410213443.31fc0784@nehalam.linuxnetplumber.net> <1334123747.5300.2197.camel@edumazet-glaptop> <20120411082054.2bf6a352@nehalam.linuxnetplumber.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:47751 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760820Ab2DKSOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 14:14:07 -0400
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 11 Apr 2012 14:14:04 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 279996E8057
	for <netdev@vger.kernel.org>; Wed, 11 Apr 2012 14:13:53 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3BIDqVX287900
	for <netdev@vger.kernel.org>; Wed, 11 Apr 2012 14:13:52 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3BIDlwe018330
	for <netdev@vger.kernel.org>; Wed, 11 Apr 2012 14:13:48 -0400
In-reply-to: <20120411082054.2bf6a352@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>On Wed, 11 Apr 2012 07:55:47 +0200
>Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> On Tue, 2012-04-10 at 21:34 -0700, Stephen Hemminger wrote:
>> > Change get_tx_queues, drop unsused arg/return value real_tx_queues,
>> > and use return by value (with error) rather than call by reference.
>> > 
>> > Probably bonding should just change to LLTX and the whole get_tx_queues
>> > API could disappear!
>> 
>> Absolutely ;)
>> 
>> 
>
>It is more complex than that (actually the bonding driver is a mess).
>The bonding device is already using Lockless Transmit and transmit queue length
>of zero (good), but it then does some queue mapping of it's own which
>is unnecessary.
>
>Multiqueue only makes sense if there is a queue, otherwise the skb
>can transparently pass through the layered device (vlan, bridge, bond)
>and get queued on the real physical device.
>
>Right now, trying to see if there is any impact by just leaving
>bond device as single queue.

	The multiqueue support in bonding is intended to permit
individual slaves to be assigned a particular queue id, which then
permits tc filter actions to steer traffic to particular slaves.

	The relevant part of Documentation/networking/bonding.txt:

The queue_id for a slave can be set using the command:

# echo "eth1:2" > /sys/class/net/bond0/bonding/queue_id

Any interface that needs a queue_id set should set it with multiple calls
like the one above until proper priorities are set for all interfaces.  On
distributions that allow configuration via initscripts, multiple 'queue_id'
arguments can be added to BONDING_OPTS to set all needed slave queues.

These queue id's can be used in conjunction with the tc utility to configure
a multiqueue qdisc and filters to bias certain traffic to transmit on certain
slave devices.  For instance, say we wanted, in the above configuration to
force all traffic bound to 192.168.1.100 to use eth1 in the bond as its output
device. The following commands would accomplish this:

# tc qdisc add dev bond0 handle 1 root multiq

# tc filter add dev bond0 protocol ip parent 1: prio 1 u32 match ip dst \
        192.168.1.100 action skbedit queue_mapping 2

These commands tell the kernel to attach a multiqueue queue discipline to the
bond0 interface and filter traffic enqueued to it, such that packets with a dst
ip of 192.168.1.100 have their output queue mapping value overwritten to 2.
This value is then passed into the driver, causing the normal output path
selection policy to be overridden, selecting instead qid 2, which maps to eth1.

Note that qid values begin at 1.  Qid 0 is reserved to initiate to the driver
that normal output policy selection should take place.  One benefit to simply
leaving the qid for a slave to 0 is the multiqueue awareness in the bonding
driver that is now present.  This awareness allows tc filters to be placed on
slave devices as well as bond devices and the bonding driver will simply act as
a pass-through for selecting output queues on the slave device rather than 
output port selection.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
