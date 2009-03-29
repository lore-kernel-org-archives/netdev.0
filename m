From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 1/3] netfilter: fix endian bug in conntrack printks
Date: Sat, 28 Mar 2009 18:38:30 -0700
Message-ID: <1238290710.3492.8.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:19924 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbZC2Big (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 21:38:36 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1877361rvb.1
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2009 18:38:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dcc_ip is treated as a host-endian value in the first printk,
but the second printk uses %pI4 which expects a be32.  This
will cause a mismatch between the debug statement and the
warning statement.

Treat as a be32 throughout and avoid some byteswapping during
some comparisions, and allow another user of HIPQUAD to bite the
dust.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, this is probably suitable for 2.6.30 as a bugfix, I include the other
removal patch only because it is the last user of HIPQUAD.

 net/netfilter/nf_conntrack_irc.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 409c8be..c2e3c52 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -66,7 +66,7 @@ static const char *const dccprotos[] = {
  *	ad_beg_p	returns pointer to first byte of addr data
  *	ad_end_p	returns pointer to last byte of addr data
  */
-static int parse_dcc(char *data, const char *data_end, u_int32_t *ip,
+static int parse_dcc(char *data, const char *data_end, __be32 *ip,
 		     u_int16_t *port, char **ad_beg_p, char **ad_end_p)
 {
 	char *tmp;
@@ -85,7 +85,7 @@ static int parse_dcc(char *data, const char *data_end, u_int32_t *ip,
 		return -1;
 
 	*ad_beg_p = data;
-	*ip = simple_strtoul(data, &data, 10);
+	*ip = cpu_to_be32(simple_strtoul(data, &data, 10));
 
 	/* skip blanks between ip and port */
 	while (*data == ' ') {
@@ -112,7 +112,7 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 	int dir = CTINFO2DIR(ctinfo);
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple *tuple;
-	u_int32_t dcc_ip;
+	__be32 dcc_ip;
 	u_int16_t dcc_port;
 	__be16 port;
 	int i, ret = NF_ACCEPT;
@@ -177,13 +177,14 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 				pr_debug("unable to parse dcc command\n");
 				continue;
 			}
-			pr_debug("DCC bound ip/port: %u.%u.%u.%u:%u\n",
-				 HIPQUAD(dcc_ip), dcc_port);
+			
+			pr_debug("DCC bound ip/port: %pI4:%u\n",
+				 &dcc_ip, dcc_port);
 
 			/* dcc_ip can be the internal OR external (NAT'ed) IP */
 			tuple = &ct->tuplehash[dir].tuple;
-			if (tuple->src.u3.ip != htonl(dcc_ip) &&
-			    tuple->dst.u3.ip != htonl(dcc_ip)) {
+			if (tuple->src.u3.ip != dcc_ip &&
+			    tuple->dst.u3.ip != dcc_ip) {
 				if (net_ratelimit())
 					printk(KERN_WARNING
 						"Forged DCC command from %pI4: %pI4:%u\n",
-- 
1.6.2.1.507.g0e68d


