From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/7] netfilter: ipset: Fix serious failure in CIDR tracking
Date: Wed, 18 Sep 2013 00:07:33 +0200
Message-ID: <1379455654-3905-7-git-send-email-pablo@netfilter.org>
References: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34732 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068Ab3IQWIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 18:08:07 -0400
In-Reply-To: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>

This fixes a serious bug affecting all hash types with a net element -
specifically, if a CIDR value is deleted such that none of the same size
exist any more, all larger (less-specific) values will then fail to
match. Adding back any prefix with a CIDR equal to or more specific than
the one deleted will fix it.

Steps to reproduce:
ipset -N test hash:net
ipset -A test 1.1.0.0/16
ipset -A test 2.2.2.0/24
ipset -T test 1.1.1.1           #1.1.1.1 IS in set
ipset -D test 2.2.2.0/24
ipset -T test 1.1.1.1           #1.1.1.1 IS NOT in set

This is due to the fact that the nets counter was unconditionally
decremented prior to the iteration that shifts up the entries. Now, we
first check if there is a proceeding entry and if not, decrement it and
return. Otherwise, we proceed to iterate and then zero the last element,
which, in most cases, will already be zero.

Signed-off-by: Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h |   28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 57beb17..707bc52 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -325,18 +325,22 @@ mtype_add_cidr(struct htype *h, u8 cidr, u8 nets_length)
 static void
 mtype_del_cidr(struct htype *h, u8 cidr, u8 nets_length)
 {
-	u8 i, j;
-
-	for (i = 0; i < nets_length - 1 && h->nets[i].cidr != cidr; i++)
-		;
-	h->nets[i].nets--;
-
-	if (h->nets[i].nets != 0)
-		return;
-
-	for (j = i; j < nets_length - 1 && h->nets[j].nets; j++) {
-		h->nets[j].cidr = h->nets[j + 1].cidr;
-		h->nets[j].nets = h->nets[j + 1].nets;
+	u8 i, j, net_end = nets_length - 1;
+
+	for (i = 0; i < nets_length; i++) {
+	        if (h->nets[i].cidr != cidr)
+	                continue;
+                if (h->nets[i].nets > 1 || i == net_end ||
+                    h->nets[i + 1].nets == 0) {
+                        h->nets[i].nets--;
+                        return;
+                }
+                for (j = i; j < net_end && h->nets[j].nets; j++) {
+		        h->nets[j].cidr = h->nets[j + 1].cidr;
+		        h->nets[j].nets = h->nets[j + 1].nets;
+                }
+                h->nets[j].nets = 0;
+                return;
 	}
 }
 #endif
-- 
1.7.10.4
