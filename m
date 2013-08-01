From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netfilter: information leaks building packet message
Date: Thu, 1 Aug 2013 12:36:57 +0300
Message-ID: <20130801093656.GA12455@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These structs have a "_pad" member.  Also the "phw" structs have an 8
byte "hw_addr[]" array but sometimes only the first 6 bytes are
initialized.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Applies to -next and -mainline.

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
