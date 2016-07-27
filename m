From: Phil Turnbull <phil.turnbull@oracle.com>
Subject: [PATCH net] sit: Correctly return -ENOMEM from SIOCGETPRL ioctl.
Date: Wed, 27 Jul 2016 09:57:25 -0400
Message-ID: <20160727135725.13559-1-phil.turnbull@oracle.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Phil Turnbull <phil.turnbull@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44463 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295AbcG0N6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 09:58:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-ENOMEM is never returned because the 'out' path unconditionally sets
'ret' to zero. Remove the 'out' path and return directly when the
allocation fails.

Fixes: 300aaeeaab5f ("[IPV6] SIT: Add SIOCGETPRL ioctl to get/dump PRL.")
Signed-off-by: Phil Turnbull <phil.turnbull@oracle.com>
---
 net/ipv6/sit.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0619ac70836d..a71514040bb4 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -320,8 +320,8 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 		 */
 		kp = kcalloc(ca, sizeof(*kp), GFP_ATOMIC);
 		if (!kp) {
-			ret = -ENOMEM;
-			goto out;
+			rcu_read_unlock();
+			return -ENOMEM;
 		}
 	}
 
@@ -337,7 +337,7 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 		if (kprl.addr != htonl(INADDR_ANY))
 			break;
 	}
-out:
+
 	rcu_read_unlock();
 
 	len = sizeof(*kp) * c;
-- 
2.9.0.rc2
