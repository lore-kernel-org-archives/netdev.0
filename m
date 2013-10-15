From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 08/18] atm: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:04 +0800
Message-ID: <1381837514-50660-9-git-send-email-wangkefeng.wang@huawei.com>
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

net_ratelimited_function() is called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 drivers/atm/solos-pci.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 32784d1..a4d20e9 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -807,8 +807,8 @@ void solos_bh(unsigned long card_arg)
 
 				skb = alloc_skb(size + 1, GFP_ATOMIC);
 				if (!skb) {
-					if (net_ratelimit())
-						dev_warn(&card->dev->dev, "Failed to allocate sk_buff for RX\n");
+					net_ratelimited_function(dev_warn, &card->dev->dev,
+						"Failed to allocate sk_buff for RX\n");
 					continue;
 				}
 
@@ -829,8 +829,8 @@ void solos_bh(unsigned long card_arg)
 				vcc = find_vcc(card->atmdev[port], le16_to_cpu(header->vpi),
 					       le16_to_cpu(header->vci));
 				if (!vcc) {
-					if (net_ratelimit())
-						dev_warn(&card->dev->dev, "Received packet for unknown VPI.VCI %d.%d on port %d\n",
+					net_ratelimited_function(dev_warn, &card->dev->dev,
+						"Received packet for unknown VPI.VCI %d.%d on port %d\n",
 							 le16_to_cpu(header->vpi), le16_to_cpu(header->vci),
 							 port);
 					dev_kfree_skb_any(skb);
@@ -856,9 +856,8 @@ void solos_bh(unsigned long card_arg)
 					break;
 				spin_lock(&card->cli_queue_lock);
 				if (skb_queue_len(&card->cli_queue[port]) > 10) {
-					if (net_ratelimit())
-						dev_warn(&card->dev->dev, "Dropping console response on port %d\n",
-							 port);
+					net_ratelimited_function(dev_warn, &card->dev->dev,
+						"Dropping console response on port %d\n", port);
 					dev_kfree_skb_any(skb);
 				} else
 					skb_queue_tail(&card->cli_queue[port], skb);
@@ -878,8 +877,7 @@ void solos_bh(unsigned long card_arg)
 					  card->config_regs + RX_DMA_ADDR(port));
 				card->rx_skb[port] = skb;
 			} else {
-				if (net_ratelimit())
-					dev_warn(&card->dev->dev, "Failed to allocate RX skb");
+				net_ratelimited_function(dev_warn, &card->dev->dev, "Failed to allocate RX skb");
 
 				/* We'll have to try again later */
 				tasklet_schedule(&card->tlet);
@@ -927,8 +925,8 @@ static int popen(struct atm_vcc *vcc)
 
 	skb = alloc_skb(sizeof(*header), GFP_KERNEL);
 	if (!skb) {
-		if (net_ratelimit())
-			dev_warn(&card->dev->dev, "Failed to allocate sk_buff in popen()\n");
+		net_ratelimited_function(dev_warn, &card->dev->dev,
+			"Failed to allocate sk_buff in popen()\n");
 		return -ENOMEM;
 	}
 	header = (void *)skb_put(skb, sizeof(*header));
-- 
1.8.2.1
