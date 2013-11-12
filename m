From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 1/2] tuntap: limit head length of skb allocated
Date: Tue, 12 Nov 2013 18:02:56 +0800
Message-ID: <1384250577-20330-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, stefanha@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 drivers/net/tun.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7cb105c..5537b65 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -954,6 +954,11 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
 	struct sock *sk = tfile->socket.sk;
 	struct sk_buff *skb;
 	int err;
+	int good_linear = SKB_MAX_HEAD(prepad);
+
+	/* Don't use huge linear part */
+	if (linear > good_linear)
+		linear = good_linear;
 
 	/* Under a page?  Don't bother with paged skb. */
 	if (prepad + len < PAGE_SIZE || !linear)
-- 
1.8.3.2
