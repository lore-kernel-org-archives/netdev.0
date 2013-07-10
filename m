From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH v2 net 1/2] tuntap: correctly linearize skb when zerocopy is used
Date: Wed, 10 Jul 2013 13:43:27 +0800
Message-ID: <1373435008-19407-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Userspace may produce vectors greater than MAX_SKB_FRAGS. When we try to
linearize parts of the skb to let the rest of iov to be fit in
the frags, we need count copylen into linear when calling tun_alloc_skb()
instead of partly counting it into data_len. Since this breaks
zerocopy_sg_from_iovec() since its inner counter assumes nr_frags should
be zero at beginning. This cause nr_frags to be increased wrongly without
setting the correct frags.

This bug were introduced from 0690899b4d4501b3505be069b9a687e68ccbe15b
(tun: experimental zero copy tx support)

Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
- This patch is needed for stable.
- Changes from v1: introduce a local variable to track linear size
---
 drivers/net/tun.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9c61f87..c3cb60b 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1044,7 +1044,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 {
 	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
 	struct sk_buff *skb;
-	size_t len = total_len, align = NET_SKB_PAD;
+	size_t len = total_len, align = NET_SKB_PAD, linear;
 	struct virtio_net_hdr gso = { 0 };
 	int offset = 0;
 	int copylen;
@@ -1108,10 +1108,13 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 			copylen = gso.hdr_len;
 		if (!copylen)
 			copylen = GOODCOPY_LEN;
-	} else
+		linear = copylen;
+	} else {
 		copylen = len;
+		linear = gso.hdr_len;
+	}
 
-	skb = tun_alloc_skb(tfile, align, copylen, gso.hdr_len, noblock);
+	skb = tun_alloc_skb(tfile, align, copylen, linear, noblock);
 	if (IS_ERR(skb)) {
 		if (PTR_ERR(skb) != -EAGAIN)
 			tun->dev->stats.rx_dropped++;
-- 
1.7.1
