From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Subject: [PATCH] ebtables: port ebt*[u]log.c to nf[netlink]_log
Date: Tue, 15 Nov 2005 18:21:21 +0000
Message-ID: <1132078881.3464.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Hi Dave,

Below is a patch from Harald, slightly altered by me to merge some
printk's.

Please apply,
Bart


[NETFILTER] ebtables: Support nf_log API from ebt_log and ebt_ulog

This makes ebt_log and ebt_ulog use the new nf_log api.  This enables
the bridging packet filter to log packets e.g. via nfnetlink_log.

Signed-off-by: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Signed-off-by: Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>


--- linux-2.6.14.2/net/bridge/netfilter/Kconfig.old	2005-11-15 18:00:10.000000000 +0000
+++ linux-2.6.14.2/net/bridge/netfilter/Kconfig	2005-11-15 18:00:24.891607224 +0000
@@ -196,9 +196,13 @@ config BRIDGE_EBT_LOG
 	  To compile it as a module, choose M here.  If unsure, say N.
 
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
--- linux-2.6.14.2/net/bridge/netfilter/ebt_log.c.old	2005-11-15 18:00:04.000000000 +0000
+++ linux-2.6.14.2/net/bridge/netfilter/ebt_log.c	2005-11-15 18:05:38.000000000 +0000
@@ -3,6 +3,7 @@
  *
  *	Authors:
  *	Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
+ *	Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
  *
  *  April, 2002
  *
@@ -10,6 +11,7 @@
 
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_log.h>
+#include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/ip.h>
 #include <linux/if_arp.h>
@@ -55,27 +57,30 @@ static void print_MAC(unsigned char *p)
 }
 
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
-	struct ebt_log_info *info = (struct ebt_log_info *)data;
-	char level_string[4] = "< >";
+	unsigned int bitmask;
 
-	level_string[1] = '0' + info->loglevel;
 	spin_lock_bh(&ebt_log_lock);
-	printk(level_string);
-	printk("%s IN=%s OUT=%s ", info->prefix, in ? in->name : "",
-	   out ? out->name : "");
+	printk("<%c>%s IN=%s OUT=%s MAC source = ", '0' + loginfo->u.log.level,
+	       prefix, in ? in->name : "", out ? out->name : "");
 
-	printk("MAC source = ");
 	print_MAC(eth_hdr(skb)->h_source);
 	printk("MAC dest = ");
 	print_MAC(eth_hdr(skb)->h_dest);
 
 	printk("proto = 0x%04x", ntohs(eth_hdr(skb)->h_proto));
 
-	if ((info->bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto ==
+	if (loginfo->type == NF_LOG_TYPE_LOG)
+		bitmask = loginfo->u.log.logflags;
+	else
+		bitmask = NF_LOG_MASK;
+
+	if ((bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto ==
 	   htons(ETH_P_IP)){
 		struct iphdr _iph, *ih;
 
@@ -84,10 +89,9 @@ static void ebt_log(const struct sk_buff
 			printk(" INCOMPLETE IP header");
 			goto out;
 		}
-		printk(" IP SRC=%u.%u.%u.%u IP DST=%u.%u.%u.%u,",
-		   NIPQUAD(ih->saddr), NIPQUAD(ih->daddr));
-		printk(" IP tos=0x%02X, IP proto=%d", ih->tos,
-		       ih->protocol);
+		printk(" IP SRC=%u.%u.%u.%u IP DST=%u.%u.%u.%u, IP "
+		       "tos=0x%02X, IP proto=%d", NIPQUAD(ih->saddr),
+		       NIPQUAD(ih->daddr), ih->tos, ih->protocol);
 		if (ih->protocol == IPPROTO_TCP ||
 		    ih->protocol == IPPROTO_UDP) {
 			struct tcpudphdr _ports, *pptr;
@@ -104,7 +108,7 @@ static void ebt_log(const struct sk_buff
 		goto out;
 	}
 
-	if ((info->bitmask & EBT_LOG_ARP) &&
+	if ((bitmask & EBT_LOG_ARP) &&
 	    ((eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) ||
 	     (eth_hdr(skb)->h_proto == htons(ETH_P_RARP)))) {
 		struct arphdr _arph, *ah;
@@ -144,6 +148,21 @@ static void ebt_log(const struct sk_buff
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
+	struct ebt_log_info *info = (struct ebt_log_info *)data;
+	struct nf_loginfo li;
+
+	li.type = NF_LOG_TYPE_LOG;
+	li.u.log.level = info->loglevel;
+	li.u.log.logflags = info->bitmask;
+
+	nf_log_packet(PF_BRIDGE, hooknr, skb, in, out, &li, info->prefix);
 }
 
 static struct ebt_watcher log =
@@ -154,13 +173,32 @@ static struct ebt_watcher log =
 	.me		= THIS_MODULE,
 };
 
+static struct nf_logger ebt_log_logger = {
+	.name 		= "ebt_log",
+	.logfn		= &ebt_log_packet,
+	.me		= THIS_MODULE,
+};
+
 static int __init init(void)
 {
-	return ebt_register_watcher(&log);
+	int ret;
+
+	ret = ebt_register_watcher(&log);
+	if (ret < 0)
+		return ret;
+	if (nf_log_register(PF_BRIDGE, &ebt_log_logger) < 0) {
+		printk(KERN_WARNING "ebt_log: not logging via system console "
+		       "since somebody else already registered for PF_INET\n");
+		/* we cannot make module load fail here, since otherwise 
+		 * ebtables userspace would abort */
+	}
+
+	return 0;
 }
 
 static void __exit fini(void)
 {
+	nf_log_unregister_logger(&ebt_log_logger);
 	ebt_unregister_watcher(&log);
 }
 
--- linux-2.6.14.2/net/bridge/netfilter/ebt_ulog.c.old	2005-11-15 18:00:02.000000000 +0000
+++ linux-2.6.14.2/net/bridge/netfilter/ebt_ulog.c	2005-11-15 18:00:24.000000000 +0000
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
 
-static void ebt_ulog(const struct sk_buff *skb, unsigned int hooknr,
+static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
-   const void *data, unsigned int datalen)
+   const struct ebt_ulog_info *uloginfo, const char *prefix)
 {
 	ebt_ulog_packet_msg_t *pm;
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
-	struct ebt_ulog_info *uloginfo = (struct ebt_ulog_info *)data;
 	unsigned int group = uloginfo->nlgroup;
 	ebt_ulog_buff_t *ub = &ulog_buffers[group];
 	spinlock_t *lock = &ub->lock;
@@ -216,6 +216,39 @@ alloc_failure:
 	goto unlock;
 }
 
+/* this function is registered with the netfilter core */
+static void ebt_log_packet(unsigned int pf, unsigned int hooknum,
+   const struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out, const struct nf_loginfo *li,
+   const char *prefix)
+{
+	struct ebt_ulog_info loginfo;
+
+	if (!li || li->type != NF_LOG_TYPE_ULOG) {
+		loginfo.nlgroup = EBT_ULOG_DEFAULT_NLGROUP;
+		loginfo.cprange = 0;
+		loginfo.qthreshold = EBT_ULOG_DEFAULT_QTHRESHOLD;
+		loginfo.prefix[0] = '\0';
+	} else {
+		loginfo.nlgroup = li->u.ulog.group;
+		loginfo.cprange = li->u.ulog.copy_len;
+		loginfo.qthreshold = li->u.ulog.qthreshold;
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
+	struct ebt_ulog_info *uloginfo = (struct ebt_ulog_info *)data;
+
+	ebt_ulog_packet(hooknr, skb, in, out, uloginfo, NULL);
+}
+
+
 static int ebt_ulog_check(const char *tablename, unsigned int hookmask,
    const struct ebt_entry *e, void *data, unsigned int datalen)
 {
@@ -240,6 +273,12 @@ static struct ebt_watcher ulog = {
 	.me		= THIS_MODULE,
 };
 
+static struct nf_logger ebt_ulog_logger = {
+	.name		= EBT_ULOG_WATCHER,
+	.logfn		= &ebt_log_packet,
+	.me		= THIS_MODULE,
+};
+
 static int __init init(void)
 {
 	int i, ret = 0;
@@ -265,6 +304,13 @@ static int __init init(void)
 	else if ((ret = ebt_register_watcher(&ulog)))
 		sock_release(ebtulognl->sk_socket);
 
+	if (nf_log_register(PF_BRIDGE, &ebt_ulog_logger) < 0) {
+		printk(KERN_WARNING "ebt_ulog: not logging via ulog "
+		       "since somebody else already registered for PF_BRIDGE\n");
+		/* we cannot make module load fail here, since otherwise
+		 * ebtables userspace would abort */
+	}
+
 	return ret;
 }
 
@@ -273,6 +319,7 @@ static void __exit fini(void)
 	ebt_ulog_buff_t *ub;
 	int i;
 
+	nf_log_unregister_logger(&ebt_ulog_logger);
 	ebt_unregister_watcher(&ulog);
 	for (i = 0; i < EBT_ULOG_MAXNLGROUPS; i++) {
 		ub = &ulog_buffers[i];




-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
