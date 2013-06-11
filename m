From: Saurabh Mohan <saumoh@gmail.com>
Subject: [PATCH net 1/1] net/ipv4: ip_vti clear skb cb before tunneling.
Date: Mon, 10 Jun 2013 17:45:10 -0700
Message-ID: <1370911510-20012-1-git-send-email-saurabh.mohan@vyatta.com>
Cc: Saurabh Mohan <saurabh@vyatta.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57721 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258Ab3FKApJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 20:45:09 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so4947240pad.37
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 17:45:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saurabh Mohan <saurabh@vyatta.com>

If users apply shaper to vti tunnel then it will cause a kernel crash. The
problem seems to be due to the vti_tunnel_xmit function not clearing
skb->opt field before passing the packet to xfrm tunneling code.

Signed-off-by: Saurabh Mohan <saurabh@vyatta.com>
---
 net/ipv4/ip_vti.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 9d2bdb2..c118f6b 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -361,8 +361,7 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			tunnel->err_count = 0;
 	}
 
-	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
-			      IPSKB_REROUTED);
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->dst);
 	nf_reset(skb);
-- 
1.7.2.5
