From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Question about way that NICs deliver packets to the kernel
Date: Tue, 20 Jul 2010 10:16:42 -0700
Message-ID: <4C45D9FA.5090108@hp.com>
References: <20100715142418.GA26491@host-a-229.ustcsz.edu.cn>	<1279204417.2118.12.camel@achroite.uk.solarflarecom.com>	<AANLkTild5SQvt7Uw7AAV7BrrSdvPdoglgbm1uJQnigdM@mail.gmail.com>	<4C409DD6.7060903@hp.com> <20100720011522.GA4123@host-a-160.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:37920 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab0GTRQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 13:16:46 -0400
In-Reply-To: <20100720011522.GA4123@host-a-160.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Junchang Wang wrote:
> On Fri, Jul 16, 2010 at 10:58:46AM -0700, Rick Jones wrote:
> 
>>>Hi Ben,
>>>I added options -c -C to netperf's command line. Result is as follows:
>>>                   scheme 1    scheme 2    Imp.
>>>Throughput:     683M        718M       5%
>>>CPU usage:     47.8%       45.6%
>>>
>>>That really surprised me because "top" command showed the CPU usage
>>>was fluctuating between 0.5% and 1.5% rather that between 45% and 50%.
>>
> 
> Hi rick,
> very sorry for my late reply. Just recovered from the final exam.:)
> 
> 
>>Can you tell us a bit more about the system, and which version of
>>netperf you are using?  
> 
> 
> The target machine is a Pentium Dual-core E2200 desktop with a r8169 
> gigabit NIC. (I couldn't find a better server with old pci slot.)
> 
> Another machine is a Nehalem based system with Intel 82576 NIC.
> 
> The target machine executes netserver and Nehalem machine executes netperf.
> The version of netperf is 2.4.5
> 
> 
>>Any chance that the CPU utilization you were
>>looking at in top was just that being charged to netperf the process?
> 
> 
> What I see on target machine is as follows:
> 
> top - 21:37:12 up 21 min,  6 users,  load average: 0.43, 0.28, 0.19
> Tasks: 152 total,   2 running, 149 sleeping,   0 stopped,   1 zombie
> Cpu(s):  2.3%us,  1.5%sy,  0.1%ni, 89.5%id,  2.7%wa,  0.0%hi,  3.9%si,  0.0%
> Mem:   2074064k total,   690200k used,  1383864k free,    39372k buffers
> Swap:  2096476k total,        0k used,  2096476k free,   435044k cached
> 
> PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND    
> 3916 root      20   0  2228  584  296 R 84.6  0.0   0:07.12 netserver    

You said this was a dual-core system right?  So two cores, no threads?  If so, 
then that does look odd - if netserver is consuming 84% of a CPU (core) and 
there are only two CPUs (cores) in the system, how the system can be 89.5% idle 
is beyond me. The 48% reported by netperf below makes better sense. If you press 
"1" while top is running it should start to show per-CPU statistics

> It shows the CPU usage of taget machine is around 10%.
> 
> while Nehalem machine's report is as follows:
> 
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.2.1 (192.168.2.1) port 0 AF_INET
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB
> 
> 87380  16384  16384    10.05       679.79   1.63     48.27    1.571   11.634 
> 
> It shows the CPU usage of target machine is 48.27%.

Clearly something is out of joint - let's go off-list (or on to 
netperf-talk@netperf.org) and hash that out to see what may be happening.  It 
will probably involve variations on grabbing the top-of-trunk, adding the debug 
option etc.

> 
> 
>>"Network processing" does not often get charged to the responsible
>>process, so netperf reports system-wide CPU utilization on the
>>assumption it is the only thing causing the CPUs to be utilized.
> 
> 
> My understand of your commends is:
> 1)except running in ksoftirqd, network processing cannot be correctly counted
>   because it runs in interrupt contexts that do not get charged to a correct
>   process. So "top" misses lots of CPU usage in high interrupt rate network
>   situation.

Top *shouldn't* miss it as far as reporting overall CPU utlization.  It just may 
not be charged to the process on who's behalf the work is done.

> 2)As you have mentioned in netperf's manual, netperf uses /proc/stat on Linux
>   to retrieve time spent in idle mode. In other words, it accumulates cpu time
>   spent in all other modes, including hardware interrupt, software interrupt,
>   etc., making the CPU usage more accurate in high interrupt situation.

That is the theory.  In practice however...  while the top output you've 
provided looks like there is an "issue" in top, netperf has been known to have a 
bug or three.

> 3)Since most processes in target machine are in sleeping mode, the CPU usage
>   of network processing is in actually very close to 48.27%. Right?

I do not expect there to be a huge discrepancy between the overall CPU 
utilization reported by top and the CPU utilization reported by netperf.  That 
there seems to be such a discrepancy has me wanting to make certain that netperf 
is operating correctly.

happy benchmarking,

rick jones

> 
> Correct me if any of them are incorrect. Thanks.
> 
> --Junchang
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

