From: Ye Xiaolong <xiaolong.ye@intel.com>
Subject: Re: [LKP] [rhashtable] 5d60de5ff1 [ INFO: suspicious RCU usage. ]
Date: Mon, 27 Feb 2017 12:31:16 +0800
Message-ID: <20170227043116.GC5599@yexl-desktop>
References: <20170218052331.dlr4si7gbhnukewb@wfg-t540p.sh.intel.com>
 <20170225143950.GB28272@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fengguang Wu <fengguang.wu@intel.com>, Thomas Graf <tgraf@suug.ch>,
        netdev@vger.kernel.org, LKP <lkp@01.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59134 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751011AbdB0IRT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 03:17:19 -0500
Content-Disposition: inline
In-Reply-To: <20170225143950.GB28272@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25, Herbert Xu wrote:
>On Sat, Feb 18, 2017 at 01:23:31PM +0800, Fengguang Wu wrote:
>> Greetings,
>> 
>> 0day kernel testing robot got the below dmesg and the first bad commit is
>> 
>> https://github.com/0day-ci/linux Herbert-Xu/rhashtable-Handle-table-allocation-failure-during-insertion/20170212-030221
>> 
>> commit 5d60de5ff12fb1e966c863bcb41c1e2bdde66c50
>> Author:     Herbert Xu <herbert@gondor.apana.org.au>
>> AuthorDate: Sat Feb 11 19:26:47 2017 +0800
>> Commit:     0day robot <fengguang.wu@intel.com>
>> CommitDate: Sun Feb 12 03:02:26 2017 +0800
>> 
>>      rhashtable: Add nested tables
>>      
>>      This patch adds code that handles GFP_ATOMIC kmalloc failure on
>>      insertion.  As we cannot use vmalloc, we solve it by making our
>>      hash table nested.  That is, we allocate single pages at each level
>>      and reach our desired table size by nesting them.
>>      
>>      When a nested table is created, only a single page is allocated
>>      at the top-level.  Lower levels are allocated on demand during
>>      insertion.  Therefore for each insertion to succeed, only two
>>      (non-consecutive) pages are needed.
>>      
>>      After a nested table is created, a rehash will be scheduled in
>>      order to switch to a vmalloced table as soon as possible.  Also,
>>      the rehash code will never rehash into a nested table.  If we
>>      detect a nested table during a rehash, the rehash will be aborted
>>      and a new rehash will be scheduled.
>>      
>>      Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>> 
>> +------------------------------------------------------------------+------------+------------+------------------+
>> |                                                                  | eadcee1e3a | 5d60de5ff1 | v4.10-rc8_021716 |
>> +------------------------------------------------------------------+------------+------------+------------------+
>> | boot_successes                                                   | 0          | 0          | 9                |
>> | boot_failures                                                    | 177        | 48         | 82               |
>> | Kernel_panic-not_syncing:softlockup:hung_tasks                   | 177        | 48         | 14               |
>> | INFO:suspicious_RCU_usage                                        | 0          | 39         | 64               |
>> | BUG:KASAN:user-memory-access_on_address                          | 0          | 0          | 16               |
>> | BUG:unable_to_handle_kernel                                      | 0          | 0          | 18               |
>> | Oops                                                             | 0          | 0          | 18               |
>> | Kernel_panic-not_syncing:Fatal_exception                         | 0          | 0          | 18               |
>> | BUG:kernel_hang_in_test_stage                                    | 0          | 0          | 19               |
>> | WARNING:at_kernel/sched/sched.h:#set_next_entity                 | 0          | 0          | 15               |
>> | INFO:possible_circular_locking_dependency_detected               | 0          | 0          | 4                |
>> | WARNING:at_include/linux/cpumask.h:#find_get_context             | 0          | 0          | 2                |
>> | invoked_oom-killer:gfp_mask=0x                                   | 0          | 0          | 4                |
>> | Mem-Info                                                         | 0          | 0          | 4                |
>> | Kernel_panic-not_syncing:Out_of_memory_and_no_killable_processes | 0          | 0          | 4                |
>> | Kernel_panic-not_syncing:Attempted_to_kill_init!exitcode=        | 0          | 0          | 7                |
>> +------------------------------------------------------------------+------------+------------+------------------+
>> 
>> [    9.022401] Testing concurrent rhashtable access from 10 threads
>> [   15.800003] 
>> [   15.801145] ===============================
>> [   15.801802] [ INFO: suspicious RCU usage. ]
>> [   15.802476] 4.10.0-rc7-00090-g5d60de5 #1 Not tainted
>> [   15.803235] -------------------------------
>> [   15.803866] lib/rhashtable.c:1126 suspicious rcu_dereference_protected() usage!
>
>Sorry, I chose the wrong annotation to fix the previous report.
>This patch should fix it completely.

This warning is gone with the fix patch in 0day environment.

Tested-by: Xiaolong Ye <xiaolong.ye@intel.com>

Thanks,
Xiaolong
>
>---8<---
>Subject: rhashtable: Fix RCU dereference annotation in rht_bucket_nested
>
>The current annotation is wrong as it says that we're only called
>under spinlock.  In fact it should be marked as under either
>spinlock or RCU read lock.
>
>Fixes: da20420f83ea ("rhashtable: Add nested tables")
>Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>---
>
> lib/rhashtable.c |    5 +++--
> 1 file changed, 3 insertions(+), 2 deletions(-)
>
>diff --git a/lib/rhashtable.c b/lib/rhashtable.c
>index fac1a78..c5b9b93 100644
>--- a/lib/rhashtable.c
>+++ b/lib/rhashtable.c
>@@ -1121,12 +1121,13 @@ struct rhash_head __rcu **rht_bucket_nested(const struct bucket_table *tbl,
> 	union nested_table *ntbl;
> 
> 	ntbl = (union nested_table *)rcu_dereference_raw(tbl->buckets[0]);
>-	ntbl = rht_dereference_bucket(ntbl[index].table, tbl, hash);
>+	ntbl = rht_dereference_bucket_rcu(ntbl[index].table, tbl, hash);
> 	subhash >>= tbl->nest;
> 
> 	while (ntbl && size > (1 << shift)) {
> 		index = subhash & ((1 << shift) - 1);
>-		ntbl = rht_dereference_bucket(ntbl[index].table, tbl, hash);
>+		ntbl = rht_dereference_bucket_rcu(ntbl[index].table,
>+						  tbl, hash);
> 		size >>= shift;
> 		subhash >>= shift;
> 	}
>-- 
>Email: Herbert Xu <herbert@gondor.apana.org.au>
>Home Page: http://gondor.apana.org.au/~herbert/
>PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>_______________________________________________
>LKP mailing list
>LKP@lists.01.org
>https://lists.01.org/mailman/listinfo/lkp
