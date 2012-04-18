From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Wed, 18 Apr 2012 19:16:15 +0200
Message-ID: <1334769375.2472.310.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl>  <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
	 <1334764184.2472.299.camel@edumazet-glaptop>  <4F8EF317.10504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45004 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646Ab2DRRQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 13:16:34 -0400
Received: by bkcik5 with SMTP id ik5so5687236bkc.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 10:16:33 -0700 (PDT)
In-Reply-To: <4F8EF317.10504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 10:00 -0700, Rick Jones wrote:

> Is the issue completely sent, or transmit completion processed?  I'd 
> think it is time to the latter that matters (and includes the former) yes?
> 

I dont know. Fact is we process ACKs before clone skb is freed by TX
completion.

> Does the ixgbe driver do transmit completions first when it gets a 
> receive interrupt, or is there still the chance that the receipt of the 
> last ACK for the 64KB skb will hit TCP before the driver has done the 
> free?  (Or does that not matter?)

It does transmit completions first, but that doesnt matter, since we
receive ACK before skb could be drained by NIC and returned to driver
for TX completion.

> 
> > Performance results on my Q6600 cpu and 82599EB 10-Gigabit card :
> > About 3% less cpu used for same workload (single netperf TCP_STREAM),
> > bounded by x4 PCI-e slots (4660 Mbits).
> 
> Three percent less or three percentage points less?  Including the 
> details of the netperf-reported service demand would make that clear.

netperf results are not precise enough, since my setup is limited by PCI
bandwidth. here are the "perf stat" ones

Maybe someone can run the test on 20Gb/40Gb links, and NUMA machine.

Before patch :

# perf stat -r 5 -d -d -o RES.before taskset 1 netperf -H 192.168.99.1 -l 20

 Performance counter stats for 'taskset 1 netperf -H 192.168.99.1 -l 20' (5 runs):

       6252,882411 task-clock                #    0,312 CPUs utilized            ( +-  0,51% )
             5 988 context-switches          #    0,958 K/sec                    ( +-  0,34% )
                 2 CPU-migrations            #    0,000 K/sec                    ( +- 15,31% )
               389 page-faults               #    0,062 K/sec                  
     9 938 280 877 cycles                    #    1,589 GHz                      ( +-  0,55% ) [21,19%]
   <not supported> stalled-cycles-frontend 
   <not supported> stalled-cycles-backend  
    11 709 374 305 instructions              #    1,18  insns per cycle          ( +-  0,28% ) [21,32%]
     1 026 659 544 branches                  #  164,190 M/sec                    ( +-  0,40% ) [21,49%]
        10 898 375 branch-misses             #    1,06% of all branches          ( +-  1,87% ) [21,54%]
     5 238 382 991 L1-dcache-loads           #  837,755 M/sec                    ( +-  0,21% ) [14,26%]
     1 117 076 847 L1-dcache-load-misses     #   21,32% of all L1-dcache hits    ( +-  0,49% ) [14,19%]
       166 208 073 LLC-loads                 #   26,581 M/sec                    ( +-  0,88% ) [14,33%]
         3 220 627 LLC-load-misses           #    1,94% of all LL-cache hits     ( +-  2,39% ) [14,31%]
     9 470 544 759 L1-icache-loads           # 1514,589 M/sec                    ( +-  0,44% ) [14,41%]
        23 602 610 L1-icache-load-misses     #    0,25% of all L1-icache hits    ( +-  3,10% ) [14,49%]
     5 241 137 739 dTLB-loads                #  838,195 M/sec                    ( +-  0,18% ) [14,20%]
         4 970 360 dTLB-load-misses          #    0,09% of all dTLB cache hits   ( +-  1,01% ) [14,47%]
    11 720 311 101 iTLB-loads                # 1874,385 M/sec                    ( +-  0,34% ) [21,33%]
           587 825 iTLB-load-misses          #    0,01% of all iTLB cache hits   ( +- 31,06% ) [21,52%]

      20,018804246 seconds time elapsed                                          ( +-  0,00% )


After patch :

# perf stat -r 5 -d -d -o RES.after taskset 1 netperf -H 192.168.99.1 -l 20

 Performance counter stats for 'taskset 1 netperf -H 192.168.99.1 -l 20' (5 runs):

       6061,208375 task-clock                #    0,303 CPUs utilized            ( +-  0,18% )
             6 032 context-switches          #    0,995 K/sec                    ( +-  0,22% )
                 2 CPU-migrations            #    0,000 K/sec                    ( +- 52,44% )
               390 page-faults               #    0,064 K/sec                    ( +-  0,05% )
     9 623 179 185 cycles                    #    1,588 GHz                      ( +-  0,16% ) [21,33%]
   <not supported> stalled-cycles-frontend 
   <not supported> stalled-cycles-backend  
    11 724 650 132 instructions              #    1,22  insns per cycle          ( +-  0,22% ) [21,52%]
     1 025 017 197 branches                  #  169,111 M/sec                    ( +-  0,29% ) [21,75%]
        10 464 785 branch-misses             #    1,02% of all branches          ( +-  1,78% ) [21,82%]
     5 230 299 185 L1-dcache-loads           #  862,914 M/sec                    ( +-  0,20% ) [14,55%]
     1 109 236 741 L1-dcache-load-misses     #   21,21% of all L1-dcache hits    ( +-  0,59% ) [14,59%]
       161 721 826 LLC-loads                 #   26,681 M/sec                    ( +-  0,58% ) [14,25%]
         2 974 990 LLC-load-misses           #    1,84% of all LL-cache hits     ( +-  0,95% ) [14,13%]
     9 233 690 637 L1-icache-loads           # 1523,408 M/sec                    ( +-  0,24% ) [14,14%]
        17 177 769 L1-icache-load-misses     #    0,19% of all L1-icache hits    ( +-  0,69% ) [14,05%]
     5 218 114 832 dTLB-loads                #  860,903 M/sec                    ( +-  0,12% ) [14,23%]
         4 980 060 dTLB-load-misses          #    0,10% of all dTLB cache hits   ( +-  1,23% ) [14,33%]
    11 743 563 935 iTLB-loads                # 1937,495 M/sec                    ( +-  0,13% ) [21,38%]
           959 598 iTLB-load-misses          #    0,01% of all iTLB cache hits   ( +- 24,72% ) [21,33%]

      20,019067285 seconds time elapsed                                          ( +-  0,00% )
