From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.4] 2/2:  Fix NAT helper locking
Date: Fri, 3 Sep 2004 09:04:55 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040903070455.GS26263@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qgEfXXHyyarqcYJd"
Cc: netdev@oss.sgi.com,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--qgEfXXHyyarqcYJd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

This is the second of a two part patch.

This part fixes the locking in NAT helpers.

Please apply, Thanks.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/08 12:49:20+02:00 kaber@coreworks.de=20
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#  =20
#   There is a possible deadlock condition with conntrack/nat-helpers:
#  =20
#   CPU1:
#   conntrack-helper:help: lock(private_lock)
#   ip_conntrack_expect_related: write_lock(ip_conntrack_lock)
#  =20
#   CPU2:
#   nat-core:do_bindings: read_lock(ip_conntrack_lock)
#   nat-helper:help: lock(private_lock)
#  =20
#   The lock in the nat-helper is unneccessary because the expectation
#   is never changed and is protected by ip_conntrack_lock.
#  =20
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#   Signed-off-by: Harald Welte <laforge@netfilter.org>
#=20
# net/ipv4/netfilter/ip_nat_irc.c
#   2004/08/08 12:49:15+02:00 kaber@coreworks.de +1 -17
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# net/ipv4/netfilter/ip_nat_ftp.c
#   2004/08/08 12:49:15+02:00 kaber@coreworks.de +1 -19
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# net/ipv4/netfilter/ip_conntrack_irc.c
#   2004/08/08 12:49:15+02:00 kaber@coreworks.de +0 -8
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# net/ipv4/netfilter/ip_conntrack_ftp.c
#   2004/08/08 12:49:15+02:00 kaber@coreworks.de +3 -6
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# include/linux/netfilter_ipv4/ip_conntrack_irc.h
#   2004/08/08 12:49:15+02:00 kaber@coreworks.de +0 -5
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# include/linux/netfilter_ipv4/ip_conntrack_ftp.h
#   2004/08/08 12:49:15+02:00 kaber@coreworks.de +0 -5
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
diff -Nru a/include/linux/netfilter_ipv4/ip_conntrack_ftp.h b/include/linux=
/netfilter_ipv4/ip_conntrack_ftp.h
--- a/include/linux/netfilter_ipv4/ip_conntrack_ftp.h	2004-08-08 12:49:45 +=
02:00
+++ b/include/linux/netfilter_ipv4/ip_conntrack_ftp.h	2004-08-08 12:49:45 +=
02:00
@@ -4,11 +4,6 @@
=20
 #ifdef __KERNEL__
=20
-#include <linux/netfilter_ipv4/lockhelp.h>
-
-/* Protects ftp part of conntracks */
-DECLARE_LOCK_EXTERN(ip_ftp_lock);
-
 #define FTP_PORT	21
=20
 #endif /* __KERNEL__ */
diff -Nru a/include/linux/netfilter_ipv4/ip_conntrack_irc.h b/include/linux=
/netfilter_ipv4/ip_conntrack_irc.h
--- a/include/linux/netfilter_ipv4/ip_conntrack_irc.h	2004-08-08 12:49:45 +=
02:00
+++ b/include/linux/netfilter_ipv4/ip_conntrack_irc.h	2004-08-08 12:49:45 +=
02:00
@@ -33,17 +33,12 @@
=20
 #ifdef __KERNEL__
=20
-#include <linux/netfilter_ipv4/lockhelp.h>
-
 #define IRC_PORT	6667
=20
 struct dccproto {
 	char* match;
 	int matchlen;
 };
-
-/* Protects irc part of conntracks */
-DECLARE_LOCK_EXTERN(ip_irc_lock);
=20
 #endif /* __KERNEL__ */
=20
diff -Nru a/net/ipv4/netfilter/ip_conntrack_ftp.c b/net/ipv4/netfilter/ip_c=
onntrack_ftp.c
--- a/net/ipv4/netfilter/ip_conntrack_ftp.c	2004-08-08 12:49:45 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_ftp.c	2004-08-08 12:49:45 +02:00
@@ -11,7 +11,7 @@
 #include <linux/netfilter_ipv4/ip_conntrack_helper.h>
 #include <linux/netfilter_ipv4/ip_conntrack_ftp.h>
=20
-DECLARE_LOCK(ip_ftp_lock);
+static DECLARE_LOCK(ip_ftp_lock);
 struct module *ip_conntrack_ftp =3D THIS_MODULE;
=20
 #define MAX_PORTS 8
@@ -338,7 +338,6 @@
 	memset(&expect, 0, sizeof(expect));
=20
 	/* Update the ftp info */
-	LOCK_BH(&ip_ftp_lock);
 	if (htonl((array[0] << 24) | (array[1] << 16) | (array[2] << 8) | array[3=
])
 	    =3D=3D ct->tuplehash[dir].tuple.src.ip) {
 		exp->seq =3D ntohl(tcph->seq) + matchoff;
@@ -358,7 +357,8 @@
 		   <lincoln@cesar.org.br> for reporting this potential
 		   problem (DMZ machines opening holes to internal
 		   networks, or the packet filter itself). */
-		if (!loose) goto out;
+		if (!loose)
+			return NF_ACCEPT;
 	}
=20
 	exp->tuple =3D ((struct ip_conntrack_tuple)
@@ -376,9 +376,6 @@
=20
 	/* Ignore failure; should only happen with NAT */
 	ip_conntrack_expect_related(ct, &expect);
- out:
-	UNLOCK_BH(&ip_ftp_lock);
-
 	return NF_ACCEPT;
 }
=20
diff -Nru a/net/ipv4/netfilter/ip_conntrack_irc.c b/net/ipv4/netfilter/ip_c=
onntrack_irc.c
--- a/net/ipv4/netfilter/ip_conntrack_irc.c	2004-08-08 12:49:45 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_irc.c	2004-08-08 12:49:45 +02:00
@@ -29,7 +29,6 @@
 #include <net/checksum.h>
 #include <net/tcp.h>
=20
-#include <linux/netfilter_ipv4/lockhelp.h>
 #include <linux/netfilter_ipv4/ip_conntrack_helper.h>
 #include <linux/netfilter_ipv4/ip_conntrack_irc.h>
=20
@@ -61,7 +60,6 @@
 };
 #define MINMATCHLEN	5
=20
-DECLARE_LOCK(ip_irc_lock);
 struct module *ip_conntrack_irc =3D THIS_MODULE;
=20
 #if 0
@@ -208,8 +206,6 @@
 		=09
 			memset(&expect, 0, sizeof(expect));
=20
-			LOCK_BH(&ip_irc_lock);
-
 			/* save position of address in dcc string,
 			 * neccessary for NAT */
 			DEBUGP("tcph->seq =3D %u\n", tcph->seq);
@@ -236,8 +232,6 @@
 				ntohs(exp->tuple.dst.u.tcp.port));
=20
 			ip_conntrack_expect_related(ct, &expect);
-			UNLOCK_BH(&ip_irc_lock);
-
 			return NF_ACCEPT;
 		} /* for .. NUM_DCCPROTO */
 	} /* while data < ... */
@@ -314,8 +308,6 @@
 		ip_conntrack_helper_unregister(&irc_helpers[i]);
 	}
 }
-
-EXPORT_SYMBOL(ip_irc_lock);
=20
 module_init(init);
 module_exit(fini);
diff -Nru a/net/ipv4/netfilter/ip_nat_ftp.c b/net/ipv4/netfilter/ip_nat_ftp=
=2Ec
--- a/net/ipv4/netfilter/ip_nat_ftp.c	2004-08-08 12:49:45 +02:00
+++ b/net/ipv4/netfilter/ip_nat_ftp.c	2004-08-08 12:49:45 +02:00
@@ -24,8 +24,6 @@
 MODULE_PARM(ports, "1-" __MODULE_STRING(MAX_PORTS) "i");
 #endif
=20
-DECLARE_LOCK_EXTERN(ip_ftp_lock);
-
 /* FIXME: Time out? --RR */
=20
 static unsigned int
@@ -48,8 +46,6 @@
 	DEBUGP("nat_expected: We have a connection!\n");
 	exp_ftp_info =3D &ct->master->help.exp_ftp_info;
=20
-	LOCK_BH(&ip_ftp_lock);
-
 	if (exp_ftp_info->ftptype =3D=3D IP_CT_FTP_PORT
 	    || exp_ftp_info->ftptype =3D=3D IP_CT_FTP_EPRT) {
 		/* PORT command: make connection go to the client. */
@@ -64,7 +60,6 @@
 		DEBUGP("nat_expected: PASV cmd. %u.%u.%u.%u->%u.%u.%u.%u\n",
 		       NIPQUAD(newsrcip), NIPQUAD(newdstip));
 	}
-	UNLOCK_BH(&ip_ftp_lock);
=20
 	if (HOOK2MANIP(hooknum) =3D=3D IP_NAT_MANIP_SRC)
 		newip =3D newsrcip;
@@ -100,8 +95,6 @@
 {
 	char buffer[sizeof("nnn,nnn,nnn,nnn,nnn,nnn")];
=20
-	MUST_BE_LOCKED(&ip_ftp_lock);
-
 	sprintf(buffer, "%u,%u,%u,%u,%u,%u",
 		NIPQUAD(newip), port>>8, port&0xFF);
=20
@@ -123,8 +116,6 @@
 {
 	char buffer[sizeof("|1|255.255.255.255|65535|")];
=20
-	MUST_BE_LOCKED(&ip_ftp_lock);
-
 	sprintf(buffer, "|1|%u.%u.%u.%u|%u|", NIPQUAD(newip), port);
=20
 	DEBUGP("calling ip_nat_mangle_tcp_packet\n");
@@ -145,8 +136,6 @@
 {
 	char buffer[sizeof("|||65535|")];
=20
-	MUST_BE_LOCKED(&ip_ftp_lock);
-
 	sprintf(buffer, "|||%u|", port);
=20
 	DEBUGP("calling ip_nat_mangle_tcp_packet\n");
@@ -178,7 +167,6 @@
 	u_int16_t port;
 	struct ip_conntrack_tuple newtuple;
=20
-	MUST_BE_LOCKED(&ip_ftp_lock);
 	DEBUGP("FTP_NAT: seq %u + %u in %u\n",
 	       expect->seq, exp_ftp_info->len,
 	       ntohl(tcph->seq));
@@ -257,15 +245,12 @@
 	}
=20
 	datalen =3D (*pskb)->len - iph->ihl * 4 - tcph->doff * 4;
-	LOCK_BH(&ip_ftp_lock);
 	/* If it's in the right range... */
 	if (between(exp->seq + exp_ftp_info->len,
 		    ntohl(tcph->seq),
 		    ntohl(tcph->seq) + datalen)) {
-		if (!ftp_data_fixup(exp_ftp_info, ct, pskb, ctinfo, exp)) {
-			UNLOCK_BH(&ip_ftp_lock);
+		if (!ftp_data_fixup(exp_ftp_info, ct, pskb, ctinfo, exp))
 			return NF_DROP;
-		}
 	} else {
 		/* Half a match?  This means a partial retransmisison.
 		   It's a cracker being funky. */
@@ -275,11 +260,8 @@
 			       ntohl(tcph->seq),
 			       ntohl(tcph->seq) + datalen);
 		}
-		UNLOCK_BH(&ip_ftp_lock);
 		return NF_DROP;
 	}
-	UNLOCK_BH(&ip_ftp_lock);
-
 	return NF_ACCEPT;
 }
=20
diff -Nru a/net/ipv4/netfilter/ip_nat_irc.c b/net/ipv4/netfilter/ip_nat_irc=
=2Ec
--- a/net/ipv4/netfilter/ip_nat_irc.c	2004-08-08 12:49:45 +02:00
+++ b/net/ipv4/netfilter/ip_nat_irc.c	2004-08-08 12:49:45 +02:00
@@ -46,9 +46,6 @@
 MODULE_PARM_DESC(ports, "port numbers of IRC servers");
 #endif
=20
-/* protects irc part of conntracks */
-DECLARE_LOCK_EXTERN(ip_irc_lock);
-
 /* FIXME: Time out? --RR */
=20
 static unsigned int
@@ -104,8 +101,6 @@
 	/* "4294967296 65635 " */
 	char buffer[18];
=20
-	MUST_BE_LOCKED(&ip_irc_lock);
-
 	DEBUGP("IRC_NAT: info (seq %u + %u) in %u\n",
 	       expect->seq, exp_irc_info->len,
 	       ntohl(tcph->seq));
@@ -113,11 +108,6 @@
 	newip =3D ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.ip;
=20
 	/* Alter conntrack's expectations. */
-
-	/* We can read expect here without conntrack lock, since it's
-	   only set in ip_conntrack_irc, with ip_irc_lock held
-	   writable */
-
 	t =3D expect->tuple;
 	t.dst.ip =3D newip;
 	for (port =3D exp_irc_info->port; port !=3D 0; port++) {
@@ -187,15 +177,12 @@
 	DEBUGP("got beyond not touching\n");
=20
 	datalen =3D (*pskb)->len - iph->ihl * 4 - tcph->doff * 4;
-	LOCK_BH(&ip_irc_lock);
 	/* Check wether the whole IP/address pattern is carried in the payload */
 	if (between(exp->seq + exp_irc_info->len,
 		    ntohl(tcph->seq),
 		    ntohl(tcph->seq) + datalen)) {
-		if (!irc_data_fixup(exp_irc_info, ct, pskb, ctinfo, exp)) {
-			UNLOCK_BH(&ip_irc_lock);
+		if (!irc_data_fixup(exp_irc_info, ct, pskb, ctinfo, exp))
 			return NF_DROP;
-		}
 	} else {=20
 		/* Half a match?  This means a partial retransmisison.
 		   It's a cracker being funky. */
@@ -206,11 +193,8 @@
 			     ntohl(tcph->seq),
 			     ntohl(tcph->seq) + datalen);
 		}
-		UNLOCK_BH(&ip_irc_lock);
 		return NF_DROP;
 	}
-	UNLOCK_BH(&ip_irc_lock);
-
 	return NF_ACCEPT;
 }
=20
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--qgEfXXHyyarqcYJd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBOBeXXaXGVTD0i/8RAjEuAJ41bNu5bI3O7R6UJQskFf5wGN5G9QCfbGDk
Joq5HfUvLv0Fokn9mwXPG50=
=aVT1
-----END PGP SIGNATURE-----

--qgEfXXHyyarqcYJd--
