From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/key: slab-out-of-bounds in pfkey_compile_policy
Date: Tue, 2 May 2017 18:45:03 +0200
Message-ID: <CAAeHK+xqxvEWMXS9sDNi2seUqFzJkijKJhivB8JDehpCJvBAaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c13d740f52490054e8d4277
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--94eb2c13d740f52490054e8d4277
Content-Type: text/plain; charset=UTF-8

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

On commit d3b5d35290d729a2518af00feca867385a1b08fa (4.11).

A reproducer and .config are attached.

==================================================================
BUG: KASAN: slab-out-of-bounds in pfkey_compile_policy+0x8e6/0xd40 at
addr ffff88006701f798
Read of size 1280 by task a.out/4181
CPU: 0 PID: 4181 Comm: a.out Not tainted 4.11.0+ #306
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x292/0x395 lib/dump_stack.c:52
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
 print_address_description mm/kasan/report.c:202
 kasan_report_error mm/kasan/report.c:291
 kasan_report+0x252/0x510 mm/kasan/report.c:347
 check_memory_region_inline mm/kasan/kasan.c:326
 check_memory_region+0x139/0x190 mm/kasan/kasan.c:333
 memcpy+0x23/0x50 mm/kasan/kasan.c:368
 pfkey_sadb2xfrm_user_sec_ctx net/key/af_key.c:474
 pfkey_compile_policy+0x8e6/0xd40 net/key/af_key.c:3294
 xfrm_user_policy+0x349/0x560 net/xfrm/xfrm_state.c:1892
 do_ip_setsockopt.isra.12+0x1d05/0x38c0 net/ipv4/ip_sockglue.c:1175
 ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
 tcp_setsockopt+0x82/0xd0 net/ipv4/tcp.c:2732
 sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2750
 SYSC_setsockopt net/socket.c:1798
 SyS_setsockopt+0x270/0x3a0 net/socket.c:1777
 entry_SYSCALL_64_fastpath+0x1f/0xbe arch/x86/entry/entry_64.S:204
RIP: 0033:0x7f13a0968b79
RSP: 002b:00007fff131bc3f8 EFLAGS: 00000206 ORIG_RAX: 0000000000000036
RAX: ffffffffffffffda RBX: 00007fff131bc550 RCX: 00007f13a0968b79
RDX: 0000000000000010 RSI: 0000000000000000 RDI: 0000000000000003
RBP: 00000000004004e0 R08: 00000000000000c2 R09: 0000000000000000
R10: 0000000020a2ff3e R11: 0000000000000206 R12: 0000000000000000
R13: 00007fff131bc550 R14: 0000000000000000 R15: 0000000000000000
Object at ffff88006701f780, in cache kmalloc-256 size: 256
Allocated:
PID = 4181
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
 __kmalloc+0xa0/0x2d0 mm/slub.c:3745
 kmalloc ./include/linux/slab.h:495
 xfrm_user_policy+0xd8/0x560 net/xfrm/xfrm_state.c:1881
 do_ip_setsockopt.isra.12+0x1d05/0x38c0 net/ipv4/ip_sockglue.c:1175
 ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
 tcp_setsockopt+0x82/0xd0 net/ipv4/tcp.c:2732
 sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2750
 SYSC_setsockopt net/socket.c:1798
 SyS_setsockopt+0x270/0x3a0 net/socket.c:1777
 entry_SYSCALL_64_fastpath+0x1f/0xbe arch/x86/entry/entry_64.S:204
Freed:
PID = 3951
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525
 kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
 slab_free_hook mm/slub.c:1357
 slab_free_freelist_hook mm/slub.c:1379
 slab_free mm/slub.c:2961
 kfree+0xe8/0x2b0 mm/slub.c:3882
 free_bprm+0x19d/0x200 fs/exec.c:1382
 do_execveat_common.isra.34+0x19ad/0x2220 fs/exec.c:1778
 do_execve fs/exec.c:1813
 SYSC_execve fs/exec.c:1894
 SyS_execve+0x39/0x50 fs/exec.c:1889
 do_syscall_64+0x2c7/0x7a0 arch/x86/entry/common.c:281
 return_from_SYSCALL_64+0x0/0x7a arch/x86/entry/entry_64.S:246
Memory state around the buggy address:
 ffff88006701f700: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff88006701f780: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff88006701f800: 00 00 00 00 00 00 00 00 02 fc fc fc fc fc fc fc
                                           ^
 ffff88006701f880: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
 ffff88006701f900: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

--94eb2c13d740f52490054e8d4277
Content-Type: text/x-csrc; charset=US-ASCII; name="pfkey_compile_policy-oob-poc.c"
Content-Disposition: attachment; filename="pfkey_compile_policy-oob-poc.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j27s4uk00

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCgojaWZuZGVmIF9fTlJfbW1hcAojZGVmaW5lIF9fTlJfbW1hcCA5CiNlbmRpZgoj
aWZuZGVmIF9fTlJfc29ja2V0CiNkZWZpbmUgX19OUl9zb2NrZXQgNDEKI2VuZGlmCiNpZm5kZWYg
X19OUl9zZXRzb2Nrb3B0CiNkZWZpbmUgX19OUl9zZXRzb2Nrb3B0IDU0CiNlbmRpZgoKI2RlZmlu
ZSBfR05VX1NPVVJDRQoKI2luY2x1ZGUgPHN5cy9pb2N0bC5oPgojaW5jbHVkZSA8c3lzL21tYW4u
aD4KI2luY2x1ZGUgPHN5cy9tb3VudC5oPgojaW5jbHVkZSA8c3lzL3ByY3RsLmg+CiNpbmNsdWRl
IDxzeXMvcmVzb3VyY2UuaD4KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1ZGUgPHN5cy9z
dGF0Lmg+CiNpbmNsdWRlIDxzeXMvc3lzY2FsbC5oPgojaW5jbHVkZSA8c3lzL3RpbWUuaD4KI2lu
Y2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lzL3dhaXQuaD4KCiNpbmNsdWRlIDxhcnBh
L2luZXQuaD4KI2luY2x1ZGUgPGxpbnV4L2NhcGFiaWxpdHkuaD4KI2luY2x1ZGUgPGxpbnV4L2lm
Lmg+CiNpbmNsdWRlIDxsaW51eC9pZl9ldGhlci5oPgojaW5jbHVkZSA8bGludXgvaWZfdHVuLmg+
CiNpbmNsdWRlIDxsaW51eC9pcC5oPgojaW5jbHVkZSA8bGludXgva3ZtLmg+CiNpbmNsdWRlIDxs
aW51eC9zY2hlZC5oPgojaW5jbHVkZSA8bGludXgvdGNwLmg+CiNpbmNsdWRlIDxuZXQvaWZfYXJw
Lmg+CgojaW5jbHVkZSA8YXNzZXJ0Lmg+CiNpbmNsdWRlIDxkaXJlbnQuaD4KI2luY2x1ZGUgPGVy
cm5vLmg+CiNpbmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8Z3JwLmg+CiNpbmNsdWRlIDxwdGhy
ZWFkLmg+CiNpbmNsdWRlIDxzZXRqbXAuaD4KI2luY2x1ZGUgPHNpZ25hbC5oPgojaW5jbHVkZSA8
c3RkYXJnLmg+CiNpbmNsdWRlIDxzdGRib29sLmg+CiNpbmNsdWRlIDxzdGRkZWYuaD4KI2luY2x1
ZGUgPHN0ZGludC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGxpYi5oPgojaW5j
bHVkZSA8c3RyaW5nLmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KCnN0YXRpYyB1aW50cHRyX3QgZXhl
Y3V0ZV9zeXNjYWxsKGludCBuciwgdWludHB0cl90IGEwLCB1aW50cHRyX3QgYTEsCiAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhMiwgdWludHB0cl90IGEzLAogICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICB1aW50cHRyX3QgYTQsIHVpbnRwdHJfdCBhNSwK
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdWludHB0cl90IGE2LCB1aW50cHRyX3Qg
YTcsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhOCkKewogIHN3
aXRjaCAobnIpIHsKICBkZWZhdWx0OgogICAgcmV0dXJuIHN5c2NhbGwobnIsIGEwLCBhMSwgYTIs
IGEzLCBhNCwgYTUpOwogIH0KfQoKbG9uZyByWzRdOwoKdm9pZCBtYWluKCkKewogIG1lbXNldChy
LCAtMSwgc2l6ZW9mKHIpKTsKICByWzBdID0gZXhlY3V0ZV9zeXNjYWxsKF9fTlJfbW1hcCwgMHgy
MDAwMDAwMHVsLCAweGVlZDAwMHVsLCAweDN1bCwKICAgICAgICAgICAgICAgICAgICAgICAgIDB4
MzJ1bCwgMHhmZmZmZmZmZmZmZmZmZmZmdWwsIDB4MHVsLCAwLCAwLCAwKTsKICByWzFdID0gZXhl
Y3V0ZV9zeXNjYWxsKF9fTlJfc29ja2V0LCAweDJ1bCwgMHgxdWwsIDB4MHVsLCAwLCAwLCAwLCAw
LAogICAgICAgICAgICAgICAgICAgICAgICAgMCwgMCk7CiAgKG1lbWNweSgKICAgICAgKHZvaWQq
KTB4MjBhMmZmM2UsCiAgICAgICJceDAyXHgwMFx4MDBceDAwXHgwMlx4MDBceDAxXHgwMFx4MDBc
eDAwXHhiZVx4OGNceDVlXHhlMVx4OGNceDg4IgogICAgICAiXHhhMVx4MDBceDAxXHgwMFx4MDBc
eDAwXHgwMFx4MDVceDAxXHhkYVx4ZmRceDAyXHhhM1x4OGFceDNjXHhkYyIKICAgICAgIlx4Zjdc
eGI5XHgzM1x4ZDhceDk4XHgwNVx4NTVceGY3XHg0OFx4NTJceGJiXHg2YVx4ODhceDA3XHg1Nlx4
N2YiCiAgICAgICJceDU5XHhkYlx4YTZceDdlXHgyMVx4NDdceGIzXHg1NVx4MDRceDAwXHg2Zlx4
Y2RceDY3XHgwMVx4ZTJceDAxIgogICAgICAiXHgwMFx4NjdceDJmXHgyMVx4NjNceGUwXHgyMFx4
OWNceGVlXHg0YVx4NWFceGNiXHgzZFx4YTRceDgzXHhmMCIKICAgICAgIlx4YTRceGNmXHg5N1x4
ZTFceDcwXHhiNlx4YzhceDhlXHhiYlx4ZmZceDA2XHgwMVx4MDBceDAwXHgwMFx4MDEiCiAgICAg
ICJceDAwXHgwMFx4MDBceGIxXHgyMVx4ZWNceDE0XHg3NFx4ZDdceDEwXHhmNVx4NDJceDUwXHg2
Ylx4MDBceGVjIgogICAgICAiXHgwMFx4OGJceGM1XHhjZlx4YjdceGIzXHhlN1x4ZWNceDA4XHhl
OFx4N2NceGNjXHhmZlx4ZjZceGJhXHgwMCIKICAgICAgIlx4MDBceDAwXHgwMlx4NGZceDAyXHg5
OFx4ZTlceGU5XHhmNVx4NTRceDA2XHhhYVx4MTBceGRkXHhmZFx4ZmYiCiAgICAgICJceDAzXHg2
YVx4MDBceDAwXHgwMFx4MDBceGQ3XHg5MVx4YTJceGZmXHhlM1x4YzVceDczXHgyY1x4MWFceGRi
IgogICAgICAiXHg4YVx4ZmNceDViXHhkOFx4YzJceGQxXHg3Zlx4ZGVceGEyXHgxYlx4NTRceDEw
XHg2OFx4MzlceDNkXHgyMiIKICAgICAgIlx4YjVceGFmXHhmYVx4MDBceDA0XHgxYVx4ZDBceGQy
XHhjMFx4M2VceGVmXHg2N1x4OTVceGRlXHg0Mlx4ZTMiCiAgICAgICJceDg0XHg5YiIsCiAgICAg
IDE5NCkpOwogIHJbM10gPSBleGVjdXRlX3N5c2NhbGwoX19OUl9zZXRzb2Nrb3B0LCByWzFdLCAw
eDB1bCwgMHgxMHVsLAogICAgICAgICAgICAgICAgICAgICAgICAgMHgyMGEyZmYzZXVsLCAweGMy
dWwsIDAsIDAsIDAsIDApOwp9Cg==
--94eb2c13d740f52490054e8d4277--
