From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/sctp: vmalloc allocation failure in sctp_setsockopt/xt_alloc_table_info
Date: Mon, 28 Nov 2016 14:00:19 +0100
Message-ID: <CAAeHK+wecw6ST_DWJQBLFNwVsOVgderGE-EEJiN0-kf796XHtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114b0bded70fcb05425c0d02
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33829 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932415AbcK1NAW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 08:00:22 -0500
Received: by mail-lf0-f45.google.com with SMTP id o141so95548280lff.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 05:00:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114b0bded70fcb05425c0d02
Content-Type: text/plain; charset=UTF-8

Hi!

I've got the following error report while running the syzkaller fuzzer.

On commit d8e435f3ab6fea2ea324dce72b51dd7761747523 (Nov 26).

A reproducer is attached.

a.out: vmalloc: allocation failure, allocated 823562240 of 1427091456
bytes, mode:0x24000c2(GFP_KERNEL|__GFP_HIGHMEM)

oom_reaper: reaped process 3810 (a.out), now anon-rss:0kB,
file-rss:0kB, shmem-rss:0kB
a.out invoked oom-killer:
gfp_mask=0x24002c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_NOWARN), nodemask=0,
order=0, oom_score_adj=0
a.out cpuset=/ mems_allowed=0
CPU: 0 PID: 3814 Comm: a.out Not tainted 4.9.0-rc6+ #457
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff880068667380 ffffffff81c73b14 ffff880068667710 ffff88006b469018
 ffff880068667718 0000000000000000 ffff880068667400 ffffffff81641a87
 0000000000000000 0000000000000000 0000000000000297 ffffffff84d37280
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81c73b14>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<ffffffff81641a87>] dump_header.isra.21+0x16f/0x5f5 mm/oom_kill.c:416
 [<ffffffff8154bad8>] oom_kill_process+0x4d8/0xab0 mm/oom_kill.c:835
 [<ffffffff8154c77c>] out_of_memory+0x2dc/0x1790 mm/oom_kill.c:1044
 [<     inline     >] __alloc_pages_may_oom mm/page_alloc.c:3086
 [<ffffffff8155afb6>] __alloc_pages_slowpath+0x1886/0x1bf0 mm/page_alloc.c:3683
 [<ffffffff8155b8e2>] __alloc_pages_nodemask+0x5c2/0x710 mm/page_alloc.c:3781
 [<ffffffff816236a4>] alloc_pages_current+0xf4/0x400 mm/mempolicy.c:2072
 [<     inline     >] alloc_pages ./include/linux/gfp.h:469
 [<     inline     >] __vmalloc_area_node mm/vmalloc.c:1631
 [<ffffffff815f8eab>] __vmalloc_node_range+0x33b/0x690 mm/vmalloc.c:1691
 [<     inline     >] __vmalloc_node mm/vmalloc.c:1734
 [<     inline     >] __vmalloc_node_flags mm/vmalloc.c:1748
 [<ffffffff815f92cb>] vmalloc+0x5b/0x70 mm/vmalloc.c:1763
 [<ffffffff82fd0893>] xt_alloc_table_info+0x83/0x120
net/netfilter/x_tables.c:961
 [<     inline     >] do_replace net/ipv4/netfilter/ip_tables.c:1140
 [<ffffffff8335b420>] do_ipt_set_ctl+0x210/0x420
net/ipv4/netfilter/ip_tables.c:1687
 [<     inline     >] nf_sockopt net/netfilter/nf_sockopt.c:105
 [<ffffffff82efdab7>] nf_setsockopt+0x67/0xc0 net/netfilter/nf_sockopt.c:114
 [<ffffffff831be741>] ip_setsockopt+0xa1/0xb0 net/ipv4/ip_sockglue.c:1231
 [<ffffffff832700d5>] udp_setsockopt+0x45/0x80 net/ipv4/udp.c:2085
 [<ffffffff8346b31f>] ipv6_setsockopt+0x11f/0x140 net/ipv6/ipv6_sockglue.c:892
 [<ffffffff83a6cd5d>] sctp_setsockopt+0x15d/0x3d70 net/sctp/socket.c:3788
 [<ffffffff82ca40e6>] sock_common_setsockopt+0x96/0xd0 net/core/sock.c:2690
 [<     inline     >] SYSC_setsockopt net/socket.c:1757
 [<ffffffff82ca10c4>] SyS_setsockopt+0x154/0x240 net/socket.c:1736
 [<ffffffff840f2c41>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
CPU: 1 PID: 3810 Comm: a.out Not tainted 4.9.0-rc6+ #457
Mem-Info:
active_anon:1938 inactive_anon:75 isolated_anon:0
 active_file:14 inactive_file:30 isolated_file:4
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:3316 slab_unreclaimable:9767
 mapped:21 shmem:81 pagetables:309 bounce:0
 free:1 free_pcp:75 free_cma:0
Node 0 active_anon:7752kB inactive_anon:300kB active_file:56kB
inactive_file:120kB unevictable:0kB isolated(anon):0kB
isolated(file):16kB mapped:84kB dirty:0kB writeback:0kB shmem:324kB
writeback_tmp:0kB unstable:0kB pages_scanned:134 all_unreclaimable? no
Node 0 DMA free:4kB min:48kB low:60kB high:72kB active_anon:0kB
inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
writepending:0kB present:15992kB managed:15908kB mlocked:0kB
slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB
pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 1641 1641 1641
Node 0 DMA32 free:0kB min:5156kB low:6836kB high:8516kB
active_anon:7752kB inactive_anon:300kB active_file:56kB
inactive_file:120kB unevictable:0kB writepending:0kB present:2080760kB
managed:1684640kB mlocked:0kB slab_reclaimable:13264kB
slab_unreclaimable:39060kB kernel_stack:2944kB pagetables:1236kB
bounce:0kB free_pcp:300kB local_pcp:120kB free_cma:0kB
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB = 0kB
Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB = 0kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
148 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
524188 pages RAM
0 pages HighMem/MovableOnly
99051 pages reserved
[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents
oom_score_adj name
    0  1767     5346      133      16       3        0         -1000 udevd
    0  1876     5315      122      15       3        0         -1000 udevd
    0  1877     5315      122      15       3        0         -1000 udevd
    0  3541     2493      573       8       3        0             0 dhclient
    0  3676    13231      171      22       3        0             0 rsyslogd
    0  3725     4725       52      15       3        0             0 cron
    0  3751    12490      155      28       3        0         -1000 sshd
    0  3775     3694       43      13       3        0             0 getty
    0  3776     3694       43      13       3        0             0 getty
    0  3777     3694       42      13       3        0             0 getty
    0  3778     3694       41      13       3        0             0 getty
    0  3779     3694       44      13       3        0             0 getty
    0  3780     3694       43      13       3        0             0 getty
    0  3785     3649       44      12       3        0             0 getty
    0  3797    17818      205      39       3        0             0 sshd
    0  3800     4474      126      15       3        0             0 bash
    0  3804     2053       22       9       3        0             0 a.out
    0  3805     2053       26       9       3        0             0 a.out
    0  3806    18488        0      18       3        0             0 a.out

--001a114b0bded70fcb05425c0d02
Content-Type: text/x-csrc; charset=US-ASCII; name="vmalloc-crash-poc.c"
Content-Disposition: attachment; filename="vmalloc-crash-poc.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iw22yf750

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCgojaWZuZGVmIF9fTlJfbW1hcAojZGVmaW5lIF9fTlJfbW1hcCA5CiNlbmRpZgoj
aWZuZGVmIF9fTlJfc2V0c29ja29wdAojZGVmaW5lIF9fTlJfc2V0c29ja29wdCA1NAojZW5kaWYK
I2lmbmRlZiBfX05SX3N5el9mdXNlX21vdW50CiNkZWZpbmUgX19OUl9zeXpfZnVzZV9tb3VudCAx
MDAwMDA0CiNlbmRpZgojaWZuZGVmIF9fTlJfc29ja2V0CiNkZWZpbmUgX19OUl9zb2NrZXQgNDEK
I2VuZGlmCiNpZm5kZWYgX19OUl9zeXpfZW1pdF9ldGhlcm5ldAojZGVmaW5lIF9fTlJfc3l6X2Vt
aXRfZXRoZXJuZXQgMTAwMDAwNgojZW5kaWYKI2lmbmRlZiBfX05SX3N5el9mdXNlYmxrX21vdW50
CiNkZWZpbmUgX19OUl9zeXpfZnVzZWJsa19tb3VudCAxMDAwMDA1CiNlbmRpZgojaWZuZGVmIF9f
TlJfc3l6X29wZW5fZGV2CiNkZWZpbmUgX19OUl9zeXpfb3Blbl9kZXYgMTAwMDAwMgojZW5kaWYK
I2lmbmRlZiBfX05SX3N5el9vcGVuX3B0cwojZGVmaW5lIF9fTlJfc3l6X29wZW5fcHRzIDEwMDAw
MDMKI2VuZGlmCiNpZm5kZWYgX19OUl9zeXpfdGVzdAojZGVmaW5lIF9fTlJfc3l6X3Rlc3QgMTAw
MDAwMQojZW5kaWYKCiNkZWZpbmUgU1laX1NBTkRCT1hfTk9ORSAxCiNkZWZpbmUgU1laX1JFUEVB
VCAxCgojZGVmaW5lIF9HTlVfU09VUkNFCgojaW5jbHVkZSA8c3lzL2lvY3RsLmg+CiNpbmNsdWRl
IDxzeXMvbW91bnQuaD4KI2luY2x1ZGUgPHN5cy9wcmN0bC5oPgojaW5jbHVkZSA8c3lzL3Jlc291
cmNlLmg+CiNpbmNsdWRlIDxzeXMvc29ja2V0Lmg+CiNpbmNsdWRlIDxzeXMvc3RhdC5oPgojaW5j
bHVkZSA8c3lzL3N5c2NhbGwuaD4KI2luY2x1ZGUgPHN5cy90aW1lLmg+CiNpbmNsdWRlIDxzeXMv
dHlwZXMuaD4KI2luY2x1ZGUgPHN5cy93YWl0Lmg+CgojaW5jbHVkZSA8bGludXgvY2FwYWJpbGl0
eS5oPgojaW5jbHVkZSA8bGludXgvaWYuaD4KI2luY2x1ZGUgPGxpbnV4L2lmX3R1bi5oPgojaW5j
bHVkZSA8bGludXgvc2NoZWQuaD4KI2luY2x1ZGUgPG5ldC9pZl9hcnAuaD4KCiNpbmNsdWRlIDxh
c3NlcnQuaD4KI2luY2x1ZGUgPGRpcmVudC5oPgojaW5jbHVkZSA8ZXJybm8uaD4KI2luY2x1ZGUg
PGZjbnRsLmg+CiNpbmNsdWRlIDxncnAuaD4KI2luY2x1ZGUgPHB0aHJlYWQuaD4KI2luY2x1ZGUg
PHNldGptcC5oPgojaW5jbHVkZSA8c2lnbmFsLmg+CiNpbmNsdWRlIDxzdGRhcmcuaD4KI2luY2x1
ZGUgPHN0ZGRlZi5oPgojaW5jbHVkZSA8c3RkaW50Lmg+CiNpbmNsdWRlIDxzdGRpby5oPgojaW5j
bHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1ZGUgPHVuaXN0ZC5oPgoK
Y29uc3QgaW50IGtGYWlsU3RhdHVzID0gNjc7CmNvbnN0IGludCBrRXJyb3JTdGF0dXMgPSA2ODsK
Y29uc3QgaW50IGtSZXRyeVN0YXR1cyA9IDY5OwoKX19hdHRyaWJ1dGVfXygobm9yZXR1cm4pKSB2
b2lkIGZhaWwoY29uc3QgY2hhciogbXNnLCAuLi4pCnsKICBpbnQgZSA9IGVycm5vOwogIGZmbHVz
aChzdGRvdXQpOwogIHZhX2xpc3QgYXJnczsKICB2YV9zdGFydChhcmdzLCBtc2cpOwogIHZmcHJp
bnRmKHN0ZGVyciwgbXNnLCBhcmdzKTsKICB2YV9lbmQoYXJncyk7CiAgZnByaW50ZihzdGRlcnIs
ICIgKGVycm5vICVkKVxuIiwgZSk7CiAgZXhpdChrRmFpbFN0YXR1cyk7Cn0KCl9fYXR0cmlidXRl
X18oKG5vcmV0dXJuKSkgdm9pZCBleGl0Zihjb25zdCBjaGFyKiBtc2csIC4uLikKewogIGludCBl
ID0gZXJybm87CiAgZmZsdXNoKHN0ZG91dCk7CiAgdmFfbGlzdCBhcmdzOwogIHZhX3N0YXJ0KGFy
Z3MsIG1zZyk7CiAgdmZwcmludGYoc3RkZXJyLCBtc2csIGFyZ3MpOwogIHZhX2VuZChhcmdzKTsK
ICBmcHJpbnRmKHN0ZGVyciwgIiAoZXJybm8gJWQpXG4iLCBlKTsKICBleGl0KGtSZXRyeVN0YXR1
cyk7Cn0KCnN0YXRpYyBpbnQgZmxhZ19kZWJ1ZzsKCnZvaWQgZGVidWcoY29uc3QgY2hhciogbXNn
LCAuLi4pCnsKICBpZiAoIWZsYWdfZGVidWcpCiAgICByZXR1cm47CiAgdmFfbGlzdCBhcmdzOwog
IHZhX3N0YXJ0KGFyZ3MsIG1zZyk7CiAgdmZwcmludGYoc3Rkb3V0LCBtc2csIGFyZ3MpOwogIHZh
X2VuZChhcmdzKTsKICBmZmx1c2goc3Rkb3V0KTsKfQoKX190aHJlYWQgaW50IHNraXBfc2VndjsK
X190aHJlYWQgam1wX2J1ZiBzZWd2X2VudjsKCnN0YXRpYyB2b2lkIHNlZ3ZfaGFuZGxlcihpbnQg
c2lnLCBzaWdpbmZvX3QqIGluZm8sIHZvaWQqIHVjdHgpCnsKICBpZiAoX19hdG9taWNfbG9hZF9u
KCZza2lwX3NlZ3YsIF9fQVRPTUlDX1JFTEFYRUQpKQogICAgX2xvbmdqbXAoc2Vndl9lbnYsIDEp
OwogIGV4aXQoc2lnKTsKfQoKc3RhdGljIHZvaWQgaW5zdGFsbF9zZWd2X2hhbmRsZXIoKQp7CiAg
c3RydWN0IHNpZ2FjdGlvbiBzYTsKICBtZW1zZXQoJnNhLCAwLCBzaXplb2Yoc2EpKTsKICBzYS5z
YV9zaWdhY3Rpb24gPSBzZWd2X2hhbmRsZXI7CiAgc2Euc2FfZmxhZ3MgPSBTQV9OT0RFRkVSIHwg
U0FfU0lHSU5GTzsKICBzaWdhY3Rpb24oU0lHU0VHViwgJnNhLCBOVUxMKTsKICBzaWdhY3Rpb24o
U0lHQlVTLCAmc2EsIE5VTEwpOwp9CgojZGVmaW5lIE5PTkZBSUxJTkcoLi4uKSAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwKICB7ICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBcCiAg
ICBfX2F0b21pY19mZXRjaF9hZGQoJnNraXBfc2VndiwgMSwgX19BVE9NSUNfU0VRX0NTVCk7ICAg
ICAgICAgICAgICAgXAogICAgaWYgKF9zZXRqbXAoc2Vndl9lbnYpID09IDApIHsgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwKICAgICAgX19WQV9BUkdTX187ICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBcCiAgICB9ICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgXAogICAgX19hdG9taWNfZmV0Y2hfc3ViKCZza2lwX3NlZ3YsIDEsIF9fQVRPTUlDX1NFUV9D
U1QpOyAgICAgICAgICAgICAgIFwKICB9CgpzdGF0aWMgdWludHB0cl90IHN5el9vcGVuX2Rldih1
aW50cHRyX3QgYTAsIHVpbnRwdHJfdCBhMSwgdWludHB0cl90IGEyKQp7CiAgaWYgKGEwID09IDB4
YyB8fCBhMCA9PSAweGIpIHsKICAgIGNoYXIgYnVmWzEyOF07CiAgICBzcHJpbnRmKGJ1ZiwgIi9k
ZXYvJXMvJWQ6JWQiLCBhMCA9PSAweGMgPyAiY2hhciIgOiAiYmxvY2siLAogICAgICAgICAgICAo
dWludDhfdClhMSwgKHVpbnQ4X3QpYTIpOwogICAgcmV0dXJuIG9wZW4oYnVmLCBPX1JEV1IsIDAp
OwogIH0gZWxzZSB7CiAgICBjaGFyIGJ1ZlsxMDI0XTsKICAgIGNoYXIqIGhhc2g7CiAgICBzdHJu
Y3B5KGJ1ZiwgKGNoYXIqKWEwLCBzaXplb2YoYnVmKSk7CiAgICBidWZbc2l6ZW9mKGJ1ZikgLSAx
XSA9IDA7CiAgICB3aGlsZSAoKGhhc2ggPSBzdHJjaHIoYnVmLCAnIycpKSkgewogICAgICAqaGFz
aCA9ICcwJyArIChjaGFyKShhMSAlIDEwKTsKICAgICAgYTEgLz0gMTA7CiAgICB9CiAgICByZXR1
cm4gb3BlbihidWYsIGEyLCAwKTsKICB9Cn0KCnN0YXRpYyB1aW50cHRyX3Qgc3l6X29wZW5fcHRz
KHVpbnRwdHJfdCBhMCwgdWludHB0cl90IGExKQp7CiAgaW50IHB0eW5vID0gMDsKICBpZiAoaW9j
dGwoYTAsIFRJT0NHUFROLCAmcHR5bm8pKQogICAgcmV0dXJuIC0xOwogIGNoYXIgYnVmWzEyOF07
CiAgc3ByaW50ZihidWYsICIvZGV2L3B0cy8lZCIsIHB0eW5vKTsKICByZXR1cm4gb3BlbihidWYs
IGExLCAwKTsKfQoKc3RhdGljIHVpbnRwdHJfdCBzeXpfZnVzZV9tb3VudCh1aW50cHRyX3QgYTAs
IHVpbnRwdHJfdCBhMSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB1aW50cHRyX3Qg
YTIsIHVpbnRwdHJfdCBhMywKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB1aW50cHRy
X3QgYTQsIHVpbnRwdHJfdCBhNSkKewogIHVpbnQ2NF90IHRhcmdldCA9IGEwOwogIHVpbnQ2NF90
IG1vZGUgPSBhMTsKICB1aW50NjRfdCB1aWQgPSBhMjsKICB1aW50NjRfdCBnaWQgPSBhMzsKICB1
aW50NjRfdCBtYXhyZWFkID0gYTQ7CiAgdWludDY0X3QgZmxhZ3MgPSBhNTsKCiAgaW50IGZkID0g
b3BlbigiL2Rldi9mdXNlIiwgT19SRFdSKTsKICBpZiAoZmQgPT0gLTEpCiAgICByZXR1cm4gZmQ7
CiAgY2hhciBidWZbMTAyNF07CiAgc3ByaW50ZihidWYsICJmZD0lZCx1c2VyX2lkPSVsZCxncm91
cF9pZD0lbGQscm9vdG1vZGU9MCVvIiwgZmQsCiAgICAgICAgICAobG9uZyl1aWQsIChsb25nKWdp
ZCwgKHVuc2lnbmVkKW1vZGUgJiB+M3UpOwogIGlmIChtYXhyZWFkICE9IDApCiAgICBzcHJpbnRm
KGJ1ZiArIHN0cmxlbihidWYpLCAiLG1heF9yZWFkPSVsZCIsIChsb25nKW1heHJlYWQpOwogIGlm
IChtb2RlICYgMSkKICAgIHN0cmNhdChidWYsICIsZGVmYXVsdF9wZXJtaXNzaW9ucyIpOwogIGlm
IChtb2RlICYgMikKICAgIHN0cmNhdChidWYsICIsYWxsb3dfb3RoZXIiKTsKICBzeXNjYWxsKFNZ
U19tb3VudCwgIiIsIHRhcmdldCwgImZ1c2UiLCBmbGFncywgYnVmKTsKICByZXR1cm4gZmQ7Cn0K
CnN0YXRpYyB1aW50cHRyX3Qgc3l6X2Z1c2VibGtfbW91bnQodWludHB0cl90IGEwLCB1aW50cHRy
X3QgYTEsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdWludHB0cl90IGEyLCB1
aW50cHRyX3QgYTMsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdWludHB0cl90
IGE0LCB1aW50cHRyX3QgYTUsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdWlu
dHB0cl90IGE2LCB1aW50cHRyX3QgYTcpCnsKICB1aW50NjRfdCB0YXJnZXQgPSBhMDsKICB1aW50
NjRfdCBibGtkZXYgPSBhMTsKICB1aW50NjRfdCBtb2RlID0gYTI7CiAgdWludDY0X3QgdWlkID0g
YTM7CiAgdWludDY0X3QgZ2lkID0gYTQ7CiAgdWludDY0X3QgbWF4cmVhZCA9IGE1OwogIHVpbnQ2
NF90IGJsa3NpemUgPSBhNjsKICB1aW50NjRfdCBmbGFncyA9IGE3OwoKICBpbnQgZmQgPSBvcGVu
KCIvZGV2L2Z1c2UiLCBPX1JEV1IpOwogIGlmIChmZCA9PSAtMSkKICAgIHJldHVybiBmZDsKICBp
ZiAoc3lzY2FsbChTWVNfbWtub2RhdCwgQVRfRkRDV0QsIGJsa2RldiwgU19JRkJMSywgbWFrZWRl
dig3LCAxOTkpKSkKICAgIHJldHVybiBmZDsKICBjaGFyIGJ1ZlsyNTZdOwogIHNwcmludGYoYnVm
LCAiZmQ9JWQsdXNlcl9pZD0lbGQsZ3JvdXBfaWQ9JWxkLHJvb3Rtb2RlPTAlbyIsIGZkLAogICAg
ICAgICAgKGxvbmcpdWlkLCAobG9uZylnaWQsICh1bnNpZ25lZCltb2RlICYgfjN1KTsKICBpZiAo
bWF4cmVhZCAhPSAwKQogICAgc3ByaW50ZihidWYgKyBzdHJsZW4oYnVmKSwgIixtYXhfcmVhZD0l
bGQiLCAobG9uZyltYXhyZWFkKTsKICBpZiAoYmxrc2l6ZSAhPSAwKQogICAgc3ByaW50ZihidWYg
KyBzdHJsZW4oYnVmKSwgIixibGtzaXplPSVsZCIsIChsb25nKWJsa3NpemUpOwogIGlmIChtb2Rl
ICYgMSkKICAgIHN0cmNhdChidWYsICIsZGVmYXVsdF9wZXJtaXNzaW9ucyIpOwogIGlmIChtb2Rl
ICYgMikKICAgIHN0cmNhdChidWYsICIsYWxsb3dfb3RoZXIiKTsKICBzeXNjYWxsKFNZU19tb3Vu
dCwgYmxrZGV2LCB0YXJnZXQsICJmdXNlYmxrIiwgZmxhZ3MsIGJ1Zik7CiAgcmV0dXJuIGZkOwp9
CgpzdGF0aWMgdWludHB0cl90IGV4ZWN1dGVfc3lzY2FsbChpbnQgbnIsIHVpbnRwdHJfdCBhMCwg
dWludHB0cl90IGExLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB1aW50cHRyX3Qg
YTIsIHVpbnRwdHJfdCBhMywKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdWludHB0
cl90IGE0LCB1aW50cHRyX3QgYTUsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVp
bnRwdHJfdCBhNiwgdWludHB0cl90IGE3LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICB1aW50cHRyX3QgYTgpCnsKICBzd2l0Y2ggKG5yKSB7CiAgZGVmYXVsdDoKICAgIHJldHVybiBz
eXNjYWxsKG5yLCBhMCwgYTEsIGEyLCBhMywgYTQsIGE1KTsKICBjYXNlIF9fTlJfc3l6X3Rlc3Q6
CiAgICByZXR1cm4gMDsKICBjYXNlIF9fTlJfc3l6X29wZW5fZGV2OgogICAgcmV0dXJuIHN5el9v
cGVuX2RldihhMCwgYTEsIGEyKTsKICBjYXNlIF9fTlJfc3l6X29wZW5fcHRzOgogICAgcmV0dXJu
IHN5el9vcGVuX3B0cyhhMCwgYTEpOwogIGNhc2UgX19OUl9zeXpfZnVzZV9tb3VudDoKICAgIHJl
dHVybiBzeXpfZnVzZV9tb3VudChhMCwgYTEsIGEyLCBhMywgYTQsIGE1KTsKICBjYXNlIF9fTlJf
c3l6X2Z1c2VibGtfbW91bnQ6CiAgICByZXR1cm4gc3l6X2Z1c2VibGtfbW91bnQoYTAsIGExLCBh
MiwgYTMsIGE0LCBhNSwgYTYsIGE3KTsKICB9Cn0KCnN0YXRpYyB2b2lkIHNldHVwX21haW5fcHJv
Y2VzcygpCnsKICBzdHJ1Y3Qgc2lnYWN0aW9uIHNhOwogIG1lbXNldCgmc2EsIDAsIHNpemVvZihz
YSkpOwogIHNhLnNhX2hhbmRsZXIgPSBTSUdfSUdOOwogIHN5c2NhbGwoU1lTX3J0X3NpZ2FjdGlv
biwgMHgyMCwgJnNhLCBOVUxMLCA4KTsKICBzeXNjYWxsKFNZU19ydF9zaWdhY3Rpb24sIDB4MjEs
ICZzYSwgTlVMTCwgOCk7CiAgaW5zdGFsbF9zZWd2X2hhbmRsZXIoKTsKCiAgY2hhciB0bXBkaXJf
dGVtcGxhdGVbXSA9ICIuL3N5emthbGxlci5YWFhYWFgiOwogIGNoYXIqIHRtcGRpciA9IG1rZHRl
bXAodG1wZGlyX3RlbXBsYXRlKTsKICBpZiAoIXRtcGRpcikKICAgIGZhaWwoImZhaWxlZCB0byBt
a2R0ZW1wIik7CiAgaWYgKGNobW9kKHRtcGRpciwgMDc3NykpCiAgICBmYWlsKCJmYWlsZWQgdG8g
Y2htb2QiKTsKICBpZiAoY2hkaXIodG1wZGlyKSkKICAgIGZhaWwoImZhaWxlZCB0byBjaGRpciIp
Owp9CgpzdGF0aWMgdm9pZCBsb29wKCk7CgpzdGF0aWMgdm9pZCBzYW5kYm94X2NvbW1vbigpCnsK
ICBwcmN0bChQUl9TRVRfUERFQVRIU0lHLCBTSUdLSUxMLCAwLCAwLCAwKTsKICBzZXRwZ3JwKCk7
CiAgc2V0c2lkKCk7CgogIHN0cnVjdCBybGltaXQgcmxpbTsKICBybGltLnJsaW1fY3VyID0gcmxp
bS5ybGltX21heCA9IDEyOCA8PCAyMDsKICBzZXRybGltaXQoUkxJTUlUX0FTLCAmcmxpbSk7CiAg
cmxpbS5ybGltX2N1ciA9IHJsaW0ucmxpbV9tYXggPSAxIDw8IDIwOwogIHNldHJsaW1pdChSTElN
SVRfRlNJWkUsICZybGltKTsKICBybGltLnJsaW1fY3VyID0gcmxpbS5ybGltX21heCA9IDEgPDwg
MjA7CiAgc2V0cmxpbWl0KFJMSU1JVF9TVEFDSywgJnJsaW0pOwogIHJsaW0ucmxpbV9jdXIgPSBy
bGltLnJsaW1fbWF4ID0gMDsKICBzZXRybGltaXQoUkxJTUlUX0NPUkUsICZybGltKTsKCiAgdW5z
aGFyZShDTE9ORV9ORVdOUyk7CiAgdW5zaGFyZShDTE9ORV9ORVdJUEMpOwogIHVuc2hhcmUoQ0xP
TkVfSU8pOwp9CgpzdGF0aWMgaW50IGRvX3NhbmRib3hfbm9uZSgpCnsKICBpbnQgcGlkID0gZm9y
aygpOwogIGlmIChwaWQpCiAgICByZXR1cm4gcGlkOwogIHNhbmRib3hfY29tbW9uKCk7CiAgbG9v
cCgpOwogIGV4aXQoMSk7Cn0KCnN0YXRpYyB2b2lkIHJlbW92ZV9kaXIoY29uc3QgY2hhciogZGly
KQp7CiAgRElSKiBkcDsKICBzdHJ1Y3QgZGlyZW50KiBlcDsKICBpbnQgaXRlciA9IDA7CiAgaW50
IGk7CnJldHJ5OgogIGRwID0gb3BlbmRpcihkaXIpOwogIGlmIChkcCA9PSBOVUxMKSB7CiAgICBp
ZiAoZXJybm8gPT0gRU1GSUxFKSB7CiAgICAgIGV4aXRmKCJvcGVuZGlyKCVzKSBmYWlsZWQgZHVl
IHRvIE5PRklMRSwgZXhpdGluZyIpOwogICAgfQogICAgZXhpdGYoIm9wZW5kaXIoJXMpIGZhaWxl
ZCIsIGRpcik7CiAgfQogIHdoaWxlICgoZXAgPSByZWFkZGlyKGRwKSkpIHsKICAgIGlmIChzdHJj
bXAoZXAtPmRfbmFtZSwgIi4iKSA9PSAwIHx8IHN0cmNtcChlcC0+ZF9uYW1lLCAiLi4iKSA9PSAw
KQogICAgICBjb250aW51ZTsKICAgIGNoYXIgZmlsZW5hbWVbRklMRU5BTUVfTUFYXTsKICAgIHNu
cHJpbnRmKGZpbGVuYW1lLCBzaXplb2YoZmlsZW5hbWUpLCAiJXMvJXMiLCBkaXIsIGVwLT5kX25h
bWUpOwogICAgc3RydWN0IHN0YXQgc3Q7CiAgICBpZiAobHN0YXQoZmlsZW5hbWUsICZzdCkpCiAg
ICAgIGV4aXRmKCJsc3RhdCglcykgZmFpbGVkIiwgZmlsZW5hbWUpOwogICAgaWYgKFNfSVNESVIo
c3Quc3RfbW9kZSkpIHsKICAgICAgcmVtb3ZlX2RpcihmaWxlbmFtZSk7CiAgICAgIGNvbnRpbnVl
OwogICAgfQogICAgZm9yIChpID0gMDs7IGkrKykgewogICAgICBkZWJ1ZygidW5saW5rKCVzKVxu
IiwgZmlsZW5hbWUpOwogICAgICBpZiAodW5saW5rKGZpbGVuYW1lKSA9PSAwKQogICAgICAgIGJy
ZWFrOwogICAgICBpZiAoZXJybm8gPT0gRVJPRlMpIHsKICAgICAgICBkZWJ1ZygiaWdub3Jpbmcg
RVJPRlNcbiIpOwogICAgICAgIGJyZWFrOwogICAgICB9CiAgICAgIGlmIChlcnJubyAhPSBFQlVT
WSB8fCBpID4gMTAwKQogICAgICAgIGV4aXRmKCJ1bmxpbmsoJXMpIGZhaWxlZCIsIGZpbGVuYW1l
KTsKICAgICAgZGVidWcoInVtb3VudCglcylcbiIsIGZpbGVuYW1lKTsKICAgICAgaWYgKHVtb3Vu
dDIoZmlsZW5hbWUsIE1OVF9ERVRBQ0gpKQogICAgICAgIGV4aXRmKCJ1bW91bnQoJXMpIGZhaWxl
ZCIsIGZpbGVuYW1lKTsKICAgIH0KICB9CiAgY2xvc2VkaXIoZHApOwogIGZvciAoaSA9IDA7OyBp
KyspIHsKICAgIGRlYnVnKCJybWRpciglcylcbiIsIGRpcik7CiAgICBpZiAocm1kaXIoZGlyKSA9
PSAwKQogICAgICBicmVhazsKICAgIGlmIChpIDwgMTAwKSB7CiAgICAgIGlmIChlcnJubyA9PSBF
Uk9GUykgewogICAgICAgIGRlYnVnKCJpZ25vcmluZyBFUk9GU1xuIik7CiAgICAgICAgYnJlYWs7
CiAgICAgIH0KICAgICAgaWYgKGVycm5vID09IEVCVVNZKSB7CiAgICAgICAgZGVidWcoInVtb3Vu
dCglcylcbiIsIGRpcik7CiAgICAgICAgaWYgKHVtb3VudDIoZGlyLCBNTlRfREVUQUNIKSkKICAg
ICAgICAgIGV4aXRmKCJ1bW91bnQoJXMpIGZhaWxlZCIsIGRpcik7CiAgICAgICAgY29udGludWU7
CiAgICAgIH0KICAgICAgaWYgKGVycm5vID09IEVOT1RFTVBUWSkgewogICAgICAgIGlmIChpdGVy
IDwgMTAwKSB7CiAgICAgICAgICBpdGVyKys7CiAgICAgICAgICBnb3RvIHJldHJ5OwogICAgICAg
IH0KICAgICAgfQogICAgfQogICAgZXhpdGYoInJtZGlyKCVzKSBmYWlsZWQiLCBkaXIpOwogIH0K
fQoKc3RhdGljIHVpbnQ2NF90IGN1cnJlbnRfdGltZV9tcygpCnsKICBzdHJ1Y3QgdGltZXNwZWMg
dHM7CgogIGlmIChjbG9ja19nZXR0aW1lKENMT0NLX01PTk9UT05JQywgJnRzKSkKICAgIGZhaWwo
ImNsb2NrX2dldHRpbWUgZmFpbGVkIik7CiAgcmV0dXJuICh1aW50NjRfdCl0cy50dl9zZWMgKiAx
MDAwICsgKHVpbnQ2NF90KXRzLnR2X25zZWMgLyAxMDAwMDAwOwp9CgpzdGF0aWMgdm9pZCB0ZXN0
KCk7Cgp2b2lkIGxvb3AoKQp7CiAgaW50IGl0ZXI7CiAgZm9yIChpdGVyID0gMDs7IGl0ZXIrKykg
ewogICAgY2hhciBjd2RidWZbMjU2XTsKICAgIHNwcmludGYoY3dkYnVmLCAiLi8lZCIsIGl0ZXIp
OwogICAgaWYgKG1rZGlyKGN3ZGJ1ZiwgMDc3NykpCiAgICAgIGZhaWwoImZhaWxlZCB0byBta2Rp
ciIpOwogICAgaW50IHBpZCA9IGZvcmsoKTsKICAgIGlmIChwaWQgPCAwKQogICAgICBmYWlsKCJj
bG9uZSBmYWlsZWQiKTsKICAgIGlmIChwaWQgPT0gMCkgewogICAgICBwcmN0bChQUl9TRVRfUERF
QVRIU0lHLCBTSUdLSUxMLCAwLCAwLCAwKTsKICAgICAgc2V0cGdycCgpOwogICAgICBpZiAoY2hk
aXIoY3dkYnVmKSkKICAgICAgICBmYWlsKCJmYWlsZWQgdG8gY2hkaXIiKTsKICAgICAgdGVzdCgp
OwogICAgICBleGl0KDApOwogICAgfQogICAgaW50IHN0YXR1cyA9IDA7CiAgICB1aW50NjRfdCBz
dGFydCA9IGN1cnJlbnRfdGltZV9tcygpOwogICAgZm9yICg7OykgewogICAgICBpbnQgcmVzID0g
d2FpdHBpZChwaWQsICZzdGF0dXMsIF9fV0FMTCB8IFdOT0hBTkcpOwogICAgICBpbnQgZXJybm8w
ID0gZXJybm87CiAgICAgIGlmIChyZXMgPT0gcGlkKQogICAgICAgIGJyZWFrOwogICAgICB1c2xl
ZXAoMTAwMCk7CiAgICAgIGlmIChjdXJyZW50X3RpbWVfbXMoKSAtIHN0YXJ0ID4gNSAqIDEwMDAp
IHsKICAgICAgICBraWxsKC1waWQsIFNJR0tJTEwpOwogICAgICAgIGtpbGwocGlkLCBTSUdLSUxM
KTsKICAgICAgICB3YWl0cGlkKHBpZCwgJnN0YXR1cywgX19XQUxMKTsKICAgICAgICBicmVhazsK
ICAgICAgfQogICAgfQogICAgcmVtb3ZlX2Rpcihjd2RidWYpOwogIH0KfQoKbG9uZyByWzVdOwp2
b2lkKiB0aHIodm9pZCogYXJnKQp7CiAgc3dpdGNoICgobG9uZylhcmcpIHsKICBjYXNlIDA6CiAg
ICByWzBdID0KICAgICAgICBleGVjdXRlX3N5c2NhbGwoX19OUl9tbWFwLCAweDIwMDAwMDAwdWws
IDB4YTAwMHVsLCAweDN1bCwKICAgICAgICAgICAgICAgICAgICAgICAgMHgzMnVsLCAweGZmZmZm
ZmZmZmZmZmZmZmZ1bCwgMHgwdWwsIDAsIDAsIDApOwogICAgYnJlYWs7CiAgY2FzZSAxOgogICAg
clsxXSA9IGV4ZWN1dGVfc3lzY2FsbChfX05SX3NvY2tldCwgMHhhdWwsIDB4NXVsLCAweDg0dWws
IDAsIDAsIDAsCiAgICAgICAgICAgICAgICAgICAgICAgICAgIDAsIDAsIDApOwogICAgYnJlYWs7
CiAgY2FzZSAyOgogICAgclsyXSA9IGV4ZWN1dGVfc3lzY2FsbChfX05SX3NvY2tldCwgMHgxZnVs
LCAweDN1bCwgMHg2dWwsIDAsIDAsIDAsCiAgICAgICAgICAgICAgICAgICAgICAgICAgIDAsIDAs
IDApOwogICAgYnJlYWs7CiAgY2FzZSAzOgogICAgTk9ORkFJTElORyhtZW1jcHkoCiAgICAgICAg
KHZvaWQqKTB4MjAwMDkwMDAsCiAgICAgICAgIlx4ODNceDE1XHhmNlx4ZGJceDQ3XHgxNFx4YWVc
eGUyXHg4ZFx4YjhceDRkXHhiOVx4MGZceDMyXHhlNyIKICAgICAgICAiXHhmNVx4YmNceGE2XHhh
ZVx4OWFceDJmXHgxOVx4ZWRceGYwXHg3NVx4NmFceDBiXHhmMFx4MDBceGU5IgogICAgICAgICJc
eGUxXHgwZVx4YjRceGE1XHgxOVx4MDhceDg4XHhmY1x4OGJceDJkXHhlMlx4OWFceDBmXHg1NVx4
MDAiCiAgICAgICAgIlx4MDBceDAwXHgwMFx4MDBceDA4XHgyN1x4YWJceDhlXHg3ZFx4Y2JceGNj
XHgxNVx4NGVceDc5XHhlMiIKICAgICAgICAiXHhkOVx4Y2FceDE1XHhjM1x4NjZceGJkXHg0NFx4
YThceDUzXHgxZlx4ZGFceGFiXHhjZVx4OThceDM5IgogICAgICAgICJceDQwXHg0ZVx4NzVceDU3
XHhmZFx4NTdceGMwXHgwMVx4MGJceGIwIiwKICAgICAgICA4NSkpOwogICAgcls0XSA9IGV4ZWN1
dGVfc3lzY2FsbChfX05SX3NldHNvY2tvcHQsIHJbMV0sIDB4MHVsLCAweDQwdWwsCiAgICAgICAg
ICAgICAgICAgICAgICAgICAgIDB4MjAwMDkwMDB1bCwgMHg1NXVsLCAwLCAwLCAwLCAwKTsKICAg
IGJyZWFrOwogIH0KICByZXR1cm4gMDsKfQoKdm9pZCB0ZXN0KCkKewogIGxvbmcgaTsKICBwdGhy
ZWFkX3QgdGhbOF07CgogIG1lbXNldChyLCAtMSwgc2l6ZW9mKHIpKTsKICBzcmFuZChnZXRwaWQo
KSk7CiAgZm9yIChpID0gMDsgaSA8IDQ7IGkrKykgewogICAgcHRocmVhZF9jcmVhdGUoJnRoW2ld
LCAwLCB0aHIsICh2b2lkKilpKTsKICAgIHVzbGVlcCgxMDAwMCk7CiAgfQogIGZvciAoaSA9IDA7
IGkgPCA0OyBpKyspIHsKICAgIHB0aHJlYWRfY3JlYXRlKCZ0aFs0ICsgaV0sIDAsIHRociwgKHZv
aWQqKWkpOwogICAgaWYgKHJhbmQoKSAlIDIpCiAgICAgIHVzbGVlcChyYW5kKCkgJSAxMDAwMCk7
CiAgfQogIHVzbGVlcCgxMDAwMDApOwp9CgppbnQgbWFpbigpCnsKICBzZXR1cF9tYWluX3Byb2Nl
c3MoKTsKICBpbnQgcGlkID0gZG9fc2FuZGJveF9ub25lKCk7CiAgaW50IHN0YXR1cyA9IDA7CiAg
d2hpbGUgKHdhaXRwaWQocGlkLCAmc3RhdHVzLCBfX1dBTEwpICE9IHBpZCkgewogIH0KICByZXR1
cm4gMDsKfQo=
--001a114b0bded70fcb05425c0d02--
