From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv6: GPF in rt6_ifdown
Date: Wed, 21 Jun 2017 19:53:05 +0200
Message-ID: <CAAeHK+xGdXtfTxNE0g71-Ffkvj+6qy4At15WisvBbXMQ4EUqNQ@mail.gmail.com>
References: <CAAeHK+z0TdpY83FiMtHBMChEQgE+0-+8roNFVzM5Uo-duCgpVA@mail.gmail.com>
 <CAAeHK+wuKeG6HhvuP89DNXYE+Okq7HDdJ+OgYGoK+FN-k=w+fA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="f403045e87f854187905527c0a12"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wuKeG6HhvuP89DNXYE+Okq7HDdJ+OgYGoK+FN-k=w+fA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--f403045e87f854187905527c0a12
Content-Type: text/plain; charset="UTF-8"

On Wed, Jun 21, 2017 at 3:09 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Wed, Jun 21, 2017 at 2:08 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while fuzzing the kernel with syzkaller.
>>
>> On commit 9705596d08ac87c18aee32cc97f2783b7d14624e (4.12-rc6+).
>>
>> It might be related to:
>> https://groups.google.com/forum/#!topic/syzkaller/ZJaqAiFLe3k
>>
>> I only have a reproducer in the form of a syzkaller program, attached
>> together with my .config.
>
> I now have a C reproducer as well, attached.

And here's a much simpler reproducer.

>
>>
>> It can be executed as described here:
>> https://github.com/google/syzkaller/blob/master/docs/executing_syzkaller_programs.md
>>
>> With the following flags:
>> ./syz-execprog -repeat=0 -procs=8 -sandbox=namespace ./log
>>
>> Since I'm able to reproduce it, I can apply debug patches and test
>> with them if required.
>>
>> kasan: CONFIG_KASAN_INLINE enabled
>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>> general protection fault: 0000 [#1] SMP KASAN
>> Modules linked in:
>> CPU: 1 PID: 4499 Comm: syz-executor Not tainted 4.12.0-rc6+ #10
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> task: ffff880068e88000 task.stack: ffff88005e0a0000
>> RIP: 0010:rt6_uncached_list_flush_dev net/ipv6/route.c:167
>> RIP: 0010:rt6_ifdown+0x3d4/0x910 net/ipv6/route.c:2824
>> RSP: 0018:ffff88005e0a6e38 EFLAGS: 00010246
>> RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffffc900029a2000
>> RDX: 0000000000002dce RSI: ffffffff83ea9ee8 RDI: ffff88006ca25444
>> RBP: ffff88005e0a6f98 R08: 0000000000000001 R09: c9811a8e00000000
>> R10: ffff880068e88810 R11: dffffc0000000000 R12: ffff88005e0ad518
>> R13: ffff88005e0ad500 R14: ffff88006200b300 R15: dffffc0000000000
>> FS:  00007f4ccaad9700(0000) GS:ffff88006cb00000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 000000002000f000 CR3: 00000000672e8000 CR4: 00000000000006e0
>> Call Trace:
>>  addrconf_ifdown+0x1a8/0x1a30 net/ipv6/addrconf.c:3588
>>  addrconf_notify+0x1cf/0x2630 net/ipv6/addrconf.c:3512
>>  notifier_call_chain+0x14a/0x2e0 kernel/notifier.c:93
>>  __raw_notifier_call_chain kernel/notifier.c:394
>>  raw_notifier_call_chain+0x32/0x40 kernel/notifier.c:401
>>  call_netdevice_notifiers_info+0x56/0x90 net/core/dev.c:1650
>>  call_netdevice_notifiers net/core/dev.c:1666
>>  __dev_notify_flags+0x202/0x330 net/core/dev.c:6647
>>  dev_change_flags+0xfa/0x150 net/core/dev.c:6678
>>  dev_ifsioc+0x62f/0x9f0 net/core/dev_ioctl.c:254
>>  dev_ioctl+0x24e/0x1160 net/core/dev_ioctl.c:532
>>  sock_do_ioctl+0x99/0xb0 net/socket.c:913
>>  sock_ioctl+0x294/0x440 net/socket.c:1004
>>  vfs_ioctl fs/ioctl.c:45
>>  do_vfs_ioctl+0x1c4/0x1660 fs/ioctl.c:685
>>  SYSC_ioctl fs/ioctl.c:700
>>  SyS_ioctl+0x94/0xc0 fs/ioctl.c:691
>>  entry_SYSCALL_64_fastpath+0x1f/0xbe arch/x86/entry/entry_64.S:203
>> RIP: 0033:0x446349
>> RSP: 002b:00007f4ccaad8c08 EFLAGS: 00000282 ORIG_RAX: 0000000000000010
>> RAX: ffffffffffffffda RBX: 0000000000003210 RCX: 0000000000446349
>> RDX: 00000000208befe0 RSI: 0000000000008914 RDI: 0000000000000018
>> RBP: 00000000ffffffff R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000282 R12: 0000000000000018
>> R13: 0000000000003210 R14: 00000000006e42d0 R15: 0000000000008914
>> Code: 49 8b 9d 58 01 00 00 4c 89 e0 48 c1 e8 03 42 80 3c 38 00 0f 85
>> 6d 04 00 00 49 8b 45 18 48 89 85 f0 fe ff ff 48 89 d8 48 c1 e8 03 <42>
>> 80 3c 38 00 0f 85 5d 04 00 00 4c 3b 33 0f 84 d7 01 00 00 e8
>> RIP: rt6_ifdown+0x3d4/0x910 RSP: ffff88005e0a6e38
>> ---[ end trace f2e889448df70bb4 ]---
>> Kernel panic - not syncing: Fatal exception in interrupt
>> Kernel Offset: disabled
>> ---[ end Kernel panic - not syncing: Fatal exception in interrupt

--f403045e87f854187905527c0a12
Content-Type: text/x-csrc; charset="US-ASCII"; name="rt6_ifdown-poc-2.c"
Content-Disposition: attachment; filename="rt6_ifdown-poc-2.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j47arb491

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCgojaWZuZGVmIF9fTlJfc2VuZG1tc2cKI2RlZmluZSBfX05SX3NlbmRtbXNnIDMw
NwojZW5kaWYKI2lmbmRlZiBfX05SX21tYXAKI2RlZmluZSBfX05SX21tYXAgOQojZW5kaWYKI2lm
bmRlZiBfX05SX3NvY2tldAojZGVmaW5lIF9fTlJfc29ja2V0IDQxCiNlbmRpZgojaWZuZGVmIF9f
TlJfaW9jdGwKI2RlZmluZSBfX05SX2lvY3RsIDE2CiNlbmRpZgojaWZuZGVmIF9fTlJfY29ubmVj
dAojZGVmaW5lIF9fTlJfY29ubmVjdCA0MgojZW5kaWYKCiNkZWZpbmUgX0dOVV9TT1VSQ0UKCiNp
bmNsdWRlIDxzdGRpbnQuaD4KI2luY2x1ZGUgPHN0cmluZy5oPgojaW5jbHVkZSA8c3lzL3N5c2Nh
bGwuaD4KI2luY2x1ZGUgPHVuaXN0ZC5oPgoKc3RhdGljIHZvaWQgdGVzdCgpOwoKdm9pZCBsb29w
KCkKewogIHdoaWxlICgxKSB7CiAgICB0ZXN0KCk7CiAgfQp9Cgpsb25nIHJbODFdOwp2b2lkIHRl
c3QoKQp7CiAgbWVtc2V0KHIsIC0xLCBzaXplb2YocikpOwogIHJbMF0gPSBzeXNjYWxsKF9fTlJf
bW1hcCwgMHgyMDAwMDAwMHVsLCAweGZmZjAwMHVsLCAweDN1bCwgMHgzMnVsLAogICAgICAgICAg
ICAgICAgIDB4ZmZmZmZmZmZmZmZmZmZmZnVsLCAweDB1bCk7CiAgclsxXSA9IHN5c2NhbGwoX19O
Ul9zb2NrZXQsIDB4YXVsLCAweDN1bCwgMHg2dWwpOwogIG1lbWNweSgodm9pZCopMHgyMDMzNDAw
MCwKICAgICAgICAgIlx4NzNceDY5XHg3NFx4MzBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAw
XHgwMFx4MDBceDAwXHgwMCIKICAgICAgICAgIlx4MDAiLAogICAgICAgICAxNik7CiAgKih1aW50
MTZfdCopMHgyMDMzNDAxMCA9ICh1aW50MTZfdCkweDI7CiAgcls0XSA9IHN5c2NhbGwoX19OUl9p
b2N0bCwgclsxXSwgMHg4OTE0dWwsIDB4MjAzMzQwMDB1bCk7CiAgcls1XSA9IHN5c2NhbGwoX19O
Ul9zb2NrZXQsIDB4MnVsLCAweDgwNnVsLCAweDB1bCk7CiAgbWVtY3B5KCh2b2lkKikweDIwZGM0
MDAwLAogICAgICAgICAiXHg2Y1x4NmZceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4
MDBceDAwXHgwMFx4MDBceDAwIgogICAgICAgICAiXHgwMCIsCiAgICAgICAgIDE2KTsKICAqKHVp
bnQ2NF90KikweDIwZGM0MDEwID0gKHVpbnQ2NF90KTB4MDsKICAqKHVpbnQ2NF90KikweDIwZGM0
MDE4ID0gKHVpbnQ2NF90KTB4ZmZmZmZmZmZmZmZmZmZmZjsKICAqKHVpbnQxNl90KikweDIwZGM0
MDIwID0gKHVpbnQxNl90KTB4MjsKICAqKHVpbnQ4X3QqKTB4MjBkYzQwMjIgPSAodWludDhfdCkw
eDQwOwogICoodWludDhfdCopMHgyMGRjNDAyMyA9ICh1aW50OF90KTB4MmVkNTsKICAqKHVpbnQ4
X3QqKTB4MjBkYzQwMjQgPSAodWludDhfdCkweDg7CiAgclsxM10gPSBzeXNjYWxsKF9fTlJfaW9j
dGwsIHJbNV0sIDB4ODkyMnVsLCAweDIwZGM0MDAwdWwpOwogIHJbMTRdID0KICAgICAgc3lzY2Fs
bChfX05SX3NvY2tldCwgMHhhdWwsIDB4ODAwMDAwMDA4MDgwM3VsLCAweDIwMDAwMDAwMGZmdWwp
OwogICoodWludDE2X3QqKTB4MjBmZmNmZTQgPSAodWludDE2X3QpMHhhOwogICoodWludDE2X3Qq
KTB4MjBmZmNmZTYgPSAodWludDE2X3QpMHgyMDRlOwogICoodWludDMyX3QqKTB4MjBmZmNmZTgg
PSAodWludDMyX3QpMHhmZmZmZmZmZmZmZmZmZmZkOwogICoodWludDY0X3QqKTB4MjBmZmNmZWMg
PSAodWludDY0X3QpMHgwOwogICoodWludDY0X3QqKTB4MjBmZmNmZjQgPSAodWludDY0X3QpMHgx
MDAwMDAwMDAwMDAwMDA7CiAgKih1aW50MzJfdCopMHgyMGZmY2ZmYyA9ICh1aW50MzJfdCkweGZm
ZmZmZmZmZmZmZmZmZmQ7CiAgclsyMV0gPSBzeXNjYWxsKF9fTlJfY29ubmVjdCwgclsxNF0sIDB4
MjBmZmNmZTR1bCwgMHgxY3VsKTsKICAqKHVpbnQ2NF90KikweDIwZmUyZjQwID0gKHVpbnQ2NF90
KTB4MDsKICAqKHVpbnQzMl90KikweDIwZmUyZjQ4ID0gKHVpbnQzMl90KTB4MDsKICAqKHVpbnQ2
NF90KikweDIwZmUyZjUwID0gKHVpbnQ2NF90KTB4MjA3MzZmNzA7CiAgKih1aW50NjRfdCopMHgy
MGZlMmY1OCA9ICh1aW50NjRfdCkweDM7CiAgKih1aW50NjRfdCopMHgyMGZlMmY2MCA9ICh1aW50
NjRfdCkweDIwZmYzMDAwOwogICoodWludDY0X3QqKTB4MjBmZTJmNjggPSAodWludDY0X3QpMHgw
OwogICoodWludDMyX3QqKTB4MjBmZTJmNzAgPSAodWludDMyX3QpMHgxOwogICoodWludDMyX3Qq
KTB4MjBmZTJmNzggPSAodWludDMyX3QpMHgwOwogICoodWludDY0X3QqKTB4MjBmZTJmODAgPSAo
dWludDY0X3QpMHgwOwogICoodWludDMyX3QqKTB4MjBmZTJmODggPSAodWludDMyX3QpMHgwOwog
ICoodWludDY0X3QqKTB4MjBmZTJmOTAgPSAodWludDY0X3QpMHgyMDY0MjAwMDsKICAqKHVpbnQ2
NF90KikweDIwZmUyZjk4ID0gKHVpbnQ2NF90KTB4MjsKICAqKHVpbnQ2NF90KikweDIwZmUyZmEw
ID0gKHVpbnQ2NF90KTB4MjBhY2VlNDA7CiAgKih1aW50NjRfdCopMHgyMGZlMmZhOCA9ICh1aW50
NjRfdCkweDQ7CiAgKih1aW50MzJfdCopMHgyMGZlMmZiMCA9ICh1aW50MzJfdCkweDQwMTA7CiAg
Kih1aW50MzJfdCopMHgyMGZlMmZiOCA9ICh1aW50MzJfdCkweDU7CiAgKih1aW50NjRfdCopMHgy
MGZlMmZjMCA9ICh1aW50NjRfdCkweDA7CiAgKih1aW50MzJfdCopMHgyMGZlMmZjOCA9ICh1aW50
MzJfdCkweDA7CiAgKih1aW50NjRfdCopMHgyMGZlMmZkMCA9ICh1aW50NjRfdCkweDIwZmY0Nzk3
OwogICoodWludDY0X3QqKTB4MjBmZTJmZDggPSAodWludDY0X3QpMHgwOwogICoodWludDY0X3Qq
KTB4MjBmZTJmZTAgPSAodWludDY0X3QpMHgyMGY1MTAwMDsKICAqKHVpbnQ2NF90KikweDIwZmUy
ZmU4ID0gKHVpbnQ2NF90KTB4MTsKICAqKHVpbnQzMl90KikweDIwZmUyZmYwID0gKHVpbnQzMl90
KTB4MjAwMDgwMDA7CiAgKih1aW50MzJfdCopMHgyMGZlMmZmOCA9ICh1aW50MzJfdCkweDI7CiAg
Kih1aW50NjRfdCopMHgyMDczNmY3MCA9ICh1aW50NjRfdCkweDIwYTRmZjE2OwogICoodWludDY0
X3QqKTB4MjA3MzZmNzggPSAodWludDY0X3QpMHgxOTsKICAqKHVpbnQ2NF90KikweDIwNzM2Zjgw
ID0gKHVpbnQ2NF90KTB4MjA4NjlmZmY7CiAgKih1aW50NjRfdCopMHgyMDczNmY4OCA9ICh1aW50
NjRfdCkweDE7CiAgKih1aW50NjRfdCopMHgyMDczNmY5MCA9ICh1aW50NjRfdCkweDIwYjY5MDAw
OwogICoodWludDY0X3QqKTB4MjA3MzZmOTggPSAodWludDY0X3QpMHhlOwogIG1lbWNweSgodm9p
ZCopMHgyMGE0ZmYxNiwKICAgICAgICAgIlx4OGNceDU3XHgwOFx4YmJceDk0XHgxMlx4NDBceGJh
XHg5ZFx4MTNceGVlXHgzMFx4YjBceDhjXHg0ZSIKICAgICAgICAgIlx4YjJceDA1XHhhZVx4OTZc
eDAyXHhkNVx4MDZceDI5XHg1NVx4ZmYiLAogICAgICAgICAyNSk7CiAgbWVtY3B5KCh2b2lkKikw
eDIwODY5ZmZmLCAiXHhhNSIsIDEpOwogIG1lbWNweSgodm9pZCopMHgyMGI2OTAwMCwKICAgICAg
ICAgIlx4ZGZceDRiXHg4NVx4Y2JceDVkXHg1Zlx4ZDdceGUyXHg1MFx4MDVceGIyXHg1Y1x4YzVc
eDBlIiwKICAgICAgICAgMTQpOwogICoodWludDY0X3QqKTB4MjA2NDIwMDAgPSAodWludDY0X3Qp
MHgyMGFhNDAwMDsKICAqKHVpbnQ2NF90KikweDIwNjQyMDA4ID0gKHVpbnQ2NF90KTB4MTk7CiAg
Kih1aW50NjRfdCopMHgyMDY0MjAxMCA9ICh1aW50NjRfdCkweDIwZmYzMDAwOwogICoodWludDY0
X3QqKTB4MjA2NDIwMTggPSAodWludDY0X3QpMHhhNjsKICBtZW1jcHkoKHZvaWQqKTB4MjBhYTQw
MDAsCiAgICAgICAgICJceDAxXHg0NVx4MDBceDAwXHgwMFx4MWZceDJjXHgwM1x4MWRceGQ4XHhj
ZFx4YmRceGNlXHgzYVx4MzkiCiAgICAgICAgICJceGJkXHg0Nlx4NGVceDBmXHhjZlx4NGNceGRj
XHgxOFx4OGVceDhhIiwKICAgICAgICAgMjUpOwogIG1lbWNweSgodm9pZCopMHgyMGZmMzAwMCwK
ICAgICAgICAgIlx4NTZceGJlXHhkZlx4OThceDMxXHgwMVx4ZTlceDAzXHhiYlx4NjBceGQwXHhm
NFx4NTdceGE0XHg0ZCIKICAgICAgICAgIlx4NDZceDA3XHhiNVx4ZjBceGIyXHg1Ylx4ZDZceDY3
XHg0NFx4ZjlceGQxXHg1Zlx4NTdceDQ4XHhjYSIKICAgICAgICAgIlx4OGVceGQ1XHg4Ylx4M2Rc
eDA4XHhlOFx4NDZceDIzXHg4Nlx4NWJceGNkXHhhNVx4ZGRceGFmXHg1MyIKICAgICAgICAgIlx4
ODBceDA5XHhhZVx4ZGFceGMwXHgwZlx4ZGZceDYyXHhjZFx4ZGJceDBhXHhlN1x4M2ZceGU5XHg2
MCIKICAgICAgICAgIlx4YzdceDNiXHhjNFx4NWJceGYwXHg1Y1x4MDlceGFkXHgzNlx4MzFceGJj
XHg3YVx4ODJceDBhXHhiNCIKICAgICAgICAgIlx4OGJceDJiXHgyYVx4YzBceDU1XHg4OFx4YWNc
eGQzXHgzMVx4NTVceDU0XHg3M1x4OWNceGEzXHg5MSIKICAgICAgICAgIlx4ZmZceGUyXHg1OFx4
ZDNceGI2XHg3YVx4MjRceGQ0XHgwZlx4MDlceDY5XHhjYVx4NDlceDdhXHhlMyIKICAgICAgICAg
Ilx4YjZceDQ4XHg0NVx4YzlceDllXHg2ZFx4YmFceGQ3XHgyYVx4OWNceDA0XHhjYlx4ZWFceDI2
XHhlOSIKICAgICAgICAgIlx4MTlceGEyXHg3NFx4ZGVceDcwXHgyOFx4ZTdceDNmXHhmYlx4NGJc
eGY5XHg3OVx4ZDVceDlmXHhlNSIKICAgICAgICAgIlx4Y2ZceGE5XHgwNVx4YWNceGYwXHg5MFx4
MGZceGEzXHg0MFx4NTJceDQwXHgwYlx4OTVceDRmXHg0MyIKICAgICAgICAgIlx4ZDVceDQ0XHg1
Y1x4NzhceGViXHhjNFx4MmVceDkxXHgwZlx4MmFceDZmXHhjMlx4YTRceGU5XHhlNiIKICAgICAg
ICAgIlx4MTIiLAogICAgICAgICAxNjYpOwogICoodWludDY0X3QqKTB4MjBhY2VlNDAgPSAodWlu
dDY0X3QpMHgxMDsKICAqKHVpbnQzMl90KikweDIwYWNlZTQ4ID0gKHVpbnQzMl90KTB4ODg7CiAg
Kih1aW50MzJfdCopMHgyMGFjZWU0YyA9ICh1aW50MzJfdCkweDgwMDAwMDAwNjsKICAqKHVpbnQ2
NF90KikweDIwYWNlZTUwID0gKHVpbnQ2NF90KTB4MTA7CiAgKih1aW50MzJfdCopMHgyMGFjZWU1
OCA9ICh1aW50MzJfdCkweDEwODsKICAqKHVpbnQzMl90KikweDIwYWNlZTVjID0gKHVpbnQzMl90
KTB4OTsKICAqKHVpbnQ2NF90KikweDIwYWNlZTYwID0gKHVpbnQ2NF90KTB4MTA7CiAgKih1aW50
MzJfdCopMHgyMGFjZWU2OCA9ICh1aW50MzJfdCkweDExZjsKICAqKHVpbnQzMl90KikweDIwYWNl
ZTZjID0gKHVpbnQzMl90KTB4NjsKICAqKHVpbnQ2NF90KikweDIwYWNlZTcwID0gKHVpbnQ2NF90
KTB4MTA7CiAgKih1aW50MzJfdCopMHgyMGFjZWU3OCA9ICh1aW50MzJfdCkweDEwZjsKICAqKHVp
bnQzMl90KikweDIwYWNlZTdjID0gKHVpbnQzMl90KTB4MTAwMDE7CiAgKih1aW50NjRfdCopMHgy
MGY1MTAwMCA9ICh1aW50NjRfdCkweDEwOwogICoodWludDMyX3QqKTB4MjBmNTEwMDggPSAodWlu
dDMyX3QpMHgxOwogICoodWludDMyX3QqKTB4MjBmNTEwMGMgPSAodWludDMyX3QpMHg3OwogIHJb
NzZdID0gc3lzY2FsbChfX05SX3NlbmRtbXNnLCByWzE0XSwgMHgyMGZlMmY0MHVsLCAweDN1bCwg
MHhjMHVsKTsKICByWzc3XSA9IHN5c2NhbGwoX19OUl9zb2NrZXQsIDB4YXVsLCAweDN1bCwgMHg2
dWwpOwogIG1lbWNweSgodm9pZCopMHgyMDMzNDAwMCwKICAgICAgICAgIlx4NzNceDY5XHg3NFx4
MzBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMFx4MDBceDAwXHgwMCIKICAgICAgICAg
Ilx4MDAiLAogICAgICAgICAxNik7CiAgKih1aW50MTZfdCopMHgyMDMzNDAxMCA9ICh1aW50MTZf
dCkweDE7CiAgcls4MF0gPSBzeXNjYWxsKF9fTlJfaW9jdGwsIHJbNzddLCAweDg5MTR1bCwgMHgy
MDMzNDAwMHVsKTsKfQoKaW50IG1haW4oKQp7CiAgaW50IGk7CiAgZm9yIChpID0gMDsgaSA8IDg7
IGkrKykgewogICAgaWYgKGZvcmsoKSA9PSAwKSB7CiAgICAgIGxvb3AoKTsKICAgICAgcmV0dXJu
IDA7CiAgICB9CiAgfQogIHNsZWVwKDEwMDAwMDApOwogIHJldHVybiAwOwp9Cgo=
--f403045e87f854187905527c0a12--
