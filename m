From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv4: deadlock in ip_ra_control
Date: Wed, 1 Mar 2017 09:18:49 -0800
Message-ID: <CAM_iQpX=Vb-0xMjwOrriYcG38GT+U9zknggVbCb0_pBUh1NMkQ@mail.gmail.com>
References: <CACT4Y+b-c=_QC51h0Qgp4buG=6cWO1xax7MrKgFS1BKV2=mdQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f40304385c1ce0c5020549ae82bc
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
In-Reply-To: <CACT4Y+b-c=_QC51h0Qgp4buG=6cWO1xax7MrKgFS1BKV2=mdQg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--f40304385c1ce0c5020549ae82bc
Content-Type: text/plain; charset=UTF-8

On Wed, Mar 1, 2017 at 2:44 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Hello,
>
> I've got the following deadlock report while running syzkaller fuzzer
> on linux-next/51788aebe7cae79cb334ad50641347465fc188fd:
>
> ======================================================
> [ INFO: possible circular locking dependency detected ]
> 4.10.0-next-20170301+ #1 Not tainted
> -------------------------------------------------------
> syz-executor1/3394 is trying to acquire lock:
>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>] lock_sock
> include/net/sock.h:1460 [inline]
>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>]
> do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>
> but task is already holding lock:
>  (rtnl_mutex){+.+.+.}, at: [<ffffffff836fbd97>] rtnl_lock+0x17/0x20
> net/core/rtnetlink.c:70
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> -> #1 (rtnl_mutex){+.+.+.}:
>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>        __mutex_lock_common kernel/locking/mutex.c:754 [inline]
>        __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:891
>        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:906
>        rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
>        mrtsock_destruct+0x86/0x2c0 net/ipv4/ipmr.c:1281
>        ip_ra_control+0x459/0x600 net/ipv4/ip_sockglue.c:372
>        do_ip_setsockopt.isra.12+0x1064/0x3540 net/ipv4/ip_sockglue.c:1161
>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>        raw_setsockopt+0xb7/0xd0 net/ipv4/raw.c:839
>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>        SYSC_setsockopt net/socket.c:1786 [inline]
>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>
> -> #0 (sk_lock-AF_INET){+.+.+.}:
>        check_prev_add kernel/locking/lockdep.c:1828 [inline]
>        check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1938
>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>        lock_sock_nested+0xcb/0x120 net/core/sock.c:2530
>        lock_sock include/net/sock.h:1460 [inline]
>        do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>        tcp_setsockopt+0x82/0xd0 net/ipv4/tcp.c:2721
>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>        SYSC_setsockopt net/socket.c:1786 [inline]
>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>

Please try the attached patch (compile only).

Thanks.

--f40304385c1ce0c5020549ae82bc
Content-Type: text/plain; charset=US-ASCII; name="ip-router-alert.diff"
Content-Disposition: attachment; filename="ip-router-alert.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_izr87r230

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMgYi9uZXQvaXB2NC9pcF9zb2NrZ2x1
ZS5jCmluZGV4IGViZDk1M2IuLmJkYTMxOGEgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L2lwX3NvY2tn
bHVlLmMKKysrIGIvbmV0L2lwdjQvaXBfc29ja2dsdWUuYwpAQCAtNTkxLDYgKzU5MSw3IEBAIHN0
YXRpYyBib29sIHNldHNvY2tvcHRfbmVlZHNfcnRubChpbnQgb3B0bmFtZSkKIAljYXNlIE1DQVNU
X0xFQVZFX0dST1VQOgogCWNhc2UgTUNBU1RfTEVBVkVfU09VUkNFX0dST1VQOgogCWNhc2UgTUNB
U1RfVU5CTE9DS19TT1VSQ0U6CisJY2FzZSBJUF9ST1VURVJfQUxFUlQ6CiAJCXJldHVybiB0cnVl
OwogCX0KIAlyZXR1cm4gZmFsc2U7CmRpZmYgLS1naXQgYS9uZXQvaXB2NC9pcG1yLmMgYi9uZXQv
aXB2NC9pcG1yLmMKaW5kZXggYmVhY2QwMi4uOTMyMzIxYiAxMDA2NDQKLS0tIGEvbmV0L2lwdjQv
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
Y2soKTsKLW91dDoKIAlyZXR1cm4gcmV0OwogfQogCg==
--f40304385c1ce0c5020549ae82bc--
