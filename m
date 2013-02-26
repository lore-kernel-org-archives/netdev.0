From: Benjamin Poirier <bpoirier@suse.de>
Subject: qeth_l2 duplicated frames in promiscuous mode
Date: Tue, 26 Feb 2013 16:08:37 -0500
Message-ID: <20130226210837.GB18118@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Post <mpost@suse.com>, linux390@de.ibm.com,
	linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: Ursula Braun <ursula.braun@de.ibm.com>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33545 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555Ab3BZVIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 16:08:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

While working with the qeth/qeth_l2 drivers I've noticed that once the
nic enters promiscuous mode, every received frame is duplicated. This
appears to happen at the (virtual) hardware level since the "RX Packets"
counter printed by `#cp q nic [...] det` shows this duplicated count. It
also happens when setting promiscuous mode using `#cp set nic [...]
pro`.

It can be witnessed in tcpdump output or simply by pinging the machine
from another host. As soon as promiscuous mode is enabled using the cp
command above, the machine receives the echo request in duplicate and
answers them accordingly:
64 bytes from 10.121.155.133: icmp_seq=61 ttl=64 time=0.314 ms
64 bytes from 10.121.155.133: icmp_seq=62 ttl=64 time=0.308 ms
# enable promiscuous mode on 10.121.155.133 now
64 bytes from 10.121.155.133: icmp_seq=63 ttl=64 time=0.301 ms
64 bytes from 10.121.155.133: icmp_seq=63 ttl=64 time=0.326 ms (DUP!)
64 bytes from 10.121.155.133: icmp_seq=64 ttl=64 time=0.309 ms
64 bytes from 10.121.155.133: icmp_seq=64 ttl=64 time=0.330 ms (DUP!)

This duplication happens for multicast and unicast frames, whether those
are directed to an address in the uc filter list or not.

Tested on v3.8.

Is this a known issue?

Here is the nic info, let me know if you need anything else, I'm not
familiar with s390.

CP Q NIC 0800 DET
Adapter 0800.P00 Type: QDIO      Name: UNASSIGNED  Devices: 3
  MAC: 02-00-00-00-00-07         VSWITCH: SYSTEM VSWNL2
      RX Packets: 3005625    Discarded: 1318       Errors: 0
      TX Packets: 287690     Discarded: 0          Errors: 0
      RX Bytes: 3777624734           TX Bytes: 32040428
  Connection Name: HALLOLE   State: Session Established
      Device: 0800  Unit: 000   Role: CTL-READ
      Device: 0801  Unit: 001   Role: CTL-WRITE
      Device: 0802  Unit: 002   Role: DATA       vPort: 0264  Index: 0264
      VLAN: 0556
      Options: Ethernet Broadcast Promiscuous
        Unicast MAC Addresses:
          02-00-00-00-00-07
        Multicast MAC Addresses:
          01-00-5E-00-00-01
          33-33-00-00-00-01
          33-33-00-00-02-02
          33-33-FF-00-00-07

Thank you,
-Benjamin
