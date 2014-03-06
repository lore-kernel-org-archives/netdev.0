From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v7 6/9] xen-netback: Add stat counters
	for zerocopy
Date: Thu, 6 Mar 2014 21:48:28 +0000
Message-ID: <1394142511-14827-7-git-send-email-zoltan.kiss@citrix.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zoltan Kiss <zoltan.kiss@citrix.com>, jonathan.davies@citrix.com
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

These counters help determine how often the buffers had to be copied. Also
they help find out if packets are leaked, as if "sent != success + fail",
there are probably packets never freed up properly.

NOTE: if bisect brought you here, you should apply the series up until
"xen-netback: Timeout packets in RX path", otherwise Windows guests can't work
properly and malicious guests can block other guests by not releasing their sent
packets.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 79ba456..eac171e 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -167,6 +167,9 @@ struct xenvif {
 
 	/* Statistics */
 	unsigned long rx_gso_checksum_fixup;
+	unsigned long tx_zerocopy_sent;
+	unsigned long tx_zerocopy_success;
+	unsigned long tx_zerocopy_fail;
 
 	/* Miscellaneous private stuff. */
 	struct net_device *dev;
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 408ab57..adfed30 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -237,6 +237,21 @@ static const struct xenvif_stat {
 		"rx_gso_checksum_fixup",
 		offsetof(struct xenvif, rx_gso_checksum_fixup)
 	},
+	/* If (sent != success + fail), there are probably packets never
+	 * freed up properly!
+	 */
+	{
+		"tx_zerocopy_sent",
+		offsetof(struct xenvif, tx_zerocopy_sent),
+	},
+	{
+		"tx_zerocopy_success",
+		offsetof(struct xenvif, tx_zerocopy_success),
+	},
+	{
+		"tx_zerocopy_fail",
+		offsetof(struct xenvif, tx_zerocopy_fail)
+	},
 };
 
 static int xenvif_get_sset_count(struct net_device *dev, int string_set)
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index bc91965..44e6988 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1554,8 +1554,10 @@ static int xenvif_tx_submit(struct xenvif *vif)
 		 * do a skb_copy_ubufs while we are still in control of the
 		 * skb. E.g. the __pskb_pull_tail earlier can do such thing.
 		 */
-		if (skb_shinfo(skb)->destructor_arg)
+		if (skb_shinfo(skb)->destructor_arg) {
 			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+			vif->tx_zerocopy_sent++;
+		}
 
 		netif_receive_skb(skb);
 	}
@@ -1595,6 +1597,11 @@ void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
 		napi_schedule(&vif->napi);
 		local_bh_enable();
 	}
+
+	if (likely(zerocopy_success))
+		vif->tx_zerocopy_success++;
+	else
+		vif->tx_zerocopy_fail++;
 }
 
 static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
