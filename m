From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the char-misc tree with the net-next
 tree
Date: Mon, 5 Sep 2016 16:56:50 +1000
Message-ID: <20160905165650.180e6c89@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        "K. Y. Srinivasan" <kys@microsoft.com>
To: Greg KH <greg@kroah.com>, Arnd Bergmann <arnd@arndb.de>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the char-misc tree got a conflict in:

  include/linux/hyperv.h

between commit:

  30d1de08c87d ("hv_netvsc: make inline functions static")

from the net-next tree and commit:

  bb08d431a914 ("Drivers: hv: ring_buffer: count on wrap around mappings in get_next_pkt_raw()")

from the char-misc tree.

I fixed it up (the former moved the code modified by the latter, so the
below patch applies to the new location of the code) and can carry the
fix as necessary. This is now fixed as far as linux-next is concerned,
but any non trivial conflicts should be mentioned to your upstream
maintainer when your tree is submitted for merging.  You may also want
to consider cooperating with the maintainer of the conflicting tree to
minimise any particularly complex conflicts.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 5 Sep 2016 16:53:06 +1000
Subject: [PATCH] Drivers: hv: ring_buffer: merge fix up for "hv_netvsc: make
 inline functions static"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/hyperv/netvsc.c | 32 +++++++++++---------------------
 1 file changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 2a9ccc4d9e3c..026df6556068 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -42,31 +42,23 @@ static struct vmpacket_descriptor *
 get_next_pkt_raw(struct vmbus_channel *channel)
 {
 	struct hv_ring_buffer_info *ring_info = &channel->inbound;
-	u32 read_loc = ring_info->priv_read_index;
+	u32 priv_read_loc = ring_info->priv_read_index;
 	void *ring_buffer = hv_get_ring_buffer(ring_info);
-	struct vmpacket_descriptor *cur_desc;
-	u32 packetlen;
 	u32 dsize = ring_info->ring_datasize;
-	u32 delta = read_loc - ring_info->ring_buffer->read_index;
+	/*
+	 * delta is the difference between what is available to read and
+	 * what was already consumed in place. We commit read index after
+	 * the whole batch is processed.
+	 */
+	u32 delta = priv_read_loc >= ring_info->ring_buffer->read_index ?
+		priv_read_loc - ring_info->ring_buffer->read_index :
+		(dsize - ring_info->ring_buffer->read_index) + priv_read_loc;
 	u32 bytes_avail_toread = (hv_get_bytes_to_read(ring_info) - delta);
 
 	if (bytes_avail_toread < sizeof(struct vmpacket_descriptor))
 		return NULL;
 
-	if ((read_loc + sizeof(*cur_desc)) > dsize)
-		return NULL;
-
-	cur_desc = ring_buffer + read_loc;
-	packetlen = cur_desc->len8 << 3;
-
-	/*
-	 * If the packet under consideration is wrapping around,
-	 * return failure.
-	 */
-	if ((read_loc + packetlen + VMBUS_PKT_TRAILER) > (dsize - 1))
-		return NULL;
-
-	return cur_desc;
+	return ring_buffer + priv_read_loc;
 }
 
 /*
@@ -78,16 +70,14 @@ static void put_pkt_raw(struct vmbus_channel *channel,
 			struct vmpacket_descriptor *desc)
 {
 	struct hv_ring_buffer_info *ring_info = &channel->inbound;
-	u32 read_loc = ring_info->priv_read_index;
 	u32 packetlen = desc->len8 << 3;
 	u32 dsize = ring_info->ring_datasize;
 
-	BUG_ON((read_loc + packetlen + VMBUS_PKT_TRAILER) > dsize);
-
 	/*
 	 * Include the packet trailer.
 	 */
 	ring_info->priv_read_index += packetlen + VMBUS_PKT_TRAILER;
+	ring_info->priv_read_index %= dsize;
 }
 
 /*
-- 
2.8.1

-- 
Cheers,
Stephen Rothwell
