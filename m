From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 31/47] netfilter: nf_nat_h323: fix logical-not-parentheses warning
Date: Mon,  4 Sep 2017 00:40:19 +0200
Message-ID: <1504478435-13160-9-git-send-email-pablo@netfilter.org>
References: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52750 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753302AbdICWk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:40:59 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F1BDF190F6C
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E396AB5059
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:31 +0200 (CEST)
In-Reply-To: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Desaulniers <ndesaulniers@google.com>

Clang produces the following warning:

net/ipv4/netfilter/nf_nat_h323.c:553:6: error:
logical not is only applied to the left hand side of this comparison
  [-Werror,-Wlogical-not-parentheses]
if (!set_h225_addr(skb, protoff, data, dataoff, taddr,
    ^
add parentheses after the '!' to evaluate the comparison first
add parentheses around left hand side expression to silence this warning

There's not necessarily a bug here, but it's cleaner to return early,
ex:

if (x)
  return
...

rather than:

if (x == 0)
  ...
else
  return

Also added a return code check that seemed to be missing in one
instance.

Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_h323.c | 57 +++++++++++++++++++++-------------------
 1 file changed, 30 insertions(+), 27 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 574f7ebba0b6..ac8342dcb55e 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -252,16 +252,16 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	if (set_h245_addr(skb, protoff, data, dataoff, taddr,
 			  &ct->tuplehash[!dir].tuple.dst.u3,
 			  htons((port & htons(1)) ? nated_port + 1 :
-						    nated_port)) == 0) {
-		/* Save ports */
-		info->rtp_port[i][dir] = rtp_port;
-		info->rtp_port[i][!dir] = htons(nated_port);
-	} else {
+						    nated_port))) {
 		nf_ct_unexpect_related(rtp_exp);
 		nf_ct_unexpect_related(rtcp_exp);
 		return -1;
 	}
 
+	/* Save ports */
+	info->rtp_port[i][dir] = rtp_port;
+	info->rtp_port[i][!dir] = htons(nated_port);
+
 	/* Success */
 	pr_debug("nf_nat_h323: expect RTP %pI4:%hu->%pI4:%hu\n",
 		 &rtp_exp->tuple.src.u3.ip,
@@ -370,15 +370,15 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 	/* Modify signal */
 	if (set_h225_addr(skb, protoff, data, dataoff, taddr,
 			  &ct->tuplehash[!dir].tuple.dst.u3,
-			  htons(nated_port)) == 0) {
-		/* Save ports */
-		info->sig_port[dir] = port;
-		info->sig_port[!dir] = htons(nated_port);
-	} else {
+			  htons(nated_port))) {
 		nf_ct_unexpect_related(exp);
 		return -1;
 	}
 
+	/* Save ports */
+	info->sig_port[dir] = port;
+	info->sig_port[!dir] = htons(nated_port);
+
 	pr_debug("nf_nat_q931: expect H.245 %pI4:%hu->%pI4:%hu\n",
 		 &exp->tuple.src.u3.ip,
 		 ntohs(exp->tuple.src.u.tcp.port),
@@ -462,24 +462,27 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 	/* Modify signal */
 	if (set_h225_addr(skb, protoff, data, 0, &taddr[idx],
 			  &ct->tuplehash[!dir].tuple.dst.u3,
-			  htons(nated_port)) == 0) {
-		/* Save ports */
-		info->sig_port[dir] = port;
-		info->sig_port[!dir] = htons(nated_port);
-
-		/* Fix for Gnomemeeting */
-		if (idx > 0 &&
-		    get_h225_addr(ct, *data, &taddr[0], &addr, &port) &&
-		    (ntohl(addr.ip) & 0xff000000) == 0x7f000000) {
-			set_h225_addr(skb, protoff, data, 0, &taddr[0],
-				      &ct->tuplehash[!dir].tuple.dst.u3,
-				      info->sig_port[!dir]);
-		}
-	} else {
+			  htons(nated_port))) {
 		nf_ct_unexpect_related(exp);
 		return -1;
 	}
 
+	/* Save ports */
+	info->sig_port[dir] = port;
+	info->sig_port[!dir] = htons(nated_port);
+
+	/* Fix for Gnomemeeting */
+	if (idx > 0 &&
+	    get_h225_addr(ct, *data, &taddr[0], &addr, &port) &&
+	    (ntohl(addr.ip) & 0xff000000) == 0x7f000000) {
+		if (set_h225_addr(skb, protoff, data, 0, &taddr[0],
+				  &ct->tuplehash[!dir].tuple.dst.u3,
+				  info->sig_port[!dir])) {
+			nf_ct_unexpect_related(exp);
+			return -1;
+		}
+	}
+
 	/* Success */
 	pr_debug("nf_nat_ras: expect Q.931 %pI4:%hu->%pI4:%hu\n",
 		 &exp->tuple.src.u3.ip,
@@ -550,9 +553,9 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (!set_h225_addr(skb, protoff, data, dataoff, taddr,
-			   &ct->tuplehash[!dir].tuple.dst.u3,
-			   htons(nated_port)) == 0) {
+	if (set_h225_addr(skb, protoff, data, dataoff, taddr,
+			  &ct->tuplehash[!dir].tuple.dst.u3,
+			  htons(nated_port))) {
 		nf_ct_unexpect_related(exp);
 		return -1;
 	}
-- 
2.1.4
