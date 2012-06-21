From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 01/13] netfilter: fix problem with proto register
Date: Thu, 21 Jun 2012 22:36:38 +0800
Message-ID: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

before commit 2c352f444ccfa966a1aa4fd8e9ee29381c467448
(netfilter: nf_conntrack: prepare namespace support for
l4 protocol trackers), we register sysctl before register
protos, so if sysctl is registered faild, the protos will
not be registered.

but now, we register protos first, and when register
sysctl failed, we can use protos too, it's different
from before.

so change to register sysctl before register protos.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto.c |   36 +++++++++++++++++++++++-------------
 1 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 1ea9194..9bd88aa 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -253,18 +253,23 @@ int nf_conntrack_l3proto_register(struct net *net,
 {
 	int ret = 0;
 
-	if (net == &init_net)
-		ret = nf_conntrack_l3proto_register_net(proto);
+	if (proto->init_net) {
+		ret = proto->init_net(net);
+		if (ret < 0)
+			return ret;
+	}
 
+	ret = nf_ct_l3proto_register_sysctl(net, proto);
 	if (ret < 0)
 		return ret;
 
-	if (proto->init_net) {
-		ret = proto->init_net(net);
+	if (net == &init_net) {
+		ret = nf_conntrack_l3proto_register_net(proto);
 		if (ret < 0)
-			return ret;
+			nf_ct_l3proto_unregister_sysctl(net, proto);
 	}
-	return nf_ct_l3proto_register_sysctl(net, proto);
+
+	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
 
@@ -454,19 +459,24 @@ int nf_conntrack_l4proto_register(struct net *net,
 				  struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
-	if (net == &init_net)
-		ret = nf_conntrack_l4proto_register_net(l4proto);
 
-	if (ret < 0)
-		return ret;
-
-	if (l4proto->init_net)
+	if (l4proto->init_net) {
 		ret = l4proto->init_net(net);
+		if (ret < 0)
+			return ret;
+	}
 
+	ret = nf_ct_l4proto_register_sysctl(net, l4proto);
 	if (ret < 0)
 		return ret;
 
-	return nf_ct_l4proto_register_sysctl(net, l4proto);
+	if (net == &init_net) {
+		ret = nf_conntrack_l4proto_register_net(l4proto);
+		if (ret < 0)
+			nf_ct_l4proto_unregister_sysctl(net, l4proto);
+	}
+
+	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
 
-- 
1.7.7.6

