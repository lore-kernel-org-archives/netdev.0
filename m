From: ganesh.venkatesan@intel.com
Subject: [PATCH 4/6 2.5] e100 - Support to load device firmware
Date: Thu, 29 Jul 2004 08:26:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290654500.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- linux-2.5/drivers/net/e100.c	2004-07-29 00:27:31.495933808 -0700
+++ linux-2.5/drivers/net/e100.c.mod	2004-07-29 00:28:30.382981616 -0700
@@ -353,10 +353,12 @@ enum cb_status {
 };
 
 enum cb_command {
+	cb_nop    = 0x0000,
 	cb_iaaddr = 0x0001,
 	cb_config = 0x0002,
 	cb_multi  = 0x0003,
 	cb_tx     = 0x0004,
+	cb_ucode  = 0x0005,
 	cb_dump   = 0x0006,
 	cb_tx_sf  = 0x0008,
 	cb_cid    = 0x1f00,
@@ -431,12 +433,14 @@ struct multi {
 };
 
 /* Important: keep total struct u32-aligned */
+#define UCODE_SIZE			134
 struct cb {
 	u16 status;
 	u16 command;
 	u32 link;
 	union {
 		u8 iaaddr[ETH_ALEN];
+		u32 ucode[UCODE_SIZE];
 		struct config config;
 		struct multi multi;
 		struct {
@@ -984,6 +988,27 @@ static void e100_configure(struct nic *n
 		c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
 }
 
+static void e100_load_ucode(struct nic *nic, struct cb *cb, struct sk_buff *skb)
+{
+	int i;
+	static const u32 ucode[UCODE_SIZE] = {
+		/* NFS packets are misinterpreted as TCO packets and
+		 * incorrectly routed to the BMC over SMBus.  This
+		 * microcode patch checks the fragmented IP bit in the
+		 * NFS/UDP header to distinguish between NFS and TCO. */
+		0x0EF70E36, 0x1FFF1FFF, 0x1FFF1FFF, 0x1FFF1FFF, 0x1FFF1FFF,
+		0x1FFF1FFF, 0x00906E41, 0x00800E3C, 0x00E00E39, 0x00000000,
+		0x00906EFD, 0x00900EFD,	0x00E00EF8,
+	};
+
+	if(nic->mac == mac_82551_F || nic->mac == mac_82551_10) {
+		for(i = 0; i < UCODE_SIZE; i++)
+			cb->u.ucode[i] = cpu_to_le32(ucode[i]);
+		cb->command = cpu_to_le16(cb_ucode);
+	} else
+		cb->command = cpu_to_le16(cb_nop);
+}
+
 static void e100_setup_iaaddr(struct nic *nic, struct cb *cb,
 	struct sk_buff *skb)
 {
@@ -1073,6 +1098,8 @@ static int e100_hw_init(struct nic *nic)
 		return err;
 	if((err = e100_exec_cmd(nic, ruc_load_base, 0)))
 		return err;
+	if((err = e100_exec_cb(nic, NULL, e100_load_ucode)))
+		return err;
 	if((err = e100_exec_cb(nic, NULL, e100_configure)))
 		return err;
 	if((err = e100_exec_cb(nic, NULL, e100_setup_iaaddr)))
