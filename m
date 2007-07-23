From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] TIPC: fix tipc_link_create error handling
Date: Mon, 23 Jul 2007 20:34:23 +0200
Message-ID: <20070723183423.GA9380@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: per.liden@ericsson.com, jon.maloy@ericsson.com,
	tipc-discussion@lists.sourceforge.net, allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

if printbuf allocation or tipc_node_attach_link() fails, invalid
references to the link are left in the associated node and bearer
structures.
Fix by doing printbuf allocation early and adding the new link
to b_ptr->links after tipc_node_attach_link() succeeded.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/tipc/link.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

Allan/Jon/Per: I'd appreciate if you could check wether I missed something.

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 5adfdfd..9917c64 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -423,6 +423,17 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 		return NULL;
 	}
 
+	if (LINK_LOG_BUF_SIZE) {
+		char *pb = kmalloc(LINK_LOG_BUF_SIZE, GFP_ATOMIC);
+
+		if (!pb) {
+			kfree(l_ptr);
+			warn("Link creation failed, no memory for print buffer\n");
+			return NULL;
+		}
+		tipc_printbuf_init(&l_ptr->print_buf, pb, LINK_LOG_BUF_SIZE);
+	}
+
 	l_ptr->addr = peer;
 	if_name = strchr(b_ptr->publ.name, ':') + 1;
 	sprintf(l_ptr->name, "%u.%u.%u:%s-%u.%u.%u:",
@@ -433,7 +444,6 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 		/* note: peer i/f is appended to link name by reset/activate */
 	memcpy(&l_ptr->media_addr, media_addr, sizeof(*media_addr));
 	k_init_timer(&l_ptr->timer, (Handler)link_timeout, (unsigned long)l_ptr);
-	list_add_tail(&l_ptr->link_list, &b_ptr->links);
 	l_ptr->checkpoint = 1;
 	l_ptr->b_ptr = b_ptr;
 	link_set_supervision_props(l_ptr, b_ptr->media->tolerance);
@@ -459,21 +469,13 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 
 	l_ptr->owner = tipc_node_attach_link(l_ptr);
 	if (!l_ptr->owner) {
+		if (LINK_LOG_BUF_SIZE)
+			kfree(l_ptr->print_buf.buf);
 		kfree(l_ptr);
 		return NULL;
 	}
 
-	if (LINK_LOG_BUF_SIZE) {
-		char *pb = kmalloc(LINK_LOG_BUF_SIZE, GFP_ATOMIC);
-
-		if (!pb) {
-			kfree(l_ptr);
-			warn("Link creation failed, no memory for print buffer\n");
-			return NULL;
-		}
-		tipc_printbuf_init(&l_ptr->print_buf, pb, LINK_LOG_BUF_SIZE);
-	}
-
+	list_add_tail(&l_ptr->link_list, &b_ptr->links);
 	tipc_k_signal((Handler)tipc_link_start, (unsigned long)l_ptr);
 
 	dbg("tipc_link_create(): tolerance = %u,cont intv = %u, abort_limit = %u\n",

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
