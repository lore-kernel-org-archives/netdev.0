From: pablo@netfilter.org
Subject: [PATCH 2/2] netfilter: nf_ct_h323: fix bug in rtcp natting
Date: Tue, 12 Jun 2012 19:36:03 +0200
Message-ID: <1339522563-9227-3-git-send-email-pablo@netfilter.org>
References: <1339522563-9227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48503 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754103Ab2FLRgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2012 13:36:55 -0400
In-Reply-To: <1339522563-9227-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

The nat_rtp_rtcp hook takes two separate parameters port and rtp_port.

port is expected to be the real h245 address (found inside the packet).
rtp_port is the even number closest to port (RTP ports are even and
RTCP ports are odd).

However currently, both port and rtp_port are having same value (both are
rounded to nearest even numbers).

This works well in case of openlogicalchannel with media (RTP/even) port.

But in case of openlogicalchannel for media control (RTCP/odd) port,
h245 address in the packet is wrongly modified to have an even port.

I am attaching a pcap demonstrating the problem, for any further analysis.

This behavior was introduced around v2.6.19 while rewriting the helper.

Signed-off-by: Jagdish Motwani <jagdish.motwani@elitecore.com>
Signed-off-by: Sanket Shah <sanket.shah@elitecore.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_h323_main.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 46d69d7..31f50bc 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -270,9 +270,8 @@ static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 		return 0;
 
 	/* RTP port is even */
-	port &= htons(~1);
-	rtp_port = port;
-	rtcp_port = htons(ntohs(port) + 1);
+	rtp_port = port & ~htons(1);
+	rtcp_port = port | htons(1);
 
 	/* Create expect for RTP */
 	if ((rtp_exp = nf_ct_expect_alloc(ct)) == NULL)
-- 
1.7.10
