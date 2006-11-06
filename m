From: Steven Whitehouse <swhiteho@redhat.com>
Subject: [DECNET] Endian bug fixes
Date: Mon, 06 Nov 2006 10:31:02 +0000
Message-ID: <1162809062.27980.311.camel@quoit.chygwyn.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-QoOdcaCdDG+Tey2jYbLd"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:21670 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1423790AbWKFK2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 05:28:52 -0500
To: Patrick Caulfield <patrick@tykepenguin.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QoOdcaCdDG+Tey2jYbLd
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

Here is a patch which fixes some endianess problems. Patrick: since you
have both big & little endian machines at your disposal, can you test to
ensure this is ok? Thanks,

Steve.


--=-QoOdcaCdDG+Tey2jYbLd
Content-Description: Patch to fix DECnet endianess bugs
Content-Disposition: attachment; filename=0001-DECNET-Endianess-fixes.txt
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

>From ed3de950e89f8b02302308a2bedd59123ff3b88e Mon Sep 17 00:00:00 2001
From: Steven Whitehouse <swhiteho@redhat.com>
Date: Mon, 6 Nov 2006 10:30:30 -0500
Subject: [PATCH] [DECNET] Endianess fixes

Here are some fixes to endianess problems spotted by Al Viro.

Cc: Al Viro <viro@ftp.linux.org.uk>
Cc: Patrick Caulfield <patrick@tykepenguin.com>
Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>
---
 net/decnet/af_decnet.c |   21 ++++++++++-----------
 net/decnet/dn_rules.c  |    4 ++--
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 3456cd3..37b4720 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -166,7 +166,7 @@ static struct hlist_head *dn_find_list(s
 	if (scp->addr.sdn_flags & SDF_WILD)
 		return hlist_empty(&dn_wild_sk) ? &dn_wild_sk : NULL;
 
-	return &dn_sk_hash[scp->addrloc & DN_SK_HASH_MASK];
+	return &dn_sk_hash[dn_ntohs(scp->addrloc) & DN_SK_HASH_MASK];
 }
 
 /* 
@@ -180,7 +180,7 @@ static int check_port(__le16 port)
 	if (port == 0)
 		return -1;
 
-	sk_for_each(sk, node, &dn_sk_hash[port & DN_SK_HASH_MASK]) {
+	sk_for_each(sk, node, &dn_sk_hash[dn_ntohs(port) & DN_SK_HASH_MASK]) {
 		struct dn_scp *scp = DN_SK(sk);
 		if (scp->addrloc == port)
 			return -1;
@@ -194,12 +194,12 @@ static unsigned short port_alloc(struct 
 static unsigned short port = 0x2000;
 	unsigned short i_port = port;
 
-	while(check_port(++port) != 0) {
+	while(check_port(dn_htons(++port)) != 0) {
 		if (port == i_port)
 			return 0;
 	}
 
-	scp->addrloc = port;
+	scp->addrloc = dn_htons(port);
 
 	return 1;
 }
@@ -418,7 +418,7 @@ struct sock *dn_find_by_skb(struct sk_bu
 	struct dn_scp *scp;
 
 	read_lock(&dn_hash_lock);
-	sk_for_each(sk, node, &dn_sk_hash[cb->dst_port & DN_SK_HASH_MASK]) {
+	sk_for_each(sk, node, &dn_sk_hash[dn_ntohs(cb->dst_port) & DN_SK_HASH_MASK]) {
 		scp = DN_SK(sk);
 		if (cb->src != dn_saddr2dn(&scp->peer))
 			continue;
@@ -1016,13 +1016,12 @@ static void dn_access_copy(struct sk_buf
 
 static void dn_user_copy(struct sk_buff *skb, struct optdata_dn *opt)
 {
-        unsigned char *ptr = skb->data;
-        
-        opt->opt_optl   = *ptr++;
-        opt->opt_status = 0;
-        memcpy(opt->opt_data, ptr, opt->opt_optl);
-        skb_pull(skb, dn_ntohs(opt->opt_optl) + 1);
+	unsigned char *ptr = skb->data;
 
+	opt->opt_optl   = dn_htons((__u16)*ptr++);
+	opt->opt_status = 0;
+	memcpy(opt->opt_data, ptr, dn_ntohs(opt->opt_optl));
+	skb_pull(skb, dn_ntohs(opt->opt_optl) + 1);
 }
 
 static struct sk_buff *dn_wait_for_connect(struct sock *sk, long *timeo)
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 3e0c882..590e0a7 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -124,8 +124,8 @@ static struct nla_policy dn_fib_rule_pol
 static int dn_fib_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 {
 	struct dn_fib_rule *r = (struct dn_fib_rule *)rule;
-	u16 daddr = fl->fld_dst;
-	u16 saddr = fl->fld_src;
+	__le16 daddr = fl->fld_dst;
+	__le16 saddr = fl->fld_src;
 
 	if (((saddr ^ r->src) & r->srcmask) ||
 	    ((daddr ^ r->dst) & r->dstmask))
-- 
1.4.1


--=-QoOdcaCdDG+Tey2jYbLd--

