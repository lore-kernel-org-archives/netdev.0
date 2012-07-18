From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 18 Jul 2012 10:55:53 +0200
Message-ID: <1342601753.2626.2040.camel@edumazet-glaptop>
References: <1342564781.2626.1264.camel@edumazet-glaptop>
	 <20120717234037.GA26972@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:36976 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab2GRIz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 04:55:59 -0400
Received: by vcbfk26 with SMTP id fk26so925295vcb.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 01:55:58 -0700 (PDT)
In-Reply-To: <20120717234037.GA26972@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 01:40 +0200, Francois Romieu wrote:

> > (I found that activating them with ethtool automatically enables GSO,
> >  and performance with GSO is not good)
> 
> It's still an improvement though, isn't it ?
> 

On an old AMD machine, I can get line rate with default conf, but using
nearly all cpu cycles.

Following test is only partial, a real one should use forwarding for
example...


# perf stat netperf -H eric -C -c -t OMNI
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to eric () port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1000 tcpi_rttvar 750 tcpi_snd_ssthresh 16 tpci_snd_cwnd 62
tcpi_reordering 3 tcpi_total_retrans 0
Local       Remote      Local  Elapsed Throughput Throughput  Local  Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU    CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util   Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %      Method %      Method                          
290160      549032      16384  10.00   915.44     10^6bits/s  44.93  S      3.61   S      8.042   7.755   usec/KB  

 Performance counter stats for 'netperf -H eric -C -c -t OMNI':

       5206,301186 task-clock                #    0,520 CPUs utilized          
            16 568 context-switches          #    0,003 M/sec                  
                 2 CPU-migrations            #    0,000 K/sec                  
               366 page-faults               #    0,070 K/sec                  
    12 362 775 266 cycles                    #    2,375 GHz                     [66,99%]
     2 529 275 760 stalled-cycles-frontend   #   20,46% frontend cycles idle    [67,00%]
     6 878 915 080 stalled-cycles-backend    #   55,64% backend  cycles idle    [66,24%]
     5 272 222 150 instructions              #    0,43  insns per cycle        
                                             #    1,30  stalled cycles per insn [66,85%]
       819 922 185 branches                  #  157,487 M/sec                   [66,79%]
        50 135 423 branch-misses             #    6,11% of all branches         [66,15%]

      10,019141027 seconds time elapsed


If I switch to SG+TX (GSO is automatically enabled), bandwidth is lower.

# ethtool -K eth1 tx on sg on
Actual changes:
tx-checksumming: on
	tx-checksum-ipv4: on
scatter-gather: on
	tx-scatter-gather: on
generic-segmentation-offload: on

# perf stat netperf -H eric -C -c -t OMNI
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to eric () port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1875 tcpi_rttvar 750 tcpi_snd_ssthresh 21 tpci_snd_cwnd 169
tcpi_reordering 3 tcpi_total_retrans 0
Local       Remote      Local  Elapsed Throughput Throughput  Local  Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU    CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util   Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %      Method %      Method                          
790920      704640      16384  10.01   762.29     10^6bits/s  38.00  S      3.38   S      8.167   8.720   usec/KB  

 Performance counter stats for 'netperf -H eric -C -c -t OMNI':

       4526,838736 task-clock                #    0,452 CPUs utilized          
             2 031 context-switches          #    0,449 K/sec                  
                 3 CPU-migrations            #    0,001 K/sec                  
               366 page-faults               #    0,081 K/sec                  
     4 476 876 825 cycles                    #    0,989 GHz                     [66,41%]
       899 080 378 stalled-cycles-frontend   #   20,08% frontend cycles idle    [66,56%]
     2 430 763 937 stalled-cycles-backend    #   54,30% backend  cycles idle    [66,87%]
     1 685 481 163 instructions              #    0,38  insns per cycle        
                                             #    1,44  stalled cycles per insn [66,93%]
       280 404 977 branches                  #   61,943 M/sec                   [66,73%]
        15 608 497 branch-misses             #    5,57% of all branches         [66,54%]

      10,025486268 seconds time elapsed

Since most frames need between 2 and 3 segments
(one for the ip/tcp headers, and one or two frags for the payload), this
might be a MMIO issue, that Alexander tried to solve recently...

If I only switch to SG+TX its ok

# ethtool -K eth1 gso off

# perf stat netperf -H eric -C -c -t OMNI
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to eric () port 0 AF_INET
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 14600
tcpi_rtt 1000 tcpi_rttvar 750 tcpi_snd_ssthresh 18 tpci_snd_cwnd 60
tcpi_reordering 3 tcpi_total_retrans 0
Local       Remote      Local  Elapsed Throughput Throughput  Local  Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU    CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util   Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %      Method %      Method                          
280800      549032      16384  10.00   916.61     10^6bits/s  40.05  S      3.62   S      7.159   7.774   usec/KB  

 Performance counter stats for 'netperf -H eric -C -c -t OMNI':

       4827,259625 task-clock                #    0,482 CPUs utilized          
            17 988 context-switches          #    0,004 M/sec                  
                 3 CPU-migrations            #    0,001 K/sec                  
               366 page-faults               #    0,076 K/sec                  
    11 448 148 411 cycles                    #    2,372 GHz                     [66,57%]
     2 278 563 777 stalled-cycles-frontend   #   19,90% frontend cycles idle    [66,38%]
     6 420 123 655 stalled-cycles-backend    #   56,08% backend  cycles idle    [66,38%]
     4 471 468 064 instructions              #    0,39  insns per cycle        
                                             #    1,44  stalled cycles per insn [67,48%]
       757 302 269 branches                  #  156,880 M/sec                   [67,08%]
        44 320 435 branch-misses             #    5,85% of all branches         [66,16%]

      10,020331031 seconds time elapsed
