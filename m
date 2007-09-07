From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Fri, 07 Sep 2007 16:41:00 -0400
Message-ID: <46E1B75C.6090208@roinet.com>
References: <20070831205430.7209E46C20E@localhost> <46E17CD7.8080605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Milton Miller <miltonm@bga.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Scott Feldman <sfeldma@pobox.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:33414
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758376AbXIGUka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 16:40:30 -0400
In-Reply-To: <46E17CD7.8080605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> first impressions are not good: pings are erratic and shoot up to 3 
> seconds. In an overnight stress test, the receive unit went offline and 
> never came back up (TX still working).
> 
> it sounds like something in the logic is suspending the ru too much, but 
> I haven't had time to look deeply into the code yet.

I don't have an e100 enabled x86 box handy but I will look into getting one setup.

I just applied this patch to my PXA255 based system http://www.compulab.co.il/x255/html/x255-cm-datasheet.htm .
It is running 2.6.18.4 plus compulab patches plus some hostap patches plus the e100 patch.  I get:

pings going from the embedded system to a desktop machine.
100 packets transmitted, 100 received, 0% packet loss, time 98996ms
rtt min/avg/max/mdev = 0.239/0.728/1.512/0.571 ms

Pings going the from the desktop machine to the embedded system
100 packets transmitted, 100 received, 0% packet loss, time 99217ms
rtt min/avg/max/mdev = 0.206/0.876/1.473/0.575 ms


iperf tcp from embedded to desktop gets:
[  5]  0.0-100.0 sec  1007 MBytes  84.4 Mbits/sec
iperf udp from the embedded to the desktop gets (embedded told to send at 100mbps):
[  5] Server Report:
[  5]  0.0-100.0 sec    947 MBytes  79.4 Mbits/sec  0.068 ms   16/675645 (0.0024%)
[  5]  0.0-100.0 sec  1 datagrams received out-of-order

iperf tcp from the desktop to the embedded gets:
[  6]  0.0-100.0 sec  1.01 GBytes  86.4 Mbits/sec
iperf udp from the desktop to the embedded gets the following when the desktop sent at 100 mbps
[  5]  0.0-100.0 sec    964 MBytes  80.8 Mbits/sec  0.359 ms 126467/813760 (16%)
[  5]  0.0-100.0 sec  1 datagrams received out-of-order


Boot messages for my e100 are:
e100: Intel(R) PRO/100 Network Driver, 3.5.10-k2-NAPI
e100: Copyright(c) 1999-2005 Intel Corporation
PCI: enabling device 0000:00:09.0 (0000 -> 0003)
PCI: Setting latency timer of device 0000:00:09.0 to 64
e100: eth0: e100_probe: addr 0x10131000, irq 111, MAC addr 00:09:30:FF:F2:F6
cat /sys/bus/pci/drivers/e100/0000\:00\:09.0/{device,vendor,subsystem_device,subsystem_vendor}
0x1209
0x8086
0x0000
0x0000

It's on its own interrupt line:
cm-debian:~# cat /proc/interrupts |grep eth0
111:     402428           -  eth0

lspci shows:
00:09.0 Ethernet controller: Intel Corporation 8255xER/82551IT Fast Ethernet Controller (rev 09)

Let me know if there is any other information I can provide you.  I will look through the code to see what could be 
going on with your machine.  I will also look into reproducing these results with a newer kernel.  This may be tricky 
since compulab's patches are pretty stale and don't always apply easily.

-Ack
