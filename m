From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: unclone unbundled buffers
	before forwarding
Date: Mon, 20 Jun 2016 09:20:46 -0400
Message-ID: <1466428846-12334-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When extracting an individual message from a received "bundle" buffer,
we just create a clone of the base buffer, and adjust it to point into
the right position of the linearized data area of the latter. This works
well for regular message reception, but during periods of extremely high
load it may happen that an extracted buffer, e.g, a connection probe, is
reversed and forwarded through an external interface while the preceding
extracted message is still unhandled. When this happens, the header or
data area of the preceding message will be partially overwritten by a
MAC header, leading to unpredicatable consequences, such as a link
reset.

We now fix this by ensuring that the msg_reverse() function never
returns a cloned buffer, and that the returned buffer always contains
sufficient valid head and tail room to be forwarded.

Reported-by: Erik Hugne <erik.hugne@gmail.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.c |  6 ++++++
 net/tipc/msg.h | 11 -----------
 2 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 8740930..17201aa 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -41,6 +41,8 @@
 #include "name_table.h"
 
 #define MAX_FORWARD_SIZE 1024
+#define BUF_HEADROOM (LL_MAX_HEADER + 48)
+#define BUF_TAILROOM 16
 
 static unsigned int align(unsigned int i)
 {
@@ -505,6 +507,10 @@ bool tipc_msg_reverse(u32 own_node,  struct sk_buff **skb, int err)
 		msg_set_hdr_sz(hdr, BASIC_H_SIZE);
 	}
 
+	if (skb_cloned(_skb) &&
+	    pskb_expand_head(_skb, BUF_HEADROOM, BUF_TAILROOM, GFP_KERNEL))
+		goto exit;
+
 	/* Now reverse the concerned fields */
 	msg_set_errcode(hdr, err);
 	msg_set_origport(hdr, msg_destport(&ohdr));
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 024da8a..7cf52fb 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -94,17 +94,6 @@ struct plist;
 
 #define TIPC_MEDIA_INFO_OFFSET	5
 
-/**
- * TIPC message buffer code
- *
- * TIPC message buffer headroom reserves space for the worst-case
- * link-level device header (in case the message is sent off-node).
- *
- * Note: Headroom should be a multiple of 4 to ensure the TIPC header fields
- *       are word aligned for quicker access
- */
-#define BUF_HEADROOM (LL_MAX_HEADER + 48)
-
 struct tipc_skb_cb {
 	void *handle;
 	struct sk_buff *tail;
-- 
1.9.1


------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports. http://sdm.link/zohomanageengine
