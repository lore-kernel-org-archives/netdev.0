From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/sctp: recursive locking in sctp_do_peeloff
Date: Wed, 15 Mar 2017 11:14:56 +0100
Message-ID: <CACT4Y+bCpT5V268gyVXYNmgMDAHy8fJZdTGL73ZG_ERfoaWh1w@mail.gmail.com>
References: <CACT4Y+ZHGC6VNJUANgSdZnCfLQrRKtsQ-Dbn6goHScj=pq7xog@mail.gmail.com>
 <CAFSqH7xrmH2Bgq3Xckgb3mkj7j1qkApemEYOq3jbQEtj+TTEpQ@mail.gmail.com>
 <CACT4Y+b1Uu9nGqX=LdJ_nEWxbeCswMOsSpvnW=OLdDKYC5EjDw@mail.gmail.com> <CAM_iQpUEWDVHx5+VBB4=r=y_vVbXq32a2QfqY=OU5ri-yyJPaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUEWDVHx5+VBB4=r=y_vVbXq32a2QfqY=OU5ri-yyJPaA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 15, 2017 at 5:52 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Mar 10, 2017 at 12:04 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Fri, Mar 10, 2017 at 8:46 PM, Marcelo Ricardo Leitner
>> <marcelo.leitner@gmail.com> wrote:
>>> On Fri, Mar 10, 2017 at 4:11 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>> Hello,
>>>>
>>>> I've got the following recursive locking report while running
>>>> syzkaller fuzzer on net-next/9c28286b1b4b9bce6e35dd4c8a1265f03802a89a:
>>>>
>>>> [ INFO: possible recursive locking detected ]
>>>> 4.10.0+ #14 Not tainted
>>>> ---------------------------------------------
>>>> syz-executor3/5560 is trying to acquire lock:
>>>>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff8401ebcd>] lock_sock
>>>> include/net/sock.h:1460 [inline]
>>>>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff8401ebcd>]
>>>> sctp_close+0xcd/0x9d0 net/sctp/socket.c:1497
>>>>
>>>> but task is already holding lock:
>>>>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff84038110>] lock_sock
>>>> include/net/sock.h:1460 [inline]
>>>>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff84038110>]
>>>> sctp_getsockopt+0x450/0x67e0 net/sctp/socket.c:6611
>>>>
>>>> other info that might help us debug this:
>>>>  Possible unsafe locking scenario:
>>>>
>>>>        CPU0
>>>>        ----
>>>>   lock(sk_lock-AF_INET6);
>>>>   lock(sk_lock-AF_INET6);
>>>>
>>>>  *** DEADLOCK ***
>>>>
>>>>  May be due to missing lock nesting notation
>>>
>>> Pretty much the case, I suppose. The lock held by sctp_getsockopt() is
>>> on one socket, while the other lock that sctp_close() is getting later
>>> is on the newly created (which failed) socket during peeloff
>>> operation.
>>
>>
>> Does this mean that never-ever lock 2 sockets at a time except for
>> this case? If so, it probably suggests that this case should not do it
>> either.
>>
>
> Yeah, actually for the error path we don't even need to lock sock
> since it is newly allocated and no one else could see it yet.
>
> Instead of checking for the status of the sock, I believe the following
> one-line fix should do the trick too. Can you give it a try?
>
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 0f378ea..4de62d4 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1494,7 +1494,7 @@ static void sctp_close(struct sock *sk, long timeout)
>
>         pr_debug("%s: sk:%p, timeout:%ld\n", __func__, sk, timeout);
>
> -       lock_sock(sk);
> +       lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
>         sk->sk_shutdown = SHUTDOWN_MASK;
>         sk->sk_state = SCTP_SS_CLOSING;


Hi  Cong,

I've applied the patch on bots. But so far it happened only once, so I
am not sure I will be able to give any conclusion.
