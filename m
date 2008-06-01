From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sun, 01 Jun 2008 08:04:58 +0200
Message-ID: <48423C0A.1090104@cosmosbay.com>
References: <20080526115628.GA31316@elte.hu>	 <20080529084524.GA24892@elte.hu>	 <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi>	 <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu>	 <20080531060947.GA26441@elte.hu>	 <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi>	 <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi>	 <20080531125428.GA22111@elte.hu>	 <Pine.LNX.4.64.0805311555570.2329@wrl-59.cs.helsinki.fi>	 <20080531163501.GB22607@elte.hu> <1212273974.28319.107.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.49]:61477 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbYFAGFa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 02:05:30 -0400
In-Reply-To: <1212273974.28319.107.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McManus a =E9crit :
> On Sat, 2008-05-31 at 18:35 +0200, Ingo Molnar wrote:
>  =20
>> * Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:
>>
>>    =20
>
>  =20
>>> ...setsockopt(listenfd, SOL_TCP, TCP_DEFER_ACCEPT, &val, sizeof(val=
))=20
>>> seems to be the magic trick that is interestion here.
>>>      =20
>> seems to be used:
>>
>>  22003 write(3, "distccd[22003] (dcc_listen_by_ad"..., 62) =3D 62
>>  22003 listen(4, 10)                     =3D 0
>>  22003 setsockopt(4, SOL_TCP, TCP_DEFER_ACCEPT, [1], 4) =3D 0
>>
>> i'll queue up your reverts for testing in -tip.
>>    =20
>
>
> So the code you will revert came from my fingers. The circumstances h=
ere
> make me nervous; while I'm at a loss to explain what might be going o=
n
> in particular, let me offer an apology in advance should the revert h=
elp
> resolve the issue.
>
> Here's what makes me nervous:
>
>  * not a lot of code uses DEFER_ACCEPT.. frankly it was pretty broken
> before 26 - but not broken this way .. the correlation of your bug us=
ing
> it is significant.=20
>
>  * in 26, a server TCP socket (with DA) goes to ESTABLISHED when the =
3rd
> part of the handshake is received (as normal without DA), but the soc=
ket
> isn't put on the accept queue until a real data packet arrives. (That=
's
> the point of DA). In <=3D 25 this socket would have syn-recv until th=
e
> data packet arrived.
>
>   - I did run tests where the server died in between the handshake be=
ing
> completed and first data packet arriving - the client should see RST =
and
> the server socket should disappear. But maybe something was missed?
>
> Do I understand this correctly, the server process is gone but the
> socket is still in the table? And the client process is still there
> waiting for the server to do something - having sent a bunch of data?
>
> Do we know if any data bytes (not handshake bytes) have been consumed=
 by
> the server side? If they were, that would seem to vindicate DA.
>
> Also pointing away from DA is that you started seeing this with rc3 -
> that code was included in rc1.Is that a firm observation, or maybe th=
ere
> weren't enough datapoints to conclude that rc1 and rc2 were clean?
>
> The most interesting patch is ec3c0982a2dd1e671bad8e9d26c28dcba0039d8=
7
> if anyone wants to eyeball it.
>
>
>
>  =20

I believe Ingo problems come on long lived sockets (were many bytes wer=
e=20
exchanged between the peers), so I dont think DEFER_ACCEPT is the cullp=
rit.

I suggest to enable CONFIG_TIMER_STATS and to check timers, because=20
/proc/net/tcp
can display apparently large timer values when the timer is elapsed=20
(jiffies > icsk->icsk_timeout)
and jiffies_to_clock_t(timer_expires - jiffies) is then overflowing=20
doing a multiply and a divide.

On a 64bits server running linux-2.6.24-rc2, I can see *strange* timers=
=20
values too in /proc/net/tcp, but not
stuck TCP sessions. On 64 bits, these strange values have 1AD7F

grep 1AD7F /proc/net/tcp | obfuscate_IP_and_ports

2017: local_peer remote_peer 03 00000000:00000000 01:1AD7F29ABBA=20
00000001     0        0 0 2 ffff81067e7520c0
2019: local_peer remote_peer 03 00000000:00000000 01:1AD7F29ABBA=20
00000003     0        0 0 2 ffff8106c580bcc0
2029: local_peer remote_peer 03 00000000:00000000 01:1AD7F29ABBA=20
00000002     0        0 0 2 ffff81067313fe40
2032: local_peer remote_peer 03 00000000:00000000 01:1AD7F29ABBA=20
00000003     0        0 0 2 ffff8106c716c340
2039: local_peer remote_peer 03 00000000:00000000 01:1AD7F29ABBA=20
00000002     0        0 0 2 ffff8107d45b3f40
2041: local_peer remote_peer 03 00000000:00000000 01:1AD7F29AB37=20
00000000     0        0 0 2 ffff810718e221c0
6610: local_peer remote_peer 01 00000000:00000000 00:1AD7F29ABCA=20
00000000     0        0 136594789 1 ffff8107183fb940 94 10 16 2 -1
9925: local_peer remote_peer 01 00000000:00000000 00:1AD7F29ABCA=20
00000000     0        0 144451161 1 ffff8107051a9840 351 10 0 2 -1

On TCP_SYN_RECV (03) sockets, timer can apparently be elapsed by many=20
ticks, while on TCP_ESTABLISHED (01) one, I get
jiffies_to_clock(-1) -> 1AD7F29ABCA value because the way=20
get_tcp4_sock() is coded (jiffies can change while running this functio=
n).
Note the 00: that means that no timer in my case.

Running again the command one second later gives completely different=20
results (other sockets are displayed)

Maybe on 2.6.26-rc3+ we miss some timer correctness or we expose a=20
latent NET bug.

void sk_reset_timer(struct sock *sk, struct timer_list* timer,
                    unsigned long expires)
{
        if (!mod_timer(timer, expires))
                sock_hold(sk);
}


Note that arming a timer also increase socket refcount and could explai=
n=20
why Ingo have sockets
apparently not owned by a process but still referenced (by a timer or=20
many ones (I see refcnt=3D5) on following snapshots)

> sl  local_address rem_address   st tx_queue rx_queue tr tm->when retr=
nsmt
> uid  timeout inode
> 21: 111111AC:0016 480111AC:E4E9 01 00000B50:00000000 01:7D1F8746 0000=
0000
> 0        0 398713 5 f71a8580 205 40 1 36 -1
> 23: 111111AC:0016 480111AC:D359 01 000010F8:00000000 01:7D19A035 0000=
0000
> 0        0 396426 5 f71a8a80 202 42 1 144 -1
> 25: 111111AC:0016 480111AC:8565 01 00000B50:00000000 01:7CEBA7D1 0000=
0000
> 0        0 349113 5 eeeaf580 204 40 1 26 -1


Just my initial thoughts, sorry I currently cannot spend much time to=20
diagnose the problem.





