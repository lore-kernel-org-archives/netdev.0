From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 16/22] xfrm offload v2: typhoon: collect crypto offload capabilities
Date: Mon, 10 Jan 2005 10:37:02 -0500
Message-ID: <20040110014300.25@ori.thedillows.org>
References: <20040110014300.24@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:57:15-05:00 dave@thedillows.org 
#   Collect some information about the Typhoon's offload capabilities,
#   and store it for future use.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# drivers/net/typhoon.h
#   2005/01/10 00:56:57-05:00 dave@thedillows.org +14 -0
#   Add the reply message format for the crypto capability query command.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# drivers/net/typhoon.c
#   2005/01/10 00:56:57-05:00 dave@thedillows.org +56 -0
#   Collect some information about the Typhoon's offload capabilities,
#   and store it for future use.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2005-01-10 01:17:33 -05:00
+++ b/drivers/net/typhoon.c	2005-01-10 01:17:33 -05:00
@@ -304,6 +304,12 @@
 	u16			wol_events;
 	u32			offload;
 
+	u16			tx_sa_max;
+	u16			rx_sa_max;
+	u16			tx_sa_avail;
+	u16			rx_sa_avail;
+	int			sa_count;
+
 	/* unused stuff (future use) */
 	int			capabilities;
 	struct transmit_ring 	txHiRing;
@@ -2104,6 +2110,53 @@
 	return 0;
 }
 
+static inline int
+typhoon_ipsec_init(struct typhoon *tp)
+{
+	struct cmd_desc xp_cmd;
+	struct resp_desc xp_resp;
+	struct ipsec_info_desc *info = (struct ipsec_info_desc *) &xp_resp;
+	u16 last_tx, last_rx, last_cap;
+	int err;
+
+	last_tx = tp->tx_sa_max;
+	last_rx = tp->rx_sa_max;
+	last_cap = tp->capabilities;
+
+	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_IPSEC_INFO);
+	err = typhoon_issue_command(tp, 1, &xp_cmd, 1, &xp_resp);
+	if(err < 0)
+		goto out;
+
+	/* We're not up yet, so no need to lock this -- we cannot modify
+	 * these fields yet.
+	 */
+	tp->tx_sa_avail = tp->tx_sa_max = le16_to_cpu(info->tx_sa_max);
+	tp->rx_sa_avail = tp->rx_sa_max = le16_to_cpu(info->rx_sa_max);
+	tp->sa_count = 0;
+
+	/* Typhoon2 was originally going to have variable crypto capabilities,
+	 * subject to registration with 3Com. It appears they have decided
+	 * to just enable 3DES as well.
+	 */
+	if(tp->capabilities & TYPHOON_CRYPTO_VARIABLE) {
+		tp->capabilities &= ~TYPHOON_CRYPTO_VARIABLE;
+		tp->capabilities |= TYPHOON_CRYPTO_DES | TYPHOON_CRYPTO_3DES;
+	}
+
+	if(last_tx != tp->tx_sa_max || last_rx != tp->rx_sa_max ||
+					last_cap != tp->capabilities) {
+		printk(KERN_INFO "%s: IPSEC offload %s%s %d Tx %d Rx\n",
+			tp->name,
+			tp->capabilities & TYPHOON_CRYPTO_DES ? "DES " : "",
+			tp->capabilities & TYPHOON_CRYPTO_3DES ? "3DES" : "",
+			tp->tx_sa_max, tp->rx_sa_max);
+	}
+
+out:
+	return err;
+}
+
 static int
 typhoon_start_runtime(struct typhoon *tp)
 {
@@ -2126,6 +2179,9 @@
 		err = -EIO;
 		goto error_out;
 	}
+
+	if(typhoon_ipsec_init(tp))
+		goto error_out;
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_SET_MAX_PKT_SIZE);
 	xp_cmd.parm1 = cpu_to_le16(PKT_BUF_SZ);
diff -Nru a/drivers/net/typhoon.h b/drivers/net/typhoon.h
--- a/drivers/net/typhoon.h	2005-01-10 01:17:33 -05:00
+++ b/drivers/net/typhoon.h	2005-01-10 01:17:33 -05:00
@@ -487,6 +487,20 @@
 	u32 unused2;
 } __attribute__ ((packed));
 
+/* TYPHOON_CMD_READ_IPSEC_INFO response descriptor
+ */
+struct ipsec_info_desc {
+	u8  flags;
+	u8  numDesc;
+	u16 cmd;
+	u16 seqNo;
+	u16 des_enabled;
+	u16 tx_sa_max;
+	u16 rx_sa_max;
+	u16 tx_sa_count;
+	u16 rx_sa_count;
+} __attribute__ ((packed));
+
 /* TYPHOON_CMD_SET_OFFLOAD_TASKS bits (cmd.parm2 (Tx) & cmd.parm3 (Rx))
  * This is all for IPv4.
  */
