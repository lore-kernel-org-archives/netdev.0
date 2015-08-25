From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH RFC 0/2] Optimize the snmp stat aggregation for large cpus
Date: Tue, 25 Aug 2015 13:24:24 +0530
Message-ID: <1440489266-31127-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <y>
Cc: <jiri@resnulli.us>, <edumazet@google.com>,
	<hannes@stressinduktion.org>, <tom@herbertland.com>,
	<azhou@nicira.com>, <ebiederm@xmission.com>,
	<ipm@chirality.org.uk>, <nicolas.dichtel@6wind.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<raghavendra.kt@linux.vnet.ibm.com>, <anton@au1.ibm.com>,
	<nacc@linux.vnet.ibm.com>, <srikar@linux.vnet.ibm.com>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e19.ny.us.ibm.com ([129.33.205.209]:47831 "EHLO
	e19.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbbHYH44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 03:56:56 -0400
Received: from /spool/local
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 25 Aug 2015 03:56:55 -0400
In-Reply-To: <y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While creating 1000 containers, perf is showing lot of time spent in
snmp_fold_field on a large cpu system.

The current patch tries to improve by reordering the statistics gathering.

Please note that similar overhead was also reported while creating
veth pairs  https://lkml.org/lkml/2013/3/19/556

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
through per cpu data to of an item (iteratively for around 90 items).
 The patch tries to aggregate the statistics by going through
all the items of each cpu sequentially which is reducing cache
misses.

Performance of docker creation improved by around more than 2x
after the patch.

before the patch: 
================
time docker run -itd  ubuntu:15.04  /bin/bash
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
 time docker run -itd  ubuntu:15.04  /bin/bash
4e0619421332990bdea413fe455ab187607ed63d33d5c37aa5291bc2f5b35857
real	0m3.357s
user	0m0.092s
sys	0m0.010s

perf record -a docker run -itd  ubuntu:15.04  /bin/bash
=======================================================
# Samples: 15K of event 'cycles'
# Event count (approx.): 11471830714
# Overhead  Command          Shared Object         Symbol                                                                                         
# ........  ...............  ....................  .........................
    10.56%  swapper          [kernel.kallsyms]     [k] snooze_loop                                                                                            
     8.72%  docker           [kernel.kallsyms]     [k] snmp_get_cpu_field                                                                                     
     7.59%  docker           [kernel.kallsyms]     [k] veth_stats_one                                                                                         
     3.65%  swapper          [kernel.kallsyms]     [k] _raw_spin_lock                                                                                         
     3.06%  docker           docker                [.] strings.FieldsFunc                                                                                     
     2.96%  docker           docker                [.] backtrace_qsort      
                
cache-misses: 1.38 %

Please let me know if you have suggestions/comments.

Raghavendra K T (2):
  net: Introduce helper functions to get the per cpu data
  net: Optimize snmp stat aggregation by walking all the percpu data at
    once

 include/net/ip.h    | 10 ++++++++++
 net/ipv4/af_inet.c  | 41 +++++++++++++++++++++++++++--------------
 net/ipv6/addrconf.c | 14 +++++++++++---
 3 files changed, 48 insertions(+), 17 deletions(-)

-- 
1.7.11.7
