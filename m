From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net] ipv4: initialize flowi4_flags before calling fib_lookup()
Date: Tue, 22 Mar 2016 11:31:19 -0400
Message-ID: <1458660679-7279-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493AbcCVPb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 11:31:26 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 6A6F7804FC
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:31:26 +0000 (UTC)
Received: from localhost.localdomain.com (vpn1-6-251.ams2.redhat.com [10.36.6.251])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u2MFVNh3018533
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 11:31:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Field fl4.flowi4_flags is not initialized in fib_compute_spec_dst()
before calling fib_lookup(), which means fib_table_lookup() is
using non-deterministic data at this line:

	if (!(flp->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF)) {

Fix by initializing fl4.flowi4_flags to zero.

Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 net/ipv4/fib_frontend.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 21add55..896844a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -304,6 +304,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 		fl4.flowi4_scope = scope;
 		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
 		fl4.flowi4_tun_key.tun_id = 0;
+		fl4.flowi4_flags = 0;
 		if (!fib_lookup(net, &fl4, &res, 0))
 			return FIB_RES_PREFSRC(net, res);
 	} else {
-- 
2.5.0
