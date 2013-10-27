From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [BUG 3.12.rc4] Oops: unable to handle kernel paging request
 during shutdown
Date: Sun, 27 Oct 2013 20:39:47 +0000
Message-ID: <CA+55aFxuVpDo3LvmG9j-Hu7sENLTcsB6_CY2TA4mE-k+CuTeGg@mail.gmail.com>
References: <525BD08C.2080101@t-online.de>
	<CA+55aFwN++wO=rTFaH7m6YYQX+Fv3qDt6Hxs7UnPUJpFsrwSkA@mail.gmail.com>
	<CA+55aFy7TpvkVuPEOJ7Qqirwap1gXoD1_MrYLhgPAYuVpN8u=w@mail.gmail.com>
	<alpine.DEB.2.02.1310251221310.5266@ionos.tec.linutronix.de>
	<CA+55aFxw1Hm4QVeEigkByP5RppSL30oHnLoR16C=henf-a=uFQ@mail.gmail.com>
	<CA+55aFyb72qoZ1Tjpb+=q-6+GmwoOXjfntY_zZnf300gg3d1Hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Knut Petersen <Knut_Petersen@t-online.de>,
	Ingo Molnar <mingo@kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	=?UTF-8?B?RnLDqWTDqXJpYyBXZWlzYmVja2Vy?= <fweisbec@gmail.com>,
	Greg KH <greg@kroah.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFyb72qoZ1Tjpb+=q-6+GmwoOXjfntY_zZnf300gg3d1Hg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 27, 2013 at 8:20 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Appended is a warning I get with DEBUG_TIMER_OBJECTS. Seems to be a
> device-mapper issue.

.. and here's another one. This time it looks like nf_conntrack_free()
is freeing something that has a delayed work in it (again, likely an
embedded 'struct kobject'). Looks like it is the

    kmem_cache_destroy(net->ct.nf_conntrack_cachep);

that triggers this. Which probably means that there are still slab
entries on that slab cache or something, but I didn't dig any deeper..

David? Patrick? Pablo? Jozsef? Any ideas? This was immediately preceded by

  [ 1136.316280] kobject: 'nf_conntrack_ffff8800b74d0000'
(ffff8801196fac78): kobject_uevent_env
  [ 1136.316287] kobject: 'nf_conntrack_ffff8800b74d0000'
(ffff8801196fac78): fill_kobj_path: path =
'/kernel/slab/nf_conntrack_ffff8800b74d0000'
  [ 1136.316331] kobject: 'nf_conntrack_ffff8800b74d0000'
(ffff8801196fac78): kobject_release, parent           (null) (delayed)

and I think it's that delayed "kobject_release()" that triggers this.

Notice that kobject_release() can be delayed *without* the magic
kobject debugging option by simply having a reference count on it from
some external source. So this particular issue is probably triggered
by my extra debug options in this case (I'm running with all those
nasty "try to find bad object freeing" options, and doing module
unloading etc), but can happen without it (it's just very hard to
trigger in practice without the debug options).

             Linus

---
[ 1136.321294] ------------[ cut here ]------------
[ 1136.321305] WARNING: CPU: 2 PID: 2483 at lib/debugobjects.c:260
debug_print_object+0x83/0xa0()
[ 1136.321311] ODEBUG: free active (active state 0) object type:
timer_list hint: delayed_work_timer_fn+0x0/0x20
[ 1136.321313] Modules linked in: fuse nf_conntrack_netbios_ns
nf_conntrack_broadcast ipt_MASQUERADE ip6t_REJECT xt_conntrack bnep
bluetooth ebtable_nat ebt
[ 1136.321357]  mfd_core mei snd_page_alloc snd_timer snd soundcore
sony_laptop rfkill uinput dm_crypt crc32_pclmul crc32c_intel i915
i2c_algo_bit drm_kms_h
[ 1136.321371] CPU: 2 PID: 2483 Comm: kworker/u8:2 Tainted: G        W
   3.12.0-rc6-00331-ga2ff82065b5b #2
[ 1136.321373] Hardware name: Sony Corporation SVP11213CXB/VAIO, BIOS
R0270V7 05/17/2013
[ 1136.321378] Workqueue: netns cleanup_net
[ 1136.321380]  0000000000000009 ffff8800a86cdbc8 ffffffff8160d4a2
ffff8800a86cdc10
[ 1136.321384]  ffff8800a86cdc00 ffffffff810514e8 ffff8800b745f848
ffffffff81c365e0
[ 1136.321387]  ffffffff819f9133 ffffffff81f34750 0000000000000001
ffff8800a86cdc60
[ 1136.321390] Call Trace:
[ 1136.321398]  [<ffffffff8160d4a2>] dump_stack+0x45/0x56
[ 1136.321405]  [<ffffffff810514e8>] warn_slowpath_common+0x78/0xa0
[ 1136.321410]  [<ffffffff81051557>] warn_slowpath_fmt+0x47/0x50
[ 1136.321414]  [<ffffffff812f8883>] debug_print_object+0x83/0xa0
[ 1136.321420]  [<ffffffff8106aa90>] ? execute_in_process_context+0x90/0x90
[ 1136.321424]  [<ffffffff812f99fb>] debug_check_no_obj_freed+0x20b/0x250
[ 1136.321429]  [<ffffffff8112e7f2>] ? kmem_cache_destroy+0x92/0x100
[ 1136.321433]  [<ffffffff8115d945>] kmem_cache_free+0x125/0x210
[ 1136.321436]  [<ffffffff8112e7f2>] kmem_cache_destroy+0x92/0x100
[ 1136.321443]  [<ffffffffa046b806>]
nf_conntrack_cleanup_net_list+0x126/0x160 [nf_conntrack]
[ 1136.321449]  [<ffffffffa046c43d>]
nf_conntrack_pernet_exit+0x6d/0x80 [nf_conntrack]
[ 1136.321453]  [<ffffffff81511cc3>] ops_exit_list.isra.3+0x53/0x60
[ 1136.321457]  [<ffffffff815124f0>] cleanup_net+0x100/0x1b0
[ 1136.321460]  [<ffffffff8106b31e>] process_one_work+0x18e/0x430
[ 1136.321463]  [<ffffffff8106bf49>] worker_thread+0x119/0x390
[ 1136.321467]  [<ffffffff8106be30>] ? manage_workers.isra.23+0x2a0/0x2a0
[ 1136.321470]  [<ffffffff8107210b>] kthread+0xbb/0xc0
[ 1136.321472]  [<ffffffff81072050>] ? kthread_create_on_node+0x110/0x110
[ 1136.321477]  [<ffffffff8161b8fc>] ret_from_fork+0x7c/0xb0
[ 1136.321479]  [<ffffffff81072050>] ? kthread_create_on_node+0x110/0x110
[ 1136.321481] ---[ end trace 25f53c192da70825 ]---
