From: Marc MERLIN <marc@merlins.org>
Subject: Re: 3.4.4/amd64 full interrupt hangs under big nfs copies
Date: Mon, 16 Jul 2012 08:18:26 -0700
Message-ID: <20120716151826.GA10586@merlins.org>
References: <20120409.143710.879746943062854492.davem@davemloft.net>
 <4F83316F.20504@lwfinger.net>
 <1333998672.3007.245.camel@edumazet-glaptop>
 <20120409.153452.1284163346306246866.davem@davemloft.net>
 <1334030180.13293.98.camel@edumazet-glaptop>
 <20120410051127.GA32048@merlins.org>
 <1334038263.2907.1.camel@edumazet-glaptop>
 <20120411052733.GA17352@merlins.org>
 <20120715215935.GF24420@merlins.org>
 <1342419529.3265.12217.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:48865 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab2GPPSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 11:18:34 -0400
Content-Disposition: inline
In-Reply-To: <1342419529.3265.12217.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 08:18:49AM +0200, Eric Dumazet wrote:
> > My understanding is that user space calling drivers that shut off all
> > interrupts for extended periods of time (as least I think so since my mouse
> > cursor would not move), is still a kernel bug.
> > 
> > For what it's worth, copying 1GB of data in lots of small files does not
> > cause problems, it seems that it's big files that cause a problem since they
> > likely fill a buffer somewhere while interrupts are disabled.
> > 
> > Do you have an idea of how I can find out where my mc process is stuck in
> > the kernel?
> > Should I reproduce with specific sysrq output?
> 
> Just to clarify, you get this freeze when transferring a big file from a
> remote NFS server to your PC, (aka a download), not the reverse way ?
 
No, it's atually when I'm 'uploading' from my laptop to my server.
One interesting thing is that my server is running lvm2 with snapshots,
which makes writes slower than my laptop can push data over the network, so
it's definitely causing buffers to fill up.
I just did a download test and got 4.5MB/s sustained without problems.

> If so, you might hit OOM condition because iwlwifi uses big/fat RX
> buffers, I never understood why...
> 
> (amsdu_size_8K = 1)
> 
> Storing an MTU=1500 frams in 8KB of memory sounds really bad.
> 
> diff --git a/drivers/net/wireless/iwlwifi/iwl-drv.c b/drivers/net/wireless/iwlwifi/iwl-drv.c
> index cc41cfa..434b924 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-drv.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-drv.c
> @@ -1006,7 +1006,7 @@ void iwl_drv_stop(struct iwl_drv *drv)
>  
>  /* shared module parameters */
>  struct iwl_mod_params iwlwifi_mod_params = {
> -	.amsdu_size_8K = 1,
> +	.amsdu_size_8K = 0,

So, do you recomend I try this if my problem is with TX and not RX?

More generally, is there a tip you have for me to get WCHAN in ps on a
process that is causing this problem, or will sysrq-W/sysrq-D show this, or
do I need something like sysrq-T ?

I just reproduced this while having a loop that did 
while :; do date; echo w > /proc/sysrq-trigger; sleep 30; done

I got a nice 30mn (!) hang, including the lines below:
[68151.449220] kworker/0:0: page allocation failure: order:1, mode:0x4020
[68151.449225] Pid: 9004, comm: kworker/0:0 Tainted: G         C O 3.4.4-amd64-preempt-noide-20120410 #1
[68151.449227] Call Trace:
[68151.449228]  <IRQ>  [<ffffffff810bf8d8>] ? warn_alloc_failed+0x11f/0x132
[68151.449239]  [<ffffffff810453ff>] ? __mod_timer+0x13a/0x14c
[68151.449243]  [<ffffffff810c26e2>] ? __alloc_pages_nodemask+0x72f/0x7df
[68151.449256]  [<ffffffff810ecf10>] ? alloc_pages_current+0xc7/0xe4
[68151.449266]  [<ffffffffa04ca247>] ? iwlagn_rx_allocate+0x97/0x24d [iwlwifi]
[68151.449273]  [<ffffffffa04cb27b>] ? iwl_irq_tasklet+0x6e4/0x838 [iwlwifi]
[68151.449279]  [<ffffffff8103f6e9>] ? tasklet_action+0x79/0xc8
[68151.449283]  [<ffffffff8103f205>] ? __do_softirq+0xc0/0x188
[68151.449288]  [<ffffffff8136879c>] ? call_softirq+0x1c/0x30
[68151.449293]  [<ffffffff8100fcf9>] ? do_softirq+0x3c/0x7b
[68151.449297]  [<ffffffff8103f4f3>] ? irq_exit+0x3d/0xa5
[68151.449301]  [<ffffffff8100fa1e>] ? do_IRQ+0x81/0x97
[68151.449306]  [<ffffffff81362e2a>] ? common_interrupt+0x6a/0x6a
[68151.449308]  <EOI>  [<ffffffff811b7bca>] ? idr_get_next+0x7d/0x92
[68151.449318]  [<ffffffff81088d74>] ? css_get_next+0x59/0x97
[68151.449322]  [<ffffffff810fc115>] ? mem_cgroup_iter+0x109/0x1ab
[68151.449328]  [<ffffffff810cb31a>] ? shrink_zone+0x89/0x9b
[68151.449333]  [<ffffffff810cb73c>] ? do_try_to_free_pages+0x1e4/0x434
[68151.449338]  [<ffffffff810cbc11>] ? try_to_free_pages+0xb3/0xf9
[68151.449343]  [<ffffffff810c24a2>] ? __alloc_pages_nodemask+0x4ef/0x7df
[68151.449349]  [<ffffffff810ecf10>] ? alloc_pages_current+0xc7/0xe4
[68151.449356]  [<ffffffffa04ca247>] ? iwlagn_rx_allocate+0x97/0x24d [iwlwifi]
[68151.449363]  [<ffffffffa04ca81e>] ? iwlagn_rx_replenish+0x3a/0x3a [iwlwifi]
[68151.449369]  [<ffffffffa04ca7fc>] ? iwlagn_rx_replenish+0x18/0x3a [iwlwifi]
[68151.449373]  [<ffffffff8104ea7d>] ? process_one_work+0x16d/0x298
[68151.449379]  [<ffffffff8104f4d9>] ? worker_thread+0xc2/0x145
[68151.449383]  [<ffffffff8104f417>] ? manage_workers.isra.23+0x15b/0x15b
[68151.449386]  [<ffffffff81052788>] ? kthread+0x7d/0x85
[68151.449390]  [<ffffffff813686a4>] ? kernel_thread_helper+0x4/0x10
[68151.449395]  [<ffffffff8105270b>] ? kthread_freezable_should_stop+0x37/0x37
[68151.449399]  [<ffffffff813686a0>] ? gs_change+0x13/0x13
(...)
[68151.475337] iwlwifi 0:03:00.0: Failed to alloc_pages with GFP_ATOMIC.Only 5 free buffers remaining.


Full log below around the 30mn hang:
[68145.180343] SysRq : Show Blocked State
[68145.180348]   task                        PC stack   pid father
[68145.180469] mc              D ffff88021e213680     0  6526  21734 0x00000080
[68145.180473]  ffff8802134ff750 0000000000000086 0000000000000008 ffff88020d76a7d0
[68145.180477]  0000000000013680 ffff88001a98dfd8 ffff88001a98dfd8 ffff8802134ff750
[68145.180480]  ffff8801a299ede0 ffff88021e213680 ffff8802134ff750 ffffffff810bb429
[68145.180483] Call Trace:
[68145.180490]  [<ffffffff810bb429>] ? __lock_page+0x66/0x66
[68145.180494]  [<ffffffff81362059>] ? io_schedule+0x55/0x6b
[68145.180496]  [<ffffffff810bb42f>] ? sleep_on_page+0x6/0xa
[68145.180499]  [<ffffffff81361054>] ? __wait_on_bit+0x3e/0x71
[68145.180502]  [<ffffffff810bb577>] ? wait_on_page_bit+0x6e/0x73
[68145.180505]  [<ffffffff81052e69>] ? autoremove_wake_function+0x2a/0x2a
[68145.180540]  [<ffffffffa0199d18>] ? read_extent_buffer_pages+0x1fb/0x24b [btrfs]
[68145.180552]  [<ffffffffa0175112>] ? lock_page+0x11/0x11 [btrfs]
[68145.180564]  [<ffffffffa0176e69>] ? btree_read_extent_buffer_pages.constprop.110+0x5c/0xf3 [btrfs]
[68145.180577]  [<ffffffffa0177412>] ? read_tree_block+0x25/0x2d [btrfs]
[68145.180586]  [<ffffffffa0163087>] ? read_block_for_search.isra.32+0x2af/0x2e7 [btrfs]
[68145.180597]  [<ffffffffa01649c2>] ? btrfs_search_slot+0x48d/0x659 [btrfs]
[68145.180608]  [<ffffffffa0172d7d>] ? btrfs_lookup_csum+0x66/0x106 [btrfs]
[68145.180611]  [<ffffffff8136583e>] ? sub_preempt_count+0x83/0x94
[68145.180622]  [<ffffffffa0172fad>] ? __btrfs_lookup_bio_sums+0x190/0x30a [btrfs]
[68145.180635]  [<ffffffffa017d021>] ? btrfs_submit_bio_hook+0xa9/0x12a [btrfs]
[68145.180649]  [<ffffffffa0194af3>] ? submit_one_bio+0x82/0xb9 [btrfs]
[68145.180662]  [<ffffffffa01977c7>] ? submit_extent_page.isra.26+0x10a/0x1b2 [btrfs]
[68145.180675]  [<ffffffffa0196d91>] ? repair_io_failure+0x18e/0x18e [btrfs]
[68145.180687]  [<ffffffffa0197cf5>] ? __extent_read_full_page+0x424/0x4be [btrfs]
[68145.180699]  [<ffffffffa0196d91>] ? repair_io_failure+0x18e/0x18e [btrfs]
[68145.180712]  [<ffffffffa017eca4>] ? btrfs_writepage+0x4b/0x4b [btrfs]
[68145.180716]  [<ffffffff810c56b3>] ? __lru_cache_add+0x7b/0x8d
[68145.180728]  [<ffffffffa01988e8>] ? extent_readpages+0xaf/0xf3 [btrfs]
[68145.180741]  [<ffffffffa017eca4>] ? btrfs_writepage+0x4b/0x4b [btrfs]
[68145.180744]  [<ffffffff810c4640>] ? __do_page_cache_readahead+0x139/0x1de
[68145.180747]  [<ffffffff810c493d>] ? ra_submit+0x19/0x1d
[68145.180749]  [<ffffffff810bca23>] ? generic_file_aio_read+0x2b0/0x5d3
[68145.180753]  [<ffffffff81110627>] ? set_fd_set+0x23/0x26
[68145.180756]  [<ffffffff8110252a>] ? do_sync_read+0xab/0xe3
[68145.180759]  [<ffffffff81362b73>] ? _raw_spin_unlock_irqrestore+0x30/0x3e
[68145.180762]  [<ffffffff810595b4>] ? __wake_up+0x35/0x46
[68145.180764]  [<ffffffff81102c22>] ? vfs_read+0x9f/0xe6
[68145.180767]  [<ffffffff81103c2d>] ? fget_light+0x33/0x8d
[68145.180769]  [<ffffffff81102cae>] ? sys_read+0x45/0x6b
[68145.180772]  [<ffffffff8136723d>] ? system_call_fastpath+0x1a/0x1f
[68145.180783] Sched Debug Version: v0.10, 3.4.4-amd64-preempt-noide-20120410 #1
[68145.180785] ktime                                   : 68319835.436522
[68145.180787] sched_clk                               : 68145180.782078
[68145.180788] cpu_clk                                 : 68145180.782141
[68145.180790] jiffies                                 : 4311972254
[68145.180791] sched_clock_stable                      : 1
[68145.180792] 
[68145.180793] sysctl_sched
[68145.180795]   .sysctl_sched_latency                    : 18.000000
[68145.180796]   .sysctl_sched_min_granularity            : 2.250000
[68145.180798]   .sysctl_sched_wakeup_granularity         : 3.000000
[68145.180799]   .sysctl_sched_child_runs_first           : 0
[68145.180801]   .sysctl_sched_features                   : 24119
[68145.180803]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[68145.180805] 
[68145.180805] cpu#0, 2893.340 MHz
[68145.180806]   .nr_running                    : 1
[68145.180808]   .load                          : 1024
[68145.180809]   .nr_switches                   : 220345791
[68145.180810]   .nr_load_updates               : 21415127
[68145.180812]   .nr_uninterruptible            : -4403
[68145.180813]   .next_balance                  : 4311.972255
[68145.180815]   .curr->pid                     : 8408
[68145.180816]   .clock                         : 68145180.058636
[68145.180818]   .cpu_load[0]                   : 0
[68145.180819]   .cpu_load[1]                   : 664
[68145.180820]   .cpu_load[2]                   : 639
[68145.180821]   .cpu_load[3]                   : 486
[68145.180823]   .cpu_load[4]                   : 397
[68145.180825] 
[68145.180825] cfs_rq[0]:/autogroup-105
[68145.180827]   .exec_clock                    : 0.000000
[68145.180828]   .MIN_vruntime                  : 0.000001
[68145.180830]   .min_vruntime                  : 632596.935417
[68145.180832]   .max_vruntime                  : 0.000001
[68145.180833]   .spread                        : 0.000000
[68145.180835]   .spread0                       : -16307488.857263
[68145.180836]   .nr_spread_over                : 0
[68145.180837]   .nr_running                    : 0
[68145.180838]   .load                          : 0
[68145.180840]   .load_avg                      : 2629.999737
[68145.180841]   .load_period                   : 5.116983
[68145.180843]   .load_contrib                  : 513
[68145.180844]   .load_tg                       : 515
[68145.180846]   .se->exec_start                : 68145177.126165
[68145.180847]   .se->vruntime                  : 16940076.867799
[68145.180849]   .se->sum_exec_runtime          : 525985.491293
[68145.180850]   .se->load.weight               : 2
[68145.180852] 
[68145.180852] cfs_rq[0]:/autogroup-728
[68145.180854]   .exec_clock                    : 0.000000
[68145.180855]   .MIN_vruntime                  : 0.000001
[68145.180857]   .min_vruntime                  : 1465.002075
[68145.180858]   .max_vruntime                  : 0.000001
[68145.180859]   .spread                        : 0.000000
[68145.180861]   .spread0                       : -16938620.790605
[68145.180862]   .nr_spread_over                : 0
[68145.180864]   .nr_running                    : 0
[68145.180865]   .load                          : 0
[68145.180866]   .load_avg                      : 718.614822
[68145.180868]   .load_period                   : 5.560256
[68145.180869]   .load_contrib                  : 121
[68145.180870]   .load_tg                       : 643
[68145.180872]   .se->exec_start                : 68145179.581565
[68145.180873]   .se->vruntime                  : 16940077.021084
[68145.180875]   .se->sum_exec_runtime          : 238.261122
[68145.180876]   .se->load.weight               : 2
[68145.180878] 
[68145.180878] cfs_rq[0]:/autogroup-77
[68145.180880]   .exec_clock                    : 0.000000
[68145.180881]   .MIN_vruntime                  : 0.000001
[68145.180883]   .min_vruntime                  : 7008.558906
[68145.180884]   .max_vruntime                  : 0.000001
[68145.180886]   .spread                        : 0.000000
[68145.180887]   .spread0                       : -16933077.233774
[68145.180888]   .nr_spread_over                : 0
[68145.180890]   .nr_running                    : 0
[68145.180891]   .load                          : 0
[68145.180892]   .load_avg                      : 639.999936
[68145.180894]   .load_period                   : 6.666654
[68145.180895]   .load_contrib                  : 96
[68145.180896]   .load_tg                       : 202
[68145.180898]   .se->exec_start                : 68145155.292812
[68145.180899]   .se->vruntime                  : 16940072.397295
[68145.180901]   .se->sum_exec_runtime          : 6875.737275
[68145.180902]   .se->load.weight               : 2
[68145.180904] 
[68145.180904] cfs_rq[0]:/autogroup-74
[68145.180906]   .exec_clock                    : 0.000000
[68145.180907]   .MIN_vruntime                  : 0.000001
[68145.180908]   .min_vruntime                  : 9096.628700
[68145.180910]   .max_vruntime                  : 0.000001
[68145.180911]   .spread                        : 0.000000
[68145.180913]   .spread0                       : -16930989.163980
[68145.180914]   .nr_spread_over                : 0
[68145.180915]   .nr_running                    : 0
[68145.180917]   .load                          : 0
[68145.180918]   .load_avg                      : 643.893952
[68145.180919]   .load_period                   : 8.513359
[68145.180921]   .load_contrib                  : 75
[68145.180922]   .load_tg                       : 75
[68145.180924]   .se->exec_start                : 68145155.254096
[68145.180926]   .se->vruntime                  : 16940072.391504
[68145.180927]   .se->sum_exec_runtime          : 8917.069991
[68145.180928]   .se->load.weight               : 2
[68145.180930] 
[68145.180930] cfs_rq[0]:/autogroup-85
[68145.180932]   .exec_clock                    : 0.000000
[68145.180933]   .MIN_vruntime                  : 0.000001
[68145.180935]   .min_vruntime                  : 461037.358394
[68145.180936]   .max_vruntime                  : 0.000001
[68145.180938]   .spread                        : 0.000000
[68145.180939]   .spread0                       : -16479048.434286
[68145.180940]   .nr_spread_over                : 0
[68145.180942]   .nr_running                    : 0
[68145.180943]   .load                          : 0
[68145.180944]   .load_avg                      : 159.999984
[68145.180946]   .load_period                   : 8.582743
[68145.180947]   .load_contrib                  : 18
[68145.180948]   .load_tg                       : 20
[68145.180950]   .se->exec_start                : 68145144.752282
[68145.180951]   .se->vruntime                  : 16940070.960978
[68145.180953]   .se->sum_exec_runtime          : 523059.429556
[68145.180954]   .se->load.weight               : 2
[68145.180956] 
[68145.180956] cfs_rq[0]:/autogroup-99
[68145.180958]   .exec_clock                    : 0.000000
[68145.180959]   .MIN_vruntime                  : 0.000001
[68145.180961]   .min_vruntime                  : 919853.728128
[68145.180962]   .max_vruntime                  : 0.000001
[68145.180963]   .spread                        : 0.000000
[68145.180965]   .spread0                       : -16020232.064552
[68145.180966]   .nr_spread_over                : 0
[68145.180968]   .nr_running                    : 0
[68145.180969]   .load                          : 0
[68145.180970]   .load_avg                      : 95.570772
[68145.180972]   .load_period                   : 8.631443
[68145.180973]   .load_contrib                  : 11
[68145.180974]   .load_tg                       : 25
[68145.180976]   .se->exec_start                : 68145166.483609
[68145.180977]   .se->vruntime                  : 16940075.698106
[68145.180979]   .se->sum_exec_runtime          : 649839.065400
[68145.180980]   .se->load.weight               : 2
[68145.180982] 
[68145.180982] cfs_rq[0]:/autogroup-53
[68145.180984]   .exec_clock                    : 0.000000
[68145.180985]   .MIN_vruntime                  : 0.000001
[68145.180987]   .min_vruntime                  : 8270588.687589
[68145.180988]   .max_vruntime                  : 0.000001
[68145.180989]   .spread                        : 0.000000
[68145.180991]   .spread0                       : -8669497.105091
[68145.180992]   .nr_spread_over                : 0
[68145.180993]   .nr_running                    : 0
[68145.180995]   .load                          : 0
[68145.180996]   .load_avg                      : 51.067853
[68145.180998]   .load_period                   : 6.626155
[68145.180999]   .load_contrib                  : 2
[68145.181000]   .load_tg                       : 1479
[68145.181002]   .se->exec_start                : 68145177.453635
[68145.181003]   .se->vruntime                  : 16940076.966610
[68145.181005]   .se->sum_exec_runtime          : 7731181.203365
[68145.181006]   .se->load.weight               : 2
[68145.181008] 
[68145.181008] cfs_rq[0]:/autogroup-216
[68145.181009]   .exec_clock                    : 0.000000
[68145.181011]   .MIN_vruntime                  : 0.000001
[68145.181012]   .min_vruntime                  : 106577.197911
[68145.181014]   .max_vruntime                  : 0.000001
[68145.181015]   .spread                        : 0.000000
[68145.181017]   .spread0                       : -16833508.594769
[68145.181018]   .nr_spread_over                : 0
[68145.181019]   .nr_running                    : 0
[68145.181020]   .load                          : 0
[68145.181022]   .load_avg                      : 22.437006
[68145.181023]   .load_period                   : 6.581971
[68145.181025]   .load_contrib                  : 3
[68145.181026]   .load_tg                       : 3
[68145.181028]   .se->exec_start                : 68145151.713745
[68145.181029]   .se->vruntime                  : 16940072.220775
[68145.181031]   .se->sum_exec_runtime          : 55613.402140
[68145.181032]   .se->load.weight               : 2
[68145.181034] 
[68145.181034] cfs_rq[0]:/autogroup-499
[68145.181036]   .exec_clock                    : 0.000000
[68145.181037]   .MIN_vruntime                  : 0.000001
[68145.181039]   .min_vruntime                  : 12143.287893
[68145.181040]   .max_vruntime                  : 0.000001
[68145.181042]   .spread                        : 0.000000
[68145.181043]   .spread0                       : -16927942.504787
[68145.181045]   .nr_spread_over                : 0
[68145.181046]   .nr_running                    : 0
[68145.181047]   .load                          : 0
[68145.181048]   .load_avg                      : 2288.736922
[68145.181050]   .load_period                   : 7.063528
[68145.181051]   .load_contrib                  : 324
[68145.181053]   .load_tg                       : 324
[68145.181054]   .se->exec_start                : 68145176.734792
[68145.181056]   .se->vruntime                  : 16940085.859991
[68145.181057]   .se->sum_exec_runtime          : 5891.241766
[68145.181058]   .se->load.weight               : 2
[68145.181060] 
[68145.181060] cfs_rq[0]:/autogroup-345
[68145.181062]   .exec_clock                    : 0.000000
[68145.181063]   .MIN_vruntime                  : 0.000001
[68145.181065]   .min_vruntime                  : 337573.928223
[68145.181066]   .max_vruntime                  : 0.000001
[68145.181067]   .spread                        : 0.000000
[68145.181069]   .spread0                       : -16602511.864457
[68145.181070]   .nr_spread_over                : 0
[68145.181072]   .nr_running                    : 0
[68145.181073]   .load                          : 0
[68145.181074]   .load_avg                      : 694.208403
[68145.181076]   .load_period                   : 6.188356
[68145.181077]   .load_contrib                  : 112
[68145.181078]   .load_tg                       : 511
[68145.181080]   .se->exec_start                : 68145174.673610
[68145.181081]   .se->vruntime                  : 16940076.816044
[68145.181083]   .se->sum_exec_runtime          : 453037.061998
[68145.181084]   .se->load.weight               : 2
[68145.181086] 
[68145.181086] cfs_rq[0]:/
[68145.181088]   .exec_clock                    : 0.000000
[68145.181089]   .MIN_vruntime                  : 0.000001
[68145.181090]   .min_vruntime                  : 16940085.792680
[68145.181092]   .max_vruntime                  : 0.000001
[68145.181093]   .spread                        : 0.000000
[68145.181095]   .spread0                       : 0.000000
[68145.181096]   .nr_spread_over                : 0
[68145.181097]   .nr_running                    : 1
[68145.181098]   .load                          : 1024
[68145.181100]   .load_avg                      : 0.000000
[68145.181101]   .load_period                   : 0.000000
[68145.181102]   .load_contrib                  : 0
[68145.181104]   .load_tg                       : 0
[68145.181105] 
[68145.181105] rt_rq[0]:
[68145.181107]   .rt_nr_running                 : 0
[68145.181108]   .rt_throttled                  : 0
[68145.181109]   .rt_time                       : 0.005109
[68145.181111]   .rt_runtime                    : 950.000000
[68145.181112] 
[68145.181113] runnable tasks:
[68145.181113]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[68145.181114] ----------------------------------------------------------------------------------------------------------
[68145.181136] R    kworker/0:1  8408  16940085.792680     29268   120               0               0               0.000000               0.000000               0.000000 /
[68145.181144] 
[68145.181144] cpu#1, 2893.340 MHz
[68145.181146]   .nr_running                    : 1
[68145.181147]   .load                          : 832
[68145.181148]   .nr_switches                   : 215554245
[68145.181150]   .nr_load_updates               : 7918869
[68145.181151]   .nr_uninterruptible            : 2380
[68145.181152]   .next_balance                  : 4311.972282
[68145.181154]   .curr->pid                     : 8880
[68145.181155]   .clock                         : 68145180.268053
[68145.181157]   .cpu_load[0]                   : 879
[68145.181158]   .cpu_load[1]                   : 706
[68145.181159]   .cpu_load[2]                   : 505
[68145.181160]   .cpu_load[3]                   : 322
[68145.181162]   .cpu_load[4]                   : 232
[68145.181163] 
[68145.181164] cfs_rq[1]:/autogroup-53
[68145.181165]   .exec_clock                    : 0.000000
[68145.181166]   .MIN_vruntime                  : 0.000001
[68145.181168]   .min_vruntime                  : 10319271.413405
[68145.181169]   .max_vruntime                  : 0.000001
[68145.181171]   .spread                        : 0.000000
[68145.181172]   .spread0                       : -6620814.379275
[68145.181174]   .nr_spread_over                : 0
[68145.181175]   .nr_running                    : 0
[68145.181176]   .load                          : 0
[68145.181177]   .load_avg                      : 2668.957401
[68145.181179]   .load_period                   : 6.733473
[68145.181180]   .load_contrib                  : 430
[68145.181181]   .load_tg                       : 1479
[68145.181183]   .se->exec_start                : 68145180.194582
[68145.181184]   .se->vruntime                  : 19124295.713641
[68145.181186]   .se->sum_exec_runtime          : 9934376.153325
[68145.181187]   .se->load.weight               : 2
[68145.181189] 
[68145.181189] cfs_rq[1]:/autogroup-728
[68145.181191]   .exec_clock                    : 0.000000
[68145.181192]   .MIN_vruntime                  : 0.000001
[68145.181193]   .min_vruntime                  : 805.626907
[68145.181195]   .max_vruntime                  : 0.000001
[68145.181196]   .spread                        : 0.000000
[68145.181198]   .spread0                       : -16939280.165773
[68145.181199]   .nr_spread_over                : 0
[68145.181200]   .nr_running                    : 1
[68145.181202]   .load                          : 526
[68145.181203]   .load_avg                      : 4387.132719
[68145.181204]   .load_period                   : 8.401223
[68145.181206]   .load_contrib                  : 522
[68145.181207]   .load_tg                       : 643
[68145.181209]   .se->exec_start                : 68145180.268053
[68145.181210]   .se->vruntime                  : 19124304.586462
[68145.181212]   .se->sum_exec_runtime          : 174.761132
[68145.181213]   .se->load.weight               : 832
[68145.181214] 
[68145.181215] cfs_rq[1]:/autogroup-77
[68145.181216]   .exec_clock                    : 0.000000
[68145.181217]   .MIN_vruntime                  : 0.000001
[68145.181219]   .min_vruntime                  : 12354.484454
[68145.181220]   .max_vruntime                  : 0.000001
[68145.181222]   .spread                        : 0.000000
[68145.181223]   .spread0                       : -16927731.308226
[68145.181225]   .nr_spread_over                : 0
[68145.181226]   .nr_running                    : 0
[68145.181227]   .load                          : 0
[68145.181228]   .load_avg                      : 639.999936
[68145.181230]   .load_period                   : 5.988008
[68145.181231]   .load_contrib                  : 106
[68145.181232]   .load_tg                       : 202
[68145.181234]   .se->exec_start                : 68145155.131954
[68145.181235]   .se->vruntime                  : 19124277.088025
[68145.181237]   .se->sum_exec_runtime          : 12258.830758
[68145.181238]   .se->load.weight               : 2
[68145.181240] 
[68145.181240] cfs_rq[1]:/autogroup-13
[68145.181242]   .exec_clock                    : 0.000000
[68145.181243]   .MIN_vruntime                  : 0.000001
[68145.181245]   .min_vruntime                  : 7268.331092
[68145.181246]   .max_vruntime                  : 0.000001
[68145.181247]   .spread                        : 0.000000
[68145.181249]   .spread0                       : -16932817.461588
[68145.181250]   .nr_spread_over                : 0
[68145.181251]   .nr_running                    : 0
[68145.181253]   .load                          : 0
[68145.181254]   .load_avg                      : 324.714656
[68145.181255]   .load_period                   : 5.489619
[68145.181257]   .load_contrib                  : 59
[68145.181258]   .load_tg                       : 59
[68145.181259]   .se->exec_start                : 68145150.974036
[68145.181261]   .se->vruntime                  : 19124277.210880
[68145.181262]   .se->sum_exec_runtime          : 3628.001811
[68145.181264]   .se->load.weight               : 2
[68145.181265] 
[68145.181266] cfs_rq[1]:/autogroup-52
[68145.181267]   .exec_clock                    : 0.000000
[68145.181268]   .MIN_vruntime                  : 0.000001
[68145.181270]   .min_vruntime                  : 244250.987333
[68145.181271]   .max_vruntime                  : 0.000001
[68145.181273]   .spread                        : 0.000000
[68145.181274]   .spread0                       : -16695834.805347
[68145.181275]   .nr_spread_over                : 0
[68145.181277]   .nr_running                    : 0
[68145.181278]   .load                          : 0
[68145.181279]   .load_avg                      : 339.904928
[68145.181281]   .load_period                   : 5.831847
[68145.181282]   .load_contrib                  : 58
[68145.181283]   .load_tg                       : 58
[68145.181285]   .se->exec_start                : 68145155.473960
[68145.181287]   .se->vruntime                  : 19124277.987459
[68145.181288]   .se->sum_exec_runtime          : 244497.514450
[68145.181289]   .se->load.weight               : 2
[68145.181291] 
[68145.181292] cfs_rq[1]:/autogroup-751
[68145.181293]   .exec_clock                    : 0.000000
[68145.181294]   .MIN_vruntime                  : 0.000001
[68145.181296]   .min_vruntime                  : 52.906532
[68145.181297]   .max_vruntime                  : 0.000001
[68145.181299]   .spread                        : 0.000000
[68145.181300]   .spread0                       : -16940032.886148
[68145.181301]   .nr_spread_over                : 0
[68145.181303]   .nr_running                    : 0
[68145.181304]   .load                          : 0
[68145.181305]   .load_avg                      : 329.284768
[68145.181307]   .load_period                   : 5.489338
[68145.181308]   .load_contrib                  : 59
[68145.181309]   .load_tg                       : 59
[68145.181311]   .se->exec_start                : 68145151.059469
[68145.181312]   .se->vruntime                  : 19124277.756132
[68145.181314]   .se->sum_exec_runtime          : 44.955108
[68145.181315]   .se->load.weight               : 2
[68145.181316] 
[68145.181317] cfs_rq[1]:/autogroup-105
[68145.181318]   .exec_clock                    : 0.000000
[68145.181320]   .MIN_vruntime                  : 0.000001
[68145.181321]   .min_vruntime                  : 586685.915590
[68145.181323]   .max_vruntime                  : 0.000001
[68145.181324]   .spread                        : 0.000000
[68145.181326]   .spread0                       : -16353399.877090
[68145.181327]   .nr_spread_over                : 0
[68145.181328]   .nr_running                    : 0
[68145.181329]   .load                          : 0
[68145.181331]   .load_avg                      : 13.583718
[68145.181332]   .load_period                   : 5.192153
[68145.181333]   .load_contrib                  : 2
[68145.181335]   .load_tg                       : 515
[68145.181336]   .se->exec_start                : 68145167.025810
[68145.181338]   .se->vruntime                  : 19124277.682220
[68145.181339]   .se->sum_exec_runtime          : 451469.872335
[68145.181341]   .se->load.weight               : 2
[68145.181342] 
[68145.181342] cfs_rq[1]:/autogroup-85
[68145.181344]   .exec_clock                    : 0.000000
[68145.181345]   .MIN_vruntime                  : 0.000001
[68145.181347]   .min_vruntime                  : 457615.974873
[68145.181348]   .max_vruntime                  : 0.000001
[68145.181350]   .spread                        : 0.000000
[68145.181351]   .spread0                       : -16482469.817807
[68145.181353]   .nr_spread_over                : 0
[68145.181354]   .nr_running                    : 0
[68145.181355]   .load                          : 0
[68145.181357]   .load_avg                      : 22.432540
[68145.181358]   .load_period                   : 9.882693
[68145.181360]   .load_contrib                  : 2
[68145.181361]   .load_tg                       : 14
[68145.181362]   .se->exec_start                : 68145166.823349
[68145.181364]   .se->vruntime                  : 19124277.441135
[68145.181366]   .se->sum_exec_runtime          : 496686.043300
[68145.181367]   .se->load.weight               : 2
[68145.181368] 
[68145.181369] cfs_rq[1]:/autogroup-99
[68145.181370]   .exec_clock                    : 0.000000
[68145.181372]   .MIN_vruntime                  : 0.000001
[68145.181373]   .min_vruntime                  : 886895.365957
[68145.181374]   .max_vruntime                  : 0.000001
[68145.181376]   .spread                        : 0.000000
[68145.181377]   .spread0                       : -16053191.714824
[68145.181379]   .nr_spread_over                : 0
[68145.181380]   .nr_running                    : 0
[68145.181381]   .load                          : 0
[68145.181382]   .load_avg                      : 19.102799
[68145.181384]   .load_period                   : 6.184140
[68145.181385]   .load_contrib                  : 3
[68145.181386]   .load_tg                       : 20
[68145.181388]   .se->exec_start                : 68145174.705985
[68145.181389]   .se->vruntime                  : 19124286.557447
[68145.181391]   .se->sum_exec_runtime          : 563791.520677
[68145.181392]   .se->load.weight               : 2
[68145.181394] 
[68145.181394] cfs_rq[1]:/autogroup-345
[68145.181395]   .exec_clock                    : 0.000000
[68145.181397]   .MIN_vruntime                  : 0.000001
[68145.181398]   .min_vruntime                  : 390277.323389
[68145.181400]   .max_vruntime                  : 0.000001
[68145.181401]   .spread                        : 0.000000
[68145.181402]   .spread0                       : -16549809.757392
[68145.181404]   .nr_spread_over                : 0
[68145.181405]   .nr_running                    : 0
[68145.181406]   .load                          : 0
[68145.181408]   .load_avg                      : 3.038718
[68145.181409]   .load_period                   : 9.886871
[68145.181410]   .load_contrib                  : 0
[68145.181412]   .load_tg                       : 431
[68145.181413]   .se->exec_start                : 68145154.709399
[68145.181415]   .se->vruntime                  : 19124277.152141
[68145.181416]   .se->sum_exec_runtime          : 488635.600464
[68145.181418]   .se->load.weight               : 2
[68145.181419] 
[68145.181419] cfs_rq[1]:/
[68145.181420]   .exec_clock                    : 0.000000
[68145.181422]   .MIN_vruntime                  : 0.000001
[68145.181423]   .min_vruntime                  : 19124304.595285
[68145.181425]   .max_vruntime                  : 0.000001
[68145.181426]   .spread                        : 0.000000
[68145.181428]   .spread0                       : 2184217.514504
[68145.181429]   .nr_spread_over                : 0
[68145.181430]   .nr_running                    : 1
[68145.181432]   .load                          : 832
[68145.181433]   .load_avg                      : 0.000000
[68145.181434]   .load_period                   : 0.000000
[68145.181436]   .load_contrib                  : 0
[68145.181437]   .load_tg                       : 0
[68145.181438] 
[68145.181438] rt_rq[1]:
[68145.181439]   .rt_nr_running                 : 0
[68145.181441]   .rt_throttled                  : 0
[68145.181442]   .rt_time                       : 0.002810
[68145.181443]   .rt_runtime                    : 950.000000
[68145.181445] 
[68145.181446] runnable tasks:
[68145.181446]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[68145.181447] ----------------------------------------------------------------------------------------------------------
[68145.181467] R           bash  8880       804.468551      1051   123               0               0               0.000000               0.000000               0.000000 /autogroup-728
[68145.181474] 
[68145.181474] cpu#2, 2893.340 MHz
[68145.181475]   .nr_running                    : 1
[68145.181477]   .load                          : 1006
[68145.181478]   .nr_switches                   : 281539588
[68145.181479]   .nr_load_updates               : 5389825
[68145.181481]   .nr_uninterruptible            : 4408
[68145.181482]   .next_balance                  : 4311.972269
[68145.181484]   .curr->pid                     : 8272
[68145.181485]   .clock                         : 68145181.347401
[68145.181486]   .cpu_load[0]                   : 1006
[68145.181488]   .cpu_load[1]                   : 1003
[68145.181489]   .cpu_load[2]                   : 979
[68145.181490]   .cpu_load[3]                   : 940
[68145.181491]   .cpu_load[4]                   : 926
[68145.181493] 
[68145.181493] cfs_rq[2]:/autogroup-53
[68145.181495]   .exec_clock                    : 0.000000
[68145.181496]   .MIN_vruntime                  : 0.000001
[68145.181498]   .min_vruntime                  : 14748239.445043
[68145.181499]   .max_vruntime                  : 0.000001
[68145.181500]   .spread                        : 0.000000
[68145.181502]   .spread0                       : -2191847.635738
[68145.181503]   .nr_spread_over                : 0
[68145.181505]   .nr_running                    : 1
[68145.181506]   .load                          : 1024
[68145.181507]   .load_avg                      : 8875.504327
[68145.181509]   .load_period                   : 8.171060
[68145.181510]   .load_contrib                  : 1043
[68145.181511]   .load_tg                       : 1480
[68145.181513]   .se->exec_start                : 68145181.347401
[68145.181514]   .se->vruntime                  : 23834838.341563
[68145.181516]   .se->sum_exec_runtime          : 14308302.530944
[68145.181517]   .se->load.weight               : 1006
[68145.181518] 
[68145.181519] cfs_rq[2]:/
[68145.181520]   .exec_clock                    : 0.000000
[68145.181522]   .MIN_vruntime                  : 0.000001
[68145.181523]   .min_vruntime                  : 23834838.341563
[68145.181525]   .max_vruntime                  : 0.000001
[68145.181526]   .spread                        : 0.000000
[68145.181527]   .spread0                       : 6894751.260782
[68145.181529]   .nr_spread_over                : 0
[68145.181530]   .nr_running                    : 1
[68145.181531]   .load                          : 1006
[68145.181533]   .load_avg                      : 0.000000
[68145.181534]   .load_period                   : 0.000000
[68145.181535]   .load_contrib                  : 0
[68145.181536]   .load_tg                       : 0
[68145.181538] 
[68145.181538] rt_rq[2]:
[68145.181539]   .rt_nr_running                 : 0
[68145.181540]   .rt_throttled                  : 0
[68145.181542]   .rt_time                       : 0.002557
[68145.181543]   .rt_runtime                    : 950.000000
[68145.181545] 
[68145.181545] runnable tasks:
[68145.181546]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[68145.181547] ----------------------------------------------------------------------------------------------------------
[68145.181556] Rplugin-containe  8272  14748239.445043  94987642   120               0               0               0.000000               0.000000               0.000000 /autogroup-53
[68145.181571] 
[68145.181571] cpu#3, 2893.340 MHz
[68145.181573]   .nr_running                    : 0
[68145.181574]   .load                          : 0
[68145.181575]   .nr_switches                   : 284183655
[68145.181576]   .nr_load_updates               : 5361929
[68145.181578]   .nr_uninterruptible            : -2384
[68145.181579]   .next_balance                  : 4311.972267
[68145.181581]   .curr->pid                     : 0
[68145.181582]   .clock                         : 68145181.363470
[68145.181583]   .cpu_load[0]                   : 923
[68145.181584]   .cpu_load[1]                   : 466
[68145.181586]   .cpu_load[2]                   : 287
[68145.181587]   .cpu_load[3]                   : 227
[68145.181588]   .cpu_load[4]                   : 173
[68145.181590] 
[68145.181590] cfs_rq[3]:/autogroup-345
[68145.181591]   .exec_clock                    : 0.000000
[68145.181593]   .MIN_vruntime                  : 0.000001
[68145.181594]   .min_vruntime                  : 271574.282861
[68145.181596]   .max_vruntime                  : 0.000001
[68145.181597]   .spread                        : 0.000000
[68145.181598]   .spread0                       : -16668512.797920
[68145.181600]   .nr_spread_over                : 0
[68145.181601]   .nr_running                    : 0
[68145.181602]   .load                          : 0
[68145.181604]   .load_avg                      : 2929.355520
[68145.181605]   .load_period                   : 8.069625
[68145.181606]   .load_contrib                  : 363
[68145.181608]   .load_tg                       : 431
[68145.181609]   .se->exec_start                : 68145181.362481
[68145.181611]   .se->vruntime                  : 24275013.527067
[68145.181612]   .se->sum_exec_runtime          : 337338.760030
[68145.181614]   .se->load.weight               : 2
[68145.181615] 
[68145.181616] cfs_rq[3]:/autogroup-99
[68145.181617]   .exec_clock                    : 0.000000
[68145.181618]   .MIN_vruntime                  : 0.000001
[68145.181620]   .min_vruntime                  : 709630.528938
[68145.181621]   .max_vruntime                  : 0.000001
[68145.181623]   .spread                        : 0.000000
[68145.181624]   .spread0                       : -16230456.551843
[68145.181625]   .nr_spread_over                : 0
[68145.181627]   .nr_running                    : 0
[68145.181628]   .load                          : 0
[68145.181629]   .load_avg                      : 80.933248
[68145.181631]   .load_period                   : 7.593330
[68145.181632]   .load_contrib                  : 10
[68145.181633]   .load_tg                       : 20
[68145.181635]   .se->exec_start                : 68145172.520017
[68145.181636]   .se->vruntime                  : 24275013.536371
[68145.181638]   .se->sum_exec_runtime          : 455298.062310
[68145.181639]   .se->load.weight               : 2
[68145.181640] 
[68145.181641] cfs_rq[3]:/autogroup-53
[68145.181642]   .exec_clock                    : 0.000000
[68145.181643]   .MIN_vruntime                  : 0.000001
[68145.181645]   .min_vruntime                  : 15285191.917887
[68145.181646]   .max_vruntime                  : 0.000001
[68145.181648]   .spread                        : 0.000000
[68145.181649]   .spread0                       : -1654895.162894
[68145.181651]   .nr_spread_over                : 0
[68145.181652]   .nr_running                    : 0
[68145.181653]   .load                          : 0
[68145.181654]   .load_avg                      : 27.589206
[68145.181656]   .load_period                   : 7.598913
[68145.181657]   .load_contrib                  : 3
[68145.181658]   .load_tg                       : 1480
[68145.181660]   .se->exec_start                : 68145171.243075
[68145.181661]   .se->vruntime                  : 24275021.987757
[68145.181663]   .se->sum_exec_runtime          : 15157215.916175
[68145.181664]   .se->load.weight               : 2
[68145.181666] 
[68145.181666] cfs_rq[3]:/
[68145.181667]   .exec_clock                    : 0.000000
[68145.181669]   .MIN_vruntime                  : 0.000001
[68145.181670]   .min_vruntime                  : 24275021.987757
[68145.181672]   .max_vruntime                  : 0.000001
[68145.181673]   .spread                        : 0.000000
[68145.181674]   .spread0                       : 7334934.906976
[68145.181675]   .nr_spread_over                : 0
[68145.181676]   .nr_running                    : 0
[68145.181677]   .load                          : 0
[68145.181678]   .load_avg                      : 0.000000
[68145.181680]   .load_period                   : 0.000000
[68145.181681]   .load_contrib                  : 0
[68145.181683]   .load_tg                       : 0
[68145.181684] 
[68145.181685] rt_rq[3]:
[68145.181686]   .rt_nr_running                 : 0
[68145.181687]   .rt_throttled                  : 0
[68145.181689]   .rt_time                       : 0.004236
[68145.181691]   .rt_runtime                    : 950.000000
[68145.181693] 
[68145.181693] runnable tasks:
[68145.181694]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[68145.181695] ----------------------------------------------------------------------------------------------------------
[68145.181712] R  btrfs-endio-3 13855  24275012.987757    163715   120               0               0               0.000000               0.000000               0.000000 /
[68145.181719] 
[68151.449220] kworker/0:0: page allocation failure: order:1, mode:0x4020
[68151.449225] Pid: 9004, comm: kworker/0:0 Tainted: G         C O 3.4.4-amd64-preempt-noide-20120410 #1
[68151.449227] Call Trace:
[68151.449228]  <IRQ>  [<ffffffff810bf8d8>] ? warn_alloc_failed+0x11f/0x132
[68151.449239]  [<ffffffff810453ff>] ? __mod_timer+0x13a/0x14c
[68151.449243]  [<ffffffff810c26e2>] ? __alloc_pages_nodemask+0x72f/0x7df
[68151.449256]  [<ffffffff810ecf10>] ? alloc_pages_current+0xc7/0xe4
[68151.449266]  [<ffffffffa04ca247>] ? iwlagn_rx_allocate+0x97/0x24d [iwlwifi]
[68151.449273]  [<ffffffffa04cb27b>] ? iwl_irq_tasklet+0x6e4/0x838 [iwlwifi]
[68151.449279]  [<ffffffff8103f6e9>] ? tasklet_action+0x79/0xc8
[68151.449283]  [<ffffffff8103f205>] ? __do_softirq+0xc0/0x188
[68151.449288]  [<ffffffff8136879c>] ? call_softirq+0x1c/0x30
[68151.449293]  [<ffffffff8100fcf9>] ? do_softirq+0x3c/0x7b
[68151.449297]  [<ffffffff8103f4f3>] ? irq_exit+0x3d/0xa5
[68151.449301]  [<ffffffff8100fa1e>] ? do_IRQ+0x81/0x97
[68151.449306]  [<ffffffff81362e2a>] ? common_interrupt+0x6a/0x6a
[68151.449308]  <EOI>  [<ffffffff811b7bca>] ? idr_get_next+0x7d/0x92
[68151.449318]  [<ffffffff81088d74>] ? css_get_next+0x59/0x97
[68151.449322]  [<ffffffff810fc115>] ? mem_cgroup_iter+0x109/0x1ab
[68151.449328]  [<ffffffff810cb31a>] ? shrink_zone+0x89/0x9b
[68151.449333]  [<ffffffff810cb73c>] ? do_try_to_free_pages+0x1e4/0x434
[68151.449338]  [<ffffffff810cbc11>] ? try_to_free_pages+0xb3/0xf9
[68151.449343]  [<ffffffff810c24a2>] ? __alloc_pages_nodemask+0x4ef/0x7df
[68151.449349]  [<ffffffff810ecf10>] ? alloc_pages_current+0xc7/0xe4
[68151.449356]  [<ffffffffa04ca247>] ? iwlagn_rx_allocate+0x97/0x24d [iwlwifi]
[68151.449363]  [<ffffffffa04ca81e>] ? iwlagn_rx_replenish+0x3a/0x3a [iwlwifi]
[68151.449369]  [<ffffffffa04ca7fc>] ? iwlagn_rx_replenish+0x18/0x3a [iwlwifi]
[68151.449373]  [<ffffffff8104ea7d>] ? process_one_work+0x16d/0x298
[68151.449379]  [<ffffffff8104f4d9>] ? worker_thread+0xc2/0x145
[68151.449383]  [<ffffffff8104f417>] ? manage_workers.isra.23+0x15b/0x15b
[68151.449386]  [<ffffffff81052788>] ? kthread+0x7d/0x85
[68151.449390]  [<ffffffff813686a4>] ? kernel_thread_helper+0x4/0x10
[68151.449395]  [<ffffffff8105270b>] ? kthread_freezable_should_stop+0x37/0x37
[68151.449399]  [<ffffffff813686a0>] ? gs_change+0x13/0x13
[68151.449401] Mem-Info:
[68151.449403] Node 0 DMA per-cpu:
[68151.449406] CPU    0: hi:    0, btch:   1 usd:   0
[68151.449409] CPU    1: hi:    0, btch:   1 usd:   0
[68151.449411] CPU    2: hi:    0, btch:   1 usd:   0
[68151.449413] CPU    3: hi:    0, btch:   1 usd:   0
[68151.449415] Node 0 DMA32 per-cpu:
[68151.449418] CPU    0: hi:  186, btch:  31 usd:  40
[68151.449421] CPU    1: hi:  186, btch:  31 usd:   0
[68151.449423] CPU    2: hi:  186, btch:  31 usd:   0
[68151.449425] CPU    3: hi:  186, btch:  31 usd:   0
[68151.449427] Node 0 Normal per-cpu:
[68151.449430] CPU    0: hi:  186, btch:  31 usd:  34
[68151.449432] CPU    1: hi:  186, btch:  31 usd:  28
[68151.449434] CPU    2: hi:  186, btch:  31 usd:   0
[68151.449436] CPU    3: hi:  186, btch:  31 usd:   0
[68151.449441] active_anon:722200 inactive_anon:259222 isolated_anon:0
[68151.449442]  active_file:278984 inactive_file:316208 isolated_file:0
[68151.449443]  unevictable:1 dirty:180847 writeback:0 unstable:0
[68151.449444]  free:40350 slab_reclaimable:31197 slab_unreclaimable:22223
[68151.449446]  mapped:306850 shmem:33690 pagetables:19223 bounce:0
[68151.449449] Node 0 DMA free:15904kB min:132kB low:164kB high:196kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15680kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[68151.449461] lowmem_reserve[]: 0 3257 7777 7777
[68151.449468] Node 0 DMA32 free:81536kB min:28252kB low:35312kB high:42376kB active_anon:1292064kB inactive_anon:514608kB active_file:593820kB inactive_file:686892kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3335900kB mlocked:0kB dirty:332952kB writeback:0kB mapped:185252kB shmem:48512kB slab_reclaimable:40220kB slab_unreclaimable:22240kB kernel_stack:1600kB pagetables:15604kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[68151.449480] lowmem_reserve[]: 0 0 4519 4519
[68151.449486] Node 0 Normal free:63960kB min:39196kB low:48992kB high:58792kB active_anon:1596736kB inactive_anon:522280kB active_file:522116kB inactive_file:577940kB unevictable:4kB isolated(anon):0kB isolated(file):0kB present:4627820kB mlocked:4kB dirty:390436kB writeback:0kB mapped:1042148kB shmem:86248kB slab_reclaimable:84568kB slab_unreclaimable:66652kB kernel_stack:4920kB pagetables:61288kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:34 all_unreclaimable? no
[68151.449500] lowmem_reserve[]: 0 0 0 0
[68151.449506] Node 0 DMA: 0*4kB 0*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15904kB
[68151.449521] Node 0 DMA32: 19072*4kB 12*8kB 0*16kB 1*32kB 1*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 1*4096kB = 81600kB
[68151.449537] Node 0 Normal: 14790*4kB 86*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 63944kB
[68151.449552] 664276 total pagecache pages
[68151.449555] 35263 pages in swap cache
[68151.449557] Swap cache stats: add 373242, delete 337979, find 73039/82302
[68151.449560] Free swap  = 3029760kB
[68151.449562] Total swap = 4106248kB
[68151.475328] 2057712 pages RAM
[68151.475330] 340431 pages reserved
[68151.475331] 589330 pages shared
[68151.475332] 1252827 pages non-shared
[68151.475337] iwlwifi 0000:03:00.0: Failed to alloc_pages with GFP_ATOMIC.Only 5 free buffers remaining.
[69042.086472] btrfs: unlinked 9 orphans
[69042.307617] btrfs: unlinked 78 orphans
[69042.434375] btrfs: unlinked 1 orphans
[69042.598993] btrfs: unlinked 27 orphans
[69647.593815] nfs: server gargamel not responding, still trying
[69647.593830] nfs: server gargamel not responding, still trying
[69647.593835] nfs: server gargamel not responding, still trying
[69647.593840] nfs: server gargamel not responding, still trying
[69647.593845] nfs: server gargamel not responding, still trying
(...)
[69658.194846] nfs: server gargamel not responding, still trying
[69658.194848] nfs: server gargamel not responding, still trying
[69658.194849] nfs: server gargamel not responding, still trying
[69671.113619] nfs: server gargamel OK
[69671.456875] nfs: server gargamel OK
[69673.105176] SysRq : Show Blocked State
[69673.105182]   task                        PC stack   pid father
[69673.105325] automount       D ffff88020e94e810     0 10363      1 0x00000080
[69673.105330]  ffff88020e94e810 0000000000000086 ffff88021142f0c0 ffff880002250140
[69673.105334]  0000000000013680 ffff8800099e3fd8 ffff8800099e3fd8 ffff88020e94e810
[69673.105338]  ffff88021142f0c0 7fffffffffffffff 7fffffffffffffff ffff8800099e3480
[69673.105342] Call Trace:
[69673.105350]  [<ffffffff81360e2b>] ? schedule_timeout+0x2c/0xdb
[69673.105355]  [<ffffffff8104e736>] ? __queue_work+0x22e/0x256
[69673.105360]  [<ffffffff8105dd51>] ? get_parent_ip+0x9/0x1b
[69673.105363]  [<ffffffff8136583e>] ? sub_preempt_count+0x83/0x94
[69673.105366]  [<ffffffff81361967>] ? wait_for_common+0x9a/0x112
[69673.105369]  [<ffffffff8105f46a>] ? try_to_wake_up+0x1b4/0x1b4
[69673.105372]  [<ffffffff8104c785>] ? call_usermodehelper_exec+0x9b/0xdd
[69673.105376]  [<ffffffff811679f6>] ? call_sbin_request_key+0x265/0x2d1
[69673.105385]  [<ffffffff81167d75>] ? request_key_and_link+0x313/0x39a
[69673.105389]  [<ffffffff810f3e0c>] ? ____cache_alloc+0x19/0x205
[69673.105393]  [<ffffffff81167eae>] ? request_key+0x37/0x69
[69673.105396]  [<ffffffff810570aa>] ? override_creds+0x1f/0x32
[69673.105411]  [<ffffffffa070196f>] ? nfs_idmap_request_key+0xe6/0x18b [nfs]
[69673.105422]  [<ffffffffa0701b25>] ? nfs_idmap_lookup_id+0x53/0xca [nfs]
[69673.105432]  [<ffffffffa06f8389>] ? decode_getfattr_attrs+0x8de/0xcf4 [nfs]
[69673.105436]  [<ffffffff81061521>] ? set_next_entity+0x32/0x52
[69673.105445]  [<ffffffffa06fdcb0>] ? nfs4_xdr_dec_lookup+0x71/0x71 [nfs]
[69673.105454]  [<ffffffffa06fd665>] ? decode_getfattr_generic.constprop.83+0x7f/0xcd [nfs]
[69673.105464]  [<ffffffffa06fdcb0>] ? nfs4_xdr_dec_lookup+0x71/0x71 [nfs]
[69673.105475]  [<ffffffffa06fdcf9>] ? nfs4_xdr_dec_getattr+0x49/0x50 [nfs]
[69673.105484]  [<ffffffffa069be59>] ? rpc_make_runnable+0x6a/0x6a [sunrpc]
[69673.105492]  [<ffffffffa069d7f3>] ? rpcauth_unwrap_resp+0x9b/0xa8 [sunrpc]
[69673.105498]  [<ffffffffa069be59>] ? rpc_make_runnable+0x6a/0x6a [sunrpc]
[69673.105504]  [<ffffffffa0693f70>] ? call_decode+0x673/0x708 [sunrpc]
[69673.105509]  [<ffffffffa06938fd>] ? call_bc_transmit+0x109/0x109 [sunrpc]
[69673.105514]  [<ffffffffa06938fd>] ? call_bc_transmit+0x109/0x109 [sunrpc]
[69673.105520]  [<ffffffffa069c6a1>] ? __rpc_execute+0xbe/0x320 [sunrpc]
[69673.105524]  [<ffffffff81052c0e>] ? wake_up_bit+0xd/0x1e
[69673.105530]  [<ffffffffa06954e7>] ? rpc_run_task+0x77/0x7e [sunrpc]
[69673.105535]  [<ffffffffa06955dd>] ? rpc_call_sync+0x42/0x62 [sunrpc]
[69673.105545]  [<ffffffffa06ef1d4>] ? _nfs4_proc_getattr+0x8b/0x94 [nfs]
[69673.105555]  [<ffffffffa06f2629>] ? nfs4_proc_getattr+0x2b/0x48 [nfs]
[69673.105562]  [<ffffffffa06de0f5>] ? __nfs_revalidate_inode+0xab/0x194 [nfs]
[69673.105569]  [<ffffffffa06d94c3>] ? nfs_check_verifier+0x42/0x60 [nfs]
[69673.105575]  [<ffffffffa06d9607>] ? nfs_lookup_revalidate+0xf0/0x353 [nfs]
[69673.105582]  [<ffffffffa06db091>] ? nfs_open_revalidate+0x1bc/0x1cb [nfs]
[69673.105585]  [<ffffffff8136583e>] ? sub_preempt_count+0x83/0x94
[69673.105588]  [<ffffffff81362b37>] ? _raw_spin_unlock+0x25/0x31
[69673.105592]  [<ffffffff81113e7f>] ? __d_lookup+0xd1/0xe3
[69673.105594]  [<ffffffff8110bf3f>] ? inode_permission+0x65/0xda
[69673.105597]  [<ffffffff8110ba37>] ? walk_component+0x202/0x3c8
[69673.105601]  [<ffffffff811be7eb>] ? put_dec+0x2e/0x33
[69673.105604]  [<ffffffff8110c81a>] ? path_lookupat+0x7c/0x29b
[69673.105608]  [<ffffffff810fcc74>] ? __mem_cgroup_uncharge_common+0x100/0x1fd
[69673.105612]  [<ffffffff810c0392>] ? get_pageblock_flags_group+0x3a/0x6e
[69673.105616]  [<ffffffffa07bfb60>] ? find_autofs_mount+0x9f/0x9f [autofs4]
[69673.105619]  [<ffffffff8110ca55>] ? do_path_lookup+0x1c/0x87
[69673.105622]  [<ffffffffa07bfb60>] ? find_autofs_mount+0x9f/0x9f [autofs4]
[69673.105625]  [<ffffffff8110cc79>] ? kern_path+0x1d/0x3a
[69673.105629]  [<ffffffffa07c0020>] ? _autofs_dev_ioctl+0x82/0x32e [autofs4]
[69673.105632]  [<ffffffff810f49aa>] ? __kmalloc_track_caller+0xf6/0x108
[69673.105636]  [<ffffffffa07bfbb5>] ? autofs_dev_ioctl_ismountpoint+0x55/0x137 [autofs4]
[69673.105640]  [<ffffffffa07c0239>] ? _autofs_dev_ioctl+0x29b/0x32e [autofs4]
[69673.105644]  [<ffffffffa07c02d7>] ? autofs_dev_ioctl+0xb/0xf [autofs4]
[69673.105647]  [<ffffffff81110091>] ? do_vfs_ioctl+0x403/0x444
[69673.105650]  [<ffffffff810dcecf>] ? do_munmap+0x2da/0x2f3
[69673.105653]  [<ffffffff8111011d>] ? sys_ioctl+0x4b/0x72
[69673.105657]  [<ffffffff8136723d>] ? system_call_fastpath+0x1a/0x1f
[69673.105666] mc              D ffff8802134ff750     0  6526  21734 0x00000080
[69673.105670]  ffff8802134ff750 0000000000000086 0000000000000008 ffff880175d69890
[69673.105673]  0000000000013680 ffff88001a98dfd8 ffff88001a98dfd8 ffff8802134ff750
[69673.105677]  ffff8801a299ede0 ffff88021e213680 ffff8802134ff750 ffffffff810bb429
[69673.105681] Call Trace:
[69673.105684]  [<ffffffff810bb429>] ? __lock_page+0x66/0x66
[69673.105687]  [<ffffffff81362059>] ? io_schedule+0x55/0x6b
[69673.105690]  [<ffffffff810bb42f>] ? sleep_on_page+0x6/0xa
[69673.105692]  [<ffffffff81361054>] ? __wait_on_bit+0x3e/0x71
[69673.105696]  [<ffffffff810bb577>] ? wait_on_page_bit+0x6e/0x73
[69673.105699]  [<ffffffff81052e69>] ? autoremove_wake_function+0x2a/0x2a
[69673.105731]  [<ffffffffa0199d18>] ? read_extent_buffer_pages+0x1fb/0x24b [btrfs]
[69673.105745]  [<ffffffffa0175112>] ? lock_page+0x11/0x11 [btrfs]
[69673.105758]  [<ffffffffa0176e69>] ? btree_read_extent_buffer_pages.constprop.110+0x5c/0xf3 [btrfs]
[69673.105771]  [<ffffffffa0177412>] ? read_tree_block+0x25/0x2d [btrfs]
[69673.105782]  [<ffffffffa0163087>] ? read_block_for_search.isra.32+0x2af/0x2e7 [btrfs]
[69673.105793]  [<ffffffffa01649c2>] ? btrfs_search_slot+0x48d/0x659 [btrfs]
[69673.105805]  [<ffffffffa0172d7d>] ? btrfs_lookup_csum+0x66/0x106 [btrfs]
[69673.105808]  [<ffffffff8136583e>] ? sub_preempt_count+0x83/0x94
[69673.105820]  [<ffffffffa0172fad>] ? __btrfs_lookup_bio_sums+0x190/0x30a [btrfs]
[69673.105834]  [<ffffffffa017d021>] ? btrfs_submit_bio_hook+0xa9/0x12a [btrfs]
[69673.105849]  [<ffffffffa0194af3>] ? submit_one_bio+0x82/0xb9 [btrfs]
[69673.105863]  [<ffffffffa01977c7>] ? submit_extent_page.isra.26+0x10a/0x1b2 [btrfs]
[69673.105876]  [<ffffffffa0196d91>] ? repair_io_failure+0x18e/0x18e [btrfs]
[69673.105889]  [<ffffffffa0197cf5>] ? __extent_read_full_page+0x424/0x4be [btrfs]
[69673.105902]  [<ffffffffa0196d91>] ? repair_io_failure+0x18e/0x18e [btrfs]
[69673.105916]  [<ffffffffa017eca4>] ? btrfs_writepage+0x4b/0x4b [btrfs]
[69673.105920]  [<ffffffff810c56b3>] ? __lru_cache_add+0x7b/0x8d
[69673.105934]  [<ffffffffa01988e8>] ? extent_readpages+0xaf/0xf3 [btrfs]
[69673.105947]  [<ffffffffa017eca4>] ? btrfs_writepage+0x4b/0x4b [btrfs]
[69673.105950]  [<ffffffff810c4640>] ? __do_page_cache_readahead+0x139/0x1de
[69673.105953]  [<ffffffff810c493d>] ? ra_submit+0x19/0x1d
[69673.105956]  [<ffffffff810bca23>] ? generic_file_aio_read+0x2b0/0x5d3
[69673.105960]  [<ffffffff81110627>] ? set_fd_set+0x23/0x26
[69673.105963]  [<ffffffff8110252a>] ? do_sync_read+0xab/0xe3
[69673.105967]  [<ffffffff81362b73>] ? _raw_spin_unlock_irqrestore+0x30/0x3e
[69673.105971]  [<ffffffff810595b4>] ? __wake_up+0x35/0x46
[69673.105973]  [<ffffffff81102c22>] ? vfs_read+0x9f/0xe6
[69673.105977]  [<ffffffff81103c2d>] ? fget_light+0x33/0x8d
[69673.105979]  [<ffffffff81102cae>] ? sys_read+0x45/0x6b
[69673.105983]  [<ffffffff8136723d>] ? system_call_fastpath+0x1a/0x1f
[69673.105986] mplayer         D ffff8802017ef040     0  8109    538 0x00000080
[69673.105990]  ffff8802017ef040 0000000000000086 ffff88012ff54700 ffff880121d77080
[69673.105993]  0000000000013680 ffff88013fc0dfd8 ffff88013fc0dfd8 ffff8802017ef040
[69673.105996]  0000000000000000 ffff88013fc0d890 ffff88021e5b5208 ffffffff8116761a
[69673.106000] Call Trace:
[69673.106003]  [<ffffffff8116761a>] ? wait_for_key_construction+0x59/0x59
[69673.106005]  [<ffffffff81167620>] ? key_wait_bit+0x6/0xa
[69673.106008]  [<ffffffff81361054>] ? __wait_on_bit+0x3e/0x71
[69673.106011]  [<ffffffff813610f6>] ? out_of_line_wait_on_bit+0x6f/0x78
[69673.106014]  [<ffffffff8116761a>] ? wait_for_key_construction+0x59/0x59
[69673.106017]  [<ffffffff81052e69>] ? autoremove_wake_function+0x2a/0x2a
[69673.106020]  [<ffffffff811675fb>] ? wait_for_key_construction+0x3a/0x59
[69673.106022]  [<ffffffff81167ec3>] ? request_key+0x4c/0x69
[69673.106025]  [<ffffffff810570aa>] ? override_creds+0x1f/0x32
[69673.106036]  [<ffffffffa070196f>] ? nfs_idmap_request_key+0xe6/0x18b [nfs]
[69673.106046]  [<ffffffffa0701b25>] ? nfs_idmap_lookup_id+0x53/0xca [nfs]
[69673.106056]  [<ffffffffa06f8389>] ? decode_getfattr_attrs+0x8de/0xcf4 [nfs]
[69673.106059]  [<ffffffff81061521>] ? set_next_entity+0x32/0x52
[69673.106069]  [<ffffffffa06fdcb0>] ? nfs4_xdr_dec_lookup+0x71/0x71 [nfs]
[69673.106078]  [<ffffffffa06fd665>] ? decode_getfattr_generic.constprop.83+0x7f/0xcd [nfs]
[69673.106087]  [<ffffffffa06fdcb0>] ? nfs4_xdr_dec_lookup+0x71/0x71 [nfs]
[69673.106096]  [<ffffffffa06fdcf9>] ? nfs4_xdr_dec_getattr+0x49/0x50 [nfs]
[69673.106104]  [<ffffffffa069be59>] ? rpc_make_runnable+0x6a/0x6a [sunrpc]
[69673.106111]  [<ffffffffa069d7f3>] ? rpcauth_unwrap_resp+0x9b/0xa8 [sunrpc]
[69673.106117]  [<ffffffffa069be59>] ? rpc_make_runnable+0x6a/0x6a [sunrpc]
[69673.106122]  [<ffffffffa0693f70>] ? call_decode+0x673/0x708 [sunrpc]
[69673.106128]  [<ffffffffa06938fd>] ? call_bc_transmit+0x109/0x109 [sunrpc]
[69673.106133]  [<ffffffffa06938fd>] ? call_bc_transmit+0x109/0x109 [sunrpc]
[69673.106139]  [<ffffffffa069c6a1>] ? __rpc_execute+0xbe/0x320 [sunrpc]
[69673.106141]  [<ffffffff81052c0e>] ? wake_up_bit+0xd/0x1e
[69673.106147]  [<ffffffffa06954e7>] ? rpc_run_task+0x77/0x7e [sunrpc]
[69673.106152]  [<ffffffffa06955dd>] ? rpc_call_sync+0x42/0x62 [sunrpc]
[69673.106162]  [<ffffffffa06ef1d4>] ? _nfs4_proc_getattr+0x8b/0x94 [nfs]
[69673.106172]  [<ffffffffa06f2629>] ? nfs4_proc_getattr+0x2b/0x48 [nfs]
[69673.106179]  [<ffffffffa06de0f5>] ? __nfs_revalidate_inode+0xab/0x194 [nfs]
[69673.106186]  [<ffffffffa06de21a>] ? nfs_revalidate_mapping+0x3c/0xf5 [nfs]
[69673.106193]  [<ffffffffa06db88d>] ? nfs_file_read+0x8d/0xce [nfs]
[69673.106196]  [<ffffffff8110252a>] ? do_sync_read+0xab/0xe3
[69673.106199]  [<ffffffff810f3bb4>] ? kfree+0x65/0x76
[69673.106204]  [<ffffffffa035f8d6>] ? snd_timer_user_read+0x10a/0x1b4 [snd_timer]
[69673.106207]  [<ffffffff81102c22>] ? vfs_read+0x9f/0xe6
[69673.106209]  [<ffffffff81103c2d>] ? fget_light+0x33/0x8d
[69673.106212]  [<ffffffff81102cae>] ? sys_read+0x45/0x6b
[69673.106215]  [<ffffffff8136723d>] ? system_call_fastpath+0x1a/0x1f

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
