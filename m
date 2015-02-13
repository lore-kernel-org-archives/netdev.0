From: Josh Hunt <johunt@akamai.com>
Subject: softlockups when trying to restore an nft set of 1M entries
Date: Fri, 13 Feb 2015 05:59:19 -0600
Message-ID: <54DDE717.6090703@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In my testing of nftables sets for our netdev bof discussion I came=20
across this problem where if I try and do a set restore of 1M entries=20
the machine gets into a softlockup state. Once this is triggered the=20
system has to be rebooted.

I can trigger the case by generating a simple nft rules file which=20
defines a set of type ipv4_addr. Something like this:

flush ruleset
table ip filter {
         set blackhole {
                 type ipv4_addr
         }
         chain input {
                  type filter hook input priority 0;
         }

         chain forward {
                  type filter hook forward priority 0;
         }

         chain output {
                  type filter hook output priority 0;
         }
}

except inside the set definition above I add 1M random ipv4 addresses.=20
Running "nft -f <filename>" will reproduce the problem. I also saw this=
=20
when trying to do a restore of 250k entries.

There are a few problems going on from what I can tell. The first is
the set defaults to 4 buckets and during restores the # of buckets does=
=20
not increase. I'm currently investigating to understand why we don't=20
expand the set on restores. However my guess into why we're=20
softlockuping here is that we're trying to shove 1M entries into 4=20
buckets :)

Second, the user has no way to tune the # of initial buckets. My=20
patchset "nft hash set expansion fixes" fixes this. If I tune the hash=20
to use a reasonable # of buckets for 1M entries. I do not see the=20
softlockup problem.

I ran these tests using the current net-next.

Here's some of the softlockup output. Let me know if you'd like more=20
info, etc.

[  328.092675] NMI watchdog: BUG: soft lockup - CPU#4 stuck for 22s!=20
[nft:3921]
[  328.100185] Modules linked in: nft_hash nft_rbtree nf_tables_ipv4=20
nf_tables nfnetlink iptable_filter ip_tables x_tables dm_crypt=20
ipmi_devintf ipmi_msghandler i2c_dev ipv6 coretemp hwmon bnx2x ptp=20
pps_core i2c_i801 lpc_ich i2c_core mfd_core crc32c_generic crc32c_intel=
=20
ie31200_edac libcrc32c edac_core mdio ext4 jbd2 crc16 raid10 raid456=20
async_raid6_recov async_pq rai=EF=BF=BD6_pq async_xor xor async_memcpy =
async_tx=20
raid1 raid0 linear md_mod dm_mod ahci libahci libata mpt2sas=20
scsi_transport_sas raid_class
[  328.151902] CPU: 4 PID: 3921 Comm: nft Not tainted 3.19.0-rc7+ #28
[  328.158542] Hardware name: CIARA TECHNOLOGIES 1X8-X6 SSD 16G=20
10GE/S5530WG2NR-LE-2T-AKA, BIOS 7.008 14/04/2014
[  328.169289] task: ffff880407266210 ti: ffff880400ff0000 task.ti:=20
ffff880400ff0000
[  328.177609] RIP: 0010:[<ffffffff8134dd41>]  [<ffffffff8134dd41>]=20
memcmp+0x11/0x50
[  328.186043] RSP: 0018:ffff880400ff38d8  EFLAGS: 00000202
[  328.191811] RAX: 00000000000000f4 RBX: ffff88040f000340 RCX:=20
00000000000000e3
[  328.199407] RDX: 0000000000000004 RSI: ffff880400ff39f0 RDI:=20
ffff8803f37ce7e8
[  328.207000] RBP: ffff880400ff38d8 R08: 00000000000000d9 R09:=20
00000000ffffffdf
[  328.214593] R10: 0000000000000015 R11: dead000000100100 R12:=20
000412d000000010
[  328.222189] R13: 00000040=EF=BF=BD000000b R14: ffffffff000492d0 R15:=
=20
ffff880400ff3928
[  328.229781] FS:  00007f7ddf1d6700(0000) GS:ffff88041fd00000(0000)=20
knlGS:0000000000000000
[  328.238709] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  328.244909] CR2: 00007f3b0d890000 CR3: 000000040ae41000 CR4:=20
00000000001407e0
[  328.252505] DR0: 0000000000000000 DR1: 0000000000000000 DR2:=20
0000000000000000
[  328.260100] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:=20
0000000000000400
[  328.267692] Stack:
[  328.270171]  ffff880400ff3908 ffffffffa056160a ffff880400ff38f8=20
ffff8800379b2290
[  328.278805]  ffffffffa05615d0 ffff880400ff3968 ffff880400ff3958=20
ffffffff8135a25d
[  328.287437]  ffff88040c86a300 0495cff0a054a125 0000000000000000=20
ffff8800379b2200
[  328.296070] Call Trace:
[  328.298983]  [<ffffffffa056160a>] nft_hash_compare+0x3a/0x88 [nft_ha=
sh]
[  328.306054]  [<ffffffffa05615d0>] ? nft_hash_lookup+0x60/0x60 [nft_h=
ash]
[  328.313218]  [<ffffffff8135a25d>] rhashtable_lookup_compare+0x6d/0xb=
0
[  328.320118]  [<ffffffffa0561560>] nft_has=EF=BF=BD_get+0x30/0x40 [nf=
t_hash]
[  328.326846]  [<ffffffffa054a4d4>] nft_add_set_elem+0x164/0x3b0=20
[nf_tables]
[  328.334180]  [<ffffffffa0546fdc>] ? nft_trans_set_add+0x2c/0xa0=20
[nf_tables]
[  328.341602]  [<ffffffffa0561000>] ? 0xffffffffa0561000
[  328.347205]  [<ffffffffa054d85f>] ? nf_tables_newset+0x7df/0x8d0=20
[nf_tables]
[  328.354711]  [<ffffffff8136ca52>] ? nla_strcmp+0x42/0x50
[  328.360489]  [<ffffffffa0546b14>] ? nf_tables_table_lookup+0x44/0x80=
=20
[nf_tables]
[  328.368723]  [<ffffffffa054da1e>] nf_tables_newsetelem+0xce/0x170=20
[nf_tables]
[  328.376316]  [<ffffffffa054093c>] nfnetlink_rcv_batch+0x33c/0x430=20
[nfnetlink]
[  328.383913]  [<ffffffffa05406ed>] ? nfnetlink_rcv_batch+0xed/0x430=20
[nfnetlink]
[  328.391974]  [<ffffffffa0540abf>] nfnetlink_rcv+0x8f/0xc8 [nfnetlink=
]
[  328.398876]  [<ffffffff81568a92>] netlink_unicast+0x182/0x210
[  328.405082]  [<ffffffff81568f58>] netlink_sendmsg+0x378/0x3e0
[  328.411295]  [<ffffffff8151ec2f>] do_sock_sendmsg+0x8f/0xa0
[  328.417327]  [<ffffffff8151ec50>] sock_sendmsg+0x10/0x20
[  328.423097]  [<ffffffff81521655>] ___sys_sendmsg+0x315/0x330
[  328.429216]  [<ffffffff810daacc>] ? acct_account_cputime+0x1c/0x20
[  328.435859]  [<ffffffff81078f5d>] ? account_system_time+0x9d/0x190
[  328.442502]  [<ffffffff81078a55>] ? local_clock+0x25/0x30
[  328.448364]  [<ffffffff8109faf8>] ? rcu_eqs_enter+0x68/0x90
[  328.454399]  [<ffffffff810daacc>] ? acct_account_cputime+0x1c/0x20
[  328.461042]  [<ffffffff81078eb1>] ? account_user_time+0x91/0xa0
[  328.467423]  [<ffffffff81522469>] __sys_sendmsg+0x49/0x90
[  328.473287]  [<ffffffff81616dfd>] ? int_check_syscall_exit_work+0x34=
/0x3d
[  328.480534]  [<ffffffff815224c9>] SyS_sendmsg+0x19/0x20
[  328.486223]  [<ffffffff81616bd2>] system_call_fastpath+0x12/0x17
[  328.492690] Code: c3 66 0f 1f 84 00 00 00 00 00 31 c0 c6 06 00 5d c3=
=20
66 0f 1f 84 00 00 00 00 00 55 31 c0 48 85 d2 48 89 e5 74 2f 0f b6 07 0f=
=20
b6 0e <29> c8 75 25 48 83 ea 01 31 c9 eb 18 0f 1f 00 44 0f b6 4c 0f 01
[  331.718616] INFO: rcu_sched self-detected stall on CPU[  331.720614]=
=20
INFO: rcu_sched detected stalls on CPUs/tasks: { 4} (detected by 0,=20
t=3D30002 jiffies, g=3D6997, c=3D6996, q=3D0)
[  331.720617] Task dump for CPU 4:
[  331.720618] nft             R  running task        0  3921   3876=20
0x00080008
[  331.720620]  ffff88041fffad80 000000000001a5e8 000000000000003e=20
000000000000003f
[  331.720621]  0000000000000000 ffff8803f41ac000 ffff88040f000340=20
0000000000000000
[  331.720622]  0000000000000000 ffff88040f0012c0 ffff88040f000340=20
ffff880400ff3818
[  331.720623] Call Trace:
[  331.720625]  [<ffffffff8116d593>] ? kmem_getpages+0xb3/0x110
[  331.720629]  [<ffffffff8116ec26>] ? cache_grow+0x146/0x210
[  331.720630]  [<ffffffff8134dd3e>] ? memcmp+0xe/0x50
[  331.720634]  [<ffffffff8136ccf0>] ? nla_parse+0x90/0x110
[  331.720636]  [<ffffffffa056160a>] ? nft_hash_compare+0x3a/0x88 [nft_=
hash]
[  331.720638]  [<ffffffffa05615d0>] ? nft_hash_lookup+0x60/0x60 [nft_h=
ash]
[  331.720639]  [<ffffffff8135a25d>] ? rhashtable_lookup_compare+0x6d/0=
xb0
[  331.720641]  [<ffffffffa0=EF=BF=BD61560>] ? nf=EF=BF=BD_hash_get+0x3=
0/0x40 [nft_hash]
[  331.720642]  [<ffffffffa054a4d4>] ? nft_add_set_elem+0x164/0x3b0=20
[nf_tables]
[  331.720645]  [<ffffffffa0546fdc>] ? nft_trans_set_add+0x2c/0xa0=20
[nf_tables]
[  331.720647]  [<ffffffffa0561000>] ? 0xffffffffa0561000
[  331.720654]  [<ffffffffa054d85f>] ? nf_tables_newset+0x7df/0x8d0=20
[nf_tables]
[  331.720656]  [<ffffffff8136ca52>] ? nla_strcmp+0x42/0x50
[  331.720657]  [<ffffffffa0546b14>] ? nf_tables_table_lookup+0x44/0x80=
=20
[nf_tables]
[  331.720659]  [<ffffffffa054da1e>] ? nf_tables_newsetelem+0xce/0x170=20
[nf_tables]
[  331.720661]  [<ffffffffa054093c>] ? nfnetlink_rcv_atch+0x33c/0x430=20
[nfnetlink]
[  331.720663]  [<ffffffffa05406ed>] ? nfnetlink_rcv_batch+0xed/0x430=20
[nfnetlink]
[  331.720664]  [<ffffffffa0540abf>] ? nfnetlink_rcv+0x8f/0xc8 [nfnetli=
nk]
[  331.720665]  [<ffffffff81568a92>] ? netlink_unicast+0x182/0x210
[  331.720668]  [<ffffffff81568f58>] ? netlink_sendmsg+0x378/0x3e0
[  331.720670]  [<ffffffff8151ec2f>] ? do_sock_sendmsg+0x8f/0xa0
[  331.720672]  [<ffffffff8151ec50>] ? sock_sendmsg+0x10/0x20
[  331.720673]  [<ffffffff81521655>] ? ___sys_sendmsg+0x315/0x330
[  331.720675]  [<ffffffff810daacc>] ? acct_account_cputime+0x1c/0x20
[  331.720677]  [<ffffffff81078f5d>] ? account_system_time+0x9d/0x190
[  331.720679]  [<ffffffff81078a55>] ? local_clock+0x25/0x30
[  331.720680]  [<ffffffff8109faf8>] ? rcu_eqs_enter+0x68/0x90
[  331.720683]  [<ffffffff810daacc>] ? acct_account_cputime+0x1c/0x20
[  331.720684]  [<ffffffff81078eb1>] ? account_user_time+0x91/0xa0
[  331.720685]  [<ffffffff81522469>] ? __sys_sendmsg+0x49/0x90
[  331.720687]  [<ffffffff81616dfd>] ? int_check_syscall_exit_work+0x34=
/0x3d
[  331.720690]  [<ffffffff815224c9>] ? SyS_sendmsg+0x19/0x20
[  331.720691]  [<ffffffff81616bd2>] ? system_call_fastpath+0x12/0x17

Thanks
Josh
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
