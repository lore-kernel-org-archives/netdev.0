From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re : Source address selection + multicast
Date: Fri, 10 Nov 2006 22:34:36 +0000 (GMT)
Message-ID: <20061110223437.25778.qmail@web26813.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from web26813.mail.ukl.yahoo.com ([217.146.177.75]:3249 "HELO
	web26813.mail.ukl.yahoo.com") by vger.kernel.org with SMTP
	id S1424455AbWKJWei convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 17:34:38 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Excuse me if I am bothering you again, but is there something so wrong
with what I point out, or is multicasting so boring, that it doesn't
even deserve an answer? :)

Please consider.

----- Message d'origine ----
> Preferred source address selection in the routing table ("src" field)
> currently does not work properly with multicast destination adresses:
> it leads packets to be routed through the wrong network device (see
> http://bugzilla.kernel.org/show_bug.cgi?id=3D7398).
>=20
> It seems to me that the main reason for this is compatibility with
> old multicast applications, and I can see no fundamental reason
> preventing the use of this two features together.
>=20
> Why not finding a way to let them coexist?
>=20
> What about a sysctl option, letting users who really want to disable
> the compatibility hack, and restore normal behavior? I am thinking
> about something like the patch below. Or does another simple way to
> do it come to your mind?
>=20
> What do you think about it?

diff -urNp linux-2.6.18/Documentation/filesystems/proc.txt linux-2.6.18=
/Documentation/filesystems/proc.txt
--- linux-2.6.18/Documentation/filesystems/proc.txt     2006-09-19 20:4=
2:06.000000000 -0700
+++ linux-2.6.18/Documentation/filesystems/proc.txt     2006-10-26 05:1=
3:15.000000000 -0700
@@ -1758,6 +1758,15 @@ max_delay, min_delay

 Delays for flushing the routing cache.

+mc_src_strict
+-------------
+
+There is a hack in the kernel router which provides compatibility for =
old
+multicast applications such as vic, vat and friends. Unfortunately, th=
is
+hack also breaks normal behavior of preferred source address selection
+(iproute2 "src" field) with multicast and limited broadcast. Enabling =
this
+option disables this hack and restores normal (strict) behavior.
+
 redirect_load, redirect_number
 ------------------------------

diff -urNp linux-2.6.18/include/linux/sysctl.h linux-2.6.18/include/lin=
ux/sysctl.h
--- linux-2.6.18/include/linux/sysctl.h 2006-09-19 20:42:06.000000000 -=
0700
+++ linux-2.6.18/include/linux/sysctl.h 2006-10-26 04:25:00.000000000 -=
0700
@@ -433,6 +433,7 @@ enum {
        NET_IPV4_ROUTE_MIN_ADVMSS=3D17,
        NET_IPV4_ROUTE_SECRET_INTERVAL=3D18,
        NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS=3D19,
+       NET_IPV4_ROUTE_MC_SRC_STRICT=3D20,
 };

 enum
diff -urNp linux-2.6.18/net/ipv4/route.c linux-2.6.18/net/ipv4/route.c
--- linux-2.6.18/net/ipv4/route.c       2006-09-19 20:42:06.000000000 -=
0700
+++ linux-2.6.18/net/ipv4/route.c       2006-10-26 05:11:00.000000000 -=
0700
@@ -132,6 +132,7 @@ static int ip_rt_mtu_expires                =3D 10 =
* 60=20
 static int ip_rt_min_pmtu              =3D 512 + 20 + 20;
 static int ip_rt_min_advmss            =3D 256;
 static int ip_rt_secret_interval       =3D 10 * 60 * HZ;
+static int ip_rt_mc_src_strict         =3D 0;
 static unsigned long rt_deadline;

 #define RTprint(a...)  printk(KERN_DEBUG a)
@@ -2416,7 +2417,7 @@ static int ip_route_output_slow(struct r
                      of another iface. --ANK
                 */

-               if (oldflp->oif =3D=3D 0
+               if (!ip_rt_mc_src_strict && oldflp->oif =3D=3D 0
                    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst =3D=
=3D 0xFFFFFFFF)) {
                        /* Special hack: user can direct multicasts
                           and limited broadcast via necessary interfac=
e
@@ -2431,6 +2432,12 @@ static int ip_route_output_slow(struct r
                           cannot know, that ttl is zero, so that packe=
t
                           will not leave this host and route is valid)=
=2E
                           Luckily, this hack is good workaround.
+
+                          Unfortunately, it also breaks normal behavio=
r of
+                          source address preference, so I added a sysc=
tl option
+                          to let the user disable this hack and restor=
e normal
+                          behavior. By default, the hack is still enab=
led (old
+                          compatibility behavior). -- PY
                         */

                        fl.oif =3D dev_out->ifindex;
@@ -3057,6 +3064,15 @@ ctl_table ipv4_route_table[] =3D {
                .proc_handler   =3D &proc_dointvec_jiffies,
                .strategy       =3D &sysctl_jiffies,
        },
+       {
+               .ctl_name       =3D NET_IPV4_ROUTE_MC_SRC_STRICT,
+               .procname       =3D "mc_src_strict",
+               .data           =3D &ip_rt_mc_src_strict,
+               .maxlen         =3D sizeof(int),
+               .mode           =3D 0644,
+               .proc_handler   =3D &ipv4_doint_and_flush,
+               .strategy       =3D &ipv4_doint_and_flush_strategy,
+       },
        { .ctl_name =3D 0 }
 };
 #endif

--=20
Pierre Ynard





=09

=09
	=09
_______________________________________________________________________=
____=20
D=E9couvrez une nouvelle fa=E7on d'obtenir des r=E9ponses =E0 toutes vo=
s questions !=20
Profitez des connaissances, des opinions et des exp=E9riences des inter=
nautes sur Yahoo! Questions/R=E9ponses=20
http://fr.answers.yahoo.com
