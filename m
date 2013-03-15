From: Sasha Levin <sasha.levin@oracle.com>
Subject: sctp: hang in sctp_remaddr_seq_show
Date: Fri, 15 Mar 2013 12:34:00 -0400
Message-ID: <51434D78.9030308@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: vyasevich@gmail.com, sri@us.ibm.com, nhorman@tuxdriver.com,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While fuzzing with trinity inside a KVM tools guest running latest -next kernel,
I've stumbled on an interesting hang related to sctp.

After some fuzzing, I get a hang message about procfs not able to grab a hold
of a mutex for one of the files:

[  375.900309] INFO: task trinity-child21:7178 blocked for more than 120 seconds.
[  375.901767] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  375.903022] trinity-child21 D ffff88009b9f74a8  5336  7178   7121 0x00000004
[  375.904211]  ffff88009ba79cb8 0000000000000002 ffff8800abf48690 ffff8800abf48690
[  375.905972]  ffff880075308000 ffff88009c798000 ffff88009ba79cb8 00000000001d7140
[  375.907263]  ffff88009c798000 ffff88009ba79fd8 00000000001d7140 00000000001d7140
[  375.908987] Call Trace:
[  375.909415]  [<ffffffff83d89569>] __schedule+0x2e9/0x3b0
[  375.910795]  [<ffffffff83d89795>] schedule+0x55/0x60
[  375.911611]  [<ffffffff83d89ae3>] schedule_preempt_disabled+0x13/0x20
[  375.912644]  [<ffffffff83d87b7d>] __mutex_lock_common+0x36d/0x5a0
[  375.913986]  [<ffffffff8129f11a>] ? seq_read+0x3a/0x3d0
[  375.914838]  [<ffffffff8129f11a>] ? seq_read+0x3a/0x3d0
[  375.916187]  [<ffffffff8129f0e0>] ? seq_lseek+0x110/0x110
[  375.917075]  [<ffffffff83d87edf>] mutex_lock_nested+0x3f/0x50
[  375.918005]  [<ffffffff8129f11a>] seq_read+0x3a/0x3d0
[  375.919124]  [<ffffffff819f19cd>] ? delay_tsc+0xdd/0x110
[  375.920916]  [<ffffffff8129f0e0>] ? seq_lseek+0x110/0x110
[  375.921794]  [<ffffffff8129f0e0>] ? seq_lseek+0x110/0x110
[  375.922966]  [<ffffffff812e7b61>] proc_reg_read+0x201/0x230
[  375.923870]  [<ffffffff812e7960>] ? proc_reg_write+0x230/0x230
[  375.924820]  [<ffffffff81279e05>] vfs_read+0xb5/0x180
[  375.925668]  [<ffffffff81279f20>] SyS_read+0x50/0xa0
[  375.926476]  [<ffffffff83d946d8>] tracesys+0xe1/0xe6
[  375.940223] 1 lock held by trinity-child21/7178:
[  375.940985]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff8129f11a>] seq_read+0x3a/0x3d

Digging deeper, there's another thread that's stuck holding that lock:

[  381.880804] trinity-child97 R  running task     4856  9490   7121 0x00000004
[  381.882064]  ffff880084cad708 0000000000000002 ffff8800bbbd71f8 ffff8800bbbd71f8
[  381.883341]  ffff8800b9490000 ffff88009a5e8000 ffff880084cad708 00000000001d7140
[  381.884652]  ffff88009a5e8000 ffff880084cadfd8 00000000001d7140 00000000001d7140
[  381.885977] Call Trace:
[  381.886392]  [<ffffffff83d89569>] __schedule+0x2e9/0x3b0
[  381.887238]  [<ffffffff83d89714>] preempt_schedule+0x44/0x70
[  381.888175]  [<ffffffff83b5674a>] ? sctp_remaddr_seq_show+0x2da/0x2f0
[  381.889314]  [<ffffffff8110e8a8>] local_bh_enable+0x128/0x140
[  381.890292]  [<ffffffff83b5674a>] sctp_remaddr_seq_show+0x2da/0x2f0
[  381.891397]  [<ffffffff83b56497>] ? sctp_remaddr_seq_show+0x27/0x2f0
[  381.892448]  [<ffffffff8129f11a>] ? seq_read+0x3a/0x3d0
[  381.893308]  [<ffffffff8129ec50>] traverse+0xe0/0x1f0
[  381.894135]  [<ffffffff8129f0e0>] ? seq_lseek+0x110/0x110
[  381.895100]  [<ffffffff8129f0e0>] ? seq_lseek+0x110/0x110
[  381.896074]  [<ffffffff8129f13c>] seq_read+0x5c/0x3d0
[  381.896912]  [<ffffffff819f19cd>] ? delay_tsc+0xdd/0x110
[  381.897796]  [<ffffffff8129f0e0>] ? seq_lseek+0x110/0x110
[  381.898734]  [<ffffffff8129f0e0>] ? seq_lseek+0x110/0x110
[  381.899629]  [<ffffffff812e7b61>] proc_reg_read+0x201/0x230
[  381.900592]  [<ffffffff812e7960>] ? proc_reg_write+0x230/0x230
[  381.901614]  [<ffffffff812e7960>] ? proc_reg_write+0x230/0x230
[  381.902543]  [<ffffffff8127a22b>] do_loop_readv_writev+0x4b/0x90
[  381.903480]  [<ffffffff8127a4a6>] do_readv_writev+0xf6/0x1d0
[  381.904456]  [<ffffffff8109b1c8>] ? kvm_clock_read+0x38/0x70
[  381.905460]  [<ffffffff8127a61e>] vfs_readv+0x3e/0x60
[  381.906306]  [<ffffffff812abb31>] default_file_splice_read+0x1e1/0x320
[  381.907365]  [<ffffffff81259396>] ? deactivate_slab+0x7d6/0x820
[  381.908412]  [<ffffffff81259396>] ? deactivate_slab+0x7d6/0x820
[  381.909404]  [<ffffffff8117db31>] ? __lock_release+0xf1/0x110
[  381.910435]  [<ffffffff81259396>] ? deactivate_slab+0x7d6/0x820
[  381.911483]  [<ffffffff81a06ee8>] ? do_raw_spin_unlock+0xc8/0xe0
[  381.912478]  [<ffffffff83d8b3d0>] ? _raw_spin_unlock+0x30/0x60
[  381.913438]  [<ffffffff81259396>] ? deactivate_slab+0x7d6/0x820
[  381.914478]  [<ffffffff812830ae>] ? alloc_pipe_info+0x3e/0xa0
[  381.915504]  [<ffffffff812830ae>] ? alloc_pipe_info+0x3e/0xa0
[  381.916461]  [<ffffffff812830ae>] ? alloc_pipe_info+0x3e/0xa0
[  381.917418]  [<ffffffff83d00b0c>] ? __slab_alloc.isra.34+0x2ed/0x31f
[  381.918533]  [<ffffffff8117acf8>] ? trace_hardirqs_on_caller+0x168/0x1a0
[  381.919637]  [<ffffffff8117ae35>] ? debug_check_no_locks_freed+0xf5/0x130
[  381.920799]  [<ffffffff812a9ef0>] ? page_cache_pipe_buf_release+0x20/0x20
[  381.921963]  [<ffffffff812aa823>] do_splice_to+0x83/0xb0
[  381.922849]  [<ffffffff812aabee>] splice_direct_to_actor+0xce/0x1c0
[  381.923874]  [<ffffffff812aa780>] ? do_splice_from+0xb0/0xb0
[  381.924855]  [<ffffffff812ac398>] do_splice_direct+0x48/0x60
[  381.925865]  [<ffffffff81279a25>] do_sendfile+0x165/0x310
[  381.926763]  [<ffffffff8117ad3d>] ? trace_hardirqs_on+0xd/0x10
[  381.927722]  [<ffffffff8127aaaa>] SyS_sendfile64+0x8a/0xc0
[  381.928702]  [<ffffffff83d94675>] ? tracesys+0x7e/0xe6
[  381.929556]  [<ffffffff83d946d8>] tracesys+0xe1/0xe6

It has gone to sleep while holding the proc mutex we're trying to acquire and
never woke up!

Looking at the code, we see:

        rcu_read_unlock();
        read_unlock(&head->lock);
        sctp_local_bh_enable(); <--- here

It hangs on local_bh_enable().

It seems that local_bh_enable() calls preempt_check_resched() which never
gets woken up. Why? I have no clue.

It's also pretty reproducible with sctp.


Thanks,
Sasha
