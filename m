From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Fri, 24 Apr 2009 12:16:08 -0400
Message-ID: <49F1E5C8.7010303@myri.com>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1957 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755368AbZDXQRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 12:17:04 -0400
In-Reply-To: <20090424054557.GA24575@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Apr 22, 2009 at 11:37:24AM -0400, Andrew Gallatin wrote:
>> I booted the sender into a kernel.org 2.6.18.2 so as to try to have  
>> results as close to yours as possible (I was running 2.6.22 on the
>> sender before).
> 
> OK I've got my hands on a myricom card.  I've tested it using the
> same 2.6.18 sender that I used against the eariler cxgb3 test.
> I wasn't able to discern any significant deviations between LRO
> and GRO.
> 
> Unfortunately it seems that this machine is a little too fast
> so even with the IRQ bound to a single CPU it's way overspeced
> for 10GbE:
> 
>     Idle at 10Gb IRQ rate	soaker IRQ rate soaker throuput
> GRO 43-45	 14700		13300		7933
> LRO 43-45	 14700		13300		7943
> 
> But even with the soaker running they seem to be neck and neck.

 From what I can tell,  CPU utilization is only broken when a CPU is
otherwise idle, so it should be accurate when you bind the IRQ and the
netserver to the same CPU.   Here are results from an older, slower
core-2 Xeon with a 4MB L2 cache:

processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 15
model name      : Intel(R) Xeon(R) CPU            5150  @ 2.66GHz
stepping        : 6
cpu MHz         : 2659.916
cache size      : 4096 KB
physical id     : 0
siblings        : 1
core id         : 0
cpu cores       : 2
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe 
syscall nx lm constant_tsc arch_perfmon pebs bts rep_good pni dtes64 
monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca lahf_lm tpr_shadow
bogomips        : 5319.83
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

The Xeon was running net-next, had DCA enabled, ioatdma disabled for
TCP (CONFIG_NET_DMA is not set).  The sender was the weak athlon64,
running 2.6.22.

LRO, no soaker: (13,200 intrs/sec)
Recv   Send    Send                          Utilization       Service 
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local 
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
  87380  65536  65536    60.02      9469.74   17.44    13.31    0.302 
0.461

LRO, soaker: (6,500 intrs/sec)

  87380  65536  65536    60.06      3955.74   7.11     25.02    0.294 
2.072

GRO, no soaker, (13,200 intrs/sec)
  87380  65536  65536    60.02      9467.90   16.76    14.16    0.290 
0.490

GRO, soaker: (6,500 intrs/sec)
  87380  65536  65536    60.02      3774.88   6.20     25.01    0.269 
2.171


These results are indeed quite close, so the performance problem seems
isolated to AMD CPUS, and perhaps due to the smaller caches.
Do you have any AMD you can use as a receiver?

Note that the GRO results were still obtained by (bogusly) setting
CHECKSUM_UNNECESSARY.  I tried to use your patch, and I see
terrible performance. Netperf shows between 1Gb/s to 2Gb/s (compared
to 5Gb/s with GRO disabled).  I don't see bad checksums in netstat
on the receiver, but it *feels* like something like that.

Here's a diff of netstat -st taken on the sender before and after
a 5 second netperf:
2c2
<     157 active connections openings
---
 >     159 active connections openings
7,9c7,9
<     31465934 segments received
<     72887021 segments send out
<     679 segments retransmited
---
 >     32184827 segments received
 >     73473546 segments send out
 >     698 segments retransmited
16c16
<     4596 packets directly queued to recvmsg prequeue.
---
 >     4603 packets directly queued to recvmsg prequeue.
18,21c18,21
<     15928 packets header predicted
<     18100148 acknowledgments not containing data received
<     13351873 predicted acknowledgments
<     343 times recovered from packet loss due to SACK data
---
 >     15930 packets header predicted
 >     18464095 acknowledgments not containing data received
 >     13706813 predicted acknowledgments
 >     365 times recovered from packet loss due to SACK data
23,25c23,25
<     53 congestion windows fully recovered
<     221 congestion windows partially recovered using Hoe heuristic
<     TCPDSACKUndo: 268
---
 >     60 congestion windows fully recovered
 >     228 congestion windows partially recovered using Hoe heuristic
 >     TCPDSACKUndo: 281
27,28c27,28
<     584 fast retransmits
<     93 forward retransmits
---
 >     597 fast retransmits
 >     99 forward retransmits
30c30
<     674 DSACKs received
---
 >     693 DSACKs received

And on the receiver (whose netstat is confused, and cannot read ext 
stats in a net-next kernel):
diff /tmp/a /tmp/b
3c3
<     12 passive connection openings
---
 >     14 passive connection openings
7,8c7,8
<     3776478 segments received
<     3775846 segments send out
---
 >     4495385 segments received
 >     4494747 segments send out



This was using a net-next pulled 1/2 hour ago.  The only patch was your 
GRO patch applied to myri10ge.  Do you have some other local patch
which might be helping you?

Drew
