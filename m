From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/3] tipc: reassembly failures
	should cause link reset
Date: Sat, 26 Oct 2013 14:41:03 -0400
Message-ID: <1382812863-23571-4-git-send-email-jon.maloy@ericsson.com>
References: <1382812863-23571-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1382812863-23571-1-git-send-email-jon.maloy@ericsson.com>
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
index 8e4942d..9cf75bb 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1634,7 +1634,7 @@ deliver:
 						goto deliver;
 					}
 					if (ret == LINK_REASM_ERROR)
-						l_ptr->next_in_no--;
+						tipc_link_reset(l_ptr);
 					tipc_node_unlock(n_ptr);
 					continue;
 				case CHANGEOVER_PROTOCOL:
-- 
1.7.9.5


------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60135991&iu=/4140/ostg.clktrk
