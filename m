From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Linux Routing Performance Update
Date: Wed, 26 Jan 2005 14:27:10 +0100
Message-ID: <16887.39598.648724.421160@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, davem@davemloft.net, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

Finally time for some more testing with a somewhat upgraded equipment.

Linux:  Vanilla 2.6.10 plus e1000 patch brewed from input from Scott feldman, 
         Lennert Buytenhek and others. 
         ftp://robur.slu.se/pub/Linux/net-development/tmp/e1000-new-tx-4.pat

System: Dual Opteron 250 (2.4 GHz) all boards dual e1000 w 82546GB.

-------------------------------------------------------------------------------
Experiment 1: Single flow on UP 

Input rate 1.488  Mpps

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 7132981 4056792 4056792 2867019      5      0      0      0 BRU
eth1   1500   0      1      0      0      0 7131234      0      0      0 BRU
eth2   1500   0      0      0      0      0      5      0      0      0 BRU
eth3   1500   0      0      0      0      0      5      0      0      0 BRU

           CPU0       
 24:        108   IO-APIC-level  eth1
 27:        107   IO-APIC-level  eth0
 28:        109   IO-APIC-level  eth2
 29:        109   IO-APIC-level  eth3

006cd736 00000000 00005ce0 00000000 00000000 00000000 00000000 00000000 00000000

Full DoS of 10 Mpackets now at 1.488 Mpps. We route 71.3%.

Routing t-put 1061 kpps. So we passed 1 Mpps...

Note there are no RX interrupts (NAPI) Also as the e1000 cleans the skb's at 
hard_xmit so we see no TX interrupts either. 

-------------------------------------------------------------------------------
Experiment 2: SMP/(NUMA)

Even more exciting. Same as above but input 2 * 1.430 Mpps (max from the
pktgen box it's a DUAL XEON 2.67 GHz) 

Note! 
Routing is setup so pkts on eth0->eth1 on CPU0. and irq's for eth0/eth1 goes
to CPU0. The other flow on eth2/eth3 on CPU1 is handled similar.


Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 7231782 4282705 4282705 2768218      5      0      0      0 BRU
eth1   1500   0      4      0      0      0 7230466      0      0      0 BRU
eth2   1500   0 7671898 4723762 4723762 2328102      5      0      0      0 BRU
eth3   1500   0      1      0      0      0 7670181      0      0      0 BRU

           CPU0       CPU1       
 24:        143          1   IO-APIC-level  eth1
 27:        138          1   IO-APIC-level  eth0
 28:         19        121   IO-APIC-level  eth2
 29:         19        121   IO-APIC-level  eth3

006e592a 00000000 00005e29 00000000 00000000 00000000 00000000 00000000 00000000
0075105b 00000000 000063e4 00000000 00000000 00000000 00000000 00000000 00000000

Few interrupts and balanced as it was setup. /proc/net/softnet_stat show both
CPU were involved forwarding.

An aggregated routing performance of 2.1 Mpps. Enjoy.


						--ro
