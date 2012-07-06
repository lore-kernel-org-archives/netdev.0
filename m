From: pablo@netfilter.org
Subject: [PATCH 02/18] netfilter: nf_conntrack: fix nf_conntrack_l3proto_register
Date: Fri,  6 Jul 2012 13:16:52 +0200
Message-ID: <1341573428-3204-3-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Before commit 2c352f444ccfa966a1aa4fd8e9ee29381c467448
(netfilter: nf_conntrack: prepare namespace support for
l4 protocol trackers), we register sysctl before register
protocol tracker. Thus, if sysctl is registration fails,
the protocol tracker will not be registered.

After that commit, if sysctl registration fails, protocol
registration still remains, so we leave things in intermediate
state.

To fix this, this patch registers sysctl before protocols.
And if protocol registration fail, sysctl is unregistered.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto.c |   36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

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
1.7.10

