From: kapil dakhane <kdakhane@gmail.com>
Subject: Infinite loop in inet_csk_get_port
Date: Thu, 18 Feb 2010 10:17:16 -0800
Message-ID: <99d458641002181017l1ab5f81es3b715a220ad79969@mail.gmail.com>
References: <99d458641002171105n34e3f053vd71941697b463a71@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <99d458641002171105n34e3f053vd71941697b463a71@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This is in continuation of my previous mail...

>From: kapil dakhane <kdakhane@gmail.com>
>Date: Mon, Nov 30, 2009 at 6:02 PM
>Subject: soft lockup in inet_csk_get_port
>To: netdev@vger.kernel.org
>Cc: netfilter@vger.kernel.org
>Hello,
>
>I am trying to analyze the capacity of linux network stack on x6270
>which has 16 Hyper threads on two 8-core Intel(r) Xeon(r) CPU.

This resulted in patch...

>From: Eric Dumazet <eric.dumazet@gmail.com>
>Date: Wed, Dec 2, 2009 at 7:08 AM
>Subject: [PATCH net-next-2.6] tcp: connect() race with timewait reuse
>To: David Miller <davem@davemloft.net>
>Cc: kdakhane@gmail.com, netdev@vger.kernel.org, netfilter@vger.kernel.=
org, Evgeniy Polyakov <zbr@ioremap.net>
>

The test is exactly same as before, except for following changes:
1. =A0linux kernel is now a snapshot of net-next jit maintained by
dave-miller. The snapshot was downloaded on Jan 28 tarball name is
net-next-2.6-d74340d.tar.gz, uname shows 2.6.33-rc5 as the kernel
version. This has all the fixes from the above mentioned patch.
2. Platform is now HS22, which is an IBM bladecenter blade with add-on
10 gb ethernet card from broadcom, "Broadcom Corporation NetXtreme II
BCM57710 10-Gigabit PCIe [Everest]". CPU is same as that in previous
tests "Intel(R) Xeon(R) CPU X5570 =A0@ 2.93GHz". Test routes both
ingress and egress traffic through this card, with the help of vlans.
As in previous tests, traffic was transparently captured, and
transparently forwarded.
3. Webproxy application now had business logic enabled as opposed to
just data forwarding as in previous tests.

Tuning parameters have remained same...

net.ipv4.tcp_keepalive_intvl =3D 5
net.ipv4.tcp_keepalive_probes =3D 3
net.ipv4.tcp_keepalive_time =3D 180
net.ipv4.tcp_fin_timeout =3D 10
net.ipv4.tcp_max_syn_backlog =3D 8192
net.ipv4.tcp_max_tw_buckets =3D 512000
net.ipv4.tcp_tw_reuse =3D 1
net.ipv4.tcp_tw_recycle =3D 1
net.ipv4.tcp_syncookies =3D 0
net.core.netdev_max_backlog =3D 5000

mpstat output shows that CPU 9 is stuck in infinite loop. This was
observed after the test was terminated.
10:22:36 AM =A0CPU =A0 %user =A0 %nice =A0 =A0%sys %iowait =A0 =A0%irq =
=A0 %soft
%steal =A0 %idle =A0 =A0intr/s
=2E..
10:22:38 AM =A0 =A09 =A0 =A00.00 =A0 =A00.00 =A0 =A00.00 =A0 =A00.00 =A0=
 =A00.00 =A0100.00
0.00 =A0 =A00.00 =A0 =A0 =A00.00
=2E..

=46eb 17 10:23:25 fusion-ch01-bl05 kernel: BUG: soft lockup - CPU#9
stuck for 61s! [webproxy:11957]
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: Modules linked in: xt_TPROXY
xt_tcpudp xt_MARK xt_socket nf_conntrack nf_defrag_ipv4 nf_tproxy_core
iptable_mangle ip_tables x_tables autofs4 hidp rfcomm l2cap crc16
bluetooth rfkill lockd sunrpc 8021q ipv6 dm_multipath scsi_dh video
output sbs sbshc battery acpi_memhotplug ac parport_pc lp parport
cdc_ether usbnet sg mii bnx2x serio_raw button tpm_tis tpm rtc_cmos
rtc_core tpm_bios rtc_lib mdio bnx2 i2c_i801 i2c_core pcspkr
dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod shpchp
mptsas mptscsih mptbase scsi_transport_sas sd_mod scsi_mod ext3 jbd
uhci_hcd ohci_hcd ehci_hcd [last unloaded: freq_table]
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: CPU 9
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: Pid: 11957, comm: webproxy
Tainted: G =A0 M =A0 =A0W =A02.6.33-rc5 #1 49Y5114 =A0 =A0 /IBM System =
x
-[7870AC1]-
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: RIP:
0010:[<ffffffff8129c590>] =A0[<ffffffff8129c590>]
inet_csk_bind_conflict+0x5f/0xa6
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: RSP: 0018:ffff880c17929e30
EFLAGS: 00000202
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: RAX: ffffffff81461a01 RBX:
ffff880c5d3205a0 RCX: ffff880bd45ef1e8
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: RDX: ffff880bd45ef1c0 RSI:
0000000000000000 RDI: ffff880674053300
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: RBP: ffffffff810031ce R08:
000000000001b20d R09: ffff880a8ecba128
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: R10: ffff880674053301 R11:
ffffffff81132b11 R12: ffff880c17929ee8
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: R13: ffff880c00000000 R14:
0000000000000000 R15: ffff880c17929d90
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: FS: =A000007fa55a6c6720(0000=
)
GS:ffff880028340000(0000) knlGS:0000000000000000
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: CS: =A00010 DS: 0000 ES: 000=
0
CR0: 0000000080050033
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: CR2: 00007fa5269c8000 CR3:
0000000c1bd12000 CR4: 00000000000006e0
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: Process webproxy (pid: 11957=
,
threadinfo ffff880c17928000, task ffff880c17b700c0)
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: Stack:
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0ffffffff8129c789
0000000000000000 0000000500000000 00000000ffffffff
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: <0> 0000000000000000
0000000000000000 ffff880674053300 00000000ffffffea
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: <0> 0000000000051005
0000000000000001 ffff880c17929ec8 00007fa55e4923f0
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: Call Trace:
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff8129c789>] ?
inet_csk_get_port+0x1b2/0x29e
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff812b9368>] ?
inet_bind+0x10c/0x1c1
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff8126497b>] ?
sys_bind+0x6e/0x9e
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff8106de32>] ?
audit_syscall_entry+0x1b9/0x1e4
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff8100286b>] ?
system_call_fastpath+0x16/0x1b
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: Code: 40 62 10 eb 04 f6 42 5=
4
01 75 44 8b 77 20 85 f6 74 0b 8b 42 20 85 c0 74 04 39 c6 75 32 45 84
d2 74 0d 80 7a 1f 00 74 07 8a 42 1e <3c> 0a 75 20 8a 42 1e 3c 06 74 08
8b 82 24 02 00 00 eb 03 8b 42
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: Call Trace:
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff8129c789>] ?
inet_csk_get_port+0x1b2/0x29e
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff812b9368>] ?
inet_bind+0x10c/0x1c1
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff8126497b>] ?
sys_bind+0x6e/0x9e
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff8106de32>] ?
audit_syscall_entry+0x1b9/0x1e4
=46eb 17 10:23:25 fusion-ch01-bl05 kernel: =A0[<ffffffff8100286b>] ?
system_call_fastpath+0x16/0x1b
=46eb 17 10:23:25 fusion-ch01-bl05 kernel:
[bnx2x_timer:4677(eth3)]drv_pulse (0x3104) !=3D mcp_pulse (0x3854)
=46eb 17 10:23:26 fusion-ch01-bl05 kernel:
[bnx2x_timer:4677(eth3)]drv_pulse (0x3105) !=3D mcp_pulse (0x3854)
=46eb 17 10:23:27 fusion-ch01-bl05 kernel:
[bnx2x_timer:4677(eth3)]drv_pulse (0x3106) !=3D mcp_pulse (0x3854)
=46eb 17 10:23:28 fusion-ch01-bl05 kernel:
[bnx2x_timer:4677(eth3)]drv_pulse (0x3107) !=3D mcp_pulse (0x3854)

These messages keep repeating every 60 seconds.

To me this feels like that there are more code paths which lead to the
same corruption as in previous issue.

Regards,
Kapil
