From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] update to the nf_log logging api
Date: Thu, 28 Jul 2005 22:04:34 +0200
Message-ID: <20050728200434.GA3763@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JWEK1jqKZ6MHAcjA"
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


--JWEK1jqKZ6MHAcjA
Content-Type: multipart/mixed; boundary="R3G7APHDIzY6R/pk"
Content-Disposition: inline


--R3G7APHDIzY6R/pk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply to your net-2.6.14 tree.

I'm still working out some glitches with nfnetlink_log, but will submit
it fairly soon, too.  I've also already some patch to make ebt_ulog.c
use the nfnetlink_log core.  Stay tuned...

[oh yes, I didn't forget my 'virtual ethernet device' code, either.  It
is just sitting in a lower priority queue at this time]

Thanks,
	Harald
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--R3G7APHDIzY6R/pk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="16-nf_logger.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] Extend netfilter logging API

This patch is in preparation to nfnetlink_log:
- loggers now have to register struct nf_logger instead of nf_logfn
- nf_log_unregister() replaced by nf_log_unregister_pf() and
  nf_log_unregister_logger()
- add comment to ip[6]t_LOG.h to assure nobody redefines flags
- add /proc/net/netfilter/nf_log to tell user which logger is currently
  registered for which address family
- if user has configured logging, but no logging backend (logger) is
  available, always spit a message to syslog, not just the first time.
- split ip[6]t_LOG.c into two parts:
  Backend: Always try to register as logger for the respective address fami=
ly
  Frontend: Always log via nf_log_packet() API
- modify all users of nf_log_packet() to accomodate additional argument

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 3770e25a01055bfa8bee52ed16666db1f3a5141f
tree bb6232f07be1a0ec617f99d0e479964ac2d66119
parent 70715270f9cedc76099ed628b5444a11127912ca
author laforge <laforge@netfilter.org> Do, 28 Jul 2005 21:27:14 +0200
committer laforge <laforge@netfilter.org> Do, 28 Jul 2005 21:27:14 +0200

 include/linux/netfilter.h                    |   48 +++++++++-
 include/linux/netfilter_ipv4/ipt_LOG.h       |    1=20
 include/linux/netfilter_ipv6/ip6t_LOG.h      |    1=20
 net/core/netfilter.c                         |  127 ++++++++++++++++++++++=
+---
 net/ipv4/netfilter/ip_conntrack_proto_icmp.c |    8 +-
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c  |   21 ++--
 net/ipv4/netfilter/ip_conntrack_proto_udp.c  |    6 +
 net/ipv4/netfilter/ipt_LOG.c                 |   84 +++++++++--------
 net/ipv4/netfilter/ipt_ULOG.c                |   33 +++++--
 net/ipv6/netfilter/ip6t_LOG.c                |   91 ++++++++++---------
 10 files changed, 295 insertions(+), 125 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -114,15 +114,51 @@ void nf_unregister_sockopt(struct nf_soc
=20
 extern struct list_head nf_hooks[NPROTO][NF_MAX_HOOKS];
=20
-typedef void nf_logfn(unsigned int hooknum,
+/* those NF_LOG_* defines and struct nf_loginfo are legacy definitios that=
 will
+ * disappear once iptables is replaced with pkttables.  Please DO NOT use =
them
+ * for any new code! */
+#define NF_LOG_TCPSEQ		0x01	/* Log TCP sequence numbers */
+#define NF_LOG_TCPOPT		0x02	/* Log TCP options */
+#define NF_LOG_IPOPT		0x04	/* Log IP options */
+#define NF_LOG_UID		0x08	/* Log UID owning local socket */
+#define NF_LOG_MASK		0x0f
+
+#define NF_LOG_TYPE_LOG		0x01
+#define NF_LOG_TYPE_ULOG	0x02
+
+struct nf_loginfo {
+	u_int8_t type;
+	union {
+		struct {
+			u_int32_t copy_len;
+			u_int16_t group;
+			u_int16_t qthreshold;
+		} ulog;
+		struct {
+			u_int8_t level;
+			u_int8_t logflags;
+		} log;
+	} u;
+};
+
+typedef void nf_logfn(unsigned int pf,
+		      unsigned int hooknum,
 		      const struct sk_buff *skb,
 		      const struct net_device *in,
 		      const struct net_device *out,
+		      const struct nf_loginfo *li,
 		      const char *prefix);
=20
+struct nf_logger {
+	struct module	*me;
+	nf_logfn 	*logfn;
+	char		*name;
+};
+
 /* Function to register/unregister log function. */
-int nf_log_register(int pf, nf_logfn *logfn);
-void nf_log_unregister(int pf, nf_logfn *logfn);
+int nf_log_register(int pf, struct nf_logger *logger);
+void nf_log_unregister_pf(int pf);
+void nf_log_unregister_logger(struct nf_logger *logger);
=20
 /* Calls the registered backend logging function */
 void nf_log_packet(int pf,
@@ -130,6 +166,7 @@ void nf_log_packet(int pf,
 		   const struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
+		   struct nf_loginfo *li,
 		   const char *fmt, ...);
                   =20
 /* Activate hook; either okfn or kfree_skb called, unless a hook
@@ -221,6 +258,11 @@ struct nf_queue_rerouter {
 extern int nf_register_queue_rerouter(int pf, struct nf_queue_rerouter *re=
r);
 extern int nf_unregister_queue_rerouter(int pf);
=20
+#ifdef CONFIG_PROC_FS
+#include <linux/proc_fs.h>
+extern struct proc_dir_entry *proc_net_netfilter;
+#endif
+
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) =
{}
diff --git a/include/linux/netfilter_ipv4/ipt_LOG.h b/include/linux/netfilt=
er_ipv4/ipt_LOG.h
--- a/include/linux/netfilter_ipv4/ipt_LOG.h
+++ b/include/linux/netfilter_ipv4/ipt_LOG.h
@@ -1,6 +1,7 @@
 #ifndef _IPT_LOG_H
 #define _IPT_LOG_H
=20
+/* make sure not to change this without changing netfilter.h:NF_LOG_* (!) =
*/
 #define IPT_LOG_TCPSEQ		0x01	/* Log TCP sequence numbers */
 #define IPT_LOG_TCPOPT		0x02	/* Log TCP options */
 #define IPT_LOG_IPOPT		0x04	/* Log IP options */
diff --git a/include/linux/netfilter_ipv6/ip6t_LOG.h b/include/linux/netfil=
ter_ipv6/ip6t_LOG.h
--- a/include/linux/netfilter_ipv6/ip6t_LOG.h
+++ b/include/linux/netfilter_ipv6/ip6t_LOG.h
@@ -1,6 +1,7 @@
 #ifndef _IP6T_LOG_H
 #define _IP6T_LOG_H
=20
+/* make sure not to change this without changing netfilter.h:NF_LOG_* (!) =
*/
 #define IP6T_LOG_TCPSEQ		0x01	/* Log TCP sequence numbers */
 #define IP6T_LOG_TCPOPT		0x02	/* Log TCP options */
 #define IP6T_LOG_IPOPT		0x04	/* Log IP options */
diff --git a/net/core/netfilter.c b/net/core/netfilter.c
--- a/net/core/netfilter.c
+++ b/net/core/netfilter.c
@@ -22,6 +22,7 @@
 #include <linux/if.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
+#include <linux/proc_fs.h>
 #include <net/sock.h>
=20
 /* In this code, we can be waiting indefinitely for userspace to
@@ -535,11 +536,10 @@ EXPORT_SYMBOL(skb_make_writable);
=20
 #define NF_LOG_PREFIXLEN		128
=20
-static nf_logfn *nf_logging[NPROTO]; /* =3D NULL */
-static int reported =3D 0;
+static struct nf_logger *nf_logging[NPROTO]; /* =3D NULL */
 static DEFINE_SPINLOCK(nf_log_lock);
=20
-int nf_log_register(int pf, nf_logfn *logfn)
+int nf_log_register(int pf, struct nf_logger *logger)
 {
 	int ret =3D -EBUSY;
=20
@@ -547,54 +547,134 @@ int nf_log_register(int pf, nf_logfn *lo
 	 * substituting pointer. */
 	spin_lock(&nf_log_lock);
 	if (!nf_logging[pf]) {
-		rcu_assign_pointer(nf_logging[pf], logfn);
+		rcu_assign_pointer(nf_logging[pf], logger);
 		ret =3D 0;
 	}
 	spin_unlock(&nf_log_lock);
 	return ret;
 }	=09
=20
-void nf_log_unregister(int pf, nf_logfn *logfn)
+void nf_log_unregister_pf(int pf)
 {
 	spin_lock(&nf_log_lock);
-	if (nf_logging[pf] =3D=3D logfn)
-		nf_logging[pf] =3D NULL;
+	nf_logging[pf] =3D NULL;
 	spin_unlock(&nf_log_lock);
=20
 	/* Give time to concurrent readers. */
 	synchronize_net();
-}	=09
+}
+
+void nf_log_unregister_logger(struct nf_logger *logger)
+{
+	int i;
+
+	spin_lock(&nf_log_lock);
+	for (i =3D 0; i < NPROTO; i++) {
+		if (nf_logging[i] =3D=3D logger)
+			nf_logging[i] =3D NULL;
+	}
+	spin_unlock(&nf_log_lock);
+
+	synchronize_net();
+}
=20
 void nf_log_packet(int pf,
 		   unsigned int hooknum,
 		   const struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
+		   struct nf_loginfo *loginfo,
 		   const char *fmt, ...)
 {
 	va_list args;
 	char prefix[NF_LOG_PREFIXLEN];
-	nf_logfn *logfn;
+	struct nf_logger *logger;
 =09
 	rcu_read_lock();
-	logfn =3D rcu_dereference(nf_logging[pf]);
-	if (logfn) {
+	logger =3D rcu_dereference(nf_logging[pf]);
+	if (logger) {
 		va_start(args, fmt);
 		vsnprintf(prefix, sizeof(prefix), fmt, args);
 		va_end(args);
 		/* We must read logging before nf_logfn[pf] */
-		logfn(hooknum, skb, in, out, prefix);
-	} else if (!reported) {
-		printk(KERN_WARNING "nf_log_packet: can\'t log yet, "
-		       "no backend logging module loaded in!\n");
-		reported++;
+		logger->logfn(pf, hooknum, skb, in, out, loginfo, prefix);
+	} else if (net_ratelimit()) {
+		printk(KERN_WARNING "nf_log_packet: can\'t log since "
+		       "no backend logging module loaded in! Please either "
+		       "load one, or disable logging explicitly\n");
 	}
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL(nf_log_register);
-EXPORT_SYMBOL(nf_log_unregister);
+EXPORT_SYMBOL(nf_log_unregister_pf);
+EXPORT_SYMBOL(nf_log_unregister_logger);
 EXPORT_SYMBOL(nf_log_packet);
=20
+#ifdef CONFIG_PROC_FS
+struct proc_dir_entry *proc_net_netfilter;
+EXPORT_SYMBOL(proc_net_netfilter);
+
+static void *seq_start(struct seq_file *seq, loff_t *pos)
+{
+	rcu_read_lock();
+
+	if (*pos >=3D NPROTO)
+		return NULL;
+
+	return pos;
+}
+
+static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	(*pos)++;
+
+	if (*pos >=3D NPROTO)
+		return NULL;
+
+	return pos;
+}
+
+static void seq_stop(struct seq_file *s, void *v)
+{
+	rcu_read_unlock();
+}
+
+static int seq_show(struct seq_file *s, void *v)
+{
+	loff_t *pos =3D v;
+	const struct nf_logger *logger;
+
+	logger =3D rcu_dereference(nf_logging[*pos]);
+
+	if (!logger)
+		return seq_printf(s, "%2lld NONE\n", *pos);
+=09
+	return seq_printf(s, "%2lld %s\n", *pos, logger->name);
+}
+
+static struct seq_operations nflog_seq_ops =3D {
+	.start	=3D seq_start,
+	.next	=3D seq_next,
+	.stop	=3D seq_stop,
+	.show	=3D seq_show,
+};
+
+static int nflog_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &nflog_seq_ops);
+}
+
+static struct file_operations nflog_file_ops =3D {
+	.owner	 =3D THIS_MODULE,
+	.open	 =3D nflog_open,
+	.read	 =3D seq_read,
+	.llseek	 =3D seq_lseek,
+	.release =3D seq_release,
+};
+
+#endif /* PROC_FS */
+
+
 /* This does not belong here, but locally generated errors need it if conn=
ection
    tracking in use: without this, connection may not be in hash table, and=
 hence
    manufactured ICMP or RST packets will not be associated with it. */
@@ -613,6 +693,9 @@ void nf_ct_attach(struct sk_buff *new, s
 void __init netfilter_init(void)
 {
 	int i, h;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *pde;
+#endif
=20
 	queue_rerouter =3D kmalloc(NPROTO * sizeof(struct nf_queue_rerouter),
 				 GFP_KERNEL);
@@ -624,6 +707,16 @@ void __init netfilter_init(void)
 		for (h =3D 0; h < NF_MAX_HOOKS; h++)
 			INIT_LIST_HEAD(&nf_hooks[i][h]);
 	}
+
+#ifdef CONFIG_PROC_FS
+	proc_net_netfilter =3D proc_mkdir("netfilter", proc_net);
+	if (!proc_net_netfilter)
+		panic("cannot create netfilter proc entry");
+	pde =3D create_proc_entry("nf_log", S_IRUGO, proc_net_netfilter);
+	if (!pde)
+		panic("cannot create /proc/net/netfilter/nf_log");
+	pde->proc_fops =3D &nflog_file_ops;
+#endif
 }
=20
 EXPORT_SYMBOL(ip_ct_attach);
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c b/net/ipv4/netfil=
ter/ip_conntrack_proto_icmp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
@@ -217,7 +217,7 @@ icmp_error(struct sk_buff *skb, enum ip_
 	icmph =3D skb_header_pointer(skb, skb->nh.iph->ihl*4, sizeof(_ih), &_ih);
 	if (icmph =3D=3D NULL) {
 		if (LOG_INVALID(IPPROTO_ICMP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				      "ip_ct_icmp: short packet ");
 		return -NF_ACCEPT;
 	}
@@ -231,13 +231,13 @@ icmp_error(struct sk_buff *skb, enum ip_
 		if (!(u16)csum_fold(skb->csum))=20
 			break;
 		if (LOG_INVALID(IPPROTO_ICMP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				      "ip_ct_icmp: bad HW ICMP checksum ");
 		return -NF_ACCEPT;
 	case CHECKSUM_NONE:
 		if ((u16)csum_fold(skb_checksum(skb, 0, skb->len, 0))) {
 			if (LOG_INVALID(IPPROTO_ICMP))
-				nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+				nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 					      "ip_ct_icmp: bad ICMP checksum ");
 			return -NF_ACCEPT;
 		}
@@ -254,7 +254,7 @@ checksum_skipped:
 	 */
 	if (icmph->type > NR_ICMP_TYPES) {
 		if (LOG_INVALID(IPPROTO_ICMP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				      "ip_ct_icmp: invalid ICMP type ");
 		return -NF_ACCEPT;
 	}
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilt=
er/ip_conntrack_proto_tcp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -716,7 +716,7 @@ static int tcp_in_window(struct ip_ct_tc
 		res =3D 1;
 	} else {
 		if (LOG_INVALID(IPPROTO_TCP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 			"ip_ct_tcp: %s ",
 			before(seq, sender->td_maxend + 1) ?
 			after(end, sender->td_end - receiver->td_maxwin - 1) ?
@@ -815,7 +815,7 @@ static int tcp_error(struct sk_buff *skb
 				sizeof(_tcph), &_tcph);
 	if (th =3D=3D NULL) {
 		if (LOG_INVALID(IPPROTO_TCP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				"ip_ct_tcp: short packet ");
 		return -NF_ACCEPT;
   	}
@@ -823,7 +823,7 @@ static int tcp_error(struct sk_buff *skb
 	/* Not whole TCP header or malformed packet */
 	if (th->doff*4 < sizeof(struct tcphdr) || tcplen < th->doff*4) {
 		if (LOG_INVALID(IPPROTO_TCP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				"ip_ct_tcp: truncated/malformed packet ");
 		return -NF_ACCEPT;
 	}
@@ -840,7 +840,7 @@ static int tcp_error(struct sk_buff *skb
 			         skb->ip_summed =3D=3D CHECKSUM_HW ? skb->csum
 			      	 : skb_checksum(skb, iph->ihl*4, tcplen, 0))) {
 		if (LOG_INVALID(IPPROTO_TCP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				  "ip_ct_tcp: bad TCP checksum ");
 		return -NF_ACCEPT;
 	}
@@ -849,7 +849,7 @@ static int tcp_error(struct sk_buff *skb
 	tcpflags =3D (((u_int8_t *)th)[13] & ~(TH_ECE|TH_CWR));
 	if (!tcp_valid_flags[tcpflags]) {
 		if (LOG_INVALID(IPPROTO_TCP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				  "ip_ct_tcp: invalid TCP flag combination ");
 		return -NF_ACCEPT;
 	}
@@ -897,8 +897,9 @@ static int tcp_packet(struct ip_conntrac
 			 */
 		    	write_unlock_bh(&tcp_lock);
 			if (LOG_INVALID(IPPROTO_TCP))
-				nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
-					  "ip_ct_tcp: killing out of sync session ");
+				nf_log_packet(PF_INET, 0, skb, NULL, NULL,
+					      NULL, "ip_ct_tcp: "
+					      "killing out of sync session ");
 		    	if (del_timer(&conntrack->timeout))
 		    		conntrack->timeout.function((unsigned long)
 		    					    conntrack);
@@ -912,7 +913,7 @@ static int tcp_packet(struct ip_conntrac
 	=09
 		write_unlock_bh(&tcp_lock);
 		if (LOG_INVALID(IPPROTO_TCP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				  "ip_ct_tcp: invalid packet ignored ");
 		return NF_ACCEPT;
 	case TCP_CONNTRACK_MAX:
@@ -922,7 +923,7 @@ static int tcp_packet(struct ip_conntrac
 		       old_state);
 		write_unlock_bh(&tcp_lock);
 		if (LOG_INVALID(IPPROTO_TCP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				  "ip_ct_tcp: invalid state ");
 		return -NF_ACCEPT;
 	case TCP_CONNTRACK_SYN_SENT:
@@ -943,7 +944,7 @@ static int tcp_packet(struct ip_conntrac
 			write_unlock_bh(&tcp_lock);
 			if (LOG_INVALID(IPPROTO_TCP))
 				nf_log_packet(PF_INET, 0, skb, NULL, NULL,
-				              "ip_ct_tcp: invalid SYN");
+					      NULL, "ip_ct_tcp: invalid SYN");
 			return -NF_ACCEPT;
 		}
 	case TCP_CONNTRACK_CLOSE:
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_udp.c b/net/ipv4/netfilt=
er/ip_conntrack_proto_udp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_udp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_udp.c
@@ -98,7 +98,7 @@ static int udp_error(struct sk_buff *skb
 	hdr =3D skb_header_pointer(skb, iph->ihl*4, sizeof(_hdr), &_hdr);
 	if (hdr =3D=3D NULL) {
 		if (LOG_INVALID(IPPROTO_UDP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				  "ip_ct_udp: short packet ");
 		return -NF_ACCEPT;
 	}
@@ -106,7 +106,7 @@ static int udp_error(struct sk_buff *skb
 	/* Truncated/malformed packets */
 	if (ntohs(hdr->len) > udplen || ntohs(hdr->len) < sizeof(*hdr)) {
 		if (LOG_INVALID(IPPROTO_UDP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				  "ip_ct_udp: truncated/malformed packet ");
 		return -NF_ACCEPT;
 	}
@@ -126,7 +126,7 @@ static int udp_error(struct sk_buff *skb
 			         skb->ip_summed =3D=3D CHECKSUM_HW ? skb->csum
 			      	 : skb_checksum(skb, iph->ihl*4, udplen, 0))) {
 		if (LOG_INVALID(IPPROTO_UDP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL,=20
+			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				  "ip_ct_udp: bad UDP checksum ");
 		return -NF_ACCEPT;
 	}
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -27,10 +27,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("iptables syslog logging module");
=20
-static unsigned int nflog =3D 1;
-module_param(nflog, int, 0400);
-MODULE_PARM_DESC(nflog, "register as internal netfilter logging module");
-=20
 #if 0
 #define DEBUGP printk
 #else
@@ -41,11 +37,17 @@ MODULE_PARM_DESC(nflog, "register as int
 static DEFINE_SPINLOCK(log_lock);
=20
 /* One level of recursion won't kill us */
-static void dump_packet(const struct ipt_log_info *info,
+static void dump_packet(const struct nf_loginfo *info,
 			const struct sk_buff *skb,
 			unsigned int iphoff)
 {
 	struct iphdr _iph, *ih;
+	unsigned int logflags;
+
+	if (info->type =3D=3D NF_LOG_TYPE_LOG)
+		logflags =3D info->u.log.logflags;
+	else
+		logflags =3D NF_LOG_MASK;
=20
 	ih =3D skb_header_pointer(skb, iphoff, sizeof(_iph), &_iph);
 	if (ih =3D=3D NULL) {
@@ -76,7 +78,7 @@ static void dump_packet(const struct ipt
 	if (ntohs(ih->frag_off) & IP_OFFSET)
 		printk("FRAG:%u ", ntohs(ih->frag_off) & IP_OFFSET);
=20
-	if ((info->logflags & IPT_LOG_IPOPT)
+	if ((logflags & IPT_LOG_IPOPT)
 	    && ih->ihl * 4 > sizeof(struct iphdr)) {
 		unsigned char _opt[4 * 15 - sizeof(struct iphdr)], *op;
 		unsigned int i, optsize;
@@ -119,7 +121,7 @@ static void dump_packet(const struct ipt
 		printk("SPT=3D%u DPT=3D%u ",
 		       ntohs(th->source), ntohs(th->dest));
 		/* Max length: 30 "SEQ=3D4294967295 ACK=3D4294967295 " */
-		if (info->logflags & IPT_LOG_TCPSEQ)
+		if (logflags & IPT_LOG_TCPSEQ)
 			printk("SEQ=3D%u ACK=3D%u ",
 			       ntohl(th->seq), ntohl(th->ack_seq));
 		/* Max length: 13 "WINDOW=3D65535 " */
@@ -146,7 +148,7 @@ static void dump_packet(const struct ipt
 		/* Max length: 11 "URGP=3D65535 " */
 		printk("URGP=3D%u ", ntohs(th->urg_ptr));
=20
-		if ((info->logflags & IPT_LOG_TCPOPT)
+		if ((logflags & IPT_LOG_TCPOPT)
 		    && th->doff * 4 > sizeof(struct tcphdr)) {
 			unsigned char _opt[4 * 15 - sizeof(struct tcphdr)];
 			unsigned char *op;
@@ -328,7 +330,7 @@ static void dump_packet(const struct ipt
 	}
=20
 	/* Max length: 15 "UID=3D4294967295 " */
- 	if ((info->logflags & IPT_LOG_UID) && !iphoff && skb->sk) {
+ 	if ((logflags & IPT_LOG_UID) && !iphoff && skb->sk) {
 		read_lock_bh(&skb->sk->sk_callback_lock);
 		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
  			printk("UID=3D%u ", skb->sk->sk_socket->file->f_uid);
@@ -349,19 +351,29 @@ static void dump_packet(const struct ipt
 	/* maxlen =3D 230+   91  + 230 + 252 =3D 803 */
 }
=20
+struct nf_loginfo default_loginfo =3D {
+	.type	=3D NF_LOG_TYPE_LOG,
+	.u.log	=3D {
+		.level    =3D 0,
+		.logflags =3D NF_LOG_MASK,
+	},
+};
+
 static void
-ipt_log_packet(unsigned int hooknum,
+ipt_log_packet(unsigned int pf,
+	       unsigned int hooknum,
 	       const struct sk_buff *skb,
 	       const struct net_device *in,
 	       const struct net_device *out,
-	       const struct ipt_log_info *loginfo,
-	       const char *level_string,
+	       const struct nf_loginfo *loginfo,
 	       const char *prefix)
 {
+	if (!loginfo)
+		loginfo =3D &default_loginfo;
+
 	spin_lock_bh(&log_lock);
-	printk(level_string);
-	printk("%sIN=3D%s OUT=3D%s ",
-	       prefix =3D=3D NULL ? loginfo->prefix : prefix,
+	printk("<%d>%sIN=3D%s OUT=3D%s ", loginfo->u.log.level,
+	       prefix,
 	       in ? in->name : "",
 	       out ? out->name : "");
 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -405,28 +417,15 @@ ipt_log_target(struct sk_buff **pskb,
 	       void *userinfo)
 {
 	const struct ipt_log_info *loginfo =3D targinfo;
-	char level_string[4] =3D "< >";
+	struct nf_loginfo li;
=20
-	level_string[1] =3D '0' + (loginfo->level % 8);
-	ipt_log_packet(hooknum, *pskb, in, out, loginfo, level_string, NULL);
+	li.type =3D NF_LOG_TYPE_LOG;
+	li.u.log.level =3D loginfo->level;
+	li.u.log.logflags =3D loginfo->logflags;
=20
-	return IPT_CONTINUE;
-}
+	nf_log_packet(PF_INET, hooknum, *pskb, in, out, &li, loginfo->prefix);
=20
-static void
-ipt_logfn(unsigned int hooknum,
-	  const struct sk_buff *skb,
-	  const struct net_device *in,
-	  const struct net_device *out,
-	  const char *prefix)
-{
-	struct ipt_log_info loginfo =3D {=20
-		.level =3D 0,=20
-		.logflags =3D IPT_LOG_MASK,=20
-		.prefix =3D ""=20
-	};
-
-	ipt_log_packet(hooknum, skb, in, out, &loginfo, KERN_WARNING, prefix);
+	return IPT_CONTINUE;
 }
=20
 static int ipt_log_checkentry(const char *tablename,
@@ -464,20 +463,29 @@ static struct ipt_target ipt_log_reg =3D {
 	.me		=3D THIS_MODULE,
 };
=20
+static struct nf_logger ipt_log_logger =3D{
+	.name		=3D "ipt_LOG",
+	.logfn		=3D &ipt_log_packet,
+	.me		=3D THIS_MODULE,
+};
+
 static int __init init(void)
 {
 	if (ipt_register_target(&ipt_log_reg))
 		return -EINVAL;
-	if (nflog)
-		nf_log_register(PF_INET, &ipt_logfn);
+	if (nf_log_register(PF_INET, &ipt_log_logger) < 0) {
+		printk(KERN_WARNING "ipt_LOG: not logging via system console "
+		       "since somebody else already registered for PF_INET\n");
+		/* we cannot make module load fail here, since otherwise
+		 * iptables userspace would abort */
+	}
 =09
 	return 0;
 }
=20
 static void __exit fini(void)
 {
-	if (nflog)
-		nf_log_unregister(PF_INET, &ipt_logfn);
+	nf_log_unregister_logger(&ipt_log_logger);
 	ipt_unregister_target(&ipt_log_reg);
 }
=20
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -304,18 +304,27 @@ static unsigned int ipt_ulog_target(stru
  	return IPT_CONTINUE;
 }
 =20
-static void ipt_logfn(unsigned int hooknum,
+static void ipt_logfn(unsigned int pf,
+		      unsigned int hooknum,
 		      const struct sk_buff *skb,
 		      const struct net_device *in,
 		      const struct net_device *out,
+		      const struct nf_loginfo *li,
 		      const char *prefix)
 {
-	struct ipt_ulog_info loginfo =3D {=20
-		.nl_group =3D ULOG_DEFAULT_NLGROUP,
-		.copy_range =3D 0,
-		.qthreshold =3D ULOG_DEFAULT_QTHRESHOLD,
-		.prefix =3D ""
-	};
+	struct ipt_ulog_info loginfo;
+
+	if (!li || li->type !=3D NF_LOG_TYPE_ULOG) {
+		loginfo.nl_group =3D ULOG_DEFAULT_NLGROUP;
+		loginfo.copy_range =3D 0;
+		loginfo.qthreshold =3D ULOG_DEFAULT_QTHRESHOLD;
+		loginfo.prefix[0] =3D '\0';
+	} else {
+		loginfo.nl_group =3D li->u.ulog.group;
+		loginfo.copy_range =3D li->u.ulog.copy_len;
+		loginfo.qthreshold =3D li->u.ulog.qthreshold;
+		strlcpy(loginfo.prefix, prefix, sizeof(loginfo.prefix));
+	}
=20
 	ipt_ulog_packet(hooknum, skb, in, out, &loginfo, prefix);
 }
@@ -355,6 +364,12 @@ static struct ipt_target ipt_ulog_reg =3D=20
 	.me		=3D THIS_MODULE,
 };
=20
+static struct nf_logger ipt_ulog_logger =3D {
+	.name		=3D "ipt_ULOG",
+	.logfn		=3D &ipt_logfn,
+	.me		=3D THIS_MODULE,
+};
+
 static int __init init(void)
 {
 	int i;
@@ -382,7 +397,7 @@ static int __init init(void)
 		return -EINVAL;
 	}
 	if (nflog)
-		nf_log_register(PF_INET, &ipt_logfn);
+		nf_log_register(PF_INET, &ipt_ulog_logger);
 =09
 	return 0;
 }
@@ -395,7 +410,7 @@ static void __exit fini(void)
 	DEBUGP("ipt_ULOG: cleanup_module\n");
=20
 	if (nflog)
-		nf_log_unregister(PF_INET, &ipt_logfn);
+		nf_log_unregister_logger(&ipt_ulog_logger);
 	ipt_unregister_target(&ipt_ulog_reg);
 	sock_release(nflognl->sk_socket);
=20
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -26,10 +26,6 @@ MODULE_AUTHOR("Jan Rekorajski <baggins@p
 MODULE_DESCRIPTION("IP6 tables LOG target module");
 MODULE_LICENSE("GPL");
=20
-static unsigned int nflog =3D 1;
-module_param(nflog, int, 0400);
-MODULE_PARM_DESC(nflog, "register as internal netfilter logging module");
-=20
 struct in_device;
 #include <net/route.h>
 #include <linux/netfilter_ipv6/ip6t_LOG.h>
@@ -44,7 +40,7 @@ struct in_device;
 static DEFINE_SPINLOCK(log_lock);
=20
 /* One level of recursion won't kill us */
-static void dump_packet(const struct ip6t_log_info *info,
+static void dump_packet(const struct nf_loginfo *info,
 			const struct sk_buff *skb, unsigned int ip6hoff,
 			int recurse)
 {
@@ -53,6 +49,12 @@ static void dump_packet(const struct ip6
 	struct ipv6hdr _ip6h, *ih;
 	unsigned int ptr;
 	unsigned int hdrlen =3D 0;
+	unsigned int logflags;
+
+	if (info->type =3D=3D NF_LOG_TYPE_LOG)
+		logflags =3D info->u.log.logflags;
+	else
+		logflags =3D NF_LOG_MASK;
=20
 	ih =3D skb_header_pointer(skb, ip6hoff, sizeof(_ip6h), &_ip6h);
 	if (ih =3D=3D NULL) {
@@ -84,7 +86,7 @@ static void dump_packet(const struct ip6
 		}
=20
 		/* Max length: 48 "OPT (...) " */
-		if (info->logflags & IP6T_LOG_IPOPT)
+		if (logflags & IP6T_LOG_IPOPT)
 			printk("OPT ( ");
=20
 		switch (currenthdr) {
@@ -119,7 +121,7 @@ static void dump_packet(const struct ip6
 		case IPPROTO_ROUTING:
 		case IPPROTO_HOPOPTS:
 			if (fragment) {
-				if (info->logflags & IP6T_LOG_IPOPT)
+				if (logflags & IP6T_LOG_IPOPT)
 					printk(")");
 				return;
 			}
@@ -127,7 +129,7 @@ static void dump_packet(const struct ip6
 			break;
 		/* Max Length */
 		case IPPROTO_AH:
-			if (info->logflags & IP6T_LOG_IPOPT) {
+			if (logflags & IP6T_LOG_IPOPT) {
 				struct ip_auth_hdr _ahdr, *ah;
=20
 				/* Max length: 3 "AH " */
@@ -158,7 +160,7 @@ static void dump_packet(const struct ip6
 			hdrlen =3D (hp->hdrlen+2)<<2;
 			break;
 		case IPPROTO_ESP:
-			if (info->logflags & IP6T_LOG_IPOPT) {
+			if (logflags & IP6T_LOG_IPOPT) {
 				struct ip_esp_hdr _esph, *eh;
=20
 				/* Max length: 4 "ESP " */
@@ -190,7 +192,7 @@ static void dump_packet(const struct ip6
 			printk("Unknown Ext Hdr %u", currenthdr);
 			return;
 		}
-		if (info->logflags & IP6T_LOG_IPOPT)
+		if (logflags & IP6T_LOG_IPOPT)
 			printk(") ");
=20
 		currenthdr =3D hp->nexthdr;
@@ -218,7 +220,7 @@ static void dump_packet(const struct ip6
 		printk("SPT=3D%u DPT=3D%u ",
 		       ntohs(th->source), ntohs(th->dest));
 		/* Max length: 30 "SEQ=3D4294967295 ACK=3D4294967295 " */
-		if (info->logflags & IP6T_LOG_TCPSEQ)
+		if (logflags & IP6T_LOG_TCPSEQ)
 			printk("SEQ=3D%u ACK=3D%u ",
 			       ntohl(th->seq), ntohl(th->ack_seq));
 		/* Max length: 13 "WINDOW=3D65535 " */
@@ -245,7 +247,7 @@ static void dump_packet(const struct ip6
 		/* Max length: 11 "URGP=3D65535 " */
 		printk("URGP=3D%u ", ntohs(th->urg_ptr));
=20
-		if ((info->logflags & IP6T_LOG_TCPOPT)
+		if ((logflags & IP6T_LOG_TCPOPT)
 		    && th->doff * 4 > sizeof(struct tcphdr)) {
 			u_int8_t _opt[60 - sizeof(struct tcphdr)], *op;
 			unsigned int i;
@@ -349,7 +351,7 @@ static void dump_packet(const struct ip6
 	}
=20
 	/* Max length: 15 "UID=3D4294967295 " */
-	if ((info->logflags & IP6T_LOG_UID) && recurse && skb->sk) {
+	if ((logflags & IP6T_LOG_UID) && recurse && skb->sk) {
 		read_lock_bh(&skb->sk->sk_callback_lock);
 		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
 			printk("UID=3D%u ", skb->sk->sk_socket->file->f_uid);
@@ -357,19 +359,29 @@ static void dump_packet(const struct ip6
 	}
 }
=20
+static struct nf_loginfo default_loginfo =3D {
+	.type	=3D NF_LOG_TYPE_LOG,
+	.u.log	=3D {
+		.level	  =3D 0,
+		.logflags =3D NF_LOG_MASK,
+	},
+};
+
 static void
-ip6t_log_packet(unsigned int hooknum,
+ip6t_log_packet(unsigned int pf,
+		unsigned int hooknum,
 		const struct sk_buff *skb,
 		const struct net_device *in,
 		const struct net_device *out,
-		const struct ip6t_log_info *loginfo,
-		const char *level_string,
+		const struct nf_loginfo *loginfo,
 		const char *prefix)
 {
+	if (!loginfo)
+		loginfo =3D &default_loginfo;
+
 	spin_lock_bh(&log_lock);
-	printk(level_string);
-	printk("%sIN=3D%s OUT=3D%s ",
-		prefix =3D=3D NULL ? loginfo->prefix : prefix,
+	printk("<%d>%sIN=3D%s OUT=3D%s ", loginfo->u.log.level,=20
+		prefix,
 		in ? in->name : "",
 		out ? out->name : "");
 	if (in && !out) {
@@ -416,29 +428,17 @@ ip6t_log_target(struct sk_buff **pskb,
 		void *userinfo)
 {
 	const struct ip6t_log_info *loginfo =3D targinfo;
-	char level_string[4] =3D "< >";
+	struct nf_loginfo li;
+
+	li.type =3D NF_LOG_TYPE_LOG;
+	li.u.log.level =3D loginfo->level;
+	li.u.log.logflags =3D loginfo->logflags;
=20
-	level_string[1] =3D '0' + (loginfo->level % 8);
-	ip6t_log_packet(hooknum, *pskb, in, out, loginfo, level_string, NULL);
+	nf_log_packet(PF_INET6, hooknum, *pskb, in, out, &li, loginfo->prefix);
=20
 	return IP6T_CONTINUE;
 }
=20
-static void
-ip6t_logfn(unsigned int hooknum,
-	   const struct sk_buff *skb,
-	   const struct net_device *in,
-	   const struct net_device *out,
-	   const char *prefix)
-{
-	struct ip6t_log_info loginfo =3D {
-		.level =3D 0,
-		.logflags =3D IP6T_LOG_MASK,
-		.prefix =3D ""
-	};
-
-	ip6t_log_packet(hooknum, skb, in, out, &loginfo, KERN_WARNING, prefix);
-}
=20
 static int ip6t_log_checkentry(const char *tablename,
 			       const struct ip6t_entry *e,
@@ -475,20 +475,29 @@ static struct ip6t_target ip6t_log_reg =3D
 	.me 		=3D THIS_MODULE,
 };
=20
+static struct nf_logger ip6t_logger =3D {
+	.name		=3D "ip6t_LOG",
+	.logfn		=3D &ip6t_log_packet,
+	.me		=3D THIS_MODULE,
+};
+
 static int __init init(void)
 {
 	if (ip6t_register_target(&ip6t_log_reg))
 		return -EINVAL;
-	if (nflog)
-		nf_log_register(PF_INET6, &ip6t_logfn);
+	if (nf_log_register(PF_INET6, &ip6t_logger) < 0) {
+		printk(KERN_WARNING "ip6t_LOG: not logging via system console "
+		       "since somebody else already registered for PF_INET6\n");
+		/* we cannot make module load fail here, since otherwise
+		 * ip6tables userspace would abort */
+	}
=20
 	return 0;
 }
=20
 static void __exit fini(void)
 {
-	if (nflog)
-		nf_log_unregister(PF_INET6, &ip6t_logfn);
+	nf_log_unregister_logger(&ip6t_logger);
 	ip6t_unregister_target(&ip6t_log_reg);
 }
=20

--R3G7APHDIzY6R/pk--

--JWEK1jqKZ6MHAcjA
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC6TpRXaXGVTD0i/8RAuhgAKCBhg9uBcQi+XZ7saWluGOplGsa3wCeKYHD
3aJDO2Sdq5XShgAEe9suFeI=
=Gidq
-----END PGP SIGNATURE-----

--JWEK1jqKZ6MHAcjA--
