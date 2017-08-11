From: Nick Desaulniers <ndesaulniers@google.com>
Subject: [PATCH v2] netfilter: nf_nat_h323: fix logical-not-parentheses warning
Date: Fri, 11 Aug 2017 11:16:07 -0700
Message-ID: <20170811181607.33878-1-ndesaulniers@google.com>
References: <20170811174259.GA3743@salvia>
Cc: mka@chromium.org, lorenzo@google.com,
        Nick Desaulniers <ndesaulniers@google.com>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34413 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753271AbdHKSQN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 14:16:13 -0400
Received: by mail-pg0-f43.google.com with SMTP id u185so18451131pgb.1
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 11:16:13 -0700 (PDT)
In-Reply-To: <20170811174259.GA3743@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

if (!x == 0)
  ...
else
  return

Also added a return code check that seemed to be missing in one
instance.

Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
---
Changes in v2:
* Reorder if/else blocks to return early.
* Also handle this for set_h245_addr(), not just set_h225_addr().
* Add return code check for the Gnomemeeting case.

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
2.14.0.434.g98096fd7a8-goog
