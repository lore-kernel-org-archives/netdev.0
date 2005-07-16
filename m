From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] convert nfmark and conntrack mark to 32bit
Date: Sat, 16 Jul 2005 21:40:30 +0000 (UTC)
Message-ID: <20050717214223.GA13434@rama.risq.ericsson.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3V7upXqbjpZ4EhLz"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
Date: Sun, 17 Jul 2005 23:42:23 +0200
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


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply:

As discussed at netconf'05, we convert nfmark and conntrack-mark to be
32bits even on 64bit architectures.=20

Signed-off-by: Harald Welte <laforge@netfilter.org>

diff --git a/include/linux/netfilter_ipv4/ip_conntrack.h b/include/linux/ne=
tfilter_ipv4/ip_conntrack.h
--- a/include/linux/netfilter_ipv4/ip_conntrack.h
+++ b/include/linux/netfilter_ipv4/ip_conntrack.h
@@ -171,7 +171,7 @@ struct ip_conntrack
 #endif /* CONFIG_IP_NF_NAT_NEEDED */
=20
 #if defined(CONFIG_IP_NF_CONNTRACK_MARK)
-	unsigned long mark;
+	u_int32_t mark;
 #endif
=20
 	/* Traversed often, so hopefully in different cacheline to top */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -259,7 +259,7 @@ struct sk_buff {
=20
 	void			(*destructor)(struct sk_buff *skb);
 #ifdef CONFIG_NETFILTER
-	unsigned long		nfmark;
+	__u32			nfmark;
 	__u32			nfcache;
 	__u32			nfctinfo;
 	struct nf_conntrack	*nfct;
diff --git a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfil=
ter/ip_conntrack_standalone.c
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c
@@ -185,7 +185,7 @@ static int ct_seq_show(struct seq_file *
 			return -ENOSPC;
=20
 #if defined(CONFIG_IP_NF_CONNTRACK_MARK)
-	if (seq_printf(s, "mark=3D%lu ", conntrack->mark))
+	if (seq_printf(s, "mark=3D%u ", conntrack->mark))
 		return -ENOSPC;
 #endif
=20
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CL=
USTERIP.c
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -367,7 +367,7 @@ target(struct sk_buff **pskb,
 #ifdef DEBUG_CLUSTERP
 	DUMP_TUPLE(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
 #endif
-	DEBUGP("hash=3D%u ct_hash=3D%lu ", hash, ct->mark);
+	DEBUGP("hash=3D%u ct_hash=3D%u ", hash, ct->mark);
 	if (!clusterip_responsible(cipinfo->config, hash)) {
 		DEBUGP("not responsible\n");
 		return NF_DROP;
diff --git a/net/ipv4/netfilter/ipt_CONNMARK.c b/net/ipv4/netfilter/ipt_CON=
NMARK.c
--- a/net/ipv4/netfilter/ipt_CONNMARK.c
+++ b/net/ipv4/netfilter/ipt_CONNMARK.c
@@ -40,9 +40,9 @@ target(struct sk_buff **pskb,
        void *userinfo)
 {
 	const struct ipt_connmark_target_info *markinfo =3D targinfo;
-	unsigned long diff;
-	unsigned long nfmark;
-	unsigned long newmark;
+	u_int32_t diff;
+	u_int32_t nfmark;
+	u_int32_t newmark;
=20
 	enum ip_conntrack_info ctinfo;
 	struct ip_conntrack *ct =3D ip_conntrack_get((*pskb), &ctinfo);
@@ -94,6 +94,11 @@ checkentry(const char *tablename,
 	    }
 	}
=20
+	if (matchinfo->mark > 0xffffffff || matchinfo->mask > 0xffffffff) {
+		printk(KERN_WARNING "CONNMARK: Only supports 32bit mark\n");
+		return 0;
+	}
+
 	return 1;
 }
=20
diff --git a/net/ipv4/netfilter/ipt_MARK.c b/net/ipv4/netfilter/ipt_MARK.c
--- a/net/ipv4/netfilter/ipt_MARK.c
+++ b/net/ipv4/netfilter/ipt_MARK.c
@@ -76,6 +76,8 @@ checkentry_v0(const char *tablename,
 	      unsigned int targinfosize,
 	      unsigned int hook_mask)
 {
+	struct ipt_mark_target_info *markinfo =3D targinfo;
+
 	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_mark_target_info))) {
 		printk(KERN_WARNING "MARK: targinfosize %u !=3D %Zu\n",
 		       targinfosize,
@@ -88,6 +90,11 @@ checkentry_v0(const char *tablename,
 		return 0;
 	}
=20
+	if (markinfo->mark > 0xffffffff) {
+		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
+		return 0;
+	}
+
 	return 1;
 }
=20
@@ -120,6 +127,11 @@ checkentry_v1(const char *tablename,
 		return 0;
 	}
=20
+	if (markinfo->mark > 0xffffffff) {
+		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
+		return 0;
+	}
+
 	return 1;
 }
=20
diff --git a/net/ipv4/netfilter/ipt_connmark.c b/net/ipv4/netfilter/ipt_con=
nmark.c
--- a/net/ipv4/netfilter/ipt_connmark.c
+++ b/net/ipv4/netfilter/ipt_connmark.c
@@ -54,9 +54,16 @@ checkentry(const char *tablename,
 	   unsigned int matchsize,
 	   unsigned int hook_mask)
 {
+	struct ipt_connmark_info *cm =3D=20
+				(struct ipt_connmark_info *)matchinfo;
 	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_connmark_info)))
 		return 0;
=20
+	if (cm->mark > 0xffffffff || cm->mask > 0xffffffff) {
+		printk(KERN_WARNING "connmark: only support 32bit mark\n");
+		return 0;
+	}
+
 	return 1;
 }
=20
diff --git a/net/ipv4/netfilter/ipt_mark.c b/net/ipv4/netfilter/ipt_mark.c
--- a/net/ipv4/netfilter/ipt_mark.c
+++ b/net/ipv4/netfilter/ipt_mark.c
@@ -37,9 +37,16 @@ checkentry(const char *tablename,
            unsigned int matchsize,
            unsigned int hook_mask)
 {
+	struct ipt_mark_info *minfo =3D (struct ipt_mark_info *) matchinfo;
+
 	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_mark_info)))
 		return 0;
=20
+	if (minfo->mark > 0xffffffff || minfo->mask > 0xffffffff) {
+		printk(KERN_WARNING "mark: only supports 32bit mark\n");
+		return 0;
+	}
+
 	return 1;
 }
=20
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--3V7upXqbjpZ4EhLz
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC2tC+XaXGVTD0i/8RApyEAKCkmJ6+P1CgrvDlShVRkNMeYG4LwACfTrdw
TkUlrTPsL8GL9V/QJbBxT+k=
=9jEK
-----END PGP SIGNATURE-----

--3V7upXqbjpZ4EhLz--
