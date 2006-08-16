From: Daniel Parthey <linux-networking@spambox.dyndns.org>
Subject: PROBLEM: baycom_ser_fdx in kernel 2.6, transmit broken
Date: Wed, 16 Aug 2006 23:05:25 +0200
Message-ID: <20060816210525.GA13193@daniel.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tnp-online.de ([212.80.247.147]:62369 "EHLO
	relay2.gigamail.to") by vger.kernel.org with ESMTP id S932227AbWHPVFa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 17:05:30 -0400
Received: from scanner7.gigamail.to (content7.cluster.gigamail.to [192.168.254.202])
	by mxout2.gigamail.to (Postfix) with ESMTP id 8A44BA774E
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 23:05:29 +0200 (CEST)
Received: from chimp.subsystem.local (content7.cluster.gigamail.to [192.168.254.202])
	by chimp.scanner7.gigamail.to (Postfix) with ESMTP id 7FE3D787AD
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 23:05:29 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by chimpgate.scanner7.gigamail.to (Postfix) with ESMTP id 1B0E1787CF
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 23:05:29 +0200 (CEST)
Received: from scanner7.gigamail.to ([127.0.0.1])
 by localhost (scanner7.gigamail.to [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 31628-01 for <netdev@vger.kernel.org>;
 Wed, 16 Aug 2006 23:05:28 +0200 (CEST)
Received: from relay2.gigamail.to (relay2.cluster.gigamail.to [192.168.254.16])
	by scanner7.gigamail.to (Postfix) with ESMTP id E7B34787AD
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 23:05:28 +0200 (CEST)
Received: from daniel.localdomain (unknown [84.19.218.176])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.chemonline.de (Postfix) with ESMTP id 8C21BA774E
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 23:05:26 +0200 (CEST)
Received: from pada with local id 1GDSZp-0003RV-Q8
	for netdev@vger.kernel.org; Wed, 16 Aug 2006 23:05:25 +0200
To: Networking Team <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Last year I reported to the linux-hams list and to Tom Sailer
that I could not get AX25 to work using a serial baycom modem with
baycom_ser_fdx under vanilla kernel 2.6.11.6 although it ran fine
under kernel 2.4.30:
http://he.fi/archive/linux-hams/200505/0021.html

I got no answer, but other people experienced the same problem:
http://he.fi/archive/linux-hams/200508/0108.html

Now, I quickly checked again with Debian Kernel linux-image-2.6.17-2-686
(2.6.17-6) and the problem still persists.

Receiving packets works without any problems, but the transmitted
packets are erroneous.

I set up another testbox (situated in the same building) with a
soundcard and the soundmodem tools to analyse this problem.
I could only read some data after enabling "pass all" (no FCS check)
and then it looked like some bytes were missing.

Packet: fm D0CHZ0-3 to IATEp-14 via B0STL0-3,H2NOD0-1 I35  pid=65
          ^            ^

The correct frame header should look like:

Packet: fm ND0CHZ-0 to IGATE-0 via CB0STL-0,CH2NOD-0 I35  pid=65

As far as I can tell from looking at the waveforms, my packets are
complete and not cut off, neither at the beginning nor the end.

Packets received from other stations are decoded correctly.

[Sending station]

  - Vanilla kernel (kernel.org) 2.6.11.6 with the configuration
    adapted from the debian kernel
  - Kernel compiled with gcc version 3.3.5
  - Processor Intel Celeron (Mendocino) 450 MHz

  - Serial configuration (Modem on ttyS0)
    # setserial -g /dev/ttyS{0,1}
    /dev/ttyS0, UART: unknown, Port: 0x03f8, IRQ: 4
    /dev/ttyS1, UART: 16550A, Port: 0x02f8, IRQ: 3

  - Baycom startup options:
    sethdlc -p -i bcsf0 mode "ser12*" io 0x3f8 irq 4
    ifup bcsf0
    sethdlc -i bcsf0 -a half

  - Module parameters for /etc/modules.conf
    options baycom_ser_fdx mode="ser12*" iobase=0x3f8 irq=4
    alias bcsf0 baycom_ser_fdx
    alias nr0 netrom
    alias tty-ldisc-5  mkiss

  - Loaded modules:
    hdlcdrv, baycom_ser_fdx, ax25, mkiss, af_packet

  - /etc/ax25/axports
    cb  CBPORT-0  19200 255 7 CB-Funk
    axudp AXUDP-0   19200 255 7 Netzwerk AX25UDP Link
    lokal CH0CON-0  19200 255 7 Lokal

# cat /proc/ioports | grep baycom
03f8-03ff : baycom_ser_fdx

# cat /proc/interrupts 
           CPU0       
  0:     285101          XT-PIC  timer
  1:        130          XT-PIC  i8042
  2:          0          XT-PIC  cascade
  4:      39576          XT-PIC  baycom_ser_fdx
  7:          0          XT-PIC  parport0
 11:       3473          XT-PIC  Intel ICH 82801AA, eth0
 12:       9693          XT-PIC  HiSax, uhci_hcd, eth1
 14:      17651          XT-PIC  ide0
 15:         13          XT-PIC  ide1
NMI:          0 
LOC:          0 
ERR:          0
MIS:          0


[Testbox]

- soundmodemconfig from debian package "soundmodem" version 0.9-1

The complete output of soundmodemconfig with "pass all" enabled:

Modulator: afsk Demodulator: afsk
Modulator: parameter bps value 1200
Modulator: parameter f0 value 1200
Modulator: parameter f1 value 2200
Modulator: parameter diffenc value 1
Demodulator: parameter bps value 1200
Demodulator: parameter f0 value 1200
Demodulator: parameter f1 value 2200
Demodulator: parameter diffdec value 1
Minimum sampling rate: 9600
Audio IO: type soundcard
sm[7286]: audio: starting "/dev/dsp"
sm[7286]: audio: forcing half duplex mode
sm[7286]: audio: sample rate 9600 input fragsz 256 numfrags 2 output fragsz 256 numfrags 256
Real sampling rate: 9600
passall: 1
passall: 0
passall: 1
Packet: fm ND0CHZ-0 to kIATE-0 via CB0M0C-8,2NOD0-8,*42'2:-7,722&-4 I37^ pid=75
x), 1.79dp02 (JO60JT:ND0CHZ)
Internet-Node Chemnitz-Gruena - Mail DP9BOX

Packet: 
Packet: 
Packet: fm D0CHZ0-3 to IATEp-14 via B0STL0-3,H2NOD0-1 I35  pid=65
NetNode (Linux), 1.79dp02 (JO60JT:ND0CHZ)
Internet-Node Chemnitz-Gruena - Mail DP9BOX

Packet: fm NXHZ0C-2 to kIATE-0 via 0STL0C-8,2NOD0-8,*42'2:-7,722&-4 I37  pid=75
x), 1.79dp0(JO60JT:NdHZ)
Internet-Node Chemnitz-Gruena - Mail DP9BOX

Packet: 
Joining TxThread
Joining RxThread
Releasing IO

I would be happy to provide further information if necessary.

Bye,
Daniel.
-- 
JabberID: pada@jabber.ccc.de
http://de.wikipedia.org/wiki/Jabber
