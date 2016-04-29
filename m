From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ila: ipv6/ila: fix nlsize calculation for lwtunnel
Date: Thu, 28 Apr 2016 17:12:29 -0700
Message-ID: <1461888749-4105343-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <nicolas.dichtel@6wind.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:10011 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752324AbcD2AMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 20:12:55 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3T08qd5030856
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 17:12:54 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22ktt2gnhh-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 17:12:54 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 14559aee0d9f11e6863b24be0593f280-425fec50 for <netdev@vger.kernel.org>;	Thu,
 28 Apr 2016 17:12:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The handler 'ila_fill_encap_info' adds two attributes: ILA_ATTR_LOCATOR
and ILA_ATTR_CSUM_MODE.

Also, do nla_put_u8 instead of nla_put_u64 for ILA_ATTR_CSUM_MODE.

Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila/ila_lwt.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index 4985e1a..7788090 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -133,7 +133,7 @@ static int ila_fill_encap_info(struct sk_buff *skb,
 	if (nla_put_u64_64bit(skb, ILA_ATTR_LOCATOR, (__force u64)p->locator.v64,
 			      ILA_ATTR_PAD))
 		goto nla_put_failure;
-	if (nla_put_u64(skb, ILA_ATTR_CSUM_MODE, (__force u8)p->csum_mode))
+	if (nla_put_u8(skb, ILA_ATTR_CSUM_MODE, (__force u8)p->csum_mode))
 		goto nla_put_failure;
 
 	return 0;
@@ -144,8 +144,12 @@ nla_put_failure:
 
 static int ila_encap_nlsize(struct lwtunnel_state *lwtstate)
 {
-	/* No encapsulation overhead */
-	return 0;
+	return
+		/* ILA_ATTR_LOCATOR */
+		nla_total_size(sizeof(u64)) +
+		/* ILA_ATTR_CSUM_MODE */
+		nla_total_size(sizeof(u8)) +
+		0;
 }
 
 static int ila_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
-- 
2.8.0.rc2
