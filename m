From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: [Question] SMP for Linux
Date: Sat, 19 Oct 2002 09:53:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15793.3958.926796.634263@robur.slu.se>
References: <15792.13249.474279.391081@robur.slu.se>
	<000b01c276fe$46626720$3701020a@CONCORDIA>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'Robert Olsson'" <Robert.Olsson@data.slu.se>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <J_Fraser@bit-net.com>
In-Reply-To: <000b01c276fe$46626720$3701020a@CONCORDIA>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jon Fraser writes:

 > The e1000 driver has been modified in a couple of ways.
 > The interrupts have been limited to 5k/second per card. This
 > mimics the actual hardware being shipped which uses an
 > intel 82543 chip but has an fpga used to do some
 > control functions and generate the interrupts.
 > 
 > We also don't use any transmit interrupts.  The Tx ring
 > is not cleaned at interrupt time.  It's cleaned when
 > we transmit frames and the number of free tx descriptors
 > drops below a threshold.  I also have some code which
 > directs the freed skb back to the cpu it was allocated on, 
 > but it's not in this driver version.

 NAPI stuff will do interrupt mitigation for you. You probably
 get a lot less RX interrupts at your loads. 

 I did the old trick to clean TX-buffers at hard_xmit as well
 but don't see any particularly win from this.

Input 1.14 Mpps. Both eth0, eth1 bound to CPU0

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 4313221 8316434 8316434 5658887     28      0      0      0 BRU
eth1   1500   0     23      0      0      0 4313217      0      0      0 BRU

e1000 messes up RX-ERR and RX-DRP as seen but you see TX-OK on eth1. 491 kpps.

           CPU0       CPU1       
 24:      53005          1   IO-APIC-level  eth1
 25:         19          0   IO-APIC-level  eth0

Alltogether 19 RX and 53k TX interrupts was used. 

0041d09c 00000000 000038d9 00000000 00000000 00000000 00000000 00000000 00000001
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
RC hit/miss = 4313099/384

And this run used "bound" w. private skb receycling.


 >                   bound   float   split
 > 			cpu %    cpu%    cpu%
 >                 -----------------------
 > 1 flow           290     270     290
 > 			99%x1	 65%x2   99%x1
 > 
 > 2 flows          270     380     450
 >                  99%x1   82%x2  96%x2

 Looks promising that you get aggregated performance from SMP.
 But "float" is the number to look for... It's almost impossible
 to use any device binding with forwarding at least as a general
 solution.

 > Previously, I've used the CPU performance monitoring counters
 > to find that cache invalidates tends to be a big problem when
 > the interrupts are not bound to a pariticular cpu.  Bind the
 > card to a particular interrupt effectively binds the flow to
 > a particular cpu.

 Hope to verify this for "kfree-route" test. Did you use oprofile
 for performance counters?

 > I'll repeat the same tests on Monday with 82543 based cards.
 > I would expect similar results.
 > Oh, I used top and vmstat to collect cpu percentages, interrupts/second,

 Hmm top and vmstat doesn't give you time spent in irq/softirq's except for 
 softirq's run via ksoftird?

 Cheers.

						--ro
