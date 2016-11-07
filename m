From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/l2tp: use-after-free write in l2tp_ip6_close
Date: Mon, 7 Nov 2016 23:35:26 +0100
Message-ID: <CAAeHK+wThP9rwA7ecbpTPLaj7BR6+qwTy_N=Zh3Jf+AsO_Njbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c18f88aefc87a0540bda317
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Wei Wang <weiwan@google.com>,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--94eb2c18f88aefc87a0540bda317
Content-Type: text/plain; charset=UTF-8

Hi,

I've got the following error report while running the syzkaller fuzzer:

==================================================================
BUG: KASAN: use-after-free in l2tp_ip6_close+0x239/0x2a0 at addr
ffff8800677276d8
Write of size 8 by task a.out/8668
CPU: 0 PID: 8668 Comm: a.out Not tainted 4.9.0-rc4+ #354
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff8800694d7b00 ffffffff81b46a64 ffff88006adb5780 ffff8800677276c0
 ffff880067727c68 ffff8800677276c0 ffff8800694d7b28 ffffffff8150a86c
 ffff8800694d7bb8 ffff88006adb5780 ffff8800e77276d8 ffff8800694d7ba8
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b46a64>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<ffffffff8150a86c>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:156
 [<     inline     >] print_address_description mm/kasan/report.c:194
 [<ffffffff8150ab07>] kasan_report_error+0x1f7/0x4d0 mm/kasan/report.c:283
 [<     inline     >] kasan_report mm/kasan/report.c:303
 [<ffffffff8150b01e>] __asan_report_store8_noabort+0x3e/0x40
mm/kasan/report.c:329
 [<     inline     >] __write_once_size ./include/linux/compiler.h:272
 [<     inline     >] __hlist_del ./include/linux/list.h:622
 [<     inline     >] hlist_del_init ./include/linux/list.h:637
 [<ffffffff83825f49>] l2tp_ip6_close+0x239/0x2a0 net/l2tp/l2tp_ip6.c:239
 [<ffffffff8316b31f>] inet_release+0xef/0x1c0 net/ipv4/af_inet.c:415
 [<ffffffff832cd4d0>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:422
 [<ffffffff82b6d89e>] sock_release+0x8e/0x1d0 net/socket.c:570
 [<ffffffff82b6d9f6>] sock_close+0x16/0x20 net/socket.c:1017
 [<ffffffff81524bdd>] __fput+0x29d/0x720 fs/file_table.c:208
 [<ffffffff815250e5>] ____fput+0x15/0x20 fs/file_table.c:244
 [<ffffffff81172928>] task_work_run+0xf8/0x170 kernel/task_work.c:116
 [<     inline     >] exit_task_work ./include/linux/task_work.h:21
 [<ffffffff8111bda3>] do_exit+0x883/0x2ac0 kernel/exit.c:828
 [<ffffffff8112234e>] do_group_exit+0x10e/0x340 kernel/exit.c:931
 [<     inline     >] SYSC_exit_group kernel/exit.c:942
 [<ffffffff8112259d>] SyS_exit_group+0x1d/0x20 kernel/exit.c:940
 [<ffffffff83fc1501>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
Object at ffff8800677276c0, in cache L2TP/IPv6 size: 1448
Allocated:
PID = 8692
[<ffffffff8107e236>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
[<ffffffff81509bd6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
[<     inline     >] set_track mm/kasan/kasan.c:507
[<ffffffff81509e4b>] kasan_kmalloc+0xab/0xe0 mm/kasan/kasan.c:598
[<ffffffff8150a3b2>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:537
[<     inline     >] slab_post_alloc_hook mm/slab.h:417
[<     inline     >] slab_alloc_node mm/slub.c:2708
[<     inline     >] slab_alloc mm/slub.c:2716
[<ffffffff81505064>] kmem_cache_alloc+0xb4/0x270 mm/slub.c:2721
[<ffffffff82b77ca9>] sk_prot_alloc+0x69/0x2b0 net/core/sock.c:1327
[<ffffffff82b80898>] sk_alloc+0x38/0xaf0 net/core/sock.c:1389
[<ffffffff832cef05>] inet6_create+0x2e5/0xf60 net/ipv6/af_inet6.c:182
[<ffffffff82b7301f>] __sock_create+0x37f/0x640 net/socket.c:1153
[<     inline     >] sock_create net/socket.c:1193
[<     inline     >] SYSC_socket net/socket.c:1223
[<ffffffff82b73510>] SyS_socket+0xf0/0x1b0 net/socket.c:1203
[<ffffffff83fc1501>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
Freed:
PID = 8668
[<ffffffff8107e236>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
[<ffffffff81509bd6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
[<     inline     >] set_track mm/kasan/kasan.c:507
[<ffffffff8150a433>] kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:571
[<     inline     >] slab_free_hook mm/slub.c:1352
[<     inline     >] slab_free_freelist_hook mm/slub.c:1374
[<     inline     >] slab_free mm/slub.c:2951
[<ffffffff81506263>] kmem_cache_free+0xb3/0x2c0 mm/slub.c:2973
[<     inline     >] sk_prot_free net/core/sock.c:1370
[<ffffffff82b7c669>] __sk_destruct+0x319/0x480 net/core/sock.c:1445
[<ffffffff82b82b94>] sk_destruct+0x44/0x80 net/core/sock.c:1453
[<ffffffff82b82c24>] __sk_free+0x54/0x230 net/core/sock.c:1461
[<ffffffff82b82e23>] sk_free+0x23/0x30 net/core/sock.c:1472
[<     inline     >] sock_put ./include/net/sock.h:1591
[<ffffffff82b84b04>] sk_common_release+0x294/0x3e0 net/core/sock.c:2745
[<ffffffff83825f19>] l2tp_ip6_close+0x209/0x2a0 net/l2tp/l2tp_ip6.c:243
[<ffffffff8316b31f>] inet_release+0xef/0x1c0 net/ipv4/af_inet.c:415
[<ffffffff832cd4d0>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:422
[<ffffffff82b6d89e>] sock_release+0x8e/0x1d0 net/socket.c:570
[<ffffffff82b6d9f6>] sock_close+0x16/0x20 net/socket.c:1017
[<ffffffff81524bdd>] __fput+0x29d/0x720 fs/file_table.c:208
[<ffffffff815250e5>] ____fput+0x15/0x20 fs/file_table.c:244
[<ffffffff81172928>] task_work_run+0xf8/0x170 kernel/task_work.c:116
[<     inline     >] exit_task_work ./include/linux/task_work.h:21
[<ffffffff8111bda3>] do_exit+0x883/0x2ac0 kernel/exit.c:828
[<ffffffff8112234e>] do_group_exit+0x10e/0x340 kernel/exit.c:931
[<     inline     >] SYSC_exit_group kernel/exit.c:942
[<ffffffff8112259d>] SyS_exit_group+0x1d/0x20 kernel/exit.c:940
[<ffffffff83fc1501>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
Memory state around the buggy address:
 ffff880067727580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880067727600: fb fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc
>ffff880067727680: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
                                                    ^
 ffff880067727700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880067727780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

To reproduce run the attached program in a tight parallel loop using
stress (https://godoc.org/golang.org/x/tools/cmd/stress):
$ gcc -lpthread tmp.c
$ ./stress ./a.out

On commit bc33b0ca11e3df467777a4fa7639ba488c9d4911 (Nov 5).

Thanks!

--94eb2c18f88aefc87a0540bda317
Content-Type: application/octet-stream; name="l2tp-uaf-poc.c"
Content-Disposition: attachment; filename="l2tp-uaf-poc.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iv8n94340

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCgojaWZuZGVmIF9fTlJfYmluZAojZGVmaW5lIF9fTlJfYmluZCA0OQojZW5kaWYK
I2lmbmRlZiBfX05SX3N5el9mdXNlYmxrX21vdW50CiNkZWZpbmUgX19OUl9zeXpfZnVzZWJsa19t
b3VudCAxMDAwMDA1CiNlbmRpZgojaWZuZGVmIF9fTlJfc3l6X29wZW5fcHRzCiNkZWZpbmUgX19O
Ul9zeXpfb3Blbl9wdHMgMTAwMDAwMwojZW5kaWYKI2lmbmRlZiBfX05SX3NvY2tldAojZGVmaW5l
IF9fTlJfc29ja2V0IDQxCiNlbmRpZgojaWZuZGVmIF9fTlJfc3l6X2Z1c2VfbW91bnQKI2RlZmlu
ZSBfX05SX3N5el9mdXNlX21vdW50IDEwMDAwMDQKI2VuZGlmCiNpZm5kZWYgX19OUl9zeXpfb3Bl
bl9kZXYKI2RlZmluZSBfX05SX3N5el9vcGVuX2RldiAxMDAwMDAyCiNlbmRpZgojaWZuZGVmIF9f
TlJfc3l6X3Rlc3QKI2RlZmluZSBfX05SX3N5el90ZXN0IDEwMDAwMDEKI2VuZGlmCiNpZm5kZWYg
X19OUl9tbWFwCiNkZWZpbmUgX19OUl9tbWFwIDkKI2VuZGlmCgojaW5jbHVkZSA8c3lzL2lvY3Rs
Lmg+CiNpbmNsdWRlIDxzeXMvc29ja2V0Lmg+CiNpbmNsdWRlIDxzeXMvc3RhdC5oPgojaW5jbHVk
ZSA8c3lzL3N5c2NhbGwuaD4KI2luY2x1ZGUgPHN5cy90eXBlcy5oPgoKI2luY2x1ZGUgPGVycm5v
Lmg+CiNpbmNsdWRlIDxlcnJvci5oPgojaW5jbHVkZSA8ZmNudGwuaD4KI2luY2x1ZGUgPHB0aHJl
YWQuaD4KI2luY2x1ZGUgPHNldGptcC5oPgojaW5jbHVkZSA8c2lnbmFsLmg+CiNpbmNsdWRlIDxz
dGRkZWYuaD4KI2luY2x1ZGUgPHN0ZGludC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUg
PHN0ZGxpYi5oPgojaW5jbHVkZSA8c3RyaW5nLmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KCl9fdGhy
ZWFkIGludCBza2lwX3NlZ3Y7Cl9fdGhyZWFkIGptcF9idWYgc2Vndl9lbnY7CgpzdGF0aWMgdm9p
ZCBzZWd2X2hhbmRsZXIoaW50IHNpZywgc2lnaW5mb190KiBpbmZvLCB2b2lkKiB1Y3R4KQp7CiAg
aWYgKF9fYXRvbWljX2xvYWRfbigmc2tpcF9zZWd2LCBfX0FUT01JQ19SRUxBWEVEKSkKICAgIF9s
b25nam1wKHNlZ3ZfZW52LCAxKTsKICBleGl0KHNpZyk7Cn0KCnN0YXRpYyB2b2lkIGluc3RhbGxf
c2Vndl9oYW5kbGVyKCkKewogIHN0cnVjdCBzaWdhY3Rpb24gc2E7CiAgbWVtc2V0KCZzYSwgMCwg
c2l6ZW9mKHNhKSk7CiAgc2Euc2Ffc2lnYWN0aW9uID0gc2Vndl9oYW5kbGVyOwogIHNhLnNhX2Zs
YWdzID0gU0FfTk9ERUZFUiB8IFNBX1NJR0lORk87CiAgc2lnYWN0aW9uKFNJR1NFR1YsICZzYSwg
TlVMTCk7CiAgc2lnYWN0aW9uKFNJR0JVUywgJnNhLCBOVUxMKTsKfQoKI2RlZmluZSBOT05GQUlM
SU5HKC4uLikgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBc
CiAgeyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgXAogICAgX19hdG9taWNfZmV0Y2hfYWRkKCZza2lwX3NlZ3YsIDEsIF9f
QVRPTUlDX1NFUV9DU1QpOyAgICAgICAgICAgICAgIFwKICAgIGlmIChfc2V0am1wKHNlZ3ZfZW52
KSA9PSAwKSB7ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBcCiAgICAgIF9f
VkFfQVJHU19fOyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgXAogICAgfSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgIFwKICAgIF9fYXRvbWljX2ZldGNoX3N1Yigmc2tpcF9zZWd2
LCAxLCBfX0FUT01JQ19TRVFfQ1NUKTsgICAgICAgICAgICAgICBcCiAgfQoKc3RhdGljIHVpbnRw
dHJfdCBzeXpfb3Blbl9kZXYodWludHB0cl90IGEwLCB1aW50cHRyX3QgYTEsIHVpbnRwdHJfdCBh
MikKewogIGlmIChhMCA9PSAweGMgfHwgYTAgPT0gMHhiKSB7CgogICAgY2hhciBidWZbMTI4XTsK
ICAgIHNwcmludGYoYnVmLCAiL2Rldi8lcy8lZDolZCIsIGEwID09IDB4YyA/ICJjaGFyIiA6ICJi
bG9jayIsCiAgICAgICAgICAgICh1aW50OF90KWExLCAodWludDhfdClhMik7CiAgICByZXR1cm4g
b3BlbihidWYsIE9fUkRXUiwgMCk7CiAgfSBlbHNlIHsKCiAgICBjaGFyIGJ1ZlsxMDI0XTsKICAg
IGNoYXIqIGhhc2g7CiAgICBzdHJuY3B5KGJ1ZiwgKGNoYXIqKWEwLCBzaXplb2YoYnVmKSk7CiAg
ICBidWZbc2l6ZW9mKGJ1ZikgLSAxXSA9IDA7CiAgICB3aGlsZSAoKGhhc2ggPSBzdHJjaHIoYnVm
LCAnIycpKSkgewogICAgICAqaGFzaCA9ICcwJyArIChjaGFyKShhMSAlIDEwKTsKICAgICAgYTEg
Lz0gMTA7CiAgICB9CiAgICByZXR1cm4gb3BlbihidWYsIGEyLCAwKTsKICB9Cn0KCnN0YXRpYyB1
aW50cHRyX3Qgc3l6X29wZW5fcHRzKHVpbnRwdHJfdCBhMCwgdWludHB0cl90IGExKQp7CgogIGlu
dCBwdHlubyA9IDA7CiAgaWYgKGlvY3RsKGEwLCBUSU9DR1BUTiwgJnB0eW5vKSkKICAgIHJldHVy
biAtMTsKICBjaGFyIGJ1ZlsxMjhdOwogIHNwcmludGYoYnVmLCAiL2Rldi9wdHMvJWQiLCBwdHlu
byk7CiAgcmV0dXJuIG9wZW4oYnVmLCBhMSwgMCk7Cn0KCnN0YXRpYyB1aW50cHRyX3Qgc3l6X2Z1
c2VfbW91bnQodWludHB0cl90IGEwLCB1aW50cHRyX3QgYTEsCiAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgdWludHB0cl90IGEyLCB1aW50cHRyX3QgYTMsCiAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgdWludHB0cl90IGE0LCB1aW50cHRyX3QgYTUpCnsKCiAgdWludDY0X3Qg
dGFyZ2V0ID0gYTA7CiAgdWludDY0X3QgbW9kZSA9IGExOwogIHVpbnQ2NF90IHVpZCA9IGEyOwog
IHVpbnQ2NF90IGdpZCA9IGEzOwogIHVpbnQ2NF90IG1heHJlYWQgPSBhNDsKICB1aW50NjRfdCBm
bGFncyA9IGE1OwoKICBpbnQgZmQgPSBvcGVuKCIvZGV2L2Z1c2UiLCBPX1JEV1IpOwogIGlmIChm
ZCA9PSAtMSkKICAgIHJldHVybiBmZDsKICBjaGFyIGJ1ZlsxMDI0XTsKICBzcHJpbnRmKGJ1Ziwg
ImZkPSVkLHVzZXJfaWQ9JWxkLGdyb3VwX2lkPSVsZCxyb290bW9kZT0wJW8iLCBmZCwKICAgICAg
ICAgIChsb25nKXVpZCwgKGxvbmcpZ2lkLCAodW5zaWduZWQpbW9kZSAmIH4zdSk7CiAgaWYgKG1h
eHJlYWQgIT0gMCkKICAgIHNwcmludGYoYnVmICsgc3RybGVuKGJ1ZiksICIsbWF4X3JlYWQ9JWxk
IiwgKGxvbmcpbWF4cmVhZCk7CiAgaWYgKG1vZGUgJiAxKQogICAgc3RyY2F0KGJ1ZiwgIixkZWZh
dWx0X3Blcm1pc3Npb25zIik7CiAgaWYgKG1vZGUgJiAyKQogICAgc3RyY2F0KGJ1ZiwgIixhbGxv
d19vdGhlciIpOwogIHN5c2NhbGwoU1lTX21vdW50LCAiIiwgdGFyZ2V0LCAiZnVzZSIsIGZsYWdz
LCBidWYpOwoKICByZXR1cm4gZmQ7Cn0KCnN0YXRpYyB1aW50cHRyX3Qgc3l6X2Z1c2VibGtfbW91
bnQodWludHB0cl90IGEwLCB1aW50cHRyX3QgYTEsCiAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgdWludHB0cl90IGEyLCB1aW50cHRyX3QgYTMsCiAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgdWludHB0cl90IGE0LCB1aW50cHRyX3QgYTUsCiAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgdWludHB0cl90IGE2LCB1aW50cHRyX3QgYTcpCnsKCiAgdWlu
dDY0X3QgdGFyZ2V0ID0gYTA7CiAgdWludDY0X3QgYmxrZGV2ID0gYTE7CiAgdWludDY0X3QgbW9k
ZSA9IGEyOwogIHVpbnQ2NF90IHVpZCA9IGEzOwogIHVpbnQ2NF90IGdpZCA9IGE0OwogIHVpbnQ2
NF90IG1heHJlYWQgPSBhNTsKICB1aW50NjRfdCBibGtzaXplID0gYTY7CiAgdWludDY0X3QgZmxh
Z3MgPSBhNzsKCiAgaW50IGZkID0gb3BlbigiL2Rldi9mdXNlIiwgT19SRFdSKTsKICBpZiAoZmQg
PT0gLTEpCiAgICByZXR1cm4gZmQ7CiAgaWYgKHN5c2NhbGwoU1lTX21rbm9kYXQsIEFUX0ZEQ1dE
LCBibGtkZXYsIFNfSUZCTEssIG1ha2VkZXYoNywgMTk5KSkpCiAgICByZXR1cm4gZmQ7CiAgY2hh
ciBidWZbMjU2XTsKICBzcHJpbnRmKGJ1ZiwgImZkPSVkLHVzZXJfaWQ9JWxkLGdyb3VwX2lkPSVs
ZCxyb290bW9kZT0wJW8iLCBmZCwKICAgICAgICAgIChsb25nKXVpZCwgKGxvbmcpZ2lkLCAodW5z
aWduZWQpbW9kZSAmIH4zdSk7CiAgaWYgKG1heHJlYWQgIT0gMCkKICAgIHNwcmludGYoYnVmICsg
c3RybGVuKGJ1ZiksICIsbWF4X3JlYWQ9JWxkIiwgKGxvbmcpbWF4cmVhZCk7CiAgaWYgKGJsa3Np
emUgIT0gMCkKICAgIHNwcmludGYoYnVmICsgc3RybGVuKGJ1ZiksICIsYmxrc2l6ZT0lbGQiLCAo
bG9uZylibGtzaXplKTsKICBpZiAobW9kZSAmIDEpCiAgICBzdHJjYXQoYnVmLCAiLGRlZmF1bHRf
cGVybWlzc2lvbnMiKTsKICBpZiAobW9kZSAmIDIpCiAgICBzdHJjYXQoYnVmLCAiLGFsbG93X290
aGVyIik7CiAgc3lzY2FsbChTWVNfbW91bnQsIGJsa2RldiwgdGFyZ2V0LCAiZnVzZWJsayIsIGZs
YWdzLCBidWYpOwoKICByZXR1cm4gZmQ7Cn0KCnN0YXRpYyB1aW50cHRyX3QgZXhlY3V0ZV9zeXNj
YWxsKGludCBuciwgdWludHB0cl90IGEwLCB1aW50cHRyX3QgYTEsCiAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhMiwgdWludHB0cl90IGEzLAogICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICB1aW50cHRyX3QgYTQsIHVpbnRwdHJfdCBhNSwKICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgdWludHB0cl90IGE2LCB1aW50cHRyX3QgYTcsCiAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhOCkKewogIHN3aXRjaCAobnIp
IHsKICBkZWZhdWx0OgogICAgcmV0dXJuIHN5c2NhbGwobnIsIGEwLCBhMSwgYTIsIGEzLCBhNCwg
YTUpOwogIGNhc2UgX19OUl9zeXpfdGVzdDoKICAgIHJldHVybiAwOwogIGNhc2UgX19OUl9zeXpf
b3Blbl9kZXY6CiAgICByZXR1cm4gc3l6X29wZW5fZGV2KGEwLCBhMSwgYTIpOwogIGNhc2UgX19O
Ul9zeXpfb3Blbl9wdHM6CiAgICByZXR1cm4gc3l6X29wZW5fcHRzKGEwLCBhMSk7CiAgY2FzZSBf
X05SX3N5el9mdXNlX21vdW50OgogICAgcmV0dXJuIHN5el9mdXNlX21vdW50KGEwLCBhMSwgYTIs
IGEzLCBhNCwgYTUpOwogIGNhc2UgX19OUl9zeXpfZnVzZWJsa19tb3VudDoKICAgIHJldHVybiBz
eXpfZnVzZWJsa19tb3VudChhMCwgYTEsIGEyLCBhMywgYTQsIGE1LCBhNiwgYTcpOwogIH0KfQoK
bG9uZyByWzEwXTsKdm9pZCogdGhyKHZvaWQqIGFyZykKewogIHN3aXRjaCAoKGxvbmcpYXJnKSB7
CiAgY2FzZSAwOgogICAgclswXSA9CiAgICAgICAgZXhlY3V0ZV9zeXNjYWxsKF9fTlJfbW1hcCwg
MHgyMDAwMDAwMHVsLCAweGVjZjAwMHVsLCAweDN1bCwKICAgICAgICAgICAgICAgICAgICAgICAg
MHgzMnVsLCAweGZmZmZmZmZmZmZmZmZmZmZ1bCwgMHgwdWwsIDAsIDAsIDApOwogICAgYnJlYWs7
CiAgY2FzZSAxOgogICAgclsxXSA9IGV4ZWN1dGVfc3lzY2FsbChfX05SX3NvY2tldCwgMHgwdWws
IDB4MHVsLCAweDB1bCwgMCwgMCwgMCwgMCwKICAgICAgICAgICAgICAgICAgICAgICAgICAgMCwg
MCk7CiAgICBicmVhazsKICBjYXNlIDI6CiAgICBOT05GQUlMSU5HKG1lbWNweSgKICAgICAgICAo
dm9pZCopMHgyMDJlMmY4MCwKICAgICAgICAiXHgwYVx4MDBceDQyXHg0Mlx4N2NceGQyXHhlMVx4
OWZceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwIgogICAgICAgICJceDAwXHgwMFx4MDBceDAw
XHgwMFx4MDBceDAwXHgwMFx4MDFceDhjXHg1NFx4MmZceDMzXHgwMFx4MDAiCiAgICAgICAgIlx4
MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgw
MCIKICAgICAgICAiXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBc
eDAwXHgwMFx4MDBceDAwIgogICAgICAgICJceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgw
MFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDAiCiAgICAgICAgIlx4MDBceDAwXHgwMFx4MDBc
eDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMCIKICAgICAgICAiXHgw
MFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAw
IgogICAgICAgICJceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4
MDBceDAwXHgwMFx4MDAiCiAgICAgICAgIlx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAw
IiwKICAgICAgICAxMjgpKTsKICAgIHJbM10gPSBleGVjdXRlX3N5c2NhbGwoX19OUl9iaW5kLCBy
WzFdLCAweDIwMmUyZjgwdWwsIDB4ODB1bCwgMCwgMCwKICAgICAgICAgICAgICAgICAgICAgICAg
ICAgMCwgMCwgMCwgMCk7CiAgICBicmVhazsKICBjYXNlIDM6CiAgICByWzRdID0gZXhlY3V0ZV9z
eXNjYWxsKF9fTlJfc29ja2V0LCAweGF1bCwgMHgydWwsIDB4NzN1bCwgMCwgMCwgMCwKICAgICAg
ICAgICAgICAgICAgICAgICAgICAgMCwgMCwgMCk7CiAgICBicmVhazsKICBjYXNlIDQ6CiAgICBy
WzVdID0KICAgICAgICBleGVjdXRlX3N5c2NhbGwoX19OUl9tbWFwLCAweDIwZWNmMDAwdWwsIDB4
MTAwMHVsLCAweDN1bCwKICAgICAgICAgICAgICAgICAgICAgICAgMHgzMnVsLCAweGZmZmZmZmZm
ZmZmZmZmZmZ1bCwgMHgwdWwsIDAsIDAsIDApOwogICAgYnJlYWs7CiAgY2FzZSA1OgogICAgTk9O
RkFJTElORyhtZW1jcHkoCiAgICAgICAgKHZvaWQqKTB4MjBlY2YwMDAsCiAgICAgICAgIlx4MGFc
eDAwXHg0Mlx4NDJceDI1XHg5M1x4OWZceGU0XHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMCIK
ICAgICAgICAiXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAxXHg5MFx4MGRceDBl
XHgzOFx4MDBceDAwIgogICAgICAgICJceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4
MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDAiCiAgICAgICAgIlx4MDBceDAwXHgwMFx4MDBceDAw
XHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMCIKICAgICAgICAiXHgwMFx4
MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwIgog
ICAgICAgICJceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBc
eDAwXHgwMFx4MDAiCiAgICAgICAgIlx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgw
MFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMCIKICAgICAgICAiXHgwMFx4MDBceDAwXHgwMFx4MDBc
eDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwIgogICAgICAgICJceDAwXHgw
MFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMCIsCiAgICAgICAgMTI4KSk7CiAgICByWzddID0gZXhl
Y3V0ZV9zeXNjYWxsKF9fTlJfYmluZCwgcls0XSwgMHgyMGVjZjAwMHVsLCAweDgwdWwsIDAsIDAs
CiAgICAgICAgICAgICAgICAgICAgICAgICAgIDAsIDAsIDAsIDApOwogICAgYnJlYWs7CiAgY2Fz
ZSA2OgogICAgTk9ORkFJTElORyhtZW1jcHkoCiAgICAgICAgKHZvaWQqKTB4MjBlYzYwMDAsCiAg
ICAgICAgIlx4MGFceDAwXHg0Mlx4NDJceDdjXHhkMlx4ZTFceDlmXHgwMFx4MDBceDAwXHgwMFx4
MDBceDAwXHgwMCIKICAgICAgICAiXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAx
XHg4Y1x4NTRceDJmXHgzM1x4MDBceDAwIgogICAgICAgICJceDAwXHgwMFx4MDBceDAwXHgwMFx4
MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDAiCiAgICAgICAgIlx4MDBceDAw
XHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMCIKICAg
ICAgICAiXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgw
MFx4MDBceDAwIgogICAgICAgICJceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBc
eDAwXHgwMFx4MDBceDAwXHgwMFx4MDAiCiAgICAgICAgIlx4MDBceDAwXHgwMFx4MDBceDAwXHgw
MFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMCIKICAgICAgICAiXHgwMFx4MDBc
eDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwIgogICAg
ICAgICJceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMCIsCiAgICAgICAgMTI4KSk7CiAg
ICByWzldID0gZXhlY3V0ZV9zeXNjYWxsKF9fTlJfYmluZCwgcls0XSwgMHgyMGVjNjAwMHVsLCAw
eDgwdWwsIDAsIDAsCiAgICAgICAgICAgICAgICAgICAgICAgICAgIDAsIDAsIDAsIDApOwogICAg
YnJlYWs7CiAgfQogIHJldHVybiAwOwp9CgppbnQgbWFpbigpCnsKICBsb25nIGk7CiAgcHRocmVh
ZF90IHRoWzE0XTsKCiAgaW5zdGFsbF9zZWd2X2hhbmRsZXIoKTsKICBtZW1zZXQociwgLTEsIHNp
emVvZihyKSk7CiAgc3JhbmQoZ2V0cGlkKCkpOwogIGZvciAoaSA9IDA7IGkgPCA3OyBpKyspIHsK
ICAgIHB0aHJlYWRfY3JlYXRlKCZ0aFtpXSwgMCwgdGhyLCAodm9pZCopaSk7CiAgICB1c2xlZXAo
MTAwMDApOwogIH0KICBmb3IgKGkgPSAwOyBpIDwgNzsgaSsrKSB7CiAgICBwdGhyZWFkX2NyZWF0
ZSgmdGhbNyArIGldLCAwLCB0aHIsICh2b2lkKilpKTsKICAgIGlmIChyYW5kKCkgJSAyKQogICAg
ICB1c2xlZXAocmFuZCgpICUgMTAwMDApOwogIH0KICB1c2xlZXAoMTAwMDAwKTsKICByZXR1cm4g
MDsKfQo=
--94eb2c18f88aefc87a0540bda317--
