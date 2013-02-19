From: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Subject: [PATCH 48/81] net: calxedaxgmac: throw away overrun frames
Date: Tue, 19 Feb 2013 15:49:11 -0300
Message-ID: <1361299784-8830-49-git-send-email-herton.krzesinski@canonical.com>
References: <1361299784-8830-1-git-send-email-herton.krzesinski@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	kernel-team@lists.ubuntu.com
Return-path: <kernel-team-bounces@lists.ubuntu.com>
In-Reply-To: <1361299784-8830-1-git-send-email-herton.krzesinski@canonical.com>
List-Unsubscribe: <https://lists.ubuntu.com/mailman/options/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=unsubscribe>
List-Archive: <https://lists.ubuntu.com/archives/kernel-team>
List-Post: <mailto:kernel-team@lists.ubuntu.com>
List-Help: <mailto:kernel-team-request@lists.ubuntu.com?subject=help>
List-Subscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=subscribe>
Sender: kernel-team-bounces@lists.ubuntu.com
Errors-To: kernel-team-bounces@lists.ubuntu.com
List-Id: netdev.vger.kernel.org

3.5.7.6 -stable review patch.  If anyone has any objections, please let me know.

------------------

From: Rob Herring <rob.herring@calxeda.com>

commit d6fb3be544b46a7611a3373fcaa62b5b0be01888 upstream.

The xgmac driver assumes 1 frame per descriptor. If a frame larger than
the descriptor's buffer size is received, the frame will spill over into
the next descriptor. So check for received frames that span more than one
descriptor and discard them. This prevents a crash if we receive erroneous
large packets.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 8b0a0e4..8a3cd87 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -546,6 +546,10 @@ static int desc_get_rx_status(struct xgmac_priv *priv, struct xgmac_dma_desc *p)
 		return -1;
 	}
 
+	/* All frames should fit into a single buffer */
+	if (!(status & RXDESC_FIRST_SEG) || !(status & RXDESC_LAST_SEG))
+		return -1;
+
 	/* Check if packet has checksum already */
 	if ((status & RXDESC_FRAME_TYPE) && (status & RXDESC_EXT_STATUS) &&
 		!(ext_status & RXDESC_IP_PAYLOAD_MASK))
-- 
1.7.9.5
