From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Tue, 17 Jun 2008 11:39:29 +0200
Message-ID: <20080617093929.GA10334@elte.hu>
References: <20080617083220.GA11393@elte.hu>
	<20080617.020840.169830916.davem@davemloft.net>
	<20080617092706.GB20621@elte.hu>
	<20080617.022909.173003136.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl,
	mcmanus@ducksong.com, ilpo.jarvinen@helsinki.fi,
	kuznet@ms2.inr.ac.ru, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080617.022909.173003136.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 17 Jun 2008 11:27:06 +0200
> 
> > when i originally reported it i debugged it back to missing e1000 TX 
> > completion IRQs. I tried various versions of the driver to figure 
> > out whether new workarounds for e1000 cover it but it was fruitless. 
> > There is a 1000 msec internal watchdog timer IRQ within e1000 that 
> > gets things going if it's stuck.
> 
> Then that explains your latency, the chip is getting stuck and TX 
> interrupts stop, right.

note that the 1000 msecs timer is AFAIK internal to the e1000 
_hardware_, not the driver itself. I.e. probably the firmware detects 
and works around a hung transmitter. This is not detectable from the OS 
(it's not an OS timer), but it can be observed by a lot of testing on a 
totally quiescent system - which i did back then ;-)

i also played a lot with the various knobs of the e1000, none of which 
seemed to help.

/me digs in archives

i reported it to the e1000 folks in 2006:

  Date: Mon, 4 Dec 2006 11:24:00 +0100

against 2.6.19. The original report is below - with a trace and various 
things i tried to debug this.

i eventually got the suggestion from Auke to set RxIntDelay=8 which 
seemed to work around the issue - but since i use a built-in driver i 
dont have that setting here (RxIntDelay=8 is a module load parameter and 
not exposed via Kconfig methods) and the e1000 driver does not seem to 
have changed its default setting for RxIntDelay.

2.6.18-1.2849.fc6 was the last kernel that worked fine.

	Ingo

-------------------->
Date: Wed, 13 Dec 2006 22:09:22 +0100
From: Ingo Molnar <mingo@elte.hu>
To: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000: 2.6.19 & long packet latencies
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        "Ronciak, John" <john.ronciak@intel.com>

Jesse, et al.,

i'm having a weird packet processing latency problem with the e1000 
driver and recent kernels.

The symptom is this: if i connect to a T60 laptop (which has an on-board 
e1000) from the outside, i see large delays in network activity, and ssh 
sessions are very sluggish.

ping latencies show it best under a dynticks kernel (but vanilla 2.6.19 
is affected too):

 titan:~/linux/linux> ping e
 PING europe (10.0.1.15) 56(84) bytes of data.
 64 bytes from europe (10.0.1.15): icmp_seq=1 ttl=64 time=0.340 ms
 64 bytes from europe (10.0.1.15): icmp_seq=2 ttl=64 time=757 ms
 64 bytes from europe (10.0.1.15): icmp_seq=3 ttl=64 time=1001 ms
 64 bytes from europe (10.0.1.15): icmp_seq=4 ttl=64 time=1001 ms
 64 bytes from europe (10.0.1.15): icmp_seq=5 ttl=64 time=0.356 ms
 64 bytes from europe (10.0.1.15): icmp_seq=6 ttl=64 time=2127 ms
 64 bytes from europe (10.0.1.15): icmp_seq=7 ttl=64 time=1002 ms
 64 bytes from europe (10.0.1.15): icmp_seq=8 ttl=64 time=0.320 ms
 64 bytes from europe (10.0.1.15): icmp_seq=9 ttl=64 time=1002 ms
 64 bytes from europe (10.0.1.15): icmp_seq=10 ttl=64 time=2004 ms
 64 bytes from europe (10.0.1.15): icmp_seq=11 ttl=64 time=1002 ms
 64 bytes from europe (10.0.1.15): icmp_seq=12 ttl=64 time=0.303 ms
 64 bytes from europe (10.0.1.15): icmp_seq=13 ttl=64 time=1000 ms
 64 bytes from europe (10.0.1.15): icmp_seq=14 ttl=64 time=2010 ms
 64 bytes from europe (10.0.1.15): icmp_seq=15 ttl=64 time=1009 ms
 64 bytes from europe (10.0.1.15): icmp_seq=16 ttl=64 time=0.283 ms

i have traced this and the 1000/2000 msecs values come from some sort of 
e1000-internal 'heartbeat' interrupt. What seems to happen is that RX 
packet processing is delayed indefinitely and the IRQ just does not 
arrive.

NOTE: the vanilla 2.6.19 kernel shows this too, but the ping delays are 
1/HZ.

here's a (filtered) trace of such a delay. IRQ 0x219 is the e1000 
interrupt:

  <idle>-0     0D.h1 761236us : do_IRQ (c0272a9b 219 0)
 IRQ_219-356   0.... 761412us+: e1000_intr (handle_IRQ_event)
 IRQ_219-356   0.... 761416us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 761418us+: e1000_clean_tx_irq (e1000_intr)
  <idle>-0     0D.h1 2760093us : do_IRQ (c0272a9b 219 0)
 IRQ_219-356   0.... 2760268us+: e1000_intr (handle_IRQ_event)
 IRQ_219-356   0.... 2760273us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 2760275us : e1000_clean_tx_irq (e1000_intr)
  <idle>-0     0D.h1 3804499us : do_IRQ (c0272a9b 219 0)
 IRQ_219-356   0.... 3804674us+: e1000_intr (handle_IRQ_event)
 IRQ_219-356   0.... 3804679us+: e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 3804761us : e1000_clean_tx_irq (e1000_intr)
 IRQ_219-356   0.... 3804763us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 3804765us : e1000_clean_tx_irq (e1000_intr)
softirq--7     0.... 3804810us : net_rx_action (ksoftirqd)
softirq--5     0D.h. 3805425us : do_IRQ (c01598ac 219 0)
 IRQ_219-356   0.... 3805499us+: e1000_intr (handle_IRQ_event)
 IRQ_219-356   0.... 3805504us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 3805506us : e1000_clean_tx_irq (e1000_intr)
 IRQ_219-356   0.... 3805547us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 3805549us : e1000_clean_tx_irq (e1000_intr)
softirq--6     0.... 3805641us : net_tx_action (ksoftirqd)
  <idle>-0     0D.h1 4760910us : do_IRQ (c01451d4 219 0)
 IRQ_219-356   0.... 4761347us+: e1000_intr (handle_IRQ_event)
 IRQ_219-356   0.... 4761352us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 4761353us : e1000_clean_tx_irq (e1000_intr)
  <idle>-0     0D.h1 6761309us : do_IRQ (c0272a9b 219 0)
 IRQ_219-356   0.... 6761483us+: e1000_intr (handle_IRQ_event)
 IRQ_219-356   0.... 6761488us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 6761490us : e1000_clean_tx_irq (e1000_intr)
softirq--5     0D.h. 8760595us : do_IRQ (c0135dc4 219 0)
 IRQ_219-356   0.... 8760676us+: e1000_intr (handle_IRQ_event)
 IRQ_219-356   0.... 8760681us+: e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 8760739us : e1000_clean_tx_irq (e1000_intr)
 IRQ_219-356   0.... 8760740us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 8760742us : e1000_clean_tx_irq (e1000_intr)
softirq--7     0.... 8760885us : net_rx_action (ksoftirqd)
softirq--7     0.... 8760914us+: icmp_rcv (ip_local_deliver)
softirq--7     0.... 8760923us+: icmp_reply (icmp_echo)
  <idle>-0     0D.h1 8761661us : do_IRQ (c0272a9b 219 0)
 IRQ_219-356   0.... 8761833us+: e1000_intr (handle_IRQ_event)
 IRQ_219-356   0.... 8761838us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 8761840us : e1000_clean_tx_irq (e1000_intr)
 IRQ_219-356   0.... 8761875us : e1000_clean_rx_irq (e1000_intr)
 IRQ_219-356   0.... 8761876us : e1000_clean_tx_irq (e1000_intr)
softirq--6     0.... 8761921us : net_tx_action (ksoftirqd)

note that timestamps 2760093us, 4760910us, 6761309us and 8760595us is 
some sort of traffic-independent 'periodic' interrupt that e1000 
generates. That 'housekeeping' interrupt doesnt seem to be doing much. 
The IRQ at 8760595us picks up an icmp packet and replies to it - but the 
icmp packet in reality arrived somewhere between timestamps 6761309us 
and 8760595us - but no IRQ was generated for it!

Suspecting the interrupt-rate controlling bits of the e1000 hw i have 
tried the following tunes too:

 -#define DEFAULT_RDTR                   0
 +#define DEFAULT_RDTR                   1

 -#define DEFAULT_RADV                 128
 +#define DEFAULT_RADV                   1

 -#define DEFAULT_TIDV                  64
 +#define DEFAULT_TIDV                   1

 -#define DEFAULT_TADV                  64
 +#define DEFAULT_TADV                   1

 -#define DEFAULT_ITR                 8000
 +#define DEFAULT_ITR               100000

but they made no difference.

a 2.6.18-ish kernel works fine (2.6.18-1.2849.fc6):

 titan:~/linux/linux> ping e
 PING europe (10.0.1.15) 56(84) bytes of data.
 64 bytes from europe (10.0.1.15): icmp_seq=1 ttl=64 time=0.695 ms
 64 bytes from europe (10.0.1.15): icmp_seq=2 ttl=64 time=0.171 ms
 64 bytes from europe (10.0.1.15): icmp_seq=3 ttl=64 time=0.184 ms
 64 bytes from europe (10.0.1.15): icmp_seq=4 ttl=64 time=0.159 ms
 64 bytes from europe (10.0.1.15): icmp_seq=5 ttl=64 time=0.148 ms

 e1000: 0000:02:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x1) 00:16:41:17:49:d2
 e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection

the precise hardware version is:

 02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
        Subsystem: Lenovo ThinkPad T60
        Flags: bus master, fast devsel, latency 0, IRQ 90
        Memory at ee000000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at 2000 [size=32]
        Capabilities: <access denied>

this laptop has a CoreDuo so i have tried maxcpus=1 too, but it didnt 
make any difference.

Any ideas about what i should try next?

	Ingo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
