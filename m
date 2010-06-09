From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Packet capture and Bonding asymmetries
Date: Wed, 09 Jun 2010 15:52:31 -0700
Message-ID: <17501.1276123951@death.nxdomain.ibm.com>
References: <20100609212704.GY11110@cel.leo>
Cc: netdev@vger.kernel.org
To: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:54264 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755566Ab0FIWwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 18:52:36 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o59Mp2bW030202
	for <netdev@vger.kernel.org>; Wed, 9 Jun 2010 18:51:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o59MqX6h1765414
	for <netdev@vger.kernel.org>; Wed, 9 Jun 2010 18:52:35 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o59MqXkb024871
	for <netdev@vger.kernel.org>; Wed, 9 Jun 2010 19:52:33 -0300
In-reply-to: <20100609212704.GY11110@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul LeoNerd Evans <leonerd@leonerd.org.uk> wrote:

>We use ethernet bonding to bond eth0 + eth1 into bond0, in an
>active/standby failover pair. Given this is for redundancy, we put the
>two physical ethernet links into different switches that follow
>different paths in the data centre.
>
>Given this topology, it can be really useful to know which physical
>interface packets are received on. It seems the bonding driver doesn't
>make this happen:
>
>  # uname -r
>  2.6.31.12
>
>  # head -1 /proc/net/bonding/bond0 
>  Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
>
>  # pktdump -f icmp
>  [15:27:12] RX(bond0): ICMP| 192.168.57.6->192.168.57.1 echo-request seq=1
>  [15:27:12] TX(bond0): ICMP| 192.168.57.1->192.168.57.6 echo-reply seq=1
>  [15:27:12] TX(eth0): ICMP| 192.168.57.1->192.168.57.6 echo-reply seq=1
>
>I.e. when we transmit we see both the virtual bond0 interface and the
>physical eth0 doing so; but when we receive only the virtual bond0
>appears to do so.
>
>I believe this should be fixable with a one-line patch; just adding a
>call to netif_nit_deliver(skb) from within the bonding driver... though
>just offhand I'm unable to find exactly the line where packets received
>on slaves gets passed up to the master. :)

	This won't work, because bonding does not have a receive
function in the usual sense.  Instead, the slaves do their normal
receive logic, and then in __netif_receive_skb, packets are assigned to
the bonding master if the device is a slave.

	On the TX side, packet capture can happen at both the bonding
device and at the slave, because the packet will pass through both.

>Can anyone advise on the sensibility or otherwise of this plan? I really
>would like the behaviour where I can see how packets are received - is
>this a good plan to acheive it?

	For your own private testing, you could add a call to
__netif_nit_deliver in netif_receive_skb prior to this part:

        master = ACCESS_ONCE(orig_dev->master);
        if (master) {
                if (skb_bond_should_drop(skb, master))
                        null_or_orig = orig_dev; /* deliver only exact match */
                else
                        skb->dev = master;
        }

	This will give you multiple captures of the same packet, as is
seen for transmit (i.e., one on the slave, one on the bond).  For
non-bonding devices, tcpdump will see each packet twice on the same
device, so it's not really suitable for general use.

>I may sometime have a hack at writing a patch for this anyway, presuming
>no major objections...

	If merely knowing the traffic counts is sufficient, the slaves
do count their received packets individually, so, e.g., ifconfig will
show how many packets a particular slave has received, regardless of
what bonding does with them.  The packet counts for the bonding device
itself are merely a sum of all of its slaves.

	Also, generally speaking, IP protocol traffic that arrives on an
inactive bonding slave is not delivered.  If you're using active-backup
mode, and your traffic makes it through, it likely arrived on the active
slave.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
