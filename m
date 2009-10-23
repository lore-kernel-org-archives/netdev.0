From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ip: Support IFLA_TXQLEN in ip link command
Date: Fri, 23 Oct 2009 06:13:21 +0200
Message-ID: <4AE12D61.2040607@gmail.com>
References: <4AE068EB.70005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39789 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbZJWENU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 00:13:20 -0400
In-Reply-To: <4AE068EB.70005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> We currently use an expensive ioctl() to get device txqueuelen, while
> rtnetlink gave it to us for free. This patch speeds up ip link operat=
ion
> when many devices are registered.
>=20

Here is a 2nd version od this patch, not displaying "qlen 0" useless in=
fo

[PATCH iproute2] ip: Support IFLA_TXQLEN in ip link show command

We currently use an expensive ioctl() to get device txqueuelen, while
rtnetlink gave it to us for free. This patch speeds up ip link operatio=
n
when many devices are registered.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

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

