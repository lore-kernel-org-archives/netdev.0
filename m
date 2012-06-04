From: pablo@netfilter.org
Subject: [PATCH 1/7] netfilter: nf_ct_helper: allocate 16 bytes for the helper and policy names
Date: Mon,  4 Jun 2012 14:21:19 +0200
Message-ID: <1338812485-4232-2-git-send-email-pablo@netfilter.org>
References: <1338812485-4232-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1338812485-4232-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch modifies the struct nf_conntrack_helper to allocate
the room for the helper name. The maximum length is 16 bytes
(this was already introduced in 2.6.24).

For the maximum length for expectation policy names, I have
also selected 16 bytes.

This patch is required by the follow-up patch to support
user-space connection tracking helpers.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_expect.h |    4 +++-
 include/net/netfilter/nf_conntrack_helper.h |    2 +-
 net/netfilter/nf_conntrack_ftp.c            |    8 ++------
 net/netfilter/nf_conntrack_irc.c            |    8 ++------
 net/netfilter/nf_conntrack_sane.c           |    8 ++------
 net/netfilter/nf_conntrack_sip.c            |    7 ++-----
 net/netfilter/nf_conntrack_tftp.c           |    8 ++------
 7 files changed, 14 insertions(+), 31 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 4619caa..983f002 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -59,10 +59,12 @@ static inline struct net *nf_ct_exp_net(struct nf_conntrack_expect *exp)
 	return nf_ct_net(exp->master);
 }
 
+#define NF_CT_EXP_POLICY_NAME_LEN	16
+
 struct nf_conntrack_expect_policy {
 	unsigned int	max_expected;
 	unsigned int	timeout;
-	const char	*name;
+	char		name[NF_CT_EXP_POLICY_NAME_LEN];
 };
 
 #define NF_CT_EXPECT_CLASS_DEFAULT	0
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 1d18894..5f5a4d9 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -19,7 +19,7 @@ struct module;
 struct nf_conntrack_helper {
 	struct hlist_node hnode;	/* Internal use. */
 
-	const char *name;		/* name of the module */
+	char name[NF_CT_HELPER_NAME_LEN]; /* name of the module */
 	struct module *me;		/* pointer to self */
 	const struct nf_conntrack_expect_policy *expect_policy;
 
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 8c5c95c..44e47c9 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -512,7 +512,6 @@ out_update_nl:
 }
 
 static struct nf_conntrack_helper ftp[MAX_PORTS][2] __read_mostly;
-static char ftp_names[MAX_PORTS][2][sizeof("ftp-65535")] __read_mostly;
 
 static const struct nf_conntrack_expect_policy ftp_exp_policy = {
 	.max_expected	= 1,
@@ -541,7 +540,6 @@ static void nf_conntrack_ftp_fini(void)
 static int __init nf_conntrack_ftp_init(void)
 {
 	int i, j = -1, ret = 0;
-	char *tmpname;
 
 	ftp_buffer = kmalloc(65536, GFP_KERNEL);
 	if (!ftp_buffer)
@@ -561,12 +559,10 @@ static int __init nf_conntrack_ftp_init(void)
 			ftp[i][j].expect_policy = &ftp_exp_policy;
 			ftp[i][j].me = THIS_MODULE;
 			ftp[i][j].help = help;
-			tmpname = &ftp_names[i][j][0];
 			if (ports[i] == FTP_PORT)
-				sprintf(tmpname, "ftp");
+				sprintf(ftp[i][j].name, "ftp");
 			else
-				sprintf(tmpname, "ftp-%d", ports[i]);
-			ftp[i][j].name = tmpname;
+				sprintf(ftp[i][j].name, "ftp-%d", ports[i]);
 
 			pr_debug("nf_ct_ftp: registering helper for pf: %d "
 				 "port: %d\n",
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 4f9390b..f6342dd 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -223,7 +223,6 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 }
 
 static struct nf_conntrack_helper irc[MAX_PORTS] __read_mostly;
-static char irc_names[MAX_PORTS][sizeof("irc-65535")] __read_mostly;
 static struct nf_conntrack_expect_policy irc_exp_policy;
 
 static void nf_conntrack_irc_fini(void);
@@ -231,7 +230,6 @@ static void nf_conntrack_irc_fini(void);
 static int __init nf_conntrack_irc_init(void)
 {
 	int i, ret;
-	char *tmpname;
 
 	if (max_dcc_channels < 1) {
 		printk(KERN_ERR "nf_ct_irc: max_dcc_channels must not be zero\n");
@@ -257,12 +255,10 @@ static int __init nf_conntrack_irc_init(void)
 		irc[i].me = THIS_MODULE;
 		irc[i].help = help;
 
-		tmpname = &irc_names[i][0];
 		if (ports[i] == IRC_PORT)
-			sprintf(tmpname, "irc");
+			sprintf(irc[i].name, "irc");
 		else
-			sprintf(tmpname, "irc-%u", i);
-		irc[i].name = tmpname;
+			sprintf(irc[i].name, "irc-%u", i);
 
 		ret = nf_conntrack_helper_register(&irc[i]);
 		if (ret) {
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index 8501823..ec3fc18 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -163,7 +163,6 @@ out:
 }
 
 static struct nf_conntrack_helper sane[MAX_PORTS][2] __read_mostly;
-static char sane_names[MAX_PORTS][2][sizeof("sane-65535")] __read_mostly;
 
 static const struct nf_conntrack_expect_policy sane_exp_policy = {
 	.max_expected	= 1,
@@ -190,7 +189,6 @@ static void nf_conntrack_sane_fini(void)
 static int __init nf_conntrack_sane_init(void)
 {
 	int i, j = -1, ret = 0;
-	char *tmpname;
 
 	sane_buffer = kmalloc(65536, GFP_KERNEL);
 	if (!sane_buffer)
@@ -210,12 +208,10 @@ static int __init nf_conntrack_sane_init(void)
 			sane[i][j].expect_policy = &sane_exp_policy;
 			sane[i][j].me = THIS_MODULE;
 			sane[i][j].help = help;
-			tmpname = &sane_names[i][j][0];
 			if (ports[i] == SANE_PORT)
-				sprintf(tmpname, "sane");
+				sprintf(sane[i][j].name, "sane");
 			else
-				sprintf(tmpname, "sane-%d", ports[i]);
-			sane[i][j].name = tmpname;
+				sprintf(sane[i][j].name, "sane-%d", ports[i]);
 
 			pr_debug("nf_ct_sane: registering helper for pf: %d "
 				 "port: %d\n",
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 6a9c9aa..c2daabe 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1573,7 +1573,6 @@ static void nf_conntrack_sip_fini(void)
 static int __init nf_conntrack_sip_init(void)
 {
 	int i, j, ret;
-	char *tmpname;
 
 	if (ports_c == 0)
 		ports[ports_c++] = SIP_PORT;
@@ -1601,12 +1600,10 @@ static int __init nf_conntrack_sip_init(void)
 			sip[i][j].expect_class_max = SIP_EXPECT_MAX;
 			sip[i][j].me = THIS_MODULE;
 
-			tmpname = &sip_names[i][j][0];
 			if (ports[i] == SIP_PORT)
-				sprintf(tmpname, "sip");
+				sprintf(sip_names[i][j], "sip");
 			else
-				sprintf(tmpname, "sip-%u", i);
-			sip[i][j].name = tmpname;
+				sprintf(sip_names[i][j], "sip-%u", i);
 
 			pr_debug("port #%u: %u\n", i, ports[i]);
 
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 75466fd..81fc61c 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -92,7 +92,6 @@ static int tftp_help(struct sk_buff *skb,
 }
 
 static struct nf_conntrack_helper tftp[MAX_PORTS][2] __read_mostly;
-static char tftp_names[MAX_PORTS][2][sizeof("tftp-65535")] __read_mostly;
 
 static const struct nf_conntrack_expect_policy tftp_exp_policy = {
 	.max_expected	= 1,
@@ -112,7 +111,6 @@ static void nf_conntrack_tftp_fini(void)
 static int __init nf_conntrack_tftp_init(void)
 {
 	int i, j, ret;
-	char *tmpname;
 
 	if (ports_c == 0)
 		ports[ports_c++] = TFTP_PORT;
@@ -129,12 +127,10 @@ static int __init nf_conntrack_tftp_init(void)
 			tftp[i][j].me = THIS_MODULE;
 			tftp[i][j].help = tftp_help;
 
-			tmpname = &tftp_names[i][j][0];
 			if (ports[i] == TFTP_PORT)
-				sprintf(tmpname, "tftp");
+				sprintf(tftp[i][j].name, "tftp");
 			else
-				sprintf(tmpname, "tftp-%u", i);
-			tftp[i][j].name = tmpname;
+				sprintf(tftp[i][j].name, "tftp-%u", i);
 
 			ret = nf_conntrack_helper_register(&tftp[i][j]);
 			if (ret) {
-- 
1.7.10

