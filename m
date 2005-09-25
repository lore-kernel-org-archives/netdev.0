From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH/RFC] [NETFILTER]: Fix invalid module autoloading by
	splitting iptable_nat
Date: Sun, 25 Sep 2005 17:07:55 +0200
Message-ID: <20050925150755.GK731@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1WjU1Nho6JDYiYBr"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@sunbeam.de.gnumonks.org>
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


--1WjU1Nho6JDYiYBr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Patrick, Dave,

I think we really need a solution for the last (known) remaining
dependency problem with 2.6.14.  Please see the description
below.  I _think_ the patch is fine, at least I couldn't find any case
where we could leak anything by splitting the code in two modules.

There's a slight semantic change, though.  If the user unloads
iptable_nat, all existing connections (including their configured NAT
mappings) will continue to work.  Only when ip_nat.ko is unloaded, the
NAT mappings are evicted from the conntrack table.  I like it that way,
since it's logical.

If Patrick has no objections, I vote for inclusion in 2.6.14.

Thanks!


[NETFILTER]: Fix invalid module autoloading by splitting iptable_nat

When you've enabled conntrack and NAT as a module (standard case in all
distributions), and you've also enabled the new conntrack netlink
interface, loading ip_conntrack_netlink.ko will auto-load iptable_nat.ko.
This causes a huge performance penalty, since for every packet you iterate
the nat code, even if you don't want it.

This patch splits iptable_nat.ko into the NAT core (ip_nat.ko) and the
iptables frontend (iptable_nat.ko).  Threfore, ip_conntrack_netlink.ko will
only pull ip_nat.ko, but not the frontend.  ip_nat.ko will "only" allocate
some resources, but not affect runtime performance.

This separation is also a nice step in anticipation of new packet filters
(nf-hipac, ipset, pkttables) being able to use the NAT core.

---
commit 5ad0f056192213b2f6ac9910f754be9e6abea574
tree b06756b046853df61b39139ae58d49d0ca84274c
parent 1699521ab4e23ba4dd9f8bdd894393b8e109fe43
author Harald Welte <laforge@hanuman.de.gnumonks.org> Sun, 25 Sep 2005 17:0=
1:38 +0200
committer Harald Welte <laforge@hanuman.de.gnumonks.org> Sun, 25 Sep 2005 1=
7:01:38 +0200

 include/linux/netfilter_ipv4/ip_nat_core.h |   12 ++++------
 net/ipv4/netfilter/Makefile                |    5 ++--
 net/ipv4/netfilter/ip_nat_core.c           |   35 +++++++++++++++++++-----=
----
 net/ipv4/netfilter/ip_nat_helper.c         |    4 +++
 net/ipv4/netfilter/ip_nat_standalone.c     |   25 +++-----------------
 5 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ip_nat_core.h b/include/linux/net=
filter_ipv4/ip_nat_core.h
--- a/include/linux/netfilter_ipv4/ip_nat_core.h
+++ b/include/linux/netfilter_ipv4/ip_nat_core.h
@@ -5,16 +5,14 @@
=20
 /* This header used to share core functionality between the standalone
    NAT module, and the compatibility layer's use of NAT for masquerading. =
*/
-extern int ip_nat_init(void);
-extern void ip_nat_cleanup(void);
=20
-extern unsigned int nat_packet(struct ip_conntrack *ct,
+extern unsigned int ip_nat_packet(struct ip_conntrack *ct,
 			       enum ip_conntrack_info conntrackinfo,
 			       unsigned int hooknum,
 			       struct sk_buff **pskb);
=20
-extern int icmp_reply_translation(struct sk_buff **pskb,
-				  struct ip_conntrack *ct,
-				  enum ip_nat_manip_type manip,
-				  enum ip_conntrack_dir dir);
+extern int ip_nat_icmp_reply_translation(struct sk_buff **pskb,
+					 struct ip_conntrack *ct,
+					 enum ip_nat_manip_type manip,
+					 enum ip_conntrack_dir dir);
 #endif /* _IP_NAT_CORE_H */
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -4,7 +4,8 @@
=20
 # objects for the standalone - connection tracking / NAT
 ip_conntrack-objs	:=3D ip_conntrack_standalone.o ip_conntrack_core.o ip_co=
nntrack_proto_generic.o ip_conntrack_proto_tcp.o ip_conntrack_proto_udp.o i=
p_conntrack_proto_icmp.o
-iptable_nat-objs	:=3D ip_nat_standalone.o ip_nat_rule.o ip_nat_core.o ip_n=
at_helper.o ip_nat_proto_unknown.o ip_nat_proto_tcp.o ip_nat_proto_udp.o ip=
_nat_proto_icmp.o
+ip_nat-objs	:=3D ip_nat_core.o ip_nat_helper.o ip_nat_proto_unknown.o ip_n=
at_proto_tcp.o ip_nat_proto_udp.o ip_nat_proto_icmp.o
+iptable_nat-objs	:=3D ip_nat_rule.o ip_nat_standalone.o
=20
 ip_conntrack_pptp-objs	:=3D ip_conntrack_helper_pptp.o ip_conntrack_proto_=
gre.o
 ip_nat_pptp-objs	:=3D ip_nat_helper_pptp.o ip_nat_proto_gre.o
@@ -40,7 +41,7 @@ obj-$(CONFIG_IP_NF_IPTABLES) +=3D ip_table
 # the three instances of ip_tables
 obj-$(CONFIG_IP_NF_FILTER) +=3D iptable_filter.o
 obj-$(CONFIG_IP_NF_MANGLE) +=3D iptable_mangle.o
-obj-$(CONFIG_IP_NF_NAT) +=3D iptable_nat.o
+obj-$(CONFIG_IP_NF_NAT) +=3D iptable_nat.o ip_nat.o
 obj-$(CONFIG_IP_NF_RAW) +=3D iptable_raw.o
=20
 # matches
diff --git a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_c=
ore.c
--- a/net/ipv4/netfilter/ip_nat_core.c
+++ b/net/ipv4/netfilter/ip_nat_core.c
@@ -74,12 +74,14 @@ ip_nat_proto_find_get(u_int8_t protonum)
=20
 	return p;
 }
+EXPORT_SYMBOL_GPL(ip_nat_proto_find_get);
=20
 void
 ip_nat_proto_put(struct ip_nat_protocol *p)
 {
 	module_put(p->me);
 }
+EXPORT_SYMBOL_GPL(ip_nat_proto_put);
=20
 /* We keep an extra hash for each conntrack, for fast searching. */
 static inline unsigned int
@@ -111,6 +113,7 @@ ip_nat_cheat_check(u_int32_t oldvalinv,=20
 	return csum_fold(csum_partial((char *)diffs, sizeof(diffs),
 				      oldcheck^0xFFFF));
 }
+EXPORT_SYMBOL(ip_nat_cheat_check);
=20
 /* Is this tuple already taken? (not by us) */
 int
@@ -127,6 +130,7 @@ ip_nat_used_tuple(const struct ip_conntr
 	invert_tuplepr(&reply, tuple);
 	return ip_conntrack_tuple_taken(&reply, ignored_conntrack);
 }
+EXPORT_SYMBOL(ip_nat_used_tuple);
=20
 /* If we source map this tuple so reply looks like reply_tuple, will
  * that meet the constraints of range. */
@@ -347,6 +351,7 @@ ip_nat_setup_info(struct ip_conntrack *c
=20
 	return NF_ACCEPT;
 }
+EXPORT_SYMBOL(ip_nat_setup_info);
=20
 /* Returns true if succeeded. */
 static int
@@ -387,10 +392,10 @@ manip_pkt(u_int16_t proto,
 }
=20
 /* Do packet manipulations according to ip_nat_setup_info. */
-unsigned int nat_packet(struct ip_conntrack *ct,
-			enum ip_conntrack_info ctinfo,
-			unsigned int hooknum,
-			struct sk_buff **pskb)
+unsigned int ip_nat_packet(struct ip_conntrack *ct,
+			   enum ip_conntrack_info ctinfo,
+			   unsigned int hooknum,
+			   struct sk_buff **pskb)
 {
 	enum ip_conntrack_dir dir =3D CTINFO2DIR(ctinfo);
 	unsigned long statusbit;
@@ -417,12 +422,13 @@ unsigned int nat_packet(struct ip_conntr
 	}
 	return NF_ACCEPT;
 }
+EXPORT_SYMBOL_GPL(ip_nat_packet);
=20
 /* Dir is direction ICMP is coming from (opposite to packet it contains) */
-int icmp_reply_translation(struct sk_buff **pskb,
-			   struct ip_conntrack *ct,
-			   enum ip_nat_manip_type manip,
-			   enum ip_conntrack_dir dir)
+int ip_nat_icmp_reply_translation(struct sk_buff **pskb,
+				  struct ip_conntrack *ct,
+				  enum ip_nat_manip_type manip,
+				  enum ip_conntrack_dir dir)
 {
 	struct {
 		struct icmphdr icmp;
@@ -509,6 +515,7 @@ int icmp_reply_translation(struct sk_buf
=20
 	return 1;
 }
+EXPORT_SYMBOL_GPL(ip_nat_icmp_reply_translation);
=20
 /* Protocol registration. */
 int ip_nat_protocol_register(struct ip_nat_protocol *proto)
@@ -525,6 +532,7 @@ int ip_nat_protocol_register(struct ip_n
 	write_unlock_bh(&ip_nat_lock);
 	return ret;
 }
+EXPORT_SYMBOL(ip_nat_protocol_register);
=20
 /* Noone stores the protocol anywhere; simply delete it. */
 void ip_nat_protocol_unregister(struct ip_nat_protocol *proto)
@@ -536,6 +544,7 @@ void ip_nat_protocol_unregister(struct i
 	/* Someone could be still looking at the proto in a bh. */
 	synchronize_net();
 }
+EXPORT_SYMBOL(ip_nat_protocol_unregister);
=20
 #if defined(CONFIG_IP_NF_CONNTRACK_NETLINK) || \
     defined(CONFIG_IP_NF_CONNTRACK_NETLINK_MODULE)
@@ -582,7 +591,7 @@ EXPORT_SYMBOL_GPL(ip_nat_port_nfattr_to_
 EXPORT_SYMBOL_GPL(ip_nat_port_range_to_nfattr);
 #endif
=20
-int __init ip_nat_init(void)
+static int __init ip_nat_init(void)
 {
 	size_t i;
=20
@@ -624,10 +633,14 @@ static int clean_nat(struct ip_conntrack
 	return 0;
 }
=20
-/* Not __exit: called from ip_nat_standalone.c:init_or_cleanup() --RR */
-void ip_nat_cleanup(void)
+static void __exit ip_nat_cleanup(void)
 {
 	ip_ct_iterate_cleanup(&clean_nat, NULL);
 	ip_conntrack_destroyed =3D NULL;
 	vfree(bysource);
 }
+
+MODULE_LICENSE("GPL");
+
+module_init(ip_nat_init);
+module_exit(ip_nat_cleanup);
diff --git a/net/ipv4/netfilter/ip_nat_helper.c b/net/ipv4/netfilter/ip_nat=
_helper.c
--- a/net/ipv4/netfilter/ip_nat_helper.c
+++ b/net/ipv4/netfilter/ip_nat_helper.c
@@ -199,6 +199,7 @@ ip_nat_mangle_tcp_packet(struct sk_buff=20
 	}
 	return 1;
 }
+EXPORT_SYMBOL(ip_nat_mangle_tcp_packet);
 		=09
 /* Generic function for mangling variable-length address changes inside
  * NATed UDP connections (like the CONNECT DATA XXXXX MESG XXXXX INDEX XXX=
XX
@@ -256,6 +257,7 @@ ip_nat_mangle_udp_packet(struct sk_buff=20
=20
 	return 1;
 }
+EXPORT_SYMBOL(ip_nat_mangle_udp_packet);
=20
 /* Adjust one found SACK option including checksum correction */
 static void
@@ -399,6 +401,7 @@ ip_nat_seq_adjust(struct sk_buff **pskb,
=20
 	return 1;
 }
+EXPORT_SYMBOL(ip_nat_seq_adjust);
=20
 /* Setup NAT on this expected conntrack so it follows master. */
 /* If we fail to get a free NAT slot, we'll get dropped on confirm */
@@ -425,3 +428,4 @@ void ip_nat_follow_master(struct ip_conn
 	/* hook doesn't matter, but it has to do destination manip */
 	ip_nat_setup_info(ct, &range, NF_IP_PRE_ROUTING);
 }
+EXPORT_SYMBOL(ip_nat_follow_master);
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip=
_nat_standalone.c
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -108,8 +108,8 @@ ip_nat_fn(unsigned int hooknum,
 	case IP_CT_RELATED:
 	case IP_CT_RELATED+IP_CT_IS_REPLY:
 		if ((*pskb)->nh.iph->protocol =3D=3D IPPROTO_ICMP) {
-			if (!icmp_reply_translation(pskb, ct, maniptype,
-						    CTINFO2DIR(ctinfo)))
+			if (!ip_nat_icmp_reply_translation(pskb, ct, maniptype,
+							   CTINFO2DIR(ctinfo)))
 				return NF_DROP;
 			else
 				return NF_ACCEPT;
@@ -152,7 +152,7 @@ ip_nat_fn(unsigned int hooknum,
 	}
=20
 	IP_NF_ASSERT(info);
-	return nat_packet(ct, ctinfo, hooknum, pskb);
+	return ip_nat_packet(ct, ctinfo, hooknum, pskb);
 }
=20
 static unsigned int
@@ -325,15 +325,10 @@ static int init_or_cleanup(int init)
 		printk("ip_nat_init: can't setup rules.\n");
 		goto cleanup_nothing;
 	}
-	ret =3D ip_nat_init();
-	if (ret < 0) {
-		printk("ip_nat_init: can't setup rules.\n");
-		goto cleanup_rule_init;
-	}
 	ret =3D nf_register_hook(&ip_nat_in_ops);
 	if (ret < 0) {
 		printk("ip_nat_init: can't register in hook.\n");
-		goto cleanup_nat;
+		goto cleanup_rule_init;
 	}
 	ret =3D nf_register_hook(&ip_nat_out_ops);
 	if (ret < 0) {
@@ -374,8 +369,6 @@ static int init_or_cleanup(int init)
 	nf_unregister_hook(&ip_nat_out_ops);
  cleanup_inops:
 	nf_unregister_hook(&ip_nat_in_ops);
- cleanup_nat:
-	ip_nat_cleanup();
  cleanup_rule_init:
 	ip_nat_rule_cleanup();
  cleanup_nothing:
@@ -395,14 +388,4 @@ static void __exit fini(void)
 module_init(init);
 module_exit(fini);
=20
-EXPORT_SYMBOL(ip_nat_setup_info);
-EXPORT_SYMBOL(ip_nat_protocol_register);
-EXPORT_SYMBOL(ip_nat_protocol_unregister);
-EXPORT_SYMBOL_GPL(ip_nat_proto_find_get);
-EXPORT_SYMBOL_GPL(ip_nat_proto_put);
-EXPORT_SYMBOL(ip_nat_cheat_check);
-EXPORT_SYMBOL(ip_nat_mangle_tcp_packet);
-EXPORT_SYMBOL(ip_nat_mangle_udp_packet);
-EXPORT_SYMBOL(ip_nat_used_tuple);
-EXPORT_SYMBOL(ip_nat_follow_master);
 MODULE_LICENSE("GPL");
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--1WjU1Nho6JDYiYBr
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDNr1LXaXGVTD0i/8RAvjJAKCn/qShk0RmMG3lXcK9po7rUADuhQCcCxvW
FXmJzt09o0hcYVpoY0GyXxo=
=iuZt
-----END PGP SIGNATURE-----

--1WjU1Nho6JDYiYBr--
