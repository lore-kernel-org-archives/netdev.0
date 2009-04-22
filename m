From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 22 Apr 2009 11:37:24 -0400
Message-ID: <49EF39B4.1040607@myri.com>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1979 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753342AbZDVPiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 11:38:19 -0400
In-Reply-To: <20090422104811.GA30981@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

 >
 > In the mean time, can you see if there is any disparity in the
 > number of aggregated segments and ACKs between GRO and LRO?
 > netstat -s should be sufficient to measure this (TCP segments
 > received and sent).

I booted the sender into a kernel.org 2.6.18.2 so as to try to have 
results as close to yours as possible (I was running 2.6.22 on the
sender before).

I ran 2 sets of experiments, with different CPU bindings.  First
I bound the netserver and IRQ to the same CPU:

LRO:
2301987 segments received
570331  segments send out

Recv   Send    Send                          Utilization       Service 
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local 
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  65536  65536    60.01      6637.79   10.07    49.99    0.249 
1.234

GRO:
2035181 segments received
493042  segments send out

  87380  65536  65536    60.01      5768.21   8.60     49.98    0.244 
1.420


Then I bound them to different CPUs, so as to get close to line rate:


LRO:
3165013 segments received
1763169 segments send out
  87380  65536  65536    60.01      9473.27   15.75    49.58    0.272 
0.858


GRO:
3032484 segments received
2265453 segments send out
  87380  65536  65536    60.01      9472.69   15.64    48.73    0.270 
0.843


Do you know what is broken with respect the CPU utilization in recent
kernels?  If I bind the IRQ to CPU0, then watch mpstat I see
zero load on that CPU:

% mpstat -P 0 1
Linux 2.6.30-rc1 (venice)       04/22/09

11:25:25     CPU   %user   %nice %system %iowait    %irq   %soft   %idle 
    intr/s
11:25:26       0    0.00    0.00    0.00    0.00    0.00    0.00  100.00 
  13248.00
11:25:27       0    0.00    0.00    0.00    0.00    0.00    0.00  100.00 
  13280.00

Common sense tells me that is wrong, and oprofile verifies there is
a lot happening on CPU0.  This makes it hard to use netperf's
service demand to compare LRO and GRO.

When I run a cpu-soaker in usermode bound to CPU0, I start to see
irq, softirq, etc:

11:28:02     CPU   %user   %nice %system %iowait    %irq   %soft   %idle 
    intr/s
11:28:03       0   45.10    0.00    0.00    0.00    1.96   52.94    0.00 
  13019.61
11:28:04       0   46.46    0.00    0.00    0.00    2.02   51.52    0.00 
  13414.14


If I use this as poor-man's way to measure CPU load on the CPU running
the softirq, then its clear that GRO is using a bit more CPU than LRO.
The above mpstat output is from LRO, and this is from GRO:

11:29:16       0   39.60    0.00    0.00    0.00    2.97   57.43    0.00 
  13146.53
11:29:17       0   38.00    0.00    0.00    0.00    2.00   60.00    0.00 
  13278.00
11:29:18       0   39.00    0.00    0.00    0.00    4.00   57.00    0.00 
  13273.00

Once we have the checksum issue worked out, either GRO or my driver
will be using even more CPU as it will need to verify the partial
checksums.  Remember that my current patch is just setting
CHECKSUM_UNNECESSARY to get around the checksum problem I was seeing.

Drew


