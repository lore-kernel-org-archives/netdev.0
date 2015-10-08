From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net v3 1/2] fix return of iptunnel_xmit
Date: Thu,  8 Oct 2015 18:08:49 +0200
Message-ID: <1444320530-28706-1-git-send-email-aschultz@tpip.net>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:45655 "EHLO mail.tpip.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933809AbbJHQI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 12:08:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users of iptunnel_xmit expect the return value to be the packet
length on success (>0), negative for a tx error and zero for a tx
dropped error. In cset 0e6fbc5b6c6218987c93b8c7ca60cf786062899d the
negative return case was lost.

This bug was introduced when the ip_tunnel_core code was refactored.

Fixes: 0e6fbc5b6c6218987c93b8c7ca60cf786062899d
Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
Change in v2:
 - remove unused variable pkt_len

Change in v3:
 - reworked based on comment from Jiri Benc
---
 net/ipv4/ip_tunnel_core.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 84dce6a..5cced3b 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -80,9 +80,12 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 			  skb_shinfo(skb)->gso_segs ?: 1);
 
 	err = ip_local_out_sk(sk, skb);
-	if (unlikely(net_xmit_eval(err)))
-		pkt_len = 0;
-	return pkt_len;
+	if (likely(net_xmit_eval(err) == 0))
+		return pkt_len;
+	if (err < 0)
+		return err;
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(iptunnel_xmit);
 
-- 
2.1.4
