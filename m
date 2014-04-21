From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 01/11] tipc: replace config_mutex
	lock with RTNL lock
Date: Mon, 21 Apr 2014 10:55:42 +0800
Message-ID: <1398048952-7825-2-git-send-email-ying.xue@windriver.com>
References: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

There have two paths where we can configure or change bearer status:
one is that bearer is configured from user space with tipc-config
tool; another one is that bearer is changed by notification events
from its attached interface. On the first path, one dedicated
config_mutex lock is guarded; on the latter path, RTNL lock has been
placed to serialize the process of dealing with interface events.
So, if RTNL lock is also used to protect the first path, this will
not only extremely help us simplify current locking policy, but also
config_mutex lock can be deleted as well.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/config.c |    6 ++----
 net/tipc/core.h   |    2 +-
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 4b981c0..251f5a2 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -42,8 +42,6 @@
 
 #define REPLY_TRUNCATED "<truncated>\n"
 
-static DEFINE_MUTEX(config_mutex);
-
 static const void *req_tlv_area;	/* request message TLV area */
 static int req_tlv_space;		/* request message TLV area size */
 static int rep_headroom;		/* reply message headroom to use */
@@ -223,7 +221,7 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 {
 	struct sk_buff *rep_tlv_buf;
 
-	mutex_lock(&config_mutex);
+	rtnl_lock();
 
 	/* Save request and reply details in a well-known location */
 	req_tlv_area = request_area;
@@ -337,6 +335,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 
 	/* Return reply buffer */
 exit:
-	mutex_unlock(&config_mutex);
+	rtnl_unlock();
 	return rep_tlv_buf;
 }
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 8985bbc..36cbf15 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -56,7 +56,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
-
+#include <linux/rtnetlink.h>
 
 #define TIPC_MOD_VER "2.0.0"
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
