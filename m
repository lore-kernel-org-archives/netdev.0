From: Wedson Almeida Filho <wedsonaf@gmail.com>
Subject: [PATCH v3] net: Unmap fragment page once iterator is done
Date: Mon, 24 Jun 2013 18:25:20 -0700
Message-ID: <1372123520-18287-1-git-send-email-wedsonaf@gmail.com>
Cc: sergei.shtylyov@cogentembedded.com, Thomas Graf <tgraf@suug.ch>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wedson Almeida Filho <wedsonaf@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Callers of skb_seq_read() are currently forced to call skb_abort_seq_read()
even when consuming all the data because the last call to skb_seq_read (the
one that returns 0 to indicate the end) fails to unmap the last fragment page.

With this patch callers will be allowed to traverse the SKB data by calling
skb_prepare_seq_read() once and repeatedly calling skb_seq_read() as originally
intended (and documented in the original commit 677e90eda - "[NET]: Zerocopy
sequential reading of skb data"), that is, only call skb_abort_seq_read() if
the sequential read is actually aborted.

Signed-off-by: Wedson Almeida Filho <wedsonaf@gmail.com>
---
 drivers/scsi/libiscsi_tcp.c |    1 -
 net/batman-adv/main.c       |    1 -
 net/core/skbuff.c           |    7 ++++++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/libiscsi_tcp.c b/drivers/scsi/libiscsi_tcp.c
index 552e8a2..448eae8 100644
--- a/drivers/scsi/libiscsi_tcp.c
+++ b/drivers/scsi/libiscsi_tcp.c
@@ -906,7 +906,6 @@ int iscsi_tcp_recv_skb(struct iscsi_conn *conn, struct sk_buff *skb,
 			ISCSI_DBG_TCP(conn, "no more data avail. Consumed %d\n",
 				      consumed);
 			*status = ISCSI_TCP_SKB_DONE;
-			skb_abort_seq_read(&seq);
 			goto skb_done;
 		}
 		BUG_ON(segment->copied >= segment->size);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 51aafd6..08125f3 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -473,7 +473,6 @@ __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr)
 		crc = crc32c(crc, data, len);
 		consumed += len;
 	}
-	skb_abort_seq_read(&st);
 
 	return htonl(crc);
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cfd777b..26ea1cf 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2554,8 +2554,13 @@ unsigned int skb_seq_read(unsigned int consumed, const u8 **data,
 	unsigned int block_limit, abs_offset = consumed + st->lower_offset;
 	skb_frag_t *frag;
 
-	if (unlikely(abs_offset >= st->upper_offset))
+	if (unlikely(abs_offset >= st->upper_offset)) {
+		if (st->frag_data) {
+			kunmap_atomic(st->frag_data);
+			st->frag_data = NULL;
+		}
 		return 0;
+	}
 
 next_skb:
 	block_limit = skb_headlen(st->cur_skb) + st->stepped_offset;
-- 
1.7.9.5
