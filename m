From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 29 Jan 2010 12:02:46 -0800
Message-ID: <4B633EE6.7060502@hp.com>
References: <20100121.012520.254679483.davem@davemloft.net>	<20100121094157.GA15262@gondor.apana.org.au>	<OF7EA723DA.DC2FF4FC-ON652576B8.002064CB-652576B8.00267739@in.ibm.com>	<20100129090625.GD23140@gondor.apana.org.au>	<OFA813CB35.7FC6144E-ON652576BA.003C3B2C-652576BA.003CB215@in.ibm.com> <20100129113346.GB1309@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:35571 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab0A2UCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 15:02:49 -0500
In-Reply-To: <20100129113346.GB1309@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Jan 29, 2010 at 04:45:01PM +0530, Krishna Kumar2 wrote:
> 
>>Same 5 runs of single netperf's:
>>
>>0. Driver unsets F_SG but sets F_GSO:
>>        Org (16K):      BW: 18180.71    SD: 13.485
>>        New (16K):      BW: 18113.15    SD: 13.551
>>        Org (64K):      BW: 21980.28    SD: 10.306
>>        New (64K):      BW: 21386.59    SD: 10.447
>>
>>1. Driver unsets F_SG, and with GSO off
>>        Org (16K):      BW: 10894.62    SD: 26.591
>>        New (16K):      BW: 7262.10     SD: 35.340
>>        Org (64K):      BW: 12396.41    SD: 23.357
>>        New (64K):      BW: 7853.02     SD: 32.405
>>
>>
>>2. Driver unsets F_SG and uses ethtool to set GSO:
>>        Org (16K):      BW: 18094.11    SD: 13.603
>>        New (16K):      BW: 17952.38    SD: 13.743
>>        Org (64K):      BW: 21540.78    SD: 10.771
>>        New (64K):      BW: 21818.35    SD: 10.598
> 
> 
> Hmm, any idea what is causing case 0 to be different from case 2?
> In particular, the 64K performance in case 0 appears to be a
> regression but in case 2 it's showing up as an improvement.
> 
> AFAICS these two cases should produce identical results, or is
> this just jitter across tests?

To get some idea of run to run variation, and one does not want to run 
multiple explicit netperf commands and do later statistical work, one 
can add global command line arguments to netperf:

netperf ... -i 30,3 -I 99,<width> ...

which will tell netperf to run at least 3 iterations (that is the 
minimum minimum netperf will do) and no more than 30 iterations (that is 
the maximum maximum netperf will do) attempting to be 99% confident that 
the mean for throughput (and the CPU utilization if -c and/or -C are 
present and a global -r is not) is within +/- width/2%  For example:

netperf -H remote -i 30,3 -I 99,0.5 -c -C

will attempt to be 99% certain that the means it reports for throughput, 
local and remote CPU utilization is within +/- 0.25% of the actual mean. 
  If, after 30 iterations it has not achieved that confidence, it will 
emit warnings giving the width of the confidence intervals it has achieved.

happy benchmarking,

rick jones
