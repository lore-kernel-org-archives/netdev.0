From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [CRIU] BUG: Dentry ffff9f795a08fe60{i=af565f, n=lo} still in use
 (1) [unmount of proc proc]
Date: Fri, 30 Jun 2017 12:11:07 -0700
Message-ID: <20170630191106.GB8899@outlook.office365.com>
References: <CANaxB-yneyRrUhJp1uwvHcaC88n3yyF5Jjr=1A869hWQsXfNEg@mail.gmail.com>
 <8737ai4ns6.fsf@xmission.com>
 <CANaxB-z-K=A2_OfMsXqROttsef0SXSeACX8Wj9ik2NJ1Dkz_Fw@mail.gmail.com>
 <87vane1cao.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andrei Vagin <avagin@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "criu@openvz.org" <criu@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87vane1cao.fsf@xmission.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 29, 2017 at 08:42:23PM -0500, Eric W. Biederman wrote:
> Andrei Vagin <avagin@gmail.com> writes:
> 
> > On Thu, Jun 29, 2017 at 12:06 PM, Eric W. Biederman
> > <ebiederm@xmission.com> wrote:
> >> Andrei Vagin <avagin@gmail.com> writes:
> >>
> >>> Hello,
> >>>
> >>> We run CRIU tests on linus' tree and today we found this issue.
> >>>
> >>> CRIU tests are the set of small programs to check checkpoint/restore
> >>> of different primitives (files, sockets, signals, pipes, etc).
> >>> https://github.com/xemul/criu/tree/master/test
> >>>
> >>> Each test is executed three times: without namespaces, in a set of all
> >>> namespaces except userns, in a set of all namespaces. When a test
> >>> passed the preparation tests, it sends a signal to an executer, and
> >>> then the executer dumps and restores tests processes, and sends a
> >>> signal to the test back to check that everything are restored
> >>> correctly.
> >>
> >> I am not certain what you are saying, and you seem to have Cc'd
> >> every list except the netdev and netfilter lists that are needed
> >> to deal with this.
> >>
> >> Are you saing that the change from Liping Zhang is needed? Or are you
> >> saying that change introduces the problem below?
> >
> > Hi Eric,
> >
> > Here I tried to explain our usecase. I don't know which changes in the
> > kernel affect this issue.
> >
> > Actually I reported about the similar problem a few month ago on the linux-next:
> > https://lkml.org/lkml/2017/3/10/1586
> >
> > So I don't think that the change from Liping Zhang affects this issue
> > somehow. I mentioned it just to describe what kernel we used.
> >
> > And I don't know how to reproduce the issue. You can see from the
> > kernel log, that the kernel worked for more than 6 hours in out case.
> > During this perioud we run all our tests a few times, so I think there
> > is a kind of race.
> >
> >>
> >> I could not find the mentioned commits.  Are the in Linus's tree or
> >> someone's next tree that feeds into linux-next?
> >
> > Here is the patch from Liping Zhang
> > https://patchwork.ozlabs.org/patch/770887/
> >
> > The second mentioned commit is HEAD of the master branch in Linus' tree:
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=6474924e2b5ddb0030c355558966adcbe3b49022
> 
> Apologies I somehow thought that g in the kernel version you mentioned
> was part of the commit id and thus I could not find it.  Sigh.
> 
> Ok so with Linus's tree and that one extra patch from Liping Zhang you
> have kernel problems sometimes.
> 
> The warning and the oops combined are quite suggestive of what is going
> on.  It does sound like while the pid namespace is being unregistered
> something under /proc/sys/net/ipv4/conf/<if>/... is being accessed
> and keeping the inode busy.
> 
> Which then leads to an oops when the network namespace is being cleaned
> up later, as it tries to purge all of the inodes.
> 
> Which raises the question how in the world can the count of the
> superblock drop to zero with an inode in use.
> 
> As devinet is where things go strange this does seem completely
> independent of what Liping Zhang was looking at.
> 
> This does smell like a bug in the generic code.  Hmm.
> 
> Is this consistently reproducible when you run your tests...

I'm not sure about that. I'm going to do some experiments to understand
how often it is reproduced on our test system, and then will try to
revert the patch from Konstantin.

Thanks!

> 
> I think the following change where it uses igrab has the possibility
> of increasing the inode count while a pid namespace is being shut down.
> So it is worth a good hard look and fixes and possibly a revert if we
> can prove that this is the issue.
> 
> commit d6cffbbe9a7e51eb705182965a189457c17ba8a3
> Author: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Date:   Fri Feb 10 10:35:02 2017 +0300
> 
>     proc/sysctl: prune stale dentries during unregistering
> 
> Eric
> 
> 
> > Thanks,
> > Andrei
> >
> >>
> >> Eric
> >>
> >>> [root@zdtm linux]# git describe HEAD~1
> >>> v4.12-rc7-25-g6474924
> >>>
> >>> And there is one more patch from the netfilter tree:
> >>> commit b216759c0cb5d37d1eec3cd5b67ba38bace94fd8
> >>> Author: Liping Zhang
> >>> Date:   Sun Jun 4 19:17:34 2017 +0800
> >>>
> >>>     netfilter: nf_ct_dccp/sctp: fix memory leak after netns cleanup
> >>>
> >>> [root@zdtm linux]# uname -a
> >>> Linux zdtm.openvz.org 4.12.0-rc7+ #9 SMP Thu Jun 29 08:28:18 CEST 2017
> >>> x86_64 x86_64 x86_64 GNU/Linux
> >>>
> >>> A kernel config is attached.
> >>>
> >>>
> >>> [22458.504137] BUG: Dentry ffff9f795a08fe60{i=af565f,n=lo}  still in
> >>> use (1) [unmount of proc proc]
> >>> [22458.505117] ------------[ cut here ]------------
> >>> [22458.505299] WARNING: CPU: 0 PID: 15036 at fs/dcache.c:1445
> >>> umount_check+0x66/0x80
> >>> [22458.505564] Modules linked in: nfsd auth_rpcgss nfs_acl lockd grace
> >>> sunrpc macvlan tun veth nf_conntrack_netlink xt_mark udp_diag tcp_diag
> >>> inet_diag netlink_diag af_packet_diag unix_diag binfmt_misc
> >>> ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink
> >>> ebtable_broute bridge stp llc ebtable_nat ip6table_security
> >>> ip6table_mangle ip6table_raw ip6table_nat nf_conntrack_ipv6
> >>> nf_defrag_ipv6 nf_nat_ipv6 iptable_security iptable_mangle iptable_raw
> >>> iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
> >>> nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables btrfs
> >>> xor raid6_pq loop ppdev crct10dif_pclmul crc32_pclmul
> >>> ghash_clmulni_intel lpc_ich sbs virtio_balloon shpchp sbshc parport_pc
> >>> parport tpm_tis tpm_tis_core tpm xfs libcrc32c crc32c_intel
> >>> ata_generic serio_raw pata_acpi
> >>> [22458.507586]  virtio_pci virtio virtio_ring e1000
> >>> [22458.507771] CPU: 0 PID: 15036 Comm: kworker/0:2 Not tainted 4.12.0-rc7+ #9
> >>> [22458.507830] systemd-journald[561]: Compressed data object 807 ->
> >>> 605 using LZ4
> >>> [22458.508184] Hardware name: Parallels Software International Inc.
> >>> Parallels Virtual Platform/Parallels Virtual Platform, BIOS
> >>> 6.12.26068.1232434 02/27/2017
> >>> [22458.508641] Workqueue: events proc_cleanup_work
> >>> [22458.508848] task: ffff9f797be80000 task.stack: ffffb2b8825f0000
> >>> [22458.509033] RIP: 0010:umount_check+0x66/0x80
> >>> [22458.509172] RSP: 0018:ffffb2b8825f3c68 EFLAGS: 00010286
> >>> [22458.509363] RAX: 0000000000000054 RBX: ffff9f798492afa0 RCX: 0000000000000000
> >>> [22458.509589] RDX: 0000000000000000 RSI: ffff9f79bce0e388 RDI: ffff9f79bce0e388
> >>> [22458.509823] RBP: ffffb2b8825f3c70 R08: 0000000000000000 R09: 0000000000000000
> >>> [22458.510022] R10: ffffb2b8825f3bf0 R11: 0000000000000000 R12: ffff9f795a08fe60
> >>> [22458.510217] R13: ffff9f795a08ff50 R14: ffff9f795a08fee0 R15: ffff9f798492afa0
> >>> [22458.510456] FS:  0000000000000000(0000) GS:ffff9f79bce00000(0000)
> >>> knlGS:0000000000000000
> >>> [22458.510726] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>> [22458.510953] CR2: 00007f834657a6b0 CR3: 00000000602a3000 CR4: 00000000000006f0
> >>> [22458.511163] Call Trace:
> >>> [22458.511289]  d_walk+0x144/0x510
> >>> [22458.511442]  ? detach_and_collect+0x30/0x30
> >>> [22458.511620]  do_one_tree+0x26/0x40
> >>> [22458.511793]  shrink_dcache_for_umount+0x2d/0x90
> >>> [22458.511954]  generic_shutdown_super+0x1f/0x120
> >>> [22458.512105]  kill_anon_super+0x12/0x20
> >>> [22458.512243]  proc_kill_sb+0x40/0x50
> >>> [22458.512406]  deactivate_locked_super+0x43/0x70
> >>> [22458.512576]  deactivate_super+0x4e/0x60
> >>> [22458.512731]  cleanup_mnt+0x3f/0x80
> >>> [22458.512890]  mntput_no_expire+0x2fc/0x3b0
> >>> [22458.513028]  kern_unmount+0x3e/0x50
> >>> [22458.513153]  pid_ns_release_proc+0x15/0x20
> >>> [22458.513309]  proc_cleanup_work+0x15/0x20
> >>> [22458.513469]  process_one_work+0x205/0x5d0
> >>> [22458.513635]  worker_thread+0x4e/0x3a0
> >>> [22458.513809]  kthread+0x109/0x140
> >>> [22458.513929]  ? process_one_work+0x5d0/0x5d0
> >>> [22458.514067]  ? kthread_create_on_node+0x70/0x70
> >>> [22458.514217]  ? prepare_exit_to_usermode+0x7e/0x80
> >>> [22458.514400]  ret_from_fork+0x2a/0x40
> >>> [22458.514550] Code: 48 8d 88 50 06 00 00 48 8b 40 28 4c 8b 08 48 8b
> >>> 46 58 48 85 c0 74 1b 48 8b 50 40 51 48 c7 c7 60 f9 c9 95 48 89 f1 e8
> >>> 99 39 f3 ff <0f> ff 58 31 c0 c9 c3 31 d2 eb e5 0f 1f 44 00 00 66 2e 0f
> >>> 1f 84
> >>> [22458.515141] ---[ end trace b37db95b00f941ab ]---
> >>> [22458.519368] VFS: Busy inodes after unmount of proc. Self-destruct
> >>> in 5 seconds.  Have a nice day...
> >>> [22458.813846] BUG: unable to handle kernel NULL pointer dereference
> >>> at 0000000000000018
> >>> [22458.814081] IP: __lock_acquire+0x127/0x12f0
> >>> [22458.814213] PGD 5ce4e067
> >>> [22458.814213] P4D 5ce4e067
> >>> [22458.814340] PUD 5ce4f067
> >>> [22458.814450] PMD 0
> >>>
> >>> [22458.814724] Oops: 0000 [#1] SMP
> >>> [22458.814844] Modules linked in: nfsd auth_rpcgss nfs_acl lockd grace
> >>> sunrpc macvlan tun veth nf_conntrack_netlink xt_mark udp_diag tcp_diag
> >>> inet_diag netlink_diag af_packet_diag unix_diag binfmt_misc
> >>> ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink
> >>> ebtable_broute bridge stp llc ebtable_nat ip6table_security
> >>> ip6table_mangle ip6table_raw ip6table_nat nf_conntrack_ipv6
> >>> nf_defrag_ipv6 nf_nat_ipv6 iptable_security iptable_mangle iptable_raw
> >>> iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
> >>> nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables btrfs
> >>> xor raid6_pq loop ppdev crct10dif_pclmul crc32_pclmul
> >>> ghash_clmulni_intel lpc_ich sbs virtio_balloon shpchp sbshc parport_pc
> >>> parport tpm_tis tpm_tis_core tpm xfs libcrc32c crc32c_intel
> >>> ata_generic serio_raw pata_acpi
> >>> [22458.816586]  virtio_pci virtio virtio_ring e1000
> >>> [22458.816741] CPU: 0 PID: 31415 Comm: kworker/u64:3 Tainted: G
> >>> W       4.12.0-rc7+ #9
> >>> [22458.816972] Hardware name: Parallels Software International Inc.
> >>> Parallels Virtual Platform/Parallels Virtual Platform, BIOS
> >>> 6.12.26068.1232434 02/27/2017
> >>> [22458.817355] Workqueue: netns cleanup_net
> >>> [22458.817500] task: ffff9f799f278000 task.stack: ffffb2b882934000
> >>> [22458.817676] RIP: 0010:__lock_acquire+0x127/0x12f0
> >>> [22458.817826] RSP: 0018:ffffb2b882937950 EFLAGS: 00010002
> >>> [22458.817995] RAX: 0000000000000046 RBX: 0000000000000000 RCX: 0000000000000000
> >>> [22458.818192] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 0000000000000018
> >>> [22458.818422] RBP: ffffb2b882937a10 R08: ffffffff95237bca R09: 0000000000000000
> >>> [22458.818637] R10: 0000000000000000 R11: ffff9f799f278000 R12: 0000000000000001
> >>> [22458.818846] R13: 0000000000000000 R14: 0000000000000001 R15: 0000000000000018
> >>> [22458.819046] FS:  0000000000000000(0000) GS:ffff9f79bce00000(0000)
> >>> knlGS:0000000000000000
> >>> [22458.819264] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>> [22458.819468] CR2: 0000000000000018 CR3: 000000003f0cd000 CR4: 00000000000006f0
> >>> [22458.819669] Call Trace:
> >>> [22458.819784]  ? __lock_acquire+0x39e/0x12f0
> >>> [22458.819919]  lock_acquire+0xd5/0x1c0
> >>> [22458.820043]  ? lock_acquire+0xd5/0x1c0
> >>> [22458.820174]  ? list_lru_del+0x5a/0x170
> >>> [22458.820331]  _raw_spin_lock+0x28/0x40
> >>> [22458.820475]  ? list_lru_del+0x5a/0x170
> >>> [22458.820611]  list_lru_del+0x5a/0x170
> >>> [22458.820748]  d_lru_del+0x44/0x60
> >>> [22458.820870]  __dentry_kill+0x149/0x180
> >>> [22458.820998]  d_prune_aliases+0x5e/0x200
> >>> [22458.821130]  drop_sysctl_table+0x135/0x310
> >>> [22458.821270]  ? trace_hardirqs_on_caller+0xf5/0x190
> >>> [22458.821454]  ? trace_hardirqs_on+0xd/0x10
> >>> [22458.821597]  drop_sysctl_table+0x212/0x310
> >>> [22458.821741]  ? trace_hardirqs_on_caller+0xf5/0x190
> >>> [22458.821898]  ? trace_hardirqs_on+0xd/0x10
> >>> [22458.822034]  drop_sysctl_table+0x212/0x310
> >>> [22458.822172]  ? unregister_sysctl_table+0x36/0x80
> >>> [22458.822343]  unregister_sysctl_table+0x3e/0x80
> >>> [22458.822507]  unregister_net_sysctl_table+0xe/0x10
> >>> [22458.822664]  __devinet_sysctl_unregister.isra.25+0x2b/0x50
> >>> [22458.822847]  devinet_exit_net+0x47/0x70
> >>> [22458.822976]  ops_exit_list.isra.4+0x38/0x60
> >>> [22458.823116]  cleanup_net+0x1ee/0x2f0
> >>> [22458.823243]  process_one_work+0x205/0x5d0
> >>> [22458.823405]  worker_thread+0x4e/0x3a0
> >>> [22458.823549]  kthread+0x109/0x140
> >>> [22458.823667]  ? process_one_work+0x5d0/0x5d0
> >>> [22458.823819]  ? kthread_create_on_node+0x70/0x70
> >>> [22458.823976]  ret_from_fork+0x2a/0x40
> >>> [22458.824101] Code: c8 65 48 33 3c 25 28 00 00 00 44 89 f0 0f 85 2b
> >>> 0d 00 00 48 81 c4 90 00 00 00 5b 41 5a 41 5c 41 5d 41 5e 41 5f 5d 49
> >>> 8d 62 f8 c3 <49> 81 3f e0 38 44 96 41 bc 00 00 00 00 44 0f 45 e2 83 fe
> >>> 01 0f
> >>> [22458.824634] RIP: __lock_acquire+0x127/0x12f0 RSP: ffffb2b882937950
> >>> [22458.824821] CR2: 0000000000000018
> >>> [22458.824943] ---[ end trace b37db95b00f941ac ]---
> _______________________________________________
> CRIU mailing list
> CRIU@openvz.org
> https://lists.openvz.org/mailman/listinfo/criu
