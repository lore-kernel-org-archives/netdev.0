From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v3 3/3] tipc: reassembly failures should cause link reset
Date: Wed, 6 Nov 2013 09:28:07 +0100
Message-ID: <1383726487-27929-4-git-send-email-erik.hugne@ericsson.com>
References: <1383726487-27929-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:49578 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092Ab3KFIaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 03:30:06 -0500
In-Reply-To: <1383726487-27929-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

If appending a received fragment to the pending fragment chain
in a unicast link fails, the current code tries to force a retransmission
of the fragment by decrementing the 'next received sequence number'
field in the link. This is done under the assumption that the failure
is caused by an out-of-memory situation, an assumption that does
not hold true after the previous patch in this series.

A failure to append a fragment can now only be caused by a protocol
violation by the sending peer, and it must hence be assumed that it
is either malicious or buggy.  Either way, the correct behavior is now
to reset the link instead of trying to revert its sequence number.
So, this is what we do in this commit.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index a63646e..cf465d6 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1652,7 +1652,7 @@ deliver:
 				goto deliver;
 			}
 			if (ret == LINK_REASM_ERROR)
-				l_ptr->next_in_no--;
+				tipc_link_reset(l_ptr);
 			tipc_node_unlock(n_ptr);
 			continue;
 		case CHANGEOVER_PROTOCOL:
-- 
1.7.9.5
