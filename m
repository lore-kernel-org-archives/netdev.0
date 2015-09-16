From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
Date: Wed, 16 Sep 2015 17:50:25 +0200
Message-ID: <1442418625-11805-1-git-send-email-vkuznets@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit b08cc79155fc26d0d112b1470d1ece5034651a4b ("hv_netvsc: Eliminate
 memory allocation in the packet send path") introduced skb headroom
request for Hyper-V netvsc driver:

       max_needed_headroom = sizeof(struct hv_netvsc_packet) +
                               sizeof(struct rndis_message) +
                               NDIS_VLAN_PPI_SIZE + NDIS_CSUM_PPI_SIZE +
                               NDIS_LSO_PPI_SIZE + NDIS_HASH_PPI_SIZE;
       ...
       net->needed_headroom = max_needed_headroom;

max_needed_headroom is 220 bytes, it significantly exceeds the
LL_MAX_HEADER setting. This causes each skb to be cloned on send path,
e.g. for IPv4 case we fall into the following clause
(ip_finish_output2()):

if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
    ...
    skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
    ...
}

leading to a significant performance regression. Increase LL_MAX_HEADER
to make it suitable for netvsc, make it 224 to be 16-aligned.
Alternatively we could (partially) revert the commit which introduced skb
headroom request restoring manual memory allocation on transmit path.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 include/linux/netdevice.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88a0069..7233790 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -132,7 +132,9 @@ static inline bool dev_xmit_complete(int rc)
  *	used.
  */
 
-#if defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
+#if IS_ENABLED(CONFIG_HYPERV_NET)
+# define LL_MAX_HEADER 224
+#elif defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
 # if defined(CONFIG_MAC80211_MESH)
 #  define LL_MAX_HEADER 128
 # else
-- 
2.4.3
