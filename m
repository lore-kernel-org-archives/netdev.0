From: Ben Greear <greearb@candelatech.com>
Subject: ixgbe funkiness after OOM
Date: Tue, 08 Dec 2009 16:12:54 -0800
Message-ID: <4B1EEB86.4030903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56827 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965731AbZLIAMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 19:12:48 -0500
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id nB90CsOP021755
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 8 Dec 2009 16:12:55 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel: 2.6.31.7, plus hacks
Fedora 11, 64-bit
ixgbe NIC is 82699 chipset, 5GT/s 8-lane pcie, not manufactured by Intel.
CPU:  Intel(R) Core(TM) i7 CPU         965  @ 3.20GHz

I've been running some tests with 10k tcp connections (to self), over
a 2-port ixgbe NIC.  First..I managed to OOM my 12GB system..perhaps because
I have tcp memory settings too high or something (though I was not actually
setting the tcp rcv/tx buffers for the sockets.)  ixgbe was unable to do
order 0 allocations.

When this happened, the ixgbe NICs got into a state where they could not
tx any packets:  tshark showed ARPs going out on eth2, but the tx pkt counters
for that NIC did not increase and the peer (eth3, other port on this NIC),
did not show any rx pkts.

I tried doing ifdown/ifup, but that didn't have much affect (eth3 bumped it's tx counter by 1).

I then tried to rmmod the NIC and re-load the driver.  This time, it really looks unhappy:


Dec  8 15:27:57 localhost kernel: ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 2.0.34-k2
Dec  8 15:27:57 localhost kernel: ixgbe: Copyright (c) 1999-2009 Intel Corporation.
Dec  8 15:27:57 localhost kernel: ixgbe 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Dec  8 15:27:57 localhost kernel: ixgbe 0000:03:00.0: HW Init failed: -12
Dec  8 15:27:57 localhost kernel: ixgbe 0000:03:00.0: PCI INT A disabled
Dec  8 15:27:57 localhost kernel: ixgbe: probe of 0000:03:00.0 failed with error -12
Dec  8 15:27:57 localhost kernel: ixgbe 0000:03:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
Dec  8 15:27:57 localhost kernel: ixgbe: 0000:03:00.1: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
Dec  8 15:27:57 localhost kernel: ixgbe 0000:03:00.1: (PCI Express:5.0Gb/s:Width x4) 00:0c:bd:00:90:19
Dec  8 15:27:57 localhost kernel: ixgbe 0000:03:00.1: MAC: 2, PHY: 9, SFP+: 5, PBA No: ffffff-0ff
Dec  8 15:27:57 localhost kernel: ixgbe 0000:03:00.1: PCI-Express bandwidth available for this card is not sufficient for optimal performance.
Dec  8 15:27:57 localhost kernel: ixgbe 0000:03:00.1: For optimal performance a x8 PCI-Express slot is required.
Dec  8 15:27:57 localhost kernel: ixgbe 0000:03:00.1: Intel(R) 10 Gigabit Network Connection


At this point, there is 8GB of free RAM, and no obvious OOM issues showing up in the logs.

It looks like error -12 means:

IXGBE_ERR_MASTER_REQUESTS_PENDING


I tried rmmod/modprobe several more times...each time I get the same error for
that device.  The one that fails is eth2, the same that could not tx earlier.

Everything came up fine on reboot.

Anyway, this is mostly just for information in case someone else is hitting similar
issues.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

