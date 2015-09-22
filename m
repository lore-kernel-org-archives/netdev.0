From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH v2] geneve: use network byte order for destination port config parameter
Date: Tue, 22 Sep 2015 13:09:32 -0400
Message-ID: <1442941772-11148-1-git-send-email-linville@tuxdriver.com>
References: <20150922152504.GA18514@tuxdriver.com>
Cc: davem@davemloft.net, Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37454 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbbIVRPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 13:15:18 -0400
In-Reply-To: <20150922152504.GA18514@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is primarily for consistancy with vxlan and other tunnels which
use network byte order for similar parameters.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
It is OK to change this, since this parameter was introduced to
net-next in the pre-4.3 cycle.  Using network byte order for this
parameter is consistent with what the other tunnels are doing.

v2 -- rebase on current net tree...

 drivers/net/geneve.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 8f1e9150341a..a955d10986b9 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -815,7 +815,7 @@ static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
 
 static int geneve_configure(struct net *net, struct net_device *dev,
 			    __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
-			    __u16 dst_port, bool metadata)
+			    __be16 dst_port, bool metadata)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_dev *t, *geneve = netdev_priv(dev);
@@ -840,10 +840,10 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 
 	geneve->ttl = ttl;
 	geneve->tos = tos;
-	geneve->dst_port = htons(dst_port);
+	geneve->dst_port = dst_port;
 	geneve->collect_md = metadata;
 
-	t = geneve_find_dev(gn, htons(dst_port), rem_addr, geneve->vni,
+	t = geneve_find_dev(gn, dst_port, rem_addr, geneve->vni,
 			    &tun_on_same_port, &tun_collect_md);
 	if (t)
 		return -EBUSY;
@@ -867,7 +867,7 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 static int geneve_newlink(struct net *net, struct net_device *dev,
 			  struct nlattr *tb[], struct nlattr *data[])
 {
-	__u16 dst_port = GENEVE_UDP_PORT;
+	__be16 dst_port = htons(GENEVE_UDP_PORT);
 	__u8 ttl = 0, tos = 0;
 	bool metadata = false;
 	__be32 rem_addr;
@@ -886,7 +886,7 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 		tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
 
 	if (data[IFLA_GENEVE_PORT])
-		dst_port = nla_get_u16(data[IFLA_GENEVE_PORT]);
+		dst_port = nla_get_be16(data[IFLA_GENEVE_PORT]);
 
 	if (data[IFLA_GENEVE_COLLECT_METADATA])
 		metadata = true;
@@ -909,7 +909,7 @@ static size_t geneve_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(struct in_addr)) + /* IFLA_GENEVE_REMOTE */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TOS */
-		nla_total_size(sizeof(__u16)) +  /* IFLA_GENEVE_PORT */
+		nla_total_size(sizeof(__be16)) +  /* IFLA_GENEVE_PORT */
 		nla_total_size(0) +	 /* IFLA_GENEVE_COLLECT_METADATA */
 		0;
 }
@@ -931,7 +931,7 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos))
 		goto nla_put_failure;
 
-	if (nla_put_u16(skb, IFLA_GENEVE_PORT, ntohs(geneve->dst_port)))
+	if (nla_put_be16(skb, IFLA_GENEVE_PORT, geneve->dst_port))
 		goto nla_put_failure;
 
 	if (geneve->collect_md) {
@@ -971,7 +971,7 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 	if (IS_ERR(dev))
 		return dev;
 
-	err = geneve_configure(net, dev, 0, 0, 0, 0, dst_port, true);
+	err = geneve_configure(net, dev, 0, 0, 0, 0, htons(dst_port), true);
 	if (err) {
 		free_netdev(dev);
 		return ERR_PTR(err);
-- 
2.4.3
