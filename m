From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net V3 1/2] tun: unbreak truncated packet signalling
Date: Wed, 11 Dec 2013 13:08:33 +0800
Message-ID: <1386738514-1502-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 6680ec68eff47d36f67b4351bc9836fd6cba9532
(tuntap: hardware vlan tx support) breaks the truncated packet signal by nev
return a length greater than iov length in tun_put_user(). This patch fixes
by always return the length of packet plus possible vlan header. Caller can
detect the truncated packet by comparing the return value and the size of io
length.

Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
Changes from V2:
- use "copied" as the variable name instead to be more descriptive
Changes from v1:
- increase total unconditionally
- do not move veth structure out of the vlan handing block
---
 drivers/net/tun.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e26cbea..7c8343a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1184,7 +1184,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 {
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
-	int vlan_offset = 0;
+	int vlan_offset = 0, copied;
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) < 0)
@@ -1248,6 +1248,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		total += tun->vnet_hdr_sz;
 	}
 
+	copied = total;
+	total += skb->len;
 	if (!vlan_tx_tag_present(skb)) {
 		len = min_t(int, skb->len, len);
 	} else {
@@ -1262,24 +1264,24 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
 		len = min_t(int, skb->len + VLAN_HLEN, len);
+		total += VLAN_HLEN;
 
 		copy = min_t(int, vlan_offset, len);
-		ret = skb_copy_datagram_const_iovec(skb, 0, iv, total, copy);
+		ret = skb_copy_datagram_const_iovec(skb, 0, iv, copied, copy);
 		len -= copy;
-		total += copy;
+		copied += copy;
 		if (ret || !len)
 			goto done;
 
 		copy = min_t(int, sizeof(veth), len);
-		ret = memcpy_toiovecend(iv, (void *)&veth, total, copy);
+		ret = memcpy_toiovecend(iv, (void *)&veth, copied, copy);
 		len -= copy;
-		total += copy;
+		copied += copy;
 		if (ret || !len)
 			goto done;
 	}
 
-	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, total, len);
-	total += len;
+	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
 
 done:
 	tun->dev->stats.tx_packets++;
-- 
1.8.3.2
