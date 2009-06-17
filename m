From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Wed, 17 Jun 2009 16:07:30 +0800
Message-ID: <20090617080730.GA24410@gondor.apana.org.au>
References: <20090529162312.GA5191@neterion.com> <20090610054449.GB16984@gondor.apana.org.au> <20090612160926.GA4290@neterion.com> <20090612.164833.35888001.davem@davemloft.net> <20090616163547.GC5013@neterion.com> <20090616163856.GA17318@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <ben.lahaise@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58035 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751727AbZFQIHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 04:07:37 -0400
Content-Disposition: inline
In-Reply-To: <20090616163856.GA17318@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2009 at 02:38:56AM +1000, Herbert Xu wrote:
> 
> I'm hoping to get onto this tomorrow.  I think there's definitely
> something broken because there's no way GRO should be slower than
> GRO off.  Slightly slower than LRO perhaps but surely not worse than
> not merging at all :)

OK, I'm seeing the opposite :)

[root@perf21 ~]# netperf -H 172.17.10.22
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.10.22 (172.17.10.22) port 0 AF_INET : spin interval : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    9280.04
[root@perf21 ~]# netperf -H 172.17.10.22
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.10.22 (172.17.10.22) port 0 AF_INET : spin interval : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    6224.12
[root@perf21 ~]# 

The corresponding commands on the receiver:

[root@perf22 ~]# ./ethtool -k eth0
Offload parameters for eth0:
Cannot get device flags: Operation not supported
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
udp fragmentation offload: off
generic segmentation offload: on
generic receive offload: on
large receive offload: off
[root@perf22 ~]# ./ethtool -K eth0 gro off
[root@perf22 ~]# ethtool -i eth0
driver: vxge
version: 2.0.1.17129-k
firmware-version: 0.41.1
bus-info: 0000:04:00.0
[root@perf22 ~]# 

Last CPU on receiver

processor       : 15
vendor_id       : GenuineIntel
cpu family      : 6
model           : 26
model name      : Intel(R) Xeon(R) CPU           X5570  @ 2.93GHz
stepping        : 5
cpu MHz         : 2933.779
cache size      : 8192 KB
physical id     : 1
siblings        : 8
core id         : 3
cpu cores       : 4
apicid          : 23
initial apicid  : 23
fpu             : yes
fpu_exception   : yes
cpuid level     : 11
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology tsc_reliable nonstop_tsc pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi flexpriority ept vpid
bogomips        : 5865.80
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management:

The kernel is the Linus tree of an hour ago.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
