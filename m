From: Daniel Stone <daniel@fooishbar.org>
Subject: net/ipv4/route.c GC patch: is this insane?
Date: Mon, 31 May 2004 01:14:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040530151434.GE24955@fooishbar.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uCPdOCrL+PnN2Vxy"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--uCPdOCrL+PnN2Vxy
Content-Type: multipart/mixed; boundary="/3yNEOqWowh/8j+e"
Content-Disposition: inline


--/3yNEOqWowh/8j+e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi guys,
Attached is a patch to net/ipv4/route.c (against 2.4.23, sorry) to
combat the 'dst cache full' issue. Essentially, there's a machine that I
have access to (a router) that will report 'dst cache full', and
immediately cease dealing with any IPv4 traffic. I found the attached
patch against 2.0, and forward-ported it to 2.4. As this issue only
crops up randomly every couple of weeks, I can't tell you whether it's
worked or not. All I know is that it hasn't eaten my firstborn so far:
given a quick spin, it seemed to work OK, but whether or not it solves
the problem is a different matter.

I also have /proc/net dumps of the machine from before and after it
died, if anyone wants them.

So, is this patch at all sane?

Please CC me: I don't subscribe.

Cheers!
:) d (to borrow from Michael M: 'hacker, iterant idiot')

--=20
Daniel Stone                                              <daniel@fooishbar=
=2Eorg>
"The programs are documented fully by _The Rise and Fall of a Fooish Bar_,
available by the Info system." -- debian/manpage.sgml.ex, dh_make template

--/3yNEOqWowh/8j+e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="route-fix-gc.diff"
Content-Transfer-Encoding: quoted-printable

--- net/ipv4/route.c.orig	2004-05-11 23:56:10.000000000 +1000
+++ net/ipv4/route.c	2004-05-27 16:16:23.000000000 +1000
@@ -101,7 +101,7 @@
=20
 #define IP_MAX_MTU	0xFFF0
=20
-#define RT_GC_TIMEOUT (300*HZ)
+#define RT_GC_TIMEOUT (120*HZ)
=20
 int ip_rt_min_delay		=3D 2 * HZ;
 int ip_rt_max_delay		=3D 10 * HZ;
@@ -138,7 +138,8 @@
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static int rt_garbage_collect(void);
-
+static int rt_garbage_docollect(void);
+static int rt_delete_now(void);
=20
 struct dst_ops ipv4_dst_ops =3D {
 	family:			AF_INET,
@@ -526,7 +527,7 @@
    and when load increases it reduces to limit cache size.
  */
=20
-static int rt_garbage_collect(void)
+static int rt_garbage_docollect(void)
 {
 	static unsigned long expire =3D RT_GC_TIMEOUT;
 	static unsigned long last_gc;
@@ -630,8 +631,11 @@
=20
 	if (atomic_read(&ipv4_dst_ops.entries) < ip_rt_max_size)
 		goto out;
+	/*
+	 * don't bitch, just silently attempt to correct
 	if (net_ratelimit())
 		printk(KERN_WARNING "dst cache overflow\n");
+	*/
 	rt_cache_stat[smp_processor_id()].gc_dst_overflow++;
 	return 1;
=20
@@ -646,6 +650,40 @@
 #endif
 out:	return 0;
 }
+static int rt_delete_now(void){
+	struct rtable *rth, **rthp;
+	int i =3D 0, ent1 =3D 0, ent2 =3D 0, c =3D 0;
+
+	ent1 =3D atomic_read(&ipv4_dst_ops.entries);
+	local_bh_disable();
+	while (i < rt_hash_mask) {
+		rthp =3D &(rt_hash_table[i].chain);
+		while ((rth =3D *rthp) !=3D NULL) {
+			*rthp =3D rth->u.rt_next;
+			rth->u.rt_next =3D NULL;
+			c++;
+			rt_free(rth);
+		}
+		i++;
+	}
+
+	atomic_set(&ipv4_dst_ops.entries, 0);
+	local_bh_enable();
+	ent2 =3D atomic_read(&ipv4_dst_ops.entries);
+
+	if (net_ratelimit()){
+		printk("dst cache overflow\n");
+		printk("rt_delete_now(): s:%d e:%d t:%d\n", ent1, ent2, c);
+	}
+=09
+	return 0;
+}
+
+static int rt_garbage_collect(void){
+	if (rt_garbage_docollect())
+		rt_delete_now();
+	return 0;
+}
=20
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable =
**rp)
 {

--/3yNEOqWowh/8j+e--

--uCPdOCrL+PnN2Vxy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAufpacPClnTztfv0RAtNkAJ90UcBDeYCGC+qgykn2jaWFUlwHVQCfdIl/
HqkrzcKj0JczVvA6uhKOnGs=
=WyW4
-----END PGP SIGNATURE-----

--uCPdOCrL+PnN2Vxy--
