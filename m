From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16568] New: Regression and incompatibility
 with Windows SP2-SP3-Vista TCP stack causing lost connections
Date: Thu, 12 Aug 2010 17:09:33 +0200
Message-ID: <1281625773.2494.38.camel@edumazet-laptop>
References: <bug-16568-10286@https.bugzilla.kernel.org/>
	 <20100812074041.cf62b793.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, yuriy@ucoz.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61456 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664Ab0HLPJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 11:09:39 -0400
Received: by wyb32 with SMTP id 32so1495677wyb.19
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 08:09:37 -0700 (PDT)
In-Reply-To: <20100812074041.cf62b793.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 ao=C3=BBt 2010 =C3=A0 07:40 -0700, Andrew Morton a =C3=A9cr=
it :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
>=20
> On Thu, 12 Aug 2010 08:20:01 GMT bugzilla-daemon@bugzilla.kernel.org =
wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D16568
> >=20
> >            Summary: Regression and incompatibility with Windows
> >                     SP2-SP3-Vista TCP stack causing lost connection=
s
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 2.6.30+
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: yuriy@ucoz.com
> >         Regression: No
> >=20
> >=20
> > Hi.
> > I administer about 50 highly-loaded web servers (free CMS hosting) =
under linux.
> > Having on most of them kernel versions between 2.6.24 and 2.6.29 at=
 the
> > beginnig of the year, I made TCP sysctls tunings for increasing DDO=
S and
> > different flooding protection (our servers have attacks rather ofte=
n).
> > tcp_tw_recyle=3D1 was among of them, as many manuals in the net rec=
ommend to do
> > this and linux documentation does not say anything bad. Having peri=
odic kernel
> > panics connected with bugs in ethernet card drivers and ext3 and af=
ter founding
> > that 2.6.31+ kernels work faster with ext3, I upgraded almost all k=
ernels to
> > 2.6.32.8, which was already being tested on several servers for sev=
eral months.=20
> > Somewhen after that we began to receive complaints from our users (=
site owners)
> > that they (and their visitors) see very unstable work of their site=
s. It looked
> > like HTTP-connections were just lost in a random way. Not everybody=
 had the
> > problem, just a small percent. We tried to find problem with intern=
et providers
> > or buggy firewalls, but finally came to conclusion that problem is =
connected
> > with our servers. Analizing situations with lost connections using =
tcpdump i
> > found that client host send packets, BUT LINUX JUST IGNORES THEM, t=
here was
> > SYN-packet repeated 3 times with interval of 3 secs, but NO SYN-ACK=
 reply.
> > Most problems had users with Windows SP3 (i.e. almost all users wit=
h SP3 had
> > the problem). I booted one server with old 2.6.24 kernel and found =
that problem
> > dissappeared. Then began look for exact kernel version, that introd=
uced
> > incompatibility. Using binary search I compiled several kernels bet=
ween 2.6.24
> > and 2.6.32.8 and found that 2.6.29.6 DO NO have the problem, but 2.=
6.30 DOES.
> > Studing commits made to tcp_input.c and tcp_ipv4.c (which i suppose=
d were
> > involved) between that releases I found this one.
> >   author    Eric Dumazet <dada1@cosmosbay.com>   =20
> >     Wed, 11 Mar 2009 16:23:57 +0000 (09:23 -0700)
> >   committer    David S. Miller <davem@davemloft.net>   =20
> >     Wed, 11 Mar 2009 16:23:57 +0000 (09:23 -0700)
> >   commit    fc1ad92dfc4e363a055053746552cdb445ba5c57
> >=20
> >   tcp: allow timestamps even if SYN packet has tsval=3D0
> >=20
> >   Some systems send SYN packets with apparently wrong RFC1323 times=
tamp
> >   option values [timestamp tsval=3D0 tsecr=3D0].
> >   It might be for security reasons (http://www.secuobs.com/plugs/25=
220.shtml )
> >   Linux TCP stack ignores this option and sends back a SYN+ACK pack=
et
> >   without timestamp option, thus many TCP flows cannot use timestam=
ps
> >   and lose some benefit of RFC1323.
> >   Other operating systems seem to not care about initial tsval valu=
e, and let
> >   tcp flows to negotiate timestamp option.
> >=20
> >   net/ipv4/tcp_ipv4.c         diff :
> >=20
> > --- a/net/ipv4/tcp_ipv4.c
> > +++ b/net/ipv4/tcp_ipv4.c
> > @@ -1226,15 +1226,6 @@ int tcp_v4_conn_request(struct sock *sk, str=
uct sk_buff
> > *skb)
> >         if (want_cookie && !tmp_opt.saw_tstamp)
> >                 tcp_clear_options(&tmp_opt);
> >=20
> > -       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
> > -               /* Some OSes (unknown ones, but I see them on web s=
erver, which
> > -                * contains information interesting only for window=
s'
> > -                * users) do not send their stamp in SYN. It is eas=
y case.
> > -                * We simply do not advertise TS support.
> > -                */
> > -               tmp_opt.saw_tstamp =3D 0;
> > -               tmp_opt.tstamp_ok  =3D 0;
> > -       }
> >         tmp_opt.tstamp_ok =3D tmp_opt.saw_tstamp;
> >=20
> >         tcp_openreq_init(req, &tmp_opt, skb);
> >=20
> > Removing that was not very good. Having analized lost connections f=
rom SP3 I
> > know that they have timestamps turned on and timestamp value is 0. =
Here is it:
> > 13:39:10.430498 IP 192.168.99.130.3493 > 192.168.99.100.80: S
> > 2507911465:2507911465(0) win 65535 <mss 1460,nop,wscale 3,nop,nop,t=
imestamp 0
> > 0,nop,nop,sackOK>
> >         0x0000:  4500 0040 2bda 4000 8006 86a6 c0a8 6382  E..@+.@..=
=2E....c.
> >         0x0010:  c0a8 6364 0da5 0050 957b b129 0000 0000  ..cd...P.=
{.)....
> >         0x0020:  b002 ffff 992c 0000 0204 05b4 0103 0303  .....,...=
=2E......
> >         0x0030:  0101 080a 0000 0000 0000 0000 0101 0402  .........=
=2E......
> >=20
> > Having above code fragment removed we got tmp_opt.tstamp_ok=3D1, as=
 i understand.
> > But a little later in source code of tcp_ipv4.c read:
> >         /* VJ's idea. We save last timestamp seen
> >          * from the destination in peer table, when entering
> >          * state TIME-WAIT, and check against it before
> >          * accepting new connection request.
> >          *
> >          * If "isn" is not zero, this request hit alive
> >          * timewait bucket, so that all the necessary checks
> >          * are made in the function processing timewait state.
> >          */
> >         if (tmp_opt.saw_tstamp &&
> >             tcp_death_row.sysctl_tw_recycle &&
> >             (dst =3D inet_csk_route_req(sk, req)) !=3D NULL &&
> >             (peer =3D rt_get_peer((struct rtable *)dst)) !=3D NULL =
&&
> >             peer->v4daddr =3D=3D saddr) {
> >             if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_=
MSL &&
> >                 (s32)(peer->tcp_ts - req->ts_recent) >
> >                             TCP_PAWS_WINDOW) {
> >                 NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIV=
EREJECTED);
> >                 goto drop_and_release;
> >             }
> >         }
> > which in some way (tmp_opt.saw_tstamp && tcp_death_row.sysctl_tw_re=
cycle are
> > true), random way, having not closed time-wait sockets from the pea=
r, leads to
> > packet ignorence.
> >=20
> > As for me, i understand, that i should not enable tw_recycle, BUT D=
OCUMENTATION
> > DOES NOT STATE, that enabling it i'll got random and rather often l=
ost of
> > connections from some types of popular clients (like Windows).
> > Concerning above stated commit, it should include something to prev=
ent above
> > condition to become true if tmp_opt.rcv_tsval=3D=3D0. I'm not sure,=
 but something
> > like
> >         if (tmp_opt.saw_tstamp &&
> > +           tmp_opt.rcv_tsval &&
> >             tcp_death_row.sysctl_tw_recycle &&
> >             (dst =3D inet_csk_route_req(sk, req)) !=3D NULL &&
> >             (peer =3D rt_get_peer((struct rtable *)dst)) !=3D NULL =
&&
> >=20
> > just to not provide regression and strong TCP-stack incompatibility=
 in case
> > tw_recycle is enabled.
> > Also documentation does not state, that tw_recyle should not be use=
d at all for
> > internet servers, because web-clients, which are behind NAT, will h=
ave problems
> > connected with the same above condition because successive connecti=
ons from
> > different clients (which have common IP) could have incompatible ti=
mestamps.
> >=20
> > Sorry if i detracted somebody busy from his work with my unimportan=
t problem.
> >=20
>=20
> --

Hi Yuriy

Interesting analysis but wrong conclusions :)

Clients using RFC1323 (timestamps) and behind a NAT device will barf on
your setup. No matter they use Windows SP3 or other operating system.

Only because RFC1323 is more often enabled at client level (a registry
change on Windows XP, Vista or Seven I dont know), you start noticing
your server drops more connections than before.

Point is  :

Dont mess with tcp_tw_recycle=3D1, tcp_timestamps=3D1 on public machine=
s

Its a non working setup, for clients behind NAT devices (since their
TSVAL will probably lead to incorrect behavior on server, with infamous
LINUX_MIB_PAWSPASSIVEREJECTED status seen on netstat -s, as you
discovered.

And your patch solves nothing for this very common case, unless the NAT
device is able to overwrite TSVAL values with its own values (very
unlikely !!!)

A working setup is (and is the default) :

tcp_tw_recycle=3D0
tcp_timestamps=3D1


Documentation might be improved, but I feel whole "tcp_tw_recycle"
affair is really too tricky to be ever documented (not mentioning using
it ;) )



