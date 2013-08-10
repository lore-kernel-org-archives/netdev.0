From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: nfnetlink_{log,queue}: fix information leaks in netlink message
Date: Sat, 10 Aug 2013 18:58:52 +0200
Message-ID: <1376153933-5747-4-git-send-email-pablo@netfilter.org>
References: <1376153933-5747-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44425 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756677Ab3HJQ7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Aug 2013 12:59:36 -0400
In-Reply-To: <1376153933-5747-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

These structs have a "_pad" member.  Also the "phw" structs have an 8
byte "hw_addr[]" array but sometimes only the first 6 bytes are
initialized.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c        |    6 +++++-
 net/netfilter/nfnetlink_queue_core.c |    5 ++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 962e979..d92cc31 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -419,6 +419,7 @@ __build_packet_message(struct nfnl_log_net *log,
 	nfmsg->version = NFNETLINK_V0;
 	nfmsg->res_id = htons(inst->group_num);
 
+	memset(&pmsg, 0, sizeof(pmsg));
 	pmsg.hw_protocol	= skb->protocol;
 	pmsg.hook		= hooknum;
 
@@ -498,7 +499,10 @@ __build_packet_message(struct nfnl_log_net *log,
 	if (indev && skb->dev &&
 	    skb->mac_header != skb->network_header) {
 		struct nfulnl_msg_packet_hw phw;
-		int len = dev_parse_header(skb, phw.hw_addr);
+		int len;
+
+		memset(&phw, 0, sizeof(phw));
+		len = dev_parse_header(skb, phw.hw_addr);
 		if (len > 0) {
 			phw.hw_addrlen = htons(len);
 			if (nla_put(inst->skb, NFULA_HWADDR, sizeof(phw), &phw))
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 971ea14..8a703c3 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -463,7 +463,10 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	if (indev && entskb->dev &&
 	    entskb->mac_header != entskb->network_header) {
 		struct nfqnl_msg_packet_hw phw;
-		int len = dev_parse_header(entskb, phw.hw_addr);
+		int len;
+
+		memset(&phw, 0, sizeof(phw));
+		len = dev_parse_header(entskb, phw.hw_addr);
 		if (len) {
 			phw.hw_addrlen = htons(len);
 			if (nla_put(skb, NFQA_HWADDR, sizeof(phw), &phw))
-- 
1.7.10.4
