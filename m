From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net] RDS-TCP: Recover correctly from pskb_pull()/pksb_trim()
 failure in rds_tcp_data_recv
Date: Mon, 26 Oct 2015 12:46:37 -0400
Message-ID: <20151026164637.GK10039@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar@oracle.com, davem@davemloft.net
To: sowmini.varadhan@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Either of pskb_pull() or pskb_trim() may fail under low memory conditions.
If rds_tcp_data_recv() ignores such failures, the application will
receive corrupted data because the skb has not been correctly
carved to the RDS datagram size.

Avoid this by handling pskb_pull/pskb_trim failure in the same
manner as the skb_clone failure: bail out of rds_tcp_data_recv(), and
retry via the deferred call to rds_send_worker() that gets set up on
ENOMEM from rds_tcp_read_sock()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp_recv.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index fbc5ef8..27a9921 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -214,8 +214,15 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 			}
 
 			to_copy = min(tc->t_tinc_data_rem, left);
-			pskb_pull(clone, offset);
-			pskb_trim(clone, to_copy);
+			if (!pskb_pull(clone, offset) ||
+			    pskb_trim(clone, to_copy)) {
+				pr_warn("rds_tcp_data_recv: pull/trim failed "
+					"left %zu data_rem %zu skb_len %d\n",
+					left, tc->t_tinc_data_rem, skb->len);
+				kfree_skb(clone);
+				desc->error = -ENOMEM;
+				goto out;
+			}
 			skb_queue_tail(&tinc->ti_skb_list, clone);
 
 			rdsdebug("skb %p data %p len %d off %u to_copy %zu -> "
-- 
1.7.1
