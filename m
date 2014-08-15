From: <erik.hugne@ericsson.com>
Subject: [PATCH net] tipc: fix message importance range
	check
Date: Fri, 15 Aug 2014 16:44:35 +0200
Message-ID: <1408113875-30655-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <jon.maloy@ericsson.com>, <ying.xue@windriver.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>
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

From: Erik Hugne <erik.hugne@ericsson.com>

Commit 3b4f302d8578 ("tipc: eliminate
redundant locking") introduced a bug by removing the sanity check
for message importance, allowing programs to assign any value to
the msg_user field. This will mess up the packet reception logic
and may cause random link resets.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/port.h   | 4 +++-
 net/tipc/socket.c | 2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/port.h b/net/tipc/port.h
index 3f93454..a69118f 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -179,8 +179,10 @@ static inline int tipc_port_importance(struct tipc_port *port)
 	return msg_importance(&port->phdr);
 }
 
-static inline void tipc_port_set_importance(struct tipc_port *port, int imp)
+static inline int tipc_port_set_importance(struct tipc_port *port, int imp)
 {
+	if (imp > TIPC_CRITICAL_IMPORTANCE)
+		return -EINVAL
 	msg_set_importance(&port->phdr, (u32)imp);
 }
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7d423ee..ff8c811 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1973,7 +1973,7 @@ static int tipc_setsockopt(struct socket *sock, int lvl, int opt,
 
 	switch (opt) {
 	case TIPC_IMPORTANCE:
-		tipc_port_set_importance(port, value);
+		res = tipc_port_set_importance(port, value);
 		break;
 	case TIPC_SRC_DROPPABLE:
 		if (sock->type != SOCK_STREAM)
-- 
1.8.3.2


------------------------------------------------------------------------------
