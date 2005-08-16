From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Route cache performance
Date: Tue, 16 Aug 2005 04:23:35 +0200
Message-ID: <43014E27.1070104@cosmosbay.com>
References: <20050815213855.GA17832@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050815213855.GA17832@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Simon Kirby a =E9crit :
> Hi!
>=20
> Well, after a few years of other work :), I have finally got around to
> setting up some more permanent forwarding / route cache performance
> test boxes.  I noticed the route trie option in the newer 2.6 kernels
> and figured it would be a good time to revisit things.
>=20
> Test setup:
>=20
> [Xeon w/e1000]---[Opteron w/dual e1000]---[Xeon w/e1000]
>=20
> The Xeons are 2.4 GHz boxes and the Opteron is a 140.  At some point
> I intend to compare the performance of a 32 bit versus 64 bit kernel.
>=20
> I'm only able to get pktgen to spit out about 660 kpps from the test 2.=
4
> Xeon box with onboard e1000 (pause disabled), but already I notice some
> disappointing results.  The old 2.4.27 kernel I last did tests with see=
ms
> to do a much better job of forwarding small packets (static src/dst) th=
an
> 2.4.31 and 2.6.12.
>=20
> On the (leftmost) sending box, 2.4.27, 2.4.31, and 2.6.12 all seem to d=
o
> fairly well at transmission with pktgen.  The 2.6 pktgen seems a little
> better (no transmission errors and a few more Mbps), so I've been using
> 2.6.12.  With fixed dst packets and pause disabled via ethtool, about
> 660 kpps is sent continuously.  juno (spoofed source, userspace) seems =
to
> do about 360 kpps.  The routes and packets are set up to route through
> the Opteron box to the receiving (rightmost) box.
>=20
> I've noticed that e1000 changes integrated in 2.6.11-bk2 are resulting =
in
> the forwarding test box slowing down enough that it seems to be exposin=
g
> "dst cache overflow", even though under slightly less load the gc seems
> to be able to keep up.  Robert, if I read correctly it seems that the
> e1000 NAPI changes were some fixes you submitted?
>=20
> Something appears to be different in the rtcache GC or perhaps NAPI or
> some other interaction, because firing juno at 2.4 does not show any
> problems while I can't seem to get 2.6.12 to _not_ print "dst cache
> overflow".  2.6.11 (pre-bk2) seems a little better at start, but any ki=
nd
> of burst seems to make the route cache entries exceed gc and then the
> slower hash lookups seem to make it get stuck at max_size (and printing
> "dst cache overflow") until the attack stops, even with gc_min_interval
> set to 0 (really 0).
>=20
> Anyway, I'm still in early testing stages here but it seems it's still =
as
> easy as ever to destroy routers (and hosts?) with a fairly small stream
> of small packets which create new rtcache entries.  These days, 184 Mbp=
s
> is starting to fall under the "small" DoS attack category, too.
>=20
> I notice the hash table size is still only 4096 buckets for 512 MB, whi=
ch
> isn't that wonderful when it hits a max_size of 65536 (w/512 MB)...
>=20
> Simon-
>=20
>=20

Hi Simon

I think one of the reason linux 2.6 has worst results is because HZ=3D100=
0 (instead of HZ=3D100 for linux 2.4)
So if rt_garbage_collect() has heavy work to do, it usually break out of =
the loop because of :

} while (!in_softirq() && time_before_eq(jiffies, now));

Could you please test latest 2.6.13-rc6 kernel on the Opteron machine, co=
mpiled with HZ=3D100, with the appended kernel argument :

rhash_entries=3D8191  ( or rhash_entries=3D16383 )

and

echo 1 >/proc/sys/net/ipv4/route/gc_interval
echo 2 >/proc/sys/net/ipv4/route/gc_elasticity

Could you also post some data from your router (like : rtstat -c 20 -i 1)

Eric
