From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net] ipvlan: fix incorrect usage of IS_ERR() macro in IPv6 code path.
Date: Sat, 24 Jan 2015 21:53:43 -0800
Message-ID: <1422165223-13496-1-git-send-email-maheshb@google.com>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:43785 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbbAYFx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 00:53:56 -0500
Received: by mail-vc0-f201.google.com with SMTP id kv7so254571vcb.0
        for <netdev@vger.kernel.org>; Sat, 24 Jan 2015 21:53:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip6_route_output() always returns a valid dst pointer unlike in IPv4
case. So the validation has to be different from the IPv4 path. Correcting
that error in this patch.

This was picked up by a static checker with a following warning -

   drivers/net/ipvlan/ipvlan_core.c:380 ipvlan_process_v6_outbound()
        warn: 'dst' isn't an ERR_PTR

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index a14d87783245..2e195289ddf4 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -377,9 +377,11 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 	};
 
 	dst = ip6_route_output(dev_net(dev), NULL, &fl6);
-	if (IS_ERR(dst))
+	if (dst->error) {
+		ret = dst->error;
+		dst_release(dst);
 		goto err;
-
+	}
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst);
 	err = ip6_local_out(skb);
-- 
2.2.0.rc0.207.ga3a616c
