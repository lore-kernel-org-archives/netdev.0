From: Hans-Peter Jansen <hpj@urpla.net>
Subject: multicast problems in forcedeth driver with MCP51 Ethernet Controller
Date: Sun, 16 Mar 2008 23:56:49 +0100
Message-ID: <200803162356.49709.hpj@urpla.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_xWa3HYkBFqHO14e"
Cc: netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49549 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbYCPW45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2008 18:56:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_xWa3HYkBFqHO14e
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Ayaz, hi forcedeth hackers,

I'm trying to get my first multicast application to life ATM, but even the 
first tests failed mysteriously for some systems, running a 2.6.24.3 
kernel. Goggling around let me to one of your fixes: 
[PATCH 5/5] forcedeth: multicast fix, which Linus applied before 2.6.25-rc1 
as: bb9a4fd1f7cc083f72e52f01938c23ac5b3403d5

I applied your patch to my local 2.6.24.3 kernel build, but still no go.
Try attached python script (after setting up a route like this):

Destination     Gateway        Genmask         Flags Metric Ref   Use  Iface
229.0.0.0       *              255.0.0.0       U     0      0        0 eth0

Run one instance as './mctest.py server' and others without arguments. 
Normally, the server sends out a multicast packet every second, and the 
clients catch 10 of those before quitting, unless such a MCP51 Ethernet 
Controller is in the equation: that one doesn't send/receive a single MC 
bit here... Other nics (well, I tested this on e1000s and another MCP55) 
behave well in this respect.

If I make the MCP51 the server, tcpdump is able to fetch the packets, but 
nothing is received on the other systems. Looks, like multicasting is still 
broken for the NIC in question.

Here's the complete hwinfo for the affected NIC:
~# hwinfo --netcards
15: PCI 14.0: 0200 Ethernet controller                          
  [Created at pci.286]
  UDI: /org/freedesktop/Hal/devices/pci_10de_269
  Unique ID: MZfG.uQ5k42VxsiA
  SysFS ID: /devices/pci0000:00/0000:00:14.0
  SysFS BusID: 0000:00:14.0
  Hardware Class: network
  Model: "ASUSTeK MCP51 Ethernet Controller"
  Vendor: pci 0x10de "nVidia Corporation"
  Device: pci 0x0269 "MCP51 Ethernet Controller"
  SubVendor: pci 0x1043 "ASUSTeK Computer Inc."
  SubDevice: pci 0x816a 
  Revision: 0xa3
  Driver: "forcedeth"
  Driver Modules: "forcedeth"
  Memory Range: 0xfe02b000-0xfe02bfff (rw,non-prefetchable)
  I/O Ports: 0xc800-0xc807 (rw)
  IRQ: 18 (309189603 events)
  Module Alias: "pci:v000010DEd00000269sv00001043sd0000816Abc06sc80i00"
  Driver Info #0:
    Driver Status: forcedeth is active
    Driver Activation Cmd: "modprobe forcedeth"
  Config Status: cfg=no, avail=yes, need=no, active=unknown

Board: ASUS M2NPV-VM ACPI BIOS Revision 0603
Distr: openSUSE 10.2

Ideas, patches, workarounds are heightly appreciated.

TIA,
Pete

--Boundary-00=_xWa3HYkBFqHO14e
Content-Type: application/x-python;
  name="mctest.py"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mctest.py"

#!/usr/bin/env python
# multicast server/client test

import socket
import struct
import time
import sys

mcip = '229.0.0.1'
host = ''
port = 12345

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

if len(sys.argv) > 1 and sys.argv[1] == 'server':
    # server
    seq = 0
    while True:
        pkt = '%s: %s' % (seq, time.asctime())
        seq += 1
        s.sendto(pkt, (mcip, port))
        print 'server: %s [%s] send' % (pkt, len(pkt))
        time.sleep(1)

else:
    # client
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((mcip, port))
    # allow broadcasts
    s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    # join the broadcast group
    mreq = struct.pack('4sl', socket.inet_aton(mcip), socket.INADDR_ANY)
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)
    for i in range(10):
        pkt, addr = s.recvfrom(1500)
        print 'client: %s [%s] received from %s' % (pkt, len(pkt), addr[0])
    s.setsockopt(socket.IPPROTO_IP, socket.IP_DROP_MEMBERSHIP, mreq)

--Boundary-00=_xWa3HYkBFqHO14e--
