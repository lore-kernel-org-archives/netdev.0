From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tx-nocache-copy performance
Date: Mon, 06 Jan 2014 13:13:25 -0800
Message-ID: <1389042805.12212.212.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140106202754.GA5877@d2.synalogic.ca>
	 <1389041855.12212.210.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:43644 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551AbaAFVN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:13:28 -0500
Received: by mail-yh0-f43.google.com with SMTP id a41so3737127yho.16
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 13:13:27 -0800 (PST)
In-Reply-To: <1389041855.12212.210.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 12:57 -0800, Eric Dumazet wrote:

> We raised this point last year, for same reasons.
> 
> http://www.spinics.net/lists/netdev/msg226501.html
> 
> I agree we should revert the default.
> 
> I'll post new perf data using latest net-next kernel and a bnx2x NIC.


Updated results with latest net-next :

(cpu is Intel(R) Xeon(R) CPU X5660  @ 2.80GHz)

lpq83:~# ./ethtool -K eth0 tx-nocache-copy on 
lpq83:~# perf stat ./netperf -H lpq84 -c
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84.prod.google.com () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    10.00      9407.44   2.50     -1.00    0.522   -1.000 

 Performance counter stats for './netperf -H lpq84 -c':

       4282.648396 task-clock                #    0.423 CPUs utilized          
             9,348 context-switches          #    0.002 M/sec                  
                88 CPU-migrations            #    0.021 K/sec                  
               355 page-faults               #    0.083 K/sec                  
    11,812,797,651 cycles                    #    2.758 GHz                     [82.79%]
     9,020,522,817 stalled-cycles-frontend   #   76.36% frontend cycles idle    [82.54%]
     4,579,889,681 stalled-cycles-backend    #   38.77% backend  cycles idle    [67.33%]
     6,053,172,792 instructions              #    0.51  insns per cycle        
                                             #    1.49  stalled cycles per insn [83.64%]
       597,275,583 branches                  #  139.464 M/sec                   [83.70%]
         8,960,541 branch-misses             #    1.50% of all branches         [83.65%]

      10.128990264 seconds time elapsed

lpq83:~# ./ethtool -K eth0 tx-nocache-copy off
lpq83:~# perf stat ./netperf -H lpq84 -c
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84.prod.google.com () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    10.00      9412.45   2.15     -1.00    0.449   -1.000 

 Performance counter stats for './netperf -H lpq84 -c':

       2847.375441 task-clock                #    0.281 CPUs utilized          
            11,632 context-switches          #    0.004 M/sec                  
                49 CPU-migrations            #    0.017 K/sec                  
               354 page-faults               #    0.124 K/sec                  
     7,646,889,749 cycles                    #    2.686 GHz                     [83.34%]
     6,115,050,032 stalled-cycles-frontend   #   79.97% frontend cycles idle    [83.31%]
     1,726,460,071 stalled-cycles-backend    #   22.58% backend  cycles idle    [66.55%]
     2,079,702,453 instructions              #    0.27  insns per cycle        
                                             #    2.94  stalled cycles per insn [83.22%]
       363,773,213 branches                  #  127.757 M/sec                   [83.29%]
         4,242,732 branch-misses             #    1.17% of all branches         [83.51%]

      10.128449949 seconds time elapsed
