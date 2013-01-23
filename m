From: Li Yu <raise.sail@gmail.com>
Subject: Re: v3 for tcp friends?
Date: Wed, 23 Jan 2013 14:12:52 +0800
Message-ID: <50FF7F64.2060902@gmail.com>
References: <20120903.154833.1547153833820955116.davem@davemloft.net> <CAEkNxbGJ6OGy3HDSeToXO_cDt7azpRZvy_CbQH0_UJ_mCS2s3w@mail.gmail.com> <20120904.125841.2293649688957878987.davem@davemloft.net> <50FCEE64.80203@gmail.com> <50FCEEC5.9010404@gmail.com> <CA+WLrf8xuJ3UXK-tZQykuTPMXu67WsNKWNuNzBKk7MBAidW-CQ@mail.gmail.com> <CAEkNxbH0MAAU9oiwwrFTbMJP1yzfNdxD5NDdZOqGnvhTLvodoQ@mail.gmail.com> <50FF5592.60008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Bruce Curtis <brutus@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:43589 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3AWGNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 01:13:05 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so4447820pbc.4
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 22:13:04 -0800 (PST)
In-Reply-To: <50FF5592.60008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Oops, this hang is not since TCP friends patch!

sk_sndbuf_get() is broken by 32 bits integer overflow
because of so large value in net.ipv4.tcp_{rmem,wmem}.

but this hang also can be found in net-next.git
(3.8.0-rc3+), if we run below commands, then all new
TCP connections stop working!

# when TCP friends is disabled
sysctl -w net.ipv4.tcp_rmem=3D"4096 4294967296 4294967296" # 4GB
sysctl -w net.ipv4.tcp_wmem=3D"4096 4294967296 4294967296"

Thanks

Yu

=D3=DA 2013=C4=EA01=D4=C223=C8=D5 11:14, Li Yu =D0=B4=B5=C0:
> =D3=DA 2013=C4=EA01=D4=C223=C8=D5 05:08, Bruce Curtis =D0=B4=B5=C0:
>> Thanks, Li
>>
>> Started working on friends again, v4, more soon.
>>
>>
>=20
> :)
>=20
> I found another odd bug in TCP friends v3, the clients
> may hang at tcp_sendmsg() -> sk_stream_wait_memory() with or
> without my refcnt fix patch.
>=20
> Below shell script can reproduce this bug:
>=20
> #! /bin/sh -x
>=20
> sysctl -w net.ipv4.tcp_rmem=3D"4096 1073741824 1073741824"
> sysctl -w net.ipv4.tcp_wmem=3D"4096 1073741824 1073741824"
>=20
> sysctl -w net.ipv4.tcp_friends=3D1
>=20
> msg=3D64K
> buf=3D256M
>=20
> pkill -9 netserver
> netserver
> netperf -t TCP_STREAM -l 1 -- -m ${msg} -M ${msg} -s ${buf} -S ${buf}=
 -4
>=20
> sysctl -w net.ipv4.tcp_friends=3D0
> pkill -9 netserver
> netserver
> netperf -t TCP_STREAM -l 1 -- -m ${msg} -M ${msg} -s ${buf} -S ${buf}=
 -4
> ##################SCRIPT END###################
>=20
> netperf kernel stack is (by cat /proc/$netperf_pid/stack)
>=20
> [<ffffffff812ce939>] sk_stream_wait_memory+0x2d9/0x2f0
> [<ffffffff8131460c>] tcp_sendmsg+0xf6c/0x1240
> [<ffffffff8133c117>] inet_sendmsg+0xf7/0x110
> [<ffffffff812bedfd>] sock_sendmsg+0x7d/0xa0
> [<ffffffff812c0e4d>] sys_sendto+0x13d/0x190
> [<ffffffff8138a6c2>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff
>=20
> netserver kernel stack is :
>=20
> [<ffffffff812c46ae>] sk_wait_data+0x8e/0xe0
> [<ffffffff81315993>] tcp_recvmsg+0x5c3/0xbe0
> [<ffffffff8133aefd>] inet_recvmsg+0xed/0x110
> [<ffffffff812becf4>] sock_recvmsg+0x84/0xb0
> [<ffffffff812c0fae>] sys_recvfrom+0xee/0x170
> [<ffffffff8138a6c2>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff
>=20
> And, "netstat -tnp" give us below results:
>=20
> Active Internet connections (w/o servers)
> Proto Recv-Q Send-Q Local Address           Foreign Address
> State       PID/Program name
> tcp        0      0 127.0.0.1:35451         127.0.0.1:12865
> ESTABLISHED 2316/netperf
> tcp6       0      0 127.0.0.1:12865         127.0.0.1:35451
> ESTABLISHED 2317/netserver
>=20
> (It seems that netperf hangs on the control connection of benchmark)
>=20
> I also try to fix this ...
>=20
> Thanks
>=20
> Yu
>=20
>> On Mon, Jan 21, 2013 at 12:55 AM, Li Yu <raise.sail@gmail.com
>> <mailto:raise.sail@gmail.com>> wrote:
>>
>>      2013/1/21 Li Yu <raise.sail@gmail.com <mailto:raise.sail@gmail.=
com>>
>>
>>          =D3=DA 2013=C4=EA01=D4=C221=C8=D5 15:29, Li Yu =D0=B4=B5=C0=
:
>>
>>              =D3=DA 2012=C4=EA09=D4=C205=C8=D5 00:58, David Miller =D0=
=B4=B5=C0:
>>
>>                  From: Bruce Curtis <brutus@google.com
>>                  <mailto:brutus@google.com>>
>>                  Date: Tue, 4 Sep 2012 08:10:23 -0700
>>
>>                      Will do, issues addressed, I'll get the patch o=
ut
>>                      later today or
>>                      tomorrow at the latest.
>>
>>
>>                  Thanks a lot Bruce.
>>                  --
>>                  To unsubscribe from this list: send the line
>>                  "unsubscribe netdev" in
>>                  the body of a message to majordomo@vger.kernel.org
>>                  <mailto:majordomo@vger.kernel.org>
>>                  More majordomo info at
>>                  http://vger.kernel.org/__majordomo-info.html
>>                  <http://vger.kernel.org/majordomo-info.html>
>>
>>
>>
>>              Hi, Bruce,
>>
>>                    I tested the TCP friends, found a bug here:
>>
>>              [  106.541372] Pid: 1765, comm: client Not tainted
>>              3.7.0-rc1+ #25
>>              [  106.543121] Call Trace:
>>              [  106.543950]  [<ffffffff8133d212>]
>>              inet_sock_destruct+0x102/0x1f0
>>              [  106.545687]  [<ffffffff812c38ad>] __sk_free+0x1d/0x1=
10
>>              [  106.547209]  [<ffffffff812c3a1c>] sk_free+0x1c/0x20
>>              [  106.548611]  [<ffffffff8131680c>] tcp_close+0x6c/0x3=
f0
>>              [  106.549863]  [<ffffffff8133caea>] inet_release+0xda/=
0xf0
>>              [  106.551134]  [<ffffffff8133ca30>] ? inet_release+0x2=
0/0xf0
>>              [  106.552419]  [<ffffffff8137f3de>] ? mutex_unlock+0xe=
/0x10
>>              [  106.553658]  [<ffffffff812bf948>] sock_release+0x28/=
0xa0
>>              [  106.557366]  [<ffffffff812bfd69>] sock_close+0x29/0x=
30
>>              [  106.558831]  [<ffffffff81128972>] __fput+0x122/0x210
>>              [  106.560541]  [<ffffffff81128a6e>] ____fput+0xe/0x10
>>              [  106.562006]  [<ffffffff8105354e>] task_work_run+0x9e=
/0xd0
>>              [  106.563285]  [<ffffffff810027e1>] do_notify_resume+0=
x61/0x70
>>              [  106.564582]  [<ffffffff8138a908>] int_signal+0x12/0x=
17
>>
>>
>>                    I also backported and tested it on stable kernel
>>              3.7.3/RHEL6
>>              kernel, this bug still exists. It seem that client may =
close
>>              listening
>>              sockets, may we need to add one reference count for lis=
ten
>>              socket
>>              before send its address to peer?
>>
>>
>>          Sorry, I lost an important line of kernel log before above =
them:
>>
>>          [  106.539367] IPv4: Attempt to release TCP socket in state=
 10
>>          ffff880074abb5c0
>>
>>          BTW: state 10 =3D TCP_LISTEN
>>
>>
>>      It seem this patch works for me.
>>
>>      diff --git a/net/ipv4/inet_connection_sock.c
>>      b/net/ipv4/inet_connection_sock.c
>>      index 9641215..a625c02 100644
>>      --- a/net/ipv4/inet_connection_sock.c
>>      +++ b/net/ipv4/inet_connection_sock.c
>>      @@ -623,8 +623,11 @@ struct sock *inet_csk_clone(struct sock *s=
k,
>>      const struct request_sock *req,
>>                               sock_hold(newsk);
>>                               was =3D xchg(&req->friend->sk_friend, =
newsk);
>>                               /* If requester already connect()ed, m=
aybe
>>      sleeping */
>>      -                       if (was && !sock_flag(req->friend, SOCK=
_DEAD))
>>      -                               sk->sk_state_change(req->friend=
);
>>      +                       if (was) {
>>      +                               if (!sock_flag(req->friend, SOC=
K_DEAD))
>>      +
>>      sk->sk_state_change(req->friend);
>>      +                               sock_put(was);
>>      +                       }
>>                       }
>>                       newsk->sk_state =3D TCP_SYN_RECV;
>>      diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>>      index 5917485..7a63245 100644
>>      --- a/net/ipv4/tcp_output.c
>>      +++ b/net/ipv4/tcp_output.c
>>      @@ -2277,8 +2277,10 @@ struct sk_buff *tcp_make_synack(struct s=
ock
>>      *sk, struct dst_entry *dst,
>>               memset(&opts, 0, sizeof(opts));
>>               /* Only try to make friends if enabled */
>>      -       if (sysctl_tcp_friends)
>>      +       if (sysctl_tcp_friends) {
>>      +               sock_hold(sk);
>>                       skb->friend =3D sk;
>>      +       }
>>        #ifdef CONFIG_SYN_COOKIES
>>               if (unlikely(req->cookie_ts))
>>
>>
>>                    And, our TCP friends v4? :)
>>
>>                    Thanks
>>
>>              Yu
>>
>>
>>
>=20
