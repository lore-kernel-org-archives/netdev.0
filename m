From: Ion Badulescu <ionut@badula.org>
Subject: weird bug with 2.6.28.9/10 tg3 and bcm5722 nic's
Date: Tue, 9 Jun 2009 10:29:21 -0400 (EDT)
Message-ID: <alpine.LRH.2.00.0906090954060.6437@ionlinux.tower-research.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.limegroup.com ([64.48.93.2]:51236 "EHLO ns1.limegroup.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758868AbZFIOic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 10:38:32 -0400
Received: from lithium-b.limegroup.com (lithium-b.limegroup.com [10.1.1.13])
	by ns1.limegroup.com (8.13.1/8.13.1) with ESMTP id n59ETSiG029676
	for <netdev@vger.kernel.org>; Tue, 9 Jun 2009 10:29:28 -0400
Received: from ionlinux.tower-research.com (ionlinux.tower-research.com [10.0.20.21])
	by lithium-b.limegroup.com (8.13.1/8.13.1) with ESMTP id n59ETNn5022051
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 9 Jun 2009 10:29:26 -0400
Received: from ionlinux.tower-research.com (localhost.localdomain [127.0.0.1])
	by ionlinux.tower-research.com (8.13.1/8.13.1) with ESMTP id n59ETNKV020602
	for <netdev@vger.kernel.org>; Tue, 9 Jun 2009 10:29:23 -0400
Received: from localhost (ion@localhost)
	by ionlinux.tower-research.com (8.13.1/8.13.1/Submit) with ESMTP id n59ETLIJ020597
	for <netdev@vger.kernel.org>; Tue, 9 Jun 2009 10:29:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm hitting the weirdest bug with 2.6.28.9/10 and bcm5722 interfaces on 
a bunch of servers we use here. The interfaces are normally stable and 
working well. However, if hald gets restarted, the interfaces stop 
receiving packets in a matter of seconds, and require a down/up to get 
them back to working.

When this happens, the rx_discard interface stat gets incremented, and I'm 
pretty sure interrupts stop occurring for the interface, at least for rx.

A little background:

-- we're running a RHEL4 distribution with the minimal changes required to 
use newer kernels
-- hal version is 0.4.7 (from FC3 with a a couple of fixes to prevent it 
from segfaulting on newer kernels)
-- the problem does not occur when running kernel 2.6.23.16
-- the problem occurs very predictably when running kernel 2.6.28.10 on 
the affected hardware
-- the affected hardware are the on-board interfaces on Dell R300 servers 
and HP ProLiant DL160 G5p servers:

Dell R300# ethtool -i eth1
driver: tg3
version: 3.94
firmware-version: 5722-v3.08, ASFIPMI v6.02
bus-info: 0000:02:00.0

Dell R300# cat /proc/interrupts | grep eth1
758:     953465      39500      41436      41224   PCI-MSI-edge      eth1


HP DL160# ethtool -i eth1
driver: tg3
version: 3.94
firmware-version: 5722-v3.07, ASFIPMI v6.02
bus-info: 0000:04:00.0

Dell R300# cat /proc/interrupts | grep eth1
760:       2133         19         16  430865463         15         15         14         14   PCI-MSI-edge      eth1


-- other hardware using the tg3 driver that's not affected includes 5721 
and 5751 interfaces, some of them on-board Dell R200 and PE-860 servers, 
others on add-on NIC's:

Dell PE-860# ethtool -i eth1
driver: tg3
version: 3.94
firmware-version: 5721-v3.61, ASFIPMI v6.21

Dell PE-860# cat /proc/interrupts | grep eth1
  17:    1416666          0   IO-APIC-fasteoi   eth1


Add-on NIC# ethtool -i eth2
driver: tg3
version: 3.94
firmware-version: 5751-v3.29a

Add-on NIC# cat /proc/interrupts | grep eth2
  16:       1592         20         21 2050734806   IO-APIC-fasteoi   eth2


Perhaps the other common ground here is that all affected interfaces use 
MSI interrupts, whereas all the not-affected interfaces use APIC 
interrupts, as seen above? But 2.6.23.16 uses the same kind of interrupts 
and doesn't have this problem...

As far as I can tell from a strace of 'service haldaemon restart', all 
hald is doing is reading from a bunch of files from /sys. However, I tried 
replicating those actions externally and the problem did not occur, so 
maybe something else is going on there.

Anyway, I'm stumped. Any help or insight would be appreciated...

Thanks,
-Ion
