From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v3 2/4] mpls: Differentiate implicit-null and unlabeled neighbours
Date: Mon, 30 Mar 2015 19:15:54 +0100
Message-ID: <1427739356-28113-3-git-send-email-rshearma@brocade.com>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
 <1427739356-28113-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:8131 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753315AbbC3SRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 14:17:45 -0400
In-Reply-To: <1427739356-28113-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The control plane can advertise labels for neighbours that don't have
an outgoing label. RFC 3031 s3.22 states that either the remaining
labels should be popped (if the control plane can determine that it's
safe to do so, which in light of MPLS-VPN, RFC 4364, is never the case
now) or that the packet should be discarded.

Therefore, if the peer is unlabeled and the last label wasn't popped
then drop the packet. The peer being unlabeled is signalled by an
empty label stack. However, penultimate hop popping still needs to be
supported (RFC 3031 s4.1.5) where the incoming label is popped and no
labels are put on and the packet can still go out labeled with the
remainder of the stack. This is achieved by the control plane
specifying a label stack consisting of the single special
implicit-null value.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0d6763a895d6..7f5f30d29f73 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -28,7 +28,8 @@ struct mpls_route { /* next hop label forwarding entry */
 	struct rcu_head		rt_rcu;
 	u32			rt_label[MAX_NEW_LABELS];
 	u8			rt_protocol; /* routing protocol that set this entry */
-	u8			rt_labels;
+	u8                      rt_unlabeled : 1;
+	u8			rt_labels : 7;
 	u8			rt_via_alen;
 	u8			rt_via_table;
 	u8			rt_via[0];
@@ -202,6 +203,11 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		/* Penultimate hop popping */
 		if (!mpls_egress(rt, skb, dec))
 			goto drop;
+	} else if (rt->rt_unlabeled) {
+		/* Labeled traffic destined to unlabeled peer should
+		 * be discarded
+		 */
+		goto drop;
 	} else {
 		bool bos;
 		int i;
@@ -386,9 +392,16 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	if (!rt)
 		goto errout;
 
-	rt->rt_labels = cfg->rc_output_labels;
-	for (i = 0; i < rt->rt_labels; i++)
-		rt->rt_label[i] = cfg->rc_output_label[i];
+	if (cfg->rc_output_labels == 1 &&
+	    cfg->rc_output_label[0] == LABEL_IMPLICIT_NULL) {
+		rt->rt_labels = 0;
+	} else {
+		rt->rt_labels = cfg->rc_output_labels;
+		for (i = 0; i < rt->rt_labels; i++)
+			rt->rt_label[i] = cfg->rc_output_label[i];
+		if (!rt->rt_labels)
+			rt->rt_unlabeled = true;
+	}
 	rt->rt_protocol = cfg->rc_protocol;
 	RCU_INIT_POINTER(rt->rt_dev, dev);
 	rt->rt_via_table = cfg->rc_via_table;
-- 
2.1.4
