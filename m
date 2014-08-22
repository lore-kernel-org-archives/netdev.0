From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 01/17] tipc: fix message
	importance range check
Date: Fri, 22 Aug 2014 18:09:04 -0400
Message-ID: <1408745360-23560-2-git-send-email-jon.maloy@ericsson.com>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
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
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/port.h   |    4 +++-
 net/tipc/socket.c |    2 +-
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
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
