From: David Greaves <david@dgreaves.com>
Subject: Re: e1000 driver (NETDEV WATCHDOG + page allocation failure)
Date: Mon, 15 Nov 2004 16:54:06 +0000
Message-ID: <4198DF2E.3030301@dgreaves.com>
References: <468F3FDA28AA87429AD807992E22D07E02C6625A@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E02C6625A@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Ganesh

Apologies for not responding sooner - you know how it is.

I've recently had a chance to update the BIOS on my motherboard as you 
suggested and it has made a considerable difference.
However I am still seeing some issues and wouldn't consider the system 
useable yet :(

Given that version 2.6.9 came out I thought it would be worth upgrading 
to grab the new patches I saw go through; so now I'm running 2.6.9

Light usage with a standard 1500 MTU now works most of the time (ie ping 
-f works fine, normal ssh usage and nfs etc)
I can't test jumbo packets as mtu 9000 causes immediate page allocation 
failures:
ifconfig: page allocation failure. order:3, mode:0x20
on my other (otherwise stable) box.

Even on mtu=1500 I do however have problems with sustained throughput. 
The reason I got the cards was to make video-editing over the network 
quicker so this is a real problem.

At the moment I'm using rsync to transfer a few hundred Gb of data.
If I use ssh as the shell tunnel then the high cpu bottlenecks the data 
to 10Mb/s
I use --rsh=rsh to ensure that there's minimal cpu usage the throughput 
goes up to ~21Mb/s (the remote server is capable of ~40Mb/s raw 
filesystem I/O but it still has a slow cpu)

At this throughput my workstation's e1000 appears to begin to fail.

Some tests:
# ping -f cuf
PING cuf (10.0.1.3): 56 data bytes
..
--- cuf ping statistics ---
1483792 packets transmitted, 1483791 packets received, 0% packet loss
round-trip min/avg/max = 0.0/0.6/3074.8 ms
so that works fine (whereas pre-BIOS update I used to have problems)

a more realistic activity:
rsync --rsh="rsh" --progress -a /scratch/* cu:/huge/myth/
1524072448 81% 22.84MB/s 0:00:14
but stalls (every 10-15 seconds) down to
95715328 5% 2.77MB/s 0:01:04

When the stall happens, the e1000_tx_timeout_task() log (extract below) 
is produced.
Normally (with R/TxDescriptors=256) the start of the log is 'lost' by 
syslogd so the version below is with T/RXDescriptors=80.

I've played with a few variables and found this set gave me better 
behaviour with a stall every minute or so rather than every few seconds)
# modprobe e1000 InterruptThrottleRate=600 FlowControl=3 
TxDescriptors=80 RxDescriptors=80


David

Venkatesan, Ganesh wrote:

>David:
>
>Could you check the BIOS version on your system? We were able to
>reproduce some of your performance issues on a machine with BIOS version
>1.03. Upgrading to version 1.10 resolved all issues. The machine we used
>is:
>Athlon 1800 with an Aopen AK77-KT600N motherboard.
>
>Please let us know what you find.
>
>Thanks,
>Ganesh.
>  
>
Nov 14 18:05:05 ash kernel: NETDEV WATCHDOG: eth0: transmit timed out 
after 5000 jiffies
Nov 14 18:05:05 ash kernel: eth0: transmit timeout from queuing
Nov 14 18:05:05 ash kernel: eth0: state=0x7 transmit ring size=4096 
count=80 to_use=6 to_clean=10
Nov 14 18:05:05 ash kernel: 0: skb=00000000 dma=0 length=1514 
time=+20656 watch=1
Nov 14 18:05:05 ash kernel: 1: skb=dffbf420 dma=747090014 length=1514 
time=+9308 watch=2
Nov 14 18:05:05 ash kernel: 2: skb=00000000 dma=0 length=1514 
time=+20656 watch=3
Nov 14 18:05:05 ash kernel: 3: skb=eef81420 dma=370819166 length=1514 
time=+9308 watch=4
Nov 14 18:05:05 ash kernel: 4: skb=00000000 dma=0 length=1514 
time=+20656 watch=5
Nov 14 18:05:05 ash kernel: 5: skb=dffbf6a0 dma=410486878 length=1514 
time=+9308 watch=6
Nov 14 18:05:05 ash kernel: 6: skb=00000000 dma=0 length=1514 
time=+20656 watch=7
Nov 14 18:05:05 ash kernel: 7: skb=00000000 dma=0 length=1514 time=+9313 
watch=8
Nov 14 18:05:05 ash kernel: 8: skb=00000000 dma=0 length=1514 
time=+20656 watch=9
Nov 14 18:05:05 ash kernel: 9: skb=00000000 dma=0 length=1514 time=+9313 
watch=10
Nov 14 18:05:05 ash kernel: 10: skb=00000000 dma=0 length=1514 
time=+20656 watch=11
Nov 14 18:05:05 ash kernel: 11: skb=dffbf9c0 dma=1015185502 length=1514 
time=+9313 watch=12
Nov 14 18:05:05 ash kernel: 12: skb=00000000 dma=0 length=1514 
time=+20656 watch=13
Nov 14 18:05:05 ash kernel: 13: skb=b94a42e0 dma=678299742 length=1514 
time=+9313watch=14
Nov 14 18:05:05 ash kernel: 14: skb=00000000 dma=0 length=1514 
time=+20656 watch=15
Nov 14 18:05:05 ash kernel: 15: skb=dffbf740 dma=244232286 length=1514 
time=+9313watch=16
Nov 14 18:05:05 ash kernel: 16: skb=00000000 dma=0 length=1514 
time=+20656 watch=17
Nov 14 18:05:05 ash kernel: 17: skb=dffbf880 dma=244234334 length=1514 
time=+9313watch=18
Nov 14 18:05:05 ash kernel: 18: skb=00000000 dma=0 length=982 
time=+20654 watch=19
Nov 14 18:05:05 ash kernel: 19: skb=e054f560 dma=543977566 length=1514 
time=+9313watch=19
Nov 14 18:05:05 ash kernel: 20: skb=00000000 dma=0 length=1514 
time=+20669 watch=21
Nov 14 18:05:05 ash kernel: 21: skb=efd22ce0 dma=543979614 length=1514 
time=+9313watch=22
Nov 14 18:05:05 ash kernel: 22: skb=00000000 dma=0 length=1514 
time=+20669 watch=23
Nov 14 18:05:05 ash kernel: 23: skb=eef81740 dma=621445214 length=1514 
time=+9313watch=24
Nov 14 18:05:05 ash kernel: 24: skb=00000000 dma=0 length=1514 
time=+20669 watch=25
Nov 14 18:05:05 ash kernel: 25: skb=dffbfd80 dma=621447262 length=1514 
time=+9313watch=26
Nov 14 18:05:05 ash kernel: 26: skb=00000000 dma=0 length=1514 
time=+20669 watch=27
Nov 14 18:05:05 ash kernel: 27: skb=b94a4920 dma=96651358 length=1514 
time=+9313 watch=28
Nov 14 18:05:05 ash kernel: 28: skb=00000000 dma=0 length=1514 
time=+20669 watch=29
Nov 14 18:05:05 ash kernel: 29: skb=ef3d27e0 dma=212396126 length=1514 
time=+9312watch=30
Nov 14 18:05:05 ash kernel: 30: skb=00000000 dma=0 length=1514 
time=+20669 watch=31
Nov 14 18:05:05 ash kernel: 31: skb=e054f420 dma=212394078 length=1514 
time=+9312watch=32
Nov 14 18:05:05 ash kernel: 32: skb=00000000 dma=0 length=1514 
time=+20669 watch=33
Nov 14 18:05:05 ash kernel: 33: skb=ef3d26a0 dma=471775326 length=1514 
time=+9312watch=34
Nov 14 18:05:05 ash kernel: 34: skb=00000000 dma=0 length=1514 
time=+20669 watch=35
Nov 14 18:05:05 ash kernel: 35: skb=b88a0880 dma=471773278 length=1514 
time=+9312watch=36
Nov 14 18:05:05 ash kernel: 36: skb=00000000 dma=0 length=1514 
time=+20669 watch=37
Nov 14 18:05:05 ash kernel: 37: skb=c9e26380 dma=301906014 length=1514 
time=+9312watch=38
Nov 14 18:05:05 ash kernel: 38: skb=00000000 dma=0 length=1514 
time=+20668 watch=39
Nov 14 18:05:05 ash kernel: 39: skb=efd227e0 dma=301903966 length=1514 
time=+9312watch=40
Nov 14 18:05:05 ash kernel: 40: skb=00000000 dma=0 length=1514 
time=+20668 watch=41
Nov 14 18:05:05 ash kernel: 41: skb=c95a2240 dma=292812894 length=1514 
time=+9312watch=42
Nov 14 18:05:05 ash kernel: 42: skb=00000000 dma=0 length=1514 
time=+20668 watch=43
Nov 14 18:05:05 ash kernel: 43: skb=eef81100 dma=292810846 length=1514 
time=+9312watch=44
Nov 14 18:05:05 ash kernel: 44: skb=00000000 dma=0 length=1514 
time=+20668 watch=45
Nov 14 18:05:05 ash kernel: 45: skb=c9e26f60 dma=412209246 length=1514 
time=+9312watch=46
Nov 14 18:05:05 ash kernel: 46: skb=00000000 dma=0 length=1514 
time=+20668 watch=47
Nov 14 18:05:05 ash kernel: 47: skb=b88a07e0 dma=410490974 length=1514 
time=+9312watch=48
Nov 14 18:05:05 ash kernel: 48: skb=00000000 dma=0 length=1514 
time=+20668 watch=49
Nov 14 18:05:05 ash kernel: 49: skb=efd22420 dma=471769182 length=1514 
time=+9312watch=50
Nov 14 18:05:05 ash kernel: 50: skb=00000000 dma=0 length=1394 
time=+20668 watch=51
Nov 14 18:05:05 ash kernel: 51: skb=e054fec0 dma=471771230 length=994 
time=+9312 watch=52
Nov 14 18:05:05 ash kernel: 52: skb=00000000 dma=0 length=78 time=+20656 
watch=53
Nov 14 18:05:05 ash kernel: 53: skb=c9e26560 dma=139356254 length=1514 
time=+9312watch=54
Nov 14 18:05:05 ash kernel: 54: skb=00000000 dma=0 length=1514 
time=+20656 watch=55
Nov 14 18:05:05 ash kernel: 55: skb=eef817e0 dma=410484830 length=1514 
time=+9312watch=56
Nov 14 18:05:05 ash kernel: 56: skb=00000000 dma=0 length=1514 
time=+20656 watch=57
Nov 14 18:05:05 ash kernel: 57: skb=e054f240 dma=410488926 length=1514 
time=+9312watch=58
Nov 14 18:05:05 ash kernel: 58: skb=00000000 dma=0 length=1514 
time=+20656 watch=59
Nov 14 18:05:05 ash kernel: 59: skb=ef3d2b00 dma=543973470 length=1514 
time=+9310watch=60
Nov 14 18:05:05 ash kernel: 60: skb=00000000 dma=0 length=1514 
time=+20656 watch=61
Nov 14 18:05:05 ash kernel: 61: skb=dffbfec0 dma=747087966 length=1514 
time=+9310watch=62
Nov 14 18:05:05 ash kernel: 62: skb=00000000 dma=0 length=1514 
time=+20656 watch=63
Nov 14 18:05:05 ash kernel: 63: skb=ef3d2560 dma=747085918 length=1514 
time=+9310watch=64
Nov 14 18:05:05 ash kernel: 64: skb=00000000 dma=0 length=1514 
time=+20656 watch=65
Nov 14 18:05:05 ash kernel: 65: skb=b94a4100 dma=1013049438 length=1514 
time=+9310 watch=66
Nov 14 18:05:05 ash kernel: 66: skb=00000000 dma=0 length=1514 
time=+20656 watch=67
Nov 14 18:05:05 ash kernel: 67: skb=c95a21a0 dma=323840094 length=1514 
time=+9310watch=68
Nov 14 18:05:05 ash kernel: 68: skb=00000000 dma=0 length=1514 
time=+20656 watch=69
Nov 14 18:05:05 ash kernel: 69: skb=e054f2e0 dma=572936286 length=1514 
time=+9310watch=70
Nov 14 18:05:05 ash kernel: 70: skb=00000000 dma=0 length=1514 
time=+20656 watch=71
Nov 14 18:05:05 ash kernel: 71: skb=b94a4060 dma=895561822 length=1514 
time=+9310watch=72
Nov 14 18:05:05 ash kernel: 72: skb=00000000 dma=0 length=1514 
time=+20656 watch=73
Nov 14 18:05:05 ash kernel: 73: skb=b94a4880 dma=96649310 length=1514 
time=+9310 watch=74
Nov 14 18:05:05 ash kernel: 74: skb=00000000 dma=0 length=1514 
time=+20656 watch=75
Nov 14 18:05:05 ash kernel: 75: skb=b88a0380 dma=512022622 length=1514 
time=+9310watch=76
Nov 14 18:05:05 ash kernel: 76: skb=00000000 dma=0 length=1514 
time=+20656 watch=77
Nov 14 18:05:05 ash kernel: 77: skb=b94a4380 dma=1013047390 length=1514 
time=+9310 watch=78
Nov 14 18:05:05 ash kernel: 78: skb=00000000 dma=0 length=1514 
time=+20656 watch=79
Nov 14 18:05:05 ash kernel: 79: skb=b88a0100 dma=1053198430 length=1514 
time=+9310 watch=0
Nov 14 18:05:08 ash kernel: e1000: eth0: e1000_watchdog: NIC Link is Up 
1000 Mbps Full Duplex
