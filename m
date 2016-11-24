From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: improve sanity check for
	received domain records
Date: Wed, 23 Nov 2016 23:46:09 -0500
Message-ID: <1479962769-24239-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
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

In commit 35c55c9877f8 ("tipc: add neighbor monitoring framework") we
added a data area to the link monitor STATE messages under the
assumption that previous versions did not use any such data area.

For versions older than Linux 4.3 this assumption is not correct. In
those version, all STATE messages sent out from a node inadvertently
contain a 16 byte data area containing a string; -a leftover from
previous RESET messages which were using this during the setup phase.
This string serves no purpose in STATE messages, and should no be there.

Unfortunately, this data area is delivered to the link monitor
framework, where a sanity check catches that it is not a correct domain
record, and drops it. It also issues a rate limited warning about the
event.

Since such events occur much more frequently than anticipated, we now
choose to remove the warning in order to not fill the kernel log with
useless contents. We also make the sanity check stricter, to further
reduce the risk that such data is inavertently admitted.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/monitor.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/monitor.c b/net/tipc/monitor.c
index ed97a58..9e109bb 100644
--- a/net/tipc/monitor.c
+++ b/net/tipc/monitor.c
@@ -455,14 +455,14 @@ void tipc_mon_rcv(struct net *net, void *data, u16 dlen, u32 addr,
 	int i, applied_bef;
 
 	state->probing = false;
-	if (!dlen)
-		return;
 
 	/* Sanity check received domain record */
-	if ((dlen < new_dlen) || ntohs(arrv_dom->len) != new_dlen) {
-		pr_warn_ratelimited("Received illegal domain record\n");
+	if (dlen < dom_rec_len(arrv_dom, 0))
+		return;
+	if (dlen != dom_rec_len(arrv_dom, new_member_cnt))
+		return;
+	if ((dlen < new_dlen) || ntohs(arrv_dom->len) != new_dlen)
 		return;
-	}
 
 	/* Synch generation numbers with peer if link just came up */
 	if (!state->synched) {
-- 
2.7.4


------------------------------------------------------------------------------
