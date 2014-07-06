From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [ipv6] BUG kmalloc-512 (Not tainted): Object padding overwritten
Date: Sun, 6 Jul 2014 10:56:06 +0800
Message-ID: <20140706025606.GB7349@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="wq9mPyueHGvFACwf"
Cc: Jet Chen <jet.chen@intel.com>, Su Tao <tao.su@intel.com>,
	Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Eric,

This is an old bug and not very reproducible, however is still showing
up in current upstream and linux-next.

git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit efe4208f47f907b86f528788da711e8ab9dea44d
Author:     Eric Dumazet <edumazet@google.com>
AuthorDate: Thu Oct 3 15:42:29 2013 -0700
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Wed Oct 9 00:01:25 2013 -0400

    ipv6: make lookups simpler and faster
    
    TCP listener refactoring, part 4 :
    
    To speed up inet lookups, we moved IPv4 addresses from inet to struct
    sock_common
    
    Now is time to do the same for IPv6, because it permits us to have fast
    lookups for all kind of sockets, including upcoming SYN_RECV.
    
    Getting IPv6 addresses in TCP lookups currently requires two extra cache
    lines, plus a dereference (and memory stall).
    
    inet6_sk(sk) does the dereference of inet_sk(__sk)->pinet6
    
    This patch is way bigger than its IPv4 counter part, because for IPv4,
    we could add aliases (inet_daddr, inet_rcv_saddr), while on IPv6,
    it's not doable easily.
    
    inet6_sk(sk)->daddr becomes sk->sk_v6_daddr
    inet6_sk(sk)->rcv_saddr becomes sk->sk_v6_rcv_saddr
    
    And timewait socket also have tw->tw_v6_daddr & tw->tw_v6_rcv_saddr
    at the same offset.
    
    We get rid of INET6_TW_MATCH() as INET6_MATCH() is now the generic
    macro.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

+-----------------------------------------------------+------------+------------+---------------+
|                                                     | 05dbc7b594 | efe4208f47 | next-20140701 |
+-----------------------------------------------------+------------+------------+---------------+
| boot_successes                                      | 738        | 238        | 38            |
| boot_failures                                       | 0          | 8          | 3             |
| BUG_kmalloc(Not_tainted):Object_padding_overwritten | 0          | 6          | 3             |
| INFO:.First_byte_instead_of                         | 0          | 7          | 3             |
| INFO:Allocated_in_sk_prot_alloc_age=cpu=pid=        | 0          | 7          | 3             |
| INFO:Freed_in__sk_free_age=cpu=pid=                 | 0          | 1          |               |
| INFO:Slab_objects=used=fp=flags=                    | 0          | 7          | 3             |
| INFO:Object_offset=fp=                              | 0          | 7          | 3             |
| BUG_kmalloc(Tainted:G_B):Object_padding_overwritten | 0          | 3          | 2             |
| INFO:Slab_objects=used=fp=x(null)flags=             | 0          | 4          | 1             |
| BUG_kmalloc(Tainted:G_B):Poison_overwritten         | 0          | 1          | 1             |
| BUG_kmalloc(Not_tainted):Padding_overwritten        | 0          | 1          |               |
| BUG:unable_to_handle_kernel_paging_request          | 0          | 1          |               |
| Oops                                                | 0          | 1          |               |
| EIP_is_at_pppol2tp_release                          | 0          | 1          |               |
| backtrace:do_group_exit                             | 0          | 1          |               |
| backtrace:SyS_exit_group                            | 0          | 1          |               |
| BUG_kmalloc(Not_tainted):Poison_overwritten         | 0          | 1          |               |
| INFO:Freed_in_load_elf_binary_age=cpu=pid=          | 0          | 0          | 1             |
+-----------------------------------------------------+------------+------------+---------------+

[    8.987192] init: Failed to create pty - disabling logging for job
[    8.991691] init: Failed to create pty - disabling logging for job
[   19.686410] =============================================================================
[   19.687007] BUG kmalloc-512 (Not tainted): Object padding overwritten
[   19.687007] -----------------------------------------------------------------------------
[   19.687007] 
[   19.687007] INFO: 0xd34113a8-0xd34113ab. First byte 0x1 instead of 0x5a
[   19.687007] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=606 cpu=0 pid=293
[   19.687007] INFO: Slab 0xd2793200 objects=14 used=3 fp=0xd3410af0 flags=0x40004080
[   19.687007] INFO: Object 0xd3411180 @offset=4480 fp=0xd3410f50
[   19.687007] 
[   19.687007] Bytes b4 d3411170: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[   19.687007] Object d3411180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

git bisect start v3.13 v3.12 --
git bisect  bad 3bad8bb5cd3048a67df43ac6b1e2f191f19d9ff0  # 08:18     11-      1  Merge branch 'for-next' of git://git.samba.org/sfrench/cifs-2.6
git bisect  bad 049ffa8ab33a63b3bff672d1a0ee6a35ad253fe8  # 09:26      1-      1  Merge branch 'drm-next' of git://people.freedesktop.org/~airlied/linux
git bisect good 7e238a2ecd117e16b154e1b0ed77906596600ff5  # 10:21    246+     11  Merge tag 'hwmon-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/groeck/linux-staging
git bisect good a30124539b2641c5b3551193af7d21a6fc61ba98  # 20:35    246+     10  Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs
git bisect  bad 42a2d923cc349583ebf6fdd52a7d35e1c2f7e6bd  # 22:11      0-      2  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect good 39222c82f738190a4f09be89510a8336a73b67c8  # 22:44    246+     14  Merge tag 'upstream-3.13-rc1' of git://git.infradead.org/linux-ubi
git bisect good 9bc9ccd7db1c9f043f75380b5a5b94912046a60e  # 22:59    246+      3  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
git bisect good 5cbb3d216e2041700231bcfc383ee5f8b7fc8b74  # 23:28    246+     11  Merge branch 'akpm' (patches from Andrew Morton)
git bisect  bad 7f8cbb23f598a07f9de7ca66ab86d772f08876b3  # 23:54     25-      2  net: stmmac: remove unnecessary pci_set_drvdata()
git bisect good d41200ad5fc6c283c8c375f52e4f8699c0eeec61  # 00:07    246+     34  rtlwifi: rtl8188ee: Convert driver to use new rtl_phy_scan_operation_backup() routine
git bisect good e1af5e445ef8582e8f690fadcd63797db1e62663  # 00:15    246+      0  cgroup: netprio: remove unnecessary task_netprioidx
git bisect  bad 5cda73b68ebf7e08586d61e6777e64e12df23f07  # 00:41     17-      1  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next
git bisect  bad da33edccebcc36d387423dcdb557094fbda55994  # 00:46      0-      1  Merge branch 'net-next' of git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables
git bisect  bad 29b67c39dc6e7ec4fdf78c620675de761971cd28  # 00:50      0-      1  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge
git bisect  bad 18c68d5960c8dfeb2db113f4b871bab259cfd565  # 00:55      0-      1  batman-adv: reorder batadv_iv_flags
git bisect  bad 414254e342a0d58144de40c3da777521ebaeeb07  # 01:02      0-      3  batman-adv: tvlv - gateway download/upload bandwidth container
git bisect  bad f69b923a758f598fd6bb69e57564b59506f4f1fc  # 01:42      1-      4  udp: fix a typo in __udp4_lib_mcast_demux_lookup
git bisect good 53af53ae83fe960ceb9ef74cac7915e9088f4266  # 02:14    246+      0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect good 05dbc7b59481ca891bbcfe6799a562d48159fbf7  # 02:28    246+      0  tcp/dccp: remove twchain
git bisect  bad efe4208f47f907b86f528788da711e8ab9dea44d  # 02:36      0-      2  ipv6: make lookups simpler and faster
# first bad commit: [efe4208f47f907b86f528788da711e8ab9dea44d] ipv6: make lookups simpler and faster
git bisect good 05dbc7b59481ca891bbcfe6799a562d48159fbf7  # 02:42    738+      0  tcp/dccp: remove twchain
git bisect  bad bbb74586d1d776b6c61ef04a2d669f2e47703ccd  # 02:44      0-      3  Add linux-next specific files for 20140701
git bisect  bad 77c4cf17ae867ba93233b3832bda3de7adaae326  # 03:51     19-      5  Merge tag 'md/3.16-fixes' of git://neil.brown.name/md
git bisect  bad bb62c798798659624c53e3727bbc18cf47eb7ae8  # 03:57      0-      1  Add linux-next specific files for 20140704


This script may reproduce the error.

-----------------------------------------------------------------------------
#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64 -cpu kvm64 -enable-kvm 
	-kernel $kernel
	-smp 2
	-m 256M
	-net nic,vlan=0,macaddr=00:00:00:00:00:00,model=virtio
	-net user,vlan=0
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-serial stdio
	-display none
	-monitor null
)

append=(
	debug
	sched_debug
	apic=debug
	ignore_loglevel
	sysrq_always_enabled
	panic=10
	prompt_ramdisk=0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
)

"${kvm[@]}" --append "${append[*]}"
-----------------------------------------------------------------------------

Here are the list of oops messages in each dmesg file:

dmesg-quantal-ivb41-115:20140706023546:i386-randconfig-x0-07021302::

[    8.462349] init: Failed to create pty - disabling logging for job
Kernel tests: Boot OK!
[   18.819897] =============================================================================
[   18.820006] BUG kmalloc-512 (Not tainted): Object padding overwritten
[   18.820006] -----------------------------------------------------------------------------
[   18.820006] 
[   18.820006] INFO: 0xc0aae688-0xc0aae68b. First byte 0x1 instead of 0x5a
[   18.820006] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=247 cpu=0 pid=293
[   18.820006] INFO: Freed in __sk_free+0xf5/0x100 age=479 cpu=0 pid=290
[   18.820006] INFO: Slab 0xd25405c0 objects=14 used=6 fp=0xc0aaf5e0 flags=0x4080
[   18.820006] INFO: Object 0xc0aae460 @offset=1120 fp=0xc0aaf180
[   18.820006] 
[   18.820006] Bytes b4 c0aae450: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[   18.820006] Object c0aae460: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae470: 18 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae480: 60 c2 d4 c1 e0 20 d4 c1 00 00 00 00 00 00 00 00  `.... ..........
[   18.820006] Object c0aae490: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae4a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae4b0: ff ff ff ff 00 00 00 00 00 00 00 00 bc e4 aa c0  ................
[   18.820006] Object c0aae4c0: bc e4 aa c0 c4 e4 aa c0 c4 e4 aa c0 00 00 00 00  ................
[   18.820006] Object c0aae4d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae4e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae4f0: 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae500: 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae510: 00 00 00 00 00 00 00 00 00 80 02 00 1c e5 aa c0  ................
[   18.820006] Object c0aae520: 1c e5 aa c0 00 00 00 00 00 01 01 00 00 00 00 00  ................
[   18.820006] Object c0aae530: d0 00 00 00 ff ff ff ff ff ff ff ff 00 00 00 00  ................
[   18.820006] Object c0aae540: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae550: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae560: 60 e5 aa c0 60 e5 aa c0 00 00 00 00 60 c2 d4 c1  `...`.......`...
[   18.820006] Object c0aae570: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae580: 00 00 00 00 00 00 00 00 ff ff ff 7f ff ff ff 7f  ................
[   18.820006] Object c0aae590: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae5a0: 80 1e df c1 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   18.820006] Object c0aae5b0: 00 36 65 c4 ff ff ff ff 00 00 00 00 00 00 00 00  .6e.............
[   18.820006] Object c0aae5c0: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   18.820006] Object c0aae5d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae5e0: 90 99 7a c1 60 9a 7a c1 d0 99 7a c1 20 99 7a c1  ..z.`.z...z. .z.
[   18.820006] Object c0aae5f0: b0 3c 8f c1 50 47 8f c1 00 00 00 00 00 00 00 00  .<..PG..........
[   18.820006] Object c0aae600: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae610: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae620: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae630: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae640: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Object c0aae650: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.820006] Redzone c0aae660: cc cc cc cc                                      ....
[   18.820006] Padding c0aae688: 01 00 00 00 5a 5a 5a 5a                          ....ZZZZ
[   18.820006] FIX kmalloc-512: Restoring 0xc0aae688-0xc0aae68b=0x5a
[   18.820006] 

dmesg-quantal-ivb41-119:20140706023802:i386-randconfig-x0-07021302::

[    8.833260] init: Failed to create pty - disabling logging for job
Kernel tests: Boot OK!
[   19.175288] =============================================================================
[   19.176005] BUG kmalloc-512 (Not tainted): Object padding overwritten
[   19.176005] -----------------------------------------------------------------------------
[   19.176005] 
[   19.176005] INFO: 0xd3411e98-0xd3411e9b. First byte 0x1 instead of 0x5a
[   19.176005] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=223 cpu=0 pid=293
[   19.176005] INFO: Slab 0xd2793200 objects=14 used=13 fp=0xd3410000 flags=0x40004080
[   19.176005] INFO: Object 0xd3411c70 @offset=7280 fp=0xd3411a40
[   19.176005] 
[   19.176005] Bytes b4 d3411c60: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[   19.176005] Object d3411c70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411c80: 18 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411c90: 60 c2 d4 c1 e0 20 d4 c1 00 00 00 00 00 00 00 00  `.... ..........
[   19.176005] Object d3411ca0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411cb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411cc0: ff ff ff ff 00 00 00 00 00 00 00 00 cc 1c 41 d3  ..............A.
[   19.176005] Object d3411cd0: cc 1c 41 d3 d4 1c 41 d3 d4 1c 41 d3 00 00 00 00  ..A...A...A.....
[   19.176005] Object d3411ce0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411cf0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411d00: 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411d10: 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411d20: 00 00 00 00 00 00 00 00 00 80 02 00 2c 1d 41 d3  ............,.A.
[   19.176005] Object d3411d30: 2c 1d 41 d3 00 00 00 00 00 01 01 00 00 00 00 00  ,.A.............
[   19.176005] Object d3411d40: d0 00 00 00 ff ff ff ff ff ff ff ff 00 00 00 00  ................
[   19.176005] Object d3411d50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411d60: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411d70: 70 1d 41 d3 70 1d 41 d3 00 00 00 00 60 c2 d4 c1  p.A.p.A.....`...
[   19.176005] Object d3411d80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411d90: 00 00 00 00 00 00 00 00 ff ff ff 7f ff ff ff 7f  ................
[   19.176005] Object d3411da0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411db0: 80 1e df c1 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.176005] Object d3411dc0: 00 36 65 c4 ff ff ff ff 00 00 00 00 00 00 00 00  .6e.............
[   19.176005] Object d3411dd0: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.176005] Object d3411de0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411df0: 90 99 7a c1 60 9a 7a c1 d0 99 7a c1 20 99 7a c1  ..z.`.z...z. .z.
[   19.176005] Object d3411e00: b0 3c 8f c1 50 47 8f c1 00 00 00 00 00 00 00 00  .<..PG..........
[   19.176005] Object d3411e10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411e20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411e30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411e40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411e50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Object d3411e60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.176005] Redzone d3411e70: cc cc cc cc                                      ....
[   19.176005] Padding d3411e98: 01 00 00 00 5a 5a 5a 5a                          ....ZZZZ
[   19.176005] FIX kmalloc-512: Restoring 0xd3411e98-0xd3411e9b=0x5a
[   19.176005] 

dmesg-quantal-ivb41-14:20140706023641:i386-randconfig-x0-07021302::

[    8.316415] init: Failed to create pty - disabling logging for job
Kernel tests: Boot OK!
[   19.335829] =============================================================================
[   19.336007] BUG kmalloc-512 (Not tainted): Object padding overwritten
[   19.336007] -----------------------------------------------------------------------------
[   19.336007] 
[   19.336007] INFO: 0xd3be7a38-0xd3be7a3b. First byte 0x1 instead of 0x5a
[   19.336007] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=1211 cpu=0 pid=290
[   19.336007] INFO: Slab 0xd27a2cc0 objects=14 used=9 fp=0xd3be6460 flags=0x40004080
[   19.336007] INFO: Object 0xd3be7810 @offset=6160 fp=0xd3be75e0
[   19.336007] 
[   19.336007] Bytes b4 d3be7800: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[   19.336007] Object d3be7810: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7820: 18 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7830: 60 c2 d4 c1 e0 20 d4 c1 00 00 00 00 00 00 00 00  `.... ..........
[   19.336007] Object d3be7840: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7850: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7860: ff ff ff ff 00 00 00 00 00 00 00 00 6c 78 be d3  ............lx..
[   19.336007] Object d3be7870: 6c 78 be d3 74 78 be d3 74 78 be d3 00 00 00 00  lx..tx..tx......
[   19.336007] Object d3be7880: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7890: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be78a0: 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be78b0: 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be78c0: 00 00 00 00 00 00 00 00 00 80 02 00 cc 78 be d3  .............x..
[   19.336007] Object d3be78d0: cc 78 be d3 00 00 00 00 00 01 01 00 00 00 00 00  .x..............
[   19.336007] Object d3be78e0: d0 00 00 00 ff ff ff ff ff ff ff ff 00 00 00 00  ................
[   19.336007] Object d3be78f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7900: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7910: 10 79 be d3 10 79 be d3 00 00 00 00 60 c2 d4 c1  .y...y......`...
[   19.336007] Object d3be7920: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7930: 00 00 00 00 00 00 00 00 ff ff ff 7f ff ff ff 7f  ................
[   19.336007] Object d3be7940: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7950: 80 1e df c1 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.336007] Object d3be7960: 00 36 65 c4 ff ff ff ff 00 00 00 00 00 00 00 00  .6e.............
[   19.336007] Object d3be7970: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.336007] Object d3be7980: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7990: 90 99 7a c1 60 9a 7a c1 d0 99 7a c1 20 99 7a c1  ..z.`.z...z. .z.
[   19.336007] Object d3be79a0: b0 3c 8f c1 50 47 8f c1 00 00 00 00 00 00 00 00  .<..PG..........
[   19.336007] Object d3be79b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be79c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be79d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be79e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be79f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Object d3be7a00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.336007] Redzone d3be7a10: cc cc cc cc                                      ....
[   19.336007] Padding d3be7a38: 01 00 00 00 5a 5a 5a 5a                          ....ZZZZ
[   19.336007] FIX kmalloc-512: Restoring 0xd3be7a38-0xd3be7a3b=0x5a
[   19.336007] 
[   19.672316] =============================================================================
[   19.673007] BUG kmalloc-512 (Tainted: G    B       ): Object padding overwritten
[   19.673007] -----------------------------------------------------------------------------
[   19.673007] 
[   19.673007] INFO: 0xd2ce2228-0xd2ce222b. First byte 0x1 instead of 0x5a
[   19.673007] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=1201 cpu=0 pid=294
[   19.673007] INFO: Slab 0xd2784c40 objects=14 used=14 fp=0x  (null) flags=0x40004080
[   19.673007] INFO: Object 0xd2ce2000 @offset=0 fp=0xd2ce2230
[   19.673007] 
[   19.673007] Object d2ce2000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2010: 18 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2020: 60 c2 d4 c1 e0 20 d4 c1 00 00 00 00 00 00 00 00  `.... ..........
[   19.673007] Object d2ce2030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2050: ff ff ff ff 00 00 00 00 00 00 00 00 5c 20 ce d2  ............\ ..
[   19.673007] Object d2ce2060: 5c 20 ce d2 64 20 ce d2 64 20 ce d2 00 00 00 00  \ ..d ..d ......
[   19.673007] Object d2ce2070: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2090: 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce20a0: 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce20b0: 00 00 00 00 00 00 00 00 00 80 02 00 bc 20 ce d2  ............. ..
[   19.673007] Object d2ce20c0: bc 20 ce d2 00 00 00 00 00 01 01 00 00 00 00 00  . ..............
[   19.673007] Object d2ce20d0: d0 00 00 00 ff ff ff ff ff ff ff ff 00 00 00 00  ................
[   19.673007] Object d2ce20e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce20f0: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2100: 00 21 ce d2 00 21 ce d2 00 00 00 00 60 c2 d4 c1  .!...!......`...
[   19.673007] Object d2ce2110: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2120: 00 00 00 00 00 00 00 00 ff ff ff 7f ff ff ff 7f  ................
[   19.673007] Object d2ce2130: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2140: 80 1e df c1 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.673007] Object d2ce2150: 00 36 65 c4 ff ff ff ff 00 00 00 00 00 00 00 00  .6e.............
[   19.673007] Object d2ce2160: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.673007] Object d2ce2170: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce2180: 90 99 7a c1 60 9a 7a c1 d0 99 7a c1 20 99 7a c1  ..z.`.z...z. .z.
[   19.673007] Object d2ce2190: b0 3c 8f c1 50 47 8f c1 00 00 00 00 00 00 00 00  .<..PG..........
[   19.673007] Object d2ce21a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce21b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce21c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce21d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce21e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Object d2ce21f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.673007] Redzone d2ce2200: cc cc cc cc                                      ....
[   19.673007] Padding d2ce2228: 01 00 00 00 5a 5a 5a 5a                          ....ZZZZ
[   19.673007] FIX kmalloc-512: Restoring 0xd2ce2228-0xd2ce222b=0x5a
[   19.673007] 

dmesg-quantal-ivb41-24:20140706023545:i386-randconfig-x0-07021302::

[    8.739767] init: Failed to create pty - disabling logging for job
Kernel tests: Boot OK!
[   18.517408] =============================================================================
[   18.518008] BUG kmalloc-512 (Not tainted): Object padding overwritten
[   18.518008] -----------------------------------------------------------------------------
[   18.518008] 
[   18.518008] INFO: 0xd3bc6688-0xd3bc668b. First byte 0x1 instead of 0x5a
[   18.518008] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=199 cpu=0 pid=290
[   18.518008] INFO: Slab 0xd27a28c0 objects=14 used=10 fp=0xd3bc7a40 flags=0x40004080
[   18.518008] INFO: Object 0xd3bc6460 @offset=1120 fp=0xd3bc6690
[   18.518008] 
[   18.518008] Bytes b4 d3bc6450: 22 01 00 00 75 b4 fb ff 5a 5a 5a 5a 5a 5a 5a 5a  "...u...ZZZZZZZZ
[   18.518008] Object d3bc6460: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6470: 18 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6480: 60 c2 d4 c1 e0 20 d4 c1 00 00 00 00 00 00 00 00  `.... ..........
[   18.518008] Object d3bc6490: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc64a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc64b0: ff ff ff ff 00 00 00 00 00 00 00 00 bc 64 bc d3  .............d..
[   18.518008] Object d3bc64c0: bc 64 bc d3 c4 64 bc d3 c4 64 bc d3 00 00 00 00  .d...d...d......
[   18.518008] Object d3bc64d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc64e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc64f0: 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6500: 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6510: 00 00 00 00 00 00 00 00 00 80 02 00 1c 65 bc d3  .............e..
[   18.518008] Object d3bc6520: 1c 65 bc d3 00 00 00 00 00 01 01 00 00 00 00 00  .e..............
[   18.518008] Object d3bc6530: d0 00 00 00 ff ff ff ff ff ff ff ff 00 00 00 00  ................
[   18.518008] Object d3bc6540: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6550: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6560: 60 65 bc d3 60 65 bc d3 00 00 00 00 60 c2 d4 c1  `e..`e......`...
[   18.518008] Object d3bc6570: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6580: 00 00 00 00 00 00 00 00 ff ff ff 7f ff ff ff 7f  ................
[   18.518008] Object d3bc6590: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc65a0: 80 1e df c1 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   18.518008] Object d3bc65b0: 00 36 65 c4 ff ff ff ff 00 00 00 00 00 00 00 00  .6e.............
[   18.518008] Object d3bc65c0: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   18.518008] Object d3bc65d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc65e0: 90 99 7a c1 60 9a 7a c1 d0 99 7a c1 20 99 7a c1  ..z.`.z...z. .z.
[   18.518008] Object d3bc65f0: b0 3c 8f c1 50 47 8f c1 00 00 00 00 00 00 00 00  .<..PG..........
[   18.518008] Object d3bc6600: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6610: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6620: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6630: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6640: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Object d3bc6650: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.518008] Redzone d3bc6660: cc cc cc cc                                      ....
[   18.518008] Padding d3bc6688: 01 00 00 00 5a 5a 5a 5a                          ....ZZZZ
[   18.518008] FIX kmalloc-512: Restoring 0xd3bc6688-0xd3bc668b=0x5a
[   18.518008] 
[   18.884038] =============================================================================
[   18.885018] BUG kmalloc-512 (Tainted: G    B       ): Poison overwritten
[   18.885018] -----------------------------------------------------------------------------
[   18.885018] 
[   18.885018] INFO: 0xd3bc6690-0xd3bc6691. First byte 0x0 instead of 0x6b
[   18.885018] INFO: Slab 0xd27a28c0 objects=14 used=14 fp=0x  (null) flags=0x40004080
[   18.885018] INFO: Object 0xd3bc6690 @offset=1680 fp=0xd3bc68c0
[   18.885018] 
[   18.885018] Bytes b4 d3bc6680: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[   18.885018] Object d3bc6690: 00 09 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ..kkkkkkkkkkkkkk

dmesg-quantal-ivb41-70:20140706023710:i386-randconfig-x0-07021302::

[    8.687986] init: Failed to create pty - disabling logging for job
Kernel tests: Boot OK!
[   18.498055] =============================================================================
[   18.499006] BUG kmalloc-512 (Not tainted): Padding overwritten. 0xd3be5ea2-0xd3be5ea4
[   18.499006] -----------------------------------------------------------------------------
[   18.499006] 
[   18.499006] INFO: Slab 0xd27a2c80 objects=14 used=14 fp=0x  (null) flags=0x40004080
[   18.499006] Padding d3be5d45: ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00 00  ................
[   18.499006] Padding d3be5d55: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.499006] Padding d3be5d65: 00 00 00 01 00 00 00 00 00 00 00 70 5d be d3 70  ...........p]..p

dmesg-quantal-ivb42-108:20140706023649:i386-randconfig-x0-07021302::

[    8.615532] init: Failed to create pty - disabling logging for job
Kernel tests: Boot OK!
[   18.961903] =============================================================================
[   18.962006] BUG kmalloc-512 (Not tainted): Poison overwritten
[   18.962006] -----------------------------------------------------------------------------
[   18.962006] 
[   18.962006] INFO: 0xd30f6462-0xd30f6464. First byte 0xff instead of 0x6b
[   18.962006] INFO: Slab 0xd278cec0 objects=14 used=14 fp=0x  (null) flags=0x40004080
[   18.962006] INFO: Object 0xd30f6460 @offset=1120 fp=0xd30f6690
[   18.962006] 
[   18.962006] Bytes b4 d30f6450: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[   18.962006] Object d30f6460: 6b 6b ff ff 6f 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kk..okkkkkkkkkkk

dmesg-quantal-ivb42-23:20140706023624:i386-randconfig-x0-07021302::

[    8.987192] init: Failed to create pty - disabling logging for job
[    8.991691] init: Failed to create pty - disabling logging for job
[   19.686410] =============================================================================
[   19.687007] BUG kmalloc-512 (Not tainted): Object padding overwritten
[   19.687007] -----------------------------------------------------------------------------
[   19.687007] 
[   19.687007] INFO: 0xd34113a8-0xd34113ab. First byte 0x1 instead of 0x5a
[   19.687007] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=606 cpu=0 pid=293
[   19.687007] INFO: Slab 0xd2793200 objects=14 used=3 fp=0xd3410af0 flags=0x40004080
[   19.687007] INFO: Object 0xd3411180 @offset=4480 fp=0xd3410f50
[   19.687007] 
[   19.687007] Bytes b4 d3411170: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[   19.687007] Object d3411180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411190: 18 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d34111a0: 60 c2 d4 c1 e0 20 d4 c1 00 00 00 00 00 00 00 00  `.... ..........
[   19.687007] Object d34111b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d34111c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d34111d0: ff ff ff ff 00 00 00 00 00 00 00 00 dc 11 41 d3  ..............A.
[   19.687007] Object d34111e0: dc 11 41 d3 e4 11 41 d3 e4 11 41 d3 00 00 00 00  ..A...A...A.....
[   19.687007] Object d34111f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411210: 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411220: 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411230: 00 00 00 00 00 00 00 00 00 80 02 00 3c 12 41 d3  ............<.A.
[   19.687007] Object d3411240: 3c 12 41 d3 00 00 00 00 00 01 01 00 00 00 00 00  <.A.............
[   19.687007] Object d3411250: d0 00 00 00 ff ff ff ff ff ff ff ff 00 00 00 00  ................
[   19.687007] Object d3411260: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411270: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411280: 80 12 41 d3 80 12 41 d3 00 00 00 00 60 c2 d4 c1  ..A...A.....`...
[   19.687007] Object d3411290: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d34112a0: 00 00 00 00 00 00 00 00 ff ff ff 7f ff ff ff 7f  ................
[   19.687007] Object d34112b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d34112c0: 80 1e df c1 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.687007] Object d34112d0: 00 36 65 c4 ff ff ff ff 00 00 00 00 00 00 00 00  .6e.............
[   19.687007] Object d34112e0: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.687007] Object d34112f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411300: 90 99 7a c1 60 9a 7a c1 d0 99 7a c1 20 99 7a c1  ..z.`.z...z. .z.
[   19.687007] Object d3411310: b0 3c 8f c1 50 47 8f c1 00 00 00 00 00 00 00 00  .<..PG..........
[   19.687007] Object d3411320: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411330: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411340: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411350: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411360: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Object d3411370: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.687007] Redzone d3411380: cc cc cc cc                                      ....
[   19.687007] Padding d34113a8: 01 00 00 00 5a 5a 5a 5a                          ....ZZZZ
[   19.687007] FIX kmalloc-512: Restoring 0xd34113a8-0xd34113ab=0x5a
[   19.687007] 

dmesg-quantal-ivb42-93:20140706023624:i386-randconfig-x0-07021302::

[    8.801875] init: Failed to create pty - disabling logging for job
Kernel tests: Boot OK!
[   18.797552] =============================================================================
[   18.798006] BUG kmalloc-512 (Not tainted): Object padding overwritten
[   18.798006] -----------------------------------------------------------------------------
[   18.798006] 
[   18.798006] INFO: 0xd3be3c68-0xd3be3c6b. First byte 0x1 instead of 0x5a
[   18.798006] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=196 cpu=0 pid=290
[   18.798006] INFO: Slab 0xd27a2c40 objects=14 used=11 fp=0xd3be2230 flags=0x40004080
[   18.798006] INFO: Object 0xd3be3a40 @offset=6720 fp=0xd3be3810
[   18.798006] 
[   18.798006] Bytes b4 d3be3a30: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[   18.798006] Object d3be3a40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3a50: 18 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3a60: 60 c2 d4 c1 e0 20 d4 c1 00 00 00 00 00 00 00 00  `.... ..........
[   18.798006] Object d3be3a70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3a80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3a90: ff ff ff ff 00 00 00 00 00 00 00 00 9c 3a be d3  .............:..
[   18.798006] Object d3be3aa0: 9c 3a be d3 a4 3a be d3 a4 3a be d3 00 00 00 00  .:...:...:......
[   18.798006] Object d3be3ab0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3ac0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3ad0: 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3ae0: 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3af0: 00 00 00 00 00 00 00 00 00 80 02 00 fc 3a be d3  .............:..
[   18.798006] Object d3be3b00: fc 3a be d3 00 00 00 00 00 01 01 00 00 00 00 00  .:..............
[   18.798006] Object d3be3b10: d0 00 00 00 ff ff ff ff ff ff ff ff 00 00 00 00  ................
[   18.798006] Object d3be3b20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3b30: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3b40: 40 3b be d3 40 3b be d3 00 00 00 00 60 c2 d4 c1  @;..@;......`...
[   18.798006] Object d3be3b50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3b60: 00 00 00 00 00 00 00 00 ff ff ff 7f ff ff ff 7f  ................
[   18.798006] Object d3be3b70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3b80: 80 1e df c1 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   18.798006] Object d3be3b90: 00 36 65 c4 ff ff ff ff 00 00 00 00 00 00 00 00  .6e.............
[   18.798006] Object d3be3ba0: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   18.798006] Object d3be3bb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3bc0: 90 99 7a c1 60 9a 7a c1 d0 99 7a c1 20 99 7a c1  ..z.`.z...z. .z.
[   18.798006] Object d3be3bd0: b0 3c 8f c1 50 47 8f c1 00 00 00 00 00 00 00 00  .<..PG..........
[   18.798006] Object d3be3be0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3bf0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3c00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3c10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3c20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Object d3be3c30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   18.798006] Redzone d3be3c40: cc cc cc cc                                      ....
[   18.798006] Padding d3be3c68: 01 00 00 00 5a 5a 5a 5a                          ....ZZZZ
[   18.798006] FIX kmalloc-512: Restoring 0xd3be3c68-0xd3be3c6b=0x5a
[   18.798006] 
[   19.144950] =============================================================================
[   19.145005] BUG kmalloc-512 (Tainted: G    B       ): Object padding overwritten
[   19.145005] -----------------------------------------------------------------------------
[   19.145005] 
[   19.145005] INFO: 0xd3b77c68-0xd3b77c6b. First byte 0x1 instead of 0x5a
[   19.145005] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=178 cpu=0 pid=293
[   19.145005] INFO: Slab 0xd27a1ec0 objects=14 used=11 fp=0xd3b76230 flags=0x40004080
[   19.145005] INFO: Object 0xd3b77a40 @offset=6720 fp=0xd3b77810
[   19.145005] 
[   19.145005] Bytes b4 d3b77a30: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[   19.145005] Object d3b77a40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77a50: 18 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77a60: 60 c2 d4 c1 e0 20 d4 c1 00 00 00 00 00 00 00 00  `.... ..........
[   19.145005] Object d3b77a70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77a80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77a90: ff ff ff ff 00 00 00 00 00 00 00 00 9c 7a b7 d3  .............z..
[   19.145005] Object d3b77aa0: 9c 7a b7 d3 a4 7a b7 d3 a4 7a b7 d3 00 00 00 00  .z...z...z......
[   19.145005] Object d3b77ab0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77ac0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77ad0: 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77ae0: 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77af0: 00 00 00 00 00 00 00 00 00 80 02 00 fc 7a b7 d3  .............z..
[   19.145005] Object d3b77b00: fc 7a b7 d3 00 00 00 00 00 01 01 00 00 00 00 00  .z..............
[   19.145005] Object d3b77b10: d0 00 00 00 ff ff ff ff ff ff ff ff 00 00 00 00  ................
[   19.145005] Object d3b77b20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77b30: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77b40: 40 7b b7 d3 40 7b b7 d3 00 00 00 00 60 c2 d4 c1  @{..@{......`...
[   19.145005] Object d3b77b50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77b60: 00 00 00 00 00 00 00 00 ff ff ff 7f ff ff ff 7f  ................
[   19.145005] Object d3b77b70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77b80: 80 1e df c1 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.145005] Object d3b77b90: 00 36 65 c4 ff ff ff ff 00 00 00 00 00 00 00 00  .6e.............
[   19.145005] Object d3b77ba0: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff  ................
[   19.145005] Object d3b77bb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77bc0: 90 99 7a c1 60 9a 7a c1 d0 99 7a c1 20 99 7a c1  ..z.`.z...z. .z.
[   19.145005] Object d3b77bd0: b0 3c 8f c1 50 47 8f c1 00 00 00 00 00 00 00 00  .<..PG..........
[   19.145005] Object d3b77be0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77bf0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77c00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77c10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77c20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Object d3b77c30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   19.145005] Redzone d3b77c40: cc cc cc cc                                      ....
[   19.145005] Padding d3b77c68: 01 00 00 00 5a 5a 5a 5a                          ....ZZZZ
[   19.145005] FIX kmalloc-512: Restoring 0xd3b77c68-0xd3b77c6b=0x5a
[   19.145005] 

Thanks,
Fengguang

--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-ivb42-23:20140706023624:i386-randconfig-x0-07021302::"
Content-Transfer-Encoding: quoted-printable

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.12.0-rc3-00804-gefe4208 (kbuild@jaketown) (g=
cc version 4.8.2 (Debian 4.8.2-18) ) #18 Sun Jul 6 02:35:01 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/0=
1/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x100000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at =
[c00f0eb0]
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] initial memory mapped: [mem 0x00000000-0x023fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12000000-0x123fffff]
[    0.000000]  [mem 0x12000000-0x123fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x10000000-0x11ffffff]
[    0.000000]  [mem 0x10000000-0x11ffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x003fffff] page 4k
[    0.000000]  [mem 0x00400000-0x0fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12400000-0x13ffdfff]
[    0.000000]  [mem 0x12400000-0x13bfffff] page 2M
[    0.000000]  [mem 0x13c00000-0x13ffdfff] page 4k
[    0.000000] BRK [0x01e77000, 0x01e77fff] PGTABLE
[    0.000000] cma: CMA: reserved 32 MiB at 10400000
[    0.000000] RAMDISK: [mem 0x127ab000-0x13feffff]
[    0.000000] ACPI: RSDP 000f0d00 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 13fffc2a 00034 (v01 BOCHS  BXPCRSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: FACP 13fff1c0 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC=
 00000001)
[    0.000000] ACPI: DSDT 13ffe040 01180 (v01 BOCHS  BXPCDSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: FACS 13ffe000 00040
[    0.000000] ACPI: SSDT 13fff234 0093E (v01 BOCHS  BXPCSSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: APIC 13fffb72 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC=
 00000001)
[    0.000000] ACPI: HPET 13fffbf2 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC=
 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, boot clock
[    0.000000] BRK [0x01e78000, 0x01e78fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x13ffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000] free_area_init_node: node 0, pgdat c1d4f2a0, node_mem_map d2=
52b020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 608 pages used for memmap
[    0.000000]   Normal zone: 77822 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] Using ACPI for processor (LAPIC) configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000]     Virtual Wire compatibility mode.
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] MPTABLE: OEM ID: BOCHSCPU
[    0.000000] MPTABLE: Product ID: 0.1        =20
[    0.000000] MPTABLE: APIC at: 0xFEE00000
[    0.000000] Lint: type 3, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC=
 LINT 00
[    0.000000] Lint: type 1, pol 0, trig 0, bus 01, IRQ 00, APIC ID ff, API=
C LINT 01
[    0.000000] Processors: 1
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1cb93c0
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81180
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramd=
isk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram=
0 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-x0-07021302/next:ma=
ster:efe4208f47f907b86f528788da711e8ab9dea44d:bisect-linux6/.vmlinuz-efe420=
8f47f907b86f528788da711e8ab9dea44d-20140706023516-161-ivb42 branch=3Dnext/m=
aster BOOT_IMAGE=3D/kernel/i386-randconfig-x0-07021302/efe4208f47f907b86f52=
8788da711e8ab9dea44d/vmlinuz-3.12.0-rc3-00804-gefe4208 drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 251748K/327280K available (9918K kernel code, 727K r=
wdata, 3008K rodata, 564K init, 548K bss, 75532K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffe1000 - 0xfffff000   ( 120 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xd47fe000 - 0xff7fe000   ( 688 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd3ffe000   ( 319 MB)
[    0.000000]       .init : 0xc1d57000 - 0xc1de4000   ( 564 kB)
[    0.000000]       .data : 0xc19afbaf - 0xc1d56e40   (3740 kB)
[    0.000000]       .text : 0xc1000000 - 0xc19afbaf   (9918 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] SLUB: HWalign=3D128, Order=3D0-3, MinObjects=3D0, CPUs=3D1, =
Nodes=3D1
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] CPU 0 irqstacks, hard=3Dd0008000 soft=3Dd000a000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.12.0-rc3-00804-gefe4208 (kbuild@jaketown) (g=
cc version 4.8.2 (Debian 4.8.2-18) ) #18 Sun Jul 6 02:35:01 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/0=
1/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x100000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at =
[c00f0eb0]
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] initial memory mapped: [mem 0x00000000-0x023fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12000000-0x123fffff]
[    0.000000]  [mem 0x12000000-0x123fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x10000000-0x11ffffff]
[    0.000000]  [mem 0x10000000-0x11ffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x003fffff] page 4k
[    0.000000]  [mem 0x00400000-0x0fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12400000-0x13ffdfff]
[    0.000000]  [mem 0x12400000-0x13bfffff] page 2M
[    0.000000]  [mem 0x13c00000-0x13ffdfff] page 4k
[    0.000000] BRK [0x01e77000, 0x01e77fff] PGTABLE
[    0.000000] cma: CMA: reserved 32 MiB at 10400000
[    0.000000] RAMDISK: [mem 0x127ab000-0x13feffff]
[    0.000000] ACPI: RSDP 000f0d00 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 13fffc2a 00034 (v01 BOCHS  BXPCRSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: FACP 13fff1c0 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC=
 00000001)
[    0.000000] ACPI: DSDT 13ffe040 01180 (v01 BOCHS  BXPCDSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: FACS 13ffe000 00040
[    0.000000] ACPI: SSDT 13fff234 0093E (v01 BOCHS  BXPCSSDT 00000001 BXPC=
 00000001)
[    0.000000] ACPI: APIC 13fffb72 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC=
 00000001)
[    0.000000] ACPI: HPET 13fffbf2 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC=
 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, boot clock
[    0.000000] BRK [0x01e78000, 0x01e78fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x13ffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000] free_area_init_node: node 0, pgdat c1d4f2a0, node_mem_map d2=
52b020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 608 pages used for memmap
[    0.000000]   Normal zone: 77822 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] Using ACPI for processor (LAPIC) configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000]     Virtual Wire compatibility mode.
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] MPTABLE: OEM ID: BOCHSCPU
[    0.000000] MPTABLE: Product ID: 0.1        =20
[    0.000000] MPTABLE: APIC at: 0xFEE00000
[    0.000000] Lint: type 3, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC=
 LINT 00
[    0.000000] Lint: type 1, pol 0, trig 0, bus 01, IRQ 00, APIC ID ff, API=
C LINT 01
[    0.000000] Processors: 1
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1cb93c0
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81180
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramd=
isk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram=
0 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-x0-07021302/next:ma=
ster:efe4208f47f907b86f528788da711e8ab9dea44d:bisect-linux6/.vmlinuz-efe420=
8f47f907b86f528788da711e8ab9dea44d-20140706023516-161-ivb42 branch=3Dnext/m=
aster BOOT_IMAGE=3D/kernel/i386-randconfig-x0-07021302/efe4208f47f907b86f52=
8788da711e8ab9dea44d/vmlinuz-3.12.0-rc3-00804-gefe4208 drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 251748K/327280K available (9918K kernel code, 727K r=
wdata, 3008K rodata, 564K init, 548K bss, 75532K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffe1000 - 0xfffff000   ( 120 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xd47fe000 - 0xff7fe000   ( 688 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd3ffe000   ( 319 MB)
[    0.000000]       .init : 0xc1d57000 - 0xc1de4000   ( 564 kB)
[    0.000000]       .data : 0xc19afbaf - 0xc1d56e40   (3740 kB)
[    0.000000]       .text : 0xc1000000 - 0xc19afbaf   (9918 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] SLUB: HWalign=3D128, Order=3D0-3, MinObjects=3D0, CPUs=3D1, =
Nodes=3D1
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] CPU 0 irqstacks, hard=3Dd0008000 soft=3Dd000a000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[    0.000000] console [ttyS0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.508 MHz processor
[    0.003000] Calibrating delay loop (skipped) preset value.. 5387.01 Bogo=
MIPS (lpj=3D2693508)
[    0.004004] pid_max: default: 32768 minimum: 301
[    0.005089] Mount-cache hash table entries: 512
[    0.006283] Initializing cgroup subsys net_cls
[    0.007006] Initializing cgroup subsys perf_event
[    0.008084] mce: CPU supports 10 MCE banks
[    0.009052] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.009052] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.009052] tlb_flushall_shift: 6
[    0.010004] CPU: Intel Common KVM processor (fam: 0f, model: 06, steppin=
g: 01)
[    0.022591] ACPI: Core revision 20130725
[    0.029633] ACPI: All ACPI Tables successfully acquired
[    0.031009] ACPI: setting ELCR to 0200 (from 0c00)
[    0.032108] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.034122] Getting VERSION: 1050014
[    0.035008] Getting VERSION: 1050014
[    0.036005] Getting ID: 0
[    0.037013] Getting ID: f000000
[    0.038009] Getting LVT0: 8700
[    0.039005] Getting LVT1: 8400
[    0.040025] enabled ExtINT on CPU#0
[    0.041014] Using local APIC timer interrupts.
[    0.041014] calibrating APIC timer ...
[    0.043000] ... lapic delta =3D 6438130
[    0.043000] ... PM-Timer delta =3D 368720
[    0.043000] APIC calibration not consistent with PM-Timer: 103ms instead=
 of 100ms
[    0.043000] APIC delta adjusted to PM-Timer: 6250147 (6438130)
[    0.043000] TSC delta adjusted to PM-Timer: 269348185 (277449234)
[    0.043000] ..... delta 6250147
[    0.043000] ..... mult: 268441769
[    0.043000] ..... calibration result: 1000023
[    0.043000] ..... CPU clock speed is 2693.0481 MHz.
[    0.043000] ..... host bus clock speed is 1000.0023 MHz.
[    0.043212] devtmpfs: initialized
[    0.045436] regulator-dummy: no parameters
[    0.046192] NET: Registered protocol family 16
[    0.048299] cpuidle: using governor ladder
[    0.049002] cpuidle: using governor menu
[    0.050494] ACPI: bus type PCI registered
[    0.051232] PCI: PCI BIOS revision 2.10 entry at 0xfd456, last bus=3D0
[    0.052002] PCI: Using configuration type 1 for base access
[    0.059893] bio: create slab <bio-0> at 0
[    0.061174] ACPI: Added _OSI(Module Device)
[    0.062002] ACPI: Added _OSI(Processor Device)
[    0.063002] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.064002] ACPI: Added _OSI(Processor Aggregator Device)
[    0.065514] ACPI: EC: Look up EC in DSDT
[    0.074615] ACPI: Interpreter enabled
[    0.075013] ACPI: (supports S0 S5)
[    0.076002] ACPI: Using PIC for interrupt routing
[    0.077043] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.091267] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.092012] acpi PNP0A03:00: Unable to request _OSC control (_OSC suppor=
t mask: 0x08)
[    0.093468] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.094057] PCI host bridge to bus 0000:00
[    0.095004] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.096004] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.097004] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff]
[    0.098004] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff]
[    0.099006] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf]
[    0.100004] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff]
[    0.101004] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.102004] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f]
[    0.103039] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.104501] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.105606] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.109492] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.112128] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.113332] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.114011] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.116119] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.118612] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.121003] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.128004] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.130252] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.132003] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.134492] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.140489] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.142241] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.143510] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.147466] pci_bus 0000:00: on NUMA node 0
[    0.149719] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.151306] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.153299] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.155345] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.157048] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.159368] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.160007] ACPI: \_SB_.PCI0: notify handler is installed
[    0.161021] Found 1 acpi root devices
[    0.163139] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.164002] vgaarb: loaded
[    0.165001] vgaarb: bridge control possible 0000:00:02.0
[    0.167315] SCSI subsystem initialized
[    0.168036] libata version 3.00 loaded.
[    0.169144] media: Linux media interface: v0.10
[    0.170023] Linux video capture interface: v2.00
[    0.171025] pps_core: LinuxPPS API ver. 1 registered
[    0.172001] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.173014] PTP clock support registered
[    0.174177] PCI: Using ACPI for IRQ routing
[    0.175002] PCI: pci_cache_line_size set to 64 bytes
[    0.176103] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.177005] e820: reserve RAM buffer [mem 0x13ffe000-0x13ffffff]
[    0.178171] Bluetooth: Core ver 2.16
[    0.179014] NET: Registered protocol family 31
[    0.180001] Bluetooth: HCI device and connection manager initialized
[    0.181006] Bluetooth: HCI socket layer initialized
[    0.182005] Bluetooth: L2CAP socket layer initialized
[    0.183005] Bluetooth: SCO socket layer initialized
[    0.185025] nfc: nfc_init: NFC Core ver 0.1
[    0.186029] NET: Registered protocol family 39
[    0.187514] Switched to clocksource kvm-clock
[    0.188086] pnp: PnP ACPI init
[    0.188901] ACPI: bus type PNP registered
[    0.189940] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.191339] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.192732] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.194144] pnp 00:03: [dma 2]
[    0.194988] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.196436] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.197871] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.199702] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.201443] pnp 00:07: Plug and Play ACPI device, IDs PNP0a06 (active)
[    0.202752] pnp: PnP ACPI: found 8 devices
[    0.203750] ACPI: bus type PNP unregistered
[    0.533006] mdacon: MDA with 8K of memory detected.
[    0.533065] Console: switching consoles 13-16 to MDA-2
[    0.570084] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.571269] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff]
[    0.572433] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff]
[    0.573628] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf]
[    0.574798] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff]
[    0.575961] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff]
[    0.577229] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff]
[    0.578564] NET: Registered protocol family 2
[    0.579757] TCP established hash table entries: 4096 (order: 2, 16384 by=
tes)
[    0.581174] TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
[    0.582468] TCP: Hash tables configured (established 4096 bind 4096)
[    0.583758] TCP: reno registered
[    0.584604] UDP hash table entries: 256 (order: 0, 4096 bytes)
[    0.585805] UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
[    0.587146] NET: Registered protocol family 1
[    0.588161] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.589390] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.590595] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.591861] pci 0000:00:02.0: Boot video device
[    0.592904] PCI: CLS 0 bytes, default 64
[    0.593943] Trying to unpack rootfs image as initramfs...
[    0.666152] cfg80211: Calling CRDA to update world regulatory domain
[    1.254651] Freeing initrd memory: 24852K (d27ab000 - d3ff0000)
[    1.256128] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.256940] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    1.258695] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    1.260039] NatSemi SCx200 Driver
[    1.260793] audit: initializing netlink socket (disabled)
[    1.261580] type=3D2000 audit(1404585359.400:1): initialized
[    1.265482] VFS: Disk quotas dquot_6.5.2
[    1.266169] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    1.267664] fuse init (API version 7.22)
[    1.268508] JFS: nTxBlock =3D 2416, nTxLock =3D 19335
[    1.269582] NILFS version 2 loaded
[    1.270170] OCFS2 1.5.0
[    1.270800] OCFS2 DLMFS 1.5.0
[    1.271394] OCFS2 User DLM kernel interface loaded
[    1.272112] OCFS2 Node Manager 1.5.0
[    1.273037] GFS2 installed
[    1.275555] alg: No test for crc32 (crc32-table)
[    1.276354] alg: No test for lz4 (lz4-generic)
[    1.277055] alg: No test for lz4hc (lz4hc-generic)
[    1.277784] alg: No test for stdrng (krng)
[    1.278478] NET: Registered protocol family 38
[    1.279167] Key type asymmetric registered
[    1.279798] Asymmetric key parser 'x509' registered
[    1.280569] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    1.283348] io scheduler noop registered (default)
[    1.284125] io scheduler cfq registered
[    1.284735] test_string_helpers: Running tests...
[    1.285783] crc32: CRC_LE_BITS =3D 64, CRC_BE BITS =3D 64
[    1.286527] crc32: self tests passed, processed 225944 bytes in 148697 n=
sec
[    1.287595] crc32c: CRC_LE_BITS =3D 64
[    1.288191] crc32c: self tests passed, processed 225944 bytes in 75040 n=
sec
[    1.289176] Console: switching consoles 13-16 to MDA-2
[    1.290085] hgafb: HGA card not detected.
[    1.290707] hgafb: probe of hgafb.0 failed with error -22
[    1.291578] uvesafb: failed to execute /sbin/v86d
[    1.292301] uvesafb: make sure that the v86d helper is installed and exe=
cutable
[    1.293440] uvesafb: Getting VBE info block failed (eax=3D0x4f00, err=3D=
-2)
[    1.294324] uvesafb: vbe_init() failed with -22
[    1.294993] uvesafb: probe of uvesafb.0 failed with error -22
[    1.295875] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    1.297054] ACPI: Power Button [PWRF]
[    1.308695] r3964: Philips r3964 Driver $Revision: 1.10 $
[    1.309482] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.336025] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    1.338995] Cyclades driver 2.6
[    1.359724] MOXA Smartio/Industio family driver version 2.0.5
[    1.360587] lp: driver loaded but no devices found
[    1.361335] DoubleTalk PC - not found
[    1.362027] ppdev: user-space parallel port driver
[    1.362768] scx200_gpio: no SCx200 gpio present
[    1.363507] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initial=
izing
[    1.364448] platform pc8736x_gpio.0: no device found
[    1.365200] nsc_gpio initializing
[    1.365773] smapi::smapi_init, ERROR invalid usSmapiID
[    1.366516] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    1.367828] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    1.368956] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    1.369822] SyncLink PC Card driver $Revision: 4.34 $, tty major#248
[    1.370730] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    1.372023] Hangcheck: Using getrawmonotonic().
[    1.372755] [drm] Initialized drm 1.1.0 20060810
[    1.373932] parport_pc 00:04: reported by Plug and Play ACPI
[    1.374811] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    1.457195] lp0: using parport0 (interrupt-driven).
[    1.457938] lp0: console ready
[    1.460430] brd: module loaded
[    1.461730] loop: module loaded
[    1.462552] nbd: registered device at major 43
[    1.465016] rbd: loaded rbd (rados block device)
[    1.465779] dummy-irq: no IRQ given.  Use irq=3DN
[    1.466603] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    1.467931] c2port c2port0: C2 port uc added
[    1.468638] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    1.470419] Uniform Multi-Platform E-IDE driver
[    1.471247] ide_generic: please use "probe_mask=3D0x3f" module parameter=
 for probing all legacy ISA IDE ports
[    1.472770] ide-gd driver 1.18
[    1.473450] ide-cd driver 5.00
[    1.474103] Loading iSCSI transport class v2.0-870.
[    1.475051] hp_sw: device handler registered
[    1.475872] emc: device handler registered
[    1.476739] iscsi: registered transport (tcp)
[    1.477850] scsi: <fdomain> Detection failed (no card)
[    1.478810] NCR53c406a: no available ports found
[    1.479618] sym53c416.c: Version 1.0.0-ac
[    1.480385] qlogicfas: no cards were found, please specify I/O address a=
nd IRQ using iobase=3D and irq=3D optionsFailed initialization of WD-7000 S=
CSI card!
[    1.590841] ppa: Version 2.07 (for Linux 2.4.x)
[    1.593756] imm: Version 2.05 (for Linux 2.4.0)
[    1.594962] osst :I: Tape driver with OnStream support version 0.99.4
[    1.594962] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    1.597100] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    1.598704] SSFDC read-only Flash Translation layer
[    1.599461] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[    1.600654] platform physmap-flash.0: failed to claim resource 0
[    1.601515] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    1.602387] scx200_docflash: NatSemi SCx200 DOCCS Flash Driver
[    1.603194] Generic platform RAM MTD, (c) 2004 Simtec Electronics
[    1.604058] slram: not enough parameters.
[    1.605399] ftl_cs: FTL header not found.
[    1.642789] No valid DiskOnChip devices found
[    1.644431] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S.=
 Miller (davem@redhat.com)
[    1.647309] LocalTalk card not found; 220 =3D ff, 240 =3D ff.
[    1.649320] arcnet loaded.
[    1.650161] arcnet: RFC1201 "standard" (`a') encapsulation support loade=
d.
[    1.651620] arcnet: raw mode (`r') encapsulation support loaded.
[    1.652988] arcnet: COM90xx chipset support
[    1.960608] S3: No ARCnet cards found.
[    1.962087] arcnet: COM90xx IO-mapped mode support (by David Woodhouse e=
t el.)
[    1.963940] E-mail me if you actually test this driver, please!
[    1.965262]  arc%d: No autoprobe for IO mapped cards; you must specify t=
he base address!
[    2.005463] PPP generic driver version 2.4.2
[    2.006646] PPP BSD Compression module registered
[    2.007788] PPP MPPE Compression module registered
[    2.008933] NET: Registered protocol family 24
[    2.010033] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=
=3D256).
[    2.011534] CSLIP: code copyright 1989 Regents of the University of Cali=
fornia.
[    2.013384] SLIP linefill/keepalive option.
[    2.014479] airo(): Probing for PCI adapters
[    2.015583] airo(): Finished probing for PCI adapters
[    2.016808] Broadcom 43xx-legacy driver loaded [ Features: PLD ]
[    2.018188] libertas_sdio: Libertas SDIO driver
[    2.019304] libertas_sdio: Copyright Pierre Ossman
[    2.020607] Intel ISA PCIC probe: not found.
[    2.021874] Databook TCIC-2 PCMCIA probe: not found.
[    2.023506] aoe: cannot create debugfs directory
[    2.024669] aoe: AoE v85 initialised.
[    2.025720] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    2.028334] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.029510] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.091936] mousedev: PS/2 mouse device common for all mice
[    2.093726] mk712: device not present
[    2.095398] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    2.097531] wistron_btns: System unknown
[    2.099572] i2c-parport-light: adapter type unspecified
[    2.100899] isa i2c-pca-isa.0: Please specify I/O base
[    2.102144] scx200_i2c: no SCx200 gpio pins available
[    2.103798] m2m-testdev m2m-testdev.0: Device registered as /dev/video0
[    2.105298] radio-rtrack2.0: you must set an I/O address with io=3D0x20f=
/0x30f.
[    2.106985] radio-rtrack2: probe of radio-rtrack2.0 failed with error -22
[    2.256092] tsc: Refined TSC clocksource calibration: 2693.522 MHz
[    5.341646] radio-typhoon.0: Initialized radio card Typhoon Radio on por=
t 0x316
[    8.343675] radio-aimslab.0: Initialized radio card AIMSlab RadioTrack/R=
adioReveal on port 0x30f
[    8.376236] radio-zoltrix.0: Initialized radio card Zoltrix Radio Plus o=
n port 0x20c
[    8.377596] pps pps0: new PPS source ktimer
[    8.378250] pps pps0: ktimer PPS source registered
[    8.378939] pps_ldisc: PPS line discipline registered
[    8.379661] pps_parport: parallel port PPS client
[    8.380363] parport0: cannot grant exclusive access for device pps_parpo=
rt
[    8.381297] pps_parport: couldn't register with parport0
[    8.395096] Driver for 1-wire Dallas network protocol.
[    8.395901] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    8.397031] w83781d: Detection failed at step 2
[    8.398409] intel_powerclamp: Intel powerclamp does not run on family 15=
 model 6
[    8.399545] md: raid0 personality registered for level 0
[    8.400296] md: raid1 personality registered for level 1
[    8.401036] md: raid10 personality registered for level 10
[    8.401794] md: multipath personality registered for level -4
[    8.402583] Bluetooth: Virtual HCI driver ver 1.4
[    8.403313] Bluetooth: HCI UART driver ver 2.2
[    8.404043] wbsd: Winbond W83L51xD SD/MMC card interface driver
[    8.404841] wbsd: Copyright(c) Pierre Ossman
[    8.405766] ledtrig-cpu: registered to indicate activity on CPUs
[    8.407211] pktgen: Packet Generator for packet performance testing. Ver=
sion: 2.74
[    8.421438] NET: Registered protocol family 26
[    8.422245] u32 classifier
[    8.422745]     input device check on
[    8.423411] ipip: IPv4 over IPv4 tunneling driver
[    8.424216] TCP: cubic registered
[    8.424773] Initializing XFRM netlink socket
[    8.425661] NET: Registered protocol family 10
[    8.426630] mip6: Mobile IPv6
[    8.427170] sit: IPv6 over IPv4 tunneling driver
[    8.428103] ip6_gre: GRE over IPv6 tunneling driver
[    8.428930] NET: Registered protocol family 15
[    8.429663] NET: Registered protocol family 5
[    8.430364] NET: Registered protocol family 9
[    8.431021] X.25 for Linux Version 0.2
[    8.431652] Bluetooth: RFCOMM socket layer initialized
[    8.432397] Bluetooth: RFCOMM ver 1.11
[    8.432988] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[    8.433734] Bluetooth: BNEP filters: multicast
[    8.434408] Bluetooth: BNEP socket layer initialized
[    8.436743] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[    8.437553] Bluetooth: HIDP socket layer initialized
[    8.438349] NET: Registered protocol family 33
[    8.439018] Key type rxrpc registered
[    8.439610] Key type rxrpc_s registered
[    8.440233] l2tp_core: L2TP core driver, V2.0
[    8.440889] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[    8.441592] lib80211: common routines for IEEE802.11 drivers
[    8.442378] lib80211_crypt: registered algorithm 'NULL'
[    8.456136] lib80211_crypt: registered algorithm 'WEP'
[    8.456864] lib80211_crypt: registered algorithm 'CCMP'
[    8.457609] lib80211_crypt: registered algorithm 'TKIP'
[    8.458359] tipc: Activated (version 2.0.0)
[    8.459144] NET: Registered protocol family 30
[    8.459932] tipc: Started in single node mode
[    8.460608] 9pnet: Installing 9P2000 support
[    8.461299] NET: Registered protocol family 37
[    8.461968] Key type ceph registered
[    8.462666] libceph: loaded (mon/osd proto 15/24)
[    8.463412] batman_adv: B.A.T.M.A.N. advanced 2013.4.0 (compatibility ve=
rsion 14) loaded
[    8.464630] mpls_gso: MPLS GSO support
[    8.465667] Using IPI Shortcut mode
[    8.466335] registered taskstats version 1
[    8.467106] Key type trusted registered
[    8.467868] Key type encrypted registered
[    8.468798] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
[    8.483057] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    8.483873] EDD information not available.
[    8.484755] Freeing unused kernel memory: 564K (c1d57000 - c1de4000)
[    8.485644] Write protecting the kernel text: 9920k
[    8.486380] Write protecting the kernel read-only data: 3012k
[    8.560469] init: Failed to create pty - disabling logging for job
[    8.561379] init: Temporary process spawn error: No such file or directo=
ry
[    8.566894] init: Failed to create pty - disabling logging for job
[    8.567789] init: Temporary process spawn error: No such file or directo=
ry
[    8.590649] init: Failed to create pty - disabling logging for job
[    8.591553] init: Temporary process spawn error: No such file or directo=
ry
[    8.593740] init: Failed to create pty - disabling logging for job
[    8.594625] init: Temporary process spawn error: No such file or directo=
ry
[    8.622613] init: Failed to create pty - disabling logging for job
[    8.623555] init: Temporary process spawn error: No such file or directo=
ry
[    8.638236] init: Failed to create pty - disabling logging for job
[    8.639123] init: Temporary process spawn error: No such file or directo=
ry
[    8.644139] init: Failed to create pty - disabling logging for job
[    8.645019] init: Temporary process spawn error: No such file or directo=
ry
[    8.650521] udevd[191]: starting version 175
[    8.665166] init: Failed to create pty - disabling logging for job
[    8.666044] init: Temporary process spawn error: No such file or directo=
ry
[    8.670498] init: Failed to create pty - disabling logging for job
[    8.671392] init: Temporary process spawn error: No such file or directo=
ry
[    8.674241] init: Failed to create pty - disabling logging for job
[    8.675132] init: Temporary process spawn error: No such file or directo=
ry
[    8.699255] init: Failed to create pty - disabling logging for job
[    8.701102] init: Failed to create pty - disabling logging for job
[    8.850837] init: Failed to create pty - disabling logging for job
[    8.852977] init: Failed to create pty - disabling logging for job
[    8.855701] init: Failed to create pty - disabling logging for job
[    8.872634] init: Failed to create pty - disabling logging for job
[    8.976187] init: Failed to create pty - disabling logging for job
[    8.981151] init: Failed to create pty - disabling logging for job
[    8.983247] init: Failed to create pty - disabling logging for job
Kernel tests: Boot OK!
[    8.987192] init: Failed to create pty - disabling logging for job
[    8.991691] init: Failed to create pty - disabling logging for job
[   19.686410] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[   19.687007] BUG kmalloc-512 (Not tainted): Object padding overwritten
[   19.687007] ------------------------------------------------------------=
-----------------
[   19.687007]=20
[   19.687007] INFO: 0xd34113a8-0xd34113ab. First byte 0x1 instead of 0x5a
[   19.687007] INFO: Allocated in sk_prot_alloc.isra.39+0x53/0xd0 age=3D606=
 cpu=3D0 pid=3D293
[   19.687007] INFO: Slab 0xd2793200 objects=3D14 used=3D3 fp=3D0xd3410af0 =
flags=3D0x40004080
[   19.687007] INFO: Object 0xd3411180 @offset=3D4480 fp=3D0xd3410f50
[   19.687007]=20
[   19.687007] Bytes b4 d3411170: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a=
 5a 5a  ........ZZZZZZZZ
[   19.687007] Object d3411180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411190: 18 00 10 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d34111a0: 60 c2 d4 c1 e0 20 d4 c1 00 00 00 00 00 00 0=
0 00  `.... ..........
[   19.687007] Object d34111b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d34111c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d34111d0: ff ff ff ff 00 00 00 00 00 00 00 00 dc 11 4=
1 d3  ..............A.
[   19.687007] Object d34111e0: dc 11 41 d3 e4 11 41 d3 e4 11 41 d3 00 00 0=
0 00  ..A...A...A.....
[   19.687007] Object d34111f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411210: 00 80 02 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411220: 00 00 00 00 01 01 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411230: 00 00 00 00 00 00 00 00 00 80 02 00 3c 12 4=
1 d3  ............<.A.
[   19.687007] Object d3411240: 3c 12 41 d3 00 00 00 00 00 01 01 00 00 00 0=
0 00  <.A.............
[   19.687007] Object d3411250: d0 00 00 00 ff ff ff ff ff ff ff ff 00 00 0=
0 00  ................
[   19.687007] Object d3411260: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411270: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411280: 80 12 41 d3 80 12 41 d3 00 00 00 00 60 c2 d=
4 c1  ..A...A.....`...
[   19.687007] Object d3411290: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d34112a0: 00 00 00 00 00 00 00 00 ff ff ff 7f ff ff f=
f 7f  ................
[   19.687007] Object d34112b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d34112c0: 80 1e df c1 00 00 00 00 00 00 00 00 ff ff f=
f ff  ................
[   19.687007] Object d34112d0: 00 36 65 c4 ff ff ff ff 00 00 00 00 00 00 0=
0 00  .6e.............
[   19.687007] Object d34112e0: 00 00 00 00 00 00 00 00 00 00 00 00 ff ff f=
f ff  ................
[   19.687007] Object d34112f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411300: 90 99 7a c1 60 9a 7a c1 d0 99 7a c1 20 99 7=
a c1  ..z.`.z...z. .z.
[   19.687007] Object d3411310: b0 3c 8f c1 50 47 8f c1 00 00 00 00 00 00 0=
0 00  .<..PG..........
[   19.687007] Object d3411320: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411330: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411340: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411350: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411360: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Object d3411370: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 00  ................
[   19.687007] Redzone d3411380: cc cc cc cc                               =
       ....
[   19.687007] Padding d34113a8: 01 00 00 00 5a 5a 5a 5a                   =
       ....ZZZZ
[   19.687007] FIX kmalloc-512: Restoring 0xd34113a8-0xd34113ab=3D0x5a
[   19.687007]=20

Elapsed time: 25
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-x=
0-07021302/efe4208f47f907b86f528788da711e8ab9dea44d/vmlinuz-3.12.0-rc3-0080=
4-gefe4208 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug ap=
ic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=
=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=
=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kb=
uild-tests/run-queue/kvm/i386-randconfig-x0-07021302/next:master:efe4208f47=
f907b86f528788da711e8ab9dea44d:bisect-linux6/.vmlinuz-efe4208f47f907b86f528=
788da711e8ab9dea44d-20140706023516-161-ivb42 branch=3Dnext/master BOOT_IMAG=
E=3D/kernel/i386-randconfig-x0-07021302/efe4208f47f907b86f528788da711e8ab9d=
ea44d/vmlinuz-3.12.0-rc3-00804-gefe4208 drbd.minor_count=3D8'  -initrd /ker=
nel-tests/initrd/quantal-core-i386.cgz -m 320 -smp 2 -net nic,vlan=3D1,mode=
l=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i6300esb=
 -rtc base=3Dlocaltime -pidfile /dev/shm/kboot/pid-quantal-ivb42-23 -serial=
 file:/dev/shm/kboot/serial-quantal-ivb42-23 -daemonize -display none -moni=
tor null=20

--wq9mPyueHGvFACwf
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="i386-randconfig-x0-07021302-bbb74586d1d776b6c61ef04a2d669f2e47703ccd-BUG----Object-padding-overwritten-52759.log"
Content-Transfer-Encoding: base64

SEVBRCBpcyBub3cgYXQgYmJiNzQ1OC4uLiBBZGQgbGludXgtbmV4dCBzcGVjaWZpYyBmaWxl
cyBmb3IgMjAxNDA3MDEKZ2l0IGNoZWNrb3V0IGYzYjgwYjFjNDM4MWYzMDJmZjdiNzZiYTMw
NWUyOGQwYmQxYTRkYmQKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYt
cmFuZGNvbmZpZy14MC0wNzAyMTMwMi9uZXh0Om1hc3RlcjpmM2I4MGIxYzQzODFmMzAyZmY3
Yjc2YmEzMDVlMjhkMGJkMWE0ZGJkOmJpc2VjdC1saW51eDYKCjIwMTQtMDctMDQtMDA6MTg6
MDYgZjNiODBiMWM0MzgxZjMwMmZmN2I3NmJhMzA1ZTI4ZDBiZDFhNGRiZCBjb21waWxpbmcK
d2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kz
ODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi1mM2I4MGIxYzQzODFmMzAyZmY3Yjc2YmEzMDVl
MjhkMGJkMWE0ZGJkCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9i
dWlsZC1xdWV1ZS9qYWtldG93bi1jb25zdW1lci9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEz
MDItZjNiODBiMWM0MzgxZjMwMmZmN2I3NmJhMzA1ZTI4ZDBiZDFhNGRiZAprZXJuZWw6IC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL2YzYjgwYjFjNDM4MWYzMDJmZjdi
NzZiYTMwNWUyOGQwYmQxYTRkYmQvdm1saW51ei0zLjE2LjAtcmMzLTAyOTgzLWdmM2I4MGIx
CgoyMDE0LTA3LTA0LTAwOjU1OjA2IGRldGVjdGluZyBib290IHN0YXRlIC4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4bWzE7MzVtMjAxNC0wNy0wNCAwMzoyNTozNyBhZGRfdG9f
cnVuX3F1ZXVlIDEyMBtbMG0KLi4uLi4uLi4uLi4uLgk1CTEyCTE5CTI1IFRFU1QgRkFJTFVS
RQpbICAgIDguMzQyNTgxXSBpbml0OiBGYWlsZWQgdG8gY3JlYXRlIHB0eSAtIGRpc2FibGlu
ZyBsb2dnaW5nIGZvciBqb2IKS2VybmVsIHRlc3RzOiBCb290IE9LIQpbICAgMTkuNzE1MTgx
XSA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PQpbICAgMTkuNzE2MDA3XSBCVUcga21hbGxvYy01
MTIgKE5vdCB0YWludGVkKTogT2JqZWN0IHBhZGRpbmcgb3ZlcndyaXR0ZW4KWyAgIDE5Ljcx
NjAwN10gLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KWyAgIDE5LjcxNjAwN10gClsgICAxOS43
MTYwMDddIElORk86IDB4ZDNhMjljNjgtMHhkM2EyOWM2Yi4gRmlyc3QgYnl0ZSAweDEgaW5z
dGVhZCBvZiAweDVhClsgICAxOS43MTYwMDddIElORk86IEFsbG9jYXRlZCBpbiBza19wcm90
X2FsbG9jLmlzcmEuMzkrMHg1My8weGQwIGFnZT0xMjM3IGNwdT0wIHBpZD0yOTYKWyAgIDE5
LjcxNjAwN10gSU5GTzogU2xhYiAweGQyNzlmNTAwIG9iamVjdHM9MTQgdXNlZD0xMSBmcD0w
eGQzYTI4MjMwIGZsYWdzPTB4NDAwMDQwODAKWyAgIDE5LjcxNjAwN10gSU5GTzogT2JqZWN0
IDB4ZDNhMjlhNDAgQG9mZnNldD02NzIwIGZwPTB4ZDNhMjk4MTAKWyAgIDE5LjcxNjAwN10g
ClsgICAxOS43MTYwMDddIEJ5dGVzIGI0IGQzYTI5YTMwOiAwMCAwMCAwMCAwMCAwMCAwMCAw
MCAwMCA1YSA1YSA1YSA1YSA1YSA1YSA1YSA1YSAgLi4uLi4uLi5aWlpaWlpaWgpbICAgMTku
NzE2MDA3XSBPYmplY3QgZDNhMjlhNDA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAw
IDAwIDAwIDAwIDAwIDAwIDAwICAuLi4uLi4uLi4uLi4uLi4uCi9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLXgwLTA3MDIxMzAyL2YzYjgwYjFjNDM4MWYzMDJmZjdiNzZiYTMwNWUyOGQwYmQx
YTRkYmQvZG1lc2ctcXVhbnRhbC1pdmI0MS0zNjoyMDE0MDcwNDAzMzAxMTppMzg2LXJhbmRj
b25maWcteDAtMDcwMjEzMDI6OgoxMzM6Njo5IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3Rz
ChtbMTszNW0yMDE0LTA3LTA0IDAzOjM0OjA4IFJFUEVBVCBDT1VOVDogMjQ2ICAjIC9jL2Jv
b3QtYmlzZWN0L2xpbnV4Ni9vYmotYmlzZWN0Ly5yZXBlYXQbWzBtCgpiaXNlY3Q6IGJhZCBj
b21taXQgZjNiODBiMWM0MzgxZjMwMmZmN2I3NmJhMzA1ZTI4ZDBiZDFhNGRiZApnaXQgY2hl
Y2tvdXQgdjMuMTUKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFu
ZGNvbmZpZy14MC0wNzAyMTMwMi9uZXh0Om1hc3RlcjoxODYwZTM3OTg3NWRmZTcyNzFjNjQ5
MDU4YWVkZGZmZTVhZmQ5ZDBkOmJpc2VjdC1saW51eDYKCjIwMTQtMDctMDQtMDM6MzQ6MjYg
MTg2MGUzNzk4NzVkZmU3MjcxYzY0OTA1OGFlZGRmZmU1YWZkOWQwZCBjb21waWxpbmcKUXVl
dWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRj
b25maWcteDAtMDcwMjEzMDItMTg2MGUzNzk4NzVkZmU3MjcxYzY0OTA1OGFlZGRmZmU1YWZk
OWQwZApDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyLzE4NjBlMzc5ODc1ZGZlNzI3MWM2NDkwNThhZWRkZmZlNWFmZDlkMGQKd2FpdGlu
ZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFu
ZGNvbmZpZy14MC0wNzAyMTMwMi0xODYwZTM3OTg3NWRmZTcyNzFjNjQ5MDU4YWVkZGZmZTVh
ZmQ5ZDBkCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1x
dWV1ZS9qYWtldG93bi1jb25zdW1lci9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItMTg2
MGUzNzk4NzVkZmU3MjcxYzY0OTA1OGFlZGRmZmU1YWZkOWQwZAprZXJuZWw6IC9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzE4NjBlMzc5ODc1ZGZlNzI3MWM2NDkwNThh
ZWRkZmZlNWFmZDlkMGQvdm1saW51ei0zLjE1LjAKCjIwMTQtMDctMDQtMDU6MTQ6MjcgZGV0
ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uCTIJOQkxNCBURVNUIEZBSUxVUkUKWyAgICA5LjU5MzYy
MV0gaW5pdDogRmFpbGVkIHRvIGNyZWF0ZSBwdHkgLSBkaXNhYmxpbmcgbG9nZ2luZyBmb3Ig
am9iCktlcm5lbCB0ZXN0czogQm9vdCBPSyEKWyAgIDIwLjA2MzAxNV0gPT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT0KWyAgIDIwLjA2NDAwOF0gQlVHIGttYWxsb2MtNTEyIChOb3QgdGFpbnRl
ZCk6IE9iamVjdCBwYWRkaW5nIG92ZXJ3cml0dGVuClsgICAyMC4wNjQwMDhdIC0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tClsgICAyMC4wNjQwMDhdIApbICAgMjAuMDY0MDA4XSBJTkZPOiAw
eGQzNDM1MTc4LTB4ZDM0MzUxN2IuIEZpcnN0IGJ5dGUgMHgxIGluc3RlYWQgb2YgMHg1YQpb
ICAgMjAuMDY0MDA4XSBJTkZPOiBBbGxvY2F0ZWQgaW4gc2tfcHJvdF9hbGxvYy5pc3JhLjQy
KzB4NTMvMHhkMCBhZ2U9MzE3IGNwdT0wIHBpZD0yOTgKWyAgIDIwLjA2NDAwOF0gSU5GTzog
U2xhYiAweGQyNzkzNjgwIG9iamVjdHM9MTQgdXNlZD0xIGZwPTB4ZDM0MzRkMjAgZmxhZ3M9
MHg0MDAwNDA4MApbICAgMjAuMDY0MDA4XSBJTkZPOiBPYmplY3QgMHhkMzQzNGY1MCBAb2Zm
c2V0PTM5MjAgZnA9MHggIChudWxsKQpbICAgMjAuMDY0MDA4XSAKWyAgIDIwLjA2NDAwOF0g
Qnl0ZXMgYjQgZDM0MzRmNDA6IDJhIDAxIDAwIDAwIDdlIGJhIGZiIGZmIDVhIDVhIDVhIDVh
IDVhIDVhIDVhIDVhICAqLi4ufi4uLlpaWlpaWlpaClsgICAyMC4wNjQwMDhdIE9iamVjdCBk
MzQzNGY1MDogMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAg
MDAgIC4uLi4uLi4uLi4uLi4uLi4KL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEz
MDIvMTg2MGUzNzk4NzVkZmU3MjcxYzY0OTA1OGFlZGRmZmU1YWZkOWQwZC9kbWVzZy1xdWFu
dGFsLWl2YjQxLTMwOjIwMTQwNzA0MDUxNDQyOmkzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMw
Mjo6CjE1OjE6MSBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwoKYmlzZWN0OiBiYWQgY29t
bWl0IHYzLjE1CmdpdCBjaGVja291dCB2My4xNApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1x
dWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL25leHQ6bWFzdGVyOjQ1NWM2
ZmRiZDIxOTE2MWJkMDliMTE2NWYxMTY5OWQ2ZDczZGUxMWM6YmlzZWN0LWxpbnV4NgoKMjAx
NC0wNy0wNC0wNToxNzozMSA0NTVjNmZkYmQyMTkxNjFiZDA5YjExNjVmMTE2OTlkNmQ3M2Rl
MTFjIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxk
LXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi00NTVjNmZkYmQyMTkxNjFiZDA5
YjExNjVmMTE2OTlkNmQ3M2RlMTFjCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2
LXJhbmRjb25maWcteDAtMDcwMjEzMDIvNDU1YzZmZGJkMjE5MTYxYmQwOWIxMTY1ZjExNjk5
ZDZkNzNkZTExYwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVp
bGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLTQ1NWM2ZmRiZDIxOTE2MWJk
MDliMTE2NWYxMTY5OWQ2ZDczZGUxMWMKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1
aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2pha2V0b3duLWNvbnN1bWVyL2kzODYtcmFuZGNvbmZp
Zy14MC0wNzAyMTMwMi00NTVjNmZkYmQyMTkxNjFiZDA5YjExNjVmMTE2OTlkNmQ3M2RlMTFj
Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvNDU1YzZmZGJk
MjE5MTYxYmQwOWIxMTY1ZjExNjk5ZDZkNzNkZTExYy92bWxpbnV6LTMuMTQuMAoKMjAxNC0w
Ny0wNC0wNjoxNTozMSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4uLi4uLi4JNQkxMQkxNyBU
RVNUIEZBSUxVUkUKWyAgICA4LjYwOTMyOF0gaW5pdDogRmFpbGVkIHRvIGNyZWF0ZSBwdHkg
LSBkaXNhYmxpbmcgbG9nZ2luZyBmb3Igam9iCktlcm5lbCB0ZXN0czogQm9vdCBPSyEKWyAg
IDE4LjYxNDM4Nl0gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KWyAgIDE4LjYxNDc0NF0gQlVH
IGttYWxsb2MtNTEyIChOb3QgdGFpbnRlZCk6IE9iamVjdCBwYWRkaW5nIG92ZXJ3cml0dGVu
ClsgICAxOC42MTQ3NDRdIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tClsgICAxOC42MTQ3NDRd
IApbICAgMTguNjE0NzQ0XSBJTkZPOiAweGQzYTU5ODA4LTB4ZDNhNTk4MGIuIEZpcnN0IGJ5
dGUgMHgxIGluc3RlYWQgb2YgMHg1YQpbICAgMTguNjE0NzQ0XSBJTkZPOiBBbGxvY2F0ZWQg
aW4gc2tfcHJvdF9hbGxvYy5pc3JhLjQxKzB4NTMvMHhkMCBhZ2U9MjEwIGNwdT0wIHBpZD0y
OTMKWyAgIDE4LjYxNDc0NF0gSU5GTzogU2xhYiAweGQyNzlmYjAwIG9iamVjdHM9MTQgdXNl
ZD03IGZwPTB4ZDNhNTg2OTAgZmxhZ3M9MHg0MDAwNDA4MApbICAgMTguNjE0NzQ0XSBJTkZP
OiBPYmplY3QgMHhkM2E1OTVlMCBAb2Zmc2V0PTU2MDAgZnA9MHhkM2E1OTNiMApbICAgMTgu
NjE0NzQ0XSAKWyAgIDE4LjYxNDc0NF0gQnl0ZXMgYjQgZDNhNTk1ZDA6IDAwIDAwIDAwIDAw
IDAwIDAwIDAwIDAwIDVhIDVhIDVhIDVhIDVhIDVhIDVhIDVhICAuLi4uLi4uLlpaWlpaWlpa
ClsgICAxOC42MTQ3NDRdIE9iamVjdCBkM2E1OTVlMDogMDAgMDAgMDAgMDAgMDAgMDAgMDAg
MDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgIC4uLi4uLi4uLi4uLi4uLi4KL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvNDU1YzZmZGJkMjE5MTYxYmQwOWIxMTY1ZjEx
Njk5ZDZkNzNkZTExYy9kbWVzZy1xdWFudGFsLWl2YjQxLTM5OjIwMTQwNzA0MDYxODQ1Omkz
ODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMjo6CjE3OjE6MSBhbGxfZ29vZDpiYWQ6YWxsX2Jh
ZCBib290cwoKYmlzZWN0OiBiYWQgY29tbWl0IHYzLjE0CmdpdCBjaGVja291dCB2My4xMwps
cyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyL25leHQ6bWFzdGVyOmQ4ZWMyNmQ3ZjgyODdmNTc4OGE0OTRmNTZlODgxNDIxMGYw
ZTY0YmU6YmlzZWN0LWxpbnV4NgoKMjAxNC0wNy0wNC0wNjoyMTozNiBkOGVjMjZkN2Y4Mjg3
ZjU3ODhhNDk0ZjU2ZTg4MTQyMTBmMGU2NGJlIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFz
ayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAy
MTMwMi1kOGVjMjZkN2Y4Mjg3ZjU3ODhhNDk0ZjU2ZTg4MTQyMTBmMGU2NGJlCkNoZWNrIGZv
ciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvZDhlYzI2
ZDdmODI4N2Y1Nzg4YTQ5NGY1NmU4ODE0MjEwZjBlNjRiZQp3YWl0aW5nIGZvciBjb21wbGV0
aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyLWQ4ZWMyNmQ3ZjgyODdmNTc4OGE0OTRmNTZlODgxNDIxMGYwZTY0YmUKd2FpdGlu
ZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2pha2V0b3du
LWNvbnN1bWVyL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi1kOGVjMjZkN2Y4Mjg3ZjU3
ODhhNDk0ZjU2ZTg4MTQyMTBmMGU2NGJlCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWcteDAtMDcwMjEzMDIvZDhlYzI2ZDdmODI4N2Y1Nzg4YTQ5NGY1NmU4ODE0MjEwZjBlNjRi
ZS92bWxpbnV6LTMuMTMuMAoKMjAxNC0wNy0wNC0wNjozNzozNiBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAuLi4uLi4uLi4uLgkxCTcJMTMgVEVTVCBGQUlMVVJFClsgICAgOC43NTQ0MTldIGlu
aXQ6IEZhaWxlZCB0byBjcmVhdGUgcHR5IC0gZGlzYWJsaW5nIGxvZ2dpbmcgZm9yIGpvYgpL
ZXJuZWwgdGVzdHM6IEJvb3QgT0shClsgICAxOC41NTk1OTZdID09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09ClsgICAxOC41NjA1NTNdIEJVRyBrbWFsbG9jLTUxMiAoTm90IHRhaW50ZWQpOiBQ
b2lzb24gb3ZlcndyaXR0ZW4KWyAgIDE4LjU2MDU1M10gLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0KWyAgIDE4LjU2MDU1M10gClsgICAxOC41NjA1NTNdIElORk86IDB4ZDM0NDhkMjAtMHhk
MzQ0OGQyMS4gRmlyc3QgYnl0ZSAweGZmIGluc3RlYWQgb2YgMHg2YgpbICAgMTguNTYwNTUz
XSBJTkZPOiBTbGFiIDB4ZDI3OTM5MDAgb2JqZWN0cz0xNCB1c2VkPTE0IGZwPTB4ICAobnVs
bCkgZmxhZ3M9MHg0MDAwNDA4MApbICAgMTguNTYwNTUzXSBJTkZPOiBPYmplY3QgMHhkMzQ0
OGQyMCBAb2Zmc2V0PTMzNjAgZnA9MHhkMzQ0OGY1MApbICAgMTguNTYwNTUzXSAKWyAgIDE4
LjU2MDU1M10gQnl0ZXMgYjQgZDM0NDhkMTA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDVh
IDVhIDVhIDVhIDVhIDVhIDVhIDVhICAuLi4uLi4uLlpaWlpaWlpaClsgICAxOC41NjA1NTNd
IE9iamVjdCBkMzQ0OGQyMDogZmYgZmYgNmIgNmIgNmIgNmIgNmIgNmIgNmIgNmIgNmIgNmIg
NmIgNmIgNmIgNmIgIC4ua2tra2tra2tra2tra2sKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
eDAtMDcwMjEzMDIvZDhlYzI2ZDdmODI4N2Y1Nzg4YTQ5NGY1NmU4ODE0MjEwZjBlNjRiZS9k
bWVzZy1xdWFudGFsLWl2YjQyLTExNDoyMDE0MDcwNDA2MzgwMTppMzg2LXJhbmRjb25maWct
eDAtMDcwMjEzMDI6OgoxMToxOjMgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCmJpc2Vj
dDogYmFkIGNvbW1pdCB2My4xMwpnaXQgY2hlY2tvdXQgdjMuMTIKbHMgLWEgL2tidWlsZC10
ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9uZXh0Om1h
c3Rlcjo1ZTAxZGM3YjI2ZDlmMjRmMzlhYmFjZTVkYTk4Y2NiZDZhNWNlYjUyOmJpc2VjdC1s
aW51eDYKCjIwMTQtMDctMDQtMDY6NDQ6NDEgNWUwMWRjN2IyNmQ5ZjI0ZjM5YWJhY2U1ZGE5
OGNjYmQ2YTVjZWI1MiBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItNWUwMWRjN2Iy
NmQ5ZjI0ZjM5YWJhY2U1ZGE5OGNjYmQ2YTVjZWI1MgpDaGVjayBmb3Iga2VybmVsIGluIC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzVlMDFkYzdiMjZkOWYyNGYzOWFi
YWNlNWRhOThjY2JkNmE1Y2ViNTIKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxk
LXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi01ZTAxZGM3
YjI2ZDlmMjRmMzlhYmFjZTVkYTk4Y2NiZDZhNWNlYjUyCndhaXRpbmcgZm9yIGNvbXBsZXRp
b24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9qYWtldG93bi1jb25zdW1lci9pMzg2
LXJhbmRjb25maWcteDAtMDcwMjEzMDItNWUwMWRjN2IyNmQ5ZjI0ZjM5YWJhY2U1ZGE5OGNj
YmQ2YTVjZWI1MgprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAy
LzVlMDFkYzdiMjZkOWYyNGYzOWFiYWNlNWRhOThjY2JkNmE1Y2ViNTIvdm1saW51ei0zLjEy
LjAKCjIwMTQtMDctMDQtMDY6NTk6NDEgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uLi4uLi4u
Li4uLi4uCTUJMTEJMTcJMjMJMjkJMzYJNDIJNDkJNTUJNjEJNjQJNzEJNzcJODMJODkJOTUJ
MTAyCTEwOAkxMTQJMTIwCTEyNwkxMzMJMTM5CTE0NgkxNTIJMTU4CTE2NAkxNzAJMTc2CTE4
MgkxODgJMTk1CTIwMQkyMDcJMjEzCTIxOQkyMjUJMjMxCTIzOAkyNDQJMjQ2IFNVQ0NFU1MK
CmJpc2VjdDogZ29vZCBjb21taXQgdjMuMTIKZ2l0IGJpc2VjdCBzdGFydCB2My4xMyB2My4x
MiAtLQovYy9rZXJuZWwtdGVzdHMvbGluZWFyLWJpc2VjdDogWyItYiIsICJ2My4xMyIsICIt
ZyIsICJ2My4xMiIsICIvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJl
LnNoIiwgIi9jL2Jvb3QtYmlzZWN0L2xpbnV4Ni9vYmotYmlzZWN0Il0KQmlzZWN0aW5nOiAx
MzI4OCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTQgc3Rl
cHMpClszYmFkOGJiNWNkMzA0OGE2N2RmNDNhYzZiMWUyZjE5MWYxOWQ5ZmYwXSBNZXJnZSBi
cmFuY2ggJ2Zvci1uZXh0JyBvZiBnaXQ6Ly9naXQuc2FtYmEub3JnL3NmcmVuY2gvY2lmcy0y
LjYKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNo
IC9jL2Jvb3QtYmlzZWN0L2xpbnV4Ni9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMv
cnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvbmV4dDptYXN0ZXI6
M2JhZDhiYjVjZDMwNDhhNjdkZjQzYWM2YjFlMmYxOTFmMTlkOWZmMDpiaXNlY3QtbGludXg2
CgoyMDE0LTA3LTA0LTA3OjI3OjQ2IDNiYWQ4YmI1Y2QzMDQ4YTY3ZGY0M2FjNmIxZTJmMTkx
ZjE5ZDlmZjAgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMv
YnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLTNiYWQ4YmI1Y2QzMDQ4
YTY3ZGY0M2FjNmIxZTJmMTkxZjE5ZDlmZjAKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVs
L2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi8zYmFkOGJiNWNkMzA0OGE2N2RmNDNhYzZi
MWUyZjE5MWYxOWQ5ZmYwCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0
cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItM2JhZDhiYjVjZDMw
NDhhNjdkZjQzYWM2YjFlMmYxOTFmMTlkOWZmMAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9m
IC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvamFrZXRvd24tY29uc3VtZXIvaTM4Ni1yYW5k
Y29uZmlnLXgwLTA3MDIxMzAyLTNiYWQ4YmI1Y2QzMDQ4YTY3ZGY0M2FjNmIxZTJmMTkxZjE5
ZDlmZjAKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi8zYmFk
OGJiNWNkMzA0OGE2N2RmNDNhYzZiMWUyZjE5MWYxOWQ5ZmYwL3ZtbGludXotMy4xMy4wLXJj
MS0wMDIxNi1nM2JhZDhiYgoKMjAxNC0wNy0wNC0wODoxMDo0NiBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAuLi4uLi4uLi4uLi4uCTYJMTEgVEVTVCBGQUlMVVJFClsgICAgOC44MDM2ODhdIGlu
aXQ6IEZhaWxlZCB0byBjcmVhdGUgcHR5IC0gZGlzYWJsaW5nIGxvZ2dpbmcgZm9yIGpvYgpL
ZXJuZWwgdGVzdHM6IEJvb3QgT0shClsgICAxOS42OTQxMDNdID09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09ClsgICAxOS42OTUwMDRdIEJVRyBrbWFsbG9jLTUxMiAoTm90IHRhaW50ZWQpOiBP
YmplY3QgcGFkZGluZyBvdmVyd3JpdHRlbgpbICAgMTkuNjk1MDA0XSAtLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLQpbICAgMTkuNjk1MDA0XSAKWyAgIDE5LjY5NTAwNF0gSU5GTzogMHhkMzQ0
YWY0OC0weGQzNDRhZjRiLiBGaXJzdCBieXRlIDB4MSBpbnN0ZWFkIG9mIDB4NWEKWyAgIDE5
LjY5NTAwNF0gSU5GTzogQWxsb2NhdGVkIGluIHNrX3Byb3RfYWxsb2MuaXNyYS4zOSsweDUz
LzB4ZDAgYWdlPTExOTcgY3B1PTAgcGlkPTI5MApbICAgMTkuNjk1MDA0XSBJTkZPOiBTbGFi
IDB4ZDI3OTM5NDAgb2JqZWN0cz0xNCB1c2VkPTIgZnA9MHhkMzQ0YjE4MCBmbGFncz0weDQw
MDA0MDgwClsgICAxOS42OTUwMDRdIElORk86IE9iamVjdCAweGQzNDRhZDIwIEBvZmZzZXQ9
MzM2MCBmcD0weGQzNDRhZjUwClsgICAxOS42OTUwMDRdIApbICAgMTkuNjk1MDA0XSBCeXRl
cyBiNCBkMzQ0YWQxMDogMjIgMDEgMDAgMDAgMGUgYjkgZmIgZmYgNWEgNWEgNWEgNWEgNWEg
NWEgNWEgNWEgICIuLi4uLi4uWlpaWlpaWloKWyAgIDE5LjY5NTAwNF0gT2JqZWN0IGQzNDRh
ZDIwOiAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAg
Li4uLi4uLi4uLi4uLi4uLgova2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi8z
YmFkOGJiNWNkMzA0OGE2N2RmNDNhYzZiMWUyZjE5MWYxOWQ5ZmYwL2RtZXNnLXF1YW50YWwt
aXZiNDEtMTIzOjIwMTQwNzA0MDgxMTM5OmkzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMjo6
CjExOjE6MSBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwoKQmlzZWN0aW5nOiAxMTU5MSBy
ZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTQgc3RlcHMpClsw
NDlmZmE4YWIzM2E2M2IzYmZmNjcyZDFhMGVlNmEzNWFkMjUzZmU4XSBNZXJnZSBicmFuY2gg
J2RybS1uZXh0JyBvZiBnaXQ6Ly9wZW9wbGUuZnJlZWRlc2t0b3Aub3JnL35haXJsaWVkL2xp
bnV4CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5z
aCAvYy9ib290LWJpc2VjdC9saW51eDYvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3Rz
L3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL25leHQ6bWFzdGVy
OjA0OWZmYThhYjMzYTYzYjNiZmY2NzJkMWEwZWU2YTM1YWQyNTNmZTg6YmlzZWN0LWxpbnV4
NgoKMjAxNC0wNy0wNC0wODoxODoyMCAwNDlmZmE4YWIzM2E2M2IzYmZmNjcyZDFhMGVlNmEz
NWFkMjUzZmU4IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3Rz
L2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi0wNDlmZmE4YWIzM2E2
M2IzYmZmNjcyZDFhMGVlNmEzNWFkMjUzZmU4CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5l
bC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvMDQ5ZmZhOGFiMzNhNjNiM2JmZjY3MmQx
YTBlZTZhMzVhZDI1M2ZlOAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVz
dHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLTA0OWZmYThhYjMz
YTYzYjNiZmY2NzJkMWEwZWU2YTM1YWQyNTNmZTgKd2FpdGluZyBmb3IgY29tcGxldGlvbiBv
ZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2pha2V0b3duLWNvbnN1bWVyL2kzODYtcmFu
ZGNvbmZpZy14MC0wNzAyMTMwMi0wNDlmZmE4YWIzM2E2M2IzYmZmNjcyZDFhMGVlNmEzNWFk
MjUzZmU4Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvMDQ5
ZmZhOGFiMzNhNjNiM2JmZjY3MmQxYTBlZTZhMzVhZDI1M2ZlOC92bWxpbnV6LTMuMTIuMC0w
OTA0Ny1nMDQ5ZmZhOAoKMjAxNC0wNy0wNC0wOToxNzoyMCBkZXRlY3RpbmcgYm9vdCBzdGF0
ZSAuLi4uLi4uLi4uLi4uLi4uLi4JMSBURVNUIEZBSUxVUkUKWyAgICA5LjA0ODU3M10gaW5p
dDogRmFpbGVkIHRvIGNyZWF0ZSBwdHkgLSBkaXNhYmxpbmcgbG9nZ2luZyBmb3Igam9iCktl
cm5lbCB0ZXN0czogQm9vdCBPSyEKWyAgIDIwLjQ5MzEwNV0gPT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT0KWyAgIDIwLjQ5NDAwNV0gQlVHIGttYWxsb2MtNTEyIChOb3QgdGFpbnRlZCk6IE9i
amVjdCBwYWRkaW5nIG92ZXJ3cml0dGVuClsgICAyMC40OTQwMDVdIC0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tClsgICAyMC40OTQwMDVdIApbICAgMjAuNDk0MDA1XSBJTkZPOiAweGQzYmVh
ZDE4LTB4ZDNiZWFkMWIuIEZpcnN0IGJ5dGUgMHgxIGluc3RlYWQgb2YgMHg1YQpbICAgMjAu
NDk0MDA1XSBJTkZPOiBBbGxvY2F0ZWQgaW4gc2tfcHJvdF9hbGxvYy5pc3JhLjM5KzB4NTMv
MHhkMCBhZ2U9MTM1OSBjcHU9MCBwaWQ9MjkzClsgICAyMC40OTQwMDVdIElORk86IFNsYWIg
MHhkMjdhMmQ0MCBvYmplY3RzPTE0IHVzZWQ9NyBmcD0weGQzYmViNWUwIGZsYWdzPTB4NDAw
MDQwODAKWyAgIDIwLjQ5NDAwNV0gSU5GTzogT2JqZWN0IDB4ZDNiZWFhZjAgQG9mZnNldD0y
ODAwIGZwPTB4ZDNiZWEwMDAKWyAgIDIwLjQ5NDAwNV0gClsgICAyMC40OTQwMDVdIEJ5dGVz
IGI0IGQzYmVhYWUwOiAyNSAwMSAwMCAwMCAyZCBiYyBmYiBmZiA1YSA1YSA1YSA1YSA1YSA1
YSA1YSA1YSAgJS4uLi0uLi5aWlpaWlpaWgpbICAgMjAuNDk0MDA1XSBPYmplY3QgZDNiZWFh
ZjA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwICAu
Li4uLi4uLi4uLi4uLi4uCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzA0
OWZmYThhYjMzYTYzYjNiZmY2NzJkMWEwZWU2YTM1YWQyNTNmZTgvZG1lc2ctcXVhbnRhbC1p
dmI0MS0xMDA6MjAxNDA3MDQwOTIxMzU6aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyOjoK
MToxOjEgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCkJpc2VjdGluZzogOTU3OSByZXZp
c2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTQgc3RlcHMpCls3ZTIz
OGEyZWNkMTE3ZTE2YjE1NGUxYjBlZDc3OTA2NTk2NjAwZmY1XSBNZXJnZSB0YWcgJ2h3bW9u
LWZvci1saW51cycgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJu
ZWwvZ2l0L2dyb2Vjay9saW51eC1zdGFnaW5nCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jp
c2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDYvb2JqLWJp
c2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmln
LXgwLTA3MDIxMzAyL25leHQ6bWFzdGVyOjdlMjM4YTJlY2QxMTdlMTZiMTU0ZTFiMGVkNzc5
MDY1OTY2MDBmZjU6YmlzZWN0LWxpbnV4NgoKMjAxNC0wNy0wNC0wOToyODowNSA3ZTIzOGEy
ZWNkMTE3ZTE2YjE1NGUxYjBlZDc3OTA2NTk2NjAwZmY1IGNvbXBpbGluZwpRdWV1ZWQgYnVp
bGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14
MC0wNzAyMTMwMi03ZTIzOGEyZWNkMTE3ZTE2YjE1NGUxYjBlZDc3OTA2NTk2NjAwZmY1CkNo
ZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIv
N2UyMzhhMmVjZDExN2UxNmIxNTRlMWIwZWQ3NzkwNjU5NjYwMGZmNQp3YWl0aW5nIGZvciBj
b21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmln
LXgwLTA3MDIxMzAyLTdlMjM4YTJlY2QxMTdlMTZiMTU0ZTFiMGVkNzc5MDY1OTY2MDBmZjUK
d2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2ph
a2V0b3duLWNvbnN1bWVyL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi03ZTIzOGEyZWNk
MTE3ZTE2YjE1NGUxYjBlZDc3OTA2NTk2NjAwZmY1Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJh
bmRjb25maWcteDAtMDcwMjEzMDIvN2UyMzhhMmVjZDExN2UxNmIxNTRlMWIwZWQ3NzkwNjU5
NjYwMGZmNS92bWxpbnV6LTMuMTIuMC0wMzcxNC1nN2UyMzhhMgoKMjAxNC0wNy0wNC0wOTo0
MDowNSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgkx
CTcJMTMJMTkJMjQJMjguLgkyOQkzMQkzMy4uLi4uCTM0CTQwCTQ1CTUxCTU2CTYyCTY4CTc0
CTc5CTg1CTkwCTk2CTEwMgkxMDcJMTEzCTExOAkxMjQJMTMwCTEzMwkxMzkJMTQ0CTE0OQkx
NTUJMTYxCTE2NgkxNzIJMTc3CTE4MgkxODgJMTk0CTE5OQkyMDUJMjEwCTIxNgkyMjEJMjI3
CTIzMi4JMjM3CTI0MwkyNDYgU1VDQ0VTUwoKQmlzZWN0aW5nOiA1ODQwIHJldmlzaW9ucyBs
ZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMyBzdGVwcykKWzA5MTBjMGJkZjdj
MjkxYTQxYmMyMWU0MGE5NzM4OWM5ZDRjMTk2MGRdIE1lcmdlIGJyYW5jaCAnZm9yLTMuMTMv
Y29yZScgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5kay9saW51eC1ibG9jawpydW5uaW5nIC9jL2tl
cm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3Qv
bGludXg2L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kz
ODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9uZXh0Om1hc3RlcjowOTEwYzBiZGY3YzI5MWE0
MWJjMjFlNDBhOTczODljOWQ0YzE5NjBkOmJpc2VjdC1saW51eDYKCjIwMTQtMDctMDQtMTA6
MjI6MDUgMDkxMGMwYmRmN2MyOTFhNDFiYzIxZTQwYTk3Mzg5YzlkNGMxOTYwZCBjb21waWxp
bmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2
LXJhbmRjb25maWcteDAtMDcwMjEzMDItMDkxMGMwYmRmN2MyOTFhNDFiYzIxZTQwYTk3Mzg5
YzlkNGMxOTYwZApDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LXgwLTA3MDIxMzAyLzA5MTBjMGJkZjdjMjkxYTQxYmMyMWU0MGE5NzM4OWM5ZDRjMTk2MGQK
d2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kz
ODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi0wOTEwYzBiZGY3YzI5MWE0MWJjMjFlNDBhOTcz
ODljOWQ0YzE5NjBkCnRpbWVvdXQKUmV0cnkgYnVpbGQgLi4Kd2FpdGluZyBmb3IgY29tcGxl
dGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0w
NzAyMTMwMi0wOTEwYzBiZGY3YzI5MWE0MWJjMjFlNDBhOTczODljOWQ0YzE5NjBkCnRpbWVv
dXQKG1sxOzM1bTIwMTQtMDctMDQgMTY6MjQ6MDcgS2VybmVsIGJ1aWxkIGZhaWwgb3IgdGlt
ZW91dBtbMG0KMjAxNC0wNy0wNC0xNjoyNDowNyAwOTEwYzBiZGY3YzI5MWE0MWJjMjFlNDBh
OTczODljOWQ0YzE5NjBkIFNLSVAgQlJPS0VOIEJVSUxECkNoZWNrIC9rYnVpbGQtdGVzdHMv
YnVpbGQtc2VydmVkL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi0wOTEwYzBiZGY3YzI5
MWE0MWJjMjFlNDBhOTczODljOWQ0YzE5NjBkCkJpc2VjdGluZzogNTg0MCByZXZpc2lvbnMg
bGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTMgc3RlcHMpCltlZGE2NzBjNjI2
YTRmNTNlYjhhYzVmMjBkOGMxMGQzZjBiNTRjNTgzXSBNZXJnZSB0YWcgJ3N0YWJsZS9mb3It
bGludXMtMy4xMy1yYzAtdGFnJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xp
bnV4L2tlcm5lbC9naXQveGVuL3RpcApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3Qt
dGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXg2L29iai1iaXNlY3QK
bHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy14MC0w
NzAyMTMwMi9uZXh0Om1hc3RlcjplZGE2NzBjNjI2YTRmNTNlYjhhYzVmMjBkOGMxMGQzZjBi
NTRjNTgzOmJpc2VjdC1saW51eDYKCjIwMTQtMDctMDQtMTY6MjQ6MTkgZWRhNjcwYzYyNmE0
ZjUzZWI4YWM1ZjIwZDhjMTBkM2YwYjU0YzU4MyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRh
c2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcw
MjEzMDItZWRhNjcwYzYyNmE0ZjUzZWI4YWM1ZjIwZDhjMTBkM2YwYjU0YzU4MwpDaGVjayBm
b3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL2VkYTY3
MGM2MjZhNGY1M2ViOGFjNWYyMGQ4YzEwZDNmMGI1NGM1ODMKd2FpdGluZyBmb3IgY29tcGxl
dGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0w
NzAyMTMwMi1lZGE2NzBjNjI2YTRmNTNlYjhhYzVmMjBkOGMxMGQzZjBiNTRjNTgzCnRpbWVv
dXQKUmV0cnkgYnVpbGQgLi4Kd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRl
c3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi1lZGE2NzBjNjI2
YTRmNTNlYjhhYzVmMjBkOGMxMGQzZjBiNTRjNTgzCnRpbWVvdXQKG1sxOzM1bTIwMTQtMDct
MDQgMjI6MjY6MjAgS2VybmVsIGJ1aWxkIGZhaWwgb3IgdGltZW91dBtbMG0KMjAxNC0wNy0w
NC0yMjoyNjoyMCBlZGE2NzBjNjI2YTRmNTNlYjhhYzVmMjBkOGMxMGQzZjBiNTRjNTgzIFNL
SVAgQlJPS0VOIEJVSUxECkNoZWNrIC9rYnVpbGQtdGVzdHMvYnVpbGQtc2VydmVkL2kzODYt
cmFuZGNvbmZpZy14MC0wNzAyMTMwMi1lZGE2NzBjNjI2YTRmNTNlYjhhYzVmMjBkOGMxMGQz
ZjBiNTRjNTgzCkJpc2VjdGluZzogNTg0MCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVy
IHRoaXMgKHJvdWdobHkgMTMgc3RlcHMpCls1NDk2MDhlYWRiMzFlYWM1ZDU3OWVkNzBhMjFh
YzcyMmJkZjcyODYxXSBNZXJnZSBicmFuY2ggJ25leHQnIG9mIGdpdDovL2dpdC5rZXJuZWwu
b3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9yemhhbmcvbGludXgKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0
L2xpbnV4Ni9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9p
Mzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvbmV4dDptYXN0ZXI6NTQ5NjA4ZWFkYjMxZWFj
NWQ1NzllZDcwYTIxYWM3MjJiZGY3Mjg2MTpiaXNlY3QtbGludXg2CgoyMDE0LTA3LTA0LTIy
OjI2OjI1IDU0OTYwOGVhZGIzMWVhYzVkNTc5ZWQ3MGEyMWFjNzIyYmRmNzI4NjEgY29tcGls
aW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4
Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLTU0OTYwOGVhZGIzMWVhYzVkNTc5ZWQ3MGEyMWFj
NzIyYmRmNzI4NjEKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZp
Zy14MC0wNzAyMTMwMi81NDk2MDhlYWRiMzFlYWM1ZDU3OWVkNzBhMjFhYzcyMmJkZjcyODYx
CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9p
Mzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItNTQ5NjA4ZWFkYjMxZWFjNWQ1NzllZDcwYTIx
YWM3MjJiZGY3Mjg2MQp0aW1lb3V0ClJldHJ5IGJ1aWxkIC4uCndhaXRpbmcgZm9yIGNvbXBs
ZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAt
MDcwMjEzMDItNTQ5NjA4ZWFkYjMxZWFjNWQ1NzllZDcwYTIxYWM3MjJiZGY3Mjg2MQp0aW1l
b3V0ChtbMTszNW0yMDE0LTA3LTA1IDA0OjI4OjI3IEtlcm5lbCBidWlsZCBmYWlsIG9yIHRp
bWVvdXQbWzBtCjIwMTQtMDctMDUtMDQ6Mjg6MjcgNTQ5NjA4ZWFkYjMxZWFjNWQ1NzllZDcw
YTIxYWM3MjJiZGY3Mjg2MSBTS0lQIEJST0tFTiBCVUlMRApDaGVjayAva2J1aWxkLXRlc3Rz
L2J1aWxkLXNlcnZlZC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItNTQ5NjA4ZWFkYjMx
ZWFjNWQ1NzllZDcwYTIxYWM3MjJiZGY3Mjg2MQpCaXNlY3Rpbmc6IDU4NDAgcmV2aXNpb25z
IGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEzIHN0ZXBzKQpbZjkzMDBlYWFh
YzFjYTMwMDA4M2FkNDE5Mzc5MjNhOTBjYzNhMjM5NF0gTWVyZ2UgdGFnICdwbSthY3BpLTMu
MTMtcmMxJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9n
aXQvcmFmYWVsL2xpbnV4LXBtCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0
LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDYvb2JqLWJpc2VjdApscyAt
YSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIx
MzAyL25leHQ6bWFzdGVyOmY5MzAwZWFhYWMxY2EzMDAwODNhZDQxOTM3OTIzYTkwY2MzYTIz
OTQ6YmlzZWN0LWxpbnV4NgoKMjAxNC0wNy0wNS0wNDoyODozMSBmOTMwMGVhYWFjMWNhMzAw
MDgzYWQ0MTkzNzkyM2E5MGNjM2EyMzk0IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0
byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMw
Mi1mOTMwMGVhYWFjMWNhMzAwMDgzYWQ0MTkzNzkyM2E5MGNjM2EyMzk0CkNoZWNrIGZvciBr
ZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvZjkzMDBlYWFh
YzFjYTMwMDA4M2FkNDE5Mzc5MjNhOTBjYzNhMjM5NAp3YWl0aW5nIGZvciBjb21wbGV0aW9u
IG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIx
MzAyLWY5MzAwZWFhYWMxY2EzMDAwODNhZDQxOTM3OTIzYTkwY2MzYTIzOTQKdGltZW91dApS
ZXRyeSBidWlsZCAuLgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMv
YnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLWY5MzAwZWFhYWMxY2Ez
MDAwODNhZDQxOTM3OTIzYTkwY2MzYTIzOTQKdGltZW91dAobWzE7MzVtMjAxNC0wNy0wNSAx
MDozMDozMiBLZXJuZWwgYnVpbGQgZmFpbCBvciB0aW1lb3V0G1swbQoyMDE0LTA3LTA1LTEw
OjMwOjMyIGY5MzAwZWFhYWMxY2EzMDAwODNhZDQxOTM3OTIzYTkwY2MzYTIzOTQgU0tJUCBC
Uk9LRU4gQlVJTEQKQ2hlY2sgL2tidWlsZC10ZXN0cy9idWlsZC1zZXJ2ZWQvaTM4Ni1yYW5k
Y29uZmlnLXgwLTA3MDIxMzAyLWY5MzAwZWFhYWMxY2EzMDAwODNhZDQxOTM3OTIzYTkwY2Mz
YTIzOTQKQmlzZWN0aW5nOiA1ODQwIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhp
cyAocm91Z2hseSAxMyBzdGVwcykKW2M2ZDY1YmYyNDZmYmJhNmU5MDQyYTM1YWJhMDUwZDJh
OTJmMzk1MDVdIE1lcmdlIHRhZyAncmVndWxhdG9yLXYzLjEzJyBvZiBnaXQ6Ly9naXQua2Vy
bmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvYnJvb25pZS9yZWd1bGF0b3IKcnVu
bmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jv
b3QtYmlzZWN0L2xpbnV4Ni9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1
ZXVlL2t2bS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvbmV4dDptYXN0ZXI6YzZkNjVi
ZjI0NmZiYmE2ZTkwNDJhMzVhYmEwNTBkMmE5MmYzOTUwNTpiaXNlY3QtbGludXg2CgoyMDE0
LTA3LTA1LTEwOjMwOjQwIGM2ZDY1YmYyNDZmYmJhNmU5MDQyYTM1YWJhMDUwZDJhOTJmMzk1
MDUgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQt
cXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLWM2ZDY1YmYyNDZmYmJhNmU5MDQy
YTM1YWJhMDUwZDJhOTJmMzk1MDUKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYt
cmFuZGNvbmZpZy14MC0wNzAyMTMwMi9jNmQ2NWJmMjQ2ZmJiYTZlOTA0MmEzNWFiYTA1MGQy
YTkyZjM5NTA1CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWls
ZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItYzZkNjViZjI0NmZiYmE2ZTkw
NDJhMzVhYmEwNTBkMmE5MmYzOTUwNQp0aW1lb3V0ClJldHJ5IGJ1aWxkIC4uCndhaXRpbmcg
Zm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRj
b25maWcteDAtMDcwMjEzMDItYzZkNjViZjI0NmZiYmE2ZTkwNDJhMzVhYmEwNTBkMmE5MmYz
OTUwNQp0aW1lb3V0ChtbMTszNW0yMDE0LTA3LTA1IDE2OjMyOjQwIEtlcm5lbCBidWlsZCBm
YWlsIG9yIHRpbWVvdXQbWzBtCjIwMTQtMDctMDUtMTY6MzI6NDAgYzZkNjViZjI0NmZiYmE2
ZTkwNDJhMzVhYmEwNTBkMmE5MmYzOTUwNSBTS0lQIEJST0tFTiBCVUlMRApDaGVjayAva2J1
aWxkLXRlc3RzL2J1aWxkLXNlcnZlZC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItYzZk
NjViZjI0NmZiYmE2ZTkwNDJhMzVhYmEwNTBkMmE5MmYzOTUwNQpCaXNlY3Rpbmc6IDU4NDAg
cmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEzIHN0ZXBzKQpb
YTMwMTI0NTM5YjI2NDFjNWIzNTUxMTkzYWY3ZDIxYTZmYzYxYmE5OF0gTWVyZ2UgYnJhbmNo
ICdmb3JfbGludXMnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2Vy
bmVsL2dpdC9qYWNrL2xpbnV4LWZzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10
ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDYvb2JqLWJpc2VjdAps
cyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyL25leHQ6bWFzdGVyOmEzMDEyNDUzOWIyNjQxYzViMzU1MTE5M2FmN2QyMWE2ZmM2
MWJhOTg6YmlzZWN0LWxpbnV4NgoKMjAxNC0wNy0wNS0xNjozMjo0MiBhMzAxMjQ1MzliMjY0
MWM1YjM1NTExOTNhZjdkMjFhNmZjNjFiYTk4IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFz
ayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAy
MTMwMi1hMzAxMjQ1MzliMjY0MWM1YjM1NTExOTNhZjdkMjFhNmZjNjFiYTk4CkNoZWNrIGZv
ciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvYTMwMTI0
NTM5YjI2NDFjNWIzNTUxMTkzYWY3ZDIxYTZmYzYxYmE5OAp3YWl0aW5nIGZvciBjb21wbGV0
aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyLWEzMDEyNDUzOWIyNjQxYzViMzU1MTE5M2FmN2QyMWE2ZmM2MWJhOTgKdGltZW91
dApSZXRyeSBidWlsZCAuLgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVz
dHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLWEzMDEyNDUzOWIy
NjQxYzViMzU1MTE5M2FmN2QyMWE2ZmM2MWJhOTgKd2FpdGluZyBmb3IgY29tcGxldGlvbiBv
ZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2pha2V0b3duLWNvbnN1bWVyL2kzODYtcmFu
ZGNvbmZpZy14MC0wNzAyMTMwMi1hMzAxMjQ1MzliMjY0MWM1YjM1NTExOTNhZjdkMjFhNmZj
NjFiYTk4Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvYTMw
MTI0NTM5YjI2NDFjNWIzNTUxMTkzYWY3ZDIxYTZmYzYxYmE5OC92bWxpbnV6LTMuMTIuMC0w
NDkyMC1nYTMwMTI0NQoKMjAxNC0wNy0wNS0yMDoyNDo0MiBkZXRlY3RpbmcgYm9vdCBzdGF0
ZSAuCTIJNwk5CTE3CTI5CTMzCTM4CTQ1CTU2CTc0CTkyCTExMAkxMjIJMTQ2CTE2NQkxNzkJ
MTk5CTIxOAkyNDQJMjQ2IFNVQ0NFU1MKCkJpc2VjdGluZzogNDY1OSByZXZpc2lvbnMgbGVm
dCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTMgc3RlcHMpCls0MmEyZDkyM2NjMzQ5
NTgzZWJmNmZkZDUyYTdkMzVlMWMyZjdlNmJkXSBNZXJnZSBnaXQ6Ly9naXQua2VybmVsLm9y
Zy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvZGF2ZW0vbmV0LW5leHQKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0
L2xpbnV4Ni9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9p
Mzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvbmV4dDptYXN0ZXI6NDJhMmQ5MjNjYzM0OTU4
M2ViZjZmZGQ1MmE3ZDM1ZTFjMmY3ZTZiZDpiaXNlY3QtbGludXg2CgoyMDE0LTA3LTA1LTIw
OjM1OjE3IDQyYTJkOTIzY2MzNDk1ODNlYmY2ZmRkNTJhN2QzNWUxYzJmN2U2YmQgY29tcGls
aW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4
Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLTQyYTJkOTIzY2MzNDk1ODNlYmY2ZmRkNTJhN2Qz
NWUxYzJmN2U2YmQKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZp
Zy14MC0wNzAyMTMwMi80MmEyZDkyM2NjMzQ5NTgzZWJmNmZkZDUyYTdkMzVlMWMyZjdlNmJk
CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9p
Mzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItNDJhMmQ5MjNjYzM0OTU4M2ViZjZmZGQ1MmE3
ZDM1ZTFjMmY3ZTZiZAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMv
YnVpbGQtcXVldWUvamFrZXRvd24tY29uc3VtZXIvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIx
MzAyLTQyYTJkOTIzY2MzNDk1ODNlYmY2ZmRkNTJhN2QzNWUxYzJmN2U2YmQKa2VybmVsOiAv
a2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi80MmEyZDkyM2NjMzQ5NTgzZWJm
NmZkZDUyYTdkMzVlMWMyZjdlNmJkL3ZtbGludXotMy4xMi4wLTA3MDMzLWc0MmEyZDkyCgoy
MDE0LTA3LTA1LTIyOjExOjE3IGRldGVjdGluZyBib290IHN0YXRlIC4gVEVTVCBGQUlMVVJF
ClsgICAgOC42MzMyNjZdIGluaXQ6IEZhaWxlZCB0byBjcmVhdGUgcHR5IC0gZGlzYWJsaW5n
IGxvZ2dpbmcgZm9yIGpvYgpLZXJuZWwgdGVzdHM6IEJvb3QgT0shClsgICAxOC42MzU3NjNd
ID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09ClsgICAxOC42MzYwMDZdIEJVRyBrbWFsbG9jLTUx
MiAoTm90IHRhaW50ZWQpOiBPYmplY3QgcGFkZGluZyBvdmVyd3JpdHRlbgpbICAgMTguNjM2
MDA2XSAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpbICAgMTguNjM2MDA2XSAKWyAgIDE4LjYz
NjAwNl0gSU5GTzogMHhkMzJmODIyOC0weGQzMmY4MjJiLiBGaXJzdCBieXRlIDB4MSBpbnN0
ZWFkIG9mIDB4NWEKWyAgIDE4LjYzNjAwNl0gSU5GTzogQWxsb2NhdGVkIGluIHNrX3Byb3Rf
YWxsb2MuaXNyYS4zOSsweDUzLzB4ZDAgYWdlPTE5NSBjcHU9MCBwaWQ9MjkwClsgICAxOC42
MzYwMDZdIElORk86IFNsYWIgMHhkMjc5MGYwMCBvYmplY3RzPTE0IHVzZWQ9MTQgZnA9MHgg
IChudWxsKSBmbGFncz0weDQwMDA0MDgwClsgICAxOC42MzYwMDZdIElORk86IE9iamVjdCAw
eGQzMmY4MDAwIEBvZmZzZXQ9MCBmcD0weGQzMmY4MjMwClsgICAxOC42MzYwMDZdIApbICAg
MTguNjM2MDA2XSBPYmplY3QgZDMyZjgwMDA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAw
IDAwIDAwIDAwIDAwIDAwIDAwIDAwICAuLi4uLi4uLi4uLi4uLi4uClsgICAxOC42MzYwMDZd
IE9iamVjdCBkMzJmODAxMDogMTggMDAgMTAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAg
MDAgMDAgMDAgMDAgIC4uLi4uLi4uLi4uLi4uLi4KL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
eDAtMDcwMjEzMDIvNDJhMmQ5MjNjYzM0OTU4M2ViZjZmZGQ1MmE3ZDM1ZTFjMmY3ZTZiZC9k
bWVzZy1xdWFudGFsLWxrcC1zYngwNC0xMDc6MjAxNDA3MDUyMjExNDc6aTM4Ni1yYW5kY29u
ZmlnLXgwLTA3MDIxMzAyOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIv
NDJhMmQ5MjNjYzM0OTU4M2ViZjZmZGQ1MmE3ZDM1ZTFjMmY3ZTZiZC9kbWVzZy1xdWFudGFs
LWl2YjQyLTY3OjIwMTQwNzA1MjIxMTAxOmkzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMjo6
CjA6MjoyIGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzCgpCaXNlY3Rpbmc6IDIxMTMgcmV2
aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEyIHN0ZXBzKQpbMzky
MjJjODJmNzM4MTkwYTRmMDliZTg5NTEwYTgzMzZhNzNiNjdjOF0gTWVyZ2UgdGFnICd1cHN0
cmVhbS0zLjEzLXJjMScgb2YgZ2l0Oi8vZ2l0LmluZnJhZGVhZC5vcmcvbGludXgtdWJpCnJ1
bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9i
b290LWJpc2VjdC9saW51eDYvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1x
dWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL25leHQ6bWFzdGVyOjM5MjIy
YzgyZjczODE5MGE0ZjA5YmU4OTUxMGE4MzM2YTczYjY3Yzg6YmlzZWN0LWxpbnV4NgoKMjAx
NC0wNy0wNS0yMjoxMTo1MCAzOTIyMmM4MmY3MzgxOTBhNGYwOWJlODk1MTBhODMzNmE3M2I2
N2M4IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxk
LXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi0zOTIyMmM4MmY3MzgxOTBhNGYw
OWJlODk1MTBhODMzNmE3M2I2N2M4CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2
LXJhbmRjb25maWcteDAtMDcwMjEzMDIvMzkyMjJjODJmNzM4MTkwYTRmMDliZTg5NTEwYTgz
MzZhNzNiNjdjOAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVp
bGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLTM5MjIyYzgyZjczODE5MGE0
ZjA5YmU4OTUxMGE4MzM2YTczYjY3YzgKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1
aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2pha2V0b3duLWNvbnN1bWVyL2kzODYtcmFuZGNvbmZp
Zy14MC0wNzAyMTMwMi0zOTIyMmM4MmY3MzgxOTBhNGYwOWJlODk1MTBhODMzNmE3M2I2N2M4
Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvMzkyMjJjODJm
NzM4MTkwYTRmMDliZTg5NTEwYTgzMzZhNzNiNjdjOC92bWxpbnV6LTMuMTIuMC0wNDk0Ny1n
MzkyMjJjOAoKMjAxNC0wNy0wNS0yMjozNDo1MCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgkx
MQkxNAkyMAkzMwkzOQk1Mgk3MQk4MAkxMDEJMTIwCTEzMAkxNTYJMTcyCTE4NQkyMTUJMjMy
CTI0NiBTVUNDRVNTCgpCaXNlY3Rpbmc6IDIwODYgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBh
ZnRlciB0aGlzIChyb3VnaGx5IDEyIHN0ZXBzKQpbOWJjOWNjZDdkYjFjOWYwNDNmNzUzODBi
NWE1Yjk0OTEyMDQ2YTYwZV0gTWVyZ2UgYnJhbmNoICdmb3ItbGludXMnIG9mIGdpdDovL2dp
dC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC92aXJvL3ZmcwpydW5uaW5n
IC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1i
aXNlY3QvbGludXg2L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUv
a3ZtL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9uZXh0Om1hc3Rlcjo5YmM5Y2NkN2Ri
MWM5ZjA0M2Y3NTM4MGI1YTViOTQ5MTIwNDZhNjBlOmJpc2VjdC1saW51eDYKCjIwMTQtMDct
MDUtMjI6NDQ6MjEgOWJjOWNjZDdkYjFjOWYwNDNmNzUzODBiNWE1Yjk0OTEyMDQ2YTYwZSBj
b21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1
ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItOWJjOWNjZDdkYjFjOWYwNDNmNzUzODBi
NWE1Yjk0OTEyMDQ2YTYwZQpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLXgwLTA3MDIxMzAyLzliYzljY2Q3ZGIxYzlmMDQzZjc1MzgwYjVhNWI5NDkxMjA0
NmE2MGUKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1
ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi05YmM5Y2NkN2RiMWM5ZjA0M2Y3NTM4
MGI1YTViOTQ5MTIwNDZhNjBlCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS9qYWtldG93bi1jb25zdW1lci9pMzg2LXJhbmRjb25maWcteDAt
MDcwMjEzMDItOWJjOWNjZDdkYjFjOWYwNDNmNzUzODBiNWE1Yjk0OTEyMDQ2YTYwZQprZXJu
ZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzliYzljY2Q3ZGIxYzlm
MDQzZjc1MzgwYjVhNWI5NDkxMjA0NmE2MGUvdm1saW51ei0zLjEyLjAtMDUwNTEtZzliYzlj
Y2QKCjIwMTQtMDctMDUtMjI6NTU6MjEgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLgkxCTIyCTUz
CTEwOQkxNjcJMjM3CTI0NiBTVUNDRVNTCgpCaXNlY3Rpbmc6IDE5ODIgcmV2aXNpb25zIGxl
ZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDExIHN0ZXBzKQpbNWNiYjNkMjE2ZTIw
NDE3MDAyMzFiY2ZjMzgzZWU1ZjhiN2ZjOGI3NF0gTWVyZ2UgYnJhbmNoICdha3BtJyAocGF0
Y2hlcyBmcm9tIEFuZHJldyBNb3J0b24pCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDYvb2JqLWJpc2Vj
dApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgw
LTA3MDIxMzAyL25leHQ6bWFzdGVyOjVjYmIzZDIxNmUyMDQxNzAwMjMxYmNmYzM4M2VlNWY4
YjdmYzhiNzQ6YmlzZWN0LWxpbnV4NgoKMjAxNC0wNy0wNS0yMjo1OToyMiA1Y2JiM2QyMTZl
MjA0MTcwMDIzMWJjZmMzODNlZTVmOGI3ZmM4Yjc0IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQg
dGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0w
NzAyMTMwMi01Y2JiM2QyMTZlMjA0MTcwMDIzMWJjZmMzODNlZTVmOGI3ZmM4Yjc0CkNoZWNr
IGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvNWNi
YjNkMjE2ZTIwNDE3MDAyMzFiY2ZjMzgzZWU1ZjhiN2ZjOGI3NAp3YWl0aW5nIGZvciBjb21w
bGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgw
LTA3MDIxMzAyLTVjYmIzZDIxNmUyMDQxNzAwMjMxYmNmYzM4M2VlNWY4YjdmYzhiNzQKd2Fp
dGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2pha2V0
b3duLWNvbnN1bWVyL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi01Y2JiM2QyMTZlMjA0
MTcwMDIzMWJjZmMzODNlZTVmOGI3ZmM4Yjc0Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRj
b25maWcteDAtMDcwMjEzMDIvNWNiYjNkMjE2ZTIwNDE3MDAyMzFiY2ZjMzgzZWU1ZjhiN2Zj
OGI3NC92bWxpbnV6LTMuMTIuMC0wNTMyMS1nNWNiYjNkMgoKMjAxNC0wNy0wNS0yMzoxOToy
MiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgkzCTUJOAkxNQkyMQkyOQkzOAk0Nwk2MQk3OAkx
MDIJMTM2CTE3MQkxOTYJMjMyCTI0NiBTVUNDRVNTCgpsaW5lYXItYmlzZWN0OiBiYWQgYnJh
bmNoIG1heSBiZSBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9n
aXQvZGF2ZW0vbmV0LW5leHQKbGluZWFyLWJpc2VjdDogaGFuZGxlIG92ZXIgdG8gZ2l0IGJp
c2VjdApsaW5lYXItYmlzZWN0OiBnaXQgYmlzZWN0IHN0YXJ0IDQyYTJkOTIzY2MzNDk1ODNl
YmY2ZmRkNTJhN2QzNWUxYzJmN2U2YmQgNWNiYjNkMjE2ZTIwNDE3MDAyMzFiY2ZjMzgzZWU1
ZjhiN2ZjOGI3NCAtLQpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyA1Y2JiM2QyLi4uIE1l
cmdlIGJyYW5jaCAnYWtwbScgKHBhdGNoZXMgZnJvbSBBbmRyZXcgTW9ydG9uKQpIRUFEIGlz
IG5vdyBhdCAxZWE1MmE5Li4uIE1lcmdlICdqYmFybmVzL2FzeW5jLWZiLXByb2JlJyBpbnRv
IGRldmVsLWhvdXJseS0yMDE0MDYwMjEwCkJpc2VjdGluZzogODU1IHJldmlzaW9ucyBsZWZ0
IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMCBzdGVwcykKWzdmOGNiYjIzZjU5OGEw
N2Y5ZGU3Y2E2NmFiODZkNzcyZjA4ODc2YjNdIG5ldDogc3RtbWFjOiByZW1vdmUgdW5uZWNl
c3NhcnkgcGNpX3NldF9kcnZkYXRhKCkKbGluZWFyLWJpc2VjdDogZ2l0IGJpc2VjdCBydW4g
L2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJp
c2VjdC9saW51eDYvb2JqLWJpc2VjdApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3Qt
dGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXg2L29iai1iaXNlY3QK
bHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy14MC0w
NzAyMTMwMi9uZXh0Om1hc3Rlcjo3ZjhjYmIyM2Y1OThhMDdmOWRlN2NhNjZhYjg2ZDc3MmYw
ODg3NmIzOmJpc2VjdC1saW51eDYKCjIwMTQtMDctMDUtMjM6MzE6MTYgN2Y4Y2JiMjNmNTk4
YTA3ZjlkZTdjYTY2YWI4NmQ3NzJmMDg4NzZiMyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRh
c2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcw
MjEzMDItN2Y4Y2JiMjNmNTk4YTA3ZjlkZTdjYTY2YWI4NmQ3NzJmMDg4NzZiMwpDaGVjayBm
b3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzdmOGNi
YjIzZjU5OGEwN2Y5ZGU3Y2E2NmFiODZkNzcyZjA4ODc2YjMKd2FpdGluZyBmb3IgY29tcGxl
dGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0w
NzAyMTMwMi03ZjhjYmIyM2Y1OThhMDdmOWRlN2NhNjZhYjg2ZDc3MmYwODg3NmIzCndhaXRp
bmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9qYWtldG93
bi1jb25zdW1lci9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItN2Y4Y2JiMjNmNTk4YTA3
ZjlkZTdjYTY2YWI4NmQ3NzJmMDg4NzZiMwprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLXgwLTA3MDIxMzAyLzdmOGNiYjIzZjU5OGEwN2Y5ZGU3Y2E2NmFiODZkNzcyZjA4ODc2
YjMvdm1saW51ei0zLjEyLjAtcmMzLTAxMTEyLWc3ZjhjYmIyCgoyMDE0LTA3LTA1LTIzOjUy
OjE2IGRldGVjdGluZyBib290IHN0YXRlIC4JNwkxMgkyNSBURVNUIEZBSUxVUkUKWyAgICA5
LjI1NzE1OV0gaW5pdDogRmFpbGVkIHRvIGNyZWF0ZSBwdHkgLSBkaXNhYmxpbmcgbG9nZ2lu
ZyBmb3Igam9iCktlcm5lbCB0ZXN0czogQm9vdCBPSyEKWyAgIDE5LjM4OTM5Nl0gPT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT0KWyAgIDE5LjM5MDAwN10gQlVHIGttYWxsb2MtNTEyIChOb3Qg
dGFpbnRlZCk6IE9iamVjdCBwYWRkaW5nIG92ZXJ3cml0dGVuClsgICAxOS4zOTAwMDddIC0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tClsgICAxOS4zOTAwMDddIApbICAgMTkuMzkwMDA3XSBJ
TkZPOiAweGQzYmJmNWQ4LTB4ZDNiYmY1ZGIuIEZpcnN0IGJ5dGUgMHgxIGluc3RlYWQgb2Yg
MHg1YQpbICAgMTkuMzkwMDA3XSBJTkZPOiBBbGxvY2F0ZWQgaW4gc2tfcHJvdF9hbGxvYy5p
c3JhLjM5KzB4NTMvMHhkMCBhZ2U9NDg4IGNwdT0wIHBpZD0yOTAKWyAgIDE5LjM5MDAwN10g
SU5GTzogU2xhYiAweGQyN2EyN2MwIG9iamVjdHM9MTQgdXNlZD01IGZwPTB4ZDNiYmU4YzAg
ZmxhZ3M9MHg0MDAwNDA4MApbICAgMTkuMzkwMDA3XSBJTkZPOiBPYmplY3QgMHhkM2JiZjNi
MCBAb2Zmc2V0PTUwNDAgZnA9MHhkM2JiZjE4MApbICAgMTkuMzkwMDA3XSAKWyAgIDE5LjM5
MDAwN10gQnl0ZXMgYjQgZDNiYmYzYTA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDVhIDVh
IDVhIDVhIDVhIDVhIDVhIDVhICAuLi4uLi4uLlpaWlpaWlpaClsgICAxOS4zOTAwMDddIE9i
amVjdCBkM2JiZjNiMDogMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAg
MDAgMDAgMDAgIC4uLi4uLi4uLi4uLi4uLi4KL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAt
MDcwMjEzMDIvN2Y4Y2JiMjNmNTk4YTA3ZjlkZTdjYTY2YWI4NmQ3NzJmMDg4NzZiMy9kbWVz
Zy1xdWFudGFsLWl2YjQyLTE6MjAxNDA3MDUyMzUzMTY6aTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvN2Y4Y2JiMjNm
NTk4YTA3ZjlkZTdjYTY2YWI4NmQ3NzJmMDg4NzZiMy9kbWVzZy1xdWFudGFsLWl2YjQyLTg0
OjIwMTQwNzA1MjM1MzIyOmkzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMjo6CjI1OjI6MiBh
bGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwoKQmlzZWN0aW5nOiAzMjUgcmV2aXNpb25zIGxl
ZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDkgc3RlcHMpCls3MDA5ZGVhYjE5ZDdi
ZTAzZTA1ZjY3Y2VhYzU2Y2ZkZmM3M2FhNzFjXSBNZXJnZSBnaXQ6Ly9naXQua2VybmVsLm9y
Zy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvbGludmlsbGUvd2lyZWxlc3MtbmV4dApydW5u
aW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9v
dC1iaXNlY3QvbGludXg2L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVl
dWUva3ZtL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9uZXh0Om1hc3Rlcjo3MDA5ZGVh
YjE5ZDdiZTAzZTA1ZjY3Y2VhYzU2Y2ZkZmM3M2FhNzFjOmJpc2VjdC1saW51eDYKCjIwMTQt
MDctMDUtMjM6NTQ6MTggNzAwOWRlYWIxOWQ3YmUwM2UwNWY2N2NlYWM1NmNmZGZjNzNhYTcx
YyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1x
dWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItNzAwOWRlYWIxOWQ3YmUwM2UwNWY2
N2NlYWM1NmNmZGZjNzNhYTcxYwpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLXgwLTA3MDIxMzAyLzcwMDlkZWFiMTlkN2JlMDNlMDVmNjdjZWFjNTZjZmRm
YzczYWE3MWMKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxk
LXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi03MDA5ZGVhYjE5ZDdiZTAzZTA1
ZjY3Y2VhYzU2Y2ZkZmM3M2FhNzFjChtbMTszNW0yMDE0LTA3LTA1IDIzOjU4OjE4IEtlcm5l
bCBidWlsZCBmYWlsIG9yIHRpbWVvdXQbWzBtCjIwMTQtMDctMDUtMjM6NTg6MTggNzAwOWRl
YWIxOWQ3YmUwM2UwNWY2N2NlYWM1NmNmZGZjNzNhYTcxYyBTS0lQIEJST0tFTiBCVUlMRApD
aGVjayAva2J1aWxkLXRlc3RzL2J1aWxkLXNlcnZlZC9pMzg2LXJhbmRjb25maWcteDAtMDcw
MjEzMDItNzAwOWRlYWIxOWQ3YmUwM2UwNWY2N2NlYWM1NmNmZGZjNzNhYTcxYwpCaXNlY3Rp
bmc6IDMyNSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgOSBz
dGVwcykKW2Q0MTIwMGFkNWZjNmMyODNjOGMzNzVmNTJlNGY4Njk5YzBlZWVjNjFdIHJ0bHdp
Zmk6IHJ0bDgxODhlZTogQ29udmVydCBkcml2ZXIgdG8gdXNlIG5ldyBydGxfcGh5X3NjYW5f
b3BlcmF0aW9uX2JhY2t1cCgpIHJvdXRpbmUKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlz
ZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4Ni9vYmotYmlz
ZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWct
eDAtMDcwMjEzMDIvbmV4dDptYXN0ZXI6ZDQxMjAwYWQ1ZmM2YzI4M2M4YzM3NWY1MmU0Zjg2
OTljMGVlZWM2MTpiaXNlY3QtbGludXg2CgoyMDE0LTA3LTA1LTIzOjU4OjIwIGQ0MTIwMGFk
NWZjNmMyODNjOGMzNzVmNTJlNGY4Njk5YzBlZWVjNjEgY29tcGlsaW5nClF1ZXVlZCBidWls
ZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgw
LTA3MDIxMzAyLWQ0MTIwMGFkNWZjNmMyODNjOGMzNzVmNTJlNGY4Njk5YzBlZWVjNjEKQ2hl
Y2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9k
NDEyMDBhZDVmYzZjMjgzYzhjMzc1ZjUyZTRmODY5OWMwZWVlYzYxCndhaXRpbmcgZm9yIGNv
bXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWct
eDAtMDcwMjEzMDItZDQxMjAwYWQ1ZmM2YzI4M2M4YzM3NWY1MmU0Zjg2OTljMGVlZWM2MQp3
YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvamFr
ZXRvd24tY29uc3VtZXIvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLWQ0MTIwMGFkNWZj
NmMyODNjOGMzNzVmNTJlNGY4Njk5YzBlZWVjNjEKa2VybmVsOiAva2VybmVsL2kzODYtcmFu
ZGNvbmZpZy14MC0wNzAyMTMwMi9kNDEyMDBhZDVmYzZjMjgzYzhjMzc1ZjUyZTRmODY5OWMw
ZWVlYzYxL3ZtbGludXotMy4xMi4wLXJjMS0wMDQ1OS1nZDQxMjAwYQoKMjAxNC0wNy0wNi0w
MDowMjoyMCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgkyCTE0CTMzCTQ5CTgxCTEzNgkxODYJ
MjQwCTI0NiBTVUNDRVNTCgpCaXNlY3Rpbmc6IDMxMiByZXZpc2lvbnMgbGVmdCB0byB0ZXN0
IGFmdGVyIHRoaXMgKHJvdWdobHkgOCBzdGVwcykKW2UxYWY1ZTQ0NWVmODU4MmU4ZjY5MGZh
ZGNkNjM3OTdkYjFlNjI2NjNdIGNncm91cDogbmV0cHJpbzogcmVtb3ZlIHVubmVjZXNzYXJ5
IHRhc2tfbmV0cHJpb2lkeApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1i
b290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXg2L29iai1iaXNlY3QKbHMgLWEg
L2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMw
Mi9uZXh0Om1hc3RlcjplMWFmNWU0NDVlZjg1ODJlOGY2OTBmYWRjZDYzNzk3ZGIxZTYyNjYz
OmJpc2VjdC1saW51eDYKCjIwMTQtMDctMDYtMDA6MDc6NTMgZTFhZjVlNDQ1ZWY4NTgyZThm
NjkwZmFkY2Q2Mzc5N2RiMWU2MjY2MyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8g
L2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIt
ZTFhZjVlNDQ1ZWY4NTgyZThmNjkwZmFkY2Q2Mzc5N2RiMWU2MjY2MwpDaGVjayBmb3Iga2Vy
bmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL2UxYWY1ZTQ0NWVm
ODU4MmU4ZjY5MGZhZGNkNjM3OTdkYjFlNjI2NjMKd2FpdGluZyBmb3IgY29tcGxldGlvbiBv
ZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMw
Mi1lMWFmNWU0NDVlZjg1ODJlOGY2OTBmYWRjZDYzNzk3ZGIxZTYyNjYzCmtlcm5lbDogL2tl
cm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvZTFhZjVlNDQ1ZWY4NTgyZThmNjkw
ZmFkY2Q2Mzc5N2RiMWU2MjY2My92bWxpbnV6LTMuMTIuMC1yYzMtMDA3MjktZ2UxYWY1ZTQK
CjIwMTQtMDctMDYtMDA6MTA6NTMgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLgkyMgk0Mwk5NAkx
NDMJMTc0CTE4NQkyMDIJMjQ2IFNVQ0NFU1MKCkJpc2VjdGluZzogMTQ0IHJldmlzaW9ucyBs
ZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA3IHN0ZXBzKQpbNWNkYTczYjY4ZWJm
N2UwODU4NmQ2MWU2Nzc3ZTY0ZTEyZGYyM2YwN10gTWVyZ2UgYnJhbmNoICdmb3ItZGF2ZW0n
IG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9saW52
aWxsZS93aXJlbGVzcy1uZXh0CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0
LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDYvb2JqLWJpc2VjdApscyAt
YSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIx
MzAyL25leHQ6bWFzdGVyOjVjZGE3M2I2OGViZjdlMDg1ODZkNjFlNjc3N2U2NGUxMmRmMjNm
MDc6YmlzZWN0LWxpbnV4NgoKMjAxNC0wNy0wNi0wMDozMDowMiA1Y2RhNzNiNjhlYmY3ZTA4
NTg2ZDYxZTY3NzdlNjRlMTJkZjIzZjA3IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0
byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMw
Mi01Y2RhNzNiNjhlYmY3ZTA4NTg2ZDYxZTY3NzdlNjRlMTJkZjIzZjA3CkNoZWNrIGZvciBr
ZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvNWNkYTczYjY4
ZWJmN2UwODU4NmQ2MWU2Nzc3ZTY0ZTEyZGYyM2YwNwp3YWl0aW5nIGZvciBjb21wbGV0aW9u
IG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIx
MzAyLTVjZGE3M2I2OGViZjdlMDg1ODZkNjFlNjc3N2U2NGUxMmRmMjNmMDcKd2FpdGluZyBm
b3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2pha2V0b3duLWNv
bnN1bWVyL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi01Y2RhNzNiNjhlYmY3ZTA4NTg2
ZDYxZTY3NzdlNjRlMTJkZjIzZjA3Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
eDAtMDcwMjEzMDIvNWNkYTczYjY4ZWJmN2UwODU4NmQ2MWU2Nzc3ZTY0ZTEyZGYyM2YwNy92
bWxpbnV6LTMuMTIuMC1yYzMtMDA5NjctZzVjZGE3M2IKCjIwMTQtMDctMDYtMDA6Mzk6MDIg
ZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLgk2CTEwCTE3IFRFU1QgRkFJTFVSRQpbICAgIDguNjY0
MjgxXSBpbml0OiBGYWlsZWQgdG8gY3JlYXRlIHB0eSAtIGRpc2FibGluZyBsb2dnaW5nIGZv
ciBqb2IKS2VybmVsIHRlc3RzOiBCb290IE9LIQpbICAgMTkuNTc0MDk0XSA9PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PQpbICAgMTkuNTc1MDA1XSBCVUcga21hbGxvYy01MTIgKE5vdCB0YWlu
dGVkKTogT2JqZWN0IHBhZGRpbmcgb3ZlcndyaXR0ZW4KWyAgIDE5LjU3NTAwNV0gLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0KWyAgIDE5LjU3NTAwNV0gClsgICAxOS41NzUwMDVdIElORk86
IDB4ZDNiY2JlOTgtMHhkM2JjYmU5Yi4gRmlyc3QgYnl0ZSAweDEgaW5zdGVhZCBvZiAweDVh
ClsgICAxOS41NzUwMDVdIElORk86IEFsbG9jYXRlZCBpbiBza19wcm90X2FsbG9jLmlzcmEu
MzkrMHg1My8weGQwIGFnZT0xMjIwIGNwdT0wIHBpZD0yOTAKWyAgIDE5LjU3NTAwNV0gSU5G
TzogU2xhYiAweGQyN2EyOTQwIG9iamVjdHM9MTQgdXNlZD0xMyBmcD0weGQzYmNhMDAwIGZs
YWdzPTB4NDAwMDQwODAKWyAgIDE5LjU3NTAwNV0gSU5GTzogT2JqZWN0IDB4ZDNiY2JjNzAg
QG9mZnNldD03MjgwIGZwPTB4ZDNiY2JhNDAKWyAgIDE5LjU3NTAwNV0gClsgICAxOS41NzUw
MDVdIEJ5dGVzIGI0IGQzYmNiYzYwOiAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCA1YSA1YSA1
YSA1YSA1YSA1YSA1YSA1YSAgLi4uLi4uLi5aWlpaWlpaWgpbICAgMTkuNTc1MDA1XSBPYmpl
Y3QgZDNiY2JjNzA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAw
IDAwIDAwICAuLi4uLi4uLi4uLi4uLi4uCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyLzVjZGE3M2I2OGViZjdlMDg1ODZkNjFlNjc3N2U2NGUxMmRmMjNmMDcvZG1lc2ct
cXVhbnRhbC1pdmI0Mi0xMjI6MjAxNDA3MDYwMDQwMTM6aTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyOjoKMTc6MToxIGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzCgpCaXNlY3Rpbmc6
IDc1IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA2IHN0ZXBz
KQpbZGEzM2VkY2NlYmNjMzZkMzg3NDIzZGNkYjU1NzA5NGZiZGE1NTk5NF0gTWVyZ2UgYnJh
bmNoICduZXQtbmV4dCcgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9r
ZXJuZWwvZ2l0L3BhYmxvL25mdGFibGVzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDYvb2JqLWJpc2Vj
dApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgw
LTA3MDIxMzAyL25leHQ6bWFzdGVyOmRhMzNlZGNjZWJjYzM2ZDM4NzQyM2RjZGI1NTcwOTRm
YmRhNTU5OTQ6YmlzZWN0LWxpbnV4NgoKMjAxNC0wNy0wNi0wMDo0MTowNCBkYTMzZWRjY2Vi
Y2MzNmQzODc0MjNkY2RiNTU3MDk0ZmJkYTU1OTk0IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQg
dGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0w
NzAyMTMwMi1kYTMzZWRjY2ViY2MzNmQzODc0MjNkY2RiNTU3MDk0ZmJkYTU1OTk0CkNoZWNr
IGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvZGEz
M2VkY2NlYmNjMzZkMzg3NDIzZGNkYjU1NzA5NGZiZGE1NTk5NAp3YWl0aW5nIGZvciBjb21w
bGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgw
LTA3MDIxMzAyLWRhMzNlZGNjZWJjYzM2ZDM4NzQyM2RjZGI1NTcwOTRmYmRhNTU5OTQKa2Vy
bmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9kYTMzZWRjY2ViY2Mz
NmQzODc0MjNkY2RiNTU3MDk0ZmJkYTU1OTk0L3ZtbGludXotMy4xMi4wLXJjMy0wMDg5MS1n
ZGEzM2VkYwoKMjAxNC0wNy0wNi0wMDo0NTowNCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLiBU
RVNUIEZBSUxVUkUKWyAgICA4Ljc0MzMxN10gaW5pdDogRmFpbGVkIHRvIGNyZWF0ZSBwdHkg
LSBkaXNhYmxpbmcgbG9nZ2luZyBmb3Igam9iCktlcm5lbCB0ZXN0czogQm9vdCBPSyEKWyAg
IDE5LjA3NzIzM10gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KWyAgIDE5LjA3ODAwNV0gQlVH
IGttYWxsb2MtNTEyIChOb3QgdGFpbnRlZCk6IE9iamVjdCBwYWRkaW5nIG92ZXJ3cml0dGVu
ClsgICAxOS4wNzgwMDVdIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tClsgICAxOS4wNzgwMDVd
IApbICAgMTkuMDc4MDA1XSBJTkZPOiAweGMwYjEwZDE4LTB4YzBiMTBkMWIuIEZpcnN0IGJ5
dGUgMHgxIGluc3RlYWQgb2YgMHg1YQpbICAgMTkuMDc4MDA1XSBJTkZPOiBBbGxvY2F0ZWQg
aW4gc2tfcHJvdF9hbGxvYy5pc3JhLjM5KzB4NTMvMHhkMCBhZ2U9Mjg1IGNwdT0wIHBpZD0y
OTMKWyAgIDE5LjA3ODAwNV0gSU5GTzogRnJlZWQgaW4gX19za19mcmVlKzB4ZjUvMHgxMDAg
YWdlPTMzMCBjcHU9MCBwaWQ9MjkwClsgICAxOS4wNzgwMDVdIElORk86IFNsYWIgMHhkMjU0
MTIwMCBvYmplY3RzPTE0IHVzZWQ9MTEgZnA9MHhjMGIxMGY1MCBmbGFncz0weDQwODAKWyAg
IDE5LjA3ODAwNV0gSU5GTzogT2JqZWN0IDB4YzBiMTBhZjAgQG9mZnNldD0yODAwIGZwPTB4
YzBiMTBkMjAKWyAgIDE5LjA3ODAwNV0gClsgICAxOS4wNzgwMDVdIEJ5dGVzIGI0IGMwYjEw
YWUwOiAwMiAwMSAwMCAwMCA0MSA4ZSBmYiBmZiA1YSA1YSA1YSA1YSA1YSA1YSA1YSA1YSAg
Li4uLkEuLi5aWlpaWlpaWgpbICAgMTkuMDc4MDA1XSBPYmplY3QgYzBiMTBhZjA6IDAwIDAw
IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwICAuLi4uLi4uLi4u
Li4uLi4uCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL2RhMzNlZGNjZWJj
YzM2ZDM4NzQyM2RjZGI1NTcwOTRmYmRhNTU5OTQvZG1lc2ctcXVhbnRhbC1pdmI0Mi03Nzoy
MDE0MDcwNjAwNDQ1NDppMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDI6OgowOjE6MSBhbGxf
Z29vZDpiYWQ6YWxsX2JhZCBib290cwoKQmlzZWN0aW5nOiA0MyByZXZpc2lvbnMgbGVmdCB0
byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNiBzdGVwcykKWzI5YjY3YzM5ZGM2ZTdlYzRm
ZGY3OGM2MjA2NzVkZTc2MTk3MWNkMjhdIE1lcmdlIHRhZyAnYmF0bWFuLWFkdi1mb3ItZGF2
ZW0nIG9mIGdpdDovL2dpdC5vcGVuLW1lc2gub3JnL2xpbnV4LW1lcmdlCnJ1bm5pbmcgL2Mv
a2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2Vj
dC9saW51eDYvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0v
aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL25leHQ6bWFzdGVyOjI5YjY3YzM5ZGM2ZTdl
YzRmZGY3OGM2MjA2NzVkZTc2MTk3MWNkMjg6YmlzZWN0LWxpbnV4NgoKMjAxNC0wNy0wNi0w
MDo0NjowNiAyOWI2N2MzOWRjNmU3ZWM0ZmRmNzhjNjIwNjc1ZGU3NjE5NzFjZDI4IGNvbXBp
bGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kz
ODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi0yOWI2N2MzOWRjNmU3ZWM0ZmRmNzhjNjIwNjc1
ZGU3NjE5NzFjZDI4CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWcteDAtMDcwMjEzMDIvMjliNjdjMzlkYzZlN2VjNGZkZjc4YzYyMDY3NWRlNzYxOTcxY2Qy
OAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUv
aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLTI5YjY3YzM5ZGM2ZTdlYzRmZGY3OGM2MjA2
NzVkZTc2MTk3MWNkMjgKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAy
MTMwMi8yOWI2N2MzOWRjNmU3ZWM0ZmRmNzhjNjIwNjc1ZGU3NjE5NzFjZDI4L3ZtbGludXot
My4xMi4wLXJjMy0wMDg0Ny1nMjliNjdjMwoKMjAxNC0wNy0wNi0wMDo1MDowNiBkZXRlY3Rp
bmcgYm9vdCBzdGF0ZSAuIFRFU1QgRkFJTFVSRQpbICAgIDguNzYwNzI5XSBpbml0OiBGYWls
ZWQgdG8gY3JlYXRlIHB0eSAtIGRpc2FibGluZyBsb2dnaW5nIGZvciBqb2IKS2VybmVsIHRl
c3RzOiBCb290IE9LIQpbICAgMTkuNTQxNjYzXSA9PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQpb
ICAgMTkuNTQyMDA4XSBCVUcga21hbGxvYy01MTIgKE5vdCB0YWludGVkKTogT2JqZWN0IHBh
ZGRpbmcgb3ZlcndyaXR0ZW4KWyAgIDE5LjU0MjAwOF0gLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0KWyAgIDE5LjU0MjAwOF0gClsgICAxOS41NDIwMDhdIElORk86IDB4ZDMwNGQxN2MtMHhk
MzA0ZDE3ZC4gRmlyc3QgYnl0ZSAweDEgaW5zdGVhZCBvZiAweDVhClsgICAxOS41NDIwMDhd
IElORk86IEFsbG9jYXRlZCBpbiBza19wcm90X2FsbG9jLmlzcmEuMzkrMHg1My8weGQwIGFn
ZT00NTYgY3B1PTAgcGlkPTI5MgpbICAgMTkuNTQyMDA4XSBJTkZPOiBTbGFiIDB4ZDI3OGI5
ODAgb2JqZWN0cz0xNCB1c2VkPTEgZnA9MHhkMzA0Y2QyMCBmbGFncz0weDQwMDA0MDgwClsg
ICAxOS41NDIwMDhdIElORk86IE9iamVjdCAweGQzMDRjZjUwIEBvZmZzZXQ9MzkyMCBmcD0w
eCAgKG51bGwpClsgICAxOS41NDIwMDhdIApbICAgMTkuNTQyMDA4XSBCeXRlcyBiNCBkMzA0
Y2Y0MDogMjQgMDEgMDAgMDAgNzUgYjggZmIgZmYgNWEgNWEgNWEgNWEgNWEgNWEgNWEgNWEg
ICQuLi51Li4uWlpaWlpaWloKWyAgIDE5LjU0MjAwOF0gT2JqZWN0IGQzMDRjZjUwOiAwMCAw
MCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAgLi4uLi4uLi4u
Li4uLi4uLgova2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi8yOWI2N2MzOWRj
NmU3ZWM0ZmRmNzhjNjIwNjc1ZGU3NjE5NzFjZDI4L2RtZXNnLXF1YW50YWwtaXZiNDEtMjA6
MjAxNDA3MDYwMDQ5NDU6aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyOjoKMDoxOjEgYWxs
X2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCkJpc2VjdGluZzogMjMgcmV2aXNpb25zIGxlZnQg
dG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDUgc3RlcHMpClsxOGM2OGQ1OTYwYzhkZmVi
MmRiMTEzZjRiODcxYmFiMjU5Y2ZkNTY1XSBiYXRtYW4tYWR2OiByZW9yZGVyIGJhdGFkdl9p
dl9mbGFncwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1
cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXg2L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10
ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9uZXh0Om1h
c3RlcjoxOGM2OGQ1OTYwYzhkZmViMmRiMTEzZjRiODcxYmFiMjU5Y2ZkNTY1OmJpc2VjdC1s
aW51eDYKCjIwMTQtMDctMDYtMDA6NTA6MzcgMThjNjhkNTk2MGM4ZGZlYjJkYjExM2Y0Yjg3
MWJhYjI1OWNmZDU2NSBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItMThjNjhkNTk2
MGM4ZGZlYjJkYjExM2Y0Yjg3MWJhYjI1OWNmZDU2NQpDaGVjayBmb3Iga2VybmVsIGluIC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzE4YzY4ZDU5NjBjOGRmZWIyZGIx
MTNmNGI4NzFiYWIyNTljZmQ1NjUKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxk
LXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi0xOGM2OGQ1
OTYwYzhkZmViMmRiMTEzZjRiODcxYmFiMjU5Y2ZkNTY1Cmtlcm5lbDogL2tlcm5lbC9pMzg2
LXJhbmRjb25maWcteDAtMDcwMjEzMDIvMThjNjhkNTk2MGM4ZGZlYjJkYjExM2Y0Yjg3MWJh
YjI1OWNmZDU2NS92bWxpbnV6LTMuMTIuMC1yYzMtMDA4MjMtZzE4YzY4ZDUKCjIwMTQtMDct
MDYtMDA6NTQ6MzcgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLiBURVNUIEZBSUxVUkUKWyAgICA4
LjQ0NzQ3N10gaW5pdDogRmFpbGVkIHRvIGNyZWF0ZSBwdHkgLSBkaXNhYmxpbmcgbG9nZ2lu
ZyBmb3Igam9iCktlcm5lbCB0ZXN0czogQm9vdCBPSyEKWyAgIDE4LjQzMzkzMl0gPT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT0KWyAgIDE4LjQzNDAwNl0gQlVHIGttYWxsb2MtNTEyIChOb3Qg
dGFpbnRlZCk6IE9iamVjdCBwYWRkaW5nIG92ZXJ3cml0dGVuClsgICAxOC40MzQwMDZdIC0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tClsgICAxOC40MzQwMDZdIApbICAgMTguNDM0MDA2XSBJ
TkZPOiAweGMwYWFmNWQ4LTB4YzBhYWY1ZGIuIEZpcnN0IGJ5dGUgMHgxIGluc3RlYWQgb2Yg
MHg1YQpbICAgMTguNDM0MDA2XSBJTkZPOiBBbGxvY2F0ZWQgaW4gc2tfcHJvdF9hbGxvYy5p
c3JhLjM5KzB4NTMvMHhkMCBhZ2U9MjgwIGNwdT0wIHBpZD0yOTAKWyAgIDE4LjQzNDAwNl0g
SU5GTzogRnJlZWQgaW4gc2tiX2ZyZWVfaGVhZCsweDM1LzB4NDAgYWdlPTEwMDAxIGNwdT0w
IHBpZD0yNTgKWyAgIDE4LjQzNDAwNl0gSU5GTzogU2xhYiAweGQyNTQwNWMwIG9iamVjdHM9
MTQgdXNlZD01IGZwPTB4YzBhYWVkMjAgZmxhZ3M9MHg0MDgwClsgICAxOC40MzQwMDZdIElO
Rk86IE9iamVjdCAweGMwYWFmM2IwIEBvZmZzZXQ9NTA0MCBmcD0weCAgKG51bGwpClsgICAx
OC40MzQwMDZdIApbICAgMTguNDM0MDA2XSBCeXRlcyBiNCBjMGFhZjNhMDogOGIgMDAgMDAg
MDAgZmUgOGIgZmIgZmYgNWEgNWEgNWEgNWEgNWEgNWEgNWEgNWEgIC4uLi4uLi4uWlpaWlpa
WloKWyAgIDE4LjQzNDAwNl0gT2JqZWN0IGMwYWFmM2IwOiAwMCAwMCAwMCAwMCAwMCAwMCAw
MCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCAgLi4uLi4uLi4uLi4uLi4uLgova2VybmVs
L2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi8xOGM2OGQ1OTYwYzhkZmViMmRiMTEzZjRi
ODcxYmFiMjU5Y2ZkNTY1L2RtZXNnLXF1YW50YWwtaXZiNDEtMjg6MjAxNDA3MDYwMDU0MDM6
aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyOjoKMDoxOjEgYWxsX2dvb2Q6YmFkOmFsbF9i
YWQgYm9vdHMKCkJpc2VjdGluZzogMTEgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0
aGlzIChyb3VnaGx5IDQgc3RlcHMpCls0MTQyNTRlMzQyYTBkNTgxNDRkZTQwYzNkYTc3NzUy
MWViYWVlYjA3XSBiYXRtYW4tYWR2OiB0dmx2IC0gZ2F0ZXdheSBkb3dubG9hZC91cGxvYWQg
YmFuZHdpZHRoIGNvbnRhaW5lcgpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVz
dC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXg2L29iai1iaXNlY3QKbHMg
LWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy14MC0wNzAy
MTMwMi9uZXh0Om1hc3Rlcjo0MTQyNTRlMzQyYTBkNTgxNDRkZTQwYzNkYTc3NzUyMWViYWVl
YjA3OmJpc2VjdC1saW51eDYKCjIwMTQtMDctMDYtMDA6NTU6MDggNDE0MjU0ZTM0MmEwZDU4
MTQ0ZGU0MGMzZGE3Nzc1MjFlYmFlZWIwNyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sg
dG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEz
MDItNDE0MjU0ZTM0MmEwZDU4MTQ0ZGU0MGMzZGE3Nzc1MjFlYmFlZWIwNwpDaGVjayBmb3Ig
a2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzQxNDI1NGUz
NDJhMGQ1ODE0NGRlNDBjM2RhNzc3NTIxZWJhZWViMDcKd2FpdGluZyBmb3IgY29tcGxldGlv
biBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAy
MTMwMi00MTQyNTRlMzQyYTBkNTgxNDRkZTQwYzNkYTc3NzUyMWViYWVlYjA3CndhaXRpbmcg
Zm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9qYWtldG93bi1j
b25zdW1lci9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItNDE0MjU0ZTM0MmEwZDU4MTQ0
ZGU0MGMzZGE3Nzc1MjFlYmFlZWIwNwprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LXgwLTA3MDIxMzAyLzQxNDI1NGUzNDJhMGQ1ODE0NGRlNDBjM2RhNzc3NTIxZWJhZWViMDcv
dm1saW51ei0zLjEyLjAtcmMzLTAwODExLWc0MTQyNTRlCgoyMDE0LTA3LTA2LTAxOjAxOjA5
IGRldGVjdGluZyBib290IHN0YXRlIC4uIFRFU1QgRkFJTFVSRQpbICAgIDguNDIzOTMyXSBp
bml0OiBGYWlsZWQgdG8gY3JlYXRlIHB0eSAtIGRpc2FibGluZyBsb2dnaW5nIGZvciBqb2IK
S2VybmVsIHRlc3RzOiBCb290IE9LIQpbICAgMTguNjAwNDI1XSA9PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PQpbICAgMTguNjAxMDExXSBCVUcga21hbGxvYy01MTIgKE5vdCB0YWludGVkKTog
UG9pc29uIG92ZXJ3cml0dGVuClsgICAxOC42MDEwMTFdIC0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tClsgICAxOC42MDEwMTFdIApbICAgMTguNjAxMDExXSBJTkZPOiAweGQzNGFhNDYyLTB4
ZDM0YWE0NjQuIEZpcnN0IGJ5dGUgMHgxIGluc3RlYWQgb2YgMHg2YgpbICAgMTguNjAxMDEx
XSBJTkZPOiBTbGFiIDB4ZDI3OTQ1NDAgb2JqZWN0cz0xNCB1c2VkPTE0IGZwPTB4ICAobnVs
bCkgZmxhZ3M9MHg0MDAwNDA4MApbICAgMTguNjAxMDExXSBJTkZPOiBPYmplY3QgMHhkMzRh
YTQ2MCBAb2Zmc2V0PTExMjAgZnA9MHhkMzRhYTY5MApbICAgMTguNjAxMDExXSAKWyAgIDE4
LjYwMTAxMV0gQnl0ZXMgYjQgZDM0YWE0NTA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDVh
IDVhIDVhIDVhIDVhIDVhIDVhIDVhICAuLi4uLi4uLlpaWlpaWlpaClsgICAxOC42MDEwMTFd
IE9iamVjdCBkMzRhYTQ2MDogNmIgNmIgMDEgMGEgNmYgNmIgNmIgNmIgNmIgNmIgNmIgNmIg
NmIgNmIgNmIgNmIgIGtrLi5va2tra2tra2tra2sKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
eDAtMDcwMjEzMDIvNDE0MjU0ZTM0MmEwZDU4MTQ0ZGU0MGMzZGE3Nzc1MjFlYmFlZWIwNy9k
bWVzZy1xdWFudGFsLWl2YjQxLTExNzoyMDE0MDcwNjAxMDEwNzppMzg2LXJhbmRjb25maWct
eDAtMDcwMjEzMDI6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi80MTQy
NTRlMzQyYTBkNTgxNDRkZTQwYzNkYTc3NzUyMWViYWVlYjA3L2RtZXNnLXF1YW50YWwtaXZi
NDEtMjc6MjAxNDA3MDYwMTAxMTU6aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyOjoKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvNDE0MjU0ZTM0MmEwZDU4MTQ0ZGU0
MGMzZGE3Nzc1MjFlYmFlZWIwNy9kbWVzZy1xdWFudGFsLWl2YjQyLTEyMzoyMDE0MDcwNjAx
MDEyMjppMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDI6OgowOjM6MyBhbGxfZ29vZDpiYWQ6
YWxsX2JhZCBib290cwoKQmlzZWN0aW5nOiA1IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0
ZXIgdGhpcyAocm91Z2hseSAzIHN0ZXBzKQpbZjY5YjkyM2E3NThmNTk4ZmQ2YmI2OWU1NzU2
NGI1OTUwNmY0ZjFmY10gdWRwOiBmaXggYSB0eXBvIGluIF9fdWRwNF9saWJfbWNhc3RfZGVt
dXhfbG9va3VwCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFp
bHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDYvb2JqLWJpc2VjdApscyAtYSAva2J1aWxk
LXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL25leHQ6
bWFzdGVyOmY2OWI5MjNhNzU4ZjU5OGZkNmJiNjllNTc1NjRiNTk1MDZmNGYxZmM6YmlzZWN0
LWxpbnV4NgoKMjAxNC0wNy0wNi0wMTowMjoxMCBmNjliOTIzYTc1OGY1OThmZDZiYjY5ZTU3
NTY0YjU5NTA2ZjRmMWZjIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxk
LXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi1mNjliOTIz
YTc1OGY1OThmZDZiYjY5ZTU3NTY0YjU5NTA2ZjRmMWZjCkNoZWNrIGZvciBrZXJuZWwgaW4g
L2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvZjY5YjkyM2E3NThmNTk4ZmQ2
YmI2OWU1NzU2NGI1OTUwNmY0ZjFmYwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVp
bGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLWY2OWI5
MjNhNzU4ZjU5OGZkNmJiNjllNTc1NjRiNTk1MDZmNGYxZmMKd2FpdGluZyBmb3IgY29tcGxl
dGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2pha2V0b3duLWNvbnN1bWVyL2kz
ODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi1mNjliOTIzYTc1OGY1OThmZDZiYjY5ZTU3NTY0
YjU5NTA2ZjRmMWZjCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEz
MDIvZjY5YjkyM2E3NThmNTk4ZmQ2YmI2OWU1NzU2NGI1OTUwNmY0ZjFmYy92bWxpbnV6LTMu
MTIuMC1yYzMtMDA4MDUtZ2Y2OWI5MjMKCjIwMTQtMDctMDYtMDE6NDE6MTEgZGV0ZWN0aW5n
IGJvb3Qgc3RhdGUgCTEuIFRFU1QgRkFJTFVSRQpbICAgIDguNDY1MDMxXSBpbml0OiBGYWls
ZWQgdG8gY3JlYXRlIHB0eSAtIGRpc2FibGluZyBsb2dnaW5nIGZvciBqb2IKS2VybmVsIHRl
c3RzOiBCb290IE9LIQpbICAgMTguNjU2NzU5XSA9PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQpb
ICAgMTguNjU2NzYxXSBCVUcga21hbGxvYy01MTIgKE5vdCB0YWludGVkKTogT2JqZWN0IHBh
ZGRpbmcgb3ZlcndyaXR0ZW4KWyAgIDE4LjY1Njc2Ml0gLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0KWyAgIDE4LjY1Njc2Ml0gClsgICAxOC42NTY3NjRdIElORk86IDB4ZDNiYTFjNjgtMHhk
M2JhMWM2Yi4gRmlyc3QgYnl0ZSAweDEgaW5zdGVhZCBvZiAweDVhClsgICAxOC42NTY3NzJd
IElORk86IEFsbG9jYXRlZCBpbiBza19wcm90X2FsbG9jLmlzcmEuMzkrMHg1My8weGQwIGFn
ZT0zODQgY3B1PTAgcGlkPTI5MApbICAgMTguNjU2NzczXSBJTkZPOiBTbGFiIDB4ZDI3YTI0
MDAgb2JqZWN0cz0xNCB1c2VkPTExIGZwPTB4ZDNiYTAyMzAgZmxhZ3M9MHg0MDAwNDA4MApb
ICAgMTguNjU2Nzc0XSBJTkZPOiBPYmplY3QgMHhkM2JhMWE0MCBAb2Zmc2V0PTY3MjAgZnA9
MHhkM2JhMTgxMApbICAgMTguNjU2Nzc0XSAKWyAgIDE4LjY1Njc3Nl0gQnl0ZXMgYjQgZDNi
YTFhMzA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDVhIDVhIDVhIDVhIDVhIDVhIDVhIDVh
ICAuLi4uLi4uLlpaWlpaWlpaClsgICAxOC42NTY3NzddIE9iamVjdCBkM2JhMWE0MDogMDAg
MDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgMDAgIC4uLi4uLi4u
Li4uLi4uLi4KL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvZjY5YjkyM2E3
NThmNTk4ZmQ2YmI2OWU1NzU2NGI1OTUwNmY0ZjFmYy9kbWVzZy1xdWFudGFsLWl2YjQyLTE5
OjIwMTQwNzA2MDE0MTE1OmkzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMjo6Ci9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL2Y2OWI5MjNhNzU4ZjU5OGZkNmJiNjllNTc1
NjRiNTk1MDZmNGYxZmMvZG1lc2ctcXVhbnRhbC1pdmI0Mi0yMDoyMDE0MDcwNjAxNDEwMjpp
Mzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDI6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy14
MC0wNzAyMTMwMi9mNjliOTIzYTc1OGY1OThmZDZiYjY5ZTU3NTY0YjU5NTA2ZjRmMWZjL2Rt
ZXNnLXF1YW50YWwtaXZiNDItNDk6MjAxNDA3MDYwMTQxMTc6aTM4Ni1yYW5kY29uZmlnLXgw
LTA3MDIxMzAyOjoKMDozOjQgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCkJpc2VjdGlu
ZzogMiByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMiBzdGVw
cykKWzUzYWY1M2FlODNmZTk2MGNlYjllZjc0Y2FjNzkxNWU5MDg4ZjQyNjZdIE1lcmdlIGdp
dDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9kYXZlbS9uZXQK
cnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9j
L2Jvb3QtYmlzZWN0L2xpbnV4Ni9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVu
LXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvbmV4dDptYXN0ZXI6NTNh
ZjUzYWU4M2ZlOTYwY2ViOWVmNzRjYWM3OTE1ZTkwODhmNDI2NjpiaXNlY3QtbGludXg2Cgoy
MDE0LTA3LTA2LTAxOjQyOjEyIDUzYWY1M2FlODNmZTk2MGNlYjllZjc0Y2FjNzkxNWU5MDg4
ZjQyNjYgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVp
bGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLTUzYWY1M2FlODNmZTk2MGNl
YjllZjc0Y2FjNzkxNWU5MDg4ZjQyNjYKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kz
ODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi81M2FmNTNhZTgzZmU5NjBjZWI5ZWY3NGNhYzc5
MTVlOTA4OGY0MjY2CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9i
dWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItNTNhZjUzYWU4M2ZlOTYw
Y2ViOWVmNzRjYWM3OTE1ZTkwODhmNDI2Ngp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9r
YnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvamFrZXRvd24tY29uc3VtZXIvaTM4Ni1yYW5kY29u
ZmlnLXgwLTA3MDIxMzAyLTUzYWY1M2FlODNmZTk2MGNlYjllZjc0Y2FjNzkxNWU5MDg4ZjQy
NjYKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi81M2FmNTNh
ZTgzZmU5NjBjZWI5ZWY3NGNhYzc5MTVlOTA4OGY0MjY2L3ZtbGludXotMy4xMi4wLXJjMy0w
MDgwMi1nNTNhZjUzYQoKMjAxNC0wNy0wNi0wMTo1OToxMiBkZXRlY3RpbmcgYm9vdCBzdGF0
ZSAuCTQJMTMJMjIJMjkJMzcJNDMJNTYJNjYJNzUJOTIJMTA2CTExOQkxMjkJMTM3CTE1Mgkx
NjUJMTY4CTE3NgkxODMJMTg1CTE5MQkxOTYJMjAyCTIwNgkyMTYJMjI0CTIzNAkyNDIJMjQ2
IFNVQ0NFU1MKCkJpc2VjdGluZzogMSByZXZpc2lvbiBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhp
cyAocm91Z2hseSAxIHN0ZXApClswNWRiYzdiNTk0ODFjYTg5MWJiY2ZlNjc5OWE1NjJkNDgx
NTlmYmY3XSB0Y3AvZGNjcDogcmVtb3ZlIHR3Y2hhaW4KcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4Ni9v
YmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRj
b25maWcteDAtMDcwMjEzMDIvbmV4dDptYXN0ZXI6MDVkYmM3YjU5NDgxY2E4OTFiYmNmZTY3
OTlhNTYyZDQ4MTU5ZmJmNzpiaXNlY3QtbGludXg2CgoyMDE0LTA3LTA2LTAyOjE0OjEzIDA1
ZGJjN2I1OTQ4MWNhODkxYmJjZmU2Nzk5YTU2MmQ0ODE1OWZiZjcgY29tcGlsaW5nClF1ZXVl
ZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29u
ZmlnLXgwLTA3MDIxMzAyLTA1ZGJjN2I1OTQ4MWNhODkxYmJjZmU2Nzk5YTU2MmQ0ODE1OWZi
ZjcKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAy
MTMwMi8wNWRiYzdiNTk0ODFjYTg5MWJiY2ZlNjc5OWE1NjJkNDgxNTlmYmY3CndhaXRpbmcg
Zm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRj
b25maWcteDAtMDcwMjEzMDItMDVkYmM3YjU5NDgxY2E4OTFiYmNmZTY3OTlhNTYyZDQ4MTU5
ZmJmNwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvamFrZXRvd24tY29uc3VtZXIvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLTA1ZGJj
N2I1OTQ4MWNhODkxYmJjZmU2Nzk5YTU2MmQ0ODE1OWZiZjcKa2VybmVsOiAva2VybmVsL2kz
ODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi8wNWRiYzdiNTk0ODFjYTg5MWJiY2ZlNjc5OWE1
NjJkNDgxNTlmYmY3L3ZtbGludXotMy4xMi4wLXJjMy0wMDgwMy1nMDVkYmM3YgoKMjAxNC0w
Ny0wNi0wMjoyMjoxMyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuCTcJMjkJNDYJNjYJODcJMTE2
CTE0NAkxNTkJMTk0CTIyMgkyNDYgU1VDQ0VTUwoKQmlzZWN0aW5nOiAwIHJldmlzaW9ucyBs
ZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAwIHN0ZXBzKQpbZWZlNDIwOGY0N2Y5
MDdiODZmNTI4Nzg4ZGE3MTFlOGFiOWRlYTQ0ZF0gaXB2NjogbWFrZSBsb29rdXBzIHNpbXBs
ZXIgYW5kIGZhc3RlcgpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290
LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXg2L29iai1iaXNlY3QKbHMgLWEgL2ti
dWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9u
ZXh0Om1hc3RlcjplZmU0MjA4ZjQ3ZjkwN2I4NmY1Mjg3ODhkYTcxMWU4YWI5ZGVhNDRkOmJp
c2VjdC1saW51eDYKCjIwMTQtMDctMDYtMDI6Mjg6MTMgZWZlNDIwOGY0N2Y5MDdiODZmNTI4
Nzg4ZGE3MTFlOGFiOWRlYTQ0ZCBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2ti
dWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItZWZl
NDIwOGY0N2Y5MDdiODZmNTI4Nzg4ZGE3MTFlOGFiOWRlYTQ0ZApDaGVjayBmb3Iga2VybmVs
IGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL2VmZTQyMDhmNDdmOTA3
Yjg2ZjUyODc4OGRhNzExZThhYjlkZWE0NGQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAv
a2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi1l
ZmU0MjA4ZjQ3ZjkwN2I4NmY1Mjg3ODhkYTcxMWU4YWI5ZGVhNDRkCndhaXRpbmcgZm9yIGNv
bXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9qYWtldG93bi1jb25zdW1l
ci9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItZWZlNDIwOGY0N2Y5MDdiODZmNTI4Nzg4
ZGE3MTFlOGFiOWRlYTQ0ZAprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyL2VmZTQyMDhmNDdmOTA3Yjg2ZjUyODc4OGRhNzExZThhYjlkZWE0NGQvdm1saW51
ei0zLjEyLjAtcmMzLTAwODA0LWdlZmU0MjA4CgoyMDE0LTA3LTA2LTAyOjM2OjEzIGRldGVj
dGluZyBib290IHN0YXRlIC4gVEVTVCBGQUlMVVJFClsgICAgOC40NjIzNDldIGluaXQ6IEZh
aWxlZCB0byBjcmVhdGUgcHR5IC0gZGlzYWJsaW5nIGxvZ2dpbmcgZm9yIGpvYgpLZXJuZWwg
dGVzdHM6IEJvb3QgT0shClsgICAxOC44MTk4OTddID09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
ClsgICAxOC44MjAwMDZdIEJVRyBrbWFsbG9jLTUxMiAoTm90IHRhaW50ZWQpOiBPYmplY3Qg
cGFkZGluZyBvdmVyd3JpdHRlbgpbICAgMTguODIwMDA2XSAtLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLQpbICAgMTguODIwMDA2XSAKWyAgIDE4LjgyMDAwNl0gSU5GTzogMHhjMGFhZTY4OC0w
eGMwYWFlNjhiLiBGaXJzdCBieXRlIDB4MSBpbnN0ZWFkIG9mIDB4NWEKWyAgIDE4LjgyMDAw
Nl0gSU5GTzogQWxsb2NhdGVkIGluIHNrX3Byb3RfYWxsb2MuaXNyYS4zOSsweDUzLzB4ZDAg
YWdlPTI0NyBjcHU9MCBwaWQ9MjkzClsgICAxOC44MjAwMDZdIElORk86IEZyZWVkIGluIF9f
c2tfZnJlZSsweGY1LzB4MTAwIGFnZT00NzkgY3B1PTAgcGlkPTI5MApbICAgMTguODIwMDA2
XSBJTkZPOiBTbGFiIDB4ZDI1NDA1YzAgb2JqZWN0cz0xNCB1c2VkPTYgZnA9MHhjMGFhZjVl
MCBmbGFncz0weDQwODAKWyAgIDE4LjgyMDAwNl0gSU5GTzogT2JqZWN0IDB4YzBhYWU0NjAg
QG9mZnNldD0xMTIwIGZwPTB4YzBhYWYxODAKWyAgIDE4LjgyMDAwNl0gClsgICAxOC44MjAw
MDZdIEJ5dGVzIGI0IGMwYWFlNDUwOiAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCA1YSA1YSA1
YSA1YSA1YSA1YSA1YSA1YSAgLi4uLi4uLi5aWlpaWlpaWgpbICAgMTguODIwMDA2XSBPYmpl
Y3QgYzBhYWU0NjA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAw
IDAwIDAwICAuLi4uLi4uLi4uLi4uLi4uCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyL2VmZTQyMDhmNDdmOTA3Yjg2ZjUyODc4OGRhNzExZThhYjlkZWE0NGQvZG1lc2ct
cXVhbnRhbC1pdmI0MS0xMTU6MjAxNDA3MDYwMjM1NDY6aTM4Ni1yYW5kY29uZmlnLXgwLTA3
MDIxMzAyOjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvZWZlNDIwOGY0
N2Y5MDdiODZmNTI4Nzg4ZGE3MTFlOGFiOWRlYTQ0ZC9kbWVzZy1xdWFudGFsLWl2YjQxLTI0
OjIwMTQwNzA2MDIzNTQ1OmkzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMjo6CjE6MjoyIGFs
bF9nb29kOmJhZDphbGxfYmFkIGJvb3RzCgplZmU0MjA4ZjQ3ZjkwN2I4NmY1Mjg3ODhkYTcx
MWU4YWI5ZGVhNDRkIGlzIHRoZSBmaXJzdCBiYWQgY29tbWl0CmNvbW1pdCBlZmU0MjA4ZjQ3
ZjkwN2I4NmY1Mjg3ODhkYTcxMWU4YWI5ZGVhNDRkCkF1dGhvcjogRXJpYyBEdW1hemV0IDxl
ZHVtYXpldEBnb29nbGUuY29tPgpEYXRlOiAgIFRodSBPY3QgMyAxNTo0MjoyOSAyMDEzIC0w
NzAwCgogICAgaXB2NjogbWFrZSBsb29rdXBzIHNpbXBsZXIgYW5kIGZhc3RlcgogICAgCiAg
ICBUQ1AgbGlzdGVuZXIgcmVmYWN0b3JpbmcsIHBhcnQgNCA6CiAgICAKICAgIFRvIHNwZWVk
IHVwIGluZXQgbG9va3Vwcywgd2UgbW92ZWQgSVB2NCBhZGRyZXNzZXMgZnJvbSBpbmV0IHRv
IHN0cnVjdAogICAgc29ja19jb21tb24KICAgIAogICAgTm93IGlzIHRpbWUgdG8gZG8gdGhl
IHNhbWUgZm9yIElQdjYsIGJlY2F1c2UgaXQgcGVybWl0cyB1cyB0byBoYXZlIGZhc3QKICAg
IGxvb2t1cHMgZm9yIGFsbCBraW5kIG9mIHNvY2tldHMsIGluY2x1ZGluZyB1cGNvbWluZyBT
WU5fUkVDVi4KICAgIAogICAgR2V0dGluZyBJUHY2IGFkZHJlc3NlcyBpbiBUQ1AgbG9va3Vw
cyBjdXJyZW50bHkgcmVxdWlyZXMgdHdvIGV4dHJhIGNhY2hlCiAgICBsaW5lcywgcGx1cyBh
IGRlcmVmZXJlbmNlIChhbmQgbWVtb3J5IHN0YWxsKS4KICAgIAogICAgaW5ldDZfc2soc2sp
IGRvZXMgdGhlIGRlcmVmZXJlbmNlIG9mIGluZXRfc2soX19zayktPnBpbmV0NgogICAgCiAg
ICBUaGlzIHBhdGNoIGlzIHdheSBiaWdnZXIgdGhhbiBpdHMgSVB2NCBjb3VudGVyIHBhcnQs
IGJlY2F1c2UgZm9yIElQdjQsCiAgICB3ZSBjb3VsZCBhZGQgYWxpYXNlcyAoaW5ldF9kYWRk
ciwgaW5ldF9yY3Zfc2FkZHIpLCB3aGlsZSBvbiBJUHY2LAogICAgaXQncyBub3QgZG9hYmxl
IGVhc2lseS4KICAgIAogICAgaW5ldDZfc2soc2spLT5kYWRkciBiZWNvbWVzIHNrLT5za192
Nl9kYWRkcgogICAgaW5ldDZfc2soc2spLT5yY3Zfc2FkZHIgYmVjb21lcyBzay0+c2tfdjZf
cmN2X3NhZGRyCiAgICAKICAgIEFuZCB0aW1ld2FpdCBzb2NrZXQgYWxzbyBoYXZlIHR3LT50
d192Nl9kYWRkciAmIHR3LT50d192Nl9yY3Zfc2FkZHIKICAgIGF0IHRoZSBzYW1lIG9mZnNl
dC4KICAgIAogICAgV2UgZ2V0IHJpZCBvZiBJTkVUNl9UV19NQVRDSCgpIGFzIElORVQ2X01B
VENIKCkgaXMgbm93IHRoZSBnZW5lcmljCiAgICBtYWNyby4KICAgIAogICAgU2lnbmVkLW9m
Zi1ieTogRXJpYyBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUuY29tPgogICAgU2lnbmVkLW9m
Zi1ieTogRGF2aWQgUy4gTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PgoKOjA0MDAwMCAw
NDAwMDAgNDQ0MmY5OTA2ZGUzMmQ2NDVjMzFhYjhmZTBjNzIxN2MwYTMyOTYyNCAwZGFhNDJl
YjQ2ZGI3Yjg0ZjE1YTQ5ZmU4M2U5ZGQzZGMzNjBhMTk5IE0JaW5jbHVkZQo6MDQwMDAwIDA0
MDAwMCA5MDkwZjIzMDBhNzk4YzJjNGE2YjlkYjUzYWNjZmNlZDMyY2ZlMGI0IDBjZGY3OThm
NTQ3Y2FiNjAwMTFlNTk3ZTRlNzA2OGMxNjNkM2I2MmUgTQluZXQKOjA0MDAwMCAwNDAwMDAg
NzQ3ODBjNTQ1MGY2YWZjM2VkZTVmYTVmNWRkYTE3MmIxOTZkNTIyMSAwOThjOWZjZDM2OTdm
MmM0ZWQ0ZjE4YWMwYzY2Y2E5NDU1MTc0MmMyIE0Jc2VjdXJpdHkKYmlzZWN0IHJ1biBzdWNj
ZXNzClByZXZpb3VzIEhFQUQgcG9zaXRpb24gd2FzIGVmZTQyMDguLi4gaXB2NjogbWFrZSBs
b29rdXBzIHNpbXBsZXIgYW5kIGZhc3RlcgpIRUFEIGlzIG5vdyBhdCAwNWRiYzdiLi4uIHRj
cC9kY2NwOiByZW1vdmUgdHdjaGFpbgpscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9r
dm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL25leHQ6bWFzdGVyOjA1ZGJjN2I1OTQ4
MWNhODkxYmJjZmU2Nzk5YTU2MmQ0ODE1OWZiZjc6YmlzZWN0LWxpbnV4NgoKMjAxNC0wNy0w
Ni0wMjozNjo0NiAwNWRiYzdiNTk0ODFjYTg5MWJiY2ZlNjc5OWE1NjJkNDgxNTlmYmY3IHJl
dXNlIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzA1ZGJjN2I1OTQ4MWNh
ODkxYmJjZmU2Nzk5YTU2MmQ0ODE1OWZiZjcvdm1saW51ei0zLjEyLjAtcmMzLTAwODAzLWcw
NWRiYzdiCgoyMDE0LTA3LTA2LTAyOjM2OjQ2IGRldGVjdGluZyBib290IHN0YXRlIC4uCTI0
OQkyODYJMzIyCTM2NAk0MjEJNTEyCTU5Mwk2MzAJNjkwCTczOCBTVUNDRVNTCgpQcmV2aW91
cyBIRUFEIHBvc2l0aW9uIHdhcyAwNWRiYzdiLi4uIHRjcC9kY2NwOiByZW1vdmUgdHdjaGFp
bgpIRUFEIGlzIG5vdyBhdCBiYmI3NDU4Li4uIEFkZCBsaW51eC1uZXh0IHNwZWNpZmljIGZp
bGVzIGZvciAyMDE0MDcwMQpscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4
Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL25leHQ6bWFzdGVyOmJiYjc0NTg2ZDFkNzc2YjZj
NjFlZjA0YTJkNjY5ZjJlNDc3MDNjY2Q6YmlzZWN0LWxpbnV4NgogVEVTVCBGQUlMVVJFClsg
ICAxMS4yNTUxNDddIGluaXQ6IEZhaWxlZCB0byBjcmVhdGUgcHR5IC0gZGlzYWJsaW5nIGxv
Z2dpbmcgZm9yIGpvYgpLZXJuZWwgdGVzdHM6IEJvb3QgT0shClsgICAyMS40MzE3NDNdID09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09ClsgICAyMS40MzE3NDZdIEJVRyBrbWFsbG9jLTUxMiAo
Tm90IHRhaW50ZWQpOiBPYmplY3QgcGFkZGluZyBvdmVyd3JpdHRlbgpbICAgMjEuNDMxNzQ2
XSAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpbICAgMjEuNDMxNzQ2XSAKWyAgIDIxLjQzMTc0
OF0gSU5GTzogMHhkM2E4NjQ1OC0weGQzYTg2NDViLiBGaXJzdCBieXRlIDB4MSBpbnN0ZWFk
IG9mIDB4NWEKWyAgIDIxLjQzMTc1Nl0gSU5GTzogQWxsb2NhdGVkIGluIHNrX3Byb3RfYWxs
b2MuaXNyYS4zOSsweDUzLzB4ZDAgYWdlPTY3NCBjcHU9MCBwaWQ9Mjk0ClsgICAyMS40MzE3
NTddIElORk86IFNsYWIgMHhkMjdhMDBjMCBvYmplY3RzPTE0IHVzZWQ9MTIgZnA9MHhkM2E4
N2M3MCBmbGFncz0weDQwMDA0MDgwClsgICAyMS40MzE3NThdIElORk86IE9iamVjdCAweGQz
YTg2MjMwIEBvZmZzZXQ9NTYwIGZwPTB4ZDNhODY0NjAKWyAgIDIxLjQzMTc1OF0gClsgICAy
MS40MzE3NjBdIEJ5dGVzIGI0IGQzYTg2MjIwOiAyNiAwMSAwMCAwMCBkNyBiZiBmYiBmZiA1
YSA1YSA1YSA1YSA1YSA1YSA1YSA1YSAgJi4uLi4uLi5aWlpaWlpaWgpbICAgMjEuNDMxNzYx
XSBPYmplY3QgZDNhODYyMzA6IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAw
IDAwIDAwIDAwIDAwICAuLi4uLi4uLi4uLi4uLi4uCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LXgwLTA3MDIxMzAyL2JiYjc0NTg2ZDFkNzc2YjZjNjFlZjA0YTJkNjY5ZjJlNDc3MDNjY2Qv
ZG1lc2ctcXVhbnRhbC1pdmI0My02MToyMDE0MDcwMzIyMjQzMjppMzg2LXJhbmRjb25maWct
eDAtMDcwMjEzMDI6Ogova2VybmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9iYmI3
NDU4NmQxZDc3NmI2YzYxZWYwNGEyZDY2OWYyZTQ3NzAzY2NkL2RtZXNnLXF1YW50YWwtaXZi
NDItNzg6MjAxNDA3MDQwMDE2NDM6aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyOjoKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvYmJiNzQ1ODZkMWQ3NzZiNmM2MWVm
MDRhMmQ2NjlmMmU0NzcwM2NjZC9kbWVzZy1xdWFudGFsLWl2YjQyLTUyOjIwMTQwNzAzMDM1
MzAzOmkzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMjo6CjM4OjM6MyBhbGxfZ29vZDpiYWQ6
YWxsX2JhZCBib290cwoKSEVBRCBpcyBub3cgYXQgYmJiNzQ1OCBBZGQgbGludXgtbmV4dCBz
cGVjaWZpYyBmaWxlcyBmb3IgMjAxNDA3MDEKCj09PT09PT09PSB1cHN0cmVhbSA9PT09PT09
PT0KRnJvbSBnaXQ6Ly9naXRtaXJyb3IvbGludXMKICAgZDkyYTMzMy4uNzdjNGNmMSAgbWFz
dGVyICAgICAtPiBsaW51cy9tYXN0ZXIKUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgYmJi
NzQ1OC4uLiBBZGQgbGludXgtbmV4dCBzcGVjaWZpYyBmaWxlcyBmb3IgMjAxNDA3MDEKSEVB
RCBpcyBub3cgYXQgNzdjNGNmMS4uLiBNZXJnZSB0YWcgJ21kLzMuMTYtZml4ZXMnIG9mIGdp
dDovL25laWwuYnJvd24ubmFtZS9tZApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9r
dm0vaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL2xpbnVzOm1hc3Rlcjo3N2M0Y2YxN2Fl
ODY3YmE5MzIzM2IzODMyYmRhM2RlN2FkYWFlMzI2OmJpc2VjdC1saW51eDYKCjIwMTQtMDct
MDYtMDI6NDQ6MzEgNzdjNGNmMTdhZTg2N2JhOTMyMzNiMzgzMmJkYTNkZTdhZGFhZTMyNiBj
b21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1
ZS9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDItNzdjNGNmMTdhZTg2N2JhOTMyMzNiMzgz
MmJkYTNkZTdhZGFhZTMyNgpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLXgwLTA3MDIxMzAyLzc3YzRjZjE3YWU4NjdiYTkzMjMzYjM4MzJiZGEzZGU3YWRh
YWUzMjYKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1
ZXVlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi03N2M0Y2YxN2FlODY3YmE5MzIzM2Iz
ODMyYmRhM2RlN2FkYWFlMzI2CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS94aWFuLXNtb2tlL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMw
Mi03N2M0Y2YxN2FlODY3YmE5MzIzM2IzODMyYmRhM2RlN2FkYWFlMzI2Cmtlcm5lbDogL2tl
cm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvNzdjNGNmMTdhZTg2N2JhOTMyMzNi
MzgzMmJkYTNkZTdhZGFhZTMyNi92bWxpbnV6LTMuMTYuMC1yYzMtMDAxNzgtZzc3YzRjZjEK
CjIwMTQtMDctMDYtMDM6Mzk6MzEgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uLi4uLi4uLi4u
Li4uLi4uCTEJMwk0CTgJMTkgVEVTVCBGQUlMVVJFClsgICAxMC41MDA4NDZdIGluaXQ6IEZh
aWxlZCB0byBjcmVhdGUgcHR5IC0gZGlzYWJsaW5nIGxvZ2dpbmcgZm9yIGpvYgpLZXJuZWwg
dGVzdHM6IEJvb3QgT0shClsgICAyMC42Mjc0NzNdID09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
ClsgICAyMC42MjgwMDddIEJVRyBrbWFsbG9jLTUxMiAoTm90IHRhaW50ZWQpOiBPYmplY3Qg
cGFkZGluZyBvdmVyd3JpdHRlbgpbICAgMjAuNjI4MDA3XSAtLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLQpbICAgMjAuNjI4MDA3XSAKWyAgIDIwLjYyODAwN10gSU5GTzogMHhkMzRlZGEzOC0w
eGQzNGVkYTNiLiBGaXJzdCBieXRlIDB4MSBpbnN0ZWFkIG9mIDB4NWEKWyAgIDIwLjYyODAw
N10gSU5GTzogQWxsb2NhdGVkIGluIHNrX3Byb3RfYWxsb2MuaXNyYS4zOSsweDUzLzB4ZDAg
YWdlPTczNiBjcHU9MCBwaWQ9MjkzClsgICAyMC42MjgwMDddIElORk86IFNsYWIgMHhkMjc5
NGQ4MCBvYmplY3RzPTE0IHVzZWQ9OSBmcD0weGQzNGVjNDYwIGZsYWdzPTB4NDAwMDQwODAK
WyAgIDIwLjYyODAwN10gSU5GTzogT2JqZWN0IDB4ZDM0ZWQ4MTAgQG9mZnNldD02MTYwIGZw
PTB4ZDM0ZWQ1ZTAKWyAgIDIwLjYyODAwN10gClsgICAyMC42MjgwMDddIEJ5dGVzIGI0IGQz
NGVkODAwOiAwMCAwMCAwMCAwMCAwMCAwMCAwMCAwMCA1YSA1YSA1YSA1YSA1YSA1YSA1YSA1
YSAgLi4uLi4uLi5aWlpaWlpaWgpbICAgMjAuNjI4MDA3XSBPYmplY3QgZDM0ZWQ4MTA6IDAw
IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwICAuLi4uLi4u
Li4uLi4uLi4uCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzc3YzRjZjE3
YWU4NjdiYTkzMjMzYjM4MzJiZGEzZGU3YWRhYWUzMjYvZG1lc2ctcXVhbnRhbC1pdmI0Mi0x
MDE6MjAxNDA3MDYwMzQ5NTY6aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyOjoKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvNzdjNGNmMTdhZTg2N2JhOTMyMzNiMzgz
MmJkYTNkZTdhZGFhZTMyNi9kbWVzZy1xdWFudGFsLWl2YjQyLTEwMDoyMDE0MDcwNjAzNTAw
NjppMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDI6Ogova2VybmVsL2kzODYtcmFuZGNvbmZp
Zy14MC0wNzAyMTMwMi83N2M0Y2YxN2FlODY3YmE5MzIzM2IzODMyYmRhM2RlN2FkYWFlMzI2
L2RtZXNnLXF1YW50YWwtaXZiNDItMTA5OjIwMTQwNzA2MDM1MDI2OmkzODYtcmFuZGNvbmZp
Zy14MC0wNzAyMTMwMjo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyLzc3
YzRjZjE3YWU4NjdiYTkzMjMzYjM4MzJiZGEzZGU3YWRhYWUzMjYvZG1lc2ctcXVhbnRhbC1p
dmI0Mi0xMTU6MjAxNDA3MDYwMzUwMTk6aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyOjoK
L2tlcm5lbC9pMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDIvNzdjNGNmMTdhZTg2N2JhOTMy
MzNiMzgzMmJkYTNkZTdhZGFhZTMyNi9kbWVzZy1xdWFudGFsLWl2YjQyLTExNzoyMDE0MDcw
NjAzNTAxOTppMzg2LXJhbmRjb25maWcteDAtMDcwMjEzMDI6OgoxOTo1OjUgYWxsX2dvb2Q6
YmFkOmFsbF9iYWQgYm9vdHMKCgo9PT09PT09PT0gbGludXgtbmV4dCA9PT09PT09PT0KRnJv
bSBnaXQ6Ly9naXRtaXJyb3IvbmV4dAogKyAwZDZhOTI2Li4uZmFjODQ3YiBha3BtICAgICAg
IC0+IG5leHQvYWtwbSAgKGZvcmNlZCB1cGRhdGUpCiArIDQ0Mzk4ODEuLi44MmMyMzc2IGFr
cG0tYmFzZSAgLT4gbmV4dC9ha3BtLWJhc2UgIChmb3JjZWQgdXBkYXRlKQogKyAwZTljZTgy
Li4uYmI2MmM3OSBtYXN0ZXIgICAgIC0+IG5leHQvbWFzdGVyICAoZm9yY2VkIHVwZGF0ZSkK
ICAgZDkyYTMzMy4uNTE3MGEzYiAgc3RhYmxlICAgICAtPiBuZXh0L3N0YWJsZQpGcm9tIGdp
dDovL2dpdG1pcnJvci9uZXh0CiAqIFtuZXcgdGFnXSAgICAgICAgIG5leHQtMjAxNDA3MDQg
LT4gbmV4dC0yMDE0MDcwNApQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyA3N2M0Y2YxLi4u
IE1lcmdlIHRhZyAnbWQvMy4xNi1maXhlcycgb2YgZ2l0Oi8vbmVpbC5icm93bi5uYW1lL21k
CkhFQUQgaXMgbm93IGF0IGJiNjJjNzkuLi4gQWRkIGxpbnV4LW5leHQgc3BlY2lmaWMgZmls
ZXMgZm9yIDIwMTQwNzA0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2
LXJhbmRjb25maWcteDAtMDcwMjEzMDIvbmV4dDptYXN0ZXI6YmI2MmM3OTg3OTg2NTk2MjRj
NTNlMzcyN2JiYzE4Y2Y0N2ViN2FlODpiaXNlY3QtbGludXg2CgoyMDE0LTA3LTA2LTAzOjUx
OjE1IGJiNjJjNzk4Nzk4NjU5NjI0YzUzZTM3MjdiYmMxOGNmNDdlYjdhZTggY29tcGlsaW5n
ClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1y
YW5kY29uZmlnLXgwLTA3MDIxMzAyLWJiNjJjNzk4Nzk4NjU5NjI0YzUzZTM3MjdiYmMxOGNm
NDdlYjdhZTgKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy14
MC0wNzAyMTMwMi9iYjYyYzc5ODc5ODY1OTYyNGM1M2UzNzI3YmJjMThjZjQ3ZWI3YWU4Cndh
aXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2
LXJhbmRjb25maWcteDAtMDcwMjEzMDItYmI2MmM3OTg3OTg2NTk2MjRjNTNlMzcyN2JiYzE4
Y2Y0N2ViN2FlOAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVp
bGQtcXVldWUvamFrZXRvd24tY29uc3VtZXIvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAy
LWJiNjJjNzk4Nzk4NjU5NjI0YzUzZTM3MjdiYmMxOGNmNDdlYjdhZTgKa2VybmVsOiAva2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy14MC0wNzAyMTMwMi9iYjYyYzc5ODc5ODY1OTYyNGM1M2Uz
NzI3YmJjMThjZjQ3ZWI3YWU4L3ZtbGludXotMy4xNi4wLXJjMy1uZXh0LTIwMTQwNzA0Cgoy
MDE0LTA3LTA2LTAzOjU3OjE1IGRldGVjdGluZyBib290IHN0YXRlIC4gVEVTVCBGQUlMVVJF
ClsgICAgOS4zNjI1NjJdIGluaXQ6IEZhaWxlZCB0byBjcmVhdGUgcHR5IC0gZGlzYWJsaW5n
IGxvZ2dpbmcgZm9yIGpvYgpLZXJuZWwgdGVzdHM6IEJvb3QgT0shClsgICAxOS45Njg3NTVd
ID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09ClsgICAxOS45NjkwMDhdIEJVRyBrbWFsbG9jLTUx
MiAoTm90IHRhaW50ZWQpOiBPYmplY3QgcGFkZGluZyBvdmVyd3JpdHRlbgpbICAgMTkuOTY5
MDA4XSAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpbICAgMTkuOTY5MDA4XSAKWyAgIDE5Ljk2
OTAwOF0gSU5GTzogMHhkMzIxMWU5OC0weGQzMjExZTliLiBGaXJzdCBieXRlIDB4MSBpbnN0
ZWFkIG9mIDB4NWEKWyAgIDE5Ljk2OTAwOF0gSU5GTzogQWxsb2NhdGVkIGluIHNrX3Byb3Rf
YWxsb2MuaXNyYS4zOSsweDUzLzB4ZDAgYWdlPTg5MiBjcHU9MCBwaWQ9Mjk0ClsgICAxOS45
NjkwMDhdIElORk86IEZyZWVkIGluIHNrYl9mcmVlX2hlYWQrMHgxNC8weDUwIGFnZT0xMDYx
MiBjcHU9MCBwaWQ9MjYyClsgICAxOS45NjkwMDhdIElORk86IFNsYWIgMHhkMjc4ZjIwMCBv
YmplY3RzPTE0IHVzZWQ9OCBmcD0weGQzMjExODEwIGZsYWdzPTB4NDAwMDQwODAKWyAgIDE5
Ljk2OTAwOF0gSU5GTzogT2JqZWN0IDB4ZDMyMTFjNzAgQG9mZnNldD03MjgwIGZwPTB4ICAo
bnVsbCkKWyAgIDE5Ljk2OTAwOF0gClsgICAxOS45NjkwMDhdIEJ5dGVzIGI0IGQzMjExYzYw
OiAyNiAwMSAwMCAwMCAyMCBiYSBmYiBmZiA1YSA1YSA1YSA1YSA1YSA1YSA1YSA1YSAgJi4u
LiAuLi5aWlpaWlpaWgpbICAgMTkuOTY5MDA4XSBPYmplY3QgZDMyMTFjNzA6IDAwIDAwIDAw
IDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwIDAwICAuLi4uLi4uLi4uLi4u
Li4uCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyL2JiNjJjNzk4Nzk4NjU5
NjI0YzUzZTM3MjdiYmMxOGNmNDdlYjdhZTgvZG1lc2ctcXVhbnRhbC1pdmI0Mi0xMTY6MjAx
NDA3MDYwMzU2NTU6aTM4Ni1yYW5kY29uZmlnLXgwLTA3MDIxMzAyOjoKMDoxOjEgYWxsX2dv
b2Q6YmFkOmFsbF9iYWQgYm9vdHMKCg==

--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.12.0-rc3-00804-gefe4208"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.12.0-rc3 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_FHANDLE=y
CONFIG_AUDIT=y
# CONFIG_AUDITSYSCALL is not set
# CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_KTIME_SCALAR=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
# CONFIG_TASK_DELAY_ACCT is not set
# CONFIG_TASK_XACCT is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
CONFIG_RT_GROUP_SCHED=y
# CONFIG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_UIDGID_STRICT_TYPE_CHECKS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
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
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
CONFIG_PROFILING=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_BLOCK=y
CONFIG_LBDAF=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_CMDLINE_PARSER=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_CFQ is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_ASN1=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
CONFIG_M686=y
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
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
# CONFIG_X86_PPRO_FENCE is not set
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_UP_APIC=y
# CONFIG_X86_UP_IOAPIC is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_ANCIENT_MCE=y
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_VM86=y
# CONFIG_TOSHIBA is not set
CONFIG_I8K=y
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_LIB=y
CONFIG_MICROCODE_INTEL_EARLY=y
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_HIGHMEM=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=1
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_ZBUD is not set
# CONFIG_HIGHPTE is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MATH_EMULATION is not set
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
# CONFIG_SCHED_HRTICK is not set
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K6=y
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
# CONFIG_X86_GX_SUSPMOD is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=y
CONFIG_X86_SPEEDSTEP_ICH=y
CONFIG_X86_SPEEDSTEP_SMI=y
CONFIG_X86_P4_CLOCKMOD=y
# CONFIG_X86_CPUFREQ_NFORCE2 is not set
# CONFIG_X86_LONGRUN is not set
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
# CONFIG_EISA is not set
CONFIG_SCx200=y
# CONFIG_SCx200HR_TIMER is not set
# CONFIG_OLPC is not set
CONFIG_ALIX=y
CONFIG_NET5501=y
# CONFIG_GEOS is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
CONFIG_I82365=y
CONFIG_TCIC=y
CONFIG_PCMCIA_PROBE=y
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_ROUTE_CLASSID=y
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_IP_MROUTE=y
CONFIG_IP_PIMSM_V1=y
# CONFIG_IP_PIMSM_V2 is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_INET_AH is not set
CONFIG_INET_ESP=y
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_LRO is not set
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_BEET is not set
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_SIT=y
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_GRE=y
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
CONFIG_NETWORK_SECMARK=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
CONFIG_TIPC=y
CONFIG_TIPC_PORTS=8191
# CONFIG_ATM is not set
CONFIG_L2TP=y
# CONFIG_L2TP_V3 is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_TRAILER=y
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_IPX is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_LTPC=y
# CONFIG_COPS is not set
# CONFIG_IPDDP is not set
CONFIG_X25=y
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
# CONFIG_NET_SCH_CBQ is not set
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_PRIO=y
# CONFIG_NET_SCH_MULTIQ is not set
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
# CONFIG_NET_SCH_QFQ is not set
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
# CONFIG_NET_SCH_FQ is not set
CONFIG_NET_SCH_PLUG=y

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
# CONFIG_CLS_U32_PERF is not set
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
# CONFIG_NET_CLS_RSVP6 is not set
# CONFIG_NET_CLS_FLOW is not set
CONFIG_NET_CLS_CGROUP=y
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
# CONFIG_DNS_RESOLVER is not set
CONFIG_BATMAN_ADV=y
# CONFIG_BATMAN_ADV_BLA is not set
CONFIG_BATMAN_ADV_DAT=y
# CONFIG_BATMAN_ADV_NC is not set
CONFIG_BATMAN_ADV_DEBUG=y
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=y
CONFIG_NET_MPLS_GSO=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
CONFIG_NET_PKTGEN=y
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
# CONFIG_BT_RFCOMM_TTY is not set
CONFIG_BT_BNEP=y
CONFIG_BT_BNEP_MC_FILTER=y
# CONFIG_BT_BNEP_PROTO_FILTER is not set
CONFIG_BT_HIDP=y

#
# Bluetooth device drivers
#
# CONFIG_BT_HCIBTSDIO is not set
CONFIG_BT_HCIUART=y
# CONFIG_BT_HCIUART_H4 is not set
# CONFIG_BT_HCIUART_BCSP is not set
# CONFIG_BT_HCIUART_ATH3K is not set
# CONFIG_BT_HCIUART_LL is not set
# CONFIG_BT_HCIUART_3WIRE is not set
# CONFIG_BT_HCIDTL1 is not set
CONFIG_BT_HCIBT3C=y
CONFIG_BT_HCIBLUECARD=y
CONFIG_BT_HCIBTUART=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_MRVL_SDIO=y
CONFIG_AF_RXRPC=y
# CONFIG_AF_RXRPC_DEBUG is not set
# CONFIG_RXKAD is not set
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
CONFIG_NL80211_TESTMODE=y
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
# CONFIG_CFG80211_REG_DEBUG is not set
# CONFIG_CFG80211_DEFAULT_PS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
# CONFIG_CFG80211_WEXT is not set
CONFIG_LIB80211=y
CONFIG_LIB80211_CRYPT_WEP=y
CONFIG_LIB80211_CRYPT_CCMP=y
CONFIG_LIB80211_CRYPT_TKIP=y
CONFIG_LIB80211_DEBUG=y
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_MESSAGE_TRACING=y
# CONFIG_MAC80211_DEBUG_MENU is not set
# CONFIG_WIMAX is not set
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_DEBUG=y
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
CONFIG_NFC=y
CONFIG_NFC_NCI=y
CONFIG_NFC_HCI=y
# CONFIG_NFC_SHDLC is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_SIM=y
# CONFIG_NFC_PN544 is not set
# CONFIG_NFC_MICROREAD is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_PERCENTAGE=10
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
CONFIG_CMA_SIZE_SEL_PERCENTAGE=y
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8
CONFIG_CMA_AREAS=7

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
# CONFIG_RFD_FTL is not set
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
# CONFIG_MTD_OOPS is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
# CONFIG_MTD_CFI_AMDSTD is not set
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
# CONFIG_MTD_SC520CDP is not set
# CONFIG_MTD_NETSC520 is not set
# CONFIG_MTD_TS5500 is not set
CONFIG_MTD_SBC_GXX=y
CONFIG_MTD_SCx200_DOCFLASH=y
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_PCI is not set
CONFIG_MTD_PCMCIA=y
CONFIG_MTD_PCMCIA_ANONYMOUS=y
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_SM_COMMON is not set
# CONFIG_MTD_NAND_DENALI is not set
CONFIG_MTD_NAND_GPIO=y
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=y
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=y
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
# CONFIG_MTD_NAND_CS553X is not set
# CONFIG_MTD_NAND_NANDSIM is not set
CONFIG_MTD_NAND_PLATFORM=y
# CONFIG_MTD_ONENAND is not set

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
# CONFIG_PARPORT_PC_FIFO is not set
CONFIG_PARPORT_PC_SUPERIO=y
# CONFIG_PARPORT_PC_PCMCIA is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
# CONFIG_ISAPNP is not set
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y
# CONFIG_BLK_DEV_DRBD is not set
CONFIG_BLK_DEV_NBD=y
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
CONFIG_BLK_DEV_XIP=y
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
CONFIG_ATA_OVER_ETH=y
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_RBD=y
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
# CONFIG_ATMEL_SSC is not set
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_SRAM is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_IDE_LEGACY=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
CONFIG_IDE_GD_ATAPI=y
# CONFIG_BLK_DEV_IDECS is not set
# CONFIG_BLK_DEV_DELKIN is not set
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=y

#
# PCI IDE chipsets support
#
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_CS5535 is not set
# CONFIG_BLK_DEV_CS5536 is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set

#
# Other IDE chipsets support
#

#
# Note: most of these also require special kernel boot parameters
#
# CONFIG_BLK_DEV_4DRIVES is not set
CONFIG_BLK_DEV_ALI14XX=y
CONFIG_BLK_DEV_DTC2278=y
# CONFIG_BLK_DEV_HT6560B is not set
# CONFIG_BLK_DEV_QD65XX is not set
# CONFIG_BLK_DEV_UMC8672 is not set
# CONFIG_BLK_DEV_IDEDMA is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
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
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_ENCLOSURE=y
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
# CONFIG_SCSI_SAS_LIBSAS is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=y
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
CONFIG_SCSI_7000FASST=y
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AHA152X=y
CONFIG_SCSI_AHA1542=y
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_IN2000=y
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_MPT3SAS is not set
CONFIG_SCSI_UFSHCD=y
# CONFIG_SCSI_UFSHCD_PCI is not set
CONFIG_SCSI_UFSHCD_PLATFORM=y
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
CONFIG_LIBFC=y
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
CONFIG_SCSI_DTC3280=y
CONFIG_SCSI_EATA=y
CONFIG_SCSI_EATA_TAGGED_QUEUE=y
CONFIG_SCSI_EATA_LINKED_COMMANDS=y
CONFIG_SCSI_EATA_MAX_TAGS=16
CONFIG_SCSI_FUTURE_DOMAIN=y
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
# CONFIG_SCSI_GENERIC_NCR5380 is not set
# CONFIG_SCSI_GENERIC_NCR5380_MMIO is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
CONFIG_SCSI_PPA=y
CONFIG_SCSI_IMM=y
CONFIG_SCSI_IZIP_EPP16=y
CONFIG_SCSI_IZIP_SLOW_CTR=y
CONFIG_SCSI_NCR53C406A=y
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_PAS16=y
CONFIG_SCSI_QLOGIC_FAS=y
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_SYM53C416=y
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
CONFIG_SCSI_T128=y
CONFIG_SCSI_U14_34F=y
CONFIG_SCSI_U14_34F_TAGGED_QUEUE=y
CONFIG_SCSI_U14_34F_LINKED_COMMANDS=y
CONFIG_SCSI_U14_34F_MAX_TAGS=8
CONFIG_SCSI_ULTRASTOR=y
# CONFIG_SCSI_NSP32 is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_CHELSIO_FCOE is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
CONFIG_SCSI_DH=y
# CONFIG_SCSI_DH_RDAC is not set
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
# CONFIG_SCSI_DH_ALUA is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
# CONFIG_MD_LINEAR is not set
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
# CONFIG_MD_RAID456 is not set
CONFIG_MD_MULTIPATH=y
# CONFIG_MD_FAULTY is not set
# CONFIG_BCACHE is not set
# CONFIG_BLK_DEV_DM is not set
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=y
# CONFIG_LOOPBACK_TARGET is not set
CONFIG_TCM_FC=y
CONFIG_ISCSI_TARGET=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
CONFIG_DUMMY=y
CONFIG_EQUALIZER=y
# CONFIG_NET_FC is not set
CONFIG_NET_TEAM=y
CONFIG_NET_TEAM_MODE_BROADCAST=y
CONFIG_NET_TEAM_MODE_ROUNDROBIN=y
CONFIG_NET_TEAM_MODE_RANDOM=y
# CONFIG_NET_TEAM_MODE_ACTIVEBACKUP is not set
CONFIG_NET_TEAM_MODE_LOADBALANCE=y
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
# CONFIG_TUN is not set
CONFIG_VETH=y
# CONFIG_VIRTIO_NET is not set
CONFIG_NLMON=y
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
# CONFIG_ARCNET_1051 is not set
CONFIG_ARCNET_RAW=y
# CONFIG_ARCNET_CAP is not set
CONFIG_ARCNET_COM90xx=y
CONFIG_ARCNET_COM90xxIO=y
# CONFIG_ARCNET_RIM_I is not set
CONFIG_ARCNET_COM20020=y
# CONFIG_ARCNET_COM20020_ISA is not set
# CONFIG_ARCNET_COM20020_PCI is not set
# CONFIG_ARCNET_COM20020_CS is not set

#
# CAIF transport drivers
#
CONFIG_CAIF_TTY=y
CONFIG_CAIF_SPI_SLAVE=y
CONFIG_CAIF_SPI_SYNC=y
CONFIG_CAIF_HSI=y
CONFIG_CAIF_VIRTIO=y
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
CONFIG_NET_DSA_MV88E6060=y
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_NET_VENDOR_3COM=y
CONFIG_EL3=y
CONFIG_3C515=y
CONFIG_PCMCIA_3C574=y
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_NET_VENDOR_AMD is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_CADENCE=y
# CONFIG_ARM_AT91_ETHER is not set
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CIRRUS=y
CONFIG_CS89x0=y
CONFIG_CS89x0_PLATFORM=y
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
CONFIG_HP100=y
# CONFIG_NET_VENDOR_INTEL is not set
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
# CONFIG_NET_VENDOR_MARVELL is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_NET_VENDOR_MICREL is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
# CONFIG_NET_VENDOR_8390 is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_NET_VENDOR_REALTEK is not set
CONFIG_SH_ETH=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
# CONFIG_SFC is not set
CONFIG_NET_VENDOR_SMSC=y
CONFIG_SMC9194=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
CONFIG_SMSC911X=y
# CONFIG_SMSC911X_ARCH_HOOKS is not set
# CONFIG_SMSC9420 is not set
# CONFIG_NET_VENDOR_STMICRO is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_NET_VENDOR_WIZNET is not set
CONFIG_NET_VENDOR_XIRCOM=y
CONFIG_PCMCIA_XIRC2PS=y
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
CONFIG_AT803X_PHY=y
CONFIG_AMD_PHY=y
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
CONFIG_QSEMI_PHY=y
# CONFIG_LXT_PHY is not set
CONFIG_CICADA_PHY=y
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
CONFIG_BROADCOM_PHY=y
CONFIG_BCM87XX_PHY=y
CONFIG_ICPLUS_PHY=y
# CONFIG_REALTEK_PHY is not set
CONFIG_NATIONAL_PHY=y
# CONFIG_STE10XP is not set
CONFIG_LSI_ET1011C_PHY=y
CONFIG_MICREL_PHY=y
# CONFIG_FIXED_PHY is not set
CONFIG_MDIO_BITBANG=y
# CONFIG_MDIO_GPIO is not set
# CONFIG_PLIP is not set
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
# CONFIG_PPP_DEFLATE is not set
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=y
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOE=y
CONFIG_PPPOL2TP=y
CONFIG_PPP_ASYNC=y
CONFIG_PPP_SYNC_TTY=y
CONFIG_SLIP=y
CONFIG_SLHC=y
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_WLAN=y
# CONFIG_PCMCIA_RAYCS is not set
CONFIG_LIBERTAS_THINFIRM=y
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
# CONFIG_AIRO is not set
CONFIG_ATMEL=y
# CONFIG_PCI_ATMEL is not set
CONFIG_PCMCIA_ATMEL=y
CONFIG_AIRO_CS=y
CONFIG_PCMCIA_WL3501=y
# CONFIG_PRISM54 is not set
# CONFIG_RTL8180 is not set
# CONFIG_ADM8211 is not set
# CONFIG_MAC80211_HWSIM is not set
# CONFIG_MWL8K is not set
CONFIG_ATH_CARDS=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K is not set
# CONFIG_ATH5K_PCI is not set
# CONFIG_ATH9K is not set
CONFIG_ATH6KL=y
# CONFIG_ATH6KL_SDIO is not set
CONFIG_ATH6KL_DEBUG=y
# CONFIG_WIL6210 is not set
# CONFIG_ATH10K is not set
# CONFIG_B43 is not set
CONFIG_B43LEGACY=y
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_HWRNG=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
# CONFIG_B43LEGACY_DMA_AND_PIO_MODE is not set
CONFIG_B43LEGACY_DMA_MODE=y
# CONFIG_B43LEGACY_PIO_MODE is not set
CONFIG_BRCMUTIL=y
CONFIG_BRCMSMAC=y
CONFIG_BRCMFMAC=y
# CONFIG_BRCMFMAC_SDIO is not set
# CONFIG_BRCM_TRACING is not set
# CONFIG_BRCMDBG is not set
CONFIG_HOSTAP=y
CONFIG_HOSTAP_FIRMWARE=y
# CONFIG_HOSTAP_FIRMWARE_NVRAM is not set
# CONFIG_HOSTAP_PLX is not set
# CONFIG_HOSTAP_PCI is not set
# CONFIG_HOSTAP_CS is not set
# CONFIG_IPW2100 is not set
# CONFIG_IWLWIFI is not set
# CONFIG_IWL4965 is not set
# CONFIG_IWL3945 is not set
CONFIG_LIBERTAS=y
# CONFIG_LIBERTAS_CS is not set
CONFIG_LIBERTAS_SDIO=y
CONFIG_LIBERTAS_DEBUG=y
CONFIG_LIBERTAS_MESH=y
CONFIG_P54_COMMON=y
# CONFIG_P54_PCI is not set
CONFIG_P54_LEDS=y
# CONFIG_RT2X00 is not set
CONFIG_RTL_CARDS=y
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192SE is not set
# CONFIG_RTL8192DE is not set
# CONFIG_RTL8723AE is not set
# CONFIG_RTL8188EE is not set
# CONFIG_WL_TI is not set
# CONFIG_MWIFIEX is not set
# CONFIG_CW1200 is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

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
# CONFIG_KEYBOARD_ADP5520 is not set
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_GPIO=y
CONFIG_KEYBOARD_GPIO_POLLED=y
# CONFIG_KEYBOARD_TCA6416 is not set
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
# CONFIG_TOUCHSCREEN_88PM860X is not set
# CONFIG_TOUCHSCREEN_AD7879 is not set
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
CONFIG_TOUCHSCREEN_BU21013=y
CONFIG_TOUCHSCREEN_CY8CTMG110=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
# CONFIG_TOUCHSCREEN_CYTTSP4_I2C is not set
# CONFIG_TOUCHSCREEN_DA9052 is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
CONFIG_TOUCHSCREEN_FUJITSU=y
CONFIG_TOUCHSCREEN_ILI210X=y
CONFIG_TOUCHSCREEN_GUNZE=y
CONFIG_TOUCHSCREEN_ELO=y
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
CONFIG_TOUCHSCREEN_MAX11801=y
CONFIG_TOUCHSCREEN_MCS5000=y
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
# CONFIG_TOUCHSCREEN_HTCPEN is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
CONFIG_TOUCHSCREEN_TOUCHWIN=y
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC2007=y
CONFIG_TOUCHSCREEN_ST1232=y
CONFIG_TOUCHSCREEN_TPS6507X=y
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=y
CONFIG_INPUT_AD714X=y
# CONFIG_INPUT_AD714X_I2C is not set
CONFIG_INPUT_BMA150=y
# CONFIG_INPUT_PCSPKR is not set
CONFIG_INPUT_MMA8450=y
CONFIG_INPUT_MPU3050=y
# CONFIG_INPUT_APANEL is not set
CONFIG_INPUT_GP2A=y
CONFIG_INPUT_GPIO_TILT_POLLED=y
CONFIG_INPUT_WISTRON_BTNS=y
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_TWL6040_VIBRA=y
CONFIG_INPUT_UINPUT=y
# CONFIG_INPUT_PCF50633_PMU is not set
CONFIG_INPUT_PCF8574=y
# CONFIG_INPUT_PWM_BEEPER is not set
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
# CONFIG_INPUT_DA9052_ONKEY is not set
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=y
# CONFIG_CYZ_INTR is not set
# CONFIG_MOXA_INTELLIO is not set
CONFIG_MOXA_SMARTIO=y
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
# CONFIG_N_HDLC is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_ROUTER is not set
CONFIG_TRACE_SINK=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_FOURPORT=y
CONFIG_SERIAL_8250_ACCENT=y
# CONFIG_SERIAL_8250_BOCA is not set
CONFIG_SERIAL_8250_EXAR_ST16C554=y
# CONFIG_SERIAL_8250_HUB6 is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
# CONFIG_SERIAL_TIMBERDALE is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_ST_ASC is not set
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
# CONFIG_NVRAM is not set
CONFIG_DTLK=y
CONFIG_R3964=y
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
# CONFIG_IPWIRELESS is not set
CONFIG_MWAVE=y
CONFIG_SCx200_GPIO=y
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
# CONFIG_TCG_TIS is not set
CONFIG_TCG_TIS_I2C_INFINEON=y
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_ST33_I2C is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_GPIO is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_ELEKTOR=y
CONFIG_I2C_PCA_ISA=y
CONFIG_SCx200_I2C=y
CONFIG_SCx200_I2C_SCL=12
CONFIG_SCx200_I2C_SDA=13
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y
CONFIG_DP83640_PHY=y
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_IT8761E is not set
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_TS5500 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_RC5T583=y
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_TWL6040 is not set
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=y
CONFIG_GPIO_ADP5520=y
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_LANGWELL is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MCP23S08 is not set

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
# CONFIG_GPIO_TPS6586X is not set
# CONFIG_GPIO_TPS65910 is not set

#
# USB GPIO expanders:
#
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
CONFIG_WM8350_POWER=y
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_88PM860X=y
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27x00=y
CONFIG_BATTERY_BQ27X00_I2C=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_DA9052=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_88PM860X=y
CONFIG_CHARGER_PCF50633=y
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65090 is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_GPIO_FAN=y
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_HTU21=y
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
# CONFIG_SENSORS_LM85 is not set
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX6639=y
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_WM8350 is not set
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_CPU_THERMAL is not set
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=y
CONFIG_X86_PKG_TEMP_THERMAL=y

#
# Texas Instruments thermal drivers
#
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9063=y
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65090=y
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM8607=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AAT2870=y
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9063 is not set
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_MAX1586=y
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8973=y
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_RC5T583=y
# CONFIG_REGULATOR_S2MPS11 is not set
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65090=y
CONFIG_REGULATOR_TPS6586X=y
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_WM8350=y
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_MEDIA_CONTROLLER=y
CONFIG_VIDEO_DEV=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
# CONFIG_VIDEO_V4L2_INT_DEVICE is not set
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
CONFIG_V4L_PLATFORM_DRIVERS=y
# CONFIG_VIDEO_CAFE_CCIC is not set
# CONFIG_VIDEO_TIMBERDALE is not set
CONFIG_SOC_CAMERA=y
CONFIG_SOC_CAMERA_PLATFORM=y
# CONFIG_VIDEO_RCAR_VIN is not set
CONFIG_V4L_MEM2MEM_DRIVERS=y
# CONFIG_VIDEO_MEM2MEM_DEINTERLACE is not set
# CONFIG_VIDEO_SH_VEU is not set
CONFIG_V4L_TEST_DRIVERS=y
# CONFIG_VIDEO_VIVI is not set
CONFIG_VIDEO_MEM2MEM_TESTDEV=y

#
# Supported MMC/SDIO adapters
#
# CONFIG_MEDIA_PARPORT_SUPPORT is not set
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_SI470X=y
CONFIG_I2C_SI470X=y
# CONFIG_RADIO_MAXIRADIO is not set
# CONFIG_I2C_SI4713 is not set
# CONFIG_RADIO_SI4713 is not set
CONFIG_RADIO_TEA5764=y
# CONFIG_RADIO_TEA5764_XTAL is not set
CONFIG_RADIO_SAA7706H=y
# CONFIG_RADIO_TEF6862 is not set
CONFIG_RADIO_WL1273=y

#
# Texas Instruments WL128x FM driver (ST based)
#
# CONFIG_RADIO_WL128X is not set
CONFIG_V4L_RADIO_ISA_DRIVERS=y
CONFIG_RADIO_ISA=y
CONFIG_RADIO_CADET=y
CONFIG_RADIO_RTRACK=y
CONFIG_RADIO_RTRACK_PORT=30f
CONFIG_RADIO_RTRACK2=y
CONFIG_RADIO_RTRACK2_PORT=30c
# CONFIG_RADIO_AZTECH is not set
# CONFIG_RADIO_GEMTEK is not set
# CONFIG_RADIO_SF16FMI is not set
# CONFIG_RADIO_SF16FMR2 is not set
# CONFIG_RADIO_TERRATEC is not set
# CONFIG_RADIO_TRUST is not set
CONFIG_RADIO_TYPHOON=y
CONFIG_RADIO_TYPHOON_PORT=316
CONFIG_RADIO_TYPHOON_MUTEFREQ=87500
CONFIG_RADIO_ZOLTRIX=y
CONFIG_RADIO_ZOLTRIX_PORT=20c

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Miscelaneous helper chips
#

#
# Sensors used on soc_camera driver
#

#
# soc_camera sensor drivers
#
CONFIG_SOC_CAMERA_IMX074=y
# CONFIG_SOC_CAMERA_MT9M001 is not set
CONFIG_SOC_CAMERA_MT9M111=y
CONFIG_SOC_CAMERA_MT9T031=y
# CONFIG_SOC_CAMERA_MT9T112 is not set
CONFIG_SOC_CAMERA_MT9V022=y
CONFIG_SOC_CAMERA_OV2640=y
CONFIG_SOC_CAMERA_OV5642=y
# CONFIG_SOC_CAMERA_OV6650 is not set
CONFIG_SOC_CAMERA_OV772X=y
CONFIG_SOC_CAMERA_OV9640=y
CONFIG_SOC_CAMERA_OV9740=y
CONFIG_SOC_CAMERA_RJ54N1=y
# CONFIG_SOC_CAMERA_TW9910 is not set
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_HDMI=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
CONFIG_FB_BIG_ENDIAN=y
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=y
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_TMIO is not set
# CONFIG_FB_GOLDFISH is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
# CONFIG_BACKLIGHT_ADP5520 is not set
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_PCF50633=y
# CONFIG_BACKLIGHT_AAT2870 is not set
# CONFIG_BACKLIGHT_LM3630 is not set
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_MDA_CONSOLE=y
CONFIG_DUMMY_CONSOLE=y
# CONFIG_FRAMEBUFFER_CONSOLE is not set
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
# CONFIG_SND is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_ELECOM=y
CONFIG_HID_EZKEY=y
CONFIG_HID_KEYTOUCH=y
# CONFIG_HID_KYE is not set
CONFIG_HID_UCLOGIC=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LOGITECH=y
# CONFIG_HID_LOGITECH_DJ is not set
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
# CONFIG_HID_PETALYNX is not set
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PRIMAX=y
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
# CONFIG_HID_WACOM is not set
CONFIG_HID_WIIMOTE=y
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_AM335X_PHY_USB is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
# CONFIG_MMC_BLOCK_BOUNCE is not set
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_NET48XX=y
# CONFIG_LEDS_WRAP is not set
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_PWM=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
# CONFIG_LEDS_TRIGGER_IDE_DISK is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
# CONFIG_RTC_SYSTOHC is not set
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM860X is not set
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1374 is not set
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
# CONFIG_RTC_DRV_X1205 is not set
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=y
# CONFIG_RTC_DRV_TPS6586X is not set
# CONFIG_RTC_DRV_TPS65910 is not set
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
# CONFIG_RTC_DRV_MSM6242 is not set
CONFIG_RTC_DRV_BQ4802=y
# CONFIG_RTC_DRV_RP5C01 is not set
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_DS2404 is not set
# CONFIG_RTC_DRV_WM8350 is not set
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_MOXART is not set

#
# HID Sensor RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
# CONFIG_NET_DMA is not set
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
# CONFIG_UIO_DMEM_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_MF624 is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_GPIO=y
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT2_FS_XIP=y
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT23=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_FS_XIP=y
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
# CONFIG_REISERFS_FS_POSIX_ACL is not set
# CONFIG_REISERFS_FS_SECURITY is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
CONFIG_JFS_SECURITY=y
CONFIG_JFS_DEBUG=y
# CONFIG_JFS_STATISTICS is not set
# CONFIG_XFS_FS is not set
CONFIG_GFS2_FS=y
CONFIG_OCFS2_FS=y
# CONFIG_OCFS2_FS_O2CB is not set
CONFIG_OCFS2_DEBUG_MASKLOG=y
CONFIG_OCFS2_DEBUG_FS=y
# CONFIG_BTRFS_FS is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
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
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_FS is not set
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_SLUB_DEBUG_ON=y
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_WRITECOUNT is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_STRING_HELPERS=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
# CONFIG_CRYPTO_DEV_PADLOCK_AES is not set
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_GEODE is not set
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_AUDIT_GENERIC=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y

--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--wq9mPyueHGvFACwf--
