From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.6] iptables CONNMARK match+target
Date: Thu, 21 Oct 2004 00:21:02 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041020222102.GO19899@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Pk/CTwBz1VvfPIDp"
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	hno@marasystems.com
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


--Pk/CTwBz1VvfPIDp
Content-Type: multipart/mixed; boundary="HxQt9wRz9wbL5Edg"
Content-Disposition: inline


--HxQt9wRz9wbL5Edg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

Since 2.6.9 is out, I'll be pushing new feature patches again.

This is the first patch, adding something similar like nfmark, but on a
per-conntrack (as opposed to per-skb) level.  Very useful especially for
asymmatric routing in combination with MASQUERADE, as often found on
home DSL setups with dymamic IP address that also have e.g. a tunnel
device with static IP.

Signed-off-by: Henrik Nordstrom <hno@marasystems.com>
Signed-off-by: Harald Welte <laforge@netfilter.org>

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--HxQt9wRz9wbL5Edg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="2.6.9-connmark.patch"
Content-Transfer-Encoding: quoted-printable

diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-test/include/linux/netfilter_ipv4/ip_conntrack.h linux-2.6.9-connmark/=
include/linux/netfilter_ipv4/ip_conntrack.h
--- linux-2.6.9-test/include/linux/netfilter_ipv4/ip_conntrack.h	2004-10-18=
 23:55:21.000000000 +0200
+++ linux-2.6.9-connmark/include/linux/netfilter_ipv4/ip_conntrack.h	2004-1=
0-20 23:59:36.354104294 +0200
@@ -212,6 +212,10 @@
 	} nat;
 #endif /* CONFIG_IP_NF_NAT_NEEDED */
=20
+#if defined(CONFIG_IP_NF_CONNTRACK_MARK)
+	unsigned long mark;
+#endif
+
 	/* Traversed often, so hopefully in different cacheline to top */
 	/* These are my tuples; original and reply */
 	struct ip_conntrack_tuple_hash tuplehash[IP_CT_DIR_MAX];
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-test/include/linux/netfilter_ipv4/ipt_CONNMARK.h linux-2.6.9-connmark/=
include/linux/netfilter_ipv4/ipt_CONNMARK.h
--- linux-2.6.9-test/include/linux/netfilter_ipv4/ipt_CONNMARK.h	1970-01-01=
 01:00:00.000000000 +0100
+++ linux-2.6.9-connmark/include/linux/netfilter_ipv4/ipt_CONNMARK.h	2004-1=
0-20 23:59:36.343104676 +0200
@@ -0,0 +1,25 @@
+#ifndef _IPT_CONNMARK_H_target
+#define _IPT_CONNMARK_H_target
+
+/* Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ * by Henrik Nordstrom <hno@marasystems.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+enum {
+	IPT_CONNMARK_SET =3D 0,
+	IPT_CONNMARK_SAVE,
+	IPT_CONNMARK_RESTORE
+};
+
+struct ipt_connmark_target_info {
+	unsigned long mark;
+	unsigned long mask;
+	u_int8_t mode;
+};
+
+#endif /*_IPT_CONNMARK_H_target*/
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-test/include/linux/netfilter_ipv4/ipt_connmark.h linux-2.6.9-connmark/=
include/linux/netfilter_ipv4/ipt_connmark.h
--- linux-2.6.9-test/include/linux/netfilter_ipv4/ipt_connmark.h	1970-01-01=
 01:00:00.000000000 +0100
+++ linux-2.6.9-connmark/include/linux/netfilter_ipv4/ipt_connmark.h	2004-1=
0-20 23:59:36.345104606 +0200
@@ -0,0 +1,18 @@
+#ifndef _IPT_CONNMARK_H
+#define _IPT_CONNMARK_H
+
+/* Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ * by Henrik Nordstrom <hno@marasystems.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+struct ipt_connmark_info {
+	unsigned long mark, mask;
+	u_int8_t invert;
+};
+
+#endif /*_IPT_CONNMARK_H*/
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-test/net/ipv4/netfilter/Kconfig linux-2.6.9-connmark/net/ipv4/netfilte=
r/Kconfig
--- linux-2.6.9-test/net/ipv4/netfilter/Kconfig	2004-10-18 23:54:55.0000000=
00 +0200
+++ linux-2.6.9-connmark/net/ipv4/netfilter/Kconfig	2004-10-21 00:16:30.830=
850002 +0200
@@ -32,6 +32,14 @@
=20
 	  If unsure, say `N'.
=20
+config IP_NF_CONNTRACK_MARK
+	bool  'Connection mark tracking support'
+	help
+	  This option enables support for connection marks, used by the
+	  `CONNMARK' target and `connmark' match. Similar to the mark value
+	  of packets, but this mark value is kept in the conntrack session
+	  instead of the individual packets.
+=09
 config IP_NF_CT_PROTO_SCTP
 	tristate  'SCTP protocol connection tracking support (EXPERIMENTAL)'
 	depends on IP_NF_CONNTRACK && EXPERIMENTAL
@@ -342,6 +350,17 @@
 	  If you want to compile it as a module, say M here and read
 	  Documentation/modules.txt.  If unsure, say `N'.
=20
+config IP_NF_MATCH_CONNMARK
+	tristate  'Connection mark match support'
+	depends on IP_NF_CONNTRACK_MARK && IP_NF_IPTABLES
+	help
+	  This option adds a `connmark' match, which allows you to match the
+	  connection mark value previously set for the session by `CONNMARK'.=20
+=09
+	  If you want to compile it as a module, say M here and read
+	  Documentation/modules.txt.  The module will be called
+	  ipt_connmark.o.  If unsure, say `N'.
+
 # `filter', generic and specific targets
 config IP_NF_FILTER
 	tristate "Packet filtering"
@@ -597,6 +616,18 @@
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
+config IP_NF_TARGET_CONNMARK
+	tristate  'CONNMARK target support'
+	depends on IP_NF_CONNTRACK_MARK && IP_NF_MANGLE
+	help
+	  This option adds a `CONNMARK' target, which allows one to manipulate
+	  the connection mark value.  Similar to the MARK target, but
+	  affects the connection mark value rather than the packet mark value.
+=09
+	  If you want to compile it as a module, say M here and read
+	  Documentation/modules.txt.  The module will be called
+	  ipt_CONNMARK.o.  If unsure, say `N'.
+
 # raw + specific targets
 config IP_NF_RAW
 	tristate  'raw table support (required for NOTRACK/TRACE)'
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-test/net/ipv4/netfilter/Makefile linux-2.6.9-connmark/net/ipv4/netfilt=
er/Makefile
--- linux-2.6.9-test/net/ipv4/netfilter/Makefile	2004-10-18 23:53:43.000000=
000 +0200
+++ linux-2.6.9-connmark/net/ipv4/netfilter/Makefile	2004-10-20 23:59:36.36=
8103807 +0200
@@ -61,6 +61,7 @@
 obj-$(CONFIG_IP_NF_MATCH_LENGTH) +=3D ipt_length.o
 obj-$(CONFIG_IP_NF_MATCH_TTL) +=3D ipt_ttl.o
 obj-$(CONFIG_IP_NF_MATCH_STATE) +=3D ipt_state.o
+obj-$(CONFIG_IP_NF_MATCH_CONNMARK) +=3D ipt_connmark.o
 obj-$(CONFIG_IP_NF_MATCH_CONNTRACK) +=3D ipt_conntrack.o
 obj-$(CONFIG_IP_NF_MATCH_TCPMSS) +=3D ipt_tcpmss.o
 obj-$(CONFIG_IP_NF_MATCH_REALM) +=3D ipt_realm.o
@@ -81,6 +82,7 @@
 obj-$(CONFIG_IP_NF_TARGET_CLASSIFY) +=3D ipt_CLASSIFY.o
 obj-$(CONFIG_IP_NF_NAT_SNMP_BASIC) +=3D ip_nat_snmp_basic.o
 obj-$(CONFIG_IP_NF_TARGET_LOG) +=3D ipt_LOG.o
+obj-$(CONFIG_IP_NF_TARGET_CONNMARK) +=3D ipt_CONNMARK.o
 obj-$(CONFIG_IP_NF_TARGET_ULOG) +=3D ipt_ULOG.o
 obj-$(CONFIG_IP_NF_TARGET_TCPMSS) +=3D ipt_TCPMSS.o
 obj-$(CONFIG_IP_NF_TARGET_NOTRACK) +=3D ipt_NOTRACK.o
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-test/net/ipv4/netfilter/ip_conntrack_core.c linux-2.6.9-connmark/net/i=
pv4/netfilter/ip_conntrack_core.c
--- linux-2.6.9-test/net/ipv4/netfilter/ip_conntrack_core.c	2004-10-18 23:5=
3:05.000000000 +0200
+++ linux-2.6.9-connmark/net/ipv4/netfilter/ip_conntrack_core.c	2004-10-20 =
23:59:36.402102626 +0200
@@ -595,6 +595,9 @@
 		__set_bit(IPS_EXPECTED_BIT, &conntrack->status);
 		conntrack->master =3D expected;
 		expected->sibling =3D conntrack;
+#if CONFIG_IP_NF_CONNTRACK_MARK
+		conntrack->mark =3D expected->expectant->mark;
+#endif
 		LIST_DELETE(&ip_conntrack_expect_list, expected);
 		expected->expectant->expecting--;
 		nf_conntrack_get(&master_ct(conntrack)->ct_general);
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-test/net/ipv4/netfilter/ip_conntrack_standalone.c linux-2.6.9-connmark=
/net/ipv4/netfilter/ip_conntrack_standalone.c
--- linux-2.6.9-test/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-10-1=
8 23:54:07.000000000 +0200
+++ linux-2.6.9-connmark/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-=
10-21 00:01:55.101282662 +0200
@@ -146,6 +146,11 @@
 		if (seq_printf(s, "[ASSURED] "))
 			return 1;
=20
+#if defined(CONFIG_IP_NF_CONNTRACK_MARK)
+	if (seq_printf(s, "mark=3D%ld ", conntrack->mark))
+		return 1;
+#endif
+
 	if (seq_printf(s, "use=3D%u\n", atomic_read(&conntrack->ct_general.use)))
 		return 1;
=20
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-test/net/ipv4/netfilter/ipt_CONNMARK.c linux-2.6.9-connmark/net/ipv4/n=
etfilter/ipt_CONNMARK.c
--- linux-2.6.9-test/net/ipv4/netfilter/ipt_CONNMARK.c	1970-01-01 01:00:00.=
000000000 +0100
+++ linux-2.6.9-connmark/net/ipv4/netfilter/ipt_CONNMARK.c	2004-10-20 23:59=
:36.347104537 +0200
@@ -0,0 +1,118 @@
+/* This kernel module is used to modify the connection mark values, or
+ * to optionally restore the skb nfmark from the connection mark
+ *
+ * Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ * by Henrik Nordstrom <hno@marasystems.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <net/checksum.h>
+
+MODULE_AUTHOR("Henrik Nordstrom <hno@marasytems.com>");
+MODULE_DESCRIPTION("IP tables CONNMARK matching module");
+MODULE_LICENSE("GPL");
+
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ipt_CONNMARK.h>
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	const struct ipt_connmark_target_info *markinfo =3D targinfo;
+	unsigned long diff;
+	unsigned long nfmark;
+	unsigned long newmark;
+
+	enum ip_conntrack_info ctinfo;
+	struct ip_conntrack *ct =3D ip_conntrack_get((*pskb), &ctinfo);
+	if (ct) {
+	    switch(markinfo->mode) {
+	    case IPT_CONNMARK_SET:
+		newmark =3D (ct->mark & ~markinfo->mask) | markinfo->mark;
+		if (newmark !=3D ct->mark)
+		    ct->mark =3D newmark;
+		break;
+	    case IPT_CONNMARK_SAVE:
+		newmark =3D (ct->mark & ~markinfo->mask) | ((*pskb)->nfmark & markinfo->=
mask);
+		if (ct->mark !=3D newmark)
+		    ct->mark =3D newmark;
+		break;
+	    case IPT_CONNMARK_RESTORE:
+		nfmark =3D (*pskb)->nfmark;
+		diff =3D (ct->mark ^ nfmark & markinfo->mask);
+		if (diff !=3D 0) {
+		    (*pskb)->nfmark =3D nfmark ^ diff;
+		    (*pskb)->nfcache |=3D NFC_ALTERED;
+		}
+		break;
+	    }
+	}
+
+	return IPT_CONTINUE;
+}
+
+static int
+checkentry(const char *tablename,
+	   const struct ipt_entry *e,
+	   void *targinfo,
+	   unsigned int targinfosize,
+	   unsigned int hook_mask)
+{
+	struct ipt_connmark_target_info *matchinfo =3D targinfo;
+	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_connmark_target_info)))=
 {
+		printk(KERN_WARNING "CONNMARK: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       IPT_ALIGN(sizeof(struct ipt_connmark_target_info)));
+		return 0;
+	}
+
+	if (matchinfo->mode =3D=3D IPT_CONNMARK_RESTORE) {
+	    if (strcmp(tablename, "mangle") !=3D 0) {
+		    printk(KERN_WARNING "CONNMARK: restore can only be called from \"man=
gle\" table, not \"%s\"\n", tablename);
+		    return 0;
+	    }
+	}
+
+	return 1;
+}
+
+static struct ipt_target ipt_connmark_reg =3D {
+	.name =3D "CONNMARK",
+	.target =3D &target,
+	.checkentry =3D &checkentry,
+	.me =3D THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ipt_register_target(&ipt_connmark_reg);
+}
+
+static void __exit fini(void)
+{
+	ipt_unregister_target(&ipt_connmark_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-test/net/ipv4/netfilter/ipt_connmark.c linux-2.6.9-connmark/net/ipv4/n=
etfilter/ipt_connmark.c
--- linux-2.6.9-test/net/ipv4/netfilter/ipt_connmark.c	1970-01-01 01:00:00.=
000000000 +0100
+++ linux-2.6.9-connmark/net/ipv4/netfilter/ipt_connmark.c	2004-10-20 23:59=
:36.349104467 +0200
@@ -0,0 +1,81 @@
+/* This kernel module matches connection mark values set by the
+ * CONNMARK target
+ *
+ * Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com>
+ * by Henrik Nordstrom <hno@marasystems.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+MODULE_AUTHOR("Henrik Nordstrom <hno@marasytems.com>");
+MODULE_DESCRIPTION("IP tables connmark match module");
+MODULE_LICENSE("GPL");
+
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ipt_connmark.h>
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      int *hotdrop)
+{
+	const struct ipt_connmark_info *info =3D matchinfo;
+	enum ip_conntrack_info ctinfo;
+	struct ip_conntrack *ct =3D ip_conntrack_get((struct sk_buff *)skb, &ctin=
fo);
+	if (!ct)
+		return 0;
+
+	return ((ct->mark & info->mask) =3D=3D info->mark) ^ info->invert;
+}
+
+static int
+checkentry(const char *tablename,
+	   const struct ipt_ip *ip,
+	   void *matchinfo,
+	   unsigned int matchsize,
+	   unsigned int hook_mask)
+{
+	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_connmark_info)))
+		return 0;
+
+	return 1;
+}
+
+static struct ipt_match connmark_match =3D {
+	.name =3D "connmark",
+	.match =3D &match,
+	.checkentry =3D &checkentry,
+	.me =3D THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ipt_register_match(&connmark_match);
+}
+
+static void __exit fini(void)
+{
+	ipt_unregister_match(&connmark_match);
+}
+
+module_init(init);
+module_exit(fini);

--HxQt9wRz9wbL5Edg--

--Pk/CTwBz1VvfPIDp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBduTOXaXGVTD0i/8RAlVJAJ4tNUu0NhWF6wREt8FhXoV4ULgYzACgqXZP
6BVDb9ucy1qYrIuC8cuAeU0=
=GFDy
-----END PGP SIGNATURE-----

--Pk/CTwBz1VvfPIDp--
