From: David Christensen <davidch@broadcom.com>
Subject: Switchdev Application to SR-IOV NICs
Date: Wed, 4 Mar 2015 00:26:22 +0000
Message-ID: <3A5015FE9E557D448AF7238AF0ACE20A2D8ACC6F@IRVEXCHMB11.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: =?iso-8859-2?B?Smn47SBQ7XJrbyAoamlyaUByZXNudWxsaS51cyk=?=
	<jiri@resnulli.us>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:60599 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757587AbbCDA0Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 19:26:25 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm struggling with the concept of implementing switchdev on an SR-IOV NIC.
Most slides presented at Netdev 0.1 agreed that switchdev should be applicable
to SR-IOV NICs as well as switch ASICs, but I'm having difficulty figuring
out exactly how things should operate.  Here's how things look today with
netdev and SR-IOV VFs passed-through to a virtual machine.

      +-----+-----+-----+
      | vm0 | vm1 | vm2 | Virtual
      | eth0| eth0| eth0| Machines
+-----+--|--+--|--+--|--+----------
|eth0 |  |     |     |    Kernel
+--|--+--|-----|-----|--+----------
| pf0   vf0   vf1   vf2 | PCIe
+--|-----|-----|-----|--+----------
| ++-----+-----+-----++ | SR-IOV NIC
| | VEB               | |
| +------------+------+ |
+--------------|--------+
               |
              PHY

Connectivity between VMs and the host is handled by the VEB operating in the
NIC, other traffic is forwarded normally by the VEB from the external network
to the host/VM based on destination MAC and VLAN with special handling 
required for broadcast/multicast.  

Based on some separate conversations I've had with Jiri, I'm lead to believe
switchdev would look something like this.

      +-----+-----+-----+
      | vm0 | vm1 | vm2 | Virtual
      | eth0| eth0| eth0| Machines
+-----+--|--+--|--+--|--+----------
|sw0p0 sw0p1 sw0p2 sw0p3| Kernel
+--|-----|-----|-----|--+----------
| pf0   vf0   vf1   vf2 | PCIe
+--|-----|-----|-----|--+----------
| ++-----+-----+-----++ | SR-IOV NIC
| | VEB               | |
| +------------+------+ |
| SR-IOV NIC   |        |
+--------------|--------+
               |
              PHY

The use of switchdev would show that all sw0* devices are associated with the
same switch, and the instantiation of the sw0* devices in the kernel would
provide higher level applications like OVS/Linux bridge/etc. to control traffic
in a way not possible in the earlier example.  So far so good?

Now the question becomes how to plumb SR-IOV NIC to create this representation.
Looking at one specific path:

  +-----+
  | vm0 |
  | eth0|
  +--|--+
  |sw0p1|
  +--|--+
  | vf0 |
+----|----+
| +--+--+ |
| | VEB | |
| +-----+ |
+---------+

It's unclear to me when traffic egressing the VEB should terminate at sw0p1 vs.
vm0's eth0.  They both represent the same MAC/VLAN.  Similarly, for traffic 
egressing vm0's eth0, when should it terminate at sw0p1 vs. the VEB.

Can anyone offer an alternate diagram for switchdev on an SR-IOV NIC?

Dave
