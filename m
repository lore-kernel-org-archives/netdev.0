From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 26 Nov 2004 16:59:01 +0100
Message-ID: <1101484740.24742.213.camel@mellia.lipar.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>  <16807.20052.569125.686158@robur.slu.se>
Reply-To: mellia@prezzemolo.polito.it
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16807.20052.569125.686158@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert,
It a pleasure to hear from you.

>  > I questioned whether you actually did receive at that rate to
>  > which you responded:
>  > 
>  >  > - using Click, we can receive 100% of (small) packets at gigabit
>  >  >   speed with TWO cards (2gigabit/s ~ 2.8Mpps)
>  >  > - using linux and standard e1000 driver, we can receive up to about
>  >  >   80% of traffic from a single nic (~1.1Mpps)
>  >  > - using linux and a modified (simplified) version of the driver, we
>  >  >   can receive 100% on a single nic, but not 100% using two nics (up
>  >  >   to ~1.5Mpps).
>  >  >
>  >  > Reception means: receiving the packet up to the rx ring at the
>  >  > kernel level, and then IMMEDIATELY drop it (no packet processing,
>  >  > no forwarding, nothing more...)
>  
>  In more detail please... The RX ring must be refilled? And HW DMA's
>  the to memory-buffer? But I assume data it not touched otherwise.
> 
>  Touching the packet-data givs a major impact. See eth_type_trans
>  in all profiles.

That's exactly what we removed from the driver code: touching the packet
limit the reception rate at about 1.1Mpps, while avoiding to check the
eth_type_trans actually allows to receive 100% of packets.

skb are de/allocated using standard kernel memory management. Still,
without touching the packet, we can receive 100% of them.

>  So what forwarding numbers is seen?

Forwarding is another issue. It seems to us that the bottleneck is in
the transmission of packets. Indeed, considering only reception and
transmission _separetely_
- all packets can be received
- no more than ~700kpps can be trasmitted

When IP-forwarding is considered, no more we hit the transmission limit
(using NAPI, and your buffer recycling patch, as mentioned on the paper
and on the slides... If no buffer recycling is adopted, performance drop
a bit)
So it seemd to us that the major bottleneck is due to the transmission
limit.

Again, you can get numbers and more details from

http://www.tlc-networks.polito.it/~mellia/euroTLC.pdf
http://www.tlc-networks.polito.it/mellia/papers/Euro_qos_ip.pdf

>  >  > But the limit in TRANSMISSION seems to be 700Kpps. Regardless of
>  >  > - the traffic generator,
>  >  > - the driver version,
>  >  > - the O.S. (linux/click),
>  >  > - the hardware (broadcom card have the same limit).
>  > 
>  > > 
>  > > - in transmission we CAN ONLY trasmit about 700.000 pkt/s when the
>  > > minimum sized packets are considered (64bytes long ethernet minumum
>  > > frame size). That is about HALF the maximum number of pkt/s considering
>  > > a gigabit link.
>  > > 
>  > > What is weird, is that if we artificially "preload" the NIC tx-fifo with
>  > > packets, and then instruct it to start sending them, those are actually
>  > > transmitted AT WIRE SPEED!!
> 
>  OK. Good to know about e1000. Networking is most DMA's and CPU is used 
>  adminstating it this is the challange.

That's true. There is still the chance that the limit is due to hardware
CRC calculation (which must be added to the ethernet frame by the
nic...). But we're quite confortable that that is not the limit, since
in the reception path the same operation must be performed...

>  > > These results have been obtained considering different software
>  > > generators (namely, UDPGEN, PACKETGEN, Application level generators)
>  > > under LINUX (2.4.x, 2.6.x), and under CLICK (using a modified version of
>  > > UDPGEN).
> 
>  We get a hundred kpps more...Turn off all mitigation so interrupts are 
>  undelayed so TX ring can be filled as quick as possible.
> 
>  Even you could try to fill TX as soon as the HW says there are available
>  buffers. This could even be done from TX-interrupt.

Are you suggesting to modify packetgen to be more aggressive?
 
>  > > The hardware setup considers 
>  > > - a 2.8GHz Xeon hardware
>  > > - PCI-X bus (133MHz/64bit)
>  > > - 1G of Ram
>  > > - Intel PRO 1000 MT single, double, and quad cards, integrated or on a
>  > > PCI slot.
>  > > Is there any limit on the PCI-X (or PCI) that can be the bottleneck?
>  > > Or Limit on the number of packets per second that can be stored in the
>  > > NIC tx-fifo?
>  > > May the lenght of the tx-fifo impact on this?
> 
>  Small packet performance is dependent on low latency. Higher bus speed
>  gives shorter latency but also on higher speed buses there use to be  
>  bridges that adds latency.

That's true. We suspect that the limit is due to bus latency. But still,
we are surprised, since the bus allows to receive 100%, but to transmit
up to ~50%. Moreover the raw aggerate bandwidth of the buffer is _far_
larger (133MHz*64bit ~ 8gbit/s

>  For packet generation we use still 866 MHz PIII:s and 82543GC on serverworks
>  64-bit board which are faster than most other systems. So for testing routing 
>  performance in pps we have to use several flows. This gives the advantage to 
>  test SMP/NUMA as well.

We use an hardware generator (Agilent router tester)... which can
saturate a gigabit link with no problem (and cost much more than a
PC...). So our forwarding test are not limited...
 
-- 
Ciao,                    /\/\/\rco

+-----------------------------------+  
| Marco Mellia - Assistant Professor|
| Tel: 39-011-2276-608              |
| Tel: 39-011-564-4173              |
| Cel: 39-340-9674888               |   /"\  .. . . . . . . . . . . . .
| Politecnico di Torino             |   \ /  . ASCII Ribbon Campaign  .
| Corso Duca degli Abruzzi 24       |    X   .- NO HTML/RTF in e-mail .
| Torino - 10129 - Italy            |   / \  .- NO Word docs in e-mail.
| http://www1.tlc.polito.it/mellia  |        .. . . . . . . . . . . . .
+-----------------------------------+
The box said "Requires Windows 95 or Better." So I installed Linux.
