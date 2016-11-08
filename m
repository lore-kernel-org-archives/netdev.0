From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv4: ip_send_unicast_reply should set oif only if it is L3 master
Date: Tue,  8 Nov 2016 14:50:31 -0800
Message-ID: <1478645431-7454-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33050 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752480AbcKHWui (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 17:50:38 -0500
Received: by mail-pf0-f176.google.com with SMTP id d2so115066492pfd.0
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 14:50:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lorenzo noted an Android unit test failed due to commit e0d56fdd7342:
  "The expectation in the test was that the RST replying to a SYN sent to a
  closed port should be generated with oif=0. In other words it should not
  prefer the interface where the SYN came in on, but instead should follow
  whatever the routing table says it should do."

Since this a change in behavior, revert the change to
ip_send_unicast_reply such that the oif in the flow is set to the skb_iif
only if skb_iif is an L3 master.

Fixes: e0d56fdd7342 ("net: l3mdev: remove redundant calls")
Reported-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/ip_output.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 49714010ac2e..9403fa3850be 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1577,7 +1577,8 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	}
 
 	oif = arg->bound_dev_if;
-	oif = oif ? : skb->skb_iif;
+	if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
+		oif = skb->skb_iif;
 
 	flowi4_init_output(&fl4, oif,
 			   IP4_REPLY_MARK(net, skb->mark),
-- 
2.1.4
