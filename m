From: Romain KUNTZ <r.kuntz@ipflavors.com>
Subject: [RFC PATCH] xfrm: release neighbor upon dst destruction
Date: Mon, 18 Feb 2013 13:36:24 +0100
Message-ID: <311F962F-9DAF-4B24-B7FD-F158895D304D@ipflavors.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"davem@davemloft.net Miller" <davem@davemloft.net>,
	"yoshfuji@linux-ipv6.org Hideaki" <yoshfuji@linux-ipv6.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:48040 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965Ab3BRMgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 07:36:24 -0500
Received: by mail-wi0-f178.google.com with SMTP id o1so3429855wic.11
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 04:36:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neighbor is cloned in xfrm6_fill_dst but seems to never be released.
Neighbor entry should be released when XFRM6 dst entry is destroyed
in xfrm6_dst_destroy, otherwise references may be kept forever on 
the device pointed by the neighbor entry.

I may not have understood all the subtleties of XFRM & dst so I would
be happy to receive comments on this patch. 

Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
---
 net/ipv6/xfrm6_policy.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c984413..8f32718 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -236,6 +236,8 @@ static void xfrm6_dst_destroy(struct dst_entry *dst)
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 
+	if (likely(xdst->u.rt6.n))
+		neigh_release(xdst->u.rt6.n);
 	if (likely(xdst->u.rt6.rt6i_idev))
 		in6_dev_put(xdst->u.rt6.rt6i_idev);
 	dst_destroy_metrics_generic(dst);
-- 
1.7.2.5
