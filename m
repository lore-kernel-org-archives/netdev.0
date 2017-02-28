From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 16:49:45 +0100
Message-ID: <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: santosh.shilimkar@oracle.com, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170228153737.GG31155@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2017 at 4:37 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (02/28/17 15:22), Dmitry Vyukov wrote:
>>
>> Hello,
>>
>> I've got the following report while running syzkaller fuzzer on
>> linux-next/8d01c069486aca75b8f6018a759215b0ed0c91f0. So far it
>> happened only once. net was somehow deleted from underneath
>> inet_create. I've noticed that rds uses sock_create_kern which does
>> not take net reference. What is that that must keep net alive then?
>
> The rds_connection (which is where the net pointer is being obtained from)
> should keep the connection alive. Did you have the rds[_tcp] modules
> loaded at the time of failure? Were there kernel tcp sockets to/from
> the 16385 port? any hints on what else the test was doing (was it
> running a userspace RDS application that triggered the kernel TCP
> connection attempt in the first place)?


Here is syzkaller log before the crash:
https://gist.githubusercontent.com/dvyukov/8bb6a4c6543597c9598d5771258889fe/raw/08bd950bb69071a260046b0bcc5ab85701aea8e7/gistfile1.txt
Separate tests are separated by "executing program" lines. If a crash
happens within a user process context, it's possible to figure out
what exactly program triggered the bug. But this happened in a kernel
thread context, so I have no glues so far.

Grepping "socket" there, it was doing lots of things with sockets. Are
we looking for some particular socket type? If there are few programs
that create sockets of that type, then we can narrow down the set:

r1 = socket(0x11, 0x5, 0xa)
socket(0x4, 0xffffffffffffffff, 0x0)
socketpair(0x7, 0x805, 0x6,
&(0x7f0000fd0000-0x8)={<r0=>0xffffffffffffffff, 0xffffffffffffffff})
socketpair(0x2, 0x80a, 0x8001,
&(0x7f0000fd1000-0x8)={0xffffffffffffffff, <r1=>0xffffffffffffffff})
socket$alg(0x26, 0x5, 0x0)
socket$sctp6(0xa, 0x8000000001, 0x84)
r10 = socket(0x10, 0x802, 0x0)
socketpair(0x10, 0x0, 0x3,
&(0x7f0000e54000)={<r16=>0xffffffffffffffff, 0xffffffffffffffff})
socket(0x2002, 0x1, 0x7f)
r8 = socket$sctp6(0xa, 0x1, 0x84)
socket(0x0, 0xa, 0x0)
socket(0x0, 0x0, 0x1)
socketpair$unix(0x1, 0x1, 0x0,
&(0x7f0000995000-0x8)={<r14=>0xffffffffffffffff,
<r15=>0xffffffffffffffff})
r1 = socket(0x2, 0x2, 0x0)
r5 = socket$alg(0x26, 0x5, 0x0)
r6 = socket$kcm(0x29, 0x2, 0x0)
r7 = socket$netlink(0x10, 0x3, 0x0)
r10 = socket(0x10, 0x3, 0x0)
r1 = socket(0x4, 0xffffffffffffffff, 0x0)
r2 = socket(0xa, 0x6, 0x0)
r6 = socket(0x2, 0x5, 0x0)
r11 = socket(0xa, 0x2, 0x0)
r12 = socket(0xa, 0x2, 0x0)
socket(0x1, 0x80007, 0xfffffffffffffffd)
socketpair$sctp(0x2, 0x1, 0x84,
&(0x7f0000000000)={<r14=>0xffffffffffffffff,
<r15=>0xffffffffffffffff})
r16 = socket$bt_hci(0x1f, 0x3, 0x1)
r18 = socket(0x10000000a, 0x80001, 0x0)
socket$sctp6(0xa, 0x1, 0x84)
socket$alg(0x26, 0x5, 0x0)
socketpair$unix(0x1, 0x4000000000000003, 0x0,
&(0x7f0000fc1000-0x8)={0xffffffffffffffff, 0xffffffffffffffff})
socketpair$unix(0x1, 0x4000000000001, 0x0,
&(0x7f0000194000)={<r22=>0xffffffffffffffff,
<r23=>0xffffffffffffffff})
socket$bt_bnep(0x1f, 0x3, 0x4)
r0 = socket(0x10, 0x7, 0x8)
r2 = socket$alg(0x26, 0x5, 0x0)
r1 = socket$tcp(0x2, 0x1, 0x0)
r1 = socket(0x0, 0x2, 0x0)
r2 = socket$alg(0x26, 0x5, 0x0)
r4 = socket(0xa, 0x0, 0x40)
r8 = socket$bt_sco(0x1f, 0x5, 0x2)
socketpair$unix(0x1, 0x0, 0x0,
&(0x7f0000024000-0x8)={<r11=>0xffffffffffffffff, 0xffffffffffffffff})
socket$nfc_raw(0x27, 0x3, 0x0)
r15 = socket(0xb, 0x6, 0x0)
socketpair$unix(0x1, 0x5, 0x0,
&(0x7f000002f000-0x8)={0xffffffffffffffff, 0xffffffffffffffff})
r16 = socket(0x10, 0x802, 0x800000010)
socket$sctp6(0xa, 0x1, 0x84)
socket$alg(0x26, 0x5, 0x0)
r3 = socket(0xa, 0x1, 0x0)
r13 = socket(0x10, 0x802, 0x0)
r0 = socket$netlink(0x10, 0x3, 0x10)
socketpair(0x1, 0x80f, 0x7,
&(0x7f0000b67000)={<r0=>0xffffffffffffffff, 0xffffffffffffffff})
r2 = socket$alg(0x26, 0x5, 0x0)
socket$bt_hidp(0x1f, 0x3, 0x6)
socket$bt_bnep(0x1f, 0x3, 0x4)
socket$sctp(0x2, 0x1, 0x84)
r2 = socket(0x2, 0x3, 0x6)
r4 = socket(0x11, 0x802, 0x300)
r0 = socket$kcm(0x29, 0x5, 0x0)
r3 = socket$alg(0x26, 0x5, 0x0)
socketpair$unix(0x1, 0x5, 0x0,
&(0x7f0000510000)={<r8=>0xffffffffffffffff, <r9=>0xffffffffffffffff})
r1 = socket$alg(0x26, 0x5, 0x0)
r0 = socket$bt_cmtp(0x1f, 0x3, 0x5)
socket$unix(0x1, 0x80000000000200, 0x0)
socketpair$unix(0x1, 0x5, 0x0,
&(0x7f0000b30000)={<r6=>0xffffffffffffffff, <r7=>0xffffffffffffffff})
r0 = socket(0xa, 0x1, 0x0)
r7 = socket(0xa, 0x2, 0x41)
r5 = socket(0xa, 0x2, 0x88)
r4 = socket(0xa, 0x2, 0x88)
r0 = socket$icmp6_raw(0xa, 0x3, 0x3a)
r1 = socket(0xa, 0x5, 0x0)
socket$icmp6(0xa, 0x2, 0x3a)
socket$icmp6_raw(0xa, 0x3, 0x3a)
