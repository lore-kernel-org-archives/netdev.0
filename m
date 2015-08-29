From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH RFC V3 0/2] Optimize the snmp stat aggregation for large cpus
Date: Sat, 29 Aug 2015 14:37:56 +0530
Message-ID: <1440839278-21928-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <y>
Cc: <jiri@resnulli.us>, <edumazet@google.com>,
	<hannes@stressinduktion.org>, <tom@herbertland.com>,
	<azhou@nicira.com>, <ebiederm@xmission.com>,
	<ipm@chirality.org.uk>, <nicolas.dichtel@6wind.com>,
	<serge.hallyn@canonical.com>, <joe@perches.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<raghavendra.kt@linux.vnet.ibm.com>, <anton@au1.ibm.com>,
	<nacc@linux.vnet.ibm.com>, <srikar@linux.vnet.ibm.com>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While creating 1000 containers, perf is showing lot of time spent in
snmp_fold_field on a large cpu system.

The current patch tries to improve by reordering the statistics gathering.

Please note that similar overhead was also reported while creating
veth pairs  https://lkml.org/lkml/2013/3/19/556

Changes in V3:
 - use memset to initialize temp buffer in leaf function. (David)
 - use memcpy to copy the buffer data to stat instead of unalign_pu (Joe)
 - Move buffer definition to leaf function __snmp6_fill_stats64() (Eric)
 -
Changes in V2:
 - Allocate the stat calculation buffer in stack. (Eric)
 
Setup:
160 cpu (20 core) baremetal powerpc system with 1TB memory

1000 docker containers was created with command
docker run -itd  ubuntu:15.04  /bin/bash in loop

observation:
Docker container creation linearly increased from around 1.6 sec to 7.5 sec
(at 1000 containers) perf data showed, creating veth interfaces resulting in
the below code path was taking more time.

rtnl_fill_ifinfo
  -> inet6_fill_link_af
    -> inet6_fill_ifla6_attrs
      -> snmp_fold_field

proposed idea:
 currently __snmp6_fill_stats64 calls snmp_fold_field that walks
through per cpu data to of an item (iteratively for around 36 items).
 The patch tries to aggregate the statistics by going through
all the items of each cpu sequentially which is reducing cache
misses.

Performance of docker creation improved by around more than 2x
after the patch.

before the patch: 
================
#time docker run -itd  ubuntu:15.04  /bin/bash
3f45ba571a42e925c4ec4aaee0e48d7610a9ed82a4c931f83324d41822cf6617
real	0m6.836s
user	0m0.095s
sys	0m0.011s

perf record -a docker run -itd  ubuntu:15.04  /bin/bash
=======================================================
# Samples: 32K of event 'cycles'
# Event count (approx.): 24688700190
# Overhead  Command          Shared Object           Symbol                                                                                         
# ........  ...............  ......................  ........................
    50.73%  docker           [kernel.kallsyms]       [k] snmp_fold_field                                                                                                        
     9.07%  swapper          [kernel.kallsyms]       [k] snooze_loop                                                                                                            
     3.49%  docker           [kernel.kallsyms]       [k] veth_stats_one                                                                                                         
     2.85%  swapper          [kernel.kallsyms]       [k] _raw_spin_lock                                                                                                         
     1.37%  docker           docker                  [.] backtrace_qsort                                                                                                        
     1.31%  docker           docker                  [.] strings.FieldsFunc                                                                      

  cache-misses:  2.7%
                                                      
after the patch:
=============
#time docker run -itd  ubuntu:15.04  /bin/bash
9178273e9df399c8290b6c196e4aef9273be2876225f63b14a60cf97eacfafb5
real	0m3.249s
user	0m0.088s
sys	0m0.020s

perf record -a docker run -itd  ubuntu:15.04  /bin/bash
=======================================================
# Samples: 18K of event 'cycles'
# Event count (approx.): 13958958797
# Overhead  Command          Shared Object         Symbol                                                                                
# ........  ...............  ....................  ..........................
    10.57%  docker           docker                [.] scanblock                                                                         
     8.37%  swapper          [kernel.kallsyms]     [k] snooze_loop                                                                       
     6.91%  docker           [kernel.kallsyms]     [k] snmp_get_cpu_field                                                                
     6.67%  docker           [kernel.kallsyms]     [k] veth_stats_one                                                                    
     3.96%  docker           docker                [.] runtime_MSpan_Sweep                                                               
     2.47%  docker           docker                [.] strings.FieldsFunc                                                                
 
cache-misses: 1.41 %

Please let me know if you have suggestions/comments.
Thanks Eric, Joe and David for comments on V1 and V2.

Raghavendra K T (2):
  net: Introduce helper functions to get the per cpu data
  net: Optimize snmp stat aggregation by walking all the percpu data at
    once

 include/net/ip.h    | 10 ++++++++++
 net/ipv4/af_inet.c  | 41 +++++++++++++++++++++++++++--------------
 net/ipv6/addrconf.c | 22 +++++++++++++---------
 3 files changed, 50 insertions(+), 23 deletions(-)

-- 
1.7.11.7
