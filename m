From: Harald Welte <laforge@netfilter.org>
Subject: [NETFILTER] fix conntrack event cache deadlock
Date: Thu, 22 Sep 2005 16:35:15 +0200
Message-ID: <20050922143515.GD8917@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yudcn1FV7Hsu/q59"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	kaber@trash.net
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


--yudcn1FV7Hsu/q59
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply the following fix. =20

(Bug #2 exists even in pre-2.6.14 kernels, but I don't think it's such a
serious problem, so I won't provide a fix for -stable.)

[NETFILTER] Fix conntrack event cache deadlock/oops

This patch fixes a number of bugs.  It cannot be reasonably split up in
multiple fixes, since all bugs interact with each other and affect the same
function:

Bug #1:
The event cache code cannot be called while a lock is held.  Therefore, the
call to ip_conntrack_event_cache() within ip_ct_refresh_acct() needs to be
moved outside of the locked section.  This fixes a number of 2.6.14-rcX
oops and deadlock reports.

Bug #2:
We used to call ct_add_counters() for unconfirmed connections without
holding a lock.  Since the add operations are not atomic, we could race
with another CPU.

Bug #3:
ip_ct_refresh_acct() lost REFRESH events in some cases where refresh
(and the corresponding event) are desired, but no accounting shall be
performed.  Both, evenst and accounting implicitly depended on the skb
parameter bein non-null.   We now re-introduce a non-accounting
"ip_ct_refresh()" variant to explicitly state the desired behaviour.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 0410f33b62b892379270539b189577126ea56ffe
tree 2031dcce6de02d10246d9fdc390e11e8f29a6c7b
parent fa304068f77ddce6ff01d48f1033d176a6e0ab5f
author Harald Welte <laforge@netfilter.org> Do, 22 Sep 2005 16:30:22 +0200
committer Harald Welte <laforge@netfilter.org> Do, 22 Sep 2005 16:30:22 +02=
00

 include/linux/netfilter_ipv4/ip_conntrack.h   |   25 +++++++++++--
 net/ipv4/netfilter/ip_conntrack_amanda.c      |    2 +
 net/ipv4/netfilter/ip_conntrack_core.c        |   49 +++++++++++++--------=
----
 net/ipv4/netfilter/ip_conntrack_helper_pptp.c |    1 -
 net/ipv4/netfilter/ip_conntrack_netbios_ns.c  |    2 +
 net/ipv4/netfilter/ip_conntrack_standalone.c  |    2 +
 6 files changed, 49 insertions(+), 32 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ip_conntrack.h b/include/linux/ne=
tfilter_ipv4/ip_conntrack.h
--- a/include/linux/netfilter_ipv4/ip_conntrack.h
+++ b/include/linux/netfilter_ipv4/ip_conntrack.h
@@ -332,11 +332,28 @@ extern void need_ip_conntrack(void);
 extern int invert_tuplepr(struct ip_conntrack_tuple *inverse,
 			  const struct ip_conntrack_tuple *orig);
=20
+extern void __ip_ct_refresh_acct(struct ip_conntrack *ct,
+			         enum ip_conntrack_info ctinfo,
+			         const struct sk_buff *skb,
+			         unsigned long extra_jiffies,
+				 int do_acct);
+
+/* Refresh conntrack for this many jiffies and do accounting */
+static inline void ip_ct_refresh_acct(struct ip_conntrack *ct,=20
+				      enum ip_conntrack_info ctinfo,
+				      const struct sk_buff *skb,
+				      unsigned long extra_jiffies)
+{
+	__ip_ct_refresh_acct(ct, ctinfo, skb, extra_jiffies, 1);
+}
+
 /* Refresh conntrack for this many jiffies */
-extern void ip_ct_refresh_acct(struct ip_conntrack *ct,
-			       enum ip_conntrack_info ctinfo,
-			       const struct sk_buff *skb,
-			       unsigned long extra_jiffies);
+static inline void ip_ct_refresh(struct ip_conntrack *ct,
+				 const struct sk_buff *skb,
+				 unsigned long extra_jiffies)
+{
+	__ip_ct_refresh_acct(ct, 0, skb, extra_jiffies, 0);
+}
=20
 /* These are for NAT.  Icky. */
 /* Update TCP window tracking data when NAT mangles the packet */
diff --git a/net/ipv4/netfilter/ip_conntrack_amanda.c b/net/ipv4/netfilter/=
ip_conntrack_amanda.c
--- a/net/ipv4/netfilter/ip_conntrack_amanda.c
+++ b/net/ipv4/netfilter/ip_conntrack_amanda.c
@@ -65,7 +65,7 @@ static int help(struct sk_buff **pskb,
=20
 	/* increase the UDP timeout of the master connection as replies from
 	 * Amanda clients to the server can be quite delayed */
-	ip_ct_refresh_acct(ct, ctinfo, NULL, master_timeout * HZ);
+	ip_ct_refresh(ct, *pskb, master_timeout * HZ);
=20
 	/* No data? */
 	dataoff =3D (*pskb)->nh.iph->ihl*4 + sizeof(struct udphdr);
diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip=
_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -1112,45 +1112,46 @@ void ip_conntrack_helper_unregister(stru
 	synchronize_net();
 }
=20
-static inline void ct_add_counters(struct ip_conntrack *ct,
-				   enum ip_conntrack_info ctinfo,
-				   const struct sk_buff *skb)
-{
-#ifdef CONFIG_IP_NF_CT_ACCT
-	if (skb) {
-		ct->counters[CTINFO2DIR(ctinfo)].packets++;
-		ct->counters[CTINFO2DIR(ctinfo)].bytes +=3D=20
-					ntohs(skb->nh.iph->tot_len);
-	}
-#endif
-}
-
-/* Refresh conntrack for this many jiffies and do accounting (if skb !=3D =
NULL) */
-void ip_ct_refresh_acct(struct ip_conntrack *ct,=20
+/* Refresh conntrack for this many jiffies and do accounting if do_acct is=
 1 */
+void __ip_ct_refresh_acct(struct ip_conntrack *ct,=20
 		        enum ip_conntrack_info ctinfo,
 			const struct sk_buff *skb,
-			unsigned long extra_jiffies)
+			unsigned long extra_jiffies,
+			int do_acct)
 {
+	int do_event =3D 0;
+
 	IP_NF_ASSERT(ct->timeout.data =3D=3D (unsigned long)ct);
+	IP_NF_ASSERT(skb);
+
+	write_lock_bh(&ip_conntrack_lock);
=20
 	/* If not in hash table, timer will not be active yet */
 	if (!is_confirmed(ct)) {
 		ct->timeout.expires =3D extra_jiffies;
-		ct_add_counters(ct, ctinfo, skb);
+		do_event =3D 1;
 	} else {
-		write_lock_bh(&ip_conntrack_lock);
 		/* Need del_timer for race avoidance (may already be dying). */
 		if (del_timer(&ct->timeout)) {
 			ct->timeout.expires =3D jiffies + extra_jiffies;
 			add_timer(&ct->timeout);
-			/* FIXME: We loose some REFRESH events if this function
-			 * is called without an skb.  I'll fix this later -HW */
-			if (skb)
-				ip_conntrack_event_cache(IPCT_REFRESH, skb);
+			do_event =3D 1;
 		}
-		ct_add_counters(ct, ctinfo, skb);
-		write_unlock_bh(&ip_conntrack_lock);
 	}
+
+#ifdef CONFIG_IP_NF_CT_ACCT
+	if (do_acct) {
+		ct->counters[CTINFO2DIR(ctinfo)].packets++;
+		ct->counters[CTINFO2DIR(ctinfo)].bytes +=3D=20
+						ntohs(skb->nh.iph->tot_len);
+	}
+#endif
+
+	write_unlock_bh(&ip_conntrack_lock);
+
+	/* must be unlocked when calling event cache */
+	if (do_event)
+		ip_conntrack_event_cache(IPCT_REFRESH, skb);
 }
=20
 #if defined(CONFIG_IP_NF_CONNTRACK_NETLINK) || \
diff --git a/net/ipv4/netfilter/ip_conntrack_helper_pptp.c b/net/ipv4/netfi=
lter/ip_conntrack_helper_pptp.c
--- a/net/ipv4/netfilter/ip_conntrack_helper_pptp.c
+++ b/net/ipv4/netfilter/ip_conntrack_helper_pptp.c
@@ -172,7 +172,6 @@ static int destroy_sibling_or_exp(const=20
 		DEBUGP("setting timeout of conntrack %p to 0\n", sibling);
 		sibling->proto.gre.timeout =3D 0;
 		sibling->proto.gre.stream_timeout =3D 0;
-		/* refresh_acct will not modify counters if skb =3D=3D NULL */
 		if (del_timer(&sibling->timeout))
 			sibling->timeout.function((unsigned long)sibling);
 		ip_conntrack_put(sibling);
diff --git a/net/ipv4/netfilter/ip_conntrack_netbios_ns.c b/net/ipv4/netfil=
ter/ip_conntrack_netbios_ns.c
--- a/net/ipv4/netfilter/ip_conntrack_netbios_ns.c
+++ b/net/ipv4/netfilter/ip_conntrack_netbios_ns.c
@@ -91,7 +91,7 @@ static int help(struct sk_buff **pskb,
 	ip_conntrack_expect_related(exp);
 	ip_conntrack_expect_put(exp);
=20
-	ip_ct_refresh_acct(ct, ctinfo, NULL, timeout * HZ);
+	ip_ct_refresh(ct, *pskb, timeout * HZ);
 out:
 	return NF_ACCEPT;
 }
diff --git a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfil=
ter/ip_conntrack_standalone.c
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c
@@ -989,7 +989,7 @@ EXPORT_SYMBOL(need_ip_conntrack);
 EXPORT_SYMBOL(ip_conntrack_helper_register);
 EXPORT_SYMBOL(ip_conntrack_helper_unregister);
 EXPORT_SYMBOL(ip_ct_iterate_cleanup);
-EXPORT_SYMBOL(ip_ct_refresh_acct);
+EXPORT_SYMBOL(__ip_ct_refresh_acct);
=20
 EXPORT_SYMBOL(ip_conntrack_expect_alloc);
 EXPORT_SYMBOL(ip_conntrack_expect_put);
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--yudcn1FV7Hsu/q59
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDMsEjXaXGVTD0i/8RAuT9AKClv7kRlrwf2x7qyjYfO6w5DaXC3gCgk+OD
2TiSHXxeUkbHGQjk9eCVvXY=
=mIhu
-----END PGP SIGNATURE-----

--yudcn1FV7Hsu/q59--
