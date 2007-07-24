From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] TIPC: fix tipc_link_create error handling
Date: Wed, 25 Jul 2007 00:02:56 +0200
Message-ID: <20070724220256.GC8732@Chamillionaire.breakpoint.cc>
References: <20070723183423.GA9380@Chamillionaire.breakpoint.cc> <AF1602CB2550CE4381C0C75118A7856B015BE75E@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: allan.stephens@windriver.com, per.liden@ericsson.com,
	jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:44274 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753232AbXGXWDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 18:03:06 -0400
Content-Disposition: inline
In-Reply-To: <AF1602CB2550CE4381C0C75118A7856B015BE75E@ala-mail02.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

if printbuf allocation or tipc_node_attach_link() fails, invalid
references to the link are left in the associated node and bearer
structures.
Fix by allocating printbuf early and moving timer initialization
and the addition of the new link to the b_ptr->links list after
tipc_node_attach_link() succeeded.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 link.c |   28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

also move k_init_timer(), as suggested by Allan.

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 5adfdfd..1d674e0 100644
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
@@ -432,8 +443,6 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 		tipc_zone(peer), tipc_cluster(peer), tipc_node(peer));
 		/* note: peer i/f is appended to link name by reset/activate */
 	memcpy(&l_ptr->media_addr, media_addr, sizeof(*media_addr));
-	k_init_timer(&l_ptr->timer, (Handler)link_timeout, (unsigned long)l_ptr);
-	list_add_tail(&l_ptr->link_list, &b_ptr->links);
 	l_ptr->checkpoint = 1;
 	l_ptr->b_ptr = b_ptr;
 	link_set_supervision_props(l_ptr, b_ptr->media->tolerance);
@@ -459,21 +468,14 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 
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
+	k_init_timer(&l_ptr->timer, (Handler)link_timeout, (unsigned long)l_ptr);
+	list_add_tail(&l_ptr->link_list, &b_ptr->links);
 	tipc_k_signal((Handler)tipc_link_start, (unsigned long)l_ptr);
 
 	dbg("tipc_link_create(): tolerance = %u,cont intv = %u, abort_limit = %u\n",
