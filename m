From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Sat, 13 Aug 2005 17:46:19 +0200
Message-ID: <20050813154619.GI4551@rama.de.gnumonks.org>
References: <20050812153730.GR18580@rama.de.gnumonks.org>
	<20050812182355.GF22901@wotan.suse.de>
	<20050812190343.GW18580@rama.de.gnumonks.org>
	<20050812.120904.88476024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQ77YLfPrO/qF/pM"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net, ak@suse.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050812.120904.88476024.davem@davemloft.net>
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


--LQ77YLfPrO/qF/pM
Content-Type: multipart/mixed; boundary="bWEb1MG/o7IKOlQF"
Content-Disposition: inline


--bWEb1MG/o7IKOlQF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The reworked version (already uses aligned_u64).  Pleas apply, thanks

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--bWEb1MG/o7IKOlQF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="46-ipt_connbytes.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] Add new iptables "connbytes" match

This patch ads a new "connbytes" match that utilizes the CONFIG_NF_CT_ACCT
per-connection byte and packet counters.  Using it you can do things like
packet classification on average packet size within a connection.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 98a0b5554e6e54a5a5a21b21b212186dc3c2118c
tree 43acbfa60366e1b111272851f1a1745a43a71d74
parent 5896088f554d8c2e7f3226973d1413df339e6b75
author Harald Welte <laforge@netfilter.org> Do, 11 Aug 2005 21:15:45 +0200
committer Harald Welte <laforge@netfilter.org> Do, 11 Aug 2005 21:15:45 +02=
00

 include/linux/netfilter_ipv4/ipt_connbytes.h |   25 ++++
 net/ipv4/netfilter/Kconfig                   |   11 ++
 net/ipv4/netfilter/Makefile                  |    1=20
 net/ipv4/netfilter/ipt_connbytes.c           |  166 ++++++++++++++++++++++=
++++
 4 files changed, 202 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ipt_connbytes.h b/include/linux/n=
etfilter_ipv4/ipt_connbytes.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ipt_connbytes.h
@@ -0,0 +1,25 @@
+#ifndef _IPT_CONNBYTES_H
+#define _IPT_CONNBYTES_H
+
+enum ipt_connbytes_what {
+	IPT_CONNBYTES_WHAT_PKTS,
+	IPT_CONNBYTES_WHAT_BYTES,
+	IPT_CONNBYTES_WHAT_AVGPKT,
+};
+
+enum ipt_connbytes_direction {
+	IPT_CONNBYTES_DIR_ORIGINAL,
+	IPT_CONNBYTES_DIR_REPLY,
+	IPT_CONNBYTES_DIR_BOTH,
+};
+
+struct ipt_connbytes_info
+{
+	struct {
+		aligned_u64 from;	/* count to be matched */
+		aligned_u64 to;		/* count to be matched */
+	} count;
+	u_int8_t what;		/* ipt_connbytes_what */
+	u_int8_t direction;	/* ipt_connbytes_direction */
+};
+#endif
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -386,6 +386,16 @@ config IP_NF_MATCH_CONNMARK
 	  <file:Documentation/modules.txt>.  The module will be called
 	  ipt_connmark.o.  If unsure, say `N'.
=20
+config IP_NF_MATCH_CONNBYTES
+	tristate  'Connection byte/packet counter match support'
+	depends on IP_NF_CT_ACCT && IP_NF_IPTABLES
+	help
+	  This option adds a `connbytes' match, which allows you to match the
+	  number of bytes and/or packets for each direction within a connection.
+
+	  If you want to compile it as a module, say M here and read
+	  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
 config IP_NF_MATCH_HASHLIMIT
 	tristate  'hashlimit match support'
 	depends on IP_NF_IPTABLES
@@ -723,6 +733,5 @@ config IP_NF_CONNTRACK_NETLINK
         help
           This option enables support for a netlink-based userspace interf=
ace
=20
-
 endmenu
=20
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_IP_NF_MATCH_TTL) +=3D ipt_ttl
 obj-$(CONFIG_IP_NF_MATCH_STATE) +=3D ipt_state.o
 obj-$(CONFIG_IP_NF_MATCH_CONNMARK) +=3D ipt_connmark.o
 obj-$(CONFIG_IP_NF_MATCH_CONNTRACK) +=3D ipt_conntrack.o
+obj-$(CONFIG_IP_NF_MATCH_CONNBYTES) +=3D ipt_connbytes.o
 obj-$(CONFIG_IP_NF_MATCH_TCPMSS) +=3D ipt_tcpmss.o
 obj-$(CONFIG_IP_NF_MATCH_REALM) +=3D ipt_realm.o
 obj-$(CONFIG_IP_NF_MATCH_ADDRTYPE) +=3D ipt_addrtype.o
diff --git a/net/ipv4/netfilter/ipt_connbytes.c b/net/ipv4/netfilter/ipt_co=
nnbytes.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_connbytes.c
@@ -0,0 +1,166 @@
+/* Kernel module to match connection tracking byte counter.
+ * GPL (C) 2002 Martin Devera (devik@cdi.cz).
+ *
+ * 2004-07-20 Harald Welte <laforge@netfilter.org>
+ * 	- reimplemented to use per-connection accounting counters
+ * 	- add functionality to match number of packets
+ * 	- add functionality to match average packet size
+ * 	- add support to match directions seperately
+ *
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ipt_connbytes.h>
+
+#include <asm/div64.h>
+#include <asm/bitops.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("iptables match for matching number of pkts/bytes per c=
onnection");
+
+/* 64bit divisor, dividend and result. dynamic precision */
+static u_int64_t div64_64(u_int64_t divisor, u_int64_t dividend)
+{
+	u_int64_t result =3D divisor;
+
+	if (dividend > 0xffffffff) {
+		int first_bit =3D find_first_bit((unsigned long *) &dividend, sizeof(div=
idend));
+		/* calculate number of bits to shift. shift exactly enough
+		 * bits to make dividend fit in 32bits. */
+		int num_shift =3D (64 - 32 - first_bit);
+		/* first bit has to be < 32, since dividend was > 0xffffffff */
+		result =3D result >> num_shift;
+		dividend =3D dividend >> num_shift;
+	}
+
+	do_div(divisor, dividend);
+
+	return divisor;
+}
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const void *matchinfo,
+      int offset,
+      int *hotdrop)
+{
+	const struct ipt_connbytes_info *sinfo =3D matchinfo;
+	enum ip_conntrack_info ctinfo;
+	struct ip_conntrack *ct;
+	u_int64_t what =3D 0;	/* initialize to make gcc happy */
+
+	if (!(ct =3D ip_conntrack_get((struct sk_buff *)skb, &ctinfo)))
+		return 0; /* no match */
+
+	switch (sinfo->what) {
+	case IPT_CONNBYTES_WHAT_PKTS:
+		switch (sinfo->direction) {
+		case IPT_CONNBYTES_DIR_ORIGINAL:
+			what =3D ct->counters[IP_CT_DIR_ORIGINAL].packets;
+			break;
+		case IPT_CONNBYTES_DIR_REPLY:
+			what =3D ct->counters[IP_CT_DIR_REPLY].packets;
+			break;
+		case IPT_CONNBYTES_DIR_BOTH:
+			what =3D ct->counters[IP_CT_DIR_ORIGINAL].packets;
+			what +=3D ct->counters[IP_CT_DIR_REPLY].packets;
+			break;
+		}
+		break;
+	case IPT_CONNBYTES_WHAT_BYTES:
+		switch (sinfo->direction) {
+		case IPT_CONNBYTES_DIR_ORIGINAL:
+			what =3D ct->counters[IP_CT_DIR_ORIGINAL].bytes;
+			break;
+		case IPT_CONNBYTES_DIR_REPLY:
+			what =3D ct->counters[IP_CT_DIR_REPLY].bytes;
+			break;
+		case IPT_CONNBYTES_DIR_BOTH:
+			what =3D ct->counters[IP_CT_DIR_ORIGINAL].bytes;
+			what +=3D ct->counters[IP_CT_DIR_REPLY].bytes;
+			break;
+		}
+		break;
+	case IPT_CONNBYTES_WHAT_AVGPKT:
+		switch (sinfo->direction) {
+		case IPT_CONNBYTES_DIR_ORIGINAL:
+			what =3D div64_64(ct->counters[IP_CT_DIR_ORIGINAL].bytes,
+					ct->counters[IP_CT_DIR_ORIGINAL].packets);
+			break;
+		case IPT_CONNBYTES_DIR_REPLY:
+			what =3D div64_64(ct->counters[IP_CT_DIR_REPLY].bytes,
+					ct->counters[IP_CT_DIR_REPLY].packets);
+			break;
+		case IPT_CONNBYTES_DIR_BOTH:
+			{
+				u_int64_t bytes;
+				u_int64_t pkts;
+				bytes =3D ct->counters[IP_CT_DIR_ORIGINAL].bytes +
+					ct->counters[IP_CT_DIR_REPLY].bytes;
+				pkts =3D ct->counters[IP_CT_DIR_ORIGINAL].packets+
+					ct->counters[IP_CT_DIR_REPLY].packets;
+
+				/* FIXME_THEORETICAL: what to do if sum
+				 * overflows ? */
+
+				what =3D div64_64(bytes, pkts);
+			}
+			break;
+		}
+		break;
+	}
+
+	if (sinfo->count.to)
+		return (what <=3D sinfo->count.to && what >=3D sinfo->count.from);
+	else
+		return (what >=3D sinfo->count.from);
+}
+
+static int check(const char *tablename,
+		 const struct ipt_ip *ip,
+		 void *matchinfo,
+		 unsigned int matchsize,
+		 unsigned int hook_mask)
+{
+	const struct ipt_connbytes_info *sinfo =3D matchinfo;
+
+	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_connbytes_info)))
+		return 0;
+
+	if (sinfo->what !=3D IPT_CONNBYTES_WHAT_PKTS &&
+	    sinfo->what !=3D IPT_CONNBYTES_WHAT_BYTES &&
+	    sinfo->what !=3D IPT_CONNBYTES_WHAT_AVGPKT)
+		return 0;
+
+	if (sinfo->direction !=3D IPT_CONNBYTES_DIR_ORIGINAL &&
+	    sinfo->direction !=3D IPT_CONNBYTES_DIR_REPLY &&
+	    sinfo->direction !=3D IPT_CONNBYTES_DIR_BOTH)
+		return 0;
+
+	return 1;
+}
+
+static struct ipt_match state_match =3D {
+	.name		=3D "connbytes",
+	.match		=3D &match,
+	.checkentry	=3D &check,
+	.me		=3D THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ipt_register_match(&state_match);
+}
+
+static void __exit fini(void)
+{
+	ipt_unregister_match(&state_match);
+}
+
+module_init(init);
+module_exit(fini);

--bWEb1MG/o7IKOlQF--

--LQ77YLfPrO/qF/pM
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC/hXKXaXGVTD0i/8RAlKvAJ0SSPBxWDZTa/u8ghIV2CS7EUJUxACdGup3
GWc00A1NoQnK9ZnUo3fwQ1I=
=xecX
-----END PGP SIGNATURE-----

--LQ77YLfPrO/qF/pM--
