From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net-next v2 1/3] net/ncsi: Fix several packet definitions
Date: Mon, 14 Aug 2017 11:29:50 +1000
Message-ID: <20170814012952.13740-2-sam@mendozajonas.com>
References: <20170814012952.13740-1-sam@mendozajonas.com>
Cc: Samuel Mendoza-Jonas <sam@mendozajonas.com>,
        Joel Stanley <joel@jms.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>, ratagupt@in.ibm.com
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814012952.13740-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
v2: Rebased on latest net-next

 net/ncsi/ncsi-cmd.c | 10 +++++-----
 net/ncsi/ncsi-pkt.h |  2 +-
 net/ncsi/ncsi-rsp.c |  3 ++-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ncsi/ncsi-cmd.c b/net/ncsi/ncsi-cmd.c
index 5e03ed190e18..7567ca63aae2 100644
--- a/net/ncsi/ncsi-cmd.c
+++ b/net/ncsi/ncsi-cmd.c
@@ -139,9 +139,9 @@ static int ncsi_cmd_handler_svf(struct sk_buff *skb,
 	struct ncsi_cmd_svf_pkt *cmd;
 
 	cmd = skb_put_zero(skb, sizeof(*cmd));
-	cmd->vlan = htons(nca->words[0]);
-	cmd->index = nca->bytes[2];
-	cmd->enable = nca->bytes[3];
+	cmd->vlan = htons(nca->words[1]);
+	cmd->index = nca->bytes[6];
+	cmd->enable = nca->bytes[7];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
 	return 0;
@@ -153,7 +153,7 @@ static int ncsi_cmd_handler_ev(struct sk_buff *skb,
 	struct ncsi_cmd_ev_pkt *cmd;
 
 	cmd = skb_put_zero(skb, sizeof(*cmd));
-	cmd->mode = nca->bytes[0];
+	cmd->mode = nca->bytes[3];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
 	return 0;
@@ -228,7 +228,7 @@ static struct ncsi_cmd_handler {
 	{ NCSI_PKT_CMD_AE,     8, ncsi_cmd_handler_ae      },
 	{ NCSI_PKT_CMD_SL,     8, ncsi_cmd_handler_sl      },
 	{ NCSI_PKT_CMD_GLS,    0, ncsi_cmd_handler_default },
-	{ NCSI_PKT_CMD_SVF,    4, ncsi_cmd_handler_svf     },
+	{ NCSI_PKT_CMD_SVF,    8, ncsi_cmd_handler_svf     },
 	{ NCSI_PKT_CMD_EV,     4, ncsi_cmd_handler_ev      },
 	{ NCSI_PKT_CMD_DV,     0, ncsi_cmd_handler_default },
 	{ NCSI_PKT_CMD_SMA,    8, ncsi_cmd_handler_sma     },
diff --git a/net/ncsi/ncsi-pkt.h b/net/ncsi/ncsi-pkt.h
index 3ea49ed0a935..91b4b66438df 100644
--- a/net/ncsi/ncsi-pkt.h
+++ b/net/ncsi/ncsi-pkt.h
@@ -104,7 +104,7 @@ struct ncsi_cmd_svf_pkt {
 	unsigned char           index;     /* VLAN table index  */
 	unsigned char           enable;    /* Enable or disable */
 	__be32                  checksum;  /* Checksum          */
-	unsigned char           pad[14];
+	unsigned char           pad[18];
 };
 
 /* Enable VLAN */
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 087db775b3dc..c1a191d790e2 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -354,7 +354,8 @@ static int ncsi_rsp_handler_svf(struct ncsi_request *nr)
 
 	/* Add or remove the VLAN filter */
 	if (!(cmd->enable & 0x1)) {
-		ret = ncsi_remove_filter(nc, NCSI_FILTER_VLAN, cmd->index);
+		/* HW indexes from 1 */
+		ret = ncsi_remove_filter(nc, NCSI_FILTER_VLAN, cmd->index - 1);
 	} else {
 		vlan = ntohs(cmd->vlan);
 		ret = ncsi_add_filter(nc, NCSI_FILTER_VLAN, &vlan);
-- 
2.14.0
