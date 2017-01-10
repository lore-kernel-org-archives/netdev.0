From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: ipv4: Fix multipath selection with vrf
Date: Tue, 10 Jan 2017 14:37:35 -0800
Message-ID: <1484087855-4607-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33940 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750869AbdAJWkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 17:40:06 -0500
Received: by mail-pf0-f178.google.com with SMTP id 127so53788709pfg.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 14:40:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_select_path does not call fib_select_multipath if oif is set in the
flow struct. For VRF use cases oif is always set, so multipath route
selection is bypassed. Use the FLOWI_FLAG_SKIP_NH_OIF to skip the oif
check similar to what is done in fib_table_lookup.

Add saddr and proto to the flow struct for the fib lookup done by the
VRF driver to better match hash computation for a flow.

Fixes: 613d09b30f8b ("net: Use VRF device index for lookups on TX")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
IPv6 multipath selection works fine as is.

 drivers/net/vrf.c        | 2 ++
 net/ipv4/fib_semantics.c | 9 +++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 23dfb0eac098..0a067708aa39 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -263,7 +263,9 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 		.flowi4_iif = LOOPBACK_IFINDEX,
 		.flowi4_tos = RT_TOS(ip4h->tos),
 		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_SKIP_NH_OIF,
+		.flowi4_proto = ip4h->protocol,
 		.daddr = ip4h->daddr,
+		.saddr = ip4h->saddr,
 	};
 	struct net *net = dev_net(vrf_dev);
 	struct rtable *rt;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 7a5b4c7d9a87..eba1546b5031 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1618,8 +1618,13 @@ void fib_select_multipath(struct fib_result *res, int hash)
 void fib_select_path(struct net *net, struct fib_result *res,
 		     struct flowi4 *fl4, int mp_hash)
 {
+	bool oif_check;
+
+	oif_check = (fl4->flowi4_oif == 0 ||
+		     fl4->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF);
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res->fi->fib_nhs > 1 && fl4->flowi4_oif == 0) {
+	if (res->fi->fib_nhs > 1 && oif_check) {
 		if (mp_hash < 0)
 			mp_hash = get_hash_from_flowi4(fl4) >> 1;
 
@@ -1629,7 +1634,7 @@ void fib_select_path(struct net *net, struct fib_result *res,
 #endif
 	if (!res->prefixlen &&
 	    res->table->tb_num_default > 1 &&
-	    res->type == RTN_UNICAST && !fl4->flowi4_oif)
+	    res->type == RTN_UNICAST && oif_check)
 		fib_select_default(fl4, res);
 
 	if (!fl4->saddr)
-- 
2.1.4
