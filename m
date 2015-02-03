From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/4] tipc: avoid stale link after
	aborted failover
Date: Tue,  3 Feb 2015 08:59:18 -0500
Message-ID: <1422971960-9172-3-git-send-email-jon.maloy@ericsson.com>
References: <1422971960-9172-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1422971960-9172-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

During link failover it may happen that the remaining link goes
down while it is still in the process of taking over traffic
from a previously failed link. When this happens, we currently
abort the failover procedure and reset the first failed link to
non-failover mode, so that it will be ready to re-establish
contact with its peer when it comes available.

However, if the first link goes down because its bearer was manually
disabled, it is not enough to reset it; it must also be deleted;
which is supposed to happen when the failover procedure is finished.
Otherwise it will remain a zombie link: attached to the owner node
structure, in mode LINK_STOPPED, and permanently blocking any re-
establishing of the link to the peer via the interface in question.

We fix this by amending the failover abort procedure. Apart from
resetting the link to non-failover state, we test if the link is
also in LINK_STOPPED mode. If so, we delete it, using the conditional
tipc_link_delete() function introduced in the previous commit.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.h | 1 +
 net/tipc/node.c | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/net/tipc/link.h b/net/tipc/link.h
index f06b779..3e3432b 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -202,6 +202,7 @@ struct tipc_port;
 struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr);
+void tipc_link_delete(struct tipc_link *link);
 void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
 			   bool shutting_down);
 void tipc_link_failover_send_queue(struct tipc_link *l_ptr);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index ee5d33c..d4cb8c1 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -406,6 +406,10 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		l_ptr->reset_checkpoint = l_ptr->next_in_no;
 		l_ptr->exp_msg_count = 0;
 		tipc_link_reset_fragments(l_ptr);
+
+		/* Link marked for deletion after failover? => do it now */
+		if (l_ptr->flags & LINK_STOPPED)
+			tipc_link_delete(l_ptr);
 	}
 
 	n_ptr->action_flags &= ~TIPC_WAIT_OWN_LINKS_DOWN;
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
