From: pablo@netfilter.org
Subject: [PATCH 3/7] netfilter: nf_ct_helper: implement variable length helper private data
Date: Sat, 16 Jun 2012 17:49:52 +0200
Message-ID: <1339861796-2676-4-git-send-email-pablo@netfilter.org>
References: <1339861796-2676-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33056 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754810Ab2FPPvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jun 2012 11:51:39 -0400
In-Reply-To: <1339861796-2676-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch uses the new variable length conntrack extensions.

Instead of using union nf_conntrack_help that contain all the
helper private data information, we allocate variable length
area to store the private helper data.

This patch includes the modification of all existing helpers.
It also includes a couple of include header to avoid compilation
warnings.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_sip.h  |    2 ++
 include/net/netfilter/nf_conntrack.h        |   35 ++-------------------
 include/net/netfilter/nf_conntrack_helper.h |   15 ++++++++-
 net/ipv4/netfilter/nf_nat_amanda.c          |    4 +--
 net/ipv4/netfilter/nf_nat_h323.c            |    8 ++---
 net/ipv4/netfilter/nf_nat_pptp.c            |    6 ++--
 net/ipv4/netfilter/nf_nat_tftp.c            |    4 +--
 net/netfilter/nf_conntrack_core.c           |    3 +-
 net/netfilter/nf_conntrack_ftp.c            |    3 +-
 net/netfilter/nf_conntrack_h323_main.c      |   16 ++++++----
 net/netfilter/nf_conntrack_helper.c         |   11 ++++---
 net/netfilter/nf_conntrack_netlink.c        |    4 +--
 net/netfilter/nf_conntrack_pptp.c           |   17 ++++++-----
 net/netfilter/nf_conntrack_proto_gre.c      |   16 +++++-----
 net/netfilter/nf_conntrack_sane.c           |    4 +--
 net/netfilter/nf_conntrack_sip.c            |   25 +++++++--------
 net/netfilter/xt_CT.c                       |   44 ++++++++++++++++-----------
 17 files changed, 111 insertions(+), 106 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index 0ce91d5..0dfc8b7 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -2,6 +2,8 @@
 #define __NF_CONNTRACK_SIP_H__
 #ifdef __KERNEL__
 
+#include <net/netfilter/nf_conntrack_expect.h>
+
 #define SIP_PORT	5060
 #define SIP_TIMEOUT	3600
 
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index cce7f6a..f1494fe 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -39,36 +39,6 @@ union nf_conntrack_expect_proto {
 	/* insert expect proto private data here */
 };
 
-/* Add protocol helper include file here */
-#include <linux/netfilter/nf_conntrack_ftp.h>
-#include <linux/netfilter/nf_conntrack_pptp.h>
-#include <linux/netfilter/nf_conntrack_h323.h>
-#include <linux/netfilter/nf_conntrack_sane.h>
-#include <linux/netfilter/nf_conntrack_sip.h>
-
-/* per conntrack: application helper private data */
-union nf_conntrack_help {
-	/* insert conntrack helper private data (master) here */
-#if defined(CONFIG_NF_CONNTRACK_FTP) || defined(CONFIG_NF_CONNTRACK_FTP_MODULE)
-	struct nf_ct_ftp_master ct_ftp_info;
-#endif
-#if defined(CONFIG_NF_CONNTRACK_PPTP) || \
-    defined(CONFIG_NF_CONNTRACK_PPTP_MODULE)
-	struct nf_ct_pptp_master ct_pptp_info;
-#endif
-#if defined(CONFIG_NF_CONNTRACK_H323) || \
-    defined(CONFIG_NF_CONNTRACK_H323_MODULE)
-	struct nf_ct_h323_master ct_h323_info;
-#endif
-#if defined(CONFIG_NF_CONNTRACK_SANE) || \
-    defined(CONFIG_NF_CONNTRACK_SANE_MODULE)
-	struct nf_ct_sane_master ct_sane_info;
-#endif
-#if defined(CONFIG_NF_CONNTRACK_SIP) || defined(CONFIG_NF_CONNTRACK_SIP_MODULE)
-	struct nf_ct_sip_master ct_sip_info;
-#endif
-};
-
 #include <linux/types.h>
 #include <linux/skbuff.h>
 #include <linux/timer.h>
@@ -89,12 +59,13 @@ struct nf_conn_help {
 	/* Helper. if any */
 	struct nf_conntrack_helper __rcu *helper;
 
-	union nf_conntrack_help help;
-
 	struct hlist_head expectations;
 
 	/* Current number of expected connections */
 	u8 expecting[NF_CT_MAX_EXPECT_CLASSES];
+
+	/* private helper information. */
+	char data[];
 };
 
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 5f5a4d9..061352f 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -11,6 +11,7 @@
 #define _NF_CONNTRACK_HELPER_H
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_extend.h>
+#include <net/netfilter/nf_conntrack_expect.h>
 
 struct module;
 
@@ -23,6 +24,9 @@ struct nf_conntrack_helper {
 	struct module *me;		/* pointer to self */
 	const struct nf_conntrack_expect_policy *expect_policy;
 
+	/* length of internal data, ie. sizeof(struct nf_ct_*_master) */
+	size_t data_len;
+
 	/* Tuple of things we will help (compared against server response) */
 	struct nf_conntrack_tuple tuple;
 
@@ -48,7 +52,7 @@ nf_conntrack_helper_try_module_get(const char *name, u16 l3num, u8 protonum);
 extern int nf_conntrack_helper_register(struct nf_conntrack_helper *);
 extern void nf_conntrack_helper_unregister(struct nf_conntrack_helper *);
 
-extern struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, gfp_t gfp);
+extern struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, struct nf_conntrack_helper *helper, gfp_t gfp);
 
 extern int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 				     gfp_t flags);
@@ -60,6 +64,15 @@ static inline struct nf_conn_help *nfct_help(const struct nf_conn *ct)
 	return nf_ct_ext_find(ct, NF_CT_EXT_HELPER);
 }
 
+static inline void *nfct_help_data(const struct nf_conn *ct)
+{
+	struct nf_conn_help *help;
+
+	help = nf_ct_ext_find(ct, NF_CT_EXT_HELPER);
+
+	return (void *)help->data;
+}
+
 extern int nf_conntrack_helper_init(struct net *net);
 extern void nf_conntrack_helper_fini(struct net *net);
 
diff --git a/net/ipv4/netfilter/nf_nat_amanda.c b/net/ipv4/netfilter/nf_nat_amanda.c
index 7b22382..3c04d24 100644
--- a/net/ipv4/netfilter/nf_nat_amanda.c
+++ b/net/ipv4/netfilter/nf_nat_amanda.c
@@ -13,10 +13,10 @@
 #include <linux/skbuff.h>
 #include <linux/udp.h>
 
-#include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_nat_helper.h>
+#include <net/netfilter/nf_nat_rule.h>
 #include <linux/netfilter/nf_conntrack_amanda.h>
 
 MODULE_AUTHOR("Brian J. Murrell <netfilter@interlinx.bc.ca>");
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index cad29c1..c6784a1 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -95,7 +95,7 @@ static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 			unsigned char **data,
 			TransportAddress *taddr, int count)
 {
-	const struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	const struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	int i;
 	__be16 port;
@@ -178,7 +178,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 			struct nf_conntrack_expect *rtp_exp,
 			struct nf_conntrack_expect *rtcp_exp)
 {
-	struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	int i;
 	u_int16_t nated_port;
@@ -330,7 +330,7 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 		    TransportAddress *taddr, __be16 port,
 		    struct nf_conntrack_expect *exp)
 {
-	struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	u_int16_t nated_port = ntohs(port);
 
@@ -419,7 +419,7 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 		    unsigned char **data, TransportAddress *taddr, int idx,
 		    __be16 port, struct nf_conntrack_expect *exp)
 {
-	struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	u_int16_t nated_port = ntohs(port);
 	union nf_inet_addr addr;
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index c273d58..3881408 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -49,7 +49,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 	const struct nf_nat_pptp *nat_pptp_info;
 	struct nf_nat_ipv4_range range;
 
-	ct_pptp_info = &nfct_help(master)->help.ct_pptp_info;
+	ct_pptp_info = nfct_help_data(master);
 	nat_pptp_info = &nfct_nat(master)->help.nat_pptp_info;
 
 	/* And here goes the grand finale of corrosion... */
@@ -123,7 +123,7 @@ pptp_outbound_pkt(struct sk_buff *skb,
 	__be16 new_callid;
 	unsigned int cid_off;
 
-	ct_pptp_info  = &nfct_help(ct)->help.ct_pptp_info;
+	ct_pptp_info = nfct_help_data(ct);
 	nat_pptp_info = &nfct_nat(ct)->help.nat_pptp_info;
 
 	new_callid = ct_pptp_info->pns_call_id;
@@ -192,7 +192,7 @@ pptp_exp_gre(struct nf_conntrack_expect *expect_orig,
 	struct nf_ct_pptp_master *ct_pptp_info;
 	struct nf_nat_pptp *nat_pptp_info;
 
-	ct_pptp_info  = &nfct_help(ct)->help.ct_pptp_info;
+	ct_pptp_info = nfct_help_data(ct);
 	nat_pptp_info = &nfct_nat(ct)->help.nat_pptp_info;
 
 	/* save original PAC call ID in nat_info */
diff --git a/net/ipv4/netfilter/nf_nat_tftp.c b/net/ipv4/netfilter/nf_nat_tftp.c
index a2901bf..9dbb8d2 100644
--- a/net/ipv4/netfilter/nf_nat_tftp.c
+++ b/net/ipv4/netfilter/nf_nat_tftp.c
@@ -8,10 +8,10 @@
 #include <linux/module.h>
 #include <linux/udp.h>
 
-#include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_nat_helper.h>
+#include <net/netfilter/nf_nat_rule.h>
 #include <linux/netfilter/nf_conntrack_tftp.h>
 
 MODULE_AUTHOR("Magnus Boden <mb@ozaba.mine.nu>");
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 1ee2082..cf48755 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -819,7 +819,8 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 		__set_bit(IPS_EXPECTED_BIT, &ct->status);
 		ct->master = exp->master;
 		if (exp->helper) {
-			help = nf_ct_helper_ext_add(ct, GFP_ATOMIC);
+			help = nf_ct_helper_ext_add(ct, exp->helper,
+						    GFP_ATOMIC);
 			if (help)
 				rcu_assign_pointer(help->helper, exp->helper);
 		}
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 44e47c9..4bb771d 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -358,7 +358,7 @@ static int help(struct sk_buff *skb,
 	u32 seq;
 	int dir = CTINFO2DIR(ctinfo);
 	unsigned int uninitialized_var(matchlen), uninitialized_var(matchoff);
-	struct nf_ct_ftp_master *ct_ftp_info = &nfct_help(ct)->help.ct_ftp_info;
+	struct nf_ct_ftp_master *ct_ftp_info = nfct_help_data(ct);
 	struct nf_conntrack_expect *exp;
 	union nf_inet_addr *daddr;
 	struct nf_conntrack_man cmd = {};
@@ -554,6 +554,7 @@ static int __init nf_conntrack_ftp_init(void)
 		ftp[i][0].tuple.src.l3num = PF_INET;
 		ftp[i][1].tuple.src.l3num = PF_INET6;
 		for (j = 0; j < 2; j++) {
+			ftp[i][j].data_len = sizeof(struct nf_ct_ftp_master);
 			ftp[i][j].tuple.src.u.tcp.port = htons(ports[i]);
 			ftp[i][j].tuple.dst.protonum = IPPROTO_TCP;
 			ftp[i][j].expect_policy = &ftp_exp_policy;
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 46d69d7..ed21992 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -114,7 +114,7 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 			 struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 			 unsigned char **data, int *datalen, int *dataoff)
 {
-	struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	const struct tcphdr *th;
 	struct tcphdr _tcph;
@@ -618,6 +618,7 @@ static const struct nf_conntrack_expect_policy h245_exp_policy = {
 static struct nf_conntrack_helper nf_conntrack_helper_h245 __read_mostly = {
 	.name			= "H.245",
 	.me			= THIS_MODULE,
+	.data_len		= sizeof(struct nf_ct_h323_master),
 	.tuple.src.l3num	= AF_UNSPEC,
 	.tuple.dst.protonum	= IPPROTO_UDP,
 	.help			= h245_help,
@@ -1170,6 +1171,7 @@ static struct nf_conntrack_helper nf_conntrack_helper_q931[] __read_mostly = {
 	{
 		.name			= "Q.931",
 		.me			= THIS_MODULE,
+		.data_len		= sizeof(struct nf_ct_h323_master),
 		.tuple.src.l3num	= AF_INET,
 		.tuple.src.u.tcp.port	= cpu_to_be16(Q931_PORT),
 		.tuple.dst.protonum	= IPPROTO_TCP,
@@ -1245,7 +1247,7 @@ static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 		       unsigned char **data,
 		       TransportAddress *taddr, int count)
 {
-	struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	int ret = 0;
 	int i;
@@ -1360,7 +1362,7 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, RegistrationRequest *rrq)
 {
-	struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int ret;
 	typeof(set_ras_addr_hook) set_ras_addr;
 
@@ -1395,7 +1397,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, RegistrationConfirm *rcf)
 {
-	struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	int ret;
 	struct nf_conntrack_expect *exp;
@@ -1444,7 +1446,7 @@ static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, UnregistrationRequest *urq)
 {
-	struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	int ret;
 	typeof(set_sig_addr_hook) set_sig_addr;
@@ -1476,7 +1478,7 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, AdmissionRequest *arq)
 {
-	const struct nf_ct_h323_master *info = &nfct_help(ct)->help.ct_h323_info;
+	const struct nf_ct_h323_master *info = nfct_help_data(ct);
 	int dir = CTINFO2DIR(ctinfo);
 	__be16 port;
 	union nf_inet_addr addr;
@@ -1743,6 +1745,7 @@ static struct nf_conntrack_helper nf_conntrack_helper_ras[] __read_mostly = {
 	{
 		.name			= "RAS",
 		.me			= THIS_MODULE,
+		.data_len		= sizeof(struct nf_ct_h323_master),
 		.tuple.src.l3num	= AF_INET,
 		.tuple.src.u.udp.port	= cpu_to_be16(RAS_PORT),
 		.tuple.dst.protonum	= IPPROTO_UDP,
@@ -1752,6 +1755,7 @@ static struct nf_conntrack_helper nf_conntrack_helper_ras[] __read_mostly = {
 	{
 		.name			= "RAS",
 		.me			= THIS_MODULE,
+		.data_len		= sizeof(struct nf_ct_h323_master),
 		.tuple.src.l3num	= AF_INET6,
 		.tuple.src.u.udp.port	= cpu_to_be16(RAS_PORT),
 		.tuple.dst.protonum	= IPPROTO_UDP,
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 4fa2ff9..9c18ecb 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -161,11 +161,14 @@ nf_conntrack_helper_try_module_get(const char *name, u16 l3num, u8 protonum)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_try_module_get);
 
-struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, gfp_t gfp)
+struct nf_conn_help *
+nf_ct_helper_ext_add(struct nf_conn *ct,
+		     struct nf_conntrack_helper *helper, gfp_t gfp)
 {
 	struct nf_conn_help *help;
 
-	help = nf_ct_ext_add(ct, NF_CT_EXT_HELPER, gfp);
+	help = nf_ct_ext_add_length(ct, NF_CT_EXT_HELPER,
+				    helper->data_len, gfp);
 	if (help)
 		INIT_HLIST_HEAD(&help->expectations);
 	else
@@ -218,13 +221,13 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 	}
 
 	if (help == NULL) {
-		help = nf_ct_helper_ext_add(ct, flags);
+		help = nf_ct_helper_ext_add(ct, helper, flags);
 		if (help == NULL) {
 			ret = -ENOMEM;
 			goto out;
 		}
 	} else {
-		memset(&help->help, 0, sizeof(help->help));
+		memset(help->data, 0, helper->data_len);
 	}
 
 	rcu_assign_pointer(help->helper, helper);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6f4b00a..a088920 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1218,7 +1218,7 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 		if (help->helper)
 			return -EBUSY;
 		/* need to zero data of old helper */
-		memset(&help->help, 0, sizeof(help->help));
+		memset(help->data, 0, help->helper->data_len);
 	} else {
 		/* we cannot set a helper for an existing conntrack */
 		return -EOPNOTSUPP;
@@ -1440,7 +1440,7 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 		} else {
 			struct nf_conn_help *help;
 
-			help = nf_ct_helper_ext_add(ct, GFP_ATOMIC);
+			help = nf_ct_helper_ext_add(ct, helper, GFP_ATOMIC);
 			if (help == NULL) {
 				err = -ENOMEM;
 				goto err2;
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 31d56b2..6fed9ec 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -174,7 +174,7 @@ static int destroy_sibling_or_exp(struct net *net, struct nf_conn *ct,
 static void pptp_destroy_siblings(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
-	const struct nf_conn_help *help = nfct_help(ct);
+	const struct nf_ct_pptp_master *ct_pptp_info = nfct_help_data(ct);
 	struct nf_conntrack_tuple t;
 
 	nf_ct_gre_keymap_destroy(ct);
@@ -182,16 +182,16 @@ static void pptp_destroy_siblings(struct nf_conn *ct)
 	/* try original (pns->pac) tuple */
 	memcpy(&t, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple, sizeof(t));
 	t.dst.protonum = IPPROTO_GRE;
-	t.src.u.gre.key = help->help.ct_pptp_info.pns_call_id;
-	t.dst.u.gre.key = help->help.ct_pptp_info.pac_call_id;
+	t.src.u.gre.key = ct_pptp_info->pns_call_id;
+	t.dst.u.gre.key = ct_pptp_info->pac_call_id;
 	if (!destroy_sibling_or_exp(net, ct, &t))
 		pr_debug("failed to timeout original pns->pac ct/exp\n");
 
 	/* try reply (pac->pns) tuple */
 	memcpy(&t, &ct->tuplehash[IP_CT_DIR_REPLY].tuple, sizeof(t));
 	t.dst.protonum = IPPROTO_GRE;
-	t.src.u.gre.key = help->help.ct_pptp_info.pac_call_id;
-	t.dst.u.gre.key = help->help.ct_pptp_info.pns_call_id;
+	t.src.u.gre.key = ct_pptp_info->pac_call_id;
+	t.dst.u.gre.key = ct_pptp_info->pns_call_id;
 	if (!destroy_sibling_or_exp(net, ct, &t))
 		pr_debug("failed to timeout reply pac->pns ct/exp\n");
 }
@@ -269,7 +269,7 @@ pptp_inbound_pkt(struct sk_buff *skb,
 		 struct nf_conn *ct,
 		 enum ip_conntrack_info ctinfo)
 {
-	struct nf_ct_pptp_master *info = &nfct_help(ct)->help.ct_pptp_info;
+	struct nf_ct_pptp_master *info = nfct_help_data(ct);
 	u_int16_t msg;
 	__be16 cid = 0, pcid = 0;
 	typeof(nf_nat_pptp_hook_inbound) nf_nat_pptp_inbound;
@@ -396,7 +396,7 @@ pptp_outbound_pkt(struct sk_buff *skb,
 		  struct nf_conn *ct,
 		  enum ip_conntrack_info ctinfo)
 {
-	struct nf_ct_pptp_master *info = &nfct_help(ct)->help.ct_pptp_info;
+	struct nf_ct_pptp_master *info = nfct_help_data(ct);
 	u_int16_t msg;
 	__be16 cid = 0, pcid = 0;
 	typeof(nf_nat_pptp_hook_outbound) nf_nat_pptp_outbound;
@@ -506,7 +506,7 @@ conntrack_pptp_help(struct sk_buff *skb, unsigned int protoff,
 
 {
 	int dir = CTINFO2DIR(ctinfo);
-	const struct nf_ct_pptp_master *info = &nfct_help(ct)->help.ct_pptp_info;
+	const struct nf_ct_pptp_master *info = nfct_help_data(ct);
 	const struct tcphdr *tcph;
 	struct tcphdr _tcph;
 	const struct pptp_pkt_hdr *pptph;
@@ -592,6 +592,7 @@ static const struct nf_conntrack_expect_policy pptp_exp_policy = {
 static struct nf_conntrack_helper pptp __read_mostly = {
 	.name			= "pptp",
 	.me			= THIS_MODULE,
+	.data_len		= sizeof(struct nf_ct_pptp_master),
 	.tuple.src.l3num	= AF_INET,
 	.tuple.src.u.tcp.port	= cpu_to_be16(PPTP_CONTROL_PORT),
 	.tuple.dst.protonum	= IPPROTO_TCP,
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 25ba5a2..5cac41c 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -117,10 +117,10 @@ int nf_ct_gre_keymap_add(struct nf_conn *ct, enum ip_conntrack_dir dir,
 {
 	struct net *net = nf_ct_net(ct);
 	struct netns_proto_gre *net_gre = gre_pernet(net);
-	struct nf_conn_help *help = nfct_help(ct);
+	struct nf_ct_pptp_master *ct_pptp_info = nfct_help_data(ct);
 	struct nf_ct_gre_keymap **kmp, *km;
 
-	kmp = &help->help.ct_pptp_info.keymap[dir];
+	kmp = &ct_pptp_info->keymap[dir];
 	if (*kmp) {
 		/* check whether it's a retransmission */
 		read_lock_bh(&net_gre->keymap_lock);
@@ -158,19 +158,19 @@ void nf_ct_gre_keymap_destroy(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
 	struct netns_proto_gre *net_gre = gre_pernet(net);
-	struct nf_conn_help *help = nfct_help(ct);
+	struct nf_ct_pptp_master *ct_pptp_info = nfct_help_data(ct);
 	enum ip_conntrack_dir dir;
 
 	pr_debug("entering for ct %p\n", ct);
 
 	write_lock_bh(&net_gre->keymap_lock);
 	for (dir = IP_CT_DIR_ORIGINAL; dir < IP_CT_DIR_MAX; dir++) {
-		if (help->help.ct_pptp_info.keymap[dir]) {
+		if (ct_pptp_info->keymap[dir]) {
 			pr_debug("removing %p from list\n",
-				 help->help.ct_pptp_info.keymap[dir]);
-			list_del(&help->help.ct_pptp_info.keymap[dir]->list);
-			kfree(help->help.ct_pptp_info.keymap[dir]);
-			help->help.ct_pptp_info.keymap[dir] = NULL;
+				 ct_pptp_info->keymap[dir]);
+			list_del(&ct_pptp_info->keymap[dir]->list);
+			kfree(ct_pptp_info->keymap[dir]);
+			ct_pptp_info->keymap[dir] = NULL;
 		}
 	}
 	write_unlock_bh(&net_gre->keymap_lock);
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index ec3fc18..295429f 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -69,13 +69,12 @@ static int help(struct sk_buff *skb,
 	void *sb_ptr;
 	int ret = NF_ACCEPT;
 	int dir = CTINFO2DIR(ctinfo);
-	struct nf_ct_sane_master *ct_sane_info;
+	struct nf_ct_sane_master *ct_sane_info = nfct_help_data(ct);
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple *tuple;
 	struct sane_request *req;
 	struct sane_reply_net_start *reply;
 
-	ct_sane_info = &nfct_help(ct)->help.ct_sane_info;
 	/* Until there's been traffic both ways, don't look in packets. */
 	if (ctinfo != IP_CT_ESTABLISHED &&
 	    ctinfo != IP_CT_ESTABLISHED_REPLY)
@@ -203,6 +202,7 @@ static int __init nf_conntrack_sane_init(void)
 		sane[i][0].tuple.src.l3num = PF_INET;
 		sane[i][1].tuple.src.l3num = PF_INET6;
 		for (j = 0; j < 2; j++) {
+			sane[i][j].data_len = sizeof(struct nf_ct_sane_master);
 			sane[i][j].tuple.src.u.tcp.port = htons(ports[i]);
 			sane[i][j].tuple.dst.protonum = IPPROTO_TCP;
 			sane[i][j].expect_policy = &sane_exp_policy;
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index dfd3ff3..758a1ba 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1075,12 +1075,12 @@ static int process_invite_response(struct sk_buff *skb, unsigned int dataoff,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
-	struct nf_conn_help *help = nfct_help(ct);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
 
 	if ((code >= 100 && code <= 199) ||
 	    (code >= 200 && code <= 299))
 		return process_sdp(skb, dataoff, dptr, datalen, cseq);
-	else if (help->help.ct_sip_info.invite_cseq == cseq)
+	else if (ct_sip_info->invite_cseq == cseq)
 		flush_expectations(ct, true);
 	return NF_ACCEPT;
 }
@@ -1091,12 +1091,12 @@ static int process_update_response(struct sk_buff *skb, unsigned int dataoff,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
-	struct nf_conn_help *help = nfct_help(ct);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
 
 	if ((code >= 100 && code <= 199) ||
 	    (code >= 200 && code <= 299))
 		return process_sdp(skb, dataoff, dptr, datalen, cseq);
-	else if (help->help.ct_sip_info.invite_cseq == cseq)
+	else if (ct_sip_info->invite_cseq == cseq)
 		flush_expectations(ct, true);
 	return NF_ACCEPT;
 }
@@ -1107,12 +1107,12 @@ static int process_prack_response(struct sk_buff *skb, unsigned int dataoff,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
-	struct nf_conn_help *help = nfct_help(ct);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
 
 	if ((code >= 100 && code <= 199) ||
 	    (code >= 200 && code <= 299))
 		return process_sdp(skb, dataoff, dptr, datalen, cseq);
-	else if (help->help.ct_sip_info.invite_cseq == cseq)
+	else if (ct_sip_info->invite_cseq == cseq)
 		flush_expectations(ct, true);
 	return NF_ACCEPT;
 }
@@ -1123,13 +1123,13 @@ static int process_invite_request(struct sk_buff *skb, unsigned int dataoff,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
-	struct nf_conn_help *help = nfct_help(ct);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
 	unsigned int ret;
 
 	flush_expectations(ct, true);
 	ret = process_sdp(skb, dataoff, dptr, datalen, cseq);
 	if (ret == NF_ACCEPT)
-		help->help.ct_sip_info.invite_cseq = cseq;
+		ct_sip_info->invite_cseq = cseq;
 	return ret;
 }
 
@@ -1154,7 +1154,7 @@ static int process_register_request(struct sk_buff *skb, unsigned int dataoff,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
-	struct nf_conn_help *help = nfct_help(ct);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	unsigned int matchoff, matchlen;
 	struct nf_conntrack_expect *exp;
@@ -1235,7 +1235,7 @@ static int process_register_request(struct sk_buff *skb, unsigned int dataoff,
 
 store_cseq:
 	if (ret == NF_ACCEPT)
-		help->help.ct_sip_info.register_cseq = cseq;
+		ct_sip_info->register_cseq = cseq;
 	return ret;
 }
 
@@ -1245,7 +1245,7 @@ static int process_register_response(struct sk_buff *skb, unsigned int dataoff,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
-	struct nf_conn_help *help = nfct_help(ct);
+	struct nf_ct_sip_master *ct_sip_info = nfct_help_data(ct);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	union nf_inet_addr addr;
 	__be16 port;
@@ -1262,7 +1262,7 @@ static int process_register_response(struct sk_buff *skb, unsigned int dataoff,
 	 * responses, so we store the sequence number of the last valid
 	 * request and compare it here.
 	 */
-	if (help->help.ct_sip_info.register_cseq != cseq)
+	if (ct_sip_info->register_cseq != cseq)
 		return NF_ACCEPT;
 
 	if (code >= 100 && code <= 199)
@@ -1578,6 +1578,7 @@ static int __init nf_conntrack_sip_init(void)
 		sip[i][3].help = sip_help_tcp;
 
 		for (j = 0; j < ARRAY_SIZE(sip[i]); j++) {
+			sip[i][j].data_len = sizeof(struct nf_ct_sip_master);
 			sip[i][j].tuple.src.u.udp.port = htons(ports[i]);
 			sip[i][j].expect_policy = sip_exp_policy;
 			sip[i][j].expect_class_max = SIP_EXPECT_MAX;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index a51de9b..1160185 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -112,6 +112,8 @@ static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 		goto err3;
 
 	if (info->helper[0]) {
+		struct nf_conntrack_helper *helper;
+
 		ret = -ENOENT;
 		proto = xt_ct_find_proto(par);
 		if (!proto) {
@@ -120,19 +122,21 @@ static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 			goto err3;
 		}
 
-		ret = -ENOMEM;
-		help = nf_ct_helper_ext_add(ct, GFP_KERNEL);
-		if (help == NULL)
-			goto err3;
-
 		ret = -ENOENT;
-		help->helper = nf_conntrack_helper_try_module_get(info->helper,
-								  par->family,
-								  proto);
-		if (help->helper == NULL) {
+		helper = nf_conntrack_helper_try_module_get(info->helper,
+							    par->family,
+							    proto);
+		if (helper == NULL) {
 			pr_info("No such helper \"%s\"\n", info->helper);
 			goto err3;
 		}
+
+		ret = -ENOMEM;
+		help = nf_ct_helper_ext_add(ct, helper, GFP_KERNEL);
+		if (help == NULL)
+			goto err3;
+
+		help->helper = helper;
 	}
 
 	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
@@ -202,6 +206,8 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 		goto err3;
 
 	if (info->helper[0]) {
+		struct nf_conntrack_helper *helper;
+
 		ret = -ENOENT;
 		proto = xt_ct_find_proto(par);
 		if (!proto) {
@@ -210,19 +216,21 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 			goto err3;
 		}
 
-		ret = -ENOMEM;
-		help = nf_ct_helper_ext_add(ct, GFP_KERNEL);
-		if (help == NULL)
-			goto err3;
-
 		ret = -ENOENT;
-		help->helper = nf_conntrack_helper_try_module_get(info->helper,
-								  par->family,
-								  proto);
-		if (help->helper == NULL) {
+		helper = nf_conntrack_helper_try_module_get(info->helper,
+							    par->family,
+							    proto);
+		if (helper == NULL) {
 			pr_info("No such helper \"%s\"\n", info->helper);
 			goto err3;
 		}
+
+		ret = -ENOMEM;
+		help = nf_ct_helper_ext_add(ct, helper, GFP_KERNEL);
+		if (help == NULL)
+			goto err3;
+
+		help->helper = helper;
 	}
 
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-- 
1.7.10
