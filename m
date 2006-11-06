From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [DECNET] Endian bug fixes
Date: Mon, 06 Nov 2006 11:50:08 +0000
Message-ID: <1162813808.18219.46.camel@quoit.chygwyn.com>
References: <1162809062.27980.311.camel@quoit.chygwyn.com>
	 <20061106103243.GF29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-NqH8lNItdDrn+HvFrm6A"
Cc: Patrick Caulfield <patrick@tykepenguin.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:63878 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1752655AbWKFLsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 06:48:03 -0500
To: Al Viro <viro@ftp.linux.org.uk>
In-Reply-To: <20061106103243.GF29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-NqH8lNItdDrn+HvFrm6A
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

On Mon, 2006-11-06 at 10:32 +0000, Al Viro wrote:
> On Mon, Nov 06, 2006 at 10:31:02AM +0000, Steven Whitehouse wrote:
> > +	opt->opt_optl   = dn_htons((__u16)*ptr++);
> 
> Lose that cast; it's only confusing the things...
> 
> > +	memcpy(opt->opt_data, ptr, dn_ntohs(opt->opt_optl));
> > +	skb_pull(skb, dn_ntohs(opt->opt_optl) + 1);
> 
> ... and I'd actually do
> 
> 	u16 len = *ptr++; /* yes, it's 8bit on the wire */
> 	opt->opt_optl   = dn_htons(len);
> 	BUG_ON(len > 16); /* we've checked the contents earlier */
> 	memcpy(opt->opt_data, ptr, len);
> 	skb_pull(skb, len + 1);

Ok, and I've also made the same change in the other places too, so far
as its relevant in those cases. New patch attached,

Steve.


--=-NqH8lNItdDrn+HvFrm6A
Content-Disposition: attachment; filename=0001-DECNET-Endianess-fixes-try-2.txt
Content-Type: text/plain; name=0001-DECNET-Endianess-fixes-try-2.txt; charset=utf-8
Content-Transfer-Encoding: 7bit

>From a184f89a13fa292589f309057cc0775a8256a89e Mon Sep 17 00:00:00 2001
From: Steven Whitehouse <swhiteho@redhat.com>
Date: Mon, 6 Nov 2006 11:51:00 -0500
Subject: [DECNET] Endianess fixes (try #2)

Here are some fixes to endianess problems spotted by Al Viro.

Cc: Al Viro <viro@ftp.linux.org.uk>
Cc: Patrick Caulfield <patrick@tykepenguin.com>
Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>
---
 net/decnet/af_decnet.c  |   25 +++++++++++++------------
 net/decnet/dn_nsp_in.c  |    8 ++++----
 net/decnet/dn_nsp_out.c |    2 +-
 net/decnet/dn_rules.c   |    4 ++--
 4 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 3456cd3..21f20f2 100644
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
@@ -1016,13 +1016,14 @@ static void dn_access_copy(struct sk_buf
 
 static void dn_user_copy(struct sk_buff *skb, struct optdata_dn *opt)
 {
-        unsigned char *ptr = skb->data;
-        
-        opt->opt_optl   = *ptr++;
-        opt->opt_status = 0;
-        memcpy(opt->opt_data, ptr, opt->opt_optl);
-        skb_pull(skb, dn_ntohs(opt->opt_optl) + 1);
-
+	unsigned char *ptr = skb->data;
+	u16 len = *ptr++; /* yes, it's 8bit on the wire */
+
+	BUG_ON(len > 16); /* we've checked the contents earlier */
+	opt->opt_optl   = dn_htons(len);
+	opt->opt_status = 0;
+	memcpy(opt->opt_data, ptr, len);
+	skb_pull(skb, len + 1);
 }
 
 static struct sk_buff *dn_wait_for_connect(struct sock *sk, long *timeo)
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 72ecc6e..7683d4f 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -360,9 +360,9 @@ static void dn_nsp_conn_conf(struct sock
 			scp->max_window = decnet_no_fc_max_cwnd;
 
 		if (skb->len > 0) {
-			unsigned char dlen = *skb->data;
+			u16 dlen = *skb->data;
 			if ((dlen <= 16) && (dlen <= skb->len)) {
-				scp->conndata_in.opt_optl = dn_htons((__u16)dlen);
+				scp->conndata_in.opt_optl = dn_htons(dlen);
 				memcpy(scp->conndata_in.opt_data, skb->data + 1, dlen);
 			}
 		}
@@ -404,9 +404,9 @@ static void dn_nsp_disc_init(struct sock
 	memset(scp->discdata_in.opt_data, 0, 16);
 
 	if (skb->len > 0) {
-		unsigned char dlen = *skb->data;
+		u16 dlen = *skb->data;
 		if ((dlen <= 16) && (dlen <= skb->len)) {
-			scp->discdata_in.opt_optl = dn_htons((__u16)dlen);
+			scp->discdata_in.opt_optl = dn_htons(dlen);
 			memcpy(scp->discdata_in.opt_data, skb->data + 1, dlen);
 		}
 	}
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index c2e21cd..b342e4e 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -526,7 +526,7 @@ void dn_send_conn_conf(struct sock *sk, 
         struct nsp_conn_init_msg *msg;
 	__u8 len = (__u8)dn_ntohs(scp->conndata_out.opt_optl);
 
-	if ((skb = dn_alloc_skb(sk, 50 + dn_ntohs(scp->conndata_out.opt_optl), gfp)) == NULL)
+	if ((skb = dn_alloc_skb(sk, 50 + len, gfp)) == NULL)
 		return;
 
         msg = (struct nsp_conn_init_msg *)skb_put(skb, sizeof(*msg));
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


--=-NqH8lNItdDrn+HvFrm6A--

