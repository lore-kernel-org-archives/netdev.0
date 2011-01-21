From: "juice" <juice@swagman.org>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Fri, 21 Jan 2011 13:44:51 +0200
Message-ID: <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Loke, Chetan" <Chetan.Loke@netscout.com>,
	"Jon Zhou" <jon.zhou@jdsu.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:20781 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314Ab1AULpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 06:45:14 -0500
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Jon Zhou
>> Sent: December 23, 2010 3:58 AM
>> To: juice@swagman.org; Eric Dumazet; Stephen Hemminger;
>> netdev@vger.kernel.org
>> Subject: RE: Using ethernet device as efficient small packet generator
>>
>>
>> At another old kernel(2.6.16) with tg3 and bnx2 1G NIC,XEON E5450, I
>> only got 490K pps(it is about 300Mbps,30% GE), I think the reason is
>> multiqueue unsupported in this kernel.
>>
>> I will do a test with 1Gb nic on the new kernel later.
>>
>
>
> I can hit close to 1M pps(first time every time) w/ a 64-byte payload on
> my VirtualMachine(running 2.6.33) via vmxnet3 vNIC -
>
>
> [root@localhost ~]# cat /proc/net/pktgen/eth2
> Params: count 0  min_pkt_size: 60  max_pkt_size: 60
>      frags: 0  delay: 0  clone_skb: 0  ifname: eth2
>      flows: 0 flowlen: 0
>      queue_map_min: 0  queue_map_max: 0
>      dst_min: 192.168.222.2  dst_max:
>         src_min:   src_max:
>      src_mac: 00:50:56:b1:00:19 dst_mac: 00:50:56:c0:00:3e
>      udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
>      src_mac_count: 0  dst_mac_count: 0
>      Flags:
> Current:
>      pkts-sofar: 59241012  errors: 0
>      started: 1898437021us  stopped: 1957709510us idle: 9168us
>      seq_num: 59241013  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
>      cur_saddr: 0x0  cur_daddr: 0x2dea8c0
>      cur_udp_dst: 9  cur_udp_src: 9
>      cur_queue_map: 0
>      flows: 0
> Result: OK: 59272488(c59263320+d9168) nsec, 59241012 (60byte,0frags)
>   999468pps 479Mb/sec (479744640bps) errors: 0
>
>
>
> Chetan
>


Hi again.

It has been a while since last time I got to be able to test this
again, as there have been some other matters at hand.
However, now I managed to rerun my tests in several different kernels.

I am using now a PCIe Intel e1000e card, that should be able to handle
the needed traffic amount.

The statistics that I get are as follows:

kernel 2.6.32-27 (ubuntu 10.10 default)
    pktgen:           750064pps 360Mb/sec (360030720bps)
    AX4000 analyser:  Total bitrate:             383.879 MBits/s
                      Bandwidth:                 38.39% GE
                      Average packet intereval:  1.33 us

kernel 2.6.37 (latest stable from kernel.org)
    pktgen:           786848pps 377Mb/sec (377687040bps)
    AX4000 analyser:  Total bitrate:             402.904 MBits/s
                      Bandwidth:                 40.29% GE
                      Average packet intereval:  1.27 us

kernel 2.6.38-rc1 (latest from kernel.org)
    pktgen:           795297pps 381Mb/sec (381742560bps)
    AX4000 analyser:  Total bitrate:             407.117 MBits/s
                      Bandwidth:                 40.72% GE
                      Average packet intereval:  1.26 us


In every case I have set the IRQ affinity of eth1 to CPU0 and started
the test running in kpktgend_0.

The complete data of my measurements follows in the end of this post.

It looks like the small packet sending effiency of the ethernet driver
is improving all the time, albeit quite slowly.

Now, I would be intrested in knowing whether it is indeed possible to
increase the sending rate near full 1GE capacity with the current
ethernet card I am using or do I have here a hardware limitation here?

I recall hearing that there are some enhanced versions of the e1000
network card, such that have been geared towards higher performance
at the expense of some functionality or general system effiency.
Can anybody point me how to do that?

As I stated before, quoting myself:

> Which do you suppose is the reason for poor performance on my setup,
> is it lack of multiqueue HW in the GE NIC's I am using or is it lack
> of multiqueue support in the kernel (2.6.32) that I am using?
>
> Is multiqueue really necessary to achieve the full 1GE saturation, or
> is it only needed on 10GE NIC's?
>
> As I understand multiqueue is useful only if there are lots of CPU cores
> to run, each handling one queue.
>
> The application I am thinking of, preloading a packet sequence into
> kernel from userland application and then starting to send from buffer
> propably does not benefit so much from many cores, it would be enough
> that one CPU would handle the sending and other core(s) would handle
> other tasks.

Yours, Jussi Ohenoja


*** Measurement details follows ***


root@d8labralinux:/var/home/juice# lspci -vvv -s 04:00.0
04:00.0 Ethernet controller: Intel Corporation 82572EI Gigabit Ethernet
Controller (Copper) (rev 06)
	Subsystem: Intel Corporation Device 1082
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f3cc0000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at f3ce0000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at cce0 [size=32]
	Expansion ROM at f3d00000 [disabled] [size=128K]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0
Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <4us, L1
<64us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
	Capabilities: [100] Advanced Error Reporting <?>
	Capabilities: [140] Device Serial Number b1-e5-7c-ff-ff-21-1b-00
	Kernel modules: e1000e

root@d8labralinux:/var/home/juice# ethtool eth1
Settings for eth1:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  Not reported
	Link partner advertised pause frame use: No
	Link partner advertised auto-negotiation: No
	Speed: 1000Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: on
	Supports Wake-on: pumbag
	Wake-on: d
	Current message level: 0x00000001 (1)
	Link detected: yes





2.6.38-rc1
----------

dmesg:

[  195.685655] e1000e: Intel(R) PRO/1000 Network Driver - 1.2.20-k2
[  195.685658] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[  195.685677] e1000e 0000:04:00.0: Disabling ASPM  L1
[  195.685690] e1000e 0000:04:00.0: PCI INT A -> GSI 16 (level, low) ->
IRQ 16
[  195.685707] e1000e 0000:04:00.0: setting latency timer to 64
[  195.685852] e1000e 0000:04:00.0: irq 69 for MSI/MSI-X
[  195.869917] e1000e 0000:04:00.0: eth1: (PCI Express:2.5GB/s:Width x1)
00:1b:21:7c:e5:b1
[  195.869921] e1000e 0000:04:00.0: eth1: Intel(R) PRO/1000 Network
Connection
[  195.870006] e1000e 0000:04:00.0: eth1: MAC: 1, PHY: 4, PBA No: D50861-006
[  196.017285] e1000e 0000:04:00.0: irq 69 for MSI/MSI-X
[  196.073144] e1000e 0000:04:00.0: irq 69 for MSI/MSI-X
[  196.073630] ADDRCONF(NETDEV_UP): eth1: link is not ready
[  198.746000] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: None
[  198.746162] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[  209.564433] eth1: no IPv6 routers present


pktgen:

Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 1  ifname: eth1
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 10.10.11.2  dst_max:
        src_min:   src_max:
     src_mac: 00:1b:21:7c:e5:b1 dst_mac: 00:04:23:08:91:dc
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 10000000  errors: 0
     started: 77203892067us  stopped: 77216465982us idle: 1325us
     seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x0  cur_daddr: 0x20b0a0a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 12573914(c12572589+d1325) nsec, 10000000 (60byte,0frags)
  795297pps 381Mb/sec (381742560bps) errors: 0


AX4000 analyser:

   Total bitrate:             407.117 MBits/s
   Bandwidth:                 40.72% GE
   Average packet intereval:  1.26 us






2.6.37
------


dmesg:

[ 1810.959907] e1000e: Intel(R) PRO/1000 Network Driver - 1.2.7-k2
[ 1810.959909] e1000e: Copyright (c) 1999 - 2010 Intel Corporation.
[ 1810.959928] e1000e 0000:04:00.0: Disabling ASPM  L1
[ 1810.959942] e1000e 0000:04:00.0: PCI INT A -> GSI 16 (level, low) ->
IRQ 16
[ 1810.959961] e1000e 0000:04:00.0: setting latency timer to 64
[ 1810.960103] e1000e 0000:04:00.0: irq 66 for MSI/MSI-X
[ 1811.137269] e1000e 0000:04:00.0: eth1: (PCI Express:2.5GB/s:Width x1)
00:1b:21:7c:e5:b1
[ 1811.137272] e1000e 0000:04:00.0: eth1: Intel(R) PRO/1000 Network
Connection
[ 1811.137358] e1000e 0000:04:00.0: eth1: MAC: 1, PHY: 4, PBA No: d50861-006
[ 1811.286173] e1000e 0000:04:00.0: irq 66 for MSI/MSI-X
[ 1811.342065] e1000e 0000:04:00.0: irq 66 for MSI/MSI-X
[ 1811.342575] ADDRCONF(NETDEV_UP): eth1: link is not ready
[ 1814.010736] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: None
[ 1814.010949] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[ 1824.082148] eth1: no IPv6 routers present


pktgen:

Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 1  ifname: eth1
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 10.10.11.2  dst_max:
        src_min:   src_max:
     src_mac: 00:1b:21:7c:e5:b1 dst_mac: 00:04:23:08:91:dc
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 10000000  errors: 0
     started: 265936151us  stopped: 278645077us idle: 1651us
     seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x0  cur_daddr: 0x20b0a0a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 12708925(c12707274+d1651) nsec, 10000000 (60byte,0frags)
  786848pps 377Mb/sec (377687040bps) errors: 0


AX4000 analyser:

   Total bitrate:             402.904 MBits/s
   Bandwidth:                 40.29% GE
   Average packet intereval:  1.27 us






2.6.32-27
---------


dmesg:

[    2.178800] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
[    2.178802] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[    2.178854] e1000e 0000:04:00.0: PCI INT A -> GSI 16 (level, low) ->
IRQ 16
[    2.178887] e1000e 0000:04:00.0: setting latency timer to 64
[    2.179039] e1000e 0000:04:00.0: irq 53 for MSI/MSI-X
[    2.360700] 0000:04:00.0: eth1: (PCI Express:2.5GB/s:Width x1)
00:1b:21:7c:e5:b1
[    2.360702] 0000:04:00.0: eth1: Intel(R) PRO/1000 Network Connection
[    2.360787] 0000:04:00.0: eth1: MAC: 1, PHY: 4, PBA No: d50861-006
[    9.551486] e1000e 0000:04:00.0: irq 53 for MSI/MSI-X
[    9.607309] e1000e 0000:04:00.0: irq 53 for MSI/MSI-X
[    9.607876] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   12.448302] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: None
[   12.448544] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   23.068498] eth1: no IPv6 routers present


pktgen:

Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 1  ifname: eth1
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 10.10.11.2  dst_max:
        src_min:   src_max:
     src_mac: 00:1b:21:7c:e5:b1 dst_mac: 00:04:23:08:91:dc
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 10000000  errors: 0
     started: 799760010us  stopped: 813092189us idle: 1314us
     seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x0  cur_daddr: 0x20b0a0a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 13332178(c13330864+d1314) nsec, 10000000 (60byte,0frags)
  750064pps 360Mb/sec (360030720bps) errors: 0


AX4000 analyser:

   Total bitrate:             383.879 MBits/s
   Bandwidth:                 38.39% GE
   Average packet intereval:  1.33 us




root@d8labralinux:/var/home/juice/pkt_test# cat ./pktgen_conf
#!/bin/bash

#modprobe pktgen

function pgset() {
  local result
  echo $1 > $PGDEV
  result=`cat $PGDEV | fgrep "Result: OK:"`
  if [ "$result" = "" ]; then
    cat $PGDEV | fgrep Result:
  fi
}

function pg() {
  echo inject > $PGDEV
  cat $PGDEV
}

# Config Start Here
-----------------------------------------------------------

# thread config
# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
PGDEV=/proc/net/pktgen/kpktgend_0
echo "Removing all devices"
pgset "rem_device_all"
PGDEV=/proc/net/pktgen/kpktgend_1
pgset "rem_device_all"

PGDEV=/proc/net/pktgen/kpktgend_0
echo "Adding eth1"
pgset "add_device eth1"
#echo "Setting max_before_softirq 10000"
#pgset "max_before_softirq 10000"

# device config
# ipg is inter packet gap. 0 means maximum speed.
CLONE_SKB="clone_skb 1"
# NIC adds 4 bytes CRC
PKT_SIZE="pkt_size 60"
# COUNT 0 means forever
#COUNT="count 0"
COUNT="count 10000000"
IPG="delay 0"
PGDEV=/proc/net/pktgen/eth1
echo "Configuring $PGDEV"
pgset "$COUNT"
pgset "$CLONE_SKB"
pgset "$PKT_SIZE"
pgset "$IPG"
pgset "dst 10.10.11.2"
pgset "dst_mac 00:04:23:08:91:dc"
pgset "queue_map_min 0"

# Time to run
PGDEV=/proc/net/pktgen/pgctrl
echo "Running... ctrl^C to stop"
pgset "start"
echo "Done"

# Result can be vieved in /proc/net/pktgen/eth1




