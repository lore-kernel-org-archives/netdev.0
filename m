From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.6] 2/2:  Fix NAT helper locking
Date: Fri, 3 Sep 2004 09:02:34 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040903070234.GQ26263@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CRjAHycgiaTQGSqU"
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


--CRjAHycgiaTQGSqU
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
#   2004/08/08 01:40:28+02:00 kaber@coreworks.de=20
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
#   2004/08/08 01:40:10+02:00 kaber@coreworks.de +1 -17
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# net/ipv4/netfilter/ip_nat_ftp.c
#   2004/08/08 01:40:10+02:00 kaber@coreworks.de +1 -19
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# net/ipv4/netfilter/ip_conntrack_irc.c
#   2004/08/08 01:40:10+02:00 kaber@coreworks.de +3 -4
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# net/ipv4/netfilter/ip_conntrack_ftp.c
#   2004/08/08 01:40:10+02:00 kaber@coreworks.de +1 -2
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# include/linux/netfilter_ipv4/ip_conntrack_irc.h
#   2004/08/08 01:40:10+02:00 kaber@coreworks.de +0 -5
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
# include/linux/netfilter_ipv4/ip_conntrack_ftp.h
#   2004/08/08 01:40:10+02:00 kaber@coreworks.de +0 -5
#   [NETFILTER]: Fix deadlock condition in conntrack/nat-helpers
#=20
diff -Nru a/include/linux/netfilter_ipv4/ip_conntrack_ftp.h b/include/linux=
/netfilter_ipv4/ip_conntrack_ftp.h
--- a/include/linux/netfilter_ipv4/ip_conntrack_ftp.h	2004-08-08 01:41:23 +=
02:00
+++ b/include/linux/netfilter_ipv4/ip_conntrack_ftp.h	2004-08-08 01:41:23 +=
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
--- a/include/linux/netfilter_ipv4/ip_conntrack_irc.h	2004-08-08 01:41:23 +=
02:00
+++ b/include/linux/netfilter_ipv4/ip_conntrack_irc.h	2004-08-08 01:41:23 +=
02:00
@@ -33,12 +33,7 @@
=20
 #ifdef __KERNEL__
=20
-#include <linux/netfilter_ipv4/lockhelp.h>
-
 #define IRC_PORT	6667
-
-/* Protects irc part of conntracks */
-DECLARE_LOCK_EXTERN(ip_irc_lock);
=20
 #endif /* __KERNEL__ */
=20
diff -Nru a/net/ipv4/netfilter/ip_conntrack_ftp.c b/net/ipv4/netfilter/ip_c=
onntrack_ftp.c
--- a/net/ipv4/netfilter/ip_conntrack_ftp.c	2004-08-08 01:41:23 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_ftp.c	2004-08-08 01:41:23 +02:00
@@ -27,7 +27,7 @@
 /* This is slow, but it's simple. --RR */
 static char ftp_buffer[65536];
=20
-DECLARE_LOCK(ip_ftp_lock);
+static DECLARE_LOCK(ip_ftp_lock);
 struct module *ip_conntrack_ftp =3D THIS_MODULE;
=20
 #define MAX_PORTS 8
@@ -455,7 +455,6 @@
 }
=20
 PROVIDES_CONNTRACK(ftp);
-EXPORT_SYMBOL(ip_ftp_lock);
=20
 module_init(init);
 module_exit(fini);
diff -Nru a/net/ipv4/netfilter/ip_conntrack_irc.c b/net/ipv4/netfilter/ip_c=
onntrack_irc.c
--- a/net/ipv4/netfilter/ip_conntrack_irc.c	2004-08-08 01:41:23 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_irc.c	2004-08-08 01:41:23 +02:00
@@ -40,6 +40,7 @@
 static unsigned int dcc_timeout =3D 300;
 /* This is slow, but it's simple. --RR */
 static char irc_buffer[65536];
+static DECLARE_LOCK(irc_buffer_lock);
=20
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_DESCRIPTION("IRC (DCC) connection tracking helper");
@@ -54,7 +55,6 @@
 static char *dccprotos[] =3D { "SEND ", "CHAT ", "MOVE ", "TSEND ", "SCHAT=
 " };
 #define MINMATCHLEN	5
=20
-DECLARE_LOCK(ip_irc_lock);
 struct module *ip_conntrack_irc =3D THIS_MODULE;
=20
 #if 0
@@ -134,7 +134,7 @@
 	if (dataoff >=3D skb->len)
 		return NF_ACCEPT;
=20
-	LOCK_BH(&ip_irc_lock);
+	LOCK_BH(&irc_buffer_lock);
 	skb_copy_bits(skb, dataoff, irc_buffer, skb->len - dataoff);
=20
 	data =3D irc_buffer;
@@ -227,7 +227,7 @@
 	} /* while data < ... */
=20
  out:
-	UNLOCK_BH(&ip_irc_lock);
+	UNLOCK_BH(&irc_buffer_lock);
 	return NF_ACCEPT;
 }
=20
@@ -302,7 +302,6 @@
 }
=20
 PROVIDES_CONNTRACK(irc);
-EXPORT_SYMBOL(ip_irc_lock);
=20
 module_init(init);
 module_exit(fini);
diff -Nru a/net/ipv4/netfilter/ip_nat_ftp.c b/net/ipv4/netfilter/ip_nat_ftp=
=2Ec
--- a/net/ipv4/netfilter/ip_nat_ftp.c	2004-08-08 01:41:23 +02:00
+++ b/net/ipv4/netfilter/ip_nat_ftp.c	2004-08-08 01:41:23 +02:00
@@ -35,8 +35,6 @@
=20
 MODULE_PARM(ports, "1-" __MODULE_STRING(MAX_PORTS) "i");
=20
-DECLARE_LOCK_EXTERN(ip_ftp_lock);
-
 /* FIXME: Time out? --RR */
=20
 static unsigned int
@@ -59,8 +57,6 @@
 	DEBUGP("nat_expected: We have a connection!\n");
 	exp_ftp_info =3D &ct->master->help.exp_ftp_info;
=20
-	LOCK_BH(&ip_ftp_lock);
-
 	if (exp_ftp_info->ftptype =3D=3D IP_CT_FTP_PORT
 	    || exp_ftp_info->ftptype =3D=3D IP_CT_FTP_EPRT) {
 		/* PORT command: make connection go to the client. */
@@ -75,7 +71,6 @@
 		DEBUGP("nat_expected: PASV cmd. %u.%u.%u.%u->%u.%u.%u.%u\n",
 		       NIPQUAD(newsrcip), NIPQUAD(newdstip));
 	}
-	UNLOCK_BH(&ip_ftp_lock);
=20
 	if (HOOK2MANIP(hooknum) =3D=3D IP_NAT_MANIP_SRC)
 		newip =3D newsrcip;
@@ -111,8 +106,6 @@
 {
 	char buffer[sizeof("nnn,nnn,nnn,nnn,nnn,nnn")];
=20
-	MUST_BE_LOCKED(&ip_ftp_lock);
-
 	sprintf(buffer, "%u,%u,%u,%u,%u,%u",
 		NIPQUAD(newip), port>>8, port&0xFF);
=20
@@ -134,8 +127,6 @@
 {
 	char buffer[sizeof("|1|255.255.255.255|65535|")];
=20
-	MUST_BE_LOCKED(&ip_ftp_lock);
-
 	sprintf(buffer, "|1|%u.%u.%u.%u|%u|", NIPQUAD(newip), port);
=20
 	DEBUGP("calling ip_nat_mangle_tcp_packet\n");
@@ -156,8 +147,6 @@
 {
 	char buffer[sizeof("|||65535|")];
=20
-	MUST_BE_LOCKED(&ip_ftp_lock);
-
 	sprintf(buffer, "|||%u|", port);
=20
 	DEBUGP("calling ip_nat_mangle_tcp_packet\n");
@@ -189,7 +178,6 @@
 	u_int16_t port;
 	struct ip_conntrack_tuple newtuple;
=20
-	MUST_BE_LOCKED(&ip_ftp_lock);
 	DEBUGP("FTP_NAT: seq %u + %u in %u\n",
 	       expect->seq, exp_ftp_info->len,
 	       ntohl(tcph->seq));
@@ -268,15 +256,12 @@
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
@@ -286,11 +271,8 @@
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
--- a/net/ipv4/netfilter/ip_nat_irc.c	2004-08-08 01:41:23 +02:00
+++ b/net/ipv4/netfilter/ip_nat_irc.c	2004-08-08 01:41:23 +02:00
@@ -44,9 +44,6 @@
 MODULE_PARM(ports, "1-" __MODULE_STRING(MAX_PORTS) "i");
 MODULE_PARM_DESC(ports, "port numbers of IRC servers");
=20
-/* protects irc part of conntracks */
-DECLARE_LOCK_EXTERN(ip_irc_lock);
-
 /* FIXME: Time out? --RR */
=20
 static unsigned int
@@ -102,8 +99,6 @@
 	/* "4294967296 65635 " */
 	char buffer[18];
=20
-	MUST_BE_LOCKED(&ip_irc_lock);
-
 	DEBUGP("IRC_NAT: info (seq %u + %u) in %u\n",
 	       expect->seq, exp_irc_info->len,
 	       ntohl(tcph->seq));
@@ -111,11 +106,6 @@
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
@@ -185,15 +175,12 @@
 	DEBUGP("got beyond not touching\n");
=20
 	datalen =3D (*pskb)->len - iph->ihl * 4 - tcph->doff * 4;
-	LOCK_BH(&ip_irc_lock);
 	/* Check whether the whole IP/address pattern is carried in the payload */
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
@@ -204,11 +191,8 @@
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

--CRjAHycgiaTQGSqU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBOBcKXaXGVTD0i/8RAt9bAJ9mgosYQaErcJ6v/8dofPmfdB+HPwCcC+hu
q/G+Xbg03/ej1aGUj2zhWSE=
=+hPN
-----END PGP SIGNATURE-----

--CRjAHycgiaTQGSqU--
