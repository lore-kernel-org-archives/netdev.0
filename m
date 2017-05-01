From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/53] netfilter: helper: add build-time asserts for helper data size
Date: Mon,  1 May 2017 12:46:54 +0200
Message-ID: <1493635640-24325-28-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49670 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378892AbdEAKsL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:11 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 44E5C209917
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:51 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 254D6FF2CF
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:51 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F38F6FF2D3
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:48 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

add a 32 byte scratch area in the helper struct instead of relying
on variable sized helpers plus compile-time asserts to let us know
if 32 bytes aren't enough anymore.

Not having variable sized helpers will later allow to add BUILD_BUG_ON
for the total size of conntrack extensions -- the helper extension is
the only one that doesn't have a fixed size.

The (useless!) NF_CT_HELPER_BUILD_BUG_ON(0); are added so that in case
someone adds a new helper and copy-pastes from one that doesn't store
private data at least some indication that this macro should be used
somehow is there...

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_helper.h | 5 ++++-
 net/netfilter/nf_conntrack_amanda.c         | 2 ++
 net/netfilter/nf_conntrack_ftp.c            | 2 ++
 net/netfilter/nf_conntrack_h323_main.c      | 2 ++
 net/netfilter/nf_conntrack_netbios_ns.c     | 2 ++
 net/netfilter/nf_conntrack_pptp.c           | 2 ++
 net/netfilter/nf_conntrack_sane.c           | 2 ++
 net/netfilter/nf_conntrack_sip.c            | 2 ++
 net/netfilter/nf_conntrack_tftp.c           | 2 ++
 9 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 15d746558665..29539ed1008f 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -66,9 +66,12 @@ struct nf_conn_help {
 	u8 expecting[NF_CT_MAX_EXPECT_CLASSES];
 
 	/* private helper information. */
-	char data[];
+	char data[32] __aligned(8);
 };
 
+#define NF_CT_HELPER_BUILD_BUG_ON(structsize) \
+	BUILD_BUG_ON((structsize) > FIELD_SIZEOF(struct nf_conn_help, data))
+
 struct nf_conntrack_helper *__nf_conntrack_helper_find(const char *name,
 						       u16 l3num, u8 protonum);
 
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 57a26cc90c9f..03d2ccffa9fa 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -207,6 +207,8 @@ static int __init nf_conntrack_amanda_init(void)
 {
 	int ret, i;
 
+	NF_CT_HELPER_BUILD_BUG_ON(0);
+
 	for (i = 0; i < ARRAY_SIZE(search); i++) {
 		search[i].ts = textsearch_prepare(ts_algo, search[i].string,
 						  search[i].len,
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 4aecef4a89fb..58e1256cd05d 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -577,6 +577,8 @@ static int __init nf_conntrack_ftp_init(void)
 {
 	int i, ret = 0;
 
+	NF_CT_HELPER_BUILD_BUG_ON(sizeof(struct nf_ct_ftp_master));
+
 	ftp_buffer = kmalloc(65536, GFP_KERNEL);
 	if (!ftp_buffer)
 		return -ENOMEM;
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index f65d93639d12..e98204349efe 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1836,6 +1836,8 @@ static int __init nf_conntrack_h323_init(void)
 {
 	int ret;
 
+	NF_CT_HELPER_BUILD_BUG_ON(sizeof(struct nf_ct_h323_master));
+
 	h323_buffer = kmalloc(65536, GFP_KERNEL);
 	if (!h323_buffer)
 		return -ENOMEM;
diff --git a/net/netfilter/nf_conntrack_netbios_ns.c b/net/netfilter/nf_conntrack_netbios_ns.c
index 4c8f30a3d6d2..496ce173f0c1 100644
--- a/net/netfilter/nf_conntrack_netbios_ns.c
+++ b/net/netfilter/nf_conntrack_netbios_ns.c
@@ -58,6 +58,8 @@ static struct nf_conntrack_helper helper __read_mostly = {
 
 static int __init nf_conntrack_netbios_ns_init(void)
 {
+	NF_CT_HELPER_BUILD_BUG_ON(0);
+
 	exp_policy.timeout = timeout;
 	return nf_conntrack_helper_register(&helper);
 }
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index f60a4755d71e..34fac4c52c4c 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -607,6 +607,8 @@ static struct nf_conntrack_helper pptp __read_mostly = {
 
 static int __init nf_conntrack_pptp_init(void)
 {
+	NF_CT_HELPER_BUILD_BUG_ON(sizeof(struct nf_ct_pptp_master));
+
 	return nf_conntrack_helper_register(&pptp);
 }
 
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index 9dcb9ee9b97d..1121db08d048 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -184,6 +184,8 @@ static int __init nf_conntrack_sane_init(void)
 {
 	int i, ret = 0;
 
+	NF_CT_HELPER_BUILD_BUG_ON(sizeof(struct nf_ct_sane_master));
+
 	sane_buffer = kmalloc(65536, GFP_KERNEL);
 	if (!sane_buffer)
 		return -ENOMEM;
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 91a9c97b7e9a..79bbcc4d52ee 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1622,6 +1622,8 @@ static int __init nf_conntrack_sip_init(void)
 {
 	int i, ret;
 
+	NF_CT_HELPER_BUILD_BUG_ON(sizeof(struct nf_ct_sip_master));
+
 	if (ports_c == 0)
 		ports[ports_c++] = SIP_PORT;
 
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index b1227dc6f75e..27e2f6f904dc 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -113,6 +113,8 @@ static int __init nf_conntrack_tftp_init(void)
 {
 	int i, ret;
 
+	NF_CT_HELPER_BUILD_BUG_ON(0);
+
 	if (ports_c == 0)
 		ports[ports_c++] = TFTP_PORT;
 
-- 
2.1.4
