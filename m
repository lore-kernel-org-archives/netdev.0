From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute2: use IFLA_TXQLEN when it is available
Date: Thu, 12 May 2011 06:40:55 +0200
Message-ID: <1305175255.20318.4.camel@edumazet-laptop>
References: <1305168451-14491-1-git-send-email-xiaosuo@gmail.com>
	 <1305170886.3232.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33800 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659Ab1ELElB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 00:41:01 -0400
Received: by wwa36 with SMTP id 36so1324244wwa.1
        for <netdev@vger.kernel.org>; Wed, 11 May 2011 21:40:59 -0700 (PDT)
In-Reply-To: <1305170886.3232.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 mai 2011 =C3=A0 05:28 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 12 mai 2011 =C3=A0 10:47 +0800, Changli Gao a =C3=A9crit :
> > Use IFLA_TXQLEN when it is available, to avoid additional system ca=
lls.
> >=20
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > ---
> >  ip/ipaddress.c |   12 ++++++++++--
> >  1 file changed, 10 insertions(+), 2 deletions(-)
> > diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> > index a1f78b9..59afafd 100644
> > --- a/ip/ipaddress.c
> > +++ b/ip/ipaddress.c
> > @@ -285,8 +285,16 @@ int print_linkinfo(const struct sockaddr_nl *w=
ho,
> >  	if (tb[IFLA_OPERSTATE])
> >  		print_operstate(fp, *(__u8 *)RTA_DATA(tb[IFLA_OPERSTATE]));
> >  	=09
> > -	if (filter.showqueue)
> > -		print_queuelen(fp, (char*)RTA_DATA(tb[IFLA_IFNAME]));
> > +	if (filter.showqueue) {
> > +		if (tb[IFLA_TXQLEN]) {
> > +			__u32 txqlen =3D *(__u32 *)RTA_DATA(tb[IFLA_TXQLEN]);
> > +
> > +			if (txqlen)
> > +				fprintf(fp, "qlen %u", txqlen);
> > +		} else {
> > +			print_queuelen(fp, (char*)RTA_DATA(tb[IFLA_IFNAME]));
> > +		}
> > +	}
> > =20
> >  	if (!filter.family || filter.family =3D=3D AF_PACKET) {
> >  		SPRINT_BUF(b1);
>=20
> Hmm, what iproute2 version do you use ???
>=20
> commit 62a5e0668e2920b7f09896abd884753255712a46
> Author: Eric Dumazet <dada1@cosmosbay.com>
> Date:   Fri Oct 23 06:25:53 2009 +0200
>=20
>     ip: Support IFLA_TXQLEN in ip link show command
>    =20
>     We currently use an expensive ioctl() to get device txqueuelen, w=
hile
>     rtnetlink gave it to us for free. This patch speeds up ip link op=
eration
>     when many devices are registered.
>=20
>=20


Apparently my patch was somehow lost

http://patchwork.ozlabs.org/patch/36762/

Strange thing is it's in my git tree.

Stephen, any idea of what happened ?

Thanks

commit 62a5e0668e2920b7f09896abd884753255712a46
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Fri Oct 23 06:25:53 2009 +0200

[PATCH iproute2] ip: Support IFLA_TXQLEN in ip link show command
   =20
We currently use an expensive ioctl() to get device txqueuelen, while
rtnetlink gave it to us for free. This patch speeds up ip link operatio=
n
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


