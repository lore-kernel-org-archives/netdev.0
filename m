From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC]: not possible to do policy routing for next hop on
 tunnels.
Date: Wed, 01 Sep 2010 15:37:48 +0200
Message-ID: <1283348268.2556.326.camel@edumazet-laptop>
References: <1283343685.14066.24.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
	 <1283345350.2556.265.camel@edumazet-laptop>
	 <1283347660.14066.27.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Anders Franzen <Anders.Franzen@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37996 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744Ab0IANhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 09:37:54 -0400
Received: by wyb35 with SMTP id 35so9253678wyb.19
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 06:37:52 -0700 (PDT)
In-Reply-To: <1283347660.14066.27.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 septembre 2010 =C3=A0 15:27 +0200, Anders Franzen a =C3=A9=
crit :
>=20
> Quick answer!
>=20
> It seems do exactly what I want.
> Is there a corresponding 'fwmark inherit' parameter added to the ip
> command somewhere?
> Will this patch get it into the kernel?
>=20
> If you need testing I will do that.

=46ollowing iproute2 patch (against current git) should be applied.

I suggest we continue by private mails to polish patches ;)

Thanks

diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
index acb9ad6..bf22b03 100644
--- a/include/linux/ip6_tunnel.h
+++ b/include/linux/ip6_tunnel.h
@@ -16,6 +16,8 @@
 #define IP6_TNL_F_MIP6_DEV 0x8
 /* copy DSCP from the outer packet */
 #define IP6_TNL_F_RCV_DSCP_COPY 0x10
+/* copy fwmark from inner packet */
+#define IP6_TNL_F_USE_ORIG_FWMARK 0x20
=20
 struct ip6_tnl_parm {
 	char name[IFNAMSIZ];	/* name of tunnel device */
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 203e4a3..2c406e3 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -51,7 +51,7 @@ static void usage(void)
 	fprintf(stderr, "          [ remote ADDR local ADDR ] [ dev PHYS_DEV =
]\n");
 	fprintf(stderr, "          [ encaplimit ELIM ]\n");
 	fprintf(stderr ,"          [ hoplimit TTL ] [ tclass TCLASS ] [ flowl=
abel FLOWLABEL ]\n");
-	fprintf(stderr, "          [ dscp inherit ]\n");
+	fprintf(stderr, "          [ dscp inherit ] [ fwmark inherit] \n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME      :=3D STRING\n");
 	fprintf(stderr, "       ADDR      :=3D IPV6_ADDRESS\n");
@@ -103,6 +103,10 @@ static void print_tunnel(struct ip6_tnl_parm *p)
=20
 	if (p->flags & IP6_TNL_F_RCV_DSCP_COPY)
 		printf(" dscp inherit");
+
+	if (p->flags & IP6_TNL_F_USE_ORIG_FWMARK)
+		printf(" fwmark inherit");
+
 }
=20
 static int parse_args(int argc, char **argv, struct ip6_tnl_parm *p)
@@ -197,6 +201,11 @@ static int parse_args(int argc, char **argv, struc=
t ip6_tnl_parm *p)
 			if (strcmp(*argv, "inherit") !=3D 0)
 				invarg("not inherit", *argv);
 			p->flags |=3D IP6_TNL_F_RCV_DSCP_COPY;
+		} else if (strcmp(*argv, "fwmark") =3D=3D 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") !=3D 0)
+				invarg("not inherit", *argv);
+			p->flags |=3D IP6_TNL_F_USE_ORIG_FWMARK;
 		} else {
 			if (strcmp(*argv, "name") =3D=3D 0) {
 				NEXT_ARG();


