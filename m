From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 15/18] net: xen: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:11 +0800
Message-ID: <1381837514-50660-16-git-send-email-wangkefeng.wang@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wrapper functions net_ratelimited_function() and net_XXX_ratelimited()
are called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 drivers/net/xen-netback/netback.c | 21 +++++++++------------
 drivers/net/xen-netfront.c        | 27 +++++++++------------------
 2 files changed, 18 insertions(+), 30 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f3e591c..bceb2ad 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -776,10 +776,9 @@ static int xenvif_count_requests(struct xenvif *vif,
 		 * dropped
 		 */
 		if (!drop_err && slots >= XEN_NETBK_LEGACY_SLOTS_MAX) {
-			if (net_ratelimit())
-				netdev_dbg(vif->dev,
-					   "Too many slots (%d) exceeding limit (%d), dropping packet\n",
-					   slots, XEN_NETBK_LEGACY_SLOTS_MAX);
+			net_ratelimited_function(netdev_dbg, vif->dev,
+				"Too many slots (%d) exceeding limit (%d), dropping packet\n",
+				slots, XEN_NETBK_LEGACY_SLOTS_MAX);
 			drop_err = -E2BIG;
 		}
 
@@ -799,10 +798,9 @@ static int xenvif_count_requests(struct xenvif *vif,
 		 * Consume all slots and drop the packet.
 		 */
 		if (!drop_err && txp->size > first->size) {
-			if (net_ratelimit())
-				netdev_dbg(vif->dev,
-					   "Invalid tx request, slot size %u > remaining size %u\n",
-					   txp->size, first->size);
+			net_ratelimited_function(netdev_dbg, vif->dev,
+				"Invalid tx request, slot size %u > remaining size %u\n",
+				txp->size, first->size);
 			drop_err = -EIO;
 		}
 
@@ -1170,10 +1168,9 @@ static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
 		}
 		break;
 	default:
-		if (net_ratelimit())
-			netdev_err(vif->dev,
-				   "Attempting to checksum a non-TCP/UDP packet, dropping a protocol %d packet\n",
-				   iph->protocol);
+		net_ratelimited_function(netdev_err, vif->dev,
+			"Attempting to checksum a non-TCP/UDP packet, dropping a protocol %d packet\n",
+			iph->protocol);
 		goto out;
 	}
 
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 36808bf..11eeef1 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -690,8 +690,7 @@ static int xennet_get_extras(struct netfront_info *np,
 		grant_ref_t ref;
 
 		if (unlikely(cons + 1 == rp)) {
-			if (net_ratelimit())
-				dev_warn(dev, "Missing extra info\n");
+			net_ratelimited_function(dev_warn, dev, "Missing extra info\n");
 			err = -EBADR;
 			break;
 		}
@@ -701,8 +700,7 @@ static int xennet_get_extras(struct netfront_info *np,
 
 		if (unlikely(!extra->type ||
 			     extra->type >= XEN_NETIF_EXTRA_TYPE_MAX)) {
-			if (net_ratelimit())
-				dev_warn(dev, "Invalid extra type: %d\n",
+			net_ratelimited_function(dev_warn, dev, "Invalid extra type: %d\n",
 					extra->type);
 			err = -EINVAL;
 		} else {
@@ -742,8 +740,7 @@ static int xennet_get_responses(struct netfront_info *np,
 	for (;;) {
 		if (unlikely(rx->status < 0 ||
 			     rx->offset + rx->status > PAGE_SIZE)) {
-			if (net_ratelimit())
-				dev_warn(dev, "rx->offset: %x, size: %u\n",
+			net_ratelimited_function(dev_warn, dev, "rx->offset: %x, size: %u\n",
 					 rx->offset, rx->status);
 			xennet_move_rx_slot(np, skb, ref);
 			err = -EINVAL;
@@ -756,8 +753,7 @@ static int xennet_get_responses(struct netfront_info *np,
 		 * situation to the system controller to reboot the backend.
 		 */
 		if (ref == GRANT_INVALID_REF) {
-			if (net_ratelimit())
-				dev_warn(dev, "Bad rx response id %d.\n",
+			net_ratelimited_function(dev_warn, dev, "Bad rx response id %d.\n",
 					 rx->id);
 			err = -EINVAL;
 			goto next;
@@ -775,8 +771,7 @@ next:
 			break;
 
 		if (cons + slots == rp) {
-			if (net_ratelimit())
-				dev_warn(dev, "Need more slots\n");
+			net_ratelimited_function(dev_warn, dev, "Need more slots\n");
 			err = -ENOENT;
 			break;
 		}
@@ -788,8 +783,7 @@ next:
 	}
 
 	if (unlikely(slots > max)) {
-		if (net_ratelimit())
-			dev_warn(dev, "Too many slots\n");
+		net_ratelimited_function(dev_warn, dev, "Too many slots\n");
 		err = -E2BIG;
 	}
 
@@ -803,15 +797,13 @@ static int xennet_set_skb_gso(struct sk_buff *skb,
 			      struct xen_netif_extra_info *gso)
 {
 	if (!gso->u.gso.size) {
-		if (net_ratelimit())
-			pr_warn("GSO size must not be zero\n");
+		net_warn_ratelimited("GSO size must not be zero\n");
 		return -EINVAL;
 	}
 
 	/* Currently only TCPv4 S.O. is supported. */
 	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4) {
-		if (net_ratelimit())
-			pr_warn("Bad GSO type %d\n", gso->u.gso.type);
+		net_warn_ratelimited("Bad GSO type %d\n", gso->u.gso.type);
 		return -EINVAL;
 	}
 
@@ -910,8 +902,7 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 		}
 		break;
 	default:
-		if (net_ratelimit())
-			pr_err("Attempting to checksum a non-TCP/UDP packet, dropping a protocol %d packet\n",
+		net_err_ratelimited("Attempting to checksum a non-TCP/UDP packet, dropping a protocol %d packet\n",
 			       iph->protocol);
 		goto out;
 	}
-- 
1.8.2.1
