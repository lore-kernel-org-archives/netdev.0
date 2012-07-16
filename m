From: Marc MERLIN <marc@merlins.org>
Subject: Re: 3.4.4/amd64 full interrupt hangs under big nfs copies
Date: Mon, 16 Jul 2012 10:17:27 -0700
Message-ID: <20120716171727.GA18469@merlins.org>
References: <1333998672.3007.245.camel@edumazet-glaptop> <20120409.153452.1284163346306246866.davem@davemloft.net> <1334030180.13293.98.camel@edumazet-glaptop> <20120410051127.GA32048@merlins.org> <1334038263.2907.1.camel@edumazet-glaptop> <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org> <1342419529.3265.12217.camel@edumazet-glaptop> <20120716151826.GA10586@merlins.org> <1342455717.2830.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:50030 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275Ab2GPRR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 13:17:29 -0400
Content-Disposition: inline
In-Reply-To: <1342455717.2830.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 06:21:57PM +0200, Eric Dumazet wrote:
> > No, it's atually when I'm 'uploading' from my laptop to my server.
> > One interesting thing is that my server is running lvm2 with snapshots,
> > which makes writes slower than my laptop can push data over the network, so
> > it's definitely causing buffers to fill up.
> > I just did a download test and got 4.5MB/s sustained without problems.
> 
> Hmm, nfs apparently is able to push lot of data, try to reduce
> rsize/wsize to sane values, like 32K instead of 512K ?
> 
> gargamel:/mnt/dshelf2/ /net/gargamel/mnt/dshelf2 nfs4
> rw,nosuid,nodev,relatime,vers=4.0,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.205.7,local_lock=none,addr=192.168.205.3 0 0

Nice catch. That seems like an excessive default from autofs5 5.0.4-3.2+b1

So, it helped. I still got hangs, but this time they were VFS hangs. I
couldn't do anything filesystem related durign the 'hangs', but the
interrupts weren't hung anymore, so I could move my mouse cursor.

Having NFS hang all of VFS and local disk is obviously still a problem, but
at this point it may not be a networking (or wireless) related problem.

I'll attach the relevant logs during that attempt. Does that help?

Thanks,
Marc

[76903.011101] SysRq : Show Blocked State
[76903.011110]   task                        PC stack   pid father
[76903.011306] mc              D ffff88021e2d3680     0  9383   9270 0x00000080
[76903.011314]  ffff880111094100 0000000000000082 000000000000000e ffff880213549140
[76903.011322]  0000000000013680 ffff8800140e3fd8 ffff8800140e3fd8 ffff880111094100
[76903.011328]  ffff88021e5c5258 0000000000000000 ffff880111094100 ffff8800140e3e40
[76903.011335] Call Trace:
[76903.011362]  [<ffffffffa06dcdf2>] ? nfs_find_actor+0x66/0x66 [nfs]
[76903.011376]  [<ffffffffa06dce4d>] ? nfs_wait_bit_killable+0x5b/0x6e [nfs]
[76903.011384]  [<ffffffff81360f55>] ? __wait_on_bit_lock+0x3c/0x85
[76903.011391]  [<ffffffff810bb793>] ? filemap_fdatawait_range+0x11b/0x139
[76903.011397]  [<ffffffff8136100d>] ? out_of_line_wait_on_bit_lock+0x6f/0x78
[76903.011410]  [<ffffffffa06dcdf2>] ? nfs_find_actor+0x66/0x66 [nfs]
[76903.011417]  [<ffffffff81052e69>] ? autoremove_wake_function+0x2a/0x2a
[76903.011435]  [<ffffffffa06e8ca2>] ? nfs_commit_inode+0x66/0x27a [nfs]
[76903.011448]  [<ffffffffa06db56e>] ? nfs_file_fsync+0x95/0xf3 [nfs]
[76903.011455]  [<ffffffff811015a9>] ? filp_close+0x3b/0x6a
[76903.011461]  [<ffffffff8110165e>] ? sys_close+0x86/0xc7
[76903.011467]  [<ffffffff8136723d>] ? system_call_fastpath+0x1a/0x1f
[76903.011482] kworker/0:0     D ffff88021e213680     0 13850      2 0x00000080
[76903.011489]  ffff8801fac7d850 0000000000000046 ffff8802117cb848 ffff880140773750
[76903.011495]  0000000000013680 ffff88004c4e7fd8 ffff88004c4e7fd8 ffff8801fac7d850
[76903.011502]  ffff88021e5df9a0 0000000000000000 ffff8801fac7d850 ffffffffa069be59
[76903.011508] Call Trace:
[76903.011524]  [<ffffffffa069be59>] ? rpc_make_runnable+0x6a/0x6a [sunrpc]
[76903.011535]  [<ffffffffa069beb2>] ? rpc_wait_bit_killable+0x59/0x6c [sunrpc]
[76903.011541]  [<ffffffff81361054>] ? __wait_on_bit+0x3e/0x71
[76903.011547]  [<ffffffff81362b73>] ? _raw_spin_unlock_irqrestore+0x30/0x3e
[76903.011553]  [<ffffffff813610f6>] ? out_of_line_wait_on_bit+0x6f/0x78
[76903.011565]  [<ffffffffa069be59>] ? rpc_make_runnable+0x6a/0x6a [sunrpc]
[76903.011570]  [<ffffffff81052e69>] ? autoremove_wake_function+0x2a/0x2a
[76903.011587]  [<ffffffffa06e7bdf>] ? nfs_initiate_commit+0xf4/0x105 [nfs]
[76903.011604]  [<ffffffffa06e8e30>] ? nfs_commit_inode+0x1f4/0x27a [nfs]
[76903.011617]  [<ffffffffa06db97c>] ? nfs_release_page+0x56/0x73 [nfs]
[76903.011626]  [<ffffffff810ca356>] ? shrink_page_list+0x556/0x739
[76903.011635]  [<ffffffff8105dd51>] ? get_parent_ip+0x9/0x1b
[76903.011640]  [<ffffffff8136583e>] ? sub_preempt_count+0x83/0x94
[76903.011646]  [<ffffffff810c91eb>] ? update_isolated_counts.isra.44+0x148/0x16e
[76903.011653]  [<ffffffff810ca9a3>] ? shrink_inactive_list+0x2b1/0x446
[76903.011661]  [<ffffffff810cb182>] ? shrink_mem_cgroup_zone+0x371/0x480
[76903.011668]  [<ffffffff810cb2f3>] ? shrink_zone+0x62/0x9b
[76903.011675]  [<ffffffff810cb73c>] ? do_try_to_free_pages+0x1e4/0x434
[76903.011682]  [<ffffffff810cbc11>] ? try_to_free_pages+0xb3/0xf9
[76903.011688]  [<ffffffff8105931b>] ? should_resched+0x5/0x23
[76903.011695]  [<ffffffff810c24a2>] ? __alloc_pages_nodemask+0x4ef/0x7df
[76903.011702]  [<ffffffff8105dd51>] ? get_parent_ip+0x9/0x1b
[76903.011711]  [<ffffffff810ecf10>] ? alloc_pages_current+0xc7/0xe4
[76903.011723]  [<ffffffffa04ca247>] ? iwlagn_rx_allocate+0x97/0x24d [iwlwifi]
[76903.011734]  [<ffffffffa04ca81e>] ? iwlagn_rx_replenish+0x3a/0x3a [iwlwifi]
[76903.011744]  [<ffffffffa04ca7fc>] ? iwlagn_rx_replenish+0x18/0x3a [iwlwifi]
[76903.011750]  [<ffffffff8104ea7d>] ? process_one_work+0x16d/0x298
[76903.011757]  [<ffffffff8104f4d9>] ? worker_thread+0xc2/0x145
[76903.011763]  [<ffffffff8104f417>] ? manage_workers.isra.23+0x15b/0x15b
[76903.011768]  [<ffffffff81052788>] ? kthread+0x7d/0x85
[76903.011774]  [<ffffffff813686a4>] ? kernel_thread_helper+0x4/0x10
[76903.011780]  [<ffffffff8105270b>] ? kthread_freezable_should_stop+0x37/0x37
[76903.011786]  [<ffffffff813686a0>] ? gs_change+0x13/0x13
[76903.011797] Sched Debug Version: v0.10, 3.4.4-amd64-preempt-noide-20120410 #1

and

[76843.153742] 
[76873.080978] SysRq : Show Blocked State
[76873.080987]   task                        PC stack   pid father
[76873.081200] mc              D ffff88021e293680     0  9383   9270 0x00000080
[76873.081208]  ffff880111094100 0000000000000082 0000000000000001 ffff8802135107d0
[76873.081216]  0000000000013680 ffff8800140e3fd8 ffff8800140e3fd8 ffff880111094100
[76873.081222]  ffff88010c9033d0 ffff88021e293680 ffff880111094100 ffffffff810bb429
[76873.081229] Call Trace:
[76873.081241]  [<ffffffff810bb429>] ? __lock_page+0x66/0x66
[76873.081249]  [<ffffffff81362059>] ? io_schedule+0x55/0x6b
[76873.081254]  [<ffffffff810bb42f>] ? sleep_on_page+0x6/0xa
[76873.081260]  [<ffffffff81361054>] ? __wait_on_bit+0x3e/0x71
[76873.081265]  [<ffffffff810bb577>] ? wait_on_page_bit+0x6e/0x73
[76873.081272]  [<ffffffff81052e69>] ? autoremove_wake_function+0x2a/0x2a
[76873.081278]  [<ffffffff810bb6ec>] ? filemap_fdatawait_range+0x74/0x139
[76873.081285]  [<ffffffff810bc2e8>] ? filemap_write_and_wait_range+0x3b/0x4d
[76873.081308]  [<ffffffffa06db536>] ? nfs_file_fsync+0x5d/0xf3 [nfs]
[76873.081317]  [<ffffffff811015a9>] ? filp_close+0x3b/0x6a
[76873.081323]  [<ffffffff8110165e>] ? sys_close+0x86/0xc7
[76873.081330]  [<ffffffff8136723d>] ? system_call_fastpath+0x1a/0x1f
[76873.081346] kworker/0:0     D ffff88021e213680     0 13850      2 0x00000080
[76873.081352]  ffff8801fac7d850 0000000000000046 ffff880186753ce8 ffff880126d7f040
[76873.081358]  0000000000013680 ffff88004c4e7fd8 ffff88004c4e7fd8 ffff8801fac7d850
[76873.081365]  ffff8801c5ae1d70 ffff88021e213680 ffff8801fac7d850 ffffffff810bb429
[76873.081371] Call Trace:
[76873.081376]  [<ffffffff810bb429>] ? __lock_page+0x66/0x66
[76873.081381]  [<ffffffff81362059>] ? io_schedule+0x55/0x6b
[76873.081386]  [<ffffffff810bb42f>] ? sleep_on_page+0x6/0xa
[76873.081391]  [<ffffffff81361054>] ? __wait_on_bit+0x3e/0x71
[76873.081396]  [<ffffffff810bb577>] ? wait_on_page_bit+0x6e/0x73
[76873.081402]  [<ffffffff81052e69>] ? autoremove_wake_function+0x2a/0x2a
[76873.081411]  [<ffffffff810c9f66>] ? shrink_page_list+0x166/0x739
[76873.081420]  [<ffffffff8105dd51>] ? get_parent_ip+0x9/0x1b
[76873.081425]  [<ffffffff8136583e>] ? sub_preempt_count+0x83/0x94
[76873.081431]  [<ffffffff810c91eb>] ? update_isolated_counts.isra.44+0x148/0x16e
[76873.081438]  [<ffffffff810ca9a3>] ? shrink_inactive_list+0x2b1/0x446
[76873.081446]  [<ffffffff810cb182>] ? shrink_mem_cgroup_zone+0x371/0x480
[76873.081454]  [<ffffffff810cb2f3>] ? shrink_zone+0x62/0x9b
[76873.081460]  [<ffffffff810cb73c>] ? do_try_to_free_pages+0x1e4/0x434
[76873.081467]  [<ffffffff810cbc11>] ? try_to_free_pages+0xb3/0xf9
[76873.081473]  [<ffffffff8105931b>] ? should_resched+0x5/0x23
[76873.081481]  [<ffffffff810c24a2>] ? __alloc_pages_nodemask+0x4ef/0x7df
[76873.081487]  [<ffffffff8105dd51>] ? get_parent_ip+0x9/0x1b
[76873.081497]  [<ffffffff810ecf10>] ? alloc_pages_current+0xc7/0xe4
[76873.081510]  [<ffffffffa04ca247>] ? iwlagn_rx_allocate+0x97/0x24d [iwlwifi]
[76873.081521]  [<ffffffffa04ca81e>] ? iwlagn_rx_replenish+0x3a/0x3a [iwlwifi]
[76873.081530]  [<ffffffffa04ca7fc>] ? iwlagn_rx_replenish+0x18/0x3a [iwlwifi]
[76873.081538]  [<ffffffff8104ea7d>] ? process_one_work+0x16d/0x298
[76873.081545]  [<ffffffff8104f4d9>] ? worker_thread+0xc2/0x145
[76873.081551]  [<ffffffff8104f417>] ? manage_workers.isra.23+0x15b/0x15b
[76873.081556]  [<ffffffff81052788>] ? kthread+0x7d/0x85
[76873.081562]  [<ffffffff813686a4>] ? kernel_thread_helper+0x4/0x10
[76873.081568]  [<ffffffff8105270b>] ? kthread_freezable_should_stop+0x37/0x37
[76873.081574]  [<ffffffff813686a0>] ? gs_change+0x13/0x13
[76873.081585] 192.168.205.3-m D ffff88021e293680     0 14532      2 0x00000080
[76873.081590]  ffff880206d600c0 0000000000000046 ffff880186733e60 ffff88004b4230c0
[76873.081597]  0000000000013680 ffff880022305fd8 ffff880022305fd8 ffff880206d600c0
[76873.081603]  ffff88021e5bb778 0000000000000000 ffff880206d600c0 ffffffffa069be59
[76873.081609] Call Trace:
[76873.081625]  [<ffffffffa069be59>] ? rpc_make_runnable+0x6a/0x6a [sunrpc]
[76873.081637]  [<ffffffffa069beb2>] ? rpc_wait_bit_killable+0x59/0x6c [sunrpc]
[76873.081642]  [<ffffffff81361054>] ? __wait_on_bit+0x3e/0x71
[76873.081648]  [<ffffffff81362b73>] ? _raw_spin_unlock_irqrestore+0x30/0x3e
[76873.081654]  [<ffffffff813610f6>] ? out_of_line_wait_on_bit+0x6f/0x78
[76873.081665]  [<ffffffffa069be59>] ? rpc_make_runnable+0x6a/0x6a [sunrpc]
[76873.081671]  [<ffffffff81052e69>] ? autoremove_wake_function+0x2a/0x2a
[76873.081690]  [<ffffffffa06efb13>] ? nfs4_run_open_task+0x101/0x12e [nfs]
[76873.081709]  [<ffffffffa06f12fb>] ? nfs4_open_recover_helper+0xbd/0x13f [nfs]
[76873.081724]  [<ffffffffa06f13e1>] ? nfs4_open_recover+0x64/0x113 [nfs]
[76873.081740]  [<ffffffffa06f36a2>] ? nfs4_open_expired+0x69/0xc4 [nfs]
[76873.081761]  [<ffffffffa06ff5b8>] ? nfs4_do_reclaim+0x109/0x4a0 [nfs]
[76873.081779]  [<ffffffffa06fe7cb>] ? nfs4_state_clear_reclaim_reboot.part.7+0xf6/0x10a [nfs]
[76873.081797]  [<ffffffffa06ffcb2>] ? nfs4_run_state_manager+0x363/0x52e [nfs]
[76873.081814]  [<ffffffffa06ff94f>] ? nfs4_do_reclaim+0x4a0/0x4a0 [nfs]
[76873.081819]  [<ffffffff81052788>] ? kthread+0x7d/0x85
[76873.081825]  [<ffffffff813686a4>] ? kernel_thread_helper+0x4/0x10
[76873.081830]  [<ffffffff8105270b>] ? kthread_freezable_should_stop+0x37/0x37
[76873.081836]  [<ffffffff813686a0>] ? gs_change+0x13/0x13
[76873.081842] Sched Debug Version: v0.10, 3.4.4-amd64-preempt-noide-20120410 #1
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
