From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp: fix secpath leak
Date: Fri,  1 Sep 2017 14:42:30 +0200
Message-ID: <5bd7a6e643340d833718722c0508474c6c3a0a3a.1504260470.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Paul Moore <paul@paul-moore.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46312 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751778AbdIAMoS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 08:44:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yossi Kuperman <yossiku@mellanox.com>

After commit dce4551cb2ad ("udp: preserve head state for IP_CMSG_PASSSEC")
we preserve the secpath for the whole skb lifecycle, but we also
end up leaking a reference to it.

We must clear the head state on skb reception, if secpath is
present.

Fixes: dce4551cb2ad ("udp: preserve head state for IP_CMSG_PASSSEC")
Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index a6dc48d76a29..62344804baae 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1176,7 +1176,7 @@ static void udp_set_dev_scratch(struct sk_buff *skb)
 	scratch->csum_unnecessary = !!skb_csum_unnecessary(skb);
 	scratch->is_linear = !skb_is_nonlinear(skb);
 #endif
-	if (likely(!skb->_skb_refdst))
+	if (likely(!skb->_skb_refdst && !skb_sec_path(skb)))
 		scratch->_tsize_state |= UDP_SKB_IS_STATELESS;
 }
 
-- 
2.13.5
