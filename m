From: Yuriy <yuriy@ucoz.com>
Subject: Re[2]: [Bugme-new] [Bug 16568] New: Regression and incompatibility with Windows SP2-SP3-Vista TCP stack causing lost connections
Date: Thu, 12 Aug 2010 19:46:07 +0300
Message-ID: <68743058.20100812194607@ucoz.com>
References: <bug-16568-10286@https.bugzilla.kernel.org/> <20100812074041.cf62b793.akpm@linux-foundation.org> <1281625773.2494.38.camel@edumazet-laptop>
Reply-To: Yuriy <yuriy@ucoz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	<bugzilla-daemon@bugzilla.kernel.org>,
	<bugme-daemon@bugzilla.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s6.ucoz.net ([217.199.217.6]:50444 "EHLO s6.ucoz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822Ab0HLRlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 13:41:04 -0400
In-Reply-To: <1281625773.2494.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric.

You wrote 12.08.2010, 18:09:33:

ED> Le jeudi 12 ao=C3=BBt 2010 =C3=A0 07:40 -0700, Andrew Morton a =C3=A9=
crit :
>> (switched to email.  Please respond via emailed reply-to-all, not vi=
a the
>> bugzilla web interface).


>> On Thu, 12 Aug 2010 08:20:01 GMT bugzilla-daemon@bugzilla.kernel.org=
 wrote:

>> > https://bugzilla.kernel.org/show_bug.cgi?id=3D16568
>> >=20
>> >            Summary: Regression and incompatibility with Windows
>> >                     SP2-SP3-Vista TCP stack causing lost connectio=
ns
>> >            Product: Networking
>> >            Version: 2.5
>> >     Kernel Version: 2.6.30+
>> >           Platform: All
>> >         OS/Version: Linux
>> >               Tree: Mainline
>> >             Status: NEW
>> >           Severity: high
>> >           Priority: P1
>> >          Component: IPV4
>> >         AssignedTo: shemminger@linux-foundation.org
>> >         ReportedBy: yuriy@ucoz.com
>> >         Regression: No
>> >=20
>> >=20
>> > Hi.
>> > I administer about 50 highly-loaded web servers (free CMS hosting)=
 under linux.
>> > Having on most of them kernel versions between 2.6.24 and 2.6.29 a=
t the
>> > beginnig of the year, I made TCP sysctls tunings for increasing DD=
OS and
>> > different flooding protection (our servers have attacks rather oft=
en).
>> > tcp_tw_recyle=3D1 was among of them, as many manuals in the net re=
commend to do
>> > this and linux documentation does not say anything bad. Having per=
iodic kernel
>> > panics connected with bugs in ethernet card drivers and ext3 and a=
fter founding
>> > that 2.6.31+ kernels work faster with ext3, I upgraded almost all =
kernels to
>> > 2.6.32.8, which was already being tested on several servers for se=
veral months.=20
>> > Somewhen after that we began to receive complaints from our users =
(site owners)
>> > that they (and their visitors) see very unstable work of their sit=
es. It looked
>> > like HTTP-connections were just lost in a random way. Not everybod=
y had the
>> > problem, just a small percent. We tried to find problem with inter=
net providers
>> > or buggy firewalls, but finally came to conclusion that problem is=
 connected
>> > with our servers. Analizing situations with lost connections using=
 tcpdump i
>> > found that client host send packets, BUT LINUX JUST IGNORES THEM, =
there was
>> > SYN-packet repeated 3 times with interval of 3 secs, but NO SYN-AC=
K reply.
>> > Most problems had users with Windows SP3 (i.e. almost all users wi=
th SP3 had
>> > the problem). I booted one server with old 2.6.24 kernel and found=
 that problem
>> > dissappeared. Then began look for exact kernel version, that intro=
duced
>> > incompatibility. Using binary search I compiled several kernels be=
tween 2.6.24
>> > and 2.6.32.8 and found that 2.6.29.6 DO NO have the problem, but 2=
=2E6.30 DOES.
>> > Studing commits made to tcp_input.c and tcp_ipv4.c (which i suppos=
ed were
>> > involved) between that releases I found this one.
>> >   author    Eric Dumazet <dada1@cosmosbay.com>   =20
>> >     Wed, 11 Mar 2009 16:23:57 +0000 (09:23 -0700)
>> >   committer    David S. Miller <davem@davemloft.net>   =20
>> >     Wed, 11 Mar 2009 16:23:57 +0000 (09:23 -0700)
>> >   commit    fc1ad92dfc4e363a055053746552cdb445ba5c57
>> >=20
>> >   tcp: allow timestamps even if SYN packet has tsval=3D0
>> >=20
>> >   Some systems send SYN packets with apparently wrong RFC1323 time=
stamp
>> >   option values [timestamp tsval=3D0 tsecr=3D0].
>> >   It might be for security reasons (http://www.secuobs.com/plugs/2=
5220.shtml )
>> >   Linux TCP stack ignores this option and sends back a SYN+ACK pac=
ket
>> >   without timestamp option, thus many TCP flows cannot use timesta=
mps
>> >   and lose some benefit of RFC1323.
>> >   Other operating systems seem to not care about initial tsval val=
ue, and let
>> >   tcp flows to negotiate timestamp option.
>> >=20
>> >   net/ipv4/tcp_ipv4.c         diff :
>> >=20
>> > --- a/net/ipv4/tcp_ipv4.c
>> > +++ b/net/ipv4/tcp_ipv4.c
>> > @@ -1226,15 +1226,6 @@ int tcp_v4_conn_request(struct sock *sk, st=
ruct sk_buff
>> > *skb)
>> >         if (want_cookie && !tmp_opt.saw_tstamp)
>> >                 tcp_clear_options(&tmp_opt);
>> >=20
>> > -       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
>> > -               /* Some OSes (unknown ones, but I see them on web =
server, which
>> > -                * contains information interesting only for windo=
ws'
>> > -                * users) do not send their stamp in SYN. It is ea=
sy case.
>> > -                * We simply do not advertise TS support.
>> > -                */
>> > -               tmp_opt.saw_tstamp =3D 0;
>> > -               tmp_opt.tstamp_ok  =3D 0;
>> > -       }
>> >         tmp_opt.tstamp_ok =3D tmp_opt.saw_tstamp;
>> >=20
>> >         tcp_openreq_init(req, &tmp_opt, skb);
>> >=20
>> > Removing that was not very good. Having analized lost connections =
from SP3 I
>> > know that they have timestamps turned on and timestamp value is 0.=
 Here is it:
>> > 13:39:10.430498 IP 192.168.99.130.3493 > 192.168.99.100.80: S
>> > 2507911465:2507911465(0) win 65535 <mss 1460,nop,wscale 3,nop,nop,=
timestamp 0
>> > 0,nop,nop,sackOK>
>> >         0x0000:  4500 0040 2bda 4000 8006 86a6 c0a8 6382  E..@+.@.=
=2E.....c.
>> >         0x0010:  c0a8 6364 0da5 0050 957b b129 0000 0000  ..cd...P=
=2E{.)....
>> >         0x0020:  b002 ffff 992c 0000 0204 05b4 0103 0303  .....,..=
=2E.......
>> >         0x0030:  0101 080a 0000 0000 0000 0000 0101 0402  ........=
=2E.......
>> >=20
>> > Having above code fragment removed we got tmp_opt.tstamp_ok=3D1, a=
s i understand.
>> > But a little later in source code of tcp_ipv4.c read:
>> >         /* VJ's idea. We save last timestamp seen
>> >          * from the destination in peer table, when entering
>> >          * state TIME-WAIT, and check against it before
>> >          * accepting new connection request.
>> >          *
>> >          * If "isn" is not zero, this request hit alive
>> >          * timewait bucket, so that all the necessary checks
>> >          * are made in the function processing timewait state.
>> >          */
>> >         if (tmp_opt.saw_tstamp &&
>> >             tcp_death_row.sysctl_tw_recycle &&
>> >             (dst =3D inet_csk_route_req(sk, req)) !=3D NULL &&
>> >             (peer =3D rt_get_peer((struct rtable *)dst)) !=3D NULL=
 &&
>> >             peer->v4daddr =3D=3D saddr) {
>> >             if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS=
_MSL &&
>> >                 (s32)(peer->tcp_ts - req->ts_recent) >
>> >                             TCP_PAWS_WINDOW) {
>> >                 NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSI=
VEREJECTED);
>> >                 goto drop_and_release;
>> >             }
>> >         }
>> > which in some way (tmp_opt.saw_tstamp && tcp_death_row.sysctl_tw_r=
ecycle are
>> > true), random way, having not closed time-wait sockets from the pe=
ar, leads to
>> > packet ignorence.
>> >=20
>> > As for me, i understand, that i should not enable tw_recycle, BUT =
DOCUMENTATION
>> > DOES NOT STATE, that enabling it i'll got random and rather often =
lost of
>> > connections from some types of popular clients (like Windows).
>> > Concerning above stated commit, it should include something to pre=
vent above
>> > condition to become true if tmp_opt.rcv_tsval=3D=3D0. I'm not sure=
, but something
>> > like
>> >         if (tmp_opt.saw_tstamp &&
>> > +           tmp_opt.rcv_tsval &&
>> >             tcp_death_row.sysctl_tw_recycle &&
>> >             (dst =3D inet_csk_route_req(sk, req)) !=3D NULL &&
>> >             (peer =3D rt_get_peer((struct rtable *)dst)) !=3D NULL=
 &&
>> >=20
>> > just to not provide regression and strong TCP-stack incompatibilit=
y in case
>> > tw_recycle is enabled.
>> > Also documentation does not state, that tw_recyle should not be us=
ed at all for
>> > internet servers, because web-clients, which are behind NAT, will =
have problems
>> > connected with the same above condition because successive connect=
ions from
>> > different clients (which have common IP) could have incompatible t=
imestamps.
>> >=20
>> > Sorry if i detracted somebody busy from his work with my unimporta=
nt problem.
>> >=20

>> --

ED> Hi Yuriy

ED> Interesting analysis but wrong conclusions :)

ED> Clients using RFC1323 (timestamps) and behind a NAT device will bar=
f on
ED> your setup. No matter they use Windows SP3 or other operating syste=
m.

ED> Only because RFC1323 is more often enabled at client level (a regis=
try
ED> change on Windows XP, Vista or Seven I dont know), you start notici=
ng
ED> your server drops more connections than before.

ED> Point is  :

ED> Dont mess with tcp_tw_recycle=3D1, tcp_timestamps=3D1 on public mac=
hines

ED> Its a non working setup, for clients behind NAT devices (since thei=
r
ED> TSVAL will probably lead to incorrect behavior on server, with infa=
mous
ED> LINUX_MIB_PAWSPASSIVEREJECTED status seen on netstat -s, as you
ED> discovered.

ED> And your patch solves nothing for this very common case, unless the=
 NAT
ED> device is able to overwrite TSVAL values with its own values (very
ED> unlikely !!!)

ED> A working setup is (and is the default) :

ED> tcp_tw_recycle=3D0
ED> tcp_timestamps=3D1


ED> Documentation might be improved, but I feel whole "tcp_tw_recycle"
ED> affair is really too tricky to be ever documented (not mentioning u=
sing
ED> it ;) )


Thanks for reply.

Main idea that i wanted to say is just to document this feature appropr=
iately as internet is full of recommendations to enable it.=20
Just few words like "do not used it on public servers" would be much be=
tter than now.




--=20
Regards,
 Yuriy                          mailto:yuriy@ucoz.com

