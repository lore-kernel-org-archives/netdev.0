From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv4: deadlock in ip_ra_control
Date: Sun, 5 Mar 2017 18:04:46 -0800
Message-ID: <CAM_iQpVf=Ky+hDFj2rt8VA3Jb1dv8oLgqovYWvHxj-k8KH3XSA@mail.gmail.com>
References: <CACT4Y+b-c=_QC51h0Qgp4buG=6cWO1xax7MrKgFS1BKV2=mdQg@mail.gmail.com>
 <CAM_iQpX=Vb-0xMjwOrriYcG38GT+U9zknggVbCb0_pBUh1NMkQ@mail.gmail.com>
 <CACT4Y+aWYLbu5Eq1WN_T6q_zDBUdP8wiAVJK1x1D_XspQSY-RQ@mail.gmail.com> <CACT4Y+b0uuE+YarvhfvWOanaoKxTsv92C5LC8btLOwEAG9Lr1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114b09c004eba5054a0653d9
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+b0uuE+YarvhfvWOanaoKxTsv92C5LC8btLOwEAG9Lr1w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a114b09c004eba5054a0653d9
Content-Type: text/plain; charset=UTF-8

On Fri, Mar 3, 2017 at 10:43 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Thu, Mar 2, 2017 at 10:40 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Wed, Mar 1, 2017 at 6:18 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Wed, Mar 1, 2017 at 2:44 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>> Hello,
>>>>
>>>> I've got the following deadlock report while running syzkaller fuzzer
>>>> on linux-next/51788aebe7cae79cb334ad50641347465fc188fd:
>>>>
>>>> ======================================================
>>>> [ INFO: possible circular locking dependency detected ]
>>>> 4.10.0-next-20170301+ #1 Not tainted
>>>> -------------------------------------------------------
>>>> syz-executor1/3394 is trying to acquire lock:
>>>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>] lock_sock
>>>> include/net/sock.h:1460 [inline]
>>>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>]
>>>> do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>>>>
>>>> but task is already holding lock:
>>>>  (rtnl_mutex){+.+.+.}, at: [<ffffffff836fbd97>] rtnl_lock+0x17/0x20
>>>> net/core/rtnetlink.c:70
>>>>
>>>> which lock already depends on the new lock.
>>>>
>>>>
>>>> the existing dependency chain (in reverse order) is:
>>>>
>>>> -> #1 (rtnl_mutex){+.+.+.}:
>>>>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>>>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>>>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>>>>        __mutex_lock_common kernel/locking/mutex.c:754 [inline]
>>>>        __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:891
>>>>        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:906
>>>>        rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
>>>>        mrtsock_destruct+0x86/0x2c0 net/ipv4/ipmr.c:1281
>>>>        ip_ra_control+0x459/0x600 net/ipv4/ip_sockglue.c:372
>>>>        do_ip_setsockopt.isra.12+0x1064/0x3540 net/ipv4/ip_sockglue.c:1161
>>>>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>>>>        raw_setsockopt+0xb7/0xd0 net/ipv4/raw.c:839
>>>>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>>>>        SYSC_setsockopt net/socket.c:1786 [inline]
>>>>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>>>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>>
>>>> -> #0 (sk_lock-AF_INET){+.+.+.}:
>>>>        check_prev_add kernel/locking/lockdep.c:1828 [inline]
>>>>        check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1938
>>>>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>>>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>>>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>>>>        lock_sock_nested+0xcb/0x120 net/core/sock.c:2530
>>>>        lock_sock include/net/sock.h:1460 [inline]
>>>>        do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>>>>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>>>>        tcp_setsockopt+0x82/0xd0 net/ipv4/tcp.c:2721
>>>>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>>>>        SYSC_setsockopt net/socket.c:1786 [inline]
>>>>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>>>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>>
>>>
>>> Please try the attached patch (compile only).
>>
>>
>> Pushed the patch to the bots.
>> Thanks
>
>
> This patch triggers:

Ah, update the patch to fix this.

--001a114b09c004eba5054a0653d9
Content-Type: text/plain; charset=US-ASCII; name="ip-router-alert.diff"
Content-Disposition: attachment; filename="ip-router-alert.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_izxgriv60

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMgYi9uZXQvaXB2NC9pcF9zb2NrZ2x1
ZS5jCmluZGV4IGViZDk1M2IuLmJkYTMxOGEgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L2lwX3NvY2tn
bHVlLmMKKysrIGIvbmV0L2lwdjQvaXBfc29ja2dsdWUuYwpAQCAtNTkxLDYgKzU5MSw3IEBAIHN0
YXRpYyBib29sIHNldHNvY2tvcHRfbmVlZHNfcnRubChpbnQgb3B0bmFtZSkKIAljYXNlIE1DQVNU
X0xFQVZFX0dST1VQOgogCWNhc2UgTUNBU1RfTEVBVkVfU09VUkNFX0dST1VQOgogCWNhc2UgTUNB
U1RfVU5CTE9DS19TT1VSQ0U6CisJY2FzZSBJUF9ST1VURVJfQUxFUlQ6CiAJCXJldHVybiB0cnVl
OwogCX0KIAlyZXR1cm4gZmFsc2U7CmRpZmYgLS1naXQgYS9uZXQvaXB2NC9pcG1yLmMgYi9uZXQv
aXB2NC9pcG1yLmMKaW5kZXggYzAzMTdjOS4uYjAzNmU4NSAxMDA2NDQKLS0tIGEvbmV0L2lwdjQv
aXBtci5jCisrKyBiL25ldC9pcHY0L2lwbXIuYwpAQCAtMTI3OCw3ICsxMjc4LDcgQEAgc3RhdGlj
IHZvaWQgbXJ0c29ja19kZXN0cnVjdChzdHJ1Y3Qgc29jayAqc2spCiAJc3RydWN0IG5ldCAqbmV0
ID0gc29ja19uZXQoc2spOwogCXN0cnVjdCBtcl90YWJsZSAqbXJ0OwogCi0JcnRubF9sb2NrKCk7
CisJQVNTRVJUX1JUTkwoKTsKIAlpcG1yX2Zvcl9lYWNoX3RhYmxlKG1ydCwgbmV0KSB7CiAJCWlm
IChzayA9PSBydG5sX2RlcmVmZXJlbmNlKG1ydC0+bXJvdXRlX3NrKSkgewogCQkJSVBWNF9ERVZD
T05GX0FMTChuZXQsIE1DX0ZPUldBUkRJTkcpLS07CkBAIC0xMjg5LDcgKzEyODksNiBAQCBzdGF0
aWMgdm9pZCBtcnRzb2NrX2Rlc3RydWN0KHN0cnVjdCBzb2NrICpzaykKIAkJCW1yb3V0ZV9jbGVh
bl90YWJsZXMobXJ0LCBmYWxzZSk7CiAJCX0KIAl9Ci0JcnRubF91bmxvY2soKTsKIH0KIAogLyog
U29ja2V0IG9wdGlvbnMgYW5kIHZpcnR1YWwgaW50ZXJmYWNlIG1hbmlwdWxhdGlvbi4gVGhlIHdo
b2xlCkBAIC0xMzUzLDEzICsxMzUyLDggQEAgaW50IGlwX21yb3V0ZV9zZXRzb2Nrb3B0KHN0cnVj
dCBzb2NrICpzaywgaW50IG9wdG5hbWUsIGNoYXIgX191c2VyICpvcHR2YWwsCiAJCWlmIChzayAh
PSByY3VfYWNjZXNzX3BvaW50ZXIobXJ0LT5tcm91dGVfc2spKSB7CiAJCQlyZXQgPSAtRUFDQ0VT
OwogCQl9IGVsc2UgewotCQkJLyogV2UgbmVlZCB0byB1bmxvY2sgaGVyZSBiZWNhdXNlIG1ydHNv
Y2tfZGVzdHJ1Y3QgdGFrZXMKLQkJCSAqIGNhcmUgb2YgcnRubCBpdHNlbGYgYW5kIHdlIGNhbid0
IGNoYW5nZSB0aGF0IGR1ZSB0bwotCQkJICogdGhlIElQX1JPVVRFUl9BTEVSVCBzZXRzb2Nrb3B0
IHdoaWNoIHJ1bnMgd2l0aG91dCBpdC4KLQkJCSAqLwotCQkJcnRubF91bmxvY2soKTsKIAkJCXJl
dCA9IGlwX3JhX2NvbnRyb2woc2ssIDAsIE5VTEwpOwotCQkJZ290byBvdXQ7CisJCQlnb3RvIG91
dF91bmxvY2s7CiAJCX0KIAkJYnJlYWs7CiAJY2FzZSBNUlRfQUREX1ZJRjoKQEAgLTE0NzAsNyAr
MTQ2NCw2IEBAIGludCBpcF9tcm91dGVfc2V0c29ja29wdChzdHJ1Y3Qgc29jayAqc2ssIGludCBv
cHRuYW1lLCBjaGFyIF9fdXNlciAqb3B0dmFsLAogCX0KIG91dF91bmxvY2s6CiAJcnRubF91bmxv
Y2soKTsKLW91dDoKIAlyZXR1cm4gcmV0OwogfQogCmRpZmYgLS1naXQgYS9uZXQvaXB2NC9yYXcu
YyBiL25ldC9pcHY0L3Jhdy5jCmluZGV4IDgxMTllMWYuLjlkOTQzOTcgMTAwNjQ0Ci0tLSBhL25l
dC9pcHY0L3Jhdy5jCisrKyBiL25ldC9pcHY0L3Jhdy5jCkBAIC02ODIsNyArNjgyLDkgQEAgc3Rh
dGljIHZvaWQgcmF3X2Nsb3NlKHN0cnVjdCBzb2NrICpzaywgbG9uZyB0aW1lb3V0KQogCS8qCiAJ
ICogUmF3IHNvY2tldHMgbWF5IGhhdmUgZGlyZWN0IGtlcm5lbCByZWZlcmVuY2VzLiBLaWxsIHRo
ZW0uCiAJICovCisJcnRubF9sb2NrKCk7CiAJaXBfcmFfY29udHJvbChzaywgMCwgTlVMTCk7CisJ
cnRubF91bmxvY2soKTsKIAogCXNrX2NvbW1vbl9yZWxlYXNlKHNrKTsKIH0K
--001a114b09c004eba5054a0653d9--
