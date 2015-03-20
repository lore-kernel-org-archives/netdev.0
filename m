From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 1/5] net: netcp: fix forward port number usage for 10G ethss
Date: Fri, 20 Mar 2015 16:11:21 -0400
Message-ID: <1426882285-4873-2-git-send-email-m-karicheri2@ti.com>
References: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>,
	WingMan Kwok <w-kwok2@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Christoph Jaeger <cj@linux.com>,
	Lokesh Vutla <lokeshvutla@ti.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

10G switch requires forward port number in the taginfo field,
where as it should be in packet_info field for necp 1.4 Ethss. So
fill this value correctly in the knav dma descriptor.

Also rename dma_psflags field in struct netcp_tx_pipe to switch_to_port
as it contain no flag, but the switch port number for forwarding the
packet. Add a flag to hold the new flag,  SWITCH_TO_PORT_IN_TAGINFO which
will be set for 10G. This can also used in the future for other flags for
the tx_pipe.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Mugunthan V N <mugunthanvnm@ti.com>
CC: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
CC: Grygorii Strashko <grygorii.strashko@ti.com>
CC: Christoph Jaeger <cj@linux.com>
CC: Lokesh Vutla <lokeshvutla@ti.com>
CC: Markus Pargmann <mpa@pengutronix.de>
CC: Kumar Gala <galak@codeaurora.org>
CC: Ian Campbell <ijc+devicetree@hellion.org.uk>
CC: Mark Rutland <mark.rutland@arm.com>
CC: Pawel Moll <pawel.moll@arm.com>
CC: Rob Herring <robh+dt@kernel.org>
---
 drivers/net/ethernet/ti/netcp.h       |    5 ++++-
 drivers/net/ethernet/ti/netcp_core.c  |   23 +++++++++++++++--------
 drivers/net/ethernet/ti/netcp_ethss.c |   14 ++++++++++----
 3 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp.h b/drivers/net/ethernet/ti/netcp.h
index 906e9bc..bbacf5c 100644
--- a/drivers/net/ethernet/ti/netcp.h
+++ b/drivers/net/ethernet/ti/netcp.h
@@ -41,7 +41,10 @@ struct netcp_tx_pipe {
 	struct netcp_device	*netcp_device;
 	void			*dma_queue;
 	unsigned int		dma_queue_id;
-	u8			dma_psflags;
+	/* To port for packet forwarded to switch. Used only by ethss */
+	u8			switch_to_port;
+#define	SWITCH_TO_PORT_IN_TAGINFO	BIT(0)
+	u8			flags;
 	void			*dma_channel;
 	const char		*dma_chan_name;
 };
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index a31a8c3..d867636 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1098,9 +1098,9 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 	struct netcp_tx_pipe *tx_pipe = NULL;
 	struct netcp_hook_list *tx_hook;
 	struct netcp_packet p_info;
-	u32 packet_info = 0;
 	unsigned int dma_sz;
 	dma_addr_t dma;
+	u32 tmp = 0;
 	int ret = 0;
 
 	p_info.netcp = netcp;
@@ -1140,20 +1140,27 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 		memmove(p_info.psdata, p_info.psdata + p_info.psdata_len,
 			p_info.psdata_len);
 		set_words(psdata, p_info.psdata_len, psdata);
-		packet_info |=
-			(p_info.psdata_len & KNAV_DMA_DESC_PSLEN_MASK) <<
+		tmp |= (p_info.psdata_len & KNAV_DMA_DESC_PSLEN_MASK) <<
 			KNAV_DMA_DESC_PSLEN_SHIFT;
 	}
 
-	packet_info |= KNAV_DMA_DESC_HAS_EPIB |
+	tmp |= KNAV_DMA_DESC_HAS_EPIB |
 		((netcp->tx_compl_qid & KNAV_DMA_DESC_RETQ_MASK) <<
-		KNAV_DMA_DESC_RETQ_SHIFT) |
-		((tx_pipe->dma_psflags & KNAV_DMA_DESC_PSFLAG_MASK) <<
-		KNAV_DMA_DESC_PSFLAG_SHIFT);
+		KNAV_DMA_DESC_RETQ_SHIFT);
 
-	set_words(&packet_info, 1, &desc->packet_info);
+	if (!(tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO)) {
+		tmp |= ((tx_pipe->switch_to_port & KNAV_DMA_DESC_PSFLAG_MASK) <<
+			KNAV_DMA_DESC_PSFLAG_SHIFT);
+	}
+
+	set_words(&tmp, 1, &desc->packet_info);
 	set_words((u32 *)&skb, 1, &desc->pad[0]);
 
+	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
+		tmp = tx_pipe->switch_to_port;
+		set_words((u32 *)&tmp, 1, &desc->tag_info);
+	}
+
 	/* submit packet descriptor */
 	ret = knav_pool_desc_map(netcp->tx_pool, desc, sizeof(*desc), &dma,
 				 &dma_sz);
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 84f5ce5..2be90a5 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -1472,15 +1472,21 @@ static int gbe_open(void *intf_priv, struct net_device *ndev)
 		GBE_MAJOR_VERSION(reg), GBE_MINOR_VERSION(reg),
 		GBE_RTL_VERSION(reg), GBE_IDENT(reg));
 
+	/* For 10G use directed to port */
+	if (gbe_dev->ss_version == XGBE_SS_VERSION_10)
+		gbe_intf->tx_pipe.flags = SWITCH_TO_PORT_IN_TAGINFO;
+
 	if (gbe_dev->enable_ale)
-		gbe_intf->tx_pipe.dma_psflags = 0;
+		gbe_intf->tx_pipe.switch_to_port = 0;
 	else
-		gbe_intf->tx_pipe.dma_psflags = port_num;
+		gbe_intf->tx_pipe.switch_to_port = port_num;
 
-	dev_dbg(gbe_dev->dev, "opened TX channel %s: %p with psflags %d\n",
+	dev_dbg(gbe_dev->dev,
+		"opened TX channel %s: %p with to port %d, flags %d\n",
 		gbe_intf->tx_pipe.dma_chan_name,
 		gbe_intf->tx_pipe.dma_channel,
-		gbe_intf->tx_pipe.dma_psflags);
+		gbe_intf->tx_pipe.switch_to_port,
+		gbe_intf->tx_pipe.flags);
 
 	gbe_slave_stop(gbe_intf);
 
-- 
1.7.9.5
