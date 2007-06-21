From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: FSCKED clock sources WAS(Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 21 Jun 2007 20:45:38 +0400
Message-ID: <20070621164538.GA29001@2ka.mipt.ru>
References: <20070619140038.GA13629@2ka.mipt.ru> <1182270529.4968.73.camel@localhost> <18040.5105.715624.286924@robur.slu.se> <20070619.152801.99185860.davem@davemloft.net> <1182441257.5017.48.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, Robert.Olsson@data.slu.se,
	krkumar2@in.ibm.com, gaagaan@gmail.com, netdev@vger.kernel.org,
	rick.jones2@hp.com, sri@us.ibm.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57386 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755197AbXFUQv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 12:51:26 -0400
Content-Disposition: inline
In-Reply-To: <1182441257.5017.48.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 21, 2007 at 11:54:17AM -0400, jamal (hadi@cyberus.ca) wrote:
> Evgeniy, did you sync on the batching case with the git tree?

My tree contains following commits:

Latest mainline commit: fa490cfd15d7ce0900097cc4e60cfd7a76381138
Latest batch commit: 9b8cc32088abfda8be7f394cfd5ee6ac694da39c

> Can you describe your hardware in /proc/cpuinfo and /proc/interupts?

Sure.
cpuinfo:
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 15
model name      : AMD Athlon(tm) 64 Processor 3500+
stepping        : 0
cpu MHz         : 2210.092
cache size      : 512 KB
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext lm
3dnowext 3dnow up
bogomips        : 4423.20
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp

interrupts:
CPU0       
0:    1668864   IO-APIC-edge      timer
1:         78   IO-APIC-edge      i8042
8:          0   IO-APIC-edge      rtc
9:          0   IO-APIC-fasteoi   acpi
12:        102   IO-APIC-edge      i8042
14:        465   IO-APIC-edge      ide0
18:     774515   IO-APIC-fasteoi   eth1
22:          0   IO-APIC-fasteoi   sata_nv
23:       5068   IO-APIC-fasteoi   sata_nv
NMI:          0 
LOC:    1668914 
ERR:          0

I pulled the latest version recently and started netperf test - both
netperf on sending (batching) machine and netserver on receiver takes
about 16-25% of CPU time, which is likely a bug.
With 4096 block it is 819 mbit/sec, which is slightly more than mainline
result, but I can not say that it is noticebly higher than a noise rate.

I did not check CPU usage time of the previous reelases, but receiving
netserver was always around 15-16%.

Here is pktgen result:

Params: count 1000000  min_pkt_size: 60  max_pkt_size: 60 min_batch 0
     frags: 0  delay: 0  clone_skb: 1  ifname: eth1
     flows: 0 flowlen: 0
     dst_min: 192.168.4.81  dst_max: 
     src_min:   src_max: 
     src_mac: 00:0E:0C:B8:63:0A  dst_mac: 00:17:31:9A:E5:BE
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags: 
Current:
     pkts-sofar: 1000000  errors: 0
     started: 1182456838614560us  stopped: 1182456842533487us idle: 15us alloc 3780137us txt 130388us
     seq_num: 1000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x3000a8c0  cur_daddr: 0x5104a8c0
     cur_udp_dst: 9  cur_udp_src: 9
     flows: 0
Result: OK: T3918927(U3918912+I15+A3780137+T130388) usec, P1000000 TE8511TS1(B60,-1frags)
  255171pps 122Mb/sec (122482080bps) errors: 0

There is no cloning.
When there is no cloning, mainline shows 112 Mb/sec, which is less, but
when there are 10k clones results are:
mainline: 	469857pps 225Mb/sec
latest batch:	246089pps 118Mb/sec

So, that is definitely a sign, that batching has some issues with skb
reusage.

> cheers,
> jamal


-- 
	Evgeniy Polyakov
