From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 2/2] macvtap: limit head length of skb allocated
Date: Tue, 12 Nov 2013 18:02:57 +0800
Message-ID: <1384250577-20330-2-git-send-email-jasowang@redhat.com>
References: <1384250577-20330-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5421 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754583Ab3KLKDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 05:03:11 -0500
In-Reply-To: <1384250577-20330-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently use hdr_len as a hint of head length which is advertised by
guest. But when guest advertise a very big value, it can lead to an 64K+
allocating of kmalloc() which has a very high possibility of failure when host
memory is fragmented or under heavy stress. The huge hdr_len also reduce the
effect of zerocopy or even disable if a gso skb is linearized in guest.

To solves those issues, this patch introduces an upper limit (PAGE_SIZE) of the
head, which guarantees an order 0 allocation each time.

Cc: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
The patch was needed for stable.
---
 drivers/net/macvtap.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 9dccb1e..7ee6f9d 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -523,6 +523,11 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
 						int noblock, int *err)
 {
 	struct sk_buff *skb;
+	int good_linear = SKB_MAX_HEAD(prepad);
+
+	/* Don't use huge linear part */
+	if (linear > good_linear)
+		linear = good_linear;
 
 	/* Under a page?  Don't bother with paged skb. */
 	if (prepad + len < PAGE_SIZE || !linear)
-- 
1.8.3.2
