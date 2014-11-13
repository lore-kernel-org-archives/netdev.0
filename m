From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] tun: fix issues of iovec iterators using in tun_put_user()
Date: Thu, 13 Nov 2014 16:54:14 +0800
Message-ID: <1415868854-4913-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net, jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes two issues after using iovec iterators:
- vlan_offset should be initialized to zero, otherwise unexpected offset
  will be used in skb_copy_datagram_iter()
- advance iovec iterator when vnet_hdr_sz is greater than sizeof(gso), this
  is the case when mergeable rx buffer were enabled for a virt guest.

Fixes e0b46d0ee9c240c7430a47e9b0365674d4a04522 ("tun: Use iovec iterators")
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 2ff769b..e3fa65a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1235,7 +1235,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 {
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total;
-	int vlan_offset;
+	int vlan_offset = 0;
 	int vlan_hlen = 0;
 	int vnet_hdr_sz = 0;
 
@@ -1304,6 +1304,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 
 		if (copy_to_iter(&gso, sizeof(gso), iter) != sizeof(gso))
 			return -EFAULT;
+
+		iov_iter_advance(iter, vnet_hdr_sz - sizeof(gso));
 	}
 
 	if (vlan_hlen) {
-- 
1.9.1
