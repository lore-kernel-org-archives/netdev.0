From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv4: deadlock in ip_ra_control
Date: Wed, 12 Apr 2017 14:05:47 +0200
Message-ID: <CAAeHK+wYR=DnbotEu0nneEv2o8MZsStGV6MCZg_3Dy90cb0iJw@mail.gmail.com>
References: <CACT4Y+b-c=_QC51h0Qgp4buG=6cWO1xax7MrKgFS1BKV2=mdQg@mail.gmail.com>
 <CAM_iQpX=Vb-0xMjwOrriYcG38GT+U9zknggVbCb0_pBUh1NMkQ@mail.gmail.com>
 <CACT4Y+aWYLbu5Eq1WN_T6q_zDBUdP8wiAVJK1x1D_XspQSY-RQ@mail.gmail.com>
 <CACT4Y+b0uuE+YarvhfvWOanaoKxTsv92C5LC8btLOwEAG9Lr1w@mail.gmail.com> <CAM_iQpVf=Ky+hDFj2rt8VA3Jb1dv8oLgqovYWvHxj-k8KH3XSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f403045d2660670038054cf7079a
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVf=Ky+hDFj2rt8VA3Jb1dv8oLgqovYWvHxj-k8KH3XSA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--f403045d2660670038054cf7079a
Content-Type: text/plain; charset=UTF-8

On Mon, Mar 6, 2017 at 3:04 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Mar 3, 2017 at 10:43 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Thu, Mar 2, 2017 at 10:40 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> On Wed, Mar 1, 2017 at 6:18 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>> On Wed, Mar 1, 2017 at 2:44 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>>> Hello,
>>>>>
>>>>> I've got the following deadlock report while running syzkaller fuzzer
>>>>> on linux-next/51788aebe7cae79cb334ad50641347465fc188fd:
>>>>>
>>>>> ======================================================
>>>>> [ INFO: possible circular locking dependency detected ]
>>>>> 4.10.0-next-20170301+ #1 Not tainted
>>>>> -------------------------------------------------------
>>>>> syz-executor1/3394 is trying to acquire lock:
>>>>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>] lock_sock
>>>>> include/net/sock.h:1460 [inline]
>>>>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>]
>>>>> do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>>>>>
>>>>> but task is already holding lock:
>>>>>  (rtnl_mutex){+.+.+.}, at: [<ffffffff836fbd97>] rtnl_lock+0x17/0x20
>>>>> net/core/rtnetlink.c:70
>>>>>
>>>>> which lock already depends on the new lock.
>>>>>
>>>>>
>>>>> the existing dependency chain (in reverse order) is:
>>>>>
>>>>> -> #1 (rtnl_mutex){+.+.+.}:
>>>>>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>>>>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>>>>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>>>>>        __mutex_lock_common kernel/locking/mutex.c:754 [inline]
>>>>>        __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:891
>>>>>        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:906
>>>>>        rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
>>>>>        mrtsock_destruct+0x86/0x2c0 net/ipv4/ipmr.c:1281
>>>>>        ip_ra_control+0x459/0x600 net/ipv4/ip_sockglue.c:372
>>>>>        do_ip_setsockopt.isra.12+0x1064/0x3540 net/ipv4/ip_sockglue.c:1161
>>>>>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>>>>>        raw_setsockopt+0xb7/0xd0 net/ipv4/raw.c:839
>>>>>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>>>>>        SYSC_setsockopt net/socket.c:1786 [inline]
>>>>>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>>>>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>>>
>>>>> -> #0 (sk_lock-AF_INET){+.+.+.}:
>>>>>        check_prev_add kernel/locking/lockdep.c:1828 [inline]
>>>>>        check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1938
>>>>>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>>>>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>>>>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>>>>>        lock_sock_nested+0xcb/0x120 net/core/sock.c:2530
>>>>>        lock_sock include/net/sock.h:1460 [inline]
>>>>>        do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>>>>>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>>>>>        tcp_setsockopt+0x82/0xd0 net/ipv4/tcp.c:2721
>>>>>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>>>>>        SYSC_setsockopt net/socket.c:1786 [inline]
>>>>>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>>>>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>>>
>>>>
>>>> Please try the attached patch (compile only).
>>>
>>>
>>> Pushed the patch to the bots.
>>> Thanks
>>
>>
>> This patch triggers:
>
> Ah, update the patch to fix this.

Hi Cong,

I now have a reproducer for this bug (attached) and your patch fixes it.

Could you send it?

Thanks!

>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.

--f403045d2660670038054cf7079a
Content-Type: text/x-csrc; charset=US-ASCII; name="ipv4-ra-control-deadlock-poc.c"
Content-Disposition: attachment; filename="ipv4-ra-control-deadlock-poc.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j1exj1281

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCgojaWZuZGVmIF9fTlJfbW1hcAojZGVmaW5lIF9fTlJfbW1hcCA5CiNlbmRpZgoj
aWZuZGVmIF9fTlJfc29ja2V0CiNkZWZpbmUgX19OUl9zb2NrZXQgNDEKI2VuZGlmCiNpZm5kZWYg
X19OUl9zZXRzb2Nrb3B0CiNkZWZpbmUgX19OUl9zZXRzb2Nrb3B0IDU0CiNlbmRpZgoKI2RlZmlu
ZSBfR05VX1NPVVJDRQoKI2luY2x1ZGUgPHN5cy9pb2N0bC5oPgojaW5jbHVkZSA8c3lzL21tYW4u
aD4KI2luY2x1ZGUgPHN5cy9tb3VudC5oPgojaW5jbHVkZSA8c3lzL3ByY3RsLmg+CiNpbmNsdWRl
IDxzeXMvcmVzb3VyY2UuaD4KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1ZGUgPHN5cy9z
dGF0Lmg+CiNpbmNsdWRlIDxzeXMvc3lzY2FsbC5oPgojaW5jbHVkZSA8c3lzL3RpbWUuaD4KI2lu
Y2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lzL3dhaXQuaD4KCiNpbmNsdWRlIDxsaW51
eC9jYXBhYmlsaXR5Lmg+CiNpbmNsdWRlIDxsaW51eC9pZi5oPgojaW5jbHVkZSA8bGludXgvaWZf
dHVuLmg+CiNpbmNsdWRlIDxsaW51eC9rdm0uaD4KI2luY2x1ZGUgPGxpbnV4L3NjaGVkLmg+CiNp
bmNsdWRlIDxuZXQvaWZfYXJwLmg+CgojaW5jbHVkZSA8YXNzZXJ0Lmg+CiNpbmNsdWRlIDxkaXJl
bnQuaD4KI2luY2x1ZGUgPGVycm5vLmg+CiNpbmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8Z3Jw
Lmg+CiNpbmNsdWRlIDxwdGhyZWFkLmg+CiNpbmNsdWRlIDxzZXRqbXAuaD4KI2luY2x1ZGUgPHNp
Z25hbC5oPgojaW5jbHVkZSA8c3RkYXJnLmg+CiNpbmNsdWRlIDxzdGRib29sLmg+CiNpbmNsdWRl
IDxzdGRkZWYuaD4KI2luY2x1ZGUgPHN0ZGludC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1
ZGUgPHN0ZGxpYi5oPgojaW5jbHVkZSA8c3RyaW5nLmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KCmNv
bnN0IGludCBrRmFpbFN0YXR1cyA9IDY3Owpjb25zdCBpbnQga0Vycm9yU3RhdHVzID0gNjg7CmNv
bnN0IGludCBrUmV0cnlTdGF0dXMgPSA2OTsKCl9fYXR0cmlidXRlX18oKG5vcmV0dXJuKSkgdm9p
ZCBkb2V4aXQoaW50IHN0YXR1cykKewogIHZvbGF0aWxlIHVuc2lnbmVkIGk7CiAgc3lzY2FsbChf
X05SX2V4aXRfZ3JvdXAsIHN0YXR1cyk7CiAgZm9yIChpID0gMDs7IGkrKykgewogIH0KfQoKX19h
dHRyaWJ1dGVfXygobm9yZXR1cm4pKSB2b2lkIGZhaWwoY29uc3QgY2hhciogbXNnLCAuLi4pCnsK
ICBpbnQgZSA9IGVycm5vOwogIGZmbHVzaChzdGRvdXQpOwogIHZhX2xpc3QgYXJnczsKICB2YV9z
dGFydChhcmdzLCBtc2cpOwogIHZmcHJpbnRmKHN0ZGVyciwgbXNnLCBhcmdzKTsKICB2YV9lbmQo
YXJncyk7CiAgZnByaW50ZihzdGRlcnIsICIgKGVycm5vICVkKVxuIiwgZSk7CiAgZG9leGl0KChl
ID09IEVOT01FTSB8fCBlID09IEVBR0FJTikgPyBrUmV0cnlTdGF0dXMgOiBrRmFpbFN0YXR1cyk7
Cn0KCl9fYXR0cmlidXRlX18oKG5vcmV0dXJuKSkgdm9pZCBleGl0Zihjb25zdCBjaGFyKiBtc2cs
IC4uLikKewogIGludCBlID0gZXJybm87CiAgZmZsdXNoKHN0ZG91dCk7CiAgdmFfbGlzdCBhcmdz
OwogIHZhX3N0YXJ0KGFyZ3MsIG1zZyk7CiAgdmZwcmludGYoc3RkZXJyLCBtc2csIGFyZ3MpOwog
IHZhX2VuZChhcmdzKTsKICBmcHJpbnRmKHN0ZGVyciwgIiAoZXJybm8gJWQpXG4iLCBlKTsKICBk
b2V4aXQoa1JldHJ5U3RhdHVzKTsKfQoKc3RhdGljIGludCBmbGFnX2RlYnVnOwoKdm9pZCBkZWJ1
Zyhjb25zdCBjaGFyKiBtc2csIC4uLikKewogIGlmICghZmxhZ19kZWJ1ZykKICAgIHJldHVybjsK
ICB2YV9saXN0IGFyZ3M7CiAgdmFfc3RhcnQoYXJncywgbXNnKTsKICB2ZnByaW50ZihzdGRvdXQs
IG1zZywgYXJncyk7CiAgdmFfZW5kKGFyZ3MpOwogIGZmbHVzaChzdGRvdXQpOwp9CgpfX3RocmVh
ZCBpbnQgc2tpcF9zZWd2OwpfX3RocmVhZCBqbXBfYnVmIHNlZ3ZfZW52OwoKc3RhdGljIHZvaWQg
c2Vndl9oYW5kbGVyKGludCBzaWcsIHNpZ2luZm9fdCogaW5mbywgdm9pZCogdWN0eCkKewogIHVp
bnRwdHJfdCBhZGRyID0gKHVpbnRwdHJfdClpbmZvLT5zaV9hZGRyOwogIGNvbnN0IHVpbnRwdHJf
dCBwcm9nX3N0YXJ0ID0gMSA8PCAyMDsKICBjb25zdCB1aW50cHRyX3QgcHJvZ19lbmQgPSAxMDAg
PDwgMjA7CiAgaWYgKF9fYXRvbWljX2xvYWRfbigmc2tpcF9zZWd2LCBfX0FUT01JQ19SRUxBWEVE
KSAmJgogICAgICAoYWRkciA8IHByb2dfc3RhcnQgfHwgYWRkciA+IHByb2dfZW5kKSkgewogICAg
ZGVidWcoIlNJR1NFR1Ygb24gJXAsIHNraXBwaW5nXG4iLCBhZGRyKTsKICAgIF9sb25nam1wKHNl
Z3ZfZW52LCAxKTsKICB9CiAgZGVidWcoIlNJR1NFR1Ygb24gJXAsIGV4aXRpbmdcbiIsIGFkZHIp
OwogIGRvZXhpdChzaWcpOwogIGZvciAoOzspIHsKICB9Cn0KCnN0YXRpYyB2b2lkIGluc3RhbGxf
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
LCAxLCBfX0FUT01JQ19TRVFfQ1NUKTsgICAgICAgICAgICAgICBcCiAgfQoKI2RlZmluZSBCSVRN
QVNLX0xFTih0eXBlLCBiZl9sZW4pICh0eXBlKSgoMXVsbCA8PCAoYmZfbGVuKSkgLSAxKQoKI2Rl
ZmluZSBCSVRNQVNLX0xFTl9PRkYodHlwZSwgYmZfb2ZmLCBiZl9sZW4pICAgICAgICAgICAgICAg
ICAgICAgICAgICBcCiAgKHR5cGUpKEJJVE1BU0tfTEVOKHR5cGUsIChiZl9sZW4pKSA8PCAoYmZf
b2ZmKSkKCiNkZWZpbmUgU1RPUkVfQllfQklUTUFTSyh0eXBlLCBhZGRyLCB2YWwsIGJmX29mZiwg
YmZfbGVuKSAgICAgICAgICAgICAgXAogIGlmICgoYmZfb2ZmKSA9PSAwICYmIChiZl9sZW4pID09
IDApIHsgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwKICAgICoodHlwZSopKGFkZHIp
ID0gKHR5cGUpKHZhbCk7ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBcCiAg
fSBlbHNlIHsgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgXAogICAgdHlwZSBuZXdfdmFsID0gKih0eXBlKikoYWRkcik7ICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwKICAgIG5ld192YWwgJj0gfkJJVE1BU0tfTEVO
X09GRih0eXBlLCAoYmZfb2ZmKSwgKGJmX2xlbikpOyAgICAgICAgICAgICBcCiAgICBuZXdfdmFs
IHw9ICgodHlwZSkodmFsKSZCSVRNQVNLX0xFTih0eXBlLCAoYmZfbGVuKSkpIDw8IChiZl9vZmYp
OyAgXAogICAgKih0eXBlKikoYWRkcikgPSBuZXdfdmFsOyAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgIFwKICB9CgpzdGF0aWMgdWludHB0cl90IGV4ZWN1dGVfc3lzY2Fs
bChpbnQgbnIsIHVpbnRwdHJfdCBhMCwgdWludHB0cl90IGExLAogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICB1aW50cHRyX3QgYTIsIHVpbnRwdHJfdCBhMywKICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgdWludHB0cl90IGE0LCB1aW50cHRyX3QgYTUsCiAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgIHVpbnRwdHJfdCBhNiwgdWludHB0cl90IGE3LAogICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICB1aW50cHRyX3QgYTgpCnsKICBzd2l0Y2ggKG5yKSB7
CiAgZGVmYXVsdDoKICAgIHJldHVybiBzeXNjYWxsKG5yLCBhMCwgYTEsIGEyLCBhMywgYTQsIGE1
KTsKICB9Cn0KCnN0YXRpYyB2b2lkIHNldHVwX21haW5fcHJvY2VzcygpCnsKICBzdHJ1Y3Qgc2ln
YWN0aW9uIHNhOwogIG1lbXNldCgmc2EsIDAsIHNpemVvZihzYSkpOwogIHNhLnNhX2hhbmRsZXIg
PSBTSUdfSUdOOwogIHN5c2NhbGwoU1lTX3J0X3NpZ2FjdGlvbiwgMHgyMCwgJnNhLCBOVUxMLCA4
KTsKICBzeXNjYWxsKFNZU19ydF9zaWdhY3Rpb24sIDB4MjEsICZzYSwgTlVMTCwgOCk7CiAgaW5z
dGFsbF9zZWd2X2hhbmRsZXIoKTsKCiAgY2hhciB0bXBkaXJfdGVtcGxhdGVbXSA9ICIuL3N5emth
bGxlci5YWFhYWFgiOwogIGNoYXIqIHRtcGRpciA9IG1rZHRlbXAodG1wZGlyX3RlbXBsYXRlKTsK
ICBpZiAoIXRtcGRpcikKICAgIGZhaWwoImZhaWxlZCB0byBta2R0ZW1wIik7CiAgaWYgKGNobW9k
KHRtcGRpciwgMDc3NykpCiAgICBmYWlsKCJmYWlsZWQgdG8gY2htb2QiKTsKICBpZiAoY2hkaXIo
dG1wZGlyKSkKICAgIGZhaWwoImZhaWxlZCB0byBjaGRpciIpOwp9CgpzdGF0aWMgdm9pZCBsb29w
KCk7CgpzdGF0aWMgdm9pZCBzYW5kYm94X2NvbW1vbigpCnsKICBwcmN0bChQUl9TRVRfUERFQVRI
U0lHLCBTSUdLSUxMLCAwLCAwLCAwKTsKICBzZXRwZ3JwKCk7CiAgc2V0c2lkKCk7CgogIHN0cnVj
dCBybGltaXQgcmxpbTsKICBybGltLnJsaW1fY3VyID0gcmxpbS5ybGltX21heCA9IDEyOCA8PCAy
MDsKICBzZXRybGltaXQoUkxJTUlUX0FTLCAmcmxpbSk7CiAgcmxpbS5ybGltX2N1ciA9IHJsaW0u
cmxpbV9tYXggPSAxIDw8IDIwOwogIHNldHJsaW1pdChSTElNSVRfRlNJWkUsICZybGltKTsKICBy
bGltLnJsaW1fY3VyID0gcmxpbS5ybGltX21heCA9IDEgPDwgMjA7CiAgc2V0cmxpbWl0KFJMSU1J
VF9TVEFDSywgJnJsaW0pOwogIHJsaW0ucmxpbV9jdXIgPSBybGltLnJsaW1fbWF4ID0gMDsKICBz
ZXRybGltaXQoUkxJTUlUX0NPUkUsICZybGltKTsKCiAgdW5zaGFyZShDTE9ORV9ORVdOUyk7CiAg
dW5zaGFyZShDTE9ORV9ORVdJUEMpOwogIHVuc2hhcmUoQ0xPTkVfSU8pOwp9CgpzdGF0aWMgaW50
IGRvX3NhbmRib3hfbm9uZShpbnQgZXhlY3V0b3JfcGlkLCBib29sIGVuYWJsZV90dW4pCnsKICBp
bnQgcGlkID0gZm9yaygpOwogIGlmIChwaWQpCiAgICByZXR1cm4gcGlkOwoKICBzYW5kYm94X2Nv
bW1vbigpOwoKICBsb29wKCk7CiAgZG9leGl0KDEpOwp9Cgpsb25nIHJbMTBdOwp2b2lkIGxvb3Ao
KQp7CiAgbWVtc2V0KHIsIC0xLCBzaXplb2YocikpOwogIHJbMF0gPSBleGVjdXRlX3N5c2NhbGwo
X19OUl9tbWFwLCAweDIwMDAwMDAwdWwsIDB4NDAwMHVsLCAweDN1bCwKICAgICAgICAgICAgICAg
ICAgICAgICAgIDB4MzJ1bCwgMHhmZmZmZmZmZmZmZmZmZmZmdWwsIDB4MHVsLCAwLCAwLCAwKTsK
ICByWzFdID0gZXhlY3V0ZV9zeXNjYWxsKF9fTlJfc29ja2V0LCAweDJ1bCwgMHg4MDAwM3VsLCAw
eDJ1bCwgMCwgMCwgMCwKICAgICAgICAgICAgICAgICAgICAgICAgIDAsIDAsIDApOwogIE5PTkZB
SUxJTkcoKih1aW50MzJfdCopMHgyMGYwMTAwMCA9ICh1aW50MzJfdCkweDApOwogIHJbM10gPSBl
eGVjdXRlX3N5c2NhbGwoX19OUl9zZXRzb2Nrb3B0LCByWzFdLCAweDB1bCwgMHhjOHVsLAogICAg
ICAgICAgICAgICAgICAgICAgICAgMHgyMGYwMTAwMHVsLCAweDR1bCwgMCwgMCwgMCwgMCk7CiAg
Tk9ORkFJTElORygqKHVpbnQzMl90KikweDIwMDAxZmY0ID0gKHVpbnQzMl90KTB4YTIwOTAwMDAp
OwogIE5PTkZBSUxJTkcoKih1aW50MzJfdCopMHgyMDAwMWZmOCA9ICh1aW50MzJfdCkweDApOwog
IE5PTkZBSUxJTkcoKih1aW50MzJfdCopMHgyMDAwMWZmYyA9ICh1aW50MzJfdCkweDkpOwogIHJb
N10gPSBleGVjdXRlX3N5c2NhbGwoX19OUl9zZXRzb2Nrb3B0LCByWzFdLCAweDB1bCwgMHgyM3Vs
LAogICAgICAgICAgICAgICAgICAgICAgICAgMHgyMDAwMWZmNHVsLCAweGN1bCwgMCwgMCwgMCwg
MCk7CiAgTk9ORkFJTElORygqKHVpbnQzMl90KikweDIwMDAwMDAwID0gKHVpbnQzMl90KTB4MCk7
CiAgcls5XSA9IGV4ZWN1dGVfc3lzY2FsbChfX05SX3NldHNvY2tvcHQsIHJbMV0sIDB4MHVsLCAw
eDV1bCwKICAgICAgICAgICAgICAgICAgICAgICAgIDB4MjAwMDAwMDB1bCwgMHg0dWwsIDAsIDAs
IDAsIDApOwp9CmludCBtYWluKCkKewogIHNldHVwX21haW5fcHJvY2VzcygpOwogIGludCBwaWQg
PSBkb19zYW5kYm94X25vbmUoMCwgZmFsc2UpOwogIGludCBzdGF0dXMgPSAwOwogIHdoaWxlICh3
YWl0cGlkKHBpZCwgJnN0YXR1cywgX19XQUxMKSAhPSBwaWQpIHsKICB9CiAgcmV0dXJuIDA7Cn0K
--f403045d2660670038054cf7079a--
