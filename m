From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 4/4] tipc: separate link starting
	event from link timeout event
Date: Tue,  3 Feb 2015 08:59:20 -0500
Message-ID: <1422971960-9172-5-git-send-email-jon.maloy@ericsson.com>
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

When a new link instance is created, it is trigged to start by
sending it a TIPC_STARTING_EVT, whereafter a regular link
reset is applied to it.

The starting event is codewise treated as a timeout event, and prompts
a link RESET message to be sent to the peer node, carrying a link
session identifier. The later link_reset() call nudges this session
identifier, whereafter all subsequent RESET messages will be sent out
with the new identifier. The latter session number overrides the former,
causing the peer to unconditionally accept it irrespective of its
current working state.

We don't think that this causes any problem, but it is not in accordance
with the protocol spec, and may cause confusion when debugging TIPC
sessions.

To avoid this, we make the starting event distinct from the
subsequent timeout events, by not allowing the former to send
out any RESET message. This eliminates the described problem.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 46aa599..77c7ccd 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -649,7 +649,9 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			break;
 		case STARTING_EVT:
 			l_ptr->flags |= LINK_STARTED;
-			/* fall through */
+			l_ptr->fsm_msg_cnt++;
+			link_set_timer(l_ptr, cont_intv);
+			break;
 		case TIMEOUT_EVT:
 			tipc_link_proto_xmit(l_ptr, RESET_MSG, 0, 0, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
