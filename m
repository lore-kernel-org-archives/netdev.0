From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 13 Jan 2005 16:27:17 -0600
Message-ID: <200501131627.20360.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501131328.34449.jeremy.guthrie@berbee.com> <16870.58414.767012.96364@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1629717.l7AYCjrpxA";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16870.58414.767012.96364@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1629717.l7AYCjrpxA
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 13 January 2005 03:12 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > I after a few revs I just bumped rhash_entries to 2.4mil in an attempt
>  > to get well above my actual usage.
>
>  A bit hefty size :-) But the stats are looking much better as we do much
>  less linear search (in_search) in hash and less fib lookups (tot)
Okay.

>  And you have now "dst cache overflows"?
No, I haven't gotten any of these yet.

>  Is the e1000 patch I sent in use?
yes.  I also have another E1000 driver I haven't had a chance to try yet.  =
It=20
is a bit more instrumented. =20

>  > You can see below I am over 600K entries before it blows them away and
>  > restarts.
>
>  This is a part of GC process to reclaim memory and reclaim unused dst
> entries. This
>
>  >  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     to=
t=20
>  >    mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
>  >
>  >
>  > 615852     86368     626     0     0     0     0     0         8      =
 0
>  > 0     624     622         0    0           56504         10
>  > 493558     47553    4603     0     0     0     0     0         2      =
 0
>  > 0    4166    4164         0    0           28346          0
>  > 10091     46526    7096     0     0     0     0     0         2       =
3=20
>  >     0 0       0         0    0             554          0
>  > 16238     80565    6145     0     0     0     0     0         6       =
3=20
>  >     0 0       0         0    0            1334          0
>
>  In short we reduce the hash size to remove unused flows and let it grow
> again. You see from (tot) that we have recreate may of the flows at this
> point. Most likely this is where we drop the packets. We have monitored
> small drops in our system when GC happens. The GC can be smoothen out but
> we leave that for now.
Sorry, not quite following.

IN:Hits are cache hits yes?  Tot, are the total number of flows created sin=
ce=20
we last looked at the total flow count, correct?  What would cause a packet=
=20
to drop in the network stack and thus showup in /proc/net/softnet_stat?

>  > How do I bump up the time from 10 minutes to something longer?
>
>  Davem pointed out another periodic task thats flushes the cache totally
> it's
>
>    /proc/sys/net/ipv4/route/secret_interval
>
>  It flushes the cache totally we so all current flows has be recreated. Y=
ou
>  probably drop packets here in your setup. Yes it can be idea to increase
> it or run the flush manually. But most routers drop packets now and then.
If I set the secret_interval to 60 seconds then I drop over 1% of all packe=
ts=20
coming through.  So GC isn't exactly my friend.

Performance has picked up.  I am not dropping packets anymore except during=
=20
GC.  I upped my interval from 600 seconds to 1800 seconds.  =20

Here are 15 second snapshots.  Line 3 appears to be when GC take effect. =20
Afterwards, everything stabilizes.  These numbers are much better.

Thu Jan 13 16:10:30 CST 2005 entries:  000de44a  Packets:  1255162  Errors:=
  0 =20
PPS:  83677  Percentage:  0.0%
Thu Jan 13 16:10:45 CST 2005 entries:  000df2ad  Packets:  1303050  Errors:=
 =20
3875  PPS:  86870  Percentage:  0.29%
Thu Jan 13 16:11:00 CST 2005 entries:  0000b053  Packets:  1265398  Errors:=
 =20
38586  PPS:  84359  Percentage:  3.04%
Thu Jan 13 16:11:15 CST 2005 entries:  00013df8  Packets:  1310618  Errors:=
  0 =20
PPS:  87374  Percentage:  0.0%
Thu Jan 13 16:11:30 CST 2005 entries:  0001b527  Packets:  1282435  Errors:=
  0 =20
PPS:  85495  Percentage:  0.0%
Thu Jan 13 16:11:45 CST 2005 entries:  000222bb  Packets:  1213217  Errors:=
  0 =20
PPS:  80881  Percentage:  0.0%
Thu Jan 13 16:12:01 CST 2005 entries:  00027c7e  Packets:  1279811  Errors:=
  0 =20
PPS:  85320  Percentage:  0.0%
Thu Jan 13 16:12:16 CST 2005 entries:  0002c5d5  Packets:  1224232  Errors:=
  0 =20
PPS:  81615  Percentage:  0.0%
Thu Jan 13 16:12:31 CST 2005 entries:  0003090c  Packets:  1243539  Errors:=
  0 =20
PPS:  82902  Percentage:  0.0%
Thu Jan 13 16:12:46 CST 2005 entries:  00034d41  Packets:  1267200  Errors:=
  0 =20
PPS:  84480  Percentage:  0.0%
Thu Jan 13 16:13:01 CST 2005 entries:  00038f82  Packets:  1238821  Errors:=
  0 =20
PPS:  82588  Percentage:  0.0%
Thu Jan 13 16:13:16 CST 2005 entries:  0003cf6a  Packets:  1245474  Errors:=
  0 =20
PPS:  83031  Percentage:  0.0%
Thu Jan 13 16:13:31 CST 2005 entries:  00040d23  Packets:  1266478  Errors:=
  0 =20
PPS:  84431  Percentage:  0.0%
Thu Jan 13 16:13:46 CST 2005 entries:  00044918  Packets:  1247576  Errors:=
  0 =20
PPS:  83171  Percentage:  0.0%
Thu Jan 13 16:14:01 CST 2005 entries:  00048520  Packets:  1223002  Errors:=
  0 =20
PPS:  81533  Percentage:  0.0%
Thu Jan 13 16:14:16 CST 2005 entries:  0004c0b6  Packets:  1303942  Errors:=
 =20
333  PPS:  86929  Percentage:  0.2%
Thu Jan 13 16:14:32 CST 2005 entries:  0004f83e  Packets:  1203334  Errors:=
  0 =20
PPS:  80222  Percentage:  0.0%
Thu Jan 13 16:14:47 CST 2005 entries:  00053241  Packets:  1216611  Errors:=
  0 =20
PPS:  81107  Percentage:  0.0%
Thu Jan 13 16:15:02 CST 2005 entries:  00056f97  Packets:  1281206  Errors:=
  0 =20
PPS:  85413  Percentage:  0.0%
Thu Jan 13 16:15:17 CST 2005 entries:  0005b020  Packets:  1270007  Errors:=
  0 =20
PPS:  84667  Percentage:  0.0%
Thu Jan 13 16:15:32 CST 2005 entries:  0005eb63  Packets:  1250099  Errors:=
  0 =20
PPS:  83339  Percentage:  0.0%
Thu Jan 13 16:15:47 CST 2005 entries:  00061e08  Packets:  1183444  Errors:=
  0 =20
PPS:  78896  Percentage:  0.0%
Thu Jan 13 16:16:02 CST 2005 entries:  0006489b  Packets:  1246170  Errors:=
 =20
3791  PPS:  83078  Percentage:  0.30%
Thu Jan 13 16:16:17 CST 2005 entries:  00066f1f  Packets:  1233601  Errors:=
 =20
4141  PPS:  82240  Percentage:  0.33%
Thu Jan 13 16:16:32 CST 2005 entries:  000695aa  Packets:  1273744  Errors:=
 =20
3798  PPS:  84916  Percentage:  0.29%
Thu Jan 13 16:16:47 CST 2005 entries:  0006ba5d  Packets:  1263619  Errors:=
 =20
4219  PPS:  84241  Percentage:  0.33%
Thu Jan 13 16:17:03 CST 2005 entries:  0006df19  Packets:  1240743  Errors:=
 =20
3616  PPS:  82716  Percentage:  0.29%

=2D---------one other snapshot------------
Thu Jan 13 16:09:03 CST 2005
eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          RX packets:459165122 errors:3427143 dropped:3427143 overruns:2045=
357=20
frame:0
1b5e031d 00000000 0000a829 00000000 00000000 00000000 00000000 00000000=20
0002cbd7
000072c1 00000000 00000001 00000000 00000000 00000000 00000000 00000000=20
00001e00
entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_sr=
c =20
out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss=20
gc_dst_overflow in_hlist_search out_hlist_search
000d92e0  1a0ecfdc 014e19f9 00000000 00000000 000000a6 000000df 00000000 =20
00009558 00000c5e 00000000 000b7605 000b6c68 00000000 00000000 07c9547f=20
0000398d
000d92e0  00001340 00005e40 00000000 00000000 0000005e 00000000 00000000 =20
00000007 00000036 00000002 00000002 00000002 00000000 00000000 00001542=20
00000004
           CPU0       CPU1
 18:  123586344       8007   IO-APIC-level  eth3
 20:          1   18109191   IO-APIC-level  eth2

Thu Jan 13 16:10:03 CST 2005
eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          RX packets:464242944 errors:3427143 dropped:3427143 overruns:2045=
357=20
frame:0
1bab839b 00000000 0000a82d 00000000 00000000 00000000 00000000 00000000=20
0002d2bc
000072e3 00000000 00000001 00000000 00000000 00000000 00000000 00000000=20
00001ed8
entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_sr=
c =20
out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss=20
gc_dst_overflow in_hlist_search out_hlist_search
000dcaba  1a5bd4fd 014e9288 00000000 00000000 000000a6 000000df 00000000 =20
00009678 00000c6a 00000000 000bee9e 000be489 00000000 00000000 08109f0f=20
00003a97
000dcaba  00001349 00005e58 00000000 00000000 0000005e 00000000 00000000 =20
00000007 00000036 00000002 00000002 00000002 00000000 00000000 00001597=20
00000004
           CPU0       CPU1
 18:  125388992       8007   IO-APIC-level  eth3
 20:          1   18340497   IO-APIC-level  eth2


=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1629717.l7AYCjrpxA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5vXIqtjaBHGZBeURAi0fAJ4yz6DtEQcQevDSEwON91O86jGFRwCggGrQ
Z8uaeS6S+YKyX2nfqm9cNYk=
=RLar
-----END PGP SIGNATURE-----

--nextPart1629717.l7AYCjrpxA--
