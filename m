From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] tun: handle copy failure in tun_put_user()
Date: Mon, 20 Jan 2014 11:16:48 +0800
Message-ID: <1390187808-5462-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch return the error code of copy helpers in tun_put_user() instead of
ignoring them.

Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ecec802..4ec8f28 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1185,7 +1185,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 {
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
-	int vlan_offset = 0, copied;
+	int vlan_offset = 0, copied, ret;
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) < 0)
@@ -1254,7 +1254,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	if (!vlan_tx_tag_present(skb)) {
 		len = min_t(int, skb->len, len);
 	} else {
-		int copy, ret;
+		int copy;
 		struct {
 			__be16 h_vlan_proto;
 			__be16 h_vlan_TCI;
@@ -1282,13 +1282,13 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 			goto done;
 	}
 
-	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
+	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
 
 done:
 	tun->dev->stats.tx_packets++;
 	tun->dev->stats.tx_bytes += len;
 
-	return total;
+	return ret ? ret : total;
 }
 
 static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
-- 
1.8.3.2
