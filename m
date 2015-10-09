From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH v4] net/bonding: send arp in interval if no active slave
Date: Fri, 09 Oct 2015 08:31:53 -0700
Message-ID: <11019.1444404713@famine>
References: <56094137.9030206@redhat.com> <1444161197-38442-1-git-send-email-jarod@redhat.com> <56150A1B.10405@cumulusnetworks.com> <56151E4A.2000503@redhat.com> <5617D0D3.90208@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	linux-kernel@vger.kernel.org,
	Uwe Koziolek <uwe.koziolek@redknee.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <5617D0D3.90208@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarod Wilson <jarod@redhat.com> wrote:

>Jarod Wilson wrote:
>...
>> As Andy already stated I'm not a fan of such workarounds either but it's
>> necessary sometimes so if this is going to be actually considered then a
>> few things need to be fixed. Please make this a proper bonding option
>> which can be changed at runtime and not only via a module parameter.
>
>Is there any particular userspace tool that would need some updating, or
>is adding the sysfs knobs sufficient here? I think I've got all the sysfs
>stuff thrown together now, but still need to test.

	Most (all?) bonding options should be configurable via iproute
(netlink) now.

>
>>> Now, I saw that you've only tested with 500 ms, can't this be fixed by
>>> using
>>> a different interval ? This seems like a very specific problem to have a
>>> whole new option for.
>>
>> ...I'll wait until we've heard confirmation from Uwe that intervals
>> other than 500ms don't fix things.
>
>Okay, so I believe the "only tested with 500ms" was in reference to
>testing with Uwe's initial patch. I do have supporting evidence in a
>bugzilla report that shows upwards of 5000ms still experience the problem
>here.

	I did set up some switches and attempt to reproduce this
yesterday; I daisy-chained three switches (two Cisco and an HP) together
and connected the bonded interfaces to the "end" switches.  I tried
various ARP targets (the switch, hosts on various points of the switch)
and varying arp_intervals and was unable to reproduce the problem.

	As I understand it, the working theory is something like this:

	- host with two bonded interfaces, A and B.  For active-backup
mode, the interfaces have been assigned the same MAC address.

	- switch has MAC for B in its forwarding table

	- bonding goes from down to up, and thinks all its slaves are
down, and starts the "curr_arp_slave" search for an active
arp_ip_target.  In this case, it starts with A, and sends an ARP from A.

	As an aside, I'm not 100% clear on what exactly is going on in
the "bonding goes from down to up" transition; this seems to be key in
reproducing the issue.

	- switch sees source mac coming from port A, starts to update
its forwarding table

	- meanwhile, switch forwards ARP request, and receives ARP
reply, which it forwards to port B.  Bonding drops this, as the slave is
inactive.

	- switch finishes updating forwarding table, MAC is now assigned
to port A.

	- bonding now tries sending on port B, and the cycle repeats.

	If this is what's taking place, then the arp_interval itself is
irrelevant, the race is between the switch table update and the
generation of the ARP reply.

	Also, presuming the above is what's going on, we could modify
the ARP "curr_arp_slave" logic a bit to resolve this without requiring
any magic knobs.

	For example, we could change the "drop on inactive" logic to
recognise the "curr_arp_slave" search and accept the unicast ARP reply,
and perhaps make that receiving slave the next curr_arp_slave
automatically.

	I also wonder if the fail_over_mac option would affect this
behavior, as it would cause the slaves to keep their MAC address for the
duration, so the switch would not see the MAC move from port to port.

	Another thought would be to have the curr_arp_slave cycle
through the slaves in random order, but that could create
non-deterministic results even when things are working correctly.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
