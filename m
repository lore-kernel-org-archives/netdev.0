From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/can: use-after-free in bcm_rx_thr_flush
Date: Tue, 22 Nov 2016 10:22:37 +0100
Message-ID: <CAAeHK+xhwpVO=xHqEOyP-Tm6cx1+jDLDpYT0hpMwM2PCf7W3Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1141d7f645246f0541e050ed
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a1141d7f645246f0541e050ed
Content-Type: text/plain; charset=UTF-8

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

A reproducer is attached.
You may need to run it a few times.

On commit 9c763584b7c8911106bb77af7e648bef09af9d80 (4.9-rc6, Nov 20).

==================================================================
BUG: KASAN: use-after-free in bcm_rx_thr_flush+0x284/0x2b0
Read of size 1 at addr ffff88006c1faae5 by task a.out/3874

page:ffffea0001b07e80 count:1 mapcount:0 mapping:          (null) index:0x0
flags: 0x100000000000080(slab)
page dumped because: kasan: bad access detected

CPU: 1 PID: 3874 Comm: a.out Not tainted 4.9.0-rc6+ #427
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88006ab07900 ffffffff81b472e4 ffff88006ab07990 ffff88006c1faae5
 00000000000000fa 00000000000000fb ffff88006ab07980 ffffffff8150ad42
 ffff88006323ce58 0000000000000246 ffff880068ca8000 0000000000000282
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b472e4>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<     inline     >] describe_address mm/kasan/report.c:259
 [<ffffffff8150ad42>] kasan_report_error+0x122/0x560 mm/kasan/report.c:365
 [<     inline     >] kasan_report mm/kasan/report.c:387
 [<ffffffff8150b1be>] __asan_report_load1_noabort+0x3e/0x40
mm/kasan/report.c:405
 [<     inline     >] bcm_rx_do_flush net/can/bcm.c:589
 [<ffffffff83577e04>] bcm_rx_thr_flush+0x284/0x2b0 net/can/bcm.c:612
 [<     inline     >] bcm_rx_setup net/can/bcm.c:1199
 [<ffffffff83578b36>] bcm_sendmsg+0xbb6/0x30e0 net/can/bcm.c:1351
 [<     inline     >] sock_sendmsg_nosec net/socket.c:621
 [<ffffffff82b7176c>] sock_sendmsg+0xcc/0x110 net/socket.c:631
 [<ffffffff82b73651>] ___sys_sendmsg+0x771/0x8b0 net/socket.c:1954
 [<ffffffff82b7563e>] __sys_sendmsg+0xce/0x170 net/socket.c:1988
 [<     inline     >] SYSC_sendmsg net/socket.c:1999
 [<ffffffff82b7570d>] SyS_sendmsg+0x2d/0x50 net/socket.c:1995
 [<ffffffff83fc4301>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209

The buggy address belongs to the object at ffff88006c1faae0
 which belongs to the cache kmalloc-32 of size 32
The buggy address ffff88006c1faae5 is located 5 bytes inside
 of 32-byte region [ffff88006c1faae0, ffff88006c1fab00)

Freed by task 2013:
 [<ffffffff8107e236>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 [<ffffffff81509e56>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
 [<     inline     >] set_track mm/kasan/kasan.c:507
 [<ffffffff8150a6b3>] kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:571
 [<     inline     >] slab_free_hook mm/slub.c:1352
 [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
 [<     inline     >] slab_free mm/slub.c:2951
 [<ffffffff81506b98>] kfree+0xe8/0x2b0 mm/slub.c:3871
 [<ffffffff819dd8c1>] selinux_cred_free+0x51/0x80 security/selinux/hooks.c:3725
 [<ffffffff819ce358>] security_cred_free+0x48/0x80 security/security.c:907
 [<ffffffff8117e27d>] put_cred_rcu+0xed/0x390 kernel/cred.c:116
 [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
 [<     inline     >] rcu_do_batch kernel/rcu/tree.c:2776
 [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
 [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
 [<ffffffff8125dfe0>] rcu_process_callbacks+0xa40/0x1190 kernel/rcu/tree.c:3024
 [<ffffffff83fc70af>] __do_softirq+0x23f/0x8e5 kernel/softirq.c:284

Allocated by task 1826:
 [<ffffffff8107e236>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 [<ffffffff81509e56>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
 [<     inline     >] set_track mm/kasan/kasan.c:507
 [<ffffffff8150a0cb>] kasan_kmalloc+0xab/0xe0 mm/kasan/kasan.c:598
 [<ffffffff8150a632>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:537
 [<     inline     >] slab_post_alloc_hook mm/slab.h:417
 [<     inline     >] slab_alloc_node mm/slub.c:2708
 [<     inline     >] slab_alloc mm/slub.c:2716
 [<ffffffff815090ef>] __kmalloc_track_caller+0xcf/0x2a0 mm/slub.c:4240
 [<ffffffff8146bf84>] kmemdup+0x24/0x50 mm/util.c:113
 [<ffffffff819dcbe9>] selinux_cred_prepare+0x49/0xb0
security/selinux/hooks.c:3739
 [<ffffffff819ce40d>] security_prepare_creds+0x7d/0xb0 security/security.c:912
 [<ffffffff8117fab3>] prepare_creds+0x243/0x340 kernel/cred.c:277
 [<ffffffff81181bab>] copy_creds+0x7b/0x5c0 kernel/cred.c:343
 [<ffffffff81109c6e>] copy_process.part.45+0x86e/0x5b50 kernel/fork.c:1529
 [<     inline     >] copy_process kernel/fork.c:1479
 [<ffffffff8110f2fa>] _do_fork+0x1ba/0xcc0 kernel/fork.c:1933
 [<     inline     >] SYSC_clone kernel/fork.c:2043
 [<ffffffff8110fed7>] SyS_clone+0x37/0x50 kernel/fork.c:2037
 [<ffffffff81006465>] do_syscall_64+0x195/0x490 arch/x86/entry/common.c:280
 [<ffffffff83fc43c9>] return_from_SYSCALL_64+0x0/0x7a
arch/x86/entry/entry_64.S:251

Memory state around the buggy address:
 ffff88006c1fa980: fc fc fb fb fb fb fc fc fb fb fb fb fc fc fb fb
 ffff88006c1faa00: fb fb fc fc fb fb fb fb fc fc fb fb fb fb fc fc
>ffff88006c1faa80: fb fb fb fb fc fc fb fb fb fb fc fc fb fb fb fb
                                                       ^
 ffff88006c1fab00: fc fc fb fb fb fb fc fc 00 00 00 00 fc fc 00 00
 ffff88006c1fab80: 00 00 fc fc fb fb fb fb fc fc fb fb fb fb fc fc
==================================================================

Thanks!

--001a1141d7f645246f0541e050ed
Content-Type: text/x-csrc; charset=US-ASCII; name="bcm-rx-uaf-poc.c"
Content-Disposition: attachment; filename="bcm-rx-uaf-poc.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ivtallvp0

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCgojaWZuZGVmIF9fTlJfc29ja2V0CiNkZWZpbmUgX19OUl9zb2NrZXQgNDEKI2Vu
ZGlmCiNpZm5kZWYgX19OUl9zeXpfZnVzZV9tb3VudAojZGVmaW5lIF9fTlJfc3l6X2Z1c2VfbW91
bnQgMTAwMDAwNAojZW5kaWYKI2lmbmRlZiBfX05SX3N5el9mdXNlYmxrX21vdW50CiNkZWZpbmUg
X19OUl9zeXpfZnVzZWJsa19tb3VudCAxMDAwMDA1CiNlbmRpZgojaWZuZGVmIF9fTlJfc3l6X29w
ZW5fcHRzCiNkZWZpbmUgX19OUl9zeXpfb3Blbl9wdHMgMTAwMDAwMwojZW5kaWYKI2lmbmRlZiBf
X05SX3N5el90ZXN0CiNkZWZpbmUgX19OUl9zeXpfdGVzdCAxMDAwMDAxCiNlbmRpZgojaWZuZGVm
IF9fTlJfbW1hcAojZGVmaW5lIF9fTlJfbW1hcCA5CiNlbmRpZgojaWZuZGVmIF9fTlJfY29ubmVj
dAojZGVmaW5lIF9fTlJfY29ubmVjdCA0MgojZW5kaWYKI2lmbmRlZiBfX05SX3NlbmRtc2cKI2Rl
ZmluZSBfX05SX3NlbmRtc2cgNDYKI2VuZGlmCiNpZm5kZWYgX19OUl9zeXpfb3Blbl9kZXYKI2Rl
ZmluZSBfX05SX3N5el9vcGVuX2RldiAxMDAwMDAyCiNlbmRpZgoKI2luY2x1ZGUgPHN5cy9pb2N0
bC5oPgojaW5jbHVkZSA8c3lzL3NvY2tldC5oPgojaW5jbHVkZSA8c3lzL3N0YXQuaD4KI2luY2x1
ZGUgPHN5cy9zeXNjYWxsLmg+CiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2luY2x1ZGUgPG5ldC9p
Zl9hcnAuaD4KCiNpbmNsdWRlIDxlcnJuby5oPgojaW5jbHVkZSA8ZXJyb3IuaD4KI2luY2x1ZGUg
PGZjbnRsLmg+CiNpbmNsdWRlIDxwdGhyZWFkLmg+CiNpbmNsdWRlIDxzZXRqbXAuaD4KI2luY2x1
ZGUgPHNpZ25hbC5oPgojaW5jbHVkZSA8c3RkZGVmLmg+CiNpbmNsdWRlIDxzdGRpbnQuaD4KI2lu
Y2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHN0cmluZy5oPgoj
aW5jbHVkZSA8dW5pc3RkLmg+CgpfX3RocmVhZCBpbnQgc2tpcF9zZWd2OwpfX3RocmVhZCBqbXBf
YnVmIHNlZ3ZfZW52OwoKc3RhdGljIHZvaWQgc2Vndl9oYW5kbGVyKGludCBzaWcsIHNpZ2luZm9f
dCogaW5mbywgdm9pZCogdWN0eCkKewogIGlmIChfX2F0b21pY19sb2FkX24oJnNraXBfc2Vndiwg
X19BVE9NSUNfUkVMQVhFRCkpCiAgICBfbG9uZ2ptcChzZWd2X2VudiwgMSk7CiAgZXhpdChzaWcp
Owp9CgpzdGF0aWMgdm9pZCBpbnN0YWxsX3NlZ3ZfaGFuZGxlcigpCnsKICBzdHJ1Y3Qgc2lnYWN0
aW9uIHNhOwogIG1lbXNldCgmc2EsIDAsIHNpemVvZihzYSkpOwogIHNhLnNhX3NpZ2FjdGlvbiA9
IHNlZ3ZfaGFuZGxlcjsKICBzYS5zYV9mbGFncyA9IFNBX05PREVGRVIgfCBTQV9TSUdJTkZPOwog
IHNpZ2FjdGlvbihTSUdTRUdWLCAmc2EsIE5VTEwpOwogIHNpZ2FjdGlvbihTSUdCVVMsICZzYSwg
TlVMTCk7Cn0KCiNkZWZpbmUgTk9ORkFJTElORyguLi4pICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgXAogIHsgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwKICAgIF9fYXRvbWljX2Zl
dGNoX2FkZCgmc2tpcF9zZWd2LCAxLCBfX0FUT01JQ19TRVFfQ1NUKTsgICAgICAgICAgICAgICBc
CiAgICBpZiAoX3NldGptcChzZWd2X2VudikgPT0gMCkgeyAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgXAogICAgICBfX1ZBX0FSR1NfXzsgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwKICAgIH0gICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBcCiAgICBfX2F0
b21pY19mZXRjaF9zdWIoJnNraXBfc2VndiwgMSwgX19BVE9NSUNfU0VRX0NTVCk7ICAgICAgICAg
ICAgICAgXAogIH0KCnN0YXRpYyB1aW50cHRyX3Qgc3l6X29wZW5fZGV2KHVpbnRwdHJfdCBhMCwg
dWludHB0cl90IGExLCB1aW50cHRyX3QgYTIpCnsKICBpZiAoYTAgPT0gMHhjIHx8IGEwID09IDB4
YikgewoKICAgIGNoYXIgYnVmWzEyOF07CiAgICBzcHJpbnRmKGJ1ZiwgIi9kZXYvJXMvJWQ6JWQi
LCBhMCA9PSAweGMgPyAiY2hhciIgOiAiYmxvY2siLAogICAgICAgICAgICAodWludDhfdClhMSwg
KHVpbnQ4X3QpYTIpOwogICAgcmV0dXJuIG9wZW4oYnVmLCBPX1JEV1IsIDApOwogIH0gZWxzZSB7
CgogICAgY2hhciBidWZbMTAyNF07CiAgICBjaGFyKiBoYXNoOwogICAgc3RybmNweShidWYsIChj
aGFyKilhMCwgc2l6ZW9mKGJ1ZikpOwogICAgYnVmW3NpemVvZihidWYpIC0gMV0gPSAwOwogICAg
d2hpbGUgKChoYXNoID0gc3RyY2hyKGJ1ZiwgJyMnKSkpIHsKICAgICAgKmhhc2ggPSAnMCcgKyAo
Y2hhcikoYTEgJSAxMCk7CiAgICAgIGExIC89IDEwOwogICAgfQogICAgcmV0dXJuIG9wZW4oYnVm
LCBhMiwgMCk7CiAgfQp9CgpzdGF0aWMgdWludHB0cl90IHN5el9vcGVuX3B0cyh1aW50cHRyX3Qg
YTAsIHVpbnRwdHJfdCBhMSkKewoKICBpbnQgcHR5bm8gPSAwOwogIGlmIChpb2N0bChhMCwgVElP
Q0dQVE4sICZwdHlubykpCiAgICByZXR1cm4gLTE7CiAgY2hhciBidWZbMTI4XTsKICBzcHJpbnRm
KGJ1ZiwgIi9kZXYvcHRzLyVkIiwgcHR5bm8pOwogIHJldHVybiBvcGVuKGJ1ZiwgYTEsIDApOwp9
CgpzdGF0aWMgdWludHB0cl90IHN5el9mdXNlX21vdW50KHVpbnRwdHJfdCBhMCwgdWludHB0cl90
IGExLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhMiwgdWludHB0
cl90IGEzLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhNCwgdWlu
dHB0cl90IGE1KQp7CgogIHVpbnQ2NF90IHRhcmdldCA9IGEwOwogIHVpbnQ2NF90IG1vZGUgPSBh
MTsKICB1aW50NjRfdCB1aWQgPSBhMjsKICB1aW50NjRfdCBnaWQgPSBhMzsKICB1aW50NjRfdCBt
YXhyZWFkID0gYTQ7CiAgdWludDY0X3QgZmxhZ3MgPSBhNTsKCiAgaW50IGZkID0gb3BlbigiL2Rl
di9mdXNlIiwgT19SRFdSKTsKICBpZiAoZmQgPT0gLTEpCiAgICByZXR1cm4gZmQ7CiAgY2hhciBi
dWZbMTAyNF07CiAgc3ByaW50ZihidWYsICJmZD0lZCx1c2VyX2lkPSVsZCxncm91cF9pZD0lbGQs
cm9vdG1vZGU9MCVvIiwgZmQsCiAgICAgICAgICAobG9uZyl1aWQsIChsb25nKWdpZCwgKHVuc2ln
bmVkKW1vZGUgJiB+M3UpOwogIGlmIChtYXhyZWFkICE9IDApCiAgICBzcHJpbnRmKGJ1ZiArIHN0
cmxlbihidWYpLCAiLG1heF9yZWFkPSVsZCIsIChsb25nKW1heHJlYWQpOwogIGlmIChtb2RlICYg
MSkKICAgIHN0cmNhdChidWYsICIsZGVmYXVsdF9wZXJtaXNzaW9ucyIpOwogIGlmIChtb2RlICYg
MikKICAgIHN0cmNhdChidWYsICIsYWxsb3dfb3RoZXIiKTsKICBzeXNjYWxsKFNZU19tb3VudCwg
IiIsIHRhcmdldCwgImZ1c2UiLCBmbGFncywgYnVmKTsKCiAgcmV0dXJuIGZkOwp9CgpzdGF0aWMg
dWludHB0cl90IHN5el9mdXNlYmxrX21vdW50KHVpbnRwdHJfdCBhMCwgdWludHB0cl90IGExLAog
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhMiwgdWludHB0cl90
IGEzLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhNCwgdWlu
dHB0cl90IGE1LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBh
NiwgdWludHB0cl90IGE3KQp7CgogIHVpbnQ2NF90IHRhcmdldCA9IGEwOwogIHVpbnQ2NF90IGJs
a2RldiA9IGExOwogIHVpbnQ2NF90IG1vZGUgPSBhMjsKICB1aW50NjRfdCB1aWQgPSBhMzsKICB1
aW50NjRfdCBnaWQgPSBhNDsKICB1aW50NjRfdCBtYXhyZWFkID0gYTU7CiAgdWludDY0X3QgYmxr
c2l6ZSA9IGE2OwogIHVpbnQ2NF90IGZsYWdzID0gYTc7CgogIGludCBmZCA9IG9wZW4oIi9kZXYv
ZnVzZSIsIE9fUkRXUik7CiAgaWYgKGZkID09IC0xKQogICAgcmV0dXJuIGZkOwogIGlmIChzeXNj
YWxsKFNZU19ta25vZGF0LCBBVF9GRENXRCwgYmxrZGV2LCBTX0lGQkxLLCBtYWtlZGV2KDcsIDE5
OSkpKQogICAgcmV0dXJuIGZkOwogIGNoYXIgYnVmWzI1Nl07CiAgc3ByaW50ZihidWYsICJmZD0l
ZCx1c2VyX2lkPSVsZCxncm91cF9pZD0lbGQscm9vdG1vZGU9MCVvIiwgZmQsCiAgICAgICAgICAo
bG9uZyl1aWQsIChsb25nKWdpZCwgKHVuc2lnbmVkKW1vZGUgJiB+M3UpOwogIGlmIChtYXhyZWFk
ICE9IDApCiAgICBzcHJpbnRmKGJ1ZiArIHN0cmxlbihidWYpLCAiLG1heF9yZWFkPSVsZCIsIChs
b25nKW1heHJlYWQpOwogIGlmIChibGtzaXplICE9IDApCiAgICBzcHJpbnRmKGJ1ZiArIHN0cmxl
bihidWYpLCAiLGJsa3NpemU9JWxkIiwgKGxvbmcpYmxrc2l6ZSk7CiAgaWYgKG1vZGUgJiAxKQog
ICAgc3RyY2F0KGJ1ZiwgIixkZWZhdWx0X3Blcm1pc3Npb25zIik7CiAgaWYgKG1vZGUgJiAyKQog
ICAgc3RyY2F0KGJ1ZiwgIixhbGxvd19vdGhlciIpOwogIHN5c2NhbGwoU1lTX21vdW50LCBibGtk
ZXYsIHRhcmdldCwgImZ1c2VibGsiLCBmbGFncywgYnVmKTsKCiAgcmV0dXJuIGZkOwp9CgpzdGF0
aWMgdWludHB0cl90IGV4ZWN1dGVfc3lzY2FsbChpbnQgbnIsIHVpbnRwdHJfdCBhMCwgdWludHB0
cl90IGExLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB1aW50cHRyX3QgYTIsIHVp
bnRwdHJfdCBhMywKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdWludHB0cl90IGE0
LCB1aW50cHRyX3QgYTUsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJf
dCBhNiwgdWludHB0cl90IGE3LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB1aW50
cHRyX3QgYTgpCnsKICBzd2l0Y2ggKG5yKSB7CiAgZGVmYXVsdDoKICAgIHJldHVybiBzeXNjYWxs
KG5yLCBhMCwgYTEsIGEyLCBhMywgYTQsIGE1KTsKICBjYXNlIF9fTlJfc3l6X3Rlc3Q6CiAgICBy
ZXR1cm4gMDsKICBjYXNlIF9fTlJfc3l6X29wZW5fZGV2OgogICAgcmV0dXJuIHN5el9vcGVuX2Rl
dihhMCwgYTEsIGEyKTsKICBjYXNlIF9fTlJfc3l6X29wZW5fcHRzOgogICAgcmV0dXJuIHN5el9v
cGVuX3B0cyhhMCwgYTEpOwogIGNhc2UgX19OUl9zeXpfZnVzZV9tb3VudDoKICAgIHJldHVybiBz
eXpfZnVzZV9tb3VudChhMCwgYTEsIGEyLCBhMywgYTQsIGE1KTsKICBjYXNlIF9fTlJfc3l6X2Z1
c2VibGtfbW91bnQ6CiAgICByZXR1cm4gc3l6X2Z1c2VibGtfbW91bnQoYTAsIGExLCBhMiwgYTMs
IGE0LCBhNSwgYTYsIGE3KTsKICB9Cn0KCmxvbmcgclsyNV07CgppbnQgbWFpbigpCnsKICBpbnN0
YWxsX3NlZ3ZfaGFuZGxlcigpOwogIG1lbXNldChyLCAtMSwgc2l6ZW9mKHIpKTsKICByWzBdID0g
ZXhlY3V0ZV9zeXNjYWxsKF9fTlJfbW1hcCwgMHgyMDAwMDAwMHVsLCAweGY2MDAwMHVsLCAweDN1
bCwKICAgICAgICAgICAgICAgICAgICAgICAgIDB4MzJ1bCwgMHhmZmZmZmZmZmZmZmZmZmZmdWws
IDB4MHVsLCAwLCAwLCAwKTsKICByWzFdID0gZXhlY3V0ZV9zeXNjYWxsKF9fTlJfc29ja2V0LCAw
eDFkdWwsIDB4ODAwMDJ1bCwgMHgydWwsIDAsIDAsIDAsCiAgICAgICAgICAgICAgICAgICAgICAg
ICAwLCAwLCAwKTsKICBOT05GQUlMSU5HKCoodWludDE2X3QqKTB4MjBmNTcwMDAgPSAodWludDE2
X3QpMHgyNyk7CiAgTk9ORkFJTElORygqKHVpbnQzMl90KikweDIwZjU3MDA0ID0gKHVpbnQzMl90
KTB4MCk7CiAgTk9ORkFJTElORygqKHVpbnQzMl90KikweDIwZjU3MDA4ID0gKHVpbnQzMl90KTB4
MCk7CiAgTk9ORkFJTElORygqKHVpbnQzMl90KikweDIwZjU3MDBjID0gKHVpbnQzMl90KTB4MCk7
CiAgTk9ORkFJTElORygqKHVpbnQ4X3QqKTB4MjBmNTcwMTAgPSAodWludDhfdCkweDApOwogIE5P
TkZBSUxJTkcoKih1aW50OF90KikweDIwZjU3MDExID0gKHVpbnQ4X3QpMHgwKTsKICBOT05GQUlM
SU5HKG1lbWNweSgKICAgICAgKHZvaWQqKTB4MjBmNTcwMTIsCiAgICAgICJceDM0XHgxYlx4M2Fc
eDAxXHhiMlx4NTdceDg0XHg5Y1x4YTFceGQ3XHhkMVx4ZmZceDlmXHg5OVx4OWRceDgxIgogICAg
ICAiXHgyN1x4YjFceDg1XHhmOFx4OGRceDFkXHg3N1x4NWRceDU5XHhjOFx4OGFceDNhXHhhNlx4
YThceGRkXHhhYyIKICAgICAgIlx4ZGZceDJiXHhkY1x4MzJceDRlXHhhNlx4NTdceDhhXHgyMVx4
YjhceDUxXHgxNFx4NjFceDAxXHg4Nlx4YzMiCiAgICAgICJceDgxXHg3Y1x4MzRceGIwXHg1ZVx4
YWZceGZkXHgyY1x4M2ZceDU0XHhmNVx4N2ZceGE4XHgxYlx4YTAiLAogICAgICA2MykpOwogIE5P
TkZBSUxJTkcoKih1aW50NjRfdCopMHgyMGY1NzA1OCA9ICh1aW50NjRfdCkweDApOwogIHJbMTBd
ID0gZXhlY3V0ZV9zeXNjYWxsKF9fTlJfY29ubmVjdCwgclsxXSwgMHgyMGY1NzAwMHVsLCAweDYw
dWwsIDAsCiAgICAgICAgICAgICAgICAgICAgICAgICAgMCwgMCwgMCwgMCwgMCk7CiAgTk9ORkFJ
TElORygqKHVpbnQ2NF90KikweDIwYjA1MDAwID0gKHVpbnQ2NF90KTB4MjBmNTUwMDApOwogIE5P
TkZBSUxJTkcoKih1aW50MzJfdCopMHgyMGIwNTAwOCA9ICh1aW50MzJfdCkweDApOwogIE5PTkZB
SUxJTkcoKih1aW50NjRfdCopMHgyMGIwNTAxMCA9ICh1aW50NjRfdCkweDIwMDA4ZmUwKTsKICBO
T05GQUlMSU5HKCoodWludDY0X3QqKTB4MjBiMDUwMTggPSAodWludDY0X3QpMHgyKTsKICBOT05G
QUlMSU5HKCoodWludDY0X3QqKTB4MjBiMDUwMjAgPSAodWludDY0X3QpMHgyMGY1NDAwMCk7CiAg
Tk9ORkFJTElORygqKHVpbnQ2NF90KikweDIwYjA1MDI4ID0gKHVpbnQ2NF90KTB4MCk7CiAgTk9O
RkFJTElORygqKHVpbnQzMl90KikweDIwYjA1MDMwID0gKHVpbnQzMl90KTB4MCk7CiAgTk9ORkFJ
TElORygqKHVpbnQ2NF90KikweDIwMDA4ZmUwID0gKHVpbnQ2NF90KTB4MjBkNWZmZjEpOwogIE5P
TkZBSUxJTkcoKih1aW50NjRfdCopMHgyMDAwOGZlOCA9ICh1aW50NjRfdCkweGYpOwogIE5PTkZB
SUxJTkcoKih1aW50NjRfdCopMHgyMDAwOGZmMCA9ICh1aW50NjRfdCkweDIwZjU1MDAwKTsKICBO
T05GQUlMSU5HKCoodWludDY0X3QqKTB4MjAwMDhmZjggPSAodWludDY0X3QpMHg2OSk7CiAgTk9O
RkFJTElORyhtZW1jcHkoCiAgICAgICh2b2lkKikweDIwZDVmZmYxLAogICAgICAiXHgwNVx4MDBc
eDAwXHgwMFx4OGRceDEzXHgwMFx4MDBceDAwXHgwMFx4MTdceDE0XHhiN1x4N2VceGE2IiwKICAg
ICAgMTUpKTsKICBOT05GQUlMSU5HKG1lbWNweSgKICAgICAgKHZvaWQqKTB4MjBmNTUwMDAsCiAg
ICAgICJceDEyXHg2Zlx4MzlceGI2XHg1Ylx4NGVceGVkXHg5MFx4NzdceGUwXHg1NFx4YmZceGI2
XHhiMlx4NDFceGQ3IgogICAgICAiXHgzNlx4NWRceDU4XHhmYVx4YThceDMyXHg3YVx4NmRceDI1
XHg4OVx4MDFceDAwXHhkZFx4MDBceGM1XHg4OSIKICAgICAgIlx4MDdceGVjXHhjMlx4NzZceDhk
XHgwMlx4MDBceDAwXHgwMFx4MTBceGI0XHgyN1x4YWJceDZjXHgyYVx4NDEiCiAgICAgICJceGUy
XHg1NFx4NDdceGNjXHgwOFx4Y2FceDc1XHgyYVx4MDNceDg5XHhkM1x4MDRceDcxXHgzZlx4NzVc
eDkwIgogICAgICAiXHhmNFx4ZGFceGM2XHhkOVx4YTdceDUwXHhmZlx4ZThceDNlXHhmZlx4Y2Rc
eDMxXHgxYlx4YTJceDBhXHhlZSIKICAgICAgIlx4OGFceDcyXHg2Ylx4ZGFceDc0XHg3NVx4OTJc
eGJmXHhhZFx4ZjBceDcxXHhiOVx4YjdceDcwXHgwNFx4YmIiCiAgICAgICJceDU4XHg0MFx4N2Rc
eDUwXHgxNFx4NmJceGQ3XHhjMlx4NjAiLAogICAgICAxMDUpKTsKICByWzI0XSA9IGV4ZWN1dGVf
c3lzY2FsbChfX05SX3NlbmRtc2csIHJbMV0sIDB4MjBiMDUwMDB1bCwgMHgwdWwsIDAsIDAsCiAg
ICAgICAgICAgICAgICAgICAgICAgICAgMCwgMCwgMCwgMCk7CiAgcmV0dXJuIDA7Cn0K
--001a1141d7f645246f0541e050ed--
