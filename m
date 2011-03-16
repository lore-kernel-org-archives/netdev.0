From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Refcount destination entry on xfrm_lookup
Date: Wed, 16 Mar 2011 08:12:49 +0100
Message-ID: <20110316071249.GS31402@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36790 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710Ab1CPHMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 03:12:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We return a destination entry without refcount if a socket
policy is found in xfrm_lookup. This triggers a warning on
a negative refcount when freeeing this dst entry. So take
a refcount in this case to fix it.

This refcount was forgotten when xfrm changed to cache bundles
instead of policies for outgoing flows.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 027e3c6..15792d8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1804,6 +1804,8 @@ restart:
 				goto no_transform;
 			}
 
+			dst_hold(&xdst->u.dst);
+
 			spin_lock_bh(&xfrm_policy_sk_bundle_lock);
 			xdst->u.dst.next = xfrm_policy_sk_bundles;
 			xfrm_policy_sk_bundles = &xdst->u.dst;
-- 
1.7.0.4

