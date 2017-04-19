From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Wed, 19 Apr 2017 03:09:01 +0200
Message-ID: <CAAeHK+y_GutDu+yQa74DFBrwnxmgGWOyMFyO4CTfFnD9V5bUBQ@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
 <CACT4Y+aDzAYs9mbNGeFEkYSB2wTwomZTGEKn4hDH0PAb4uiLqw@mail.gmail.com>
 <2b60b1b8-4766-0e36-f6fb-79914bf1925d@cumulusnetworks.com>
 <CACT4Y+YpUZ+7f5bzPh1hATwUXaZaPTu4rYYdz0RY1MHA1WG3SA@mail.gmail.com>
 <328b1fa7-2d97-6ae3-3b87-e33a0d564ad9@cumulusnetworks.com>
 <CACT4Y+aQFe+M=ESuShQ4FYNWAd8CNEQ=0rW+aAB0P-tp=PpFyQ@mail.gmail.com>
 <CACT4Y+aQgM=9QMkyfcXF2B5gGidvL07JP_m_inNXTPXU22i=aA@mail.gmail.com>
 <CACT4Y+Yx1cgWCkC2c7bze1V1VaecgBfioMvKS2-FUeaRr4DGXg@mail.gmail.com>
 <CACT4Y+bcMz13ad2kLaZGvct5sQ+RDki0StnOEbz3exAa8=zxqQ@mail.gmail.com>
 <CACT4Y+Z6f4aOxMZW44WXdYEyDJbGBYLnjKsHBXfK800h+EkrxA@mail.gmail.com>
 <2270c1ca-9481-60c1-9c29-87669223bded@cumulusnetworks.com>
 <CACT4Y+aUROZgAczRfntp5Rgvzcypviz5ZWBPdE6MWSiO0-3jEg@mail.gmail.com>
 <CAAeHK+zx6W_yxnoEQ2Pc1AT4uLXqYZaoi5oQBeuCntdGS38TQg@mail.gmail.com> <732d29dc-0240-cd1a-6973-5d14636ceaee@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <732d29dc-0240-cd1a-6973-5d14636ceaee@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2017 at 1:20 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 4/18/17 2:43 PM, Andrey Konovalov wrote:
>> I've finally managed to reproduce one of the crashes on commit
>> 4f7d029b9bf009fbee76bb10c0c4351a1870d2f3 (4.11-rc7).
>>
>> I'm not sure if this bug has the same root cause as the first one
>> reported in this thread, but it definitely has to do with ipv6
>> routing.
>>
>> C reproducer, syzkaller program and my .config are attached.

Just FYI, the reproducer uses interface number 9 inside a user
namespace, which is apparently ip6gre0.

1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
3: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/gre 0.0.0.0 brd 0.0.0.0
4: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN
mode DEFAULT qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
5: ip_vti0@NONE: <NOARP> mtu 1332 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
6: ip6_vti0@NONE: <NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/tunnel6 :: brd ::
7: sit0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/sit 0.0.0.0 brd 0.0.0.0
8: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/tunnel6 :: brd ::
9: ip6gre0@NONE: <NOARP> mtu 1448 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/[823] 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00 brd
00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00

>>
>> Thanks!
>>
>> kasan: CONFIG_KASAN_INLINE enabled
>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>> general protection fault: 0000 [#1] SMP KASAN
>> Modules linked in:
>> CPU: 1 PID: 4035 Comm: a.out Not tainted 4.11.0-rc7+ #250
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> task: ffff880069809600 task.stack: ffff880062dc8000
>> RIP: 0010:ip6_rt_cache_alloc+0xa6/0x560 net/ipv6/route.c:975
>
> From a quick glance seems to be a different bug than Dmitry's.

It might be.

>
