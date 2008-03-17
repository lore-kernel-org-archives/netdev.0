From: Hans-Peter Jansen <hpj@urpla.net>
Subject: Re: multicast problems in forcedeth driver with MCP51 Ethernet Controller
Date: Mon, 17 Mar 2008 23:32:17 +0100
Message-ID: <200803172332.17734.hpj@urpla.net>
References: <200803162356.49709.hpj@urpla.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_xFv3HUmJGbRIZik"
Cc: netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:63075 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbYCQWc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 18:32:26 -0400
In-Reply-To: <200803162356.49709.hpj@urpla.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_xFv3HUmJGbRIZik
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Am Sonntag, 16. M=C3=A4rz 2008 schrieb Hans-Peter Jansen:
> Hi Ayaz, hi forcedeth hackers,
>
> I'm trying to get my first multicast application to life ATM, but even
> the first tests failed mysteriously for some systems, running a 2.6.24.3
> kernel. Goggling around let me to one of your fixes:
> [PATCH 5/5] forcedeth: multicast fix, which Linus applied before
> 2.6.25-rc1 as: bb9a4fd1f7cc083f72e52f01938c23ac5b3403d5
>
> I applied your patch to my local 2.6.24.3 kernel build, but still no go.
> Try attached python script (after setting up a route like this):
>
> Destination     Gateway        Genmask         Flags Metric Ref   Use=20
> Iface 229.0.0.0       *              255.0.0.0       U     0      0     =
=20
>  0 eth0
>
> Run one instance as './mctest.py server' and others without arguments.
> Normally, the server sends out a multicast packet every second, and the
> clients catch 10 of those before quitting, unless such a MCP51 Ethernet
> Controller is in the equation: that one doesn't send/receive a single MC
> bit here... Other nics (well, I tested this on e1000s and another MCP55)
> behave well in this respect.
>
> If I make the MCP51 the server, tcpdump is able to fetch the packets, but
> nothing is received on the other systems. Looks, like multicasting is
> still broken for the NIC in question.
>
> Here's the complete hwinfo for the affected NIC:
> ~# hwinfo --netcards
> 15: PCI 14.0: 0200 Ethernet controller
>   [Created at pci.286]
>   UDI: /org/freedesktop/Hal/devices/pci_10de_269
>   Unique ID: MZfG.uQ5k42VxsiA
>   SysFS ID: /devices/pci0000:00/0000:00:14.0
>   SysFS BusID: 0000:00:14.0
>   Hardware Class: network
>   Model: "ASUSTeK MCP51 Ethernet Controller"
>   Vendor: pci 0x10de "nVidia Corporation"
>   Device: pci 0x0269 "MCP51 Ethernet Controller"
>   SubVendor: pci 0x1043 "ASUSTeK Computer Inc."
>   SubDevice: pci 0x816a
>   Revision: 0xa3
>   Driver: "forcedeth"
>   Driver Modules: "forcedeth"
>   Memory Range: 0xfe02b000-0xfe02bfff (rw,non-prefetchable)
>   I/O Ports: 0xc800-0xc807 (rw)
>   IRQ: 18 (309189603 events)
>   Module Alias: "pci:v000010DEd00000269sv00001043sd0000816Abc06sc80i00"
>   Driver Info #0:
>     Driver Status: forcedeth is active
>     Driver Activation Cmd: "modprobe forcedeth"
>   Config Status: cfg=3Dno, avail=3Dyes, need=3Dno, active=3Dunknown
>
> Board: ASUS M2NPV-VM ACPI BIOS Revision 0603
> Distr: openSUSE 10.2
>
> Ideas, patches, workarounds are heightly appreciated.

Okay, I've read the multicast howto again, inquired on linux-net about my=20
procedures, and did more tests.=20

In my environment, it seems to not matter, what multicast routing I use:
route add -net 224.0.0.0/4 dev eth0
ip route add 224.0.0.0/4 dev eth0
ip route add multicast 224.0.0.0/4 dev eth0

On those systems, that work fine, it does without, and on those, that don't=
,=20
it doesn't change behavior (nothing is send/received), _unless_ I use=20
224.0.0.1 as the multicast group address, which should be avoided, AFAICS.

I've learned to look for the group membership, and while the test program=20
runs, it looks fine:

~# LANG=3DC netstat -gn
IPv6/IPv4 Group Memberships
Interface       RefCnt Group
=2D-------------- ------ ---------------------
lo              1      224.0.0.1
eth0            1      232.1.1.1	    <-- new mc group address default
eth0            1      224.0.0.1
lo              1      ff02::1
eth0            1      ff02::1:ff24:683c
eth0            1      ff02::1

Below, you find the updated/cleaned up version of my test script.

Still busted,
Pete

--Boundary-00=_xFv3HUmJGbRIZik
Content-Type: application/x-python;
  name="mctest.py"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mctest.py"

#!/usr/bin/env python
"""\
Description: simple multicast server/client test

Usage: %(appname)s [-hs][-m ip][-p port]
       -h       this text
       -s       run as server [default: run as client]
       -m ip    multicast address [default: %(mcip)s]
       -p port  udp port [default: %(port)s]
"""
import os
import sys
import time
import socket
import struct
import getopt

class gpar:
    """ central parameter class """
    # internal
    appdir, appname = os.path.split(sys.argv[0])
    if appdir == '.':
        appdir = os.getcwd()
    mcip = '232.1.1.1'
    port = 12345

def out(arg):
    err(arg, sys.stdout)

def err(arg, ch = sys.stderr):
    if arg:
        ch.write(arg)
        if arg[-1] != '\n':
            ch.write('\n')
    ch.flush()

def exit(ret = 0, msg = None, usage = False):
    if msg:
        err('%s: %s' % (gpar.appname, msg))
    if usage:
        err(__doc__ % (gpar.__dict__))
    sys.exit(ret)

def server():
    # enable multicast loopback for local clients
    s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    # set multicast ttl
    s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 1)
    # todo: select the correct iface and check if it is mc capable
    seq = 0
    while True:
        pkt = '%s: %s' % (seq, time.asctime())
        seq += 1
        s.sendto(pkt, (gpar.mcip, gpar.port))
        out('server: %s [%s] send' % (pkt, len(pkt)))
        time.sleep(1)

def client():
    s.bind((gpar.mcip, gpar.port))
    # join the broadcast group
    ip_mreq = struct.pack('4sl', socket.inet_aton(gpar.mcip), socket.INADDR_ANY)
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, ip_mreq)
    while True:
        pkt, addr = s.recvfrom(1500)
        out('client: %s [%s] received from %s' % (pkt, len(pkt), addr[0]))
    # leave the broadcast group (paranoiac..)
    s.setsockopt(socket.IPPROTO_IP, socket.IP_DROP_MEMBERSHIP, ip_mreq)

if __name__ == '__main__':
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'hsm:p:')
    except getopt.error, msg:
        exit(1, msg, True)

    run = client
    for opt, par in optlist:
        if opt == '-h':
            exit(0, usage = True)
        elif opt == '-s':
            run = server
        elif opt == '-m':
            gpar.mcip = par
        elif opt == '-p':
            try:
                gpar.port = int(par)
            except ValueError:
                exit(1, 'option -p requires numeric argument')
    
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    # probably we want to reuse the same address
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    try:
        run()
    except KeyboardInterrupt, e:
        exit(0)

--Boundary-00=_xFv3HUmJGbRIZik--
