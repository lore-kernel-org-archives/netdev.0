From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/sctp: recursive locking in sctp_do_peeloff
Date: Fri, 10 Mar 2017 21:04:27 +0100
Message-ID: <CACT4Y+b1Uu9nGqX=LdJ_nEWxbeCswMOsSpvnW=OLdDKYC5EjDw@mail.gmail.com>
References: <CACT4Y+ZHGC6VNJUANgSdZnCfLQrRKtsQ-Dbn6goHScj=pq7xog@mail.gmail.com>
 <CAFSqH7xrmH2Bgq3Xckgb3mkj7j1qkApemEYOq3jbQEtj+TTEpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFSqH7xrmH2Bgq3Xckgb3mkj7j1qkApemEYOq3jbQEtj+TTEpQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 10, 2017 at 8:46 PM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Fri, Mar 10, 2017 at 4:11 PM, Dmitry Vyukov <dvyukov@google.com> wrote=
:
>> Hello,
>>
>> I've got the following recursive locking report while running
>> syzkaller fuzzer on net-next/9c28286b1b4b9bce6e35dd4c8a1265f03802a89a:
>>
>> [ INFO: possible recursive locking detected ]
>> 4.10.0+ #14 Not tainted
>> ---------------------------------------------
>> syz-executor3/5560 is trying to acquire lock:
>>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff8401ebcd>] lock_sock
>> include/net/sock.h:1460 [inline]
>>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff8401ebcd>]
>> sctp_close+0xcd/0x9d0 net/sctp/socket.c:1497
>>
>> but task is already holding lock:
>>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff84038110>] lock_sock
>> include/net/sock.h:1460 [inline]
>>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff84038110>]
>> sctp_getsockopt+0x450/0x67e0 net/sctp/socket.c:6611
>>
>> other info that might help us debug this:
>>  Possible unsafe locking scenario:
>>
>>        CPU0
>>        ----
>>   lock(sk_lock-AF_INET6);
>>   lock(sk_lock-AF_INET6);
>>
>>  *** DEADLOCK ***
>>
>>  May be due to missing lock nesting notation
>
> Pretty much the case, I suppose. The lock held by sctp_getsockopt() is
> on one socket, while the other lock that sctp_close() is getting later
> is on the newly created (which failed) socket during peeloff
> operation.


Does this mean that never-ever lock 2 sockets at a time except for
this case? If so, it probably suggests that this case should not do it
either.


> I don=C2=B4t know how to fix this nesting notation in this situation, but
> any idea why sock_create failed? Seems security_socket_post_create()
> failed in there, so sock_release was called with sock->ops still
> valid.

No idea. The fuzzer frequently creates low memory conditions, but
there are no alloc failures messages in the log (maybe some allocation
used NOWARN?).
