From: Andrey Konovalov <andreyknvl@google.com>
Subject: Fwd: net/netlink: global-out-of-bounds in genl_family_rcv_msg/validate_nla
Date: Thu, 3 Nov 2016 01:26:12 +0100
Message-ID: <CAAeHK+xYr-eczJ78V58es7PuA=8xvG8aKWauXYkNA=99jxGkGQ@mail.gmail.com>
References: <CAAeHK+xm5_n-Ep2d4YEq=Yx=f5M2NpV-So0o7811LUk+pLr+rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11406a82e8980105405a9aef
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        Florian Westphal <fw@strlen.de>,
        netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+xm5_n-Ep2d4YEq=Yx=f5M2NpV-So0o7811LUk+pLr+rg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a11406a82e8980105405a9aef
Content-Type: text/plain; charset=UTF-8

Hi,

I've got the following error report while running the syzkaller fuzzer:

==================================================================
BUG: KASAN: global-out-of-bounds in validate_nla+0x49b/0x4e0 at addr
ffffffff8407e3ac
Read of size 2 by task a.out/3877
Address belongs to variable[<        none        >]
cgroupstats_cmd_get_policy+0xc/0x40 ??:?
CPU: 1 PID: 3877 Comm: a.out Not tainted 4.9.0-rc3+ #336
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff880063077690 ffffffff81b46934 ffff880063077720 ffffffff847a369f
 ffffffff8407e3a0 ffffffff8407e3ac ffff880063077710 ffffffff8150ac7c
 ffffffff85f44280 ffff88006aec1de8 ffff88006aec1e38 0000000000000286
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<     inline     >] print_address_description mm/kasan/report.c:204
 [<ffffffff8150ac7c>] kasan_report_error+0x49c/0x4d0 mm/kasan/report.c:283
 [<     inline     >] kasan_report mm/kasan/report.c:303
 [<ffffffff8150ad2e>] __asan_report_load2_noabort+0x3e/0x40
mm/kasan/report.c:322
 [<ffffffff81be27eb>] validate_nla+0x49b/0x4e0 lib/nlattr.c:41
 [<ffffffff81be2ab5>] nla_parse+0x115/0x280 lib/nlattr.c:195
 [<     inline     >] nlmsg_parse ./include/net/netlink.h:386
 [<ffffffff82dc2723>] genl_family_rcv_msg+0x543/0xc80
net/netlink/genetlink.c:613
 [<ffffffff82dc3016>] genl_rcv_msg+0x1b6/0x270 net/netlink/genetlink.c:658
 [<ffffffff82dc10a0>] netlink_rcv_skb+0x2c0/0x3b0 net/netlink/af_netlink.c:2281
 [<ffffffff82dc21c8>] genl_rcv+0x28/0x40 net/netlink/genetlink.c:669
 [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
 [<ffffffff82dbf959>] netlink_unicast+0x5a9/0x880 net/netlink/af_netlink.c:1240
 [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
 [<     inline     >] sock_sendmsg_nosec net/socket.c:606
 [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
 [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
 [<     inline     >] new_sync_write fs/read_write.c:499
 [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
 [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
 [<     inline     >] SYSC_write fs/read_write.c:607
 [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
 [<ffffffff83fc0401>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
Memory state around the buggy address:
 ffffffff8407e280: 00 02 fa fa fa fa fa fa 00 00 00 00 02 fa fa fa
 ffffffff8407e300: fa fa fa fa 00 00 00 00 00 00 00 00 00 00 00 00
>ffffffff8407e380: fa fa fa fa 00 fa fa fa fa fa fa fa 00 00 04 fa
                                  ^
 ffffffff8407e400: fa fa fa fa 00 00 00 00 00 02 fa fa fa fa fa fa
 ffffffff8407e480: 00 00 00 03 fa fa fa fa 00 00 00 00 00 01 fa fa
==================================================================

A reproducer is attached.

On commit 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).

Thanks!

--001a11406a82e8980105405a9aef
Content-Type: application/octet-stream; name="netlink-validate-oob-poc.c"
Content-Disposition: attachment; filename="netlink-validate-oob-poc.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iv1m1mxc0

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCgojaWZuZGVmIF9fTlJfbW1hcAojZGVmaW5lIF9fTlJfbW1hcCA5CiNlbmRpZgoj
aWZuZGVmIF9fTlJfc3l6X2luamVjdF9ibG9iCiNkZWZpbmUgX19OUl9zeXpfaW5qZWN0X2Jsb2Ig
MTAwMDAwNgojZW5kaWYKI2lmbmRlZiBfX05SX3N5el9vcGVuX3B0cwojZGVmaW5lIF9fTlJfc3l6
X29wZW5fcHRzIDEwMDAwMDMKI2VuZGlmCiNpZm5kZWYgX19OUl9zb2NrZXQKI2RlZmluZSBfX05S
X3NvY2tldCA0MQojZW5kaWYKI2lmbmRlZiBfX05SX3dyaXRlCiNkZWZpbmUgX19OUl93cml0ZSAx
CiNlbmRpZgojaWZuZGVmIF9fTlJfc3l6X2Z1c2VfbW91bnQKI2RlZmluZSBfX05SX3N5el9mdXNl
X21vdW50IDEwMDAwMDQKI2VuZGlmCiNpZm5kZWYgX19OUl9zeXpfZnVzZWJsa19tb3VudAojZGVm
aW5lIF9fTlJfc3l6X2Z1c2VibGtfbW91bnQgMTAwMDAwNQojZW5kaWYKI2lmbmRlZiBfX05SX3N5
el9vcGVuX2RldgojZGVmaW5lIF9fTlJfc3l6X29wZW5fZGV2IDEwMDAwMDIKI2VuZGlmCiNpZm5k
ZWYgX19OUl9zeXpfdGVzdAojZGVmaW5lIF9fTlJfc3l6X3Rlc3QgMTAwMDAwMQojZW5kaWYKCiNp
bmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8cHRocmVhZC5oPgojaW5jbHVkZSA8c2V0am1wLmg+
CiNpbmNsdWRlIDxzaWduYWwuaD4KI2luY2x1ZGUgPHN0ZGRlZi5oPgojaW5jbHVkZSA8c3RkaW50
Lmg+CiNpbmNsdWRlIDxzdGRpby5oPgojaW5jbHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDxzdHJp
bmcuaD4KI2luY2x1ZGUgPHN5cy9pb2N0bC5oPgojaW5jbHVkZSA8c3lzL3N0YXQuaD4KI2luY2x1
ZGUgPHN5cy9zeXNjYWxsLmg+CiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2luY2x1ZGUgPHVuaXN0
ZC5oPgoKX190aHJlYWQgaW50IHNraXBfc2VndjsKX190aHJlYWQgam1wX2J1ZiBzZWd2X2VudjsK
CnN0YXRpYyB2b2lkIHNlZ3ZfaGFuZGxlcihpbnQgc2lnLCBzaWdpbmZvX3QqIGluZm8sIHZvaWQq
IHVjdHgpCnsKICBpZiAoX19hdG9taWNfbG9hZF9uKCZza2lwX3NlZ3YsIF9fQVRPTUlDX1JFTEFY
RUQpKQogICAgX2xvbmdqbXAoc2Vndl9lbnYsIDEpOwogIGV4aXQoc2lnKTsKfQoKc3RhdGljIHZv
aWQgaW5zdGFsbF9zZWd2X2hhbmRsZXIoKQp7CiAgc3RydWN0IHNpZ2FjdGlvbiBzYTsKICBtZW1z
ZXQoJnNhLCAwLCBzaXplb2Yoc2EpKTsKICBzYS5zYV9zaWdhY3Rpb24gPSBzZWd2X2hhbmRsZXI7
CiAgc2Euc2FfZmxhZ3MgPSBTQV9OT0RFRkVSIHwgU0FfU0lHSU5GTzsKICBzaWdhY3Rpb24oU0lH
U0VHViwgJnNhLCBOVUxMKTsKICBzaWdhY3Rpb24oU0lHQlVTLCAmc2EsIE5VTEwpOwp9CgojZGVm
aW5lIE5PTkZBSUxJTkcoLi4uKSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgIFwKICB7ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICBcCiAgICBfX2F0b21pY19mZXRjaF9hZGQoJnNraXBf
c2VndiwgMSwgX19BVE9NSUNfU0VRX0NTVCk7ICAgICAgICAgICAgICAgXAogICAgaWYgKF9zZXRq
bXAoc2Vndl9lbnYpID09IDApIHsgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
IFwKICAgICAgX19WQV9BUkdTX187ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICBcCiAgICB9ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgXAogICAgX19hdG9taWNfZmV0Y2hfc3Vi
KCZza2lwX3NlZ3YsIDEsIF9fQVRPTUlDX1NFUV9DU1QpOyAgICAgICAgICAgICAgIFwKICB9Cgpz
dGF0aWMgdWludHB0cl90IHN5el9vcGVuX2Rldih1aW50cHRyX3QgYTAsIHVpbnRwdHJfdCBhMSwg
dWludHB0cl90IGEyKQp7CiAgaWYgKGEwID09IDB4YyB8fCBhMCA9PSAweGIpIHsKICAgIGNoYXIg
YnVmWzEyOF07CiAgICBzcHJpbnRmKGJ1ZiwgIi9kZXYvJXMvJWQ6JWQiLCBhMCA9PSAweGMgPyAi
Y2hhciIgOiAiYmxvY2siLAogICAgICAgICAgICAodWludDhfdClhMSwgKHVpbnQ4X3QpYTIpOwog
ICAgcmV0dXJuIG9wZW4oYnVmLCBPX1JEV1IsIDApOwogIH0gZWxzZSB7CiAgICBjaGFyIGJ1Zlsx
MDI0XTsKICAgIGNoYXIqIGhhc2g7CiAgICBzdHJuY3B5KGJ1ZiwgKGNoYXIqKWEwLCBzaXplb2Yo
YnVmKSk7CiAgICBidWZbc2l6ZW9mKGJ1ZikgLSAxXSA9IDA7CiAgICB3aGlsZSAoKGhhc2ggPSBz
dHJjaHIoYnVmLCAnIycpKSkgewogICAgICAqaGFzaCA9ICcwJyArIChjaGFyKShhMSAlIDEwKTsK
ICAgICAgYTEgLz0gMTA7CiAgICB9CiAgICByZXR1cm4gb3BlbihidWYsIGEyLCAwKTsKICB9Cn0K
CnN0YXRpYyB1aW50cHRyX3Qgc3l6X29wZW5fcHRzKHVpbnRwdHJfdCBhMCwgdWludHB0cl90IGEx
KQp7CiAgaW50IHB0eW5vID0gMDsKICBpZiAoaW9jdGwoYTAsIFRJT0NHUFROLCAmcHR5bm8pKQog
ICAgcmV0dXJuIC0xOwogIGNoYXIgYnVmWzEyOF07CiAgc3ByaW50ZihidWYsICIvZGV2L3B0cy8l
ZCIsIHB0eW5vKTsKICByZXR1cm4gb3BlbihidWYsIGExLCAwKTsKfQoKc3RhdGljIHVpbnRwdHJf
dCBzeXpfZnVzZV9tb3VudCh1aW50cHRyX3QgYTAsIHVpbnRwdHJfdCBhMSwKICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICB1aW50cHRyX3QgYTIsIHVpbnRwdHJfdCBhMywKICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICB1aW50cHRyX3QgYTQsIHVpbnRwdHJfdCBhNSkKewogIHVp
bnQ2NF90IHRhcmdldCA9IGEwOwogIHVpbnQ2NF90IG1vZGUgPSBhMTsKICB1aW50NjRfdCB1aWQg
PSBhMjsKICB1aW50NjRfdCBnaWQgPSBhMzsKICB1aW50NjRfdCBtYXhyZWFkID0gYTQ7CiAgdWlu
dDY0X3QgZmxhZ3MgPSBhNTsKCiAgaW50IGZkID0gb3BlbigiL2Rldi9mdXNlIiwgT19SRFdSKTsK
ICBpZiAoZmQgPT0gLTEpCiAgICByZXR1cm4gZmQ7CiAgY2hhciBidWZbMTAyNF07CiAgc3ByaW50
ZihidWYsICJmZD0lZCx1c2VyX2lkPSVsZCxncm91cF9pZD0lbGQscm9vdG1vZGU9MCVvIiwgZmQs
CiAgICAgICAgICAobG9uZyl1aWQsIChsb25nKWdpZCwgKHVuc2lnbmVkKW1vZGUgJiB+M3UpOwog
IGlmIChtYXhyZWFkICE9IDApCiAgICBzcHJpbnRmKGJ1ZiArIHN0cmxlbihidWYpLCAiLG1heF9y
ZWFkPSVsZCIsIChsb25nKW1heHJlYWQpOwogIGlmIChtb2RlICYgMSkKICAgIHN0cmNhdChidWYs
ICIsZGVmYXVsdF9wZXJtaXNzaW9ucyIpOwogIGlmIChtb2RlICYgMikKICAgIHN0cmNhdChidWYs
ICIsYWxsb3dfb3RoZXIiKTsKICBzeXNjYWxsKFNZU19tb3VudCwgIiIsIHRhcmdldCwgImZ1c2Ui
LCBmbGFncywgYnVmKTsKICByZXR1cm4gZmQ7Cn0KCnN0YXRpYyB1aW50cHRyX3Qgc3l6X2Z1c2Vi
bGtfbW91bnQodWludHB0cl90IGEwLCB1aW50cHRyX3QgYTEsCiAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgdWludHB0cl90IGEyLCB1aW50cHRyX3QgYTMsCiAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgdWludHB0cl90IGE0LCB1aW50cHRyX3QgYTUsCiAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgdWludHB0cl90IGE2LCB1aW50cHRyX3QgYTcpCnsK
ICB1aW50NjRfdCB0YXJnZXQgPSBhMDsKICB1aW50NjRfdCBibGtkZXYgPSBhMTsKICB1aW50NjRf
dCBtb2RlID0gYTI7CiAgdWludDY0X3QgdWlkID0gYTM7CiAgdWludDY0X3QgZ2lkID0gYTQ7CiAg
dWludDY0X3QgbWF4cmVhZCA9IGE1OwogIHVpbnQ2NF90IGJsa3NpemUgPSBhNjsKICB1aW50NjRf
dCBmbGFncyA9IGE3OwoKICBpbnQgZmQgPSBvcGVuKCIvZGV2L2Z1c2UiLCBPX1JEV1IpOwogIGlm
IChmZCA9PSAtMSkKICAgIHJldHVybiBmZDsKICBpZiAoc3lzY2FsbChTWVNfbWtub2RhdCwgQVRf
RkRDV0QsIGJsa2RldiwgU19JRkJMSywgbWFrZWRldig3LCAxOTkpKSkKICAgIHJldHVybiBmZDsK
ICBjaGFyIGJ1ZlsyNTZdOwogIHNwcmludGYoYnVmLCAiZmQ9JWQsdXNlcl9pZD0lbGQsZ3JvdXBf
aWQ9JWxkLHJvb3Rtb2RlPTAlbyIsIGZkLAogICAgICAgICAgKGxvbmcpdWlkLCAobG9uZylnaWQs
ICh1bnNpZ25lZCltb2RlICYgfjN1KTsKICBpZiAobWF4cmVhZCAhPSAwKQogICAgc3ByaW50Zihi
dWYgKyBzdHJsZW4oYnVmKSwgIixtYXhfcmVhZD0lbGQiLCAobG9uZyltYXhyZWFkKTsKICBpZiAo
Ymxrc2l6ZSAhPSAwKQogICAgc3ByaW50ZihidWYgKyBzdHJsZW4oYnVmKSwgIixibGtzaXplPSVs
ZCIsIChsb25nKWJsa3NpemUpOwogIGlmIChtb2RlICYgMSkKICAgIHN0cmNhdChidWYsICIsZGVm
YXVsdF9wZXJtaXNzaW9ucyIpOwogIGlmIChtb2RlICYgMikKICAgIHN0cmNhdChidWYsICIsYWxs
b3dfb3RoZXIiKTsKICBzeXNjYWxsKFNZU19tb3VudCwgYmxrZGV2LCB0YXJnZXQsICJmdXNlYmxr
IiwgZmxhZ3MsIGJ1Zik7CiAgcmV0dXJuIGZkOwp9CgpzdGF0aWMgdWludHB0cl90IHN5el9pbmpl
Y3RfYmxvYih1aW50cHRyX3QgYTApCnsKICBpbnQgZmQgPSBvcGVuKCIvc3lzL2tlcm5lbC9kZWJ1
Zy9zeXpfdm5ldCIsIE9fUkRXUik7CiAgaWYgKGZkID09IC0xKQogICAgcmV0dXJuIGZkOwogIGlv
Y3RsKGZkLCAwLCAodm9pZCopYTApOwogIGNsb3NlKGZkKTsKICByZXR1cm4gMDsKfQoKc3RhdGlj
IHVpbnRwdHJfdCBleGVjdXRlX3N5c2NhbGwoaW50IG5yLCB1aW50cHRyX3QgYTAsIHVpbnRwdHJf
dCBhMSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdWludHB0cl90IGEyLCB1aW50
cHRyX3QgYTMsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhNCwg
dWludHB0cl90IGE1LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB1aW50cHRyX3Qg
YTYsIHVpbnRwdHJfdCBhNywKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdWludHB0
cl90IGE4KQp7CiAgc3dpdGNoIChucikgewogIGRlZmF1bHQ6CiAgICByZXR1cm4gc3lzY2FsbChu
ciwgYTAsIGExLCBhMiwgYTMsIGE0LCBhNSk7CiAgY2FzZSBfX05SX3N5el90ZXN0OgogICAgcmV0
dXJuIDA7CiAgY2FzZSBfX05SX3N5el9vcGVuX2RldjoKICAgIHJldHVybiBzeXpfb3Blbl9kZXYo
YTAsIGExLCBhMik7CiAgY2FzZSBfX05SX3N5el9vcGVuX3B0czoKICAgIHJldHVybiBzeXpfb3Bl
bl9wdHMoYTAsIGExKTsKICBjYXNlIF9fTlJfc3l6X2Z1c2VfbW91bnQ6CiAgICByZXR1cm4gc3l6
X2Z1c2VfbW91bnQoYTAsIGExLCBhMiwgYTMsIGE0LCBhNSk7CiAgY2FzZSBfX05SX3N5el9mdXNl
YmxrX21vdW50OgogICAgcmV0dXJuIHN5el9mdXNlYmxrX21vdW50KGEwLCBhMSwgYTIsIGEzLCBh
NCwgYTUsIGE2LCBhNyk7CiAgY2FzZSBfX05SX3N5el9pbmplY3RfYmxvYjoKICAgIHJldHVybiBz
eXpfaW5qZWN0X2Jsb2IoYTApOwogIH0KfQoKbG9uZyByWzVdOwoKaW50IG1haW4oKQp7CiAgaW5z
dGFsbF9zZWd2X2hhbmRsZXIoKTsKICBtZW1zZXQociwgLTEsIHNpemVvZihyKSk7CiAgclswXSA9
IGV4ZWN1dGVfc3lzY2FsbChfX05SX21tYXAsIDB4MjBmMjYwMDB1bCwgMHg0MDAwdWwsIDB4M3Vs
LAogICAgICAgICAgICAgICAgICAgICAgICAgMHgzMnVsLCAweGZmZmZmZmZmZmZmZmZmZmZ1bCwg
MHgwdWwsIDAsIDAsIDApOwogIHJbMV0gPSBleGVjdXRlX3N5c2NhbGwoX19OUl9zb2NrZXQsIDB4
MTB1bCwgMHgzdWwsIDB4MTB1bCwgMCwgMCwgMCwgMCwKICAgICAgICAgICAgICAgICAgICAgICAg
IDAsIDApOwogIHJbMl0gPSBleGVjdXRlX3N5c2NhbGwoX19OUl9tbWFwLCAweDIwZjFiMDAwdWws
IDB4MTAwMHVsLCAweDN1bCwKICAgICAgICAgICAgICAgICAgICAgICAgIDB4MzJ1bCwgMHhmZmZm
ZmZmZmZmZmZmZmZmdWwsIDB4MHVsLCAwLCAwLCAwKTsKICBOT05GQUlMSU5HKG1lbWNweSgodm9p
ZCopMHgyMGYxYmZkNiwKICAgICAgICAgICAgICAgICAgICAiXHgxZlx4MDBceDAwXHgwMFx4MmZc
eDAwXHgwN1x4MDZceDAwXHgwMFx4MDBceDA1IgogICAgICAgICAgICAgICAgICAgICJceDI5XHhm
Zlx4MGZceGZmXHgwNFx4MDBceDAwXHgwMFx4MDVceDAwXHgwM1x4MDAiCiAgICAgICAgICAgICAg
ICAgICAgIlx4MDNceDRiXHgwMFx4YTBceDAxXHgwOFx4YTBceGViXHhmYlx4N2ZceGZmXHhmZiIK
ICAgICAgICAgICAgICAgICAgICAiXHhmZlx4ZjlceGE5XHg0N1x4ZTZceGU0IiwKICAgICAgICAg
ICAgICAgICAgICA0MikpOwogIHJbNF0gPSBleGVjdXRlX3N5c2NhbGwoX19OUl93cml0ZSwgclsx
XSwgMHgyMGYxYmZkNnVsLCAweDJhdWwsIDAsIDAsCiAgICAgICAgICAgICAgICAgICAgICAgICAw
LCAwLCAwLCAwKTsKICByZXR1cm4gMDsKfQo=
--001a11406a82e8980105405a9aef--
