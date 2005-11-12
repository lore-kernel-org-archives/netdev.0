From: Harald Welte <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org>
Subject: Re: Re: [PATCH] ebtables: Port ebt_[u]log.c to nf[netlink]_log
Date: Sat, 12 Nov 2005 10:49:36 +0100
Message-ID: <20051112094936.GA27644@sunbeam.de.gnumonks.org>
References: <20051007234903.GR4450@rama.customers.eurospot.com> <1129571999.3383.6.camel@localhost.localdomain> <20051018085853.GG20338@sunbeam.de.gnumonks.org> <1129648337.4504.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="x+6KMIRAuhnl3hBn"
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1129648337.4504.3.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ebtables-devel>
List-Id: netdev.vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Sorry for this extremely delayed follow-up, but I just noticed that this
is the only patch in my 'master' branch that is not yet merged mainline.

On Tue, Oct 18, 2005 at 03:12:17PM +0000, Bart De Schuymer wrote:
> OK, but please fix the typo then. Shouldn't a similar comment be in
> ebt_ulog?

I've addressed both of your concerns (typo and similar comment/message
in ebt_ulog).

If you deem the attached patch fine, please submit it to davem.


[NETFILTER] ebtables: Support nf_log API from ebt_log and ebt_ulog

This makes ebt_log and ebt_ulog use the new nf_log api.  This enables the
bridging packet filter to log packets e.g. via nfnetlink_log.

Signed-off-by: Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>

diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -196,9 +196,13 @@ config BRIDGE_EBT_LOG
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
 config BRIDGE_EBT_ULOG
-	tristate "ebt: ulog support"
+	tristate "ebt: ulog support (OBSOLETE)"
 	depends on BRIDGE_NF_EBTABLES
 	help
+	  This option enables the old bridge-specific "ebt_ulog" implementation
+	  which has been obsoleted by the new "nfnetlink_log" code (see
+	  CONFIG_NETFILTER_NETLINK_LOG).
+
 	  This option adds the ulog watcher, that you can use in any rule
 	  in any ebtables table. The packet is passed to a userspace
 	  logging daemon using netlink multicast sockets. This differs
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -3,6 +3,7 @@
  *
  *	Authors:
  *	Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
+ *	Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
  *
  *  April, 2002
  *
@@ -10,6 +11,7 @@
=20
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_log.h>
+#include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/ip.h>
 #include <linux/if_arp.h>
@@ -55,17 +57,19 @@ static void print_MAC(unsigned char *p)
 }
=20
 #define myNIPQUAD(a) a[0], a[1], a[2], a[3]
-static void ebt_log(const struct sk_buff *skb, unsigned int hooknr,
-   const struct net_device *in, const struct net_device *out,
-   const void *data, unsigned int datalen)
+static void
+ebt_log_packet(unsigned int pf, unsigned int hooknum,
+   const struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out, const struct nf_loginfo *loginfo,
+   const char *prefix)
 {
-	struct ebt_log_info *info =3D (struct ebt_log_info *)data;
 	char level_string[4] =3D "< >";
+	unsigned int bitmask;
=20
-	level_string[1] =3D '0' + info->loglevel;
+	level_string[1] =3D '0' + loginfo->u.log.level;
 	spin_lock_bh(&ebt_log_lock);
 	printk(level_string);
-	printk("%s IN=3D%s OUT=3D%s ", info->prefix, in ? in->name : "",
+	printk("%s IN=3D%s OUT=3D%s ", prefix, in ? in->name : "",
 	   out ? out->name : "");
=20
 	printk("MAC source =3D ");
@@ -75,7 +79,12 @@ static void ebt_log(const struct sk_buff
=20
 	printk("proto =3D 0x%04x", ntohs(eth_hdr(skb)->h_proto));
=20
-	if ((info->bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto =3D=3D
+	if (loginfo->type =3D=3D NF_LOG_TYPE_LOG)
+		bitmask =3D loginfo->u.log.logflags;
+	else
+		bitmask =3D NF_LOG_MASK;
+
+	if ((bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto =3D=3D
 	   htons(ETH_P_IP)){
 		struct iphdr _iph, *ih;
=20
@@ -104,7 +113,7 @@ static void ebt_log(const struct sk_buff
 		goto out;
 	}
=20
-	if ((info->bitmask & EBT_LOG_ARP) &&
+	if ((bitmask & EBT_LOG_ARP) &&
 	    ((eth_hdr(skb)->h_proto =3D=3D htons(ETH_P_ARP)) ||
 	     (eth_hdr(skb)->h_proto =3D=3D htons(ETH_P_RARP)))) {
 		struct arphdr _arph, *ah;
@@ -144,6 +153,21 @@ static void ebt_log(const struct sk_buff
 out:
 	printk("\n");
 	spin_unlock_bh(&ebt_log_lock);
+
+}
+
+static void ebt_log(const struct sk_buff *skb, unsigned int hooknr,
+   const struct net_device *in, const struct net_device *out,
+   const void *data, unsigned int datalen)
+{
+	struct ebt_log_info *info =3D (struct ebt_log_info *)data;
+	struct nf_loginfo li;
+
+	li.type =3D NF_LOG_TYPE_LOG;
+	li.u.log.level =3D info->loglevel;
+	li.u.log.logflags =3D info->bitmask;
+
+	nf_log_packet(PF_BRIDGE, hooknr, skb, in, out, &li, info->prefix);
 }
=20
 static struct ebt_watcher log =3D
@@ -154,13 +178,32 @@ static struct ebt_watcher log =3D
 	.me		=3D THIS_MODULE,
 };
=20
+static struct nf_logger ebt_log_logger =3D {
+	.name 		=3D "ebt_log",
+	.logfn		=3D &ebt_log_packet,
+	.me		=3D THIS_MODULE,
+};
+
 static int __init init(void)
 {
-	return ebt_register_watcher(&log);
+	int ret;
+
+	ret =3D ebt_register_watcher(&log);
+	if (ret < 0)
+		return ret;
+	if (nf_log_register(PF_BRIDGE, &ebt_log_logger) < 0) {
+		printk(KERN_WARNING "ebt_log: not logging via system console "
+		       "since somebody else already registered for PF_INET\n");
+		/* we cannot make module load fail here, since otherwise=20
+		 * ebtables userspace would abort */
+	}
+
+	return 0;
 }
=20
 static void __exit fini(void)
 {
+	nf_log_unregister_logger(&ebt_log_logger);
 	ebt_unregister_watcher(&log);
 }
=20
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulo=
g.c
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -3,6 +3,7 @@
  *
  *	Authors:
  *	Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
+ *	Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
  *
  *  November, 2004
  *
@@ -115,14 +116,13 @@ static struct sk_buff *ulog_alloc_skb(un
 	return skb;
 }
=20
-static void ebt_ulog(const struct sk_buff *skb, unsigned int hooknr,
+static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
-   const void *data, unsigned int datalen)
+   const struct ebt_ulog_info *uloginfo, const char *prefix)
 {
 	ebt_ulog_packet_msg_t *pm;
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
-	struct ebt_ulog_info *uloginfo =3D (struct ebt_ulog_info *)data;
 	unsigned int group =3D uloginfo->nlgroup;
 	ebt_ulog_buff_t *ub =3D &ulog_buffers[group];
 	spinlock_t *lock =3D &ub->lock;
@@ -216,6 +216,39 @@ alloc_failure:
 	goto unlock;
 }
=20
+/* this function is registered with the netfilter core */
+static void ebt_log_packet(unsigned int pf, unsigned int hooknum,
+   const struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out, const struct nf_loginfo *li,
+   const char *prefix)
+{
+	struct ebt_ulog_info loginfo;
+
+	if (!li || li->type !=3D NF_LOG_TYPE_ULOG) {
+		loginfo.nlgroup =3D EBT_ULOG_DEFAULT_NLGROUP;
+		loginfo.cprange =3D 0;
+		loginfo.qthreshold =3D EBT_ULOG_DEFAULT_QTHRESHOLD;
+		loginfo.prefix[0] =3D '\0';
+	} else {
+		loginfo.nlgroup =3D li->u.ulog.group;
+		loginfo.cprange =3D li->u.ulog.copy_len;
+		loginfo.qthreshold =3D li->u.ulog.qthreshold;
+		strlcpy(loginfo.prefix, prefix, sizeof(loginfo.prefix));
+	}
+
+	ebt_ulog_packet(hooknum, skb, in, out, &loginfo, prefix);
+}
+
+static void ebt_ulog(const struct sk_buff *skb, unsigned int hooknr,
+   const struct net_device *in, const struct net_device *out,
+   const void *data, unsigned int datalen)
+{
+	struct ebt_ulog_info *uloginfo =3D (struct ebt_ulog_info *)data;
+
+	ebt_ulog_packet(hooknr, skb, in, out, uloginfo, NULL);
+}
+
+
 static int ebt_ulog_check(const char *tablename, unsigned int hookmask,
    const struct ebt_entry *e, void *data, unsigned int datalen)
 {
@@ -240,6 +273,12 @@ static struct ebt_watcher ulog =3D {
 	.me		=3D THIS_MODULE,
 };
=20
+static struct nf_logger ebt_ulog_logger =3D {
+	.name		=3D EBT_ULOG_WATCHER,
+	.logfn		=3D &ebt_log_packet,
+	.me		=3D THIS_MODULE,
+};
+
 static int __init init(void)
 {
 	int i, ret =3D 0;
@@ -265,6 +304,13 @@ static int __init init(void)
 	else if ((ret =3D ebt_register_watcher(&ulog)))
 		sock_release(ebtulognl->sk_socket);
=20
+	if (nf_log_register(PF_BRIDGE, &ebt_ulog_logger) < 0) {
+		printk(KERN_WARNING "ebt_ulog: not logging via ulog "
+		       "since somebody else already registered for PF_BRIDGE\n");
+		/* we cannot make module load fail here, since otherwise
+		 * ebtables userspace would abort */
+	}
+
 	return ret;
 }
=20
@@ -273,6 +319,7 @@ static void __exit fini(void)
 	ebt_ulog_buff_t *ub;
 	int i;
=20
+	nf_log_unregister_logger(&ebt_ulog_logger);
 	ebt_unregister_watcher(&ulog);
 	for (i =3D 0; i < EBT_ULOG_MAXNLGROUPS; i++) {
 		ub =3D &ulog_buffers[i];
--=20
- Harald Welte <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--x+6KMIRAuhnl3hBn
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDdbqwXaXGVTD0i/8RAr1EAKCO99XC3sWXb7foQdaMYQinVY6UcQCgtDOm
qC0q9zafKsZvaFAQaDD8qH8=
=dUvn
-----END PGP SIGNATURE-----

--x+6KMIRAuhnl3hBn--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
