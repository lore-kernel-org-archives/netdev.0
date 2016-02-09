From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH v3 4/6] net: phy: spi_ks8995: generalize creation of SPI commands
Date: Tue,  9 Feb 2016 20:47:16 +0100
Message-ID: <1455047238-111358-5-git-send-email-helmut.buchsbaum@gmail.com>
References: <1455047238-111358-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32997 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932414AbcBITrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 14:47:39 -0500
Received: by mail-wm0-f66.google.com with SMTP id c200so5402914wme.0
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 11:47:39 -0800 (PST)
In-Reply-To: <1455047238-111358-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare creating SPI reads and writes for other switch families.
The KS8995 family uses the straight forward
	<8bit CMD><8bit ADDR>
sequence.
To be able to support KSZ8795 family, which uses
	<3bit CMD><12bit ADDR><1 bit TR>
make the SPI command creation chip variant dependent.

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/phy/spi_ks8995.c | 46 +++++++++++++++++++++++++++++++++-----------
 1 file changed, 35 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 04d468f..f866786 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -105,6 +105,8 @@ struct ks8995_chip_params {
 	int family_id;
 	int chip_id;
 	int regs_size;
+	int addr_width;
+	int addr_shift;
 };
 
 static const struct ks8995_chip_params ks8995_chip[] = {
@@ -113,12 +115,16 @@ static const struct ks8995_chip_params ks8995_chip[] = {
 		.family_id = FAMILY_KS8995,
 		.chip_id = KS8995_CHIP_ID,
 		.regs_size = KS8995_REGS_SIZE,
+		.addr_width = 8,
+		.addr_shift = 0,
 	},
 	[ksz8864] = {
 		.name = "KSZ8864RMN",
 		.family_id = FAMILY_KS8995,
 		.chip_id = KSZ8864_CHIP_ID,
 		.regs_size = KSZ8864_REGS_SIZE,
+		.addr_width = 8,
+		.addr_shift = 0,
 	},
 };
 
@@ -153,20 +159,44 @@ static inline u8 get_chip_rev(u8 val)
 	return (val >> ID1_REVISION_S) & ID1_REVISION_M;
 }
 
+/* create_spi_cmd - create a chip specific SPI command header
+ * @ks: pointer to switch instance
+ * @cmd: SPI command for switch
+ * @address: register address for command
+ *
+ * Different chip families use different bit pattern to address the switches
+ * registers:
+ *
+ * KS8995: 8bit command + 8bit address
+ * KSZ8795: 3bit command + 12bit address + 1bit TR (?)
+ */
+static inline __be16 create_spi_cmd(struct ks8995_switch *ks, int cmd,
+				    unsigned address)
+{
+	u16 result = cmd;
+
+	/* make room for address (incl. address shift) */
+	result <<= ks->chip->addr_width + ks->chip->addr_shift;
+	/* add address */
+	result |= address << ks->chip->addr_shift;
+	/* SPI protocol needs big endian */
+	return cpu_to_be16(result);
+}
 /* ------------------------------------------------------------------------ */
 static int ks8995_read(struct ks8995_switch *ks, char *buf,
 		 unsigned offset, size_t count)
 {
-	u8 cmd[2];
+	__be16 cmd;
 	struct spi_transfer t[2];
 	struct spi_message m;
 	int err;
 
+	cmd = create_spi_cmd(ks, KS8995_CMD_READ, offset);
 	spi_message_init(&m);
 
 	memset(&t, 0, sizeof(t));
 
-	t[0].tx_buf = cmd;
+	t[0].tx_buf = &cmd;
 	t[0].len = sizeof(cmd);
 	spi_message_add_tail(&t[0], &m);
 
@@ -174,9 +204,6 @@ static int ks8995_read(struct ks8995_switch *ks, char *buf,
 	t[1].len = count;
 	spi_message_add_tail(&t[1], &m);
 
-	cmd[0] = KS8995_CMD_READ;
-	cmd[1] = offset;
-
 	mutex_lock(&ks->lock);
 	err = spi_sync(ks->spi, &m);
 	mutex_unlock(&ks->lock);
@@ -184,20 +211,20 @@ static int ks8995_read(struct ks8995_switch *ks, char *buf,
 	return err ? err : count;
 }
 
-
 static int ks8995_write(struct ks8995_switch *ks, char *buf,
 		 unsigned offset, size_t count)
 {
-	u8 cmd[2];
+	__be16 cmd;
 	struct spi_transfer t[2];
 	struct spi_message m;
 	int err;
 
+	cmd = create_spi_cmd(ks, KS8995_CMD_WRITE, offset);
 	spi_message_init(&m);
 
 	memset(&t, 0, sizeof(t));
 
-	t[0].tx_buf = cmd;
+	t[0].tx_buf = &cmd;
 	t[0].len = sizeof(cmd);
 	spi_message_add_tail(&t[0], &m);
 
@@ -205,9 +232,6 @@ static int ks8995_write(struct ks8995_switch *ks, char *buf,
 	t[1].len = count;
 	spi_message_add_tail(&t[1], &m);
 
-	cmd[0] = KS8995_CMD_WRITE;
-	cmd[1] = offset;
-
 	mutex_lock(&ks->lock);
 	err = spi_sync(ks->spi, &m);
 	mutex_unlock(&ks->lock);
-- 
2.1.4
