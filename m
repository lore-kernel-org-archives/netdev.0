From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] libertas: fix return value when processing invalid packet
Date: Thu, 22 May 2014 07:32:41 -0500
Message-ID: <1400761961.15674.4.camel@dcbw.local>
References: <1400473875-22228-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1400473875-22228-2-git-send-email-Julia.Lawall@lip6.fr>
	 <5379FCD0.2030506@cogentembedded.com> <1400520341.3819.15.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, libertas-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, Julia Lawall <Julia.Lawall@lip6.fr>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400520341.3819.15.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nothing actually uses the return value yet, but we might as well
make it correct, like process_rxed_802_11_packet() does for the
same case.  Also ensure that if monitor mode is enabled (and
thus process_rxed_802_11_packet() is called) that the debugging
enter/leave functions are balanced.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
 drivers/net/wireless/libertas/Makefile | 4 ++--
 drivers/net/wireless/libertas/rx.c     | 8 +++++---
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index c7366b0..e446fed 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -67,30 +67,32 @@ int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
 
 	lbs_deb_enter(LBS_DEB_RX);
 
 	BUG_ON(!skb);
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	if (priv->wdev->iftype == NL80211_IFTYPE_MONITOR)
-		return process_rxed_802_11_packet(priv, skb);
+	if (priv->wdev->iftype == NL80211_IFTYPE_MONITOR) {
+		ret = process_rxed_802_11_packet(priv, skb);
+		goto done;
+	}
 
 	p_rx_pd = (struct rxpd *) skb->data;
 	p_rx_pkt = (struct rxpackethdr *) ((u8 *)p_rx_pd +
 		le32_to_cpu(p_rx_pd->pkt_ptr));
 
 	dev = lbs_mesh_set_dev(priv, dev, p_rx_pd);
 
 	lbs_deb_hex(LBS_DEB_RX, "RX Data: Before chop rxpd", skb->data,
 		 min_t(unsigned int, skb->len, 100));
 
 	if (skb->len < (ETH_HLEN + 8 + sizeof(struct rxpd))) {
 		lbs_deb_rx("rx err: frame received with bad length\n");
 		dev->stats.rx_length_errors++;
-		ret = 0;
+		ret = -EINVAL;
 		dev_kfree_skb(skb);
 		goto done;
 	}
 
 	lbs_deb_rx("rx data: skb->len - pkt_ptr = %d-%zd = %zd\n",
 		skb->len, (size_t)le32_to_cpu(p_rx_pd->pkt_ptr),
 		skb->len - (size_t)le32_to_cpu(p_rx_pd->pkt_ptr));
-- 
1.9.0
