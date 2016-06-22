From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] net: avoid vlan ptype specific match to be leaked on real device
Date: Wed, 22 Jun 2016 12:25:15 +0200
Message-ID: <3d191a3c51bd564da8b0c3ffe1e9c90fa7bd4d7b.1466590952.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721AbcFVKd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 06:33:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before the commit 0dfe17823945 ("net: vlan: goto another_round
instead of calling __netif_receive_skb"), on tagged skb ingress,
ptype specific protocol matches were delivered only to the
related vlan device, if any.
After said commit, jumping back to the 'another_round' label, allows
the later ptype specific check to match both orig_dev and skb->dev,
delivering the skb to both the vlan device and the underlying
device.
This cause i.e. packet sockets bound to a specific protocol type on
one of said devices to receive also frames really targeting the
other device.
This commit resets orig_dev before performing another round due to
vlan processing, allowing the skb to be delivered once again only
to the vlan specific ptypes.

Fixes: 0dfe17823945 ("net: vlan: goto another_round instead of calling __netif_receive_skb")
Reported-by: Ryan Liu <Ryan.Liu@alcatel-lucent.com>
Reported-by: Cliff Chen <Cliff.Chen@alcatel-lucent.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/core/dev.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 904ff43..9d08dd6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4144,10 +4144,15 @@ ncls:
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
-		if (vlan_do_receive(&skb))
+		if (vlan_do_receive(&skb)) {
+			/* avoid delivering to ptype registered on
+			 * vlan's underlying device only
+			 */
+			orig_dev = skb->dev;
 			goto another_round;
-		else if (unlikely(!skb))
+		} else if (unlikely(!skb)) {
 			goto out;
+		}
 	}
 
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
-- 
1.8.3.1
