From: David Greaves <david@dgreaves.com>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 18 Jun 2004 19:44:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D337FA.1080404@dgreaves.com>
References: <40CDD68C.8070509@dgreaves.com>	<20040615155111.26d6b809@dell_ss3.pdx.osdl.net>	<40D0280B.2030308@dgreaves.com>	<Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se> <20040618111124.3a2681b5@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jens Laas <jens.laas@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040618111124.3a2681b5@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

>To get to the root of these problems, could you:
>
>* Give full lspci -v output for the boards in question.
>  
>
ash:
00:07.0 Ethernet controller: Intel Corp.: Unknown device 1076
        Subsystem: Intel Corp.: Unknown device 1176
        Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 11
        Memory at e3020000 (32-bit, non-prefetchable) [size=128K]
        Memory at e3000000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at b400 [size=64]
        Expansion ROM at <unassigned> [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
        Capabilities: [e4] PCI-X non-bridge device.
        Capabilities: [f0] Message Signalled Interrupts: 64bit+ 
Queue=0/0 Enable-

>* Are you using any special queuing or shaping (output of "tc qdisc ls")
>  
>
no
root@ash:~ # tc qdisc ls
RTNETLINK answers: Invalid argument
Dump terminated

>* You could try the following, which dumps out the state of the transmit ring
>  in case of error. and tries to see if it is one of the other watchdog hooks in
>  this driver.
>  
>
patched :)

Test

root@ash:/usr/src/linux # ifdown eth0 ; modprobe -r e1000;modprobe 
e1000; ifup eth0ifdown: interface eth0 not configured
root@ash:/usr/src/linux # ping 10.0.1.1
PING 10.0.1.1 (10.0.1.1): 56 data bytes
64 bytes from 10.0.1.1: icmp_seq=0 ttl=64 time=0.3 ms
64 bytes from 10.0.1.1: icmp_seq=1 ttl=64 time=0.1 ms
64 bytes from 10.0.1.1: icmp_seq=2 ttl=64 time=0.1 ms
64 bytes from 10.0.1.1: icmp_seq=3 ttl=64 time=0.2 ms

--- 10.0.1.1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.1/0.1/0.3 ms
root@ash:/usr/src/linux # ping -s 1500 10.0.1.1
PING 10.0.1.1 (10.0.1.1): 1500 data bytes
1508 bytes from 10.0.1.1: icmp_seq=0 ttl=64 time=0.3 ms
1508 bytes from 10.0.1.1: icmp_seq=1 ttl=64 time=0.4 ms
1508 bytes from 10.0.1.1: icmp_seq=2 ttl=64 time=0.3 ms

--- 10.0.1.1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.3/0.3/0.4 ms
root@ash:/usr/src/linux # ping -s 3000 10.0.1.1
PING 10.0.1.1 (10.0.1.1): 3000 data bytes
3008 bytes from 10.0.1.1: icmp_seq=0 ttl=64 time=0.4 ms
3008 bytes from 10.0.1.1: icmp_seq=3 ttl=64 time=0.3 ms

--- 10.0.1.1 ping statistics ---
7 packets transmitted, 2 packets received, 71% packet loss
round-trip min/avg/max = 0.3/0.3/0.4 ms

messages: (the 'after 5000 jiffies' is mine)
Jun 18 19:37:43 ash kernel: Copyright (c) 1999-2004 Intel Corporation.
Jun 18 19:37:44 ash kernel: e1000: eth0: e1000_probe: Intel(R) PRO/1000 
Network Co
nnection
Jun 18 19:37:46 ash kernel: e1000: eth0: e1000_watchdog: NIC Link is Up 
1000 Mbps
Full Duplex

Jun 18 19:38:18 ash kernel: eth0: may be hung last tx was 2457 ticks

Jun 18 19:38:20 ash kernel: eth0: may be hung last tx was 4457 ticks
Jun 18 19:38:22 ash kernel: eth0: may be hung last tx was 6457 ticks
Jun 18 19:38:24 ash kernel: eth0: may be hung last tx was 8457 ticks
Jun 18 19:38:26 ash kernel: NETDEV WATCHDOG: eth0: transmit timed out 
after 5000 j
iffies
Jun 18 19:38:26 ash kernel: eth0: transmit timeout from queuing
Jun 18 19:38:26 ash kernel: eth0: may be hung last tx was 10457 ticks
Jun 18 19:38:26 ash kernel: eth0: state=0x7 transmit ring size=4096 
count=256 to_u
se=66 to_clean=59
Jun 18 19:38:26 ash kernel:  0: skb=00000000 dma=0 length=42 time=+29527 
watch=0
Jun 18 19:38:26 ash kernel:  1: skb=00000000 dma=0 length=98 time=+29527 
watch=1
Jun 18 19:38:26 ash kernel:  2: skb=00000000 dma=0 length=98 time=+28526 
watch=2
Jun 18 19:38:26 ash kernel:  3: skb=00000000 dma=0 length=98 time=+27525 
watch=3
Jun 18 19:38:26 ash kernel:  4: skb=00000000 dma=0 length=98 time=+26524 
watch=4
Jun 18 19:38:26 ash kernel:  5: skb=00000000 dma=0 length=42 time=+24528 
watch=5
Jun 18 19:38:26 ash kernel:  6: skb=00000000 dma=0 length=0 
time=+20324251 watch=7
Jun 18 19:38:26 ash kernel:  7: skb=00000000 dma=0 length=110 
time=+24510 watch=0
Jun 18 19:38:26 ash kernel:  8: skb=00000000 dma=0 length=0 
time=+20324251 watch=9
Jun 18 19:38:26 ash kernel:  9: skb=00000000 dma=0 length=110 
time=+24510 watch=0
Jun 18 19:38:26 ash kernel:  10: skb=00000000 dma=0 length=0 
time=+20324251 watch=
11
Jun 18 19:38:26 ash kernel:  11: skb=00000000 dma=0 length=110 
time=+24510 watch=0
Jun 18 19:38:26 ash kernel:  12: skb=00000000 dma=0 length=0 
time=+20324251 watch=
13
Jun 18 19:38:26 ash kernel:  13: skb=00000000 dma=0 length=110 
time=+24510 watch=0
Jun 18 19:38:26 ash kernel:  14: skb=00000000 dma=0 length=0 
time=+20324251 watch=
15
Jun 18 19:38:26 ash kernel:  15: skb=00000000 dma=0 length=110 
time=+24510 watch=0
Jun 18 19:38:26 ash kernel:  16: skb=00000000 dma=0 length=0 
time=+20324251 watch=
17
Jun 18 19:38:26 ash kernel:  17: skb=00000000 dma=0 length=257 
time=+24510 watch=0
Jun 18 19:38:26 ash kernel:  18: skb=00000000 dma=0 length=0 
time=+20324251 watch=
19
Jun 18 19:38:26 ash kernel:  19: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  20: skb=00000000 dma=0 length=0 
time=+20324251 watch=
21
Jun 18 19:38:26 ash kernel:  21: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  22: skb=00000000 dma=0 length=0 
time=+20324251 watch=
23
Jun 18 19:38:26 ash kernel:  23: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  24: skb=00000000 dma=0 length=0 
time=+20324251 watch=
25
Jun 18 19:38:26 ash kernel:  25: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  26: skb=00000000 dma=0 length=0 
time=+20324251 watch=
27
Jun 18 19:38:26 ash kernel:  27: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  28: skb=00000000 dma=0 length=0 
time=+20324251 watch=
29
Jun 18 19:38:26 ash kernel:  29: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  30: skb=00000000 dma=0 length=0 
time=+20324251 watch=
31
Jun 18 19:38:26 ash kernel:  31: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  32: skb=00000000 dma=0 length=0 
time=+20324251 watch=
33
Jun 18 19:38:26 ash kernel:  33: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  34: skb=00000000 dma=0 length=0 
time=+20324251 watch=
35
Jun 18 19:38:26 ash kernel:  35: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  36: skb=00000000 dma=0 length=0 
time=+20324251 watch=
37
Jun 18 19:38:26 ash kernel:  37: skb=00000000 dma=0 length=110 
time=+22510 watch=0
Jun 18 19:38:26 ash kernel:  38: skb=00000000 dma=0 length=1514 
time=+21082 watch=
38
Jun 18 19:38:26 ash kernel:  39: skb=00000000 dma=0 length=62 
time=+21082 watch=39
Jun 18 19:38:26 ash kernel:  40: skb=00000000 dma=0 length=0 
time=+20324251 watch=
41
Jun 18 19:38:26 ash kernel:  41: skb=00000000 dma=0 length=110 
time=+20510 watch=0
Jun 18 19:38:26 ash kernel:  42: skb=00000000 dma=0 length=0 
time=+20324251 watch=
43
Jun 18 19:38:26 ash kernel:  43: skb=00000000 dma=0 length=110 
time=+20510 watch=0
Jun 18 19:38:26 ash kernel:  44: skb=00000000 dma=0 length=0 
time=+20324251 watch=
45
Jun 18 19:38:26 ash kernel:  45: skb=00000000 dma=0 length=110 
time=+20510 watch=0
Jun 18 19:38:26 ash kernel:  46: skb=00000000 dma=0 length=0 
time=+20324251 watch=
47
Jun 18 19:38:26 ash kernel:  47: skb=00000000 dma=0 length=110 
time=+20510 watch=0
Jun 18 19:38:26 ash kernel:  48: skb=00000000 dma=0 length=0 
time=+20324251 watch=
49
Jun 18 19:38:26 ash kernel:  49: skb=00000000 dma=0 length=110 
time=+20510 watch=0
Jun 18 19:38:26 ash kernel:  50: skb=00000000 dma=0 length=1514 
time=+20081 watch=
50
Jun 18 19:38:26 ash kernel:  51: skb=00000000 dma=0 length=62 
time=+20081 watch=51
Jun 18 19:38:26 ash kernel:  52: skb=00000000 dma=0 length=1514 
time=+19080 watch=
52
Jun 18 19:38:26 ash kernel:  53: skb=00000000 dma=0 length=62 
time=+19080 watch=53
Jun 18 19:38:26 ash kernel:  54: skb=00000000 dma=0 length=1514 
time=+11459 watch=
54
Jun 18 19:38:26 ash kernel:  55: skb=00000000 dma=0 length=1514 
time=+11458 watch=
55
Jun 18 19:38:26 ash kernel:  56: skb=00000000 dma=0 length=82 
time=+11458 watch=56
Jun 18 19:38:26 ash kernel:  57: skb=00000000 dma=0 length=1514 
time=+10457 watch=
57
Jun 18 19:38:26 ash kernel:  58: skb=00000000 dma=0 length=1514 
time=+10457 watch=
58
Jun 18 19:38:26 ash kernel:  59: skb=f0740420 dma=934467074 length=82 
time=+10457
watch=59
Jun 18 19:38:26 ash kernel:  60: skb=d6e91420 dma=397015042 length=1514 
time=+9456
 watch=60
Jun 18 19:38:26 ash kernel:  61: skb=f07406a0 dma=935571458 length=1514 
time=+9456
 watch=61
Jun 18 19:38:26 ash kernel:  62: skb=f3fcde20 dma=26358274 length=82 
time=+9456 wa
tch=62
Jun 18 19:38:26 ash kernel:  63: skb=f0740ba0 dma=397012994 length=1514 
time=+8455
 watch=63
Jun 18 19:38:26 ash kernel:  64: skb=d6e914c0 dma=935573506 length=1514 
time=+8455
 watch=64
Jun 18 19:38:26 ash kernel:  65: skb=f0740600 dma=937204738 length=82 
time=+8455 w
atch=65
Jun 18 19:38:26 ash kernel:  66: skb=00000000 dma=0 length=0 
time=+20324251 watch=
0
<snip many duplicate lines>
Jun 18 19:38:26 ash kernel: eth0: link lost but ring is full
Jun 18 19:38:26 ash kernel: eth0: state=0x16 transmit ring size=4096 
count=256 to_
use=9 to_clean=2
Jun 18 19:38:26 ash kernel:  0: skb=00000000 dma=0 length=1514 time=+1 
watch=0
Jun 18 19:38:26 ash kernel:  1: skb=00000000 dma=0 length=1514 time=+1 
watch=1
Jun 18 19:38:26 ash kernel:  2: skb=f0740060 dma=26400258 length=82 
time=+1 watch=
2
Jun 18 19:38:26 ash kernel:  3: skb=f0740ec0 dma=594843650 length=1514 
time=+1 wat
ch=3
Jun 18 19:38:26 ash kernel:  4: skb=d6e91a60 dma=594841602 length=1514 
time=+1 wat
ch=4
Jun 18 19:38:26 ash kernel:  5: skb=f0740560 dma=937203714 length=82 
time=+1 watch
=5
Jun 18 19:38:26 ash kernel:  6: skb=d6e919c0 dma=426745858 length=1514 
time=+1 wat
ch=6
Jun 18 19:38:26 ash kernel:  7: skb=d6e91880 dma=426747906 length=1514 
time=+1 wat
ch=7
Jun 18 19:38:26 ash kernel:  8: skb=f65ca920 dma=934469122 length=82 
time=+1 watch
=8
Jun 18 19:38:26 ash kernel:  9: skb=00000000 dma=0 length=0 
time=+20324352 watch=0
Jun 18 19:38:26 ash kernel:  10: skb=00000000 dma=0 length=0 
time=+20324352 watch=
0
<snip many many lines>
=0
Jun 18 19:38:26 ash kernel:  255: skb=00000000 dma=0 length=0 
time=+20324352 watch


David
