From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/04: conntrack: fix dropping packet after l4proto->packet()
Date: Mon, 16 Mar 2009 17:08:46 +0100 (MET)
Message-ID: <20090316160845.3567.95650.sendpatchset@x2.localnet>
References: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49664 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316AbZCPQIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 12:08:48 -0400
In-Reply-To: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ec8d540969da9a70790e9028d57b5b577dd7aa77
Author: Christoph Paasch <christoph.paasch@gmail.com>
Date:   Mon Mar 16 15:51:29 2009 +0100

    netfilter: conntrack: fix dropping packet after l4proto->packet()
    
    We currently use the negative value in the conntrack code to encode
    the packet verdict in the error. As NF_DROP is equal to 0, inverting
    NF_DROP makes no sense and, as a result, no packets are ever dropped.
    
    Signed-off-by: Christoph Paasch <christoph.paasch@gmail.com>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 90ce9dd..f4935e3 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -726,7 +726,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	NF_CT_ASSERT(skb->nfct);
 
 	ret = l4proto->packet(ct, skb, dataoff, ctinfo, pf, hooknum);
-	if (ret < 0) {
+	if (ret <= 0) {
 		/* Invalid: inverse of the return code tells
 		 * the netfilter core what to do */
 		pr_debug("nf_conntrack_in: Can't track with proto module\n");
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index a1edb9c..f3fd154 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -859,7 +859,7 @@ static int tcp_packet(struct nf_conn *ct,
 			 */
 			if (nf_ct_kill(ct))
 				return -NF_REPEAT;
-			return -NF_DROP;
+			return NF_DROP;
 		}
 		/* Fall through */
 	case TCP_CONNTRACK_IGNORE:
@@ -892,7 +892,7 @@ static int tcp_packet(struct nf_conn *ct,
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: killing out of sync session ");
 			nf_ct_kill(ct);
-			return -NF_DROP;
+			return NF_DROP;
 		}
 		ct->proto.tcp.last_index = index;
 		ct->proto.tcp.last_dir = dir;
