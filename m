From: Marc Zyngier <mzyngier@freesurf.fr>
Subject: de2104x (was Re: [PATCH][2.6] de4x5 cleanup)
Date: Sun, 31 Aug 2003 11:31:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wrp65ke5g2c.fsf_-_@hina.wild-wind.fr.eu.org>
References: <wrpad9r79g6.fsf@hina.wild-wind.fr.eu.org>
	<3F50E3FD.1000703@pobox.com>
	<wrpn0dr55n1.fsf@hina.wild-wind.fr.eu.org>
	<3F50F805.9090805@pobox.com>
Reply-To: mzyngier@freesurf.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-net@vger.kernel.org,
   Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F50F805.9090805@pobox.com> (Jeff Garzik's message of "Sat, 30
 Aug 2003 15:16:21 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Jeff" == Jeff Garzik <jgarzik@pobox.com> writes:

Jeff> Well, 2.6 tulip intentionally doesn't work at all on 21040 and
Jeff> 21041 :) That's what de2104x driver is for.  Can you give that a
Jeff> beating, and verify that it works for you?

So, as promised, I tried de2104x on the AS-255 (which was problematic
a few months ago). I must say it works nicely, as long as I don't
unplug the cable...

Here are the details :

otherside:~# lspci
00:06.0 SCSI storage controller: LSI Logic / Symbios Logic (formerly NCR) 53c810 (rev 11)
00:07.0 Non-VGA unclassified device: Intel Corp. 82378IB [SIO ISA Bridge] (rev 43)
00:0d.0 VGA compatible controller: Digital Equipment Corporation PBXGB [TGA2] (rev 22)
00:0e.0 Ethernet controller: Digital Equipment Corporation DECchip 21040 [Tulip] (rev 26)
otherside:~# ethtool eth0
Settings for eth0:
        Supported ports: [ TP AUI ]
        Supported link modes:   10baseT/Half 10baseT/Full 
        Supports auto-negotiation: No
        Advertised link modes:  10baseT/Half 10baseT/Full 
        Advertised auto-negotiation: No
        Speed: Unknown! (5)
        Duplex: Half
        Port: AUI
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Current message level: 0x000000f7 (247)
        Link detected: yes

Note that an AUI port is reported, while the system really has only a
10baseT port.

while booting, everything looks OK :
[...]
de2104x PCI Ethernet driver v0.5.4 (Jan 1, 2002)
eth0: 21040 at 0xfffffc0301209000, 00:00:25:4a:21:3a, IRQ 15
[...]
eth0: enabling interface
eth0: set link 10baseT-HD
eth0:    mode 0xfffc0040, sia 0xffffffcd,0xffff8f01,0xffffffff,0xffff0000
eth0:    set mode 0xfffc0000, set sia 0x8f01,0xffff,0x0
eth0: link up, media 10baseT-HD

It works perfectly, until I unplug the cable (I know, I'm a bad
boy... ;-), wait 10 seconds, then plug it back :

eth0: link down
eth0: set link AUI
eth0:    mode 0xfffc0000, sia 0xffffffc1,0xffff8f09,0xffff0705,0xffff0006
eth0:    set mode 0xfffc0000, set sia 0x8f09,0x705,0x6
eth0: link up, media AUI

So link is now up, on a non-existant AUI port ?!?!
Let's inform the driver that we want the TP port instead :

otherside:~# ethtool -s eth0 port tp
Cannot set new settings: Invalid argument
  not setting port

So 'tp' is invalid ? Interesting... Let's try the old ifconfig down/up
method :

eth0: disabling interface
eth0: enabling interface
eth0: set link AUI
eth0:    mode 0xfffc0040, sia 0xffffffc1,0xffff8f09,0xffff0705,0xffff0006
eth0:    set mode 0xfffc0000, set sia 0x8f09,0x705,0x6
eth0: link up, media AUI

No effect... Let's try it again, for fun :

eth0: disabling interface
eth0: timeout expired stopping DMA
eth0: enabling interface
eth0: set link AUI
eth0:    mode 0xfffc0040, sia 0xffffffc1,0xffff8f09,0xffff0705,0xffff0006
eth0:    set mode 0xfffc0000, set sia 0x8f09,0x705,0x6
eth0: link up, media AUI

Problem stopping DMA ? Frightening ! :-) Finally, I had to reboot the
system to get the the network back up (since modules are not really
useable currently on alpha, but that's another story).

Now, the same thing with the ugly de4x5 :

[...]
0000:00:0e.0: DE434/5 at 0x8400, h/w address 00:00:f8:25:4a:21,
      and requires IRQ15 (provided by PCI BIOS).
de4x5.c:V0.546 2001/02/22 davies@maniac.ultranet.com
[...]
eth0: media is TP.

Unplug the cable, wait 10 seconds, plug it back :

eth0: media is unconnected, link down or incompatible connection.
eth0: media is TP.

Works as expected.

While this problem is a corner case (the de2104x driver itself works
fine), it would be nice if we could solve this issue (loosing network
connectivity because someone rebooted the switch is a bad
behaviour). I promise this machine wont run de4x5 ever again once it
is solved :-).

Thanks,

        M.
-- 
Places change, faces change. Life is so very strange.
