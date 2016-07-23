From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/25] netfilter: Add helper array register/unregister functions
Date: Sat, 23 Jul 2016 13:08:30 +0200
Message-ID: <1469272119-29942-17-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35953 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657AbcGWLJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:32 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 3E811E7DAE
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2A9A6FC61B
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 84931FB467
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:27 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Add nf_ct_helper_init(), nf_conntrack_helpers_register() and
nf_conntrack_helpers_unregister() functions to avoid repetitive
opencoded initialization in helpers.

This patch keeps an id parameter for nf_ct_helper_init() not to break
helper matching by name that has been inconsistently exposed to
userspace through ports, eg. ftp-2121, and through an incremental id,
eg. tftp-1.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_helper.h | 15 ++++++
 net/netfilter/nf_conntrack_ftp.c            | 58 +++++++---------------
 net/netfilter/nf_conntrack_helper.c         | 57 ++++++++++++++++++++++
 net/netfilter/nf_conntrack_irc.c            | 36 +++++---------
 net/netfilter/nf_conntrack_sane.c           | 57 ++++++++--------------
 net/netfilter/nf_conntrack_sip.c            | 75 +++++++++++------------------
 net/netfilter/nf_conntrack_tftp.c           | 48 ++++++------------
 7 files changed, 165 insertions(+), 181 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 6cf614bc..1eaac1f 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -58,10 +58,25 @@ struct nf_conntrack_helper *__nf_conntrack_helper_find(const char *name,
 struct nf_conntrack_helper *nf_conntrack_helper_try_module_get(const char *name,
 							       u16 l3num,
 							       u8 protonum);
+void nf_ct_helper_init(struct nf_conntrack_helper *helper,
+		       u16 l3num, u16 protonum, const char *name,
+		       u16 default_port, u16 spec_port, u32 id,
+		       const struct nf_conntrack_expect_policy *exp_pol,
+		       u32 expect_class_max, u32 data_len,
+		       int (*help)(struct sk_buff *skb, unsigned int protoff,
+				   struct nf_conn *ct,
+				   enum ip_conntrack_info ctinfo),
+		       int (*from_nlattr)(struct nlattr *attr,
+					  struct nf_conn *ct),
+		       struct module *module);
 
 int nf_conntrack_helper_register(struct nf_conntrack_helper *);
 void nf_conntrack_helper_unregister(struct nf_conntrack_helper *);
 
+int nf_conntrack_helpers_register(struct nf_conntrack_helper *, unsigned int);
+void nf_conntrack_helpers_unregister(struct nf_conntrack_helper *,
+				     unsigned int);
+
 struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct,
 					  struct nf_conntrack_helper *helper,
 					  gfp_t gfp);
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 19efeba..4314700 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -572,7 +572,7 @@ static int nf_ct_ftp_from_nlattr(struct nlattr *attr, struct nf_conn *ct)
 	return 0;
 }
 
-static struct nf_conntrack_helper ftp[MAX_PORTS][2] __read_mostly;
+static struct nf_conntrack_helper ftp[MAX_PORTS * 2] __read_mostly;
 
 static const struct nf_conntrack_expect_policy ftp_exp_policy = {
 	.max_expected	= 1,
@@ -582,24 +582,13 @@ static const struct nf_conntrack_expect_policy ftp_exp_policy = {
 /* don't make this __exit, since it's called from __init ! */
 static void nf_conntrack_ftp_fini(void)
 {
-	int i, j;
-	for (i = 0; i < ports_c; i++) {
-		for (j = 0; j < 2; j++) {
-			if (ftp[i][j].me == NULL)
-				continue;
-
-			pr_debug("unregistering helper for pf: %d port: %d\n",
-				 ftp[i][j].tuple.src.l3num, ports[i]);
-			nf_conntrack_helper_unregister(&ftp[i][j]);
-		}
-	}
-
+	nf_conntrack_helpers_unregister(ftp, ports_c * 2);
 	kfree(ftp_buffer);
 }
 
 static int __init nf_conntrack_ftp_init(void)
 {
-	int i, j = -1, ret = 0;
+	int i, ret = 0;
 
 	ftp_buffer = kmalloc(65536, GFP_KERNEL);
 	if (!ftp_buffer)
@@ -611,32 +600,21 @@ static int __init nf_conntrack_ftp_init(void)
 	/* FIXME should be configurable whether IPv4 and IPv6 FTP connections
 		 are tracked or not - YK */
 	for (i = 0; i < ports_c; i++) {
-		ftp[i][0].tuple.src.l3num = PF_INET;
-		ftp[i][1].tuple.src.l3num = PF_INET6;
-		for (j = 0; j < 2; j++) {
-			ftp[i][j].data_len = sizeof(struct nf_ct_ftp_master);
-			ftp[i][j].tuple.src.u.tcp.port = htons(ports[i]);
-			ftp[i][j].tuple.dst.protonum = IPPROTO_TCP;
-			ftp[i][j].expect_policy = &ftp_exp_policy;
-			ftp[i][j].me = THIS_MODULE;
-			ftp[i][j].help = help;
-			ftp[i][j].from_nlattr = nf_ct_ftp_from_nlattr;
-			if (ports[i] == FTP_PORT)
-				sprintf(ftp[i][j].name, "ftp");
-			else
-				sprintf(ftp[i][j].name, "ftp-%d", ports[i]);
-
-			pr_debug("registering helper for pf: %d port: %d\n",
-				 ftp[i][j].tuple.src.l3num, ports[i]);
-			ret = nf_conntrack_helper_register(&ftp[i][j]);
-			if (ret) {
-				pr_err("failed to register helper for pf: %d port: %d\n",
-				       ftp[i][j].tuple.src.l3num, ports[i]);
-				ports_c = i;
-				nf_conntrack_ftp_fini();
-				return ret;
-			}
-		}
+		nf_ct_helper_init(&ftp[2 * i], AF_INET, IPPROTO_TCP, "ftp",
+				  FTP_PORT, ports[i], ports[i], &ftp_exp_policy,
+				  0, sizeof(struct nf_ct_ftp_master), help,
+				  nf_ct_ftp_from_nlattr, THIS_MODULE);
+		nf_ct_helper_init(&ftp[2 * i + 1], AF_INET6, IPPROTO_TCP, "ftp",
+				  FTP_PORT, ports[i], ports[i], &ftp_exp_policy,
+				  0, sizeof(struct nf_ct_ftp_master), help,
+				  nf_ct_ftp_from_nlattr, THIS_MODULE);
+	}
+
+	ret = nf_conntrack_helpers_register(ftp, ports_c * 2);
+	if (ret < 0) {
+		pr_err("failed to register helpers\n");
+		kfree(ftp_buffer);
+		return ret;
 	}
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index a4294e9..b989b81 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -465,6 +465,63 @@ restart:
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_unregister);
 
+void nf_ct_helper_init(struct nf_conntrack_helper *helper,
+		       u16 l3num, u16 protonum, const char *name,
+		       u16 default_port, u16 spec_port, u32 id,
+		       const struct nf_conntrack_expect_policy *exp_pol,
+		       u32 expect_class_max, u32 data_len,
+		       int (*help)(struct sk_buff *skb, unsigned int protoff,
+				   struct nf_conn *ct,
+				   enum ip_conntrack_info ctinfo),
+		       int (*from_nlattr)(struct nlattr *attr,
+					  struct nf_conn *ct),
+		       struct module *module)
+{
+	helper->tuple.src.l3num = l3num;
+	helper->tuple.dst.protonum = protonum;
+	helper->tuple.src.u.all = htons(spec_port);
+	helper->expect_policy = exp_pol;
+	helper->expect_class_max = expect_class_max;
+	helper->data_len = data_len;
+	helper->help = help;
+	helper->from_nlattr = from_nlattr;
+	helper->me = module;
+
+	if (spec_port == default_port)
+		snprintf(helper->name, sizeof(helper->name), "%s", name);
+	else
+		snprintf(helper->name, sizeof(helper->name), "%s-%u", name, id);
+}
+EXPORT_SYMBOL_GPL(nf_ct_helper_init);
+
+int nf_conntrack_helpers_register(struct nf_conntrack_helper *helper,
+				  unsigned int n)
+{
+	unsigned int i;
+	int err = 0;
+
+	for (i = 0; i < n; i++) {
+		err = nf_conntrack_helper_register(&helper[i]);
+		if (err < 0)
+			goto err;
+	}
+
+	return err;
+err:
+	if (i > 0)
+		nf_conntrack_helpers_unregister(helper, i);
+	return err;
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_helpers_register);
+
+void nf_conntrack_helpers_unregister(struct nf_conntrack_helper *helper,
+				unsigned int n)
+{
+	while (n-- > 0)
+		nf_conntrack_helper_unregister(&helper[n]);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_helpers_unregister);
+
 static struct nf_ct_ext_type helper_extend __read_mostly = {
 	.len	= sizeof(struct nf_conn_help),
 	.align	= __alignof__(struct nf_conn_help),
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index f97ac61..1972a14 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -255,27 +255,18 @@ static int __init nf_conntrack_irc_init(void)
 		ports[ports_c++] = IRC_PORT;
 
 	for (i = 0; i < ports_c; i++) {
-		irc[i].tuple.src.l3num = AF_INET;
-		irc[i].tuple.src.u.tcp.port = htons(ports[i]);
-		irc[i].tuple.dst.protonum = IPPROTO_TCP;
-		irc[i].expect_policy = &irc_exp_policy;
-		irc[i].me = THIS_MODULE;
-		irc[i].help = help;
-
-		if (ports[i] == IRC_PORT)
-			sprintf(irc[i].name, "irc");
-		else
-			sprintf(irc[i].name, "irc-%u", i);
-
-		ret = nf_conntrack_helper_register(&irc[i]);
-		if (ret) {
-			pr_err("failed to register helper for pf: %u port: %u\n",
-			       irc[i].tuple.src.l3num, ports[i]);
-			ports_c = i;
-			nf_conntrack_irc_fini();
-			return ret;
-		}
+		nf_ct_helper_init(&irc[i], AF_INET, IPPROTO_TCP, "irc",
+				  IRC_PORT, ports[i], i, &irc_exp_policy,
+				  0, 0, help, NULL, THIS_MODULE);
+	}
+
+	ret = nf_conntrack_helpers_register(&irc[0], ports_c);
+	if (ret) {
+		pr_err("failed to register helpers\n");
+		kfree(irc_buffer);
+		return ret;
 	}
+
 	return 0;
 }
 
@@ -283,10 +274,7 @@ static int __init nf_conntrack_irc_init(void)
  * it is needed by the init function */
 static void nf_conntrack_irc_fini(void)
 {
-	int i;
-
-	for (i = 0; i < ports_c; i++)
-		nf_conntrack_helper_unregister(&irc[i]);
+	nf_conntrack_helpers_unregister(irc, ports_c);
 	kfree(irc_buffer);
 }
 
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index 3fcbaab..9dcb9ee 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -166,7 +166,7 @@ out:
 	return ret;
 }
 
-static struct nf_conntrack_helper sane[MAX_PORTS][2] __read_mostly;
+static struct nf_conntrack_helper sane[MAX_PORTS * 2] __read_mostly;
 
 static const struct nf_conntrack_expect_policy sane_exp_policy = {
 	.max_expected	= 1,
@@ -176,22 +176,13 @@ static const struct nf_conntrack_expect_policy sane_exp_policy = {
 /* don't make this __exit, since it's called from __init ! */
 static void nf_conntrack_sane_fini(void)
 {
-	int i, j;
-
-	for (i = 0; i < ports_c; i++) {
-		for (j = 0; j < 2; j++) {
-			pr_debug("unregistering helper for pf: %d port: %d\n",
-				 sane[i][j].tuple.src.l3num, ports[i]);
-			nf_conntrack_helper_unregister(&sane[i][j]);
-		}
-	}
-
+	nf_conntrack_helpers_unregister(sane, ports_c * 2);
 	kfree(sane_buffer);
 }
 
 static int __init nf_conntrack_sane_init(void)
 {
-	int i, j = -1, ret = 0;
+	int i, ret = 0;
 
 	sane_buffer = kmalloc(65536, GFP_KERNEL);
 	if (!sane_buffer)
@@ -203,31 +194,23 @@ static int __init nf_conntrack_sane_init(void)
 	/* FIXME should be configurable whether IPv4 and IPv6 connections
 		 are tracked or not - YK */
 	for (i = 0; i < ports_c; i++) {
-		sane[i][0].tuple.src.l3num = PF_INET;
-		sane[i][1].tuple.src.l3num = PF_INET6;
-		for (j = 0; j < 2; j++) {
-			sane[i][j].data_len = sizeof(struct nf_ct_sane_master);
-			sane[i][j].tuple.src.u.tcp.port = htons(ports[i]);
-			sane[i][j].tuple.dst.protonum = IPPROTO_TCP;
-			sane[i][j].expect_policy = &sane_exp_policy;
-			sane[i][j].me = THIS_MODULE;
-			sane[i][j].help = help;
-			if (ports[i] == SANE_PORT)
-				sprintf(sane[i][j].name, "sane");
-			else
-				sprintf(sane[i][j].name, "sane-%d", ports[i]);
-
-			pr_debug("registering helper for pf: %d port: %d\n",
-				 sane[i][j].tuple.src.l3num, ports[i]);
-			ret = nf_conntrack_helper_register(&sane[i][j]);
-			if (ret) {
-				pr_err("failed to register helper for pf: %d port: %d\n",
-				       sane[i][j].tuple.src.l3num, ports[i]);
-				ports_c = i;
-				nf_conntrack_sane_fini();
-				return ret;
-			}
-		}
+		nf_ct_helper_init(&sane[2 * i], AF_INET, IPPROTO_TCP, "sane",
+				  SANE_PORT, ports[i], ports[i],
+				  &sane_exp_policy, 0,
+				  sizeof(struct nf_ct_sane_master), help, NULL,
+				  THIS_MODULE);
+		nf_ct_helper_init(&sane[2 * i + 1], AF_INET6, IPPROTO_TCP, "sane",
+				  SANE_PORT, ports[i], ports[i],
+				  &sane_exp_policy, 0,
+				  sizeof(struct nf_ct_sane_master), help, NULL,
+				  THIS_MODULE);
+	}
+
+	ret = nf_conntrack_helpers_register(sane, ports_c * 2);
+	if (ret < 0) {
+		pr_err("failed to register helpers\n");
+		kfree(sane_buffer);
+		return ret;
 	}
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index f72ba55..8d9db9d 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1589,7 +1589,7 @@ static int sip_help_udp(struct sk_buff *skb, unsigned int protoff,
 	return process_sip_msg(skb, ct, protoff, dataoff, &dptr, &datalen);
 }
 
-static struct nf_conntrack_helper sip[MAX_PORTS][4] __read_mostly;
+static struct nf_conntrack_helper sip[MAX_PORTS * 4] __read_mostly;
 
 static const struct nf_conntrack_expect_policy sip_exp_policy[SIP_EXPECT_MAX + 1] = {
 	[SIP_EXPECT_SIGNALLING] = {
@@ -1616,20 +1616,12 @@ static const struct nf_conntrack_expect_policy sip_exp_policy[SIP_EXPECT_MAX + 1
 
 static void nf_conntrack_sip_fini(void)
 {
-	int i, j;
-
-	for (i = 0; i < ports_c; i++) {
-		for (j = 0; j < ARRAY_SIZE(sip[i]); j++) {
-			if (sip[i][j].me == NULL)
-				continue;
-			nf_conntrack_helper_unregister(&sip[i][j]);
-		}
-	}
+	nf_conntrack_helpers_unregister(sip, ports_c * 4);
 }
 
 static int __init nf_conntrack_sip_init(void)
 {
-	int i, j, ret;
+	int i, ret;
 
 	if (ports_c == 0)
 		ports[ports_c++] = SIP_PORT;
@@ -1637,43 +1629,32 @@ static int __init nf_conntrack_sip_init(void)
 	for (i = 0; i < ports_c; i++) {
 		memset(&sip[i], 0, sizeof(sip[i]));
 
-		sip[i][0].tuple.src.l3num = AF_INET;
-		sip[i][0].tuple.dst.protonum = IPPROTO_UDP;
-		sip[i][0].help = sip_help_udp;
-		sip[i][1].tuple.src.l3num = AF_INET;
-		sip[i][1].tuple.dst.protonum = IPPROTO_TCP;
-		sip[i][1].help = sip_help_tcp;
-
-		sip[i][2].tuple.src.l3num = AF_INET6;
-		sip[i][2].tuple.dst.protonum = IPPROTO_UDP;
-		sip[i][2].help = sip_help_udp;
-		sip[i][3].tuple.src.l3num = AF_INET6;
-		sip[i][3].tuple.dst.protonum = IPPROTO_TCP;
-		sip[i][3].help = sip_help_tcp;
-
-		for (j = 0; j < ARRAY_SIZE(sip[i]); j++) {
-			sip[i][j].data_len = sizeof(struct nf_ct_sip_master);
-			sip[i][j].tuple.src.u.udp.port = htons(ports[i]);
-			sip[i][j].expect_policy = sip_exp_policy;
-			sip[i][j].expect_class_max = SIP_EXPECT_MAX;
-			sip[i][j].me = THIS_MODULE;
-
-			if (ports[i] == SIP_PORT)
-				sprintf(sip[i][j].name, "sip");
-			else
-				sprintf(sip[i][j].name, "sip-%u", i);
-
-			pr_debug("port #%u: %u\n", i, ports[i]);
+		nf_ct_helper_init(&sip[4 * i], AF_INET, IPPROTO_UDP, "sip",
+				  SIP_PORT, ports[i], i, sip_exp_policy,
+				  SIP_EXPECT_MAX,
+				  sizeof(struct nf_ct_sip_master), sip_help_udp,
+				  NULL, THIS_MODULE);
+		nf_ct_helper_init(&sip[4 * i + 1], AF_INET, IPPROTO_TCP, "sip",
+				  SIP_PORT, ports[i], i, sip_exp_policy,
+				  SIP_EXPECT_MAX,
+				  sizeof(struct nf_ct_sip_master), sip_help_tcp,
+				  NULL, THIS_MODULE);
+		nf_ct_helper_init(&sip[4 * i + 2], AF_INET6, IPPROTO_UDP, "sip",
+				  SIP_PORT, ports[i], i, sip_exp_policy,
+				  SIP_EXPECT_MAX,
+				  sizeof(struct nf_ct_sip_master), sip_help_udp,
+				  NULL, THIS_MODULE);
+		nf_ct_helper_init(&sip[4 * i + 3], AF_INET6, IPPROTO_TCP, "sip",
+				  SIP_PORT, ports[i], i, sip_exp_policy,
+				  SIP_EXPECT_MAX,
+				  sizeof(struct nf_ct_sip_master), sip_help_tcp,
+				  NULL, THIS_MODULE);
+	}
 
-			ret = nf_conntrack_helper_register(&sip[i][j]);
-			if (ret) {
-				pr_err("failed to register helper for pf: %u port: %u\n",
-				       sip[i][j].tuple.src.l3num, ports[i]);
-				ports_c = i;
-				nf_conntrack_sip_fini();
-				return ret;
-			}
-		}
+	ret = nf_conntrack_helpers_register(sip, ports_c * 4);
+	if (ret < 0) {
+		pr_err("failed to register helpers\n");
+		return ret;
 	}
 	return 0;
 }
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 2e65b543..b1227dc 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -97,7 +97,7 @@ static int tftp_help(struct sk_buff *skb,
 	return ret;
 }
 
-static struct nf_conntrack_helper tftp[MAX_PORTS][2] __read_mostly;
+static struct nf_conntrack_helper tftp[MAX_PORTS * 2] __read_mostly;
 
 static const struct nf_conntrack_expect_policy tftp_exp_policy = {
 	.max_expected	= 1,
@@ -106,47 +106,29 @@ static const struct nf_conntrack_expect_policy tftp_exp_policy = {
 
 static void nf_conntrack_tftp_fini(void)
 {
-	int i, j;
-
-	for (i = 0; i < ports_c; i++) {
-		for (j = 0; j < 2; j++)
-			nf_conntrack_helper_unregister(&tftp[i][j]);
-	}
+	nf_conntrack_helpers_unregister(tftp, ports_c * 2);
 }
 
 static int __init nf_conntrack_tftp_init(void)
 {
-	int i, j, ret;
+	int i, ret;
 
 	if (ports_c == 0)
 		ports[ports_c++] = TFTP_PORT;
 
 	for (i = 0; i < ports_c; i++) {
-		memset(&tftp[i], 0, sizeof(tftp[i]));
-
-		tftp[i][0].tuple.src.l3num = AF_INET;
-		tftp[i][1].tuple.src.l3num = AF_INET6;
-		for (j = 0; j < 2; j++) {
-			tftp[i][j].tuple.dst.protonum = IPPROTO_UDP;
-			tftp[i][j].tuple.src.u.udp.port = htons(ports[i]);
-			tftp[i][j].expect_policy = &tftp_exp_policy;
-			tftp[i][j].me = THIS_MODULE;
-			tftp[i][j].help = tftp_help;
-
-			if (ports[i] == TFTP_PORT)
-				sprintf(tftp[i][j].name, "tftp");
-			else
-				sprintf(tftp[i][j].name, "tftp-%u", i);
-
-			ret = nf_conntrack_helper_register(&tftp[i][j]);
-			if (ret) {
-				pr_err("failed to register helper for pf: %u port: %u\n",
-				       tftp[i][j].tuple.src.l3num, ports[i]);
-				ports_c = i;
-				nf_conntrack_tftp_fini();
-				return ret;
-			}
-		}
+		nf_ct_helper_init(&tftp[2 * i], AF_INET, IPPROTO_UDP, "tftp",
+				  TFTP_PORT, ports[i], i, &tftp_exp_policy,
+				  0, 0, tftp_help, NULL, THIS_MODULE);
+		nf_ct_helper_init(&tftp[2 * i + 1], AF_INET6, IPPROTO_UDP, "tftp",
+				  TFTP_PORT, ports[i], i, &tftp_exp_policy,
+				  0, 0, tftp_help, NULL, THIS_MODULE);
+	}
+
+	ret = nf_conntrack_helpers_register(tftp, ports_c * 2);
+	if (ret < 0) {
+		pr_err("failed to register helpers\n");
+		return ret;
 	}
 	return 0;
 }
-- 
2.1.4
