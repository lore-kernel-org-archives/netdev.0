From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: tcp response should set oif only if it is L3 master
Date: Wed,  9 Nov 2016 09:07:26 -0800
Message-ID: <1478711246-17440-1-git-send-email-dsa@cumulusnetworks.com>
Cc: lorenzo@google.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34105 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753562AbcKIRHe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 12:07:34 -0500
Received: by mail-pf0-f176.google.com with SMTP id n85so129721621pfi.1
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 09:07:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lorenzo noted an Android unit test failed due to e0d56fdd7342:
"The expectation in the test was that the RST replying to a SYN sent to a
closed port should be generated with oif=0. In other words it should not
prefer the interface where the SYN came in on, but instead should follow
whatever the routing table says it should do."

Revert the change to ip_send_unicast_reply and tcp_v6_send_response such
that the oif in the flow is set to the skb_iif only if skb_iif is an L3
master.

Fixes: e0d56fdd7342 ("net: l3mdev: remove redundant calls")
Reported-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/ip_output.c | 3 ++-
 net/ipv6/tcp_ipv6.c  | 8 ++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 03e7f7310423..7cf627b0b248 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1579,7 +1579,8 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	}
 
 	oif = arg->bound_dev_if;
-	oif = oif ? : skb->skb_iif;
+	if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
+		oif = skb->skb_iif;
 
 	flowi4_init_output(&fl4, oif,
 			   IP4_REPLY_MARK(net, skb->mark),
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5a27ab4eab39..6ca23c2e76f7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -818,8 +818,12 @@ static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32
 	fl6.flowi6_proto = IPPROTO_TCP;
 	if (rt6_need_strict(&fl6.daddr) && !oif)
 		fl6.flowi6_oif = tcp_v6_iif(skb);
-	else
-		fl6.flowi6_oif = oif ? : skb->skb_iif;
+	else {
+		if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
+			oif = skb->skb_iif;
+
+		fl6.flowi6_oif = oif;
+	}
 
 	fl6.flowi6_mark = IP6_REPLY_MARK(net, skb->mark);
 	fl6.fl6_dport = t1->dest;
-- 
2.1.4
