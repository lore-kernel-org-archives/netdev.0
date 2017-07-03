From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/17] v3 net generic subsystem refcount conversions
Date: Mon, 03 Jul 2017 02:28:56 -0700
Message-ID: <1499074136.1462.0.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1498817290-3368-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, kaber@trash.net, stephen@networkplumber.org,
        peterz@infradead.org, keescook@chromium.org
To: Elena Reshetova <elena.reshetova@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498817290-3368-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-06-30 at 13:07 +0300, Elena Reshetova wrote:
> Changes in v3:
> Rebased on top of the net-next tree.
> 
> Changes in v2:
> No changes in patches apart from rebases, but now by
> default refcount_t = atomic_t (*) and uses all atomic standard operations
> unless CONFIG_REFCOUNT_FULL is enabled. This is a compromise for the
> systems that are critical on performance (such as net) and cannot accept even
> slight delay on the refcounter operations.
> 
> This series, for core network subsystem components, replaces atomic_t reference
> counters with the new refcount_t type and API (see include/linux/refcount.h).
> By doing this we prevent intentional or accidental
> underflows or overflows that can led to use-after-free vulnerabilities.
> These patches contain only generic net pieces. Other changes will be sent separately.
> 
> The patches are fully independent and can be cherry-picked separately.
> The big patches, such as conversions for sock structure, need a very detailed
> look from maintainers: refcount managing is quite complex in them and while
> it seems that they would benefit from the change, extra checking is needed.
> The biggest corner issue is the fact that refcount_inc() does not increment
> from zero.
> 
> If there are no objections to the patches, please merge them via respective trees.
> 
> * The respective change is currently merged into -next as
>   "locking/refcount: Create unchecked atomic_t implementation".
> 
> Elena Reshetova (17):
>   net: convert inet_peer.refcnt from atomic_t to refcount_t
>   net: convert neighbour.refcnt from atomic_t to refcount_t
>   net: convert neigh_params.refcnt from atomic_t to refcount_t
>   net: convert nf_bridge_info.use from atomic_t to refcount_t
>   net: convert sk_buff.users from atomic_t to refcount_t
>   net: convert sk_buff_fclones.fclone_ref from atomic_t to refcount_t
>   net: convert sock.sk_wmem_alloc from atomic_t to refcount_t
>   net: convert sock.sk_refcnt from atomic_t to refcount_t
>   net: convert ip_mc_list.refcnt from atomic_t to refcount_t
>   net: convert in_device.refcnt from atomic_t to refcount_t
>   net: convert netpoll_info.refcnt from atomic_t to refcount_t
>   net: convert unix_address.refcnt from atomic_t to refcount_t
>   net: convert fib_rule.refcnt from atomic_t to refcount_t
>   net: convert inet_frag_queue.refcnt from atomic_t to refcount_t
>   net: convert net.passive from atomic_t to refcount_t
>   net: convert netlbl_lsm_cache.refcount from atomic_t to refcount_t
>   net: convert packet_fanout.sk_ref from atomic_t to refcount_t


Can you take a look at this please ?

Thanks.

[   64.601749] ------------[ cut here ]------------
[   64.601757] WARNING: CPU: 0 PID: 6476 at lib/refcount.c:184 refcount_sub_and_test+0x75/0xa0
[   64.601758] Modules linked in: w1_therm wire cdc_acm ehci_pci ehci_hcd mlx4_en ib_uverbs mlx4_ib ib_core mlx4_core
[   64.601769] CPU: 0 PID: 6476 Comm: ip Tainted: G        W       4.12.0-smp-DEV #274
[   64.601770] Hardware name: Intel RML,PCH/Iota_QC_19, BIOS 2.40.0 06/22/2016
[   64.601771] task: ffff8837bf482040 task.stack: ffff8837bdc08000
[   64.601773] RIP: 0010:refcount_sub_and_test+0x75/0xa0
[   64.601774] RSP: 0018:ffff8837bdc0f5c0 EFLAGS: 00010286
[   64.601776] RAX: 0000000000000026 RBX: 0000000000000001 RCX: 0000000000000000
[   64.601777] RDX: 0000000000000026 RSI: 0000000000000096 RDI: ffffed06f7b81eae
[   64.601778] RBP: ffff8837bdc0f5d0 R08: 0000000000000004 R09: fffffbfff4a54c25
[   64.601779] R10: 00000000cbc500e5 R11: ffffffffa52a6128 R12: ffff881febcf6f24
[   64.601779] R13: ffff881fbf4eaf00 R14: ffff881febcf6f80 R15: ffff8837d7a4ed00
[   64.601781] FS:  00007ff5a2f6b700(0000) GS:ffff881fff800000(0000) knlGS:0000000000000000
[   64.601782] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   64.601783] CR2: 00007ffcdc70d000 CR3: 0000001f9c91e000 CR4: 00000000001406f0
[   64.601783] Call Trace:
[   64.601786]  refcount_dec_and_test+0x11/0x20
[   64.601790]  fib_nl_delrule+0xc39/0x1630
[   64.601793]  ? is_bpf_text_address+0xe/0x20
[   64.601795]  ? fib_nl_newrule+0x25e0/0x25e0
[   64.601798]  ? depot_save_stack+0x133/0x470
[   64.601801]  ? ns_capable+0x13/0x20
[   64.601803]  ? __netlink_ns_capable+0xcc/0x100
[   64.601806]  rtnetlink_rcv_msg+0x23a/0x6a0
[   64.601808]  ? rtnl_newlink+0x1630/0x1630
[   64.601811]  ? memset+0x31/0x40
[   64.601813]  netlink_rcv_skb+0x2d7/0x440
[   64.601815]  ? rtnl_newlink+0x1630/0x1630
[   64.601816]  ? netlink_ack+0xaf0/0xaf0
[   64.601818]  ? kasan_unpoison_shadow+0x35/0x50
[   64.601820]  ? __kmalloc_node_track_caller+0x4c/0x70
[   64.601821]  rtnetlink_rcv+0x28/0x30
[   64.601823]  netlink_unicast+0x422/0x610
[   64.601824]  ? netlink_attachskb+0x650/0x650
[   64.601826]  netlink_sendmsg+0x7b7/0xb60
[   64.601828]  ? netlink_unicast+0x610/0x610
[   64.601830]  ? netlink_unicast+0x610/0x610
[   64.601832]  sock_sendmsg+0xba/0xf0
[   64.601834]  ___sys_sendmsg+0x6a9/0x8c0
[   64.601835]  ? copy_msghdr_from_user+0x520/0x520
[   64.601837]  ? __alloc_pages_nodemask+0x160/0x520
[   64.601839]  ? memcg_write_event_control+0xd60/0xd60
[   64.601841]  ? __alloc_pages_slowpath+0x1d50/0x1d50
[   64.601843]  ? kasan_slab_free+0x71/0xc0
[   64.601845]  ? mem_cgroup_commit_charge+0xb2/0x11d0
[   64.601847]  ? lru_cache_add_active_or_unevictable+0x7d/0x1a0
[   64.601849]  ? __handle_mm_fault+0x1af8/0x2810
[   64.601851]  ? may_open_dev+0xc0/0xc0
[   64.601852]  ? __pmd_alloc+0x2c0/0x2c0
[   64.601853]  ? __fdget+0x13/0x20
[   64.601855]  __sys_sendmsg+0xc6/0x150
[   64.601856]  ? __sys_sendmsg+0xc6/0x150
[   64.601857]  ? SyS_shutdown+0x170/0x170
[   64.601859]  ? handle_mm_fault+0x28a/0x650
[   64.601861]  SyS_sendmsg+0x12/0x20
[   64.601863]  entry_SYSCALL_64_fastpath+0x13/0x94
[   64.601864] RIP: 0033:0x7ff5a29b6080
[   64.601865] RSP: 002b:00007ffcdc707e08 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
[   64.601867] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007ff5a29b6080
[   64.601867] RDX: 0000000000000000 RSI: 00007ffcdc707e58 RDI: 0000000000000003
[   64.601868] RBP: 00007ffcdc70fec0 R08: 0000000000000001 R09: 0000000000000000
[   64.601869] R10: 00007ffcdc711eb7 R11: 0000000000000246 R12: 0000000000456000
[   64.601870] R13: 00007ffcdc7108b0 R14: 0000000000000000 R15: 0000000000000001
[   64.601871] Code: 16 75 33 85 d2 0f 94 c0 48 83 c4 08 5b 5d c3 80 3d 7d 5b 84 01 00 75 15 48 c7 c7 60 8e 57 a4 c6 05 6d 5b 84 01 01 e8 bb e2 99 ff <0f> ff 31 c0 48 83 c4 08 5b 5d c3 83 f8 ff 75 b3 31 c0 eb f0 48 
