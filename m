From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] move conntrack helper buffers out of BSS
Date: Mon, 8 Aug 2005 00:39:34 +0200
Message-ID: <20050807223934.GA4066@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="V88s5gaDVPzZ0KCq"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
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
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--V88s5gaDVPzZ0KCq
Content-Type: multipart/mixed; boundary="98e8jtXdkpgskNou"
Content-Disposition: inline


--98e8jtXdkpgskNou
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,
I guess you will enjoy the following patch ;)
Please apply to net-2.6.14, thanks.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--98e8jtXdkpgskNou
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="36-conntrack_helper-nobss.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] move conntrack helper buffers from BSS to kmalloc()ed memory

According to DaveM, it is preferrable to have large data structures be
allocated dynamically from the module init() function rather than putting
them as static global variables into BSS.

This patch moves the conntrack helper packet buffers into dynamically
allocated memory.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 6a85f7cafea91c2eea692828c7c1602d2da4f4c4
tree 66716ca9e7565377dcd42552a69189c8300f8182
parent 56ca768cb5d27e3b1929656cb186976c3b9af5ec
author Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 00:31:23 +0200
committer Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 00:31:23 +02=
00

 net/ipv4/netfilter/ip_conntrack_amanda.c |   18 ++++++++++++++++--
 net/ipv4/netfilter/ip_conntrack_ftp.c    |    9 +++++++--
 net/ipv4/netfilter/ip_conntrack_irc.c    |    7 ++++++-
 3 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_amanda.c b/net/ipv4/netfilter/=
ip_conntrack_amanda.c
--- a/net/ipv4/netfilter/ip_conntrack_amanda.c
+++ b/net/ipv4/netfilter/ip_conntrack_amanda.c
@@ -40,7 +40,7 @@ MODULE_PARM_DESC(master_timeout, "timeou
 static char *conns[] =3D { "DATA ", "MESG ", "INDEX " };
=20
 /* This is slow, but it's simple. --RR */
-static char amanda_buffer[65536];
+static char *amanda_buffer;
 static DEFINE_SPINLOCK(amanda_buffer_lock);
=20
 unsigned int (*ip_nat_amanda_hook)(struct sk_buff **pskb,
@@ -153,11 +153,25 @@ static struct ip_conntrack_helper amanda
 static void __exit fini(void)
 {
 	ip_conntrack_helper_unregister(&amanda_helper);
+	kfree(amanda_buffer);
 }
=20
 static int __init init(void)
 {
-	return ip_conntrack_helper_register(&amanda_helper);
+	int ret;
+
+	amanda_buffer =3D kmalloc(65536, GFP_KERNEL);
+	if (!amanda_buffer)
+		return -ENOMEM;
+
+	ret =3D ip_conntrack_helper_register(&amanda_helper);
+	if (ret < 0) {
+		kfree(amanda_buffer);
+		return ret;
+	}
+	return 0;
+
+
 }
=20
 module_init(init);
diff --git a/net/ipv4/netfilter/ip_conntrack_ftp.c b/net/ipv4/netfilter/ip_=
conntrack_ftp.c
--- a/net/ipv4/netfilter/ip_conntrack_ftp.c
+++ b/net/ipv4/netfilter/ip_conntrack_ftp.c
@@ -25,8 +25,7 @@ MODULE_AUTHOR("Rusty Russell <rusty@rust
 MODULE_DESCRIPTION("ftp connection tracking helper");
=20
 /* This is slow, but it's simple. --RR */
-static char ftp_buffer[65536];
-
+static char *ftp_buffer;
 static DEFINE_SPINLOCK(ip_ftp_lock);
=20
 #define MAX_PORTS 8
@@ -461,6 +460,8 @@ static void fini(void)
 				ports[i]);
 		ip_conntrack_helper_unregister(&ftp[i]);
 	}
+
+	kfree(ftp_buffer);
 }
=20
 static int __init init(void)
@@ -468,6 +469,10 @@ static int __init init(void)
 	int i, ret;
 	char *tmpname;
=20
+	ftp_buffer =3D kmalloc(65536, GFP_KERNEL);
+	if (!ftp_buffer)
+		return -ENOMEM;
+
 	if (ports_c =3D=3D 0)
 		ports[ports_c++] =3D FTP_PORT;
=20
diff --git a/net/ipv4/netfilter/ip_conntrack_irc.c b/net/ipv4/netfilter/ip_=
conntrack_irc.c
--- a/net/ipv4/netfilter/ip_conntrack_irc.c
+++ b/net/ipv4/netfilter/ip_conntrack_irc.c
@@ -39,7 +39,7 @@ static int ports_c;
 static int max_dcc_channels =3D 8;
 static unsigned int dcc_timeout =3D 300;
 /* This is slow, but it's simple. --RR */
-static char irc_buffer[65536];
+static char *irc_buffer;
 static DEFINE_SPINLOCK(irc_buffer_lock);
=20
 unsigned int (*ip_nat_irc_hook)(struct sk_buff **pskb,
@@ -257,6 +257,10 @@ static int __init init(void)
 		printk("ip_conntrack_irc: dcc_timeout must be a positive integer\n");
 		return -EBUSY;
 	}
+
+	irc_buffer =3D kmalloc(65536, GFP_KERNEL);
+	if (!irc_buffer)
+		return -ENOMEM;
 =09
 	/* If no port given, default to standard irc port */
 	if (ports_c =3D=3D 0)
@@ -304,6 +308,7 @@ static void fini(void)
 		       ports[i]);
 		ip_conntrack_helper_unregister(&irc_helpers[i]);
 	}
+	kfree(irc_buffer);
 }
=20
 module_init(init);

--98e8jtXdkpgskNou--

--V88s5gaDVPzZ0KCq
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC9o2lXaXGVTD0i/8RAjfcAJ9Z6UU4YeES79tTqKaw6pQrpveCfACgiYuj
JdHYqE/PeTD+lT1IbjtZM5E=
=N5yC
-----END PGP SIGNATURE-----

--V88s5gaDVPzZ0KCq--
