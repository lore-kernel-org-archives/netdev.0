From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Wed, 09 Sep 2009 19:06:10 +0200
Message-ID: <4AA7E082.90807@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58953 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbZIIRGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 13:06:13 -0400
In-Reply-To: <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Wed, 9 Sep 2009, Eric Dumazet wrote:
>=20
>> Christoph Lameter a ?crit :
>>> On Wed, 9 Sep 2009, Eric Dumazet wrote:
>>>
>>>> In order to reproduce this here, could you tell me if you use
>>>>
>>>> Producer linux-2.6.22 -> Receiver 2.6.22
>>>> Producer linux-2.6.31 -> Receiver 2.6.31
>>> I use the above setup.
>> Then frames are sent on wire but not received
>>
>> (they are received via  mc loop, internal stack magic)
>=20
> We are talking about two machines running 2.6.22 or 2.6.31. There is =
no
> magic mc loop between the two machines. -L was not used.
>=20
>> # ./mcast -L -n1 -r 10000
>> WARNING: Multiple active ethernet devices. Using local address 192.1=
68.0.1
>> Receiver: Listening to control channel 239.0.192.1
>> Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0=
 origin 192.168.0.1
>> Sender: Sending 10000 msgs/ch/sec on 1 channels. Probe interval=3D0.=
001-1 sec.
>>
>> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/u=
s StdDv
>> 100000      0      0      0   10000  3000.0    7.84    8.89   10.51 =
 0.66
>=20
> These are loopback latencies... Dont use -L
>=20
>> # uname -a
>> Linux erd 2.6.30.5 #2 SMP Mon Sep 7 17:15:43 CEST 2009 i686 i686 i38=
6 GNU/Linux
>>
>>
>>
>> I tried an old kernel on same hardware :
>>
>> # ./mcast -L -n1 -r 10000
>> WARNING: Multiple active ethernet devices. Using local address 55.22=
5.18.6
>> Receiver: Listening to control channel 239.0.192.1
>> Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0=
 origin 55.225.18.6
>> Sender: Sending 10000 msgs/ch/sec on 1 channels. Probe interval=3D0.=
001-1 sec.
>>
>> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/u=
s StdDv
>>    99999      0      0      0    9998     0.0    9.00    9.95   14.5=
0  1.56
>>
>> Linux erd 2.6.9-55.ELsmp #1 SMP Fri Apr 20 17:03:35 EDT 2007 i686 i6=
86 i386 GNU/Linux
>>
>> So my numbers seem much better than yours...
>=20
> These are loopback numbers. Why is 2.6.9 so high? The regression show=
 at
> less than 10k.
>=20
> Could you use real NICs? With multiple TX queues and all the other co=
ol
> stuff? And run at lower packet rates?

well, on your mono-flow test, multiqueue wont help anyway.

>=20
> My loopback numbers also show the same trends.
>=20
> 2.6.22:
>=20
> mcast -Ln1
> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us=
 StdDv
>      101      0      0      0      10     3.0    5.47    5.74    7.00=
  0.43
>=20
> mcast -Ln1 -r10000
> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us=
 StdDv
>   100000      0      0      0   10000  3000.0    5.97    6.11    6.40=
 0.13
>=20
>=20
> 2.6.31-rc9
>=20
> mcast -Ln1
> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us=
 StdDv
>      100      0      0      0      10     3.0   13.26   13.45   13.56=
  0.09
>=20
> mcast -Ln1 -r10000
> TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us=
 StdDv
>   100000      0      0      0   10000  3000.0    5.70    5.82    5.91=
  0.07
>=20
>=20
> So 2.6.22 is better at 10 msgs per second. 2.6.31 is slightly better =
at
> 10k.

Unfortunatly there is too much noise on this test

# uname -a
Linux nag001 2.6.26-2-amd64 #1 SMP Fri Mar 27 04:02:59 UTC 2009 x86_64 =
GNU/Linux
# ./mcast -Ln1 -C
WARNING: Multiple active ethernet devices. Using local address 55.225.1=
8.110
Receiver: Listening to control channel 239.0.192.1
Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0 or=
igin 55.225.18.110
Sender: Sending 10 msgs/ch/sec on 1 channels. Probe interval=3D0.001-1 =
sec.

TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us S=
tdDv
     100      0      0      0      10     0.0    8.78   10.56   18.20  =
2.62
     100      0      0      0      10     3.0    8.60    9.33    9.88  =
0.45
     101      0      0      0      10     3.0    8.42    9.47   11.53  =
0.85
     100      0      0      0      10     3.0    8.37   10.19   14.85  =
1.74
     101      0      0      0      10     3.0    8.86   11.23   18.00  =
3.11
     100      0      0      0      10     3.0    8.43    9.72   11.48  =
0.82
     101      0      0      0      10     3.0    9.02   29.78  210.25 6=
0.16
     100      0      0      0      10     3.0    8.47   10.27   11.69  =
0.99
     100      0      0      0      10     3.0    9.21   10.16   12.15  =
0.84
     101      0      0      0      10     3.0    8.46   10.65   17.88  =
2.64
     101      0      0      0      10     3.0    8.65   10.00   11.32  =
0.86
     100      0      0      0      10     3.0    8.98    9.71   10.77  =
0.58
     100      0      0      0      10     3.0    8.38   11.73   19.06  =
3.74


Also I believe you hit scheduler artefact at very low rate,
since there are two tasks that are considered as coupled.

Check commit 6f3d09291b4982991680b61763b2541e53e2a95f

sched, net: socket wakeups are sync

'sync' wakeups are a hint towards the scheduler that (certain)
networking related wakeups likely create coupling between tasks.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/net/core/sock.c b/net/core/sock.c
index 09cb3a7..2654c14 100644 (file)
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1621,7 +1621,7 @@ static void sock_def_readable(struct sock *sk, in=
t len)
 {
        read_lock(&sk->sk_callback_lock);
        if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-               wake_up_interruptible(sk->sk_sleep);
+               wake_up_interruptible_sync(sk->sk_sleep);
        sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
        read_unlock(&sk->sk_callback_lock);
 }
@@ -1635,7 +1635,7 @@ static void sock_def_write_space(struct sock *sk)
         */
        if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D sk->sk_sndbuf) =
{
                if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-                       wake_up_interruptible(sk->sk_sleep);
+                       wake_up_interruptible_sync(sk->sk_sleep);
=20
                /* Should agree with poll, otherwise some programs brea=
k */
                if (sock_writeable(sk))

