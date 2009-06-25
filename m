From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: weird problem
Date: Fri, 26 Jun 2009 00:23:44 +0200
Message-ID: <4A43F8F0.3060309@itcare.pl>
References: <4A43A098.1@itcare.pl> <4A43A6D1.70901@itcare.pl> <4A43B17E.6060102@itcare.pl> <4A43D3CC.2050405@itcare.pl> <4A43DB99.70602@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040802030102000607070906"
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:35604 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766AbZFYWXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 18:23:48 -0400
In-Reply-To: <4A43DB99.70602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040802030102000607070906
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

Thanks for reply


Yes i will try 2.6.31-rc1

but i make this on my one of failover machines 5 min ago with the same 
config that was working with 2.6.30 ......
...... and now i have one failover router less :) kernel panic after 
reboot and maybee one second of traffic on kernel-2.6.31-rc1  :)
 
My .config is in attachement.


I will make more work to check this at the day.

Regards
Pawe³ Staszewski



Eric Dumazet pisze:
> Pawe³ Staszewski a écrit :
>   
>> Ok
>>
>> After this day of observation im near 100% sure that this cpu load is
>> made by route cahce flushes
>> When route cache increase to its "net.ipv4.route.gc_thresh" size or is
>> near that size
>> system is starting to drop some routes from cache then cpu load is
>> increase from 2% to near 80%
>> after cleaning / flush cache when cache is filling cpu load is again
>> normal 2%
>>
>> Someone know how to resolve this ?
>> on kernels < 2.6.29 i don't see this, all start after upgrade from
>> 2.6.28 to 2.6.29 - then i try 2.6.29.1 , 2.6.29.3 and 2.6.30 and on all
>> this kernels >= 2.6.29 problem with cpu load is the same.
>>
>> I can minimize this cpu fluctuations by changing of route cache /proc
>> parameters but the best result for my router was
>>
>> 15 sec of 2% cpu
>> and after
>> 15sec of 80% cpu
>>
>>
>> Regards
>> Pawel Staszewski
>>     
>
>
> I believe this is known 2.6.29 regressions
>
> Following two commits should correct the problem you have
>
> Your best bet would be to try 2.6.31-rc1, and tell us if this recent kernel
> is ok on your machine ?
>
>
>
> commit 1ddbcb005c395518c2cd0df504cff3d4b5c85853
> Author: Eric Dumazet <dada1@cosmosbay.com>
> Date:   Tue May 19 20:14:28 2009 +0000
>
>     net: fix rtable leak in net/ipv4/route.c
>
>     Alexander V. Lukyanov found a regression in 2.6.29 and made a complete
>     analysis found in http://bugzilla.kernel.org/show_bug.cgi?id=13339
>     Quoted here because its a perfect one :
>
>     begin_of_quotation
>      2.6.29 patch has introduced flexible route cache rebuilding. Unfortunately the
>      patch has at least one critical flaw, and another problem.
>
>      rt_intern_hash calculates rthi pointer, which is later used for new entry
>      insertion. The same loop calculates cand pointer which is used to clean the
>      list. If the pointers are the same, rtable leak occurs, as first the cand is
>      removed then the new entry is appended to it.
>
>      This leak leads to unregister_netdevice problem (usage count > 0).
>
>      Another problem of the patch is that it tries to insert the entries in certain
>      order, to facilitate counting of entries distinct by all but QoS parameters.
>      Unfortunately, referencing an existing rtable entry moves it to list beginning,
>      to speed up further lookups, so the carefully built order is destroyed.
>
>      For the first problem the simplest patch it to set rthi=0 when rthi==cand, but
>      it will also destroy the ordering.
>     end_of_quotation
>
>     Problematic commit is 1080d709fb9d8cd4392f93476ee46a9d6ea05a5b
>     (net: implement emergency route cache rebulds when gc_elasticity is exceeded)
>
>     Trying to keep dst_entries ordered is too complex and breaks the fact that
>     order should depend on the frequency of use for garbage collection.
>
>     A possible fix is to make rt_intern_hash() simpler, and only makes
>     rt_check_expire() a litle bit smarter, being able to cope with an arbitrary
>     entries order. The added loop is running on cache hot data, while cpu
>     is prefetching next object, so should be unnoticied.
>
>     Reported-and-analyzed-by: Alexander V. Lukyanov <lav@yar.ru>
>
> commit cf8da764fc6959b7efb482f375dfef9830e98205
> Author: Eric Dumazet <dada1@cosmosbay.com>
> Date:   Tue May 19 18:54:22 2009 +0000
>
>     net: fix length computation in rt_check_expire()
>
>     rt_check_expire() computes average and standard deviation of chain lengths,
>     but not correclty reset length to 0 at beginning of each chain.
>     This probably gives overflows for sum2 (and sum) on loaded machines instead
>     of meaningful results.
>
>     Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>     Acked-by: Neil Horman <nhorman@tuxdriver.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
>
>   
>>
>> Pawe³ Staszewski pisze:
>>     
>>> Another info
>>>
>>> i look at some stats from rtstats and mpstat and try to join them
>>> together and here is output:
>>> 19:06:50     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>> %steal  %guest   %idle        rt_cache entries
>>> 19:07:01     all    0.00    0.00    0.12    0.00    0.59   12.00   
>>> 0.00    0.00   87.29        77726
>>> 19:07:02     all    0.00    0.00    0.12    0.00    0.49    6.11   
>>> 0.00    0.00   93.28        80127
>>> 19:07:03     all    0.00    0.00    0.00    0.00    0.11    1.06   
>>> 0.00    0.00   98.84        82596
>>> 19:07:04     all    0.00    0.00    0.16    0.00    0.00    2.07   
>>> 0.00    0.00   97.77        85147
>>> 19:07:05     all    0.00    0.00    0.00    0.00    0.12    1.81   
>>> 0.00    0.00   98.07        87641
>>> 19:07:06     all    0.00    0.00    0.00    0.00    0.27    1.50   
>>> 0.00    0.00   98.22        90085
>>> 19:07:07     all    0.00    0.00    0.00    0.00    0.23    1.72   
>>> 0.00    0.00   98.05        93586
>>> 19:07:08     all    0.00    0.00    0.00    0.00    0.00    1.56   
>>> 0.00    0.00   98.44        96865
>>> 19:07:09     all    0.00    0.00    0.00    0.00    0.00    1.45   
>>> 0.00    0.00   98.55        99803
>>> 19:07:10     all    0.00    0.00    0.00    0.00    0.27    1.65   
>>> 0.00    0.00   98.08        102123
>>> 19:07:11     all    0.00    0.00    0.10    0.00    0.30    4.07   
>>> 0.00    0.00   95.54        104618
>>> 19:07:12     all    0.00    0.00    0.00    0.00    1.30   18.96   
>>> 0.00    0.00   79.74        105524
>>> 19:07:13     all    0.00    0.00    0.00    0.00    0.84   13.58   
>>> 0.00    0.00   85.58        101085
>>> 19:07:14     all    0.00    0.00    0.00    0.00    1.36   20.45   
>>> 0.00    0.00   78.18        97518
>>> 19:07:15     all    0.00    0.00    0.00    0.00    0.98   15.89   
>>> 0.00    0.00   83.13        94308
>>> 19:07:16     all    0.00    0.00    0.00    0.00    1.32   17.00   
>>> 0.00    0.00   81.69        91811
>>> 19:07:17     all    0.00    0.00    0.00    0.00    0.67   14.57   
>>> 0.00    0.00   84.75        92278
>>> 19:07:18     all    0.00    0.00    0.00    0.00    1.51   17.40   
>>> 0.00    0.00   81.10        90936
>>> 19:07:19     all    0.00    0.00    0.00    0.00    1.24   13.46   
>>> 0.00    0.00   85.29        87951
>>> 19:07:20     all    0.00    0.00    0.14    0.00    0.99   18.75   
>>> 0.00    0.00   80.11        85071
>>> 19:07:21     all    0.00    0.00    0.00    0.00    0.84   15.20   
>>> 0.00    0.00   83.96        82477
>>> 19:07:22     all    0.40    0.00    0.00    0.00    1.71   17.65   
>>> 0.00    0.00   80.24        80301
>>> 19:07:23     all    0.00    0.00    0.11    0.00    1.08   13.33   
>>> 0.00    0.00   85.48        78480
>>> 19:07:24     all    0.00    0.00    0.00    0.00    0.87   19.25   
>>> 0.00    0.00   79.88        76880
>>>
>>> When cpu load is rising rt cache entries are decreasing
>>> and when cpu load is from 1 do 3% rt cache entries are increasing
>>>
>>> some sysctl-s that i have and are route cache specific:
>>> net.ipv4.route.gc_thresh = 190536
>>> net.ipv4.route.gc_min_interval = 0
>>> net.ipv4.route.gc_min_interval_ms = 0
>>> net.ipv4.route.gc_timeout = 15
>>> net.ipv4.route.gc_interval = 1
>>> net.ipv4.route.gc_elasticity = 4
>>>
>>>
>>>
>>>
>>> Pawe³ Staszewski pisze:
>>>       
>>>> oprofile output per cpu
>>>> CPU: Core 2, speed 3000.08 MHz (estimated)
>>>> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a
>>>> unit mask of 0x00 (Unhalted core cycles) count 100000
>>>> Samples on CPU 0
>>>> Samples on CPU 1
>>>> Samples on CPU 2
>>>> Samples on CPU 3
>>>> Samples on CPU 4
>>>> Samples on CPU 5
>>>> Samples on CPU 6
>>>> Samples on CPU 7
>>>> Samples on CPU all
>>>> samples  %        samples  %        samples  %        samples 
>>>> %        samples  %        samples  %        samples  %       
>>>> samples  %        samples  %
>>>>    image name               app name                 symbol name
>>>> 29520    21.7362  0              0  0              0  0             
>>>> 0  0              0  0              0  9571     34.0254 
>>>> 0              0  4701      0.22
>>>> 55  oprofiled                oprofiled                (no symbols)
>>>> 18441    13.5785  0              0  0              0  0             
>>>> 0  0              0  0              0  0              0 
>>>> 0              0  2666      0.12
>>>> 79  vmlinux                  vmlinux                  rt_worker_func
>>>> 18428    13.5690  132089    2.1756  135138    1.4238  21735   
>>>> 42.7703  775       1.9819  893       5.3180  847       3.0111 
>>>> 1056      3.3130  37949     1.82
>>>> 01  vmlinux                  vmlinux                  mwait_idle
>>>> 15797    11.6317  212       0.0035  2879      0.0303  17       
>>>> 0.0335  2         0.0051  4         0.0238  14        0.0498 
>>>> 185       0.5804  2895      0.13
>>>> 89  vmlinux                  vmlinux                  free_block
>>>> 9034      6.6519  1218      0.0201  2727      0.0287  0             
>>>> 0  0              0  0              0  0              0 
>>>> 0              0  2004      0.09
>>>> 61  vmlinux                  vmlinux                  dst_destroy
>>>> 7113      5.2375  632       0.0104  483       0.0051  6615    
>>>> 13.0170  543       1.3886  461       2.7454  1951      6.9359 
>>>> 1274      3.9970  4073      0.19
>>>> 54  vmlinux                  vmlinux                 
>>>> mutex_spin_on_owner
>>>> 4382      3.2266  652       0.0107  1880      0.0198  2        
>>>> 0.0039  0              0  0              0  3         0.0107 
>>>> 7         0.0220  1050      0.05
>>>> 04  vmlinux                  vmlinux                  __call_rcu
>>>> 4337      3.1934  418       0.0069  830       0.0087  58       
>>>> 0.1141  18        0.0460  8         0.0476  20        0.0711 
>>>> 39        0.1224  917       0.04
>>>> 40  vmlinux                  vmlinux                 
>>>> __rcu_process_callbacks
>>>> 3991      2.9387  51       8.4e-04  325       0.0034  136      
>>>> 0.2676  2         0.0051  1         0.0060  1034      3.6759 
>>>> 205       0.6432  1110      0.05
>>>> 32  vmlinux                  vmlinux                 
>>>> copy_user_generic_string
>>>> 3292      2.4240  275838    4.5432  391639    4.1263  869      
>>>> 1.7100  431       1.1022  350       2.0843  673       2.3925 
>>>> 1069      3.3538  89939     4.31
>>>> 37  vmlinux                  vmlinux                  _raw_spin_lock
>>>> 1909      1.4056  79        0.0013  376       0.0040  0             
>>>> 0  0              0  0              0  0              0 
>>>> 0              0  348       0.01
>>>> 67  vmlinux                  vmlinux                  dst_rcu_free
>>>> 1461      1.0758  0              0  1163      0.0123  0             
>>>> 0  0              0  0              0  0              0 
>>>> 0              0  0
>>>> 0  vim                      vim                      (no symbols)
>>>> 1122      0.8262  11514     0.1896  6590      0.0694  1857     
>>>> 3.6542  7638     19.5325  2138     12.7323  1213      4.3123 
>>>> 4025     12.6278  9676      0.46
>>>> 41  libc-2.8.so              libc-2.8.so              (no symbols)
>>>> 1035      0.7621  9027      0.1487  22216     0.2341  4        
>>>> 0.0079  0              0  0              0  5         0.0178 
>>>> 15        0.0471  4310      0.20
>>>> 67  vmlinux                  vmlinux                  kmem_cache_free
>>>> 1016      0.7481  218       0.0036  465       0.0049  0             
>>>> 0  0              0  0              0  0              0 
>>>> 0              0  255       0.01
>>>> 22  vmlinux                  vmlinux                  ipv4_dst_destroy
>>>> 951       0.7002  4290      0.0707  5514      0.0581  3283     
>>>> 6.4603  867       2.2172  673       4.0079  1096      3.8963 
>>>> 1316      4.1288  2593      0.12
>>>> 44  vmlinux                  vmlinux                  tg_shares_up
>>>> 708       0.5213  104       0.0017  279       0.0029  0             
>>>> 0  0              0  0              0  0              0 
>>>> 0              0  159       0.00
>>>> 76  vmlinux                  vmlinux                  call_rcu_bh
>>>> 581       0.4278  21812     0.3593  38364     0.4042  68       
>>>> 0.1338  23        0.0588  23        0.1370  65        0.2311 
>>>> 96        0.3012  8000      0.38
>>>> 37  vmlinux                  vmlinux                  _raw_spin_unlock
>>>> 563       0.4145  1027      0.0169  2528      0.0266  0             
>>>> 0  0              0  0              0  0              0  3        
>>>> 0.0094  545       0.02
>>>> 61  vmlinux                  vmlinux                  local_bh_enable_ip
>>>> 509       0.3748  0              0  3        3.2e-05  0             
>>>> 0  0              0  0              0  4         0.0142  3        
>>>> 0.0094  76        0.00
>>>> 36  vmlinux                  vmlinux                  can_dirty
>>>> 430       0.3166  74        0.0012  148       0.0016  25       
>>>> 0.0492  13        0.0332  12        0.0715  9         0.0320 
>>>> 12        0.0376  96        0.00
>>>> 46  vmlinux                  vmlinux                 
>>>> rcu_process_callbacks
>>>> 372       0.2739  0              0  0              0  0             
>>>> 0  0              0  0              0  3         0.0107  2        
>>>> 0.0063  48        0.00
>>>> 23  vmlinux                  vmlinux                  do_journal_end
>>>> 347       0.2555  9991      0.1646  16066     0.1693  143      
>>>> 0.2814  66        0.1688  25        0.1489  46        0.1635 
>>>> 71        0.2228  3514      0.16
>>>> 85  vmlinux                  vmlinux                  rb_get_reader_page
>>>> 346       0.2548  952       0.0157  566       0.0060  871      
>>>> 1.7140  321       0.8209  174       1.0362  324       1.1518 
>>>> 269       0.8439  655       0.03
>>>> 14  vmlinux                  vmlinux                  find_busiest_group
>>>> 275       0.2025  1194      0.0197  1228      0.0129  1019     
>>>> 2.0052  203       0.5191  151       0.8992  290       1.0310 
>>>> 653       2.0487  799       0.03
>>>> 83  vmlinux                  vmlinux                  find_next_bit
>>>> 238       0.1752  3053      0.0503  4711      0.0496  116      
>>>> 0.2283  82        0.2097  54        0.3216  101       0.3591 
>>>> 101       0.3169  1174      0.05
>>>> 63  oprofile                 oprofile                 (no symbols)
>>>> 221       0.1627  0              0  0              0  0             
>>>> 0  0              0  0              0  0              0 
>>>> 0              0  18       8.6e-
>>>> 04  vmlinux                  vmlinux                  ahci_interrupt
>>>> 212       0.1561  38335     0.6314  60370     0.6361  329      
>>>> 0.6474  165       0.4220  136       0.8099  133       0.4728 
>>>> 205       0.6432  12821     0.61
>>>> 49  vmlinux                  vmlinux                 
>>>> apic_timer_interrupt
>>>> 210       0.1546  117       0.0019  1001      0.0105  2        
>>>> 0.0039  0              0  0              0  55        0.1955 
>>>> 16        0.0502  270       0.01
>>>> 30  vmlinux                  vmlinux                  memmove
>>>> 207       0.1524  0              0  7        7.4e-05  34       
>>>> 0.0669  0              0  0              0  93        0.3306 
>>>> 62        0.1945  214       0.01
>>>> 03  vmlinux                  vmlinux                  search_by_key
>>>> 204       0.1502  26603     0.4382  25086     0.2643  45       
>>>> 0.0886  18        0.0460  19        0.1131  19        0.0675 
>>>> 25        0.0784  6580      0.31
>>>> 56  vmlinux                  vmlinux                  __do_softirq
>>>> 170       0.1252  2618      0.0431  3493      0.0368  69       
>>>> 0.1358  42        0.1074  51        0.3037  64        0.2275 
>>>> 87        0.2729  856       0.04
>>>> 11  vmlinux                  vmlinux                  __schedule
>>>> 151       0.1112  7590      0.1250  8909      0.0939  273      
>>>> 0.5372  86        0.2199  73        0.4347  99        0.3519 
>>>> 142       0.4455  2114      0.10
>>>> 14  vmlinux                  vmlinux                  sched_clock_cpu
>>>> 142       0.1046  200       0.0033  165       0.0017  65       
>>>> 0.1279  23        0.0588  20        0.1191  15        0.0533 
>>>> 36        0.1129  94        0.00
>>>> 45  vmlinux                  vmlinux                  raise_softirq
>>>> 141       0.1038  8048      0.1326  11386     0.1200  2        
>>>> 0.0039  0              0  0              0  2         0.0071 
>>>> 4         0.0125  2589      0.12
>>>> 42  vmlinux                  vmlinux                  __phys_addr
>>>> 141       0.1038  23726     0.3908  24837     0.2617  89       
>>>> 0.1751  58        0.1483  55        0.3275  66        0.2346 
>>>> 62        0.1945  5398      0.25
>>>> 89  vmlinux                  vmlinux                 
>>>> tick_nohz_stop_sched_tick
>>>> 139       0.1023  43230     0.7120  68500     0.7217  105      
>>>> 0.2066  66        0.1688  86        0.5121  100       0.3555 
>>>> 100       0.3137  13725     0.65
>>>> 83  vmlinux                  vmlinux                  getnstimeofday
>>>> 136       0.1001  0              0  0              0  0             
>>>> 0  0              0  0              0  0              0 
>>>> 0              0  36        0.00
>>>> 17  vmlinux                  vmlinux                 
>>>> remove_journal_hash
>>>> 133       0.0979  8624      0.1420  9518      0.1003  217      
>>>> 0.4270  68        0.1739  64        0.3811  79        0.2808 
>>>> 106       0.3326  2348      0.11
>>>> 26  vmlinux                  vmlinux                  native_sched_clock
>>>> 129       0.0950  270       0.0044  233       0.0025  355      
>>>> 0.6986  93        0.2378  60        0.3573  102       0.3626 
>>>> 105       0.3294  214       0.01
>>>> 03  vmlinux                  vmlinux                  rebalance_domains
>>>> 117       0.0861  0              0  36       3.8e-04  57       
>>>> 0.1122  0              0  10        0.0596  66        0.2346 
>>>> 60        0.1882  220       0.01
>>>> 06  vmlinux                  vmlinux                  find_get_page
>>>> 112       0.0825  287       0.0047  397       0.0042  121      
>>>> 0.2381  89        0.2276  63        0.3752  85        0.3022 
>>>> 114       0.3577  220       0.01
>>>> 06  vmlinux                  vmlinux                  scheduler_tick
>>>> 107       0.0788  13702     0.2257  16191     0.1706  102      
>>>> 0.2007  28        0.0716  44        0.2620  41        0.1458 
>>>> 66        0.2071  3890      0.18
>>>> 66  vmlinux                  vmlinux                 
>>>> tick_nohz_stop_idle
>>>> 105       0.0773  4277      0.0704  7002      0.0738  53       
>>>> 0.1043  26        0.0665  24        0.1429  24        0.0853 
>>>> 38        0.1192  1561      0.07
>>>> 49  vmlinux                  vmlinux                 
>>>> ring_buffer_consume
>>>> 103       0.0758  0              0  2        2.1e-05  5        
>>>> 0.0098  0              0  0              0  20        0.0711 
>>>> 13        0.0408  61        0.00
>>>> 29  vmlinux                  vmlinux                  __find_get_block
>>>> 103       0.0758  49251     0.8112  85999     0.9061  166      
>>>> 0.3267  105       0.2685  97        0.5777  122       0.4337 
>>>> 138       0.4330  17108     0.82
>>>> 06  vmlinux                  vmlinux                  read_tsc
>>>> 98        0.0722  17406     0.2867  40897     0.4309  15       
>>>> 0.0295  2         0.0051  2         0.0119  62        0.2204 
>>>> 51        0.1600  7913      0.37
>>>> 95  vmlinux                  vmlinux                  kmem_cache_alloc
>>>> 98        0.0722  14817     0.2440  21291     0.2243  41       
>>>> 0.0807  49        0.1253  48        0.2859  62        0.2204 
>>>> 64        0.2008  4582      0.21
>>>> 98  vmlinux                  vmlinux                  ktime_get_ts
>>>> 94        0.0692  0              0  1        1.1e-05  2        
>>>> 0.0039  0              0  0              0  7         0.0249 
>>>> 6         0.0188  16       7.7e-
>>>> 04  vmlinux                  vmlinux                 
>>>> __find_get_block_slow
>>>> 92        0.0677  1161      0.0191  1411      0.0149  41       
>>>> 0.0807  39        0.0997  40        0.2382  53        0.1884 
>>>> 49        0.1537  408       0.01
>>>> 96  vmlinux                  vmlinux                 
>>>> select_nohz_load_balancer
>>>> 88        0.0648  11160     0.1838  54990     0.5794  69       
>>>> 0.1358  43        0.1100  35        0.2084  661       2.3499 
>>>> 55        0.1726  4513      0.21
>>>> 65  vmlinux                  vmlinux                 
>>>> get_next_timer_interrupt
>>>> 75        0.0552  0              0  0              0  0             
>>>> 0  0              0  0              0  0              0 
>>>> 0              0  6        2.9e-
>>>> 04  vmlinux                  vmlinux                  make_request
>>>> 69        0.0508  803       0.0132  1048      0.0110  35       
>>>> 0.0689  26        0.0665  15        0.0893  24        0.0853 
>>>> 58        0.1820  334       0.01
>>>> --More--
>>>>
>>>> Pawe³ Staszewski pisze:
>>>>         
>>>>> I dont know where to put this message so i start here because server
>>>>> that i see this funny thing is make only networking
>>>>> Routing (bgpd) / traffic management (iproute2)
>>>>>
>>>>> This starts on kernels >= 2.6.29
>>>>>
>>>>> On server i have almost constant traffic that is about 300Mbit/s RX
>>>>> and 300Mbit/s TX
>>>>> Server have two interfaces:
>>>>> 04:00.0 Ethernet controller: Intel Corporation 82573E Gigabit
>>>>> Ethernet Controller (Copper) (rev 03)
>>>>> 05:00.0 Ethernet controller: Intel Corporation 82573L Gigabit
>>>>> Ethernet Controller
>>>>>
>>>>> iBGP peer < - > [ eth0 - forward + shaping - eth1 ] < - >  eBGP
>>>>>
>>>>>
>>>>> And what is weird is CPU Load
>>>>> it fluctuate from 10% to almost 80% - but traffic is  constant :
>>>>> bwm-ng v0.6 (probing every 10.000s), press 'h' for help
>>>>>  input: /proc/net/dev type: rate
>>>>>  |         iface                   Rx                  
>>>>> Tx                Total
>>>>>  
>>>>> ==============================================================================
>>>>>
>>>>>               lo:           0.00  b/s            0.00 
>>>>> b/s            0.00  b/s
>>>>>             eth0:         200.22 Mb/s          266.74 Mb/s         
>>>>> 466.96 Mb/s
>>>>>             eth1:         264.00 Mb/s          192.59 Mb/s         
>>>>> 456.59 Mb/s
>>>>>  
>>>>> ------------------------------------------------------------------------------
>>>>>
>>>>>            total:         464.22 Mb/s          459.34 Mb/s         
>>>>> 923.56 Mb/s
>>>>>
>>>>>
>>>>> bwm-ng v0.6 (probing every 10.000s), press 'h' for help
>>>>>  input: /proc/net/dev type: rate
>>>>>  /         iface                   Rx                  
>>>>> Tx                Total
>>>>>  
>>>>> ==============================================================================
>>>>>
>>>>>               lo:            0.00 P/s             0.00
>>>>> P/s             0.00 P/s
>>>>>             eth0:        51314.95 P/s         49880.20 P/s       
>>>>> 101195.14 P/s
>>>>>             eth1:        43309.85 P/s         41885.79 P/s        
>>>>> 85195.64 P/s
>>>>>  
>>>>> ------------------------------------------------------------------------------
>>>>>
>>>>>            total:        94624.80 P/s         91765.99 P/s       
>>>>> 186390.79 P/s
>>>>>
>>>>>
>>>>> mpstat -P ALL 1
>>>>> 18:00:05     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:06     all    0.00    0.00    0.00    0.00    1.33   13.65   
>>>>> 0.00    0.00   85.02
>>>>> 18:00:06       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:06       1    0.00    0.00    0.00    0.00    3.77   39.62   
>>>>> 0.00    0.00   56.60
>>>>> 18:00:06       2    0.00    0.00    0.00    0.00    7.92   70.30   
>>>>> 0.00    0.00   21.78
>>>>> 18:00:06       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:06       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:06       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:06       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:06       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:06     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:07     all    0.12    0.00    0.12    0.00    1.19   13.35   
>>>>> 0.00    0.00   85.22
>>>>> 18:00:07       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:07       1    0.00    0.00    0.00    0.00    2.75   42.20   
>>>>> 0.00    0.00   55.05
>>>>> 18:00:07       2    0.00    0.00    0.99    0.00    5.94   65.35   
>>>>> 0.00    0.00   27.72
>>>>> 18:00:07       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:07       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:07       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:07       6    0.00    0.00    0.99    0.00    0.00    0.00   
>>>>> 0.00    0.00   99.01
>>>>> 18:00:07       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:07     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:08     all    0.00    0.00    0.12    0.00    0.85   13.42   
>>>>> 0.00    0.00   85.61
>>>>> 18:00:08       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:08       1    0.00    0.00    0.00    0.00    1.85   38.89   
>>>>> 0.00    0.00   59.26
>>>>> 18:00:08       2    0.00    0.00    0.00    0.00    5.94   68.32   
>>>>> 0.00    0.00   25.74
>>>>> 18:00:08       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:08       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:08       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:08       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:08       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:08     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:09     all    0.00    0.00    0.00    0.00    1.33   14.18   
>>>>> 0.00    0.00   84.48
>>>>> 18:00:09       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:09       1    0.00    0.00    0.99    0.00    2.97   50.50   
>>>>> 0.00    0.00   45.54
>>>>> 18:00:09       2    0.00    0.00    0.00    0.00    6.93   65.35   
>>>>> 0.00    0.00   27.72
>>>>> 18:00:09       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:09       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:09       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:09       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:09       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:09     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:10     all    0.00    0.00    0.24    0.00    1.20   11.81   
>>>>> 0.00    0.00   86.75
>>>>> 18:00:10       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:10       1    0.00    0.00    0.95    0.00    4.76   35.24   
>>>>> 0.00    0.00   59.05
>>>>> 18:00:10       2    0.00    0.00    0.00    0.00    4.95   59.41   
>>>>> 0.00    0.00   35.64
>>>>> 18:00:10       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:10       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:10       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:10       6    0.00    0.00    0.95    0.00    0.00    0.00   
>>>>> 0.00    0.00   99.05
>>>>> 18:00:10       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:10     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:11     all    0.00    0.00    0.24    0.00    0.36    5.97   
>>>>> 0.00    0.00   93.43
>>>>> 18:00:11       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:11       1    0.00    0.00    0.97    0.00    0.97   17.48   
>>>>> 0.00    0.00   80.58
>>>>> 18:00:11       2    0.00    0.00    0.00    0.00    2.88   31.73   
>>>>> 0.00    0.00   65.38
>>>>> 18:00:11       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:11       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:11       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:11       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:11       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:11     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:12     all    0.00    0.00    0.25    0.00    0.37    5.76   
>>>>> 0.00    0.00   93.63
>>>>> 18:00:12       0    0.00    0.00    0.00    1.06    0.00    0.00   
>>>>> 0.00    0.00   98.94
>>>>> 18:00:12       1    0.00    0.00    1.92    0.00    0.00   18.27   
>>>>> 0.00    0.00   79.81
>>>>> 18:00:12       2    0.00    0.00    0.96    0.00    1.92   26.92   
>>>>> 0.00    0.00   70.19
>>>>> 18:00:12       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:12       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:12       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:12       6    0.96    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00   99.04
>>>>> 18:00:12       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:12     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:13     all    0.12    0.00    0.25    0.00    0.12    2.34   
>>>>> 0.00    0.00   97.17
>>>>> 18:00:13       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:13       1    0.00    0.00    0.00    0.00    0.97    7.77   
>>>>> 0.00    0.00   91.26
>>>>> 18:00:13       2    0.00    0.00    0.98    0.00    0.98   10.78   
>>>>> 0.00    0.00   87.25
>>>>> 18:00:13       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:13       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:13       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:13       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:13       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:13     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:14     all    0.00    0.00    0.37    0.00    0.37    2.33   
>>>>> 0.00    0.00   96.94
>>>>> 18:00:14       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:14       1    0.00    0.00    1.92    0.00    0.96    7.69   
>>>>> 0.00    0.00   89.42
>>>>> 18:00:14       2    0.00    0.00    0.97    0.00    0.97   10.68   
>>>>> 0.00    0.00   87.38
>>>>> 18:00:14       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:14       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:14       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:14       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:14       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:14     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:15     all    0.00    0.00    0.61    0.00    0.25    2.45   
>>>>> 0.00    0.00   96.69
>>>>> 18:00:15       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:15       1    0.00    0.00    3.85    0.00    0.96    7.69   
>>>>> 0.00    0.00   87.50
>>>>> 18:00:15       2    0.00    0.00    0.96    0.00    1.92   12.50   
>>>>> 0.00    0.00   84.62
>>>>> 18:00:15       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:15       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:15       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:15       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:15       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:15     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:16     all    0.00    0.00    0.37    0.00    0.37    1.83   
>>>>> 0.00    0.00   97.43
>>>>> 18:00:16       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:16       1    0.00    0.00    1.96    0.00    0.98    4.90   
>>>>> 0.00    0.00   92.16
>>>>> 18:00:16       2    0.00    0.00    1.00    0.00    1.00   10.00   
>>>>> 0.00    0.00   88.00
>>>>> 18:00:16       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:16       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:16       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:16       6    0.98    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00   99.02
>>>>> 18:00:16       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:16     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:17     all    0.00    0.00    0.25    0.00    0.25    2.73   
>>>>> 0.00    0.00   96.78
>>>>> 18:00:17       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:17       1    0.00    0.00    1.96    0.00    0.00    8.82   
>>>>> 0.00    0.00   89.22
>>>>> 18:00:17       2    0.00    0.00    0.99    0.00    1.98   11.88   
>>>>> 0.00    0.00   85.15
>>>>> 18:00:17       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:17       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:17       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:17       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:17       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:17     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:18     all    0.12    0.00    0.12    0.00    0.95   11.51   
>>>>> 0.00    0.00   87.31
>>>>> 18:00:18       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:18       1    0.00    0.00    0.00    0.00    3.03   33.33   
>>>>> 0.00    0.00   63.64
>>>>> 18:00:18       2    0.00    0.00    0.00    0.00    5.00   64.00   
>>>>> 0.00    0.00   31.00
>>>>> 18:00:18       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:18       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:18       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:18       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:18       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:18     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:19     all    0.36    0.00    0.12    0.00    1.46   14.48   
>>>>> 0.00    0.00   83.58
>>>>> 18:00:19       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:19       1    0.00    0.00    0.00    0.00    4.00   46.00   
>>>>> 0.00    0.00   50.00
>>>>> 18:00:19       2    0.00    0.00    0.99    0.00    7.92   72.28   
>>>>> 0.00    0.00   18.81
>>>>> 18:00:19       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:19       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:19       5    2.86    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00   97.14
>>>>> 18:00:19       6    0.95    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00   99.05
>>>>> 18:00:19       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:19     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:20     all    0.00    0.00    0.00    0.00    1.58   14.86   
>>>>> 0.00    0.00   83.56
>>>>> 18:00:20       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:20       1    0.00    0.00    0.00    0.00    3.96   49.50   
>>>>> 0.00    0.00   46.53
>>>>> 18:00:20       2    0.00    0.00    0.00    0.00    9.00   73.00   
>>>>> 0.00    0.00   18.00
>>>>> 18:00:20       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:20       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:20       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:20       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:20       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:20     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:21     all    0.00    0.00    0.00    0.00    1.71   14.86   
>>>>> 0.00    0.00   83.43
>>>>> 18:00:21       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:21       1    0.00    0.00    0.00    0.00    5.05   51.52   
>>>>> 0.00    0.00   43.43
>>>>> 18:00:21       2    0.00    0.00    0.00    0.00   10.00   70.00   
>>>>> 0.00    0.00   20.00
>>>>> 18:00:21       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:21       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:21       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:21       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:21       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:21     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:22     all    0.00    0.00    0.24    0.00    1.70   13.97   
>>>>> 0.00    0.00   84.08
>>>>> 18:00:22       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:22       1    0.00    0.00    0.00    0.00    4.95   42.57   
>>>>> 0.00    0.00   52.48
>>>>> 18:00:22       2    0.00    0.00    1.01    0.00    8.08   72.73   
>>>>> 0.00    0.00   18.18
>>>>> 18:00:22       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:22       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:22       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:22       6    0.00    0.00    0.95    0.00    0.00    0.00   
>>>>> 0.00    0.00   99.05
>>>>> 18:00:22       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:22     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:23     all    0.12    0.00    0.00    0.00    1.58   14.13   
>>>>> 0.00    0.00   84.17
>>>>> 18:00:23       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:23       1    0.00    0.00    0.00    0.00    5.00   45.00   
>>>>> 0.00    0.00   50.00
>>>>> 18:00:23       2    0.99    0.00    0.00    0.00    8.91   70.30   
>>>>> 0.00    0.00   19.80
>>>>> 18:00:23       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:23       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:23       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:23       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:23       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:23     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:24     all    0.00    0.00    0.00    0.00    1.34   14.13   
>>>>> 0.00    0.00   84.53
>>>>> 18:00:24       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:24       1    0.00    0.00    0.00    0.00    4.04   42.42   
>>>>> 0.00    0.00   53.54
>>>>> 18:00:24       2    0.00    0.00    0.00    0.00    6.93   73.27   
>>>>> 0.00    0.00   19.80
>>>>> 18:00:24       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:24       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:24       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:24       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:24       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:24     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:25     all    0.12    0.00    0.12    0.00    1.45   14.67   
>>>>> 0.00    0.00   83.64
>>>>> 18:00:25       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:25       1    0.00    0.00    0.99    0.00    3.96   45.54   
>>>>> 0.00    0.00   49.50
>>>>> 18:00:25       2    0.00    0.00    0.00    0.00    8.00   75.00   
>>>>> 0.00    0.00   17.00
>>>>> 18:00:25       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:25       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:25       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:25       6    0.95    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00   99.05
>>>>> 18:00:25       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:25     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:26     all    0.00    0.00    0.00    0.00    1.22   14.60   
>>>>> 0.00    0.00   84.18
>>>>> 18:00:26       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:26       1    0.99    0.00    0.00    0.00    2.97   50.50   
>>>>> 0.00    0.00   45.54
>>>>> 18:00:26       2    0.00    0.00    0.00    0.00    7.07   68.69   
>>>>> 0.00    0.00   24.24
>>>>> 18:00:26       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:26       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:26       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:26       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:26       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:26     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:27     all    0.00    0.00    0.00    0.00    1.59   15.02   
>>>>> 0.00    0.00   83.39
>>>>> 18:00:27       0    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:27       1    0.00    0.00    0.00    0.00    6.00   52.00   
>>>>> 0.00    0.00   42.00
>>>>> 18:00:27       2    0.00    0.00    0.00    0.00    6.93   71.29   
>>>>> 0.00    0.00   21.78
>>>>> 18:00:27       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:27       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:27       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:27       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:27       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> 18:00:27     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
>>>>> %steal  %guest   %idle
>>>>> 18:00:28     all    0.00    0.00    0.00    0.00    1.33   14.56   
>>>>> 0.00    0.00   84.10
>>>>> 18:00:28       0    0.00    0.00    0.00    0.00    0.00    0.99   
>>>>> 0.00    0.00   99.01
>>>>> 18:00:28       1    0.00    0.00    0.00    0.00    4.00   50.00   
>>>>> 0.00    0.00   46.00
>>>>> 18:00:28       2    0.00    0.00    0.00    0.00    6.06   69.70   
>>>>> 0.00    0.00   24.24
>>>>> 18:00:28       3    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:28       4    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:28       5    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:28       6    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>> 18:00:28       7    0.00    0.00    0.00    0.00    0.00    0.00   
>>>>> 0.00    0.00  100.00
>>>>>
>>>>> at the same time top shows:
>>>>>  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
>>>>>   28 root      15  -5     0    0    0 S    2  0.0   0:16.60 events/1
>>>>>   29 root      15  -5     0    0    0 S    2  0.0   0:15.62 events/2
>>>>>   10 root      15  -5     0    0    0 S    2  0.0   0:41.01 ksoftirqd/2
>>>>>    7 root      15  -5     0    0    0 S    1  0.0   0:31.17 ksoftirqd/1
>>>>>   30 root      15  -5     0    0    0 S    1  0.0   0:03.00 events/3
>>>>> 6545 root      20   0 11112 3244 1780 S    0  0.0   0:08.69 oprofiled
>>>>> 6845 root      20   0 19084 1384 1008 R    0  0.0   0:00.07 top
>>>>>    1 root      20   0  3812  612  520 S    0  0.0   0:01.00 init
>>>>>    2 root      15  -5     0    0    0 S    0  0.0   0:00.00 kthreadd
>>>>>    3 root      RT  -5     0    0    0 S    0  0.0   0:00.00 migration/0
>>>>>    4 root      15  -5     0    0    0 S    0  0.0   0:01.04 ksoftirqd/0
>>>>>    5 root      RT  -5     0    0    0 S    0  0.0   0:00.00 watchdog/0
>>>>>    6 root      RT  -5     0    0    0 S    0  0.0   0:00.00 migration/1
>>>>>    8 root      RT  -5     0    0    0 S    0  0.0   0:00.00 watchdog/1
>>>>>    9 root      RT  -5     0    0    0 S    0  0.0   0:00.00 migration/2
>>>>>   11 root      RT  -5     0    0    0 S    0  0.0   0:00.00 watchdog/2
>>>>>   12 root      RT  -5     0    0    0 S    0  0.0   0:00.00 migration/3
>>>>>   13 root      15  -5     0    0    0 S    0  0.0   0:00.00 ksoftirqd/3
>>>>>   14 root      RT  -5     0    0    0 S    0  0.0   0:00.00 watchdog/3
>>>>>   15 root      RT  -5     0    0    0 S    0  0.0   0:00.00 migration/4
>>>>>   16 root      15  -5     0    0    0 S    0  0.0   0:00.00 ksoftirqd/4
>>>>>   17 root      RT  -5     0    0    0 S    0  0.0   0:00.00 watchdog/4
>>>>>   18 root      RT  -5     0    0    0 S    0  0.0   0:00.00 migration/5
>>>>>   19 root      15  -5     0    0    0 S    0  0.0   0:00.00 ksoftirqd/5
>>>>>   20 root      RT  -5     0    0    0 S    0  0.0   0:00.00 watchdog/5
>>>>>   21 root      RT  -5     0    0    0 S    0  0.0   0:00.00 migration/6
>>>>>   22 root      15  -5     0    0    0 S    0  0.0   0:00.00 ksoftirqd/6
>>>>>   23 root      RT  -5     0    0    0 S    0  0.0   0:00.00 watchdog/6
>>>>>   24 root      RT  -5     0    0    0 S    0  0.0   0:00.00 migration/7
>>>>>   25 root      15  -5     0    0    0 S    0  0.0   0:00.00 ksoftirqd/7
>>>>>   26 root      RT  -5     0    0    0 S    0  0.0   0:00.00 watchdog/7
>>>>>   27 root      15  -5     0    0    0 S    0  0.0   0:00.00 events/0
>>>>>   31 root      15  -5     0    0    0 S    0  0.0   0:00.00 events/4
>>>>>   32 root      15  -5     0    0    0 S    0  0.0   0:00.01 events/5
>>>>>   33 root      15  -5     0    0    0 S    0  0.0   0:00.02 events/6
>>>>>   34 root      15  -5     0    0    0 S    0  0.0   0:00.01 events/7
>>>>>   35 root      15  -5     0    0    0 S    0  0.0   0:00.01 khelper
>>>>>   41 root      15  -5     0    0    0 S    0  0.0   0:00.00 async/mgr
>>>>>  159 root      15  -5     0    0    0 S    0  0.0   0:00.00 kblockd/0
>>>>>  160 root      15  -5     0    0    0 S    0  0.0   0:00.00 kblockd/1
>>>>>  161 root      15  -5     0    0    0 S    0  0.0   0:00.00 kblockd/2
>>>>>  162 root      15  -5     0    0    0 S    0  0.0   0:00.00 kblockd/3
>>>>>  163 root      15  -5     0    0    0 S    0  0.0   0:00.00 kblockd/4
>>>>>  164 root      15  -5     0    0    0 S    0  0.0   0:00.00 kblockd/5
>>>>>  165 root      15  -5     0    0    0 S    0  0.0   0:00.00 kblockd/6
>>>>>  166 root      15  -5     0    0    0 S    0  0.0   0:00.00 kblockd/7
>>>>>  167 root      15  -5     0    0    0 S    0  0.0   0:00.00 kacpid
>>>>>  168 root      15  -5     0    0    0 S    0  0.0   0:00.00
>>>>> kacpi_notify
>>>>>  246 root      15  -5     0    0    0 S    0  0.0   0:00.00 ata/0
>>>>>  247 root      15  -5     0    0    0 S    0  0.0   0:00.00 ata/1
>>>>>
>>>>> and oprofile output:
>>>>> CPU: Core 2, speed 3000.08 MHz (estimated)
>>>>> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with
>>>>> a unit mask of 0x00 (Unhalted core cycles) count 100000
>>>>> samples  %        image name               app name                
>>>>> symbol name
>>>>> 11138304 12.3598  vmlinux                  vmlinux                 
>>>>> rb_next
>>>>> 7714260   8.5602  vmlinux                  vmlinux                 
>>>>> e1000_clean
>>>>> 5380466   5.9705  vmlinux                  vmlinux                 
>>>>> e1000_intr_msi
>>>>> 4881445   5.4168  vmlinux                  vmlinux                 
>>>>> u32_classify
>>>>> 3977072   4.4132  vmlinux                  vmlinux                 
>>>>> _raw_spin_lock
>>>>> 3471611   3.8523  vmlinux                  vmlinux                 
>>>>> hfsc_dequeue
>>>>> 3103493   3.4438  vmlinux                  vmlinux                 
>>>>> hfsc_enqueue
>>>>> 2636824   2.9260  vmlinux                  vmlinux                 
>>>>> delay_tsc
>>>>> 2464293   2.7345  vmlinux                  vmlinux                 
>>>>> e1000_xmit_frame
>>>>> 2035779   2.2590  vmlinux                  vmlinux                 
>>>>> e1000_clean_tx_irq
>>>>> 1947231   2.1608  vmlinux                  vmlinux                 
>>>>> mwait_idle
>>>>> 1919540   2.1300  vmlinux                  vmlinux                 
>>>>> ipt_do_table
>>>>> 1908544   2.1178  vmlinux                  vmlinux                 
>>>>> e1000_clean_rx_irq
>>>>> 1865996   2.0706  vmlinux                  vmlinux                 
>>>>> update_vf
>>>>> 1829293   2.0299  vmlinux                  vmlinux                 
>>>>> rb_erase
>>>>> 1777847   1.9728  vmlinux                  vmlinux                 
>>>>> ip_route_input
>>>>> 1430773   1.5877  vmlinux                  vmlinux                 
>>>>> rb_insert_color
>>>>> 1329674   1.4755  vmlinux                  vmlinux                 
>>>>> __alloc_skb
>>>>> 1091678   1.2114  vmlinux                  vmlinux                 
>>>>> sfq_enqueue
>>>>> 985105    1.0931  vmlinux                  vmlinux                 
>>>>> rb_first
>>>>> 944928    1.0486  vmlinux                  vmlinux                 
>>>>> sfq_dequeue
>>>>> 756452    0.8394  vmlinux                  vmlinux                 
>>>>> read_tsc
>>>>> 728703    0.8086  vmlinux                  vmlinux                 
>>>>> nf_iterate
>>>>> 665551    0.7385  vmlinux                  vmlinux                 
>>>>> ip_forward
>>>>> 662616    0.7353  vmlinux                  vmlinux                 
>>>>> dev_queue_xmit
>>>>> 648919    0.7201  vmlinux                  vmlinux                 
>>>>> __qdisc_run
>>>>> 615592    0.6831  vmlinux                  vmlinux                 
>>>>> ip_rcv
>>>>> 589743    0.6544  vmlinux                  vmlinux                 
>>>>> apic_timer_interrupt
>>>>> 550581    0.6110  vmlinux                  vmlinux                 
>>>>> irq_entries_start
>>>>> 536172    0.5950  vmlinux                  vmlinux                 
>>>>> getnstimeofday
>>>>> 527467    0.5853  vmlinux                  vmlinux                 
>>>>> rb_last
>>>>> 508305    0.5640  vmlinux                  vmlinux                 
>>>>> skb_release_data
>>>>> 506763    0.5623  vmlinux                  vmlinux                 
>>>>> kfree
>>>>> 506269    0.5618  vmlinux                  vmlinux                 
>>>>> dst_release
>>>>> 464412    0.5153  vmlinux                  vmlinux                 
>>>>> __hrtimer_start_range_ns
>>>>> 456354    0.5064  vmlinux                  vmlinux                 
>>>>> e1000_alloc_rx_buffers
>>>>> 435339    0.4831  vmlinux                  vmlinux                 
>>>>> dev_hard_start_xmit
>>>>> 371439    0.4122  vmlinux                  vmlinux                 
>>>>> local_bh_enable
>>>>> 369266    0.4098  vmlinux                  vmlinux                 
>>>>> __rb_rotate_left
>>>>> 361627    0.4013  vmlinux                  vmlinux                 
>>>>> net_tx_action
>>>>> 357797    0.3970  vmlinux                  vmlinux                 
>>>>> rtsc_y2x
>>>>> 350595    0.3890  vmlinux                  vmlinux                 
>>>>> _raw_spin_unlock
>>>>> 349359    0.3877  vmlinux                  vmlinux                 
>>>>> kmem_cache_alloc
>>>>> 336255    0.3731  vmlinux                  vmlinux                 
>>>>> skb_dma_map
>>>>> 328809    0.3649  vmlinux                  vmlinux                 
>>>>> netif_receive_skb
>>>>> 315826    0.3505  vmlinux                  vmlinux                 
>>>>> fn_trie_lookup
>>>>> 313065    0.3474  vmlinux                  vmlinux                 
>>>>> __kmalloc
>>>>> 307684    0.3414  vmlinux                  vmlinux                 
>>>>> __do_softirq
>>>>> 298676    0.3314  vmlinux                  vmlinux                 
>>>>> skb_pull
>>>>> 292352    0.3244  vmlinux                  vmlinux                 
>>>>> __napi_complete
>>>>> 288878    0.3206  vmlinux                  vmlinux                 
>>>>> get_next_timer_interrupt
>>>>> 280449    0.3112  vmlinux                  vmlinux                 
>>>>> ip_finish_output
>>>>> 264482    0.2935  vmlinux                  vmlinux                 
>>>>> consume_skb
>>>>> 251622    0.2792  vmlinux                  vmlinux                 
>>>>> __remove_hrtimer
>>>>> 227178    0.2521  vmlinux                  vmlinux                 
>>>>> tc_classify_compat
>>>>> 226224    0.2510  vmlinux                  vmlinux                 
>>>>> handle_edge_irq
>>>>>
>>>>>
>>>>>
>>>>> proces that this machine is running is only quagga (zebra + bgpd +
>>>>> oprofiled)
>>>>>
>>>>>
>>>>> Regards
>>>>> Pawe³ Staszewski
>>>>>
>>>>>
>>>>> -- 
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>
>>>>>
>>>>>           
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>>
>>>>         
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>>       
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>     
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   


--------------040802030102000607070906
Content-Type: text/plain;
 name="kern-conf"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kern-conf"

# CONFIG_64BIT is not set
CONFIG_X86_32=y
# CONFIG_X86_64 is not set
CONFIG_X86=y
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_FAST_CMPXCHG_LOCAL=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
# CONFIG_GENERIC_TIME_VSYSCALL is not set
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_HAVE_DYNAMIC_PER_CPU_AREA=y
# CONFIG_HAVE_CPUMASK_OF_CPU_MAP is not set
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
# CONFIG_ZONE_DMA32 is not set
CONFIG_ARCH_POPULATES_NODE_MAP=y
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_X86_32_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_TRAMPOLINE=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_KTIME_SCALAR=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
# CONFIG_AUDIT is not set

#
# RCU Subsystem
#
CONFIG_CLASSIC_RCU=y
# CONFIG_TREE_RCU is not set
# CONFIG_PREEMPT_RCU is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_PREEMPT_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=18
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_GROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_USER_SCHED=y
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUPS is not set
CONFIG_SYSFS_DEPRECATED=y
CONFIG_SYSFS_DEPRECATED_V2=y
CONFIG_RELAY=y
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
# CONFIG_NET_NS is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EMBEDDED is not set
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_EXTRA_PASS is not set
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_MARKERS=y
CONFIG_OPROFILE=m
# CONFIG_OPROFILE_IBS is not set
CONFIG_HAVE_OPROFILE=y
# CONFIG_KPROBES is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_API_DEBUG=y
# CONFIG_SLOW_WORK is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
# CONFIG_LBD is not set
# CONFIG_BLK_DEV_BSG is not set
# CONFIG_BLK_DEV_INTEGRITY is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_AS is not set
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
CONFIG_SPARSE_IRQ=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_BIGSMP is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_ELAN is not set
# CONFIG_X86_RDC321X is not set
# CONFIG_X86_32_NON_STANDARD is not set
CONFIG_SCHED_OMIT_FRAME_POINTER=y
# CONFIG_PARAVIRT_GUEST is not set
# CONFIG_MEMTEST is not set
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_CPU=y
CONFIG_X86_L1_CACHE_BYTES=64
CONFIG_X86_INTERNODE_CACHE_BYTES=64
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INVLPG=y
CONFIG_X86_BSWAP=y
CONFIG_X86_POPAD_OK=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
# CONFIG_X86_DS is not set
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
# CONFIG_IOMMU_HELPER is not set
CONFIG_IOMMU_API=y
CONFIG_NR_CPUS=8
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set
CONFIG_VM86=y
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
# CONFIG_X86_REBOOTFIXUPS is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
# CONFIG_X86_CPU_DEBUG is not set
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_HIGHMEM=y
# CONFIG_ARCH_PHYS_ADDR_T_64BIT is not set
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_DISCONTIGMEM_MANUAL is not set
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_UNEVICTABLE_LRU=y
CONFIG_HAVE_MLOCK=y
CONFIG_HAVE_MLOCKED_PAGE_BIT=y
CONFIG_HIGHPTE=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW_64K=y
# CONFIG_MATH_EMULATION is not set
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x100000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_HOTPLUG_CPU is not set
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOOLPC is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_DMAR=y
CONFIG_DMAR_DEFAULT_ON=y
CONFIG_DMAR_GFX_WA=y
CONFIG_DMAR_FLOPPY_WA=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_LEGACY is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
# CONFIG_MCA is not set
# CONFIG_SCx200 is not set
# CONFIG_OLPC is not set
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_HAVE_AOUT=y
# CONFIG_BINFMT_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
CONFIG_UNIX=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_ASK_IP_FIB_HASH is not set
CONFIG_IP_FIB_TRIE=y
# CONFIG_IP_FIB_HASH is not set
# CONFIG_IP_FIB_TRIE_STATS is not set
# CONFIG_IP_MULTIPLE_TABLES is not set
# CONFIG_IP_ROUTE_MULTIPATH is not set
# CONFIG_IP_ROUTE_VERBOSE is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_LRO is not set
# CONFIG_INET_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
# CONFIG_TCP_CONG_HSTCP is not set
# CONFIG_TCP_CONG_HYBLA is not set
# CONFIG_TCP_CONG_VEGAS is not set
# CONFIG_TCP_CONG_SCALABLE is not set
# CONFIG_TCP_CONG_LP is not set
# CONFIG_TCP_CONG_VENO is not set
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y

#
# Core Netfilter Configuration
#
# CONFIG_NETFILTER_NETLINK_QUEUE is not set
# CONFIG_NETFILTER_NETLINK_LOG is not set
# CONFIG_NF_CONNTRACK is not set
CONFIG_NETFILTER_XTABLES=y
# CONFIG_NETFILTER_XT_TARGET_CLASSIFY is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
# CONFIG_NETFILTER_XT_TARGET_NFLOG is not set
# CONFIG_NETFILTER_XT_TARGET_NFQUEUE is not set
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
# CONFIG_NETFILTER_XT_TARGET_TRACE is not set
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set
# CONFIG_NETFILTER_XT_MATCH_COMMENT is not set
# CONFIG_NETFILTER_XT_MATCH_DCCP is not set
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
# CONFIG_NETFILTER_XT_MATCH_ESP is not set
# CONFIG_NETFILTER_XT_MATCH_HASHLIMIT is not set
# CONFIG_NETFILTER_XT_MATCH_HL is not set
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
# CONFIG_NETFILTER_XT_MATCH_LENGTH is not set
# CONFIG_NETFILTER_XT_MATCH_LIMIT is not set
# CONFIG_NETFILTER_XT_MATCH_MAC is not set
CONFIG_NETFILTER_XT_MATCH_MARK=y
# CONFIG_NETFILTER_XT_MATCH_MULTIPORT is not set
# CONFIG_NETFILTER_XT_MATCH_OWNER is not set
# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set
# CONFIG_NETFILTER_XT_MATCH_QUOTA is not set
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
# CONFIG_NETFILTER_XT_MATCH_REALM is not set
# CONFIG_NETFILTER_XT_MATCH_RECENT is not set
# CONFIG_NETFILTER_XT_MATCH_SCTP is not set
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
# CONFIG_NETFILTER_XT_MATCH_STRING is not set
# CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set
# CONFIG_NETFILTER_XT_MATCH_TIME is not set
CONFIG_NETFILTER_XT_MATCH_U32=y
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
# CONFIG_NF_DEFRAG_IPV4 is not set
# CONFIG_IP_NF_QUEUE is not set
CONFIG_IP_NF_IPTABLES=y
# CONFIG_IP_NF_MATCH_ADDRTYPE is not set
# CONFIG_IP_NF_MATCH_AH is not set
# CONFIG_IP_NF_MATCH_ECN is not set
# CONFIG_IP_NF_MATCH_TTL is not set
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_LOG=y
# CONFIG_IP_NF_TARGET_ULOG is not set
# CONFIG_IP_NF_MANGLE is not set
# CONFIG_IP_NF_TARGET_TTL is not set
CONFIG_IP_NF_RAW=y
# CONFIG_IP_NF_ARPTABLES is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_PHONET is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
# CONFIG_NET_SCH_CBQ is not set
# CONFIG_NET_SCH_HTB is not set
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFQ=y
# CONFIG_NET_SCH_TEQL is not set
# CONFIG_NET_SCH_TBF is not set
CONFIG_NET_SCH_GRED=y
# CONFIG_NET_SCH_DSMARK is not set
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_DRR=y

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
# CONFIG_NET_CLS_TCINDEX is not set
# CONFIG_NET_CLS_ROUTE4 is not set
# CONFIG_NET_CLS_FW is not set
CONFIG_NET_CLS_U32=y
# CONFIG_CLS_U32_PERF is not set
# CONFIG_CLS_U32_MARK is not set
# CONFIG_NET_CLS_RSVP is not set
# CONFIG_NET_CLS_RSVP6 is not set
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set

#
# Network testing
#
CONFIG_NET_PKTGEN=m
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_BLK_DEV_XIP is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set
CONFIG_MISC_DEVICES=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_93CX6 is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
# CONFIG_IDE_GD_ATAPI is not set
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
CONFIG_BLK_DEV_AMD74XX=y
CONFIG_BLK_DEV_ATIIXP=y
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_CS5535 is not set
# CONFIG_BLK_DEV_CS5536 is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
CONFIG_BLK_DEV_PDC202XX_NEW=y
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=4000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_LIBFC is not set
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_NSP32 is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y
CONFIG_SATA_AHCI=y
CONFIG_SATA_SIL24=y
CONFIG_ATA_SFF=y
CONFIG_SATA_SVW=y
CONFIG_ATA_PIIX=y
# CONFIG_SATA_MV is not set
CONFIG_SATA_NV=y
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
CONFIG_SATA_SIL=y
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
CONFIG_SATA_VIA=y
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_PATA_ACPI is not set
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5535 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
CONFIG_PATA_MPIIX=y
CONFIG_PATA_OLDPIIX=y
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set
# CONFIG_PATA_SCH is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
# CONFIG_MD_LINEAR is not set
# CONFIG_MD_RAID0 is not set
CONFIG_MD_RAID1=y
# CONFIG_MD_RAID10 is not set
# CONFIG_MD_RAID456 is not set
# CONFIG_MD_MULTIPATH is not set
# CONFIG_MD_FAULTY is not set
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
# CONFIG_DM_CRYPT is not set
# CONFIG_DM_SNAPSHOT is not set
# CONFIG_DM_MIRROR is not set
# CONFIG_DM_ZERO is not set
# CONFIG_DM_MULTIPATH is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#

#
# Enable only one of the two stacks, unless you know what you are doing
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_COMPAT_NET_DEV_OPS=y
# CONFIG_DUMMY is not set
CONFIG_BONDING=m
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
# CONFIG_NET_ETHERNET is not set
CONFIG_MII=y
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
CONFIG_E1000E=y
CONFIG_IP1000=y
CONFIG_IGB=y
CONFIG_IGB_DCA=y
# CONFIG_IGBVF is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_JME is not set
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
CONFIG_DEVKMEM=y
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_NSC_GPIO is not set
# CONFIG_CS5535_GPIO is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_I2C is not set
# CONFIG_SPI is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_HWMON is not set
CONFIG_THERMAL=y
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_REGULATOR is not set

#
# Multimedia devices
#

#
# Multimedia core support
#
# CONFIG_VIDEO_DEV is not set
# CONFIG_DVB_CORE is not set
# CONFIG_VIDEO_MEDIA is not set

#
# Multimedia drivers
#
# CONFIG_DAB is not set

#
# Graphics support
#
# CONFIG_AGP is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=256
CONFIG_DUMMY_CONSOLE=y
# CONFIG_SOUND is not set
# CONFIG_HID_SUPPORT is not set
# CONFIG_USB_SUPPORT is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_V3020 is not set

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y

#
# DMA Devices
#
CONFIG_INTEL_IOATDMA=y
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set
CONFIG_DCA=y
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_TC1100_WMI is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_TOSHIBA is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
# CONFIG_EXT2_FS_SECURITY is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
# CONFIG_EXT3_FS_SECURITY is not set
# CONFIG_EXT4_FS is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
# CONFIG_REISERFS_FS_SECURITY is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_FILE_LOCKING=y
# CONFIG_XFS_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_DNOTIFY=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS_FS is not set
CONFIG_AUTOFS4_FS=y
# CONFIG_FUSE_FS is not set
CONFIG_GENERIC_ACL=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
# CONFIG_VFAT_FS is not set
CONFIG_FAT_DEFAULT_CODEPAGE=437
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
# CONFIG_CONFIGFS_FS is not set
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_NILFS2_FS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_MAGIC_SYSRQ=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
CONFIG_DETECT_SOFTLOCKUP=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
CONFIG_TIMER_STATS=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_SPINLOCK_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_HIGHMEM=y
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
# CONFIG_FRAME_POINTER is not set
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
# CONFIG_SYSCTL_SYSCALL_CHECK is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_FTRACE_SYSCALLS=y
CONFIG_RING_BUFFER=y
CONFIG_TRACING=y
CONFIG_TRACING_SUPPORT=y

#
# Tracers
#
# CONFIG_FUNCTION_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
# CONFIG_SYSPROF_TRACER is not set
# CONFIG_SCHED_TRACER is not set
CONFIG_CONTEXT_SWITCH_TRACER=y
# CONFIG_EVENT_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
# CONFIG_BOOT_TRACER is not set
# CONFIG_TRACE_BRANCH_PROFILING is not set
# CONFIG_POWER_TRACER is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_KMEMTRACE is not set
# CONFIG_WORKQUEUE_TRACER is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DYNAMIC_DEBUG is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DEBUG_NX_TEST is not set
# CONFIG_4KSTACKS is not set
CONFIG_DOUBLEFAULT=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
# CONFIG_IMA is not set
# CONFIG_CRYPTO is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
# CONFIG_VIRTUALIZATION is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_FIND_LAST_BIT=y
# CONFIG_CRC_CCITT is not set
# CONFIG_CRC16 is not set
# CONFIG_CRC_T10DIF is not set
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_NLATTR=y

--------------040802030102000607070906--
