From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug handling devices with weird names
Date: Fri, 09 Jul 2010 18:14:00 +0200
Message-ID: <1278692040.2696.42.camel@edumazet-laptop>
References: <AANLkTinBvzfdiAldJkXfH_vOkCv_cK7hBhjmH1l2vHTd@mail.gmail.com>
	 <20100708102747.66d0ad78@s6510>
	 <AANLkTim3IpnHn8ZedpYAphlA1ZdhzizuJo-azmPtd-kd@mail.gmail.com>
	 <1278670779.2696.1.camel@edumazet-laptop>
	 <AANLkTinGqQm_HaQABTwQes2D60D3smU2WrD5qydBvoOb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: =?ISO-8859-1?Q?Mart=EDn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39266 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151Ab0GIQOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 12:14:04 -0400
Received: by wyf23 with SMTP id 23so1673248wyf.19
        for <netdev@vger.kernel.org>; Fri, 09 Jul 2010 09:14:03 -0700 (PDT)
In-Reply-To: <AANLkTinGqQm_HaQABTwQes2D60D3smU2WrD5qydBvoOb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 juillet 2010 =C3=A0 17:41 +0200, Mart=C3=ADn Ferrari a =C3=
=A9crit :
> Hi,
>=20
> On Fri, Jul 9, 2010 at 12:19, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> > Update user land tools ?
> >
> > No problem here :
> >
> > # ip link add name foo: type dummy
> > # ip link list foo:
> > 14: foo:: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
> >    link/ether e6:48:a9:57:d4:1f brd ff:ff:ff:ff:ff:ff
> > # ip link del foo:
> > # ip -V
> > ip utility, iproute2-ss100519
>=20
> I am using the exact same version (from Debian), and I can also
> reproduce it with fedora's iproute2-ss080725.
> The kernels are 2.6.35-rc4 and 2.6.27, respectively.. Maybe your
> version of iprout is patched as to not use ioctl?
>=20
>=20
>=20

Well

I use the git version of iproute2, this includes following patch.

Nothing very exciting, but this avoids this ioctl() as you guessed ;)

You cannot ask old binaries to handle foo: devices very well, since
this special char (:) had special meaning in old days.

commit 62a5e0668e2920b7f09896abd884753255712a46
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Fri Oct 23 06:25:53 2009 +0200

    ip: Support IFLA_TXQLEN in ip link show command
   =20
    We currently use an expensive ioctl() to get device txqueuelen, whi=
le
    rtnetlink gave it to us for free. This patch speeds up ip link oper=
ation
    when many devices are registered.

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 267ecb3..cadc1a3 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -131,26 +131,31 @@ static void print_operstate(FILE *f, __u8 state)
 		fprintf(f, "state %s ", oper_states[state]);
 }
=20
-static void print_queuelen(FILE *f, const char *name)
+static void print_queuelen(FILE *f, struct rtattr *tb[IFLA_MAX + 1])
 {
-	struct ifreq ifr;
-	int s;
-
-	s =3D socket(AF_INET, SOCK_STREAM, 0);
-	if (s < 0)
-		return;
-
-	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, name);
-	if (ioctl(s, SIOCGIFTXQLEN, &ifr) < 0) {
-		fprintf(f, "ioctl(SIOCGIFXQLEN) failed: %s\n", strerror(errno));
+	int qlen;
+
+	if (tb[IFLA_TXQLEN])
+		qlen =3D *(int *)RTA_DATA(tb[IFLA_TXQLEN]);
+	else {
+		struct ifreq ifr;
+		int s =3D socket(AF_INET, SOCK_STREAM, 0);
+
+		if (s < 0)
+			return;
+
+		memset(&ifr, 0, sizeof(ifr));
+		strcpy(ifr.ifr_name, (char *)RTA_DATA(tb[IFLA_IFNAME]));
+		if (ioctl(s, SIOCGIFTXQLEN, &ifr) < 0) {
+			fprintf(f, "ioctl(SIOCGIFXQLEN) failed: %s\n", strerror(errno));
+			close(s);
+			return;
+		}
 		close(s);
-		return;
+		qlen =3D ifr.ifr_qlen;
 	}
-	close(s);
-
-	if (ifr.ifr_qlen)
-		fprintf(f, "qlen %d", ifr.ifr_qlen);
+	if (qlen)
+		fprintf(f, "qlen %d", qlen);
 }
=20
 static void print_linktype(FILE *fp, struct rtattr *tb)
@@ -253,7 +258,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		print_operstate(fp, *(__u8 *)RTA_DATA(tb[IFLA_OPERSTATE]));
 	=09
 	if (filter.showqueue)
-		print_queuelen(fp, (char*)RTA_DATA(tb[IFLA_IFNAME]));
+		print_queuelen(fp, tb);
=20
 	if (!filter.family || filter.family =3D=3D AF_PACKET) {
 		SPRINT_BUF(b1);


