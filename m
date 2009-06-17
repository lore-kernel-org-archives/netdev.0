From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Wed, 17 Jun 2009 13:14:33 -0700
Message-ID: <4A394EA9.20503@hp.com>
References: <20090529162312.GA5191@neterion.com>	<20090610054449.GB16984@gondor.apana.org.au>	<20090612160926.GA4290@neterion.com>	<20090612.164833.35888001.davem@davemloft.net>	<20090616163547.GC5013@neterion.com>	<20090616163856.GA17318@gondor.apana.org.au>	<20090617080730.GA24410@gondor.apana.org.au> <20090617080847.GA24504@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <ben.lahaise@neterion.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:25699 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbZFQUOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 16:14:32 -0400
In-Reply-To: <20090617080847.GA24504@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Jun 17, 2009 at 04:07:30PM +0800, Herbert Xu wrote:
> 
>>On Wed, Jun 17, 2009 at 02:38:56AM +1000, Herbert Xu wrote:
>>
>>>I'm hoping to get onto this tomorrow.  I think there's definitely
>>>something broken because there's no way GRO should be slower than
>>>GRO off.  Slightly slower than LRO perhaps but surely not worse than
>>>not merging at all :)
>>
>>OK, I'm seeing the opposite :)
> 
> 
> Can you check your sender to see whether it's maxed out? That
> can play havoc when benchmarking the receiver.

Realted to that, and dealing with the inaccuracy of what classic netperf reports 
for thesocket buffers (your previous message) and wanting to know about the CPUs 
on either side, if one grabs netperf 2.4.5  and ./configure --enable-omni on both 
sides, a command like:

netperf -H 172.17.10.22 -c -C -t omni -- -m 16K -O foo

where the contents of the file foo are:

LSS_SIZE_END,RSR_SIZE_END,LOCAL_SEND_SIZE,ELAPSED_TIME,THROUGHPUT,THROUGHPUT_UNITS
LOCAL_CPU_UTIL,LOCAL_SD,LOCAL_CPU_COUNT,LOCAL_CPU_PEAK_UTIL,LOCAL_CPU_PEAK_ID
REMOTE_CPU_UTIL,REMOTE_SD,REMOTE_CPU_COUNT,REMOTE_CPU_PEAK_UTIL,REMOTE_CPU_PEAK_ID
LOCAL_CPU_MODEL,LOCAL_CPU_FREQUENCY,REMOTE_CPU_MODEL,REMOTE_CPU_FREQUENCY

will result in output that looks like:

raj@tardy:~/netperf2_trunk$ src/netperf -t omni -H localhost -c -C -- -m 16K -O foo
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain 
(127.0.0.1) port 0 AF_INET
Local       Remote      Local  Elapsed Throughput Throughput
Send Socket Recv Socket Send   Time               Units
Size        Size        Size   (sec)
Final       Final
606960      2072576     16384  10.00   3437.47    10^6bits/s

Local   Local   Local Local   Local
CPU     Service CPU   Peak    Peak
Util    Demand  Count Per CPU Per CPU
%                     Util %  ID
100.00  2.383   1     100.00  0

Remote  Remote  Remote Remote  Remote
CPU     Service CPU    Peak    Peak
Util    Demand  Count  Per CPU Per CPU
%                      Util %  ID
100.00  2.383   1      100.00  0

Local                          Local     Remote                         Remote
CPU                            CPU       CPU                            CPU
Model                          Frequency Model                          Frequency
                                MHz                                      MHz
Intel(R) XEON(TM) CPU 2.00GHz  1995      Intel(R) XEON(TM) CPU 2.00GHz  1995

modulo some wrapping,  can also use -o to get one set of CSV or -k to get keyval. 
  The file can have as many as four lines which will be honored by the -O option, 
with -o producing one big line regardless and -k producing one line per keyval 
regardless.  netperf -t omni -- -O \?  will give a list of all the known output 
selections.

So, you can get netperf to tell you about the CPUs, and whether one of them 
pegged on either side.

happy benchmarking,

rick jones

> 
> Also what are the raw numbers that you were getting?
> 
> Cheers,

