From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 03/24] net: rbridge: Add RBridge structure
Date: Wed, 24 Sep 2014 17:51:59 +0200
Message-ID: <1411573940-14079-4-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:37952 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076AbaIXP6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:13 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add basic RBridge structure
add basic TRILL constant
define rbr_nickinfo structure which represent distant RBridge information

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
---
 net/bridge/rbridge/rbr_private.h | 60 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 60 insertions(+)
 create mode 100644 net/bridge/rbridge/rbr_private.h

diff --git a/net/bridge/rbridge/rbr_private.h b/net/bridge/rbridge/rbr_private.h
new file mode 100644
index 0000000..f21e4a5
--- /dev/null
+++ b/net/bridge/rbridge/rbr_private.h
@@ -0,0 +1,60 @@
+#ifndef _RBR_PRIVATE_H
+#define _RBR_PRIVATE_H
+
+#include <linux/atomic.h>
+
+#define	RBRIDGE_NICKNAME_MIN	0x0000
+#define	RBRIDGE_NICKNAME_MAX	0xFFFF
+
+/* Define well-known nicknames */
+#define	RBRIDGE_NICKNAME_NONE	RBRIDGE_NICKNAME_MIN
+#define	RBRIDGE_NICKNAME_UNUSED	RBRIDGE_NICKNAME_MAX
+
+#define	TRILL_PROTOCOL_VERS 0	/* th_version */
+#define	TRILL_DEFAULT_HOPS 21	/* th_hopcount */
+#define VALID_NICK(n)	((n) != RBRIDGE_NICKNAME_NONE && \
+			(n) != RBRIDGE_NICKNAME_UNUSED)
+
+struct rbr_nickinfo {
+	/* Nickname of the RBridge */
+	uint16_t nick;
+	/* Next-hop SNPA address to reach this RBridge */
+	u8 adjsnpa[ETH_ALEN];
+	/* Link on our system to use to reach next-hop */
+	uint32_t linkid;
+	/* Num of *our* adjacencies on a tree rooted at this RBridge */
+	uint16_t adjcount;
+	/* Num of distribution tree root nicks chosen by this RBridge */
+	uint16_t dtrootcount;
+	/*
+	 * Variable size bytes to store adjacency nicks, distribution
+	 * tree roots. Adjacency nicks and
+	 * distribution tree roots are 16-bit fields.
+	 */
+};
+struct rbr_node {
+	struct rbr_nickinfo *rbr_ni;
+	atomic_t refs;		/* reference count */
+};
+
+struct rbr {
+	uint16_t nick;		/* our nickname */
+	uint16_t treeroot;	/* tree root nickname */
+	struct rbr_node *rbr_nodes[RBRIDGE_NICKNAME_MAX];
+	struct net_bridge *br;	/* back pointer */
+};
+
+/* Access the adjacency nick list at the end of rbr_nickinfo */
+#define	RBR_NI_ADJNICKSPTR(v) ((uint16_t *)((struct rbr_nickinfo *)(v)+1))
+#define	RBR_NI_ADJNICK(v, n) (RBR_NI_ADJNICKSPTR(v)[(n)])
+
+/* Access the DT root nick list in rbr_nickinfo after adjacency nicks */
+#define	RBR_NI_DTROOTNICKSPTR(v) (RBR_NI_ADJNICKSPTR(v)+(v)->adjcount)
+#define	RBR_NI_DTROOTNICK(v, n) (RBR_NI_DTROOTNICKSPTR(v)[(n)])
+
+#define	RBR_NI_TOTALSIZE(v) (\
+		(sizeof (struct rbr_nickinfo)) + \
+		(sizeof (uint16_t) * (v)->adjcount) + \
+		(sizeof (uint16_t) * (v)->dtrootcount)\
+		)
+#endif
-- 
1.9.1
