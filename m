From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sysfs warnings, reserved names
Date: Fri, 17 Feb 2012 12:03:51 +0100
Message-ID: <1329476631.2861.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <41230e67c273dde6b60cfc7110f496e2@visp.net.lb>
	 <1329475042.2861.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:56528 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061Ab2BQLDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 06:03:55 -0500
Received: by wics10 with SMTP id s10so1461874wic.19
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 03:03:54 -0800 (PST)
In-Reply-To: <1329475042.2861.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 11:37 +0100, Eric Dumazet a =C3=
=A9crit :
> Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 12:14 +0200, Denys Fedoryshch=
enko a
> =C3=A9crit :
> > Hi
> >=20
> > Just did a test:
> >=20
> > ip link set dev eth1 name default
> >=20
> > And got a lot of (expected) sysfs warnings:
> > [1068625.677143] sysctl table check failed:=20
> > /net/ipv4/conf/default/promote_secondaries  Sysctl already exists
> > [1068625.677151] Pid: 18106, comm: ip Not tainted 3.2.4-centaur #1
> > and etc
> >=20
> > Kernel 3.2.4, but i guess it doesn't matter much.
> > Maybe such names (as all and default) should be "reserved"?
> > Or it is ok like that?
> >=20
>=20
> You're right, we should forbid this to happen.
>=20
>=20

=46ollowing is a quick hack, I CC Eric because its probaly better to
address this in sysfs.


diff --git a/net/core/dev.c b/net/core/dev.c
index 763a0ed..ec68f89 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -856,7 +856,11 @@ int dev_valid_name(const char *name)
 		return 0;
 	if (!strcmp(name, ".") || !strcmp(name, ".."))
 		return 0;
-
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_INET)
+	/* /proc/sys/net/ipv{4|6}/conf/{default|all} are reserved */
+	if (!strcmp(name, "default") || !strcmp(name, "all"))
+		return 0;
+#endif
 	while (*name) {
 		if (*name =3D=3D '/' || isspace(*name))
 			return 0;
