From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: de2104x problems (and perhaps a clue as to why)
Date: Wed, 26 Nov 2003 13:41:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031126134140.A7327@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

I'm trying to get the de2104x driver to work with a DE450 board. It looks
like something is wrong with either the code to start/stop the chip. This is
with 2.6.0-test10 with your 2.6.0-test9-bk24-netdrv-exp1 patch and the
de2104x fixes posted in the last few days.

$ modprobe -k de2104x
$ ethtool -s eth0 port bnc
$ tulip-diag -faa
tulip-diag.c:v2.17 5/6/2003 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a Digital DC21041 Tulip adapter at 0x2080.
Digital DC21041 Tulip chip registers at 0x2080:
 0x00: ffe00000 ffffffff ffffffff 016dc000 016dc400 fc000000 7ffc0040 fffe0000
 0x40: fffe0000 ffff4bf8 ffffffff fffe0000 000000c4 ffff0000 ffffffff ffff0000
 Port selection is half-duplex.
 Transmit stopped, Receive stopped.
  The Rx process state is 'Stopped'.
  The Tx process state is 'Stopped'.
  The transmit unit is set to store-and-forward.
  The NWay status register is 000000c4.
    100baseTx link good.
    10baseT link good.
  Internal autonegotiation state is 'Autonegotiation disabled'.

$ ifconfig eth0 up
$ tulip-diag -faa
tulip-diag.c:v2.17 5/6/2003 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a Digital DC21041 Tulip adapter at 0x2080.
Digital DC21041 Tulip chip registers at 0x2080:
 0x00: ffe00000 ffffffff ffffffff 014c5000 014c5400 fc660000 7ffc2002 ffffb0d5
 0x40: fffe0000 ffff03ff ffffffff fffe0000 000020c4 ffffef09 fffff7fd ffff0006
 Port selection is half-duplex.
 Transmit started, Receive started.
  The Rx process state is 'Waiting for packets'.
  The Tx process state is 'Idle'.
  The transmit unit is set to store-and-forward.
  The NWay status register is 000020c4.
    100baseTx link good.
    10baseT link good.
  Internal autonegotiation state is 'Ability detect'.

$ ifconfig eth0 down
$ tulip-diag -faa
tulip-diag.c:v2.17 5/6/2003 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a Digital DC21041 Tulip adapter at 0x2080.
Digital DC21041 Tulip chip registers at 0x2080:
 0x00: ffe00000 ffffffff ffffffff 014c5000 014c5400 fc000000 7ffc0000 fffe0000
 0x40: fffe0000 ffff4bf8 ffffffff fffe0000 000020c4 ffffef09 fffff7fd ffff0006
 Port selection is half-duplex.
 Transmit stopped, Receive stopped.
  The Rx process state is 'Stopped'.
  The Tx process state is 'Stopped'.
  The transmit unit is set to store-and-forward.
  The NWay status register is 000020c4.
    100baseTx link good.
    10baseT link good.
  Internal autonegotiation state is 'Ability detect'.

So far so good. Now, if I try to bring the interface up again, the trouble
starts:
$ ifconfig eth0 up
$ tulip-diag -faa
tulip-diag.c:v2.17 5/6/2003 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a Digital DC21041 Tulip adapter at 0x2080.
Digital DC21041 Tulip chip registers at 0x2080:
 0x00: ffe00000 ffffffff ffffffff 0171a000 0171a400 fc120000 7ffc2002 ffffb0d5
 0x40: fffe0000 ffff03ff ffffffff fffe0000 000020c4 ffffef09 fffff7fd ffff0006
 Port selection is half-duplex.
 Transmit started, Receive started.
  The Rx process state is 'Reading a Rx descriptor'.
  The Tx process state is 'Reading a Tx descriptor'.
  The transmit unit is set to store-and-forward.
  The NWay status register is 000020c4.
    100baseTx link good.
    10baseT link good.
  Internal autonegotiation state is 'Ability detect'.

Taking the interface down no longer works either:
$ ifconfig eth0 down
eth0: timeout expired stopping dma
$ tulip-diag -faa
tulip-diag.c:v2.17 5/6/2003 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a Digital DC21041 Tulip adapter at 0x2080.
Digital DC21041 Tulip chip registers at 0x2080:
 0x00: ffe00000 ffffffff ffffffff 0171a000 0171a400 fc120000 7ffc0000 fffe0000
 0x40: fffe0000 ffff4bf8 ffffffff fffe0000 000020c4 ffffef09 fffff7fd ffff0006
 Port selection is half-duplex.
 Transmit stopped, Receive stopped.
  The Rx process state is 'Reading a Rx descriptor'.
  The Tx process state is 'Reading a Tx descriptor'.
  The transmit unit is set to store-and-forward.
  The NWay status register is 000020c4.
    100baseTx link good.
    10baseT link good.
  Internal autonegotiation state is 'Ability detect'.

The chip appears to get stuck reading the descriptors. Reloading the module
is necessary to make the interface work again.

The de4x5 driver works fine.
$ rmmod de2104x
$ modprobe -k de4x5
$ ifconfig eth0 up
$ ifconfig eth0 down
$ ifconfig eth0 up
$ tulip-diag -faa
tulip-diag.c:v2.17 5/6/2003 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a Digital DC21041 Tulip adapter at 0x2080.
Digital DC21041 Tulip chip registers at 0x2080:
 0x00: ffe08400 ffffffff ffffffff 0139a000 0139a080 fc660000 7ffc2002 ffff8065
 0x40: fffe0000 ffff03ff ffffffff fffe0000 000000c4 ffffef09 fffff73d ffff0006
 Port selection is half-duplex.
 Transmit started, Receive started.
  The Rx process state is 'Waiting for packets'.
  The Tx process state is 'Idle'.
  The transmit unit is set to store-and-forward.
  The NWay status register is 000000c4.
    100baseTx link good.
    10baseT link good.
  Internal autonegotiation state is 'Autonegotiation disabled'.


lspci dug up something interesting:
$ modprobe -k de2104x
$ ethtool -s eth0 port bnc
$ ifconfig eth0 up
$ ifconfig eth0 down
$ ifconfig eth0 up
$ lspci -vvv
[...]
00:0e.0 Ethernet controller: Digital Equipment Corporation DECchip 21041 [Tulip Pass 3] (rev 11)
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 11
	Region 0: I/O ports at 2080 [size=128]
	Region 1: Memory at 42200000 (32-bit, non-prefetchable) [size=128]
	Expansion ROM at <unassigned> [disabled] [size=256K]
[...]

Say what? It says "BusMaster-", which means busmaster DMA is disabled,
right? Then of course it won't work. Is this because de_close() calls
pci_disable_device() and de_open() doesn't not reenable the device?

-- 
Regards,
Rask Ingemann Lambertsen
