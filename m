From: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Subject: [PATCH,
	RFC] enc28j60: use only one spi_message per register access
Date: Mon, 22 Dec 2008 16:19:59 +0200
Message-ID: <20081222141958.GA27240@diamond.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Claudio Lanconelli <lanconelli.claudio-DtroZxfa9uMAvxtiuMwx3w@public.gmane.org>
Return-path: <spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=spi-devel-general>
List-Post: <mailto:spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

A major cause of overhead in the enc28j60 driver is the SPI transfers used for  
registers access. Each SPI transfer entails two kernel thread context 
switches. Each register access requires up to 4 SPI transfers (two for setting 
the register bank, and two for reading/writing the register in case of 16 bit 
registers).

With this patch the enc28j60 driver uses one spi_message per register access.  
Multiple spi_transfer structs are used in each spi_message to make the bank 
switching and the register access in the context of one spi_message.

My tests show that this patch cuts about 20% of the round trip time for a 
simple ping test. The system I used for these test is a ARM926EJ-S based chip, 
clocked at 112MHz, with 8KB I-cache and 8KB D-cache.

Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
---

--- drivers/net/enc28j60.c-git	2008-12-22 13:58:40.000000000 +0200
+++ drivers/net/enc28j60.c	2008-12-22 15:49:38.000000000 +0200
@@ -74,6 +74,8 @@ struct enc28j60_net {
 	int rxfilter;
 	u32 msg_enable;
 	u8 spi_transfer_buf[SPI_TRANSFER_BUF_LEN];
+	unsigned spi_transfer_buf_off;
+	struct spi_transfer transfers[4];
 };
 
 /* use ethtool to change the level for any given device */
@@ -137,30 +139,22 @@ static int spi_write_buf(struct enc28j60
 }
 
 /*
- * basic SPI read operation
+ * add register read spi_transfer to an spi_message
  */
-static u8 spi_read_op(struct enc28j60_net *priv, u8 op,
-			   u8 addr)
+static void spi_read_t(struct enc28j60_net *priv, u8 op,
+			   u8 addr, unsigned tidx, struct spi_message *m)
 {
-	u8 tx_buf[2];
-	u8 rx_buf[4];
-	u8 val = 0;
-	int ret;
-	int slen = SPI_OPLEN;
-
-	/* do dummy read if needed */
-	if (addr & SPRD_MASK)
-		slen++;
-
-	tx_buf[0] = op | (addr & ADDR_MASK);
-	ret = spi_write_then_read(priv->spi, tx_buf, 1, rx_buf, slen);
-	if (ret)
-		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-			__func__, ret);
-	else
-		val = rx_buf[slen - 1];
+	int slen = (addr & SPRD_MASK) ? 3 : 2; /* dummy byte */
 
-	return val;
+	priv->transfers[tidx].tx_buf = priv->transfers[tidx].rx_buf =
+		&priv->spi_transfer_buf[priv->spi_transfer_buf_off];
+	priv->spi_transfer_buf[priv->spi_transfer_buf_off] =
+		op | (addr & ADDR_MASK);
+	priv->transfers[tidx].len = slen;
+	priv->transfers[tidx].cs_change = 1;
+	priv->spi_transfer_buf_off += slen;
+	spi_message_add_tail(&priv->transfers[tidx], m);
+	spi_message_add_tail(&priv->transfers[tidx+1], m);
 }
 
 /*
@@ -180,6 +174,21 @@ static int spi_write_op(struct enc28j60_
 	return ret;
 }
 
+
+static void spi_write_t(struct enc28j60_net *priv, u8 op,
+			u8 addr, u8 val, unsigned tidx, struct spi_message *m)
+{
+	priv->transfers[tidx].tx_buf = &priv->spi_transfer_buf[tidx*2];
+	priv->transfers[tidx].rx_buf = NULL;
+	priv->transfers[tidx].len = 2;
+	priv->transfers[tidx].cs_change = 1;
+	priv->spi_transfer_buf[tidx*2] = op | (addr & ADDR_MASK);
+	priv->spi_transfer_buf[tidx*2+1] = val;
+	priv->spi_transfer_buf_off += 2;
+	spi_message_add_tail(&priv->transfers[tidx], m);
+}
+
+
 static void enc28j60_soft_reset(struct enc28j60_net *priv)
 {
 	if (netif_msg_hw(priv))
@@ -193,35 +202,38 @@ static void enc28j60_soft_reset(struct e
 
 /*
  * select the current register bank if necessary
+ * return the number of spi_transfer structs used
  */
-static void enc28j60_set_bank(struct enc28j60_net *priv, u8 addr)
+static unsigned enc28j60_set_bank_t(struct enc28j60_net *priv, u8 addr,
+		struct spi_message *m)
 {
 	u8 b = (addr & BANK_MASK) >> 5;
+	unsigned t_count = 0;
 
-	/* These registers (EIE, EIR, ESTAT, ECON2, ECON1)
-	 * are present in all banks, no need to switch bank
-	 */
 	if (addr >= EIE && addr <= ECON1)
-		return;
+		return 0;
 
-	/* Clear or set each bank selection bit as needed */
 	if ((b & ECON1_BSEL0) != (priv->bank & ECON1_BSEL0)) {
 		if (b & ECON1_BSEL0)
-			spi_write_op(priv, ENC28J60_BIT_FIELD_SET, ECON1,
-					ECON1_BSEL0);
+			spi_write_t(priv, ENC28J60_BIT_FIELD_SET, ECON1,
+					ECON1_BSEL0, t_count, m);
 		else
-			spi_write_op(priv, ENC28J60_BIT_FIELD_CLR, ECON1,
-					ECON1_BSEL0);
+			spi_write_t(priv, ENC28J60_BIT_FIELD_CLR, ECON1,
+					ECON1_BSEL0, t_count, m);
+		t_count++;
 	}
 	if ((b & ECON1_BSEL1) != (priv->bank & ECON1_BSEL1)) {
 		if (b & ECON1_BSEL1)
-			spi_write_op(priv, ENC28J60_BIT_FIELD_SET, ECON1,
-					ECON1_BSEL1);
+			spi_write_t(priv, ENC28J60_BIT_FIELD_SET, ECON1,
+					ECON1_BSEL1, t_count, m);
 		else
-			spi_write_op(priv, ENC28J60_BIT_FIELD_CLR, ECON1,
-					ECON1_BSEL1);
+			spi_write_t(priv, ENC28J60_BIT_FIELD_CLR, ECON1,
+					ECON1_BSEL1, t_count, m);
+		t_count++;
 	}
-	priv->bank = b;
+	priv->bank = (addr & BANK_MASK) >> 5;
+
+	return t_count;
 }
 
 /*
@@ -241,8 +253,18 @@ static void enc28j60_set_bank(struct enc
 static void nolock_reg_bfset(struct enc28j60_net *priv,
 				      u8 addr, u8 mask)
 {
-	enc28j60_set_bank(priv, addr);
-	spi_write_op(priv, ENC28J60_BIT_FIELD_SET, addr, mask);
+	struct spi_message msg;
+	unsigned t_count;
+	int ret;
+
+	spi_message_init(&msg);
+	priv->spi_transfer_buf_off = 0;
+	t_count = enc28j60_set_bank_t(priv, addr, &msg);
+	spi_write_t(priv, ENC28J60_BIT_FIELD_SET, addr, mask, t_count, &msg);
+	ret = spi_sync(priv->spi, &msg);
+	if (ret && netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+			__func__, ret);
 }
 
 static void locked_reg_bfset(struct enc28j60_net *priv,
@@ -259,8 +281,18 @@ static void locked_reg_bfset(struct enc2
 static void nolock_reg_bfclr(struct enc28j60_net *priv,
 				      u8 addr, u8 mask)
 {
-	enc28j60_set_bank(priv, addr);
-	spi_write_op(priv, ENC28J60_BIT_FIELD_CLR, addr, mask);
+	struct spi_message msg;
+	unsigned t_count;
+	int ret;
+
+	spi_message_init(&msg);
+	priv->spi_transfer_buf_off = 0;
+	t_count = enc28j60_set_bank_t(priv, addr, &msg);
+	spi_write_t(priv, ENC28J60_BIT_FIELD_CLR, addr, mask, t_count, &msg);
+	ret = spi_sync(priv->spi, &msg);
+	if (ret && netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+			__func__, ret);
 }
 
 static void locked_reg_bfclr(struct enc28j60_net *priv,
@@ -277,8 +309,21 @@ static void locked_reg_bfclr(struct enc2
 static int nolock_regb_read(struct enc28j60_net *priv,
 				     u8 address)
 {
-	enc28j60_set_bank(priv, address);
-	return spi_read_op(priv, ENC28J60_READ_CTRL_REG, address);
+	struct spi_message msg;
+	unsigned t_count, len;
+	int ret;
+
+	spi_message_init(&msg);
+	memset(priv->transfers, 0, sizeof priv->transfers);
+	priv->spi_transfer_buf_off = 0;
+	t_count = enc28j60_set_bank_t(priv, address, &msg);
+	spi_read_t(priv, ENC28J60_READ_CTRL_REG, address, t_count, &msg);
+	ret = spi_sync(priv->spi, &msg);
+	if (ret && netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+			__func__, ret);
+	len = priv->transfers[t_count].len;
+	return ((u8 *) priv->transfers[t_count].rx_buf)[len-1];
 }
 
 static int locked_regb_read(struct enc28j60_net *priv,
@@ -299,11 +344,29 @@ static int locked_regb_read(struct enc28
 static int nolock_regw_read(struct enc28j60_net *priv,
 				     u8 address)
 {
+	struct spi_message msg;
+	unsigned t_count, len;
+	int ret;
 	int rl, rh;
 
-	enc28j60_set_bank(priv, address);
-	rl = spi_read_op(priv, ENC28J60_READ_CTRL_REG, address);
-	rh = spi_read_op(priv, ENC28J60_READ_CTRL_REG, address + 1);
+	spi_message_init(&msg);
+	memset(priv->transfers, 0, sizeof priv->transfers);
+	priv->spi_transfer_buf_off = 0;
+
+	t_count = enc28j60_set_bank_t(priv, address, &msg);
+	spi_read_t(priv, ENC28J60_READ_CTRL_REG, address, t_count, &msg);
+	spi_read_t(priv, ENC28J60_READ_CTRL_REG, address + 1,
+			 t_count+1, &msg);
+
+	ret = spi_sync(priv->spi, &msg);
+	if (ret && netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+			__func__, ret);
+
+	len = priv->transfers[t_count].len;
+	rl = ((u8 *) priv->transfers[t_count].rx_buf)[len-1];
+	len = priv->transfers[t_count+1].len;
+	rh = ((u8 *) priv->transfers[t_count+1].rx_buf)[len-1];
 
 	return (rh << 8) | rl;
 }
@@ -326,8 +389,19 @@ static int locked_regw_read(struct enc28
 static void nolock_regb_write(struct enc28j60_net *priv,
 				       u8 address, u8 data)
 {
-	enc28j60_set_bank(priv, address);
-	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, address, data);
+	struct spi_message msg;
+	unsigned t_count;
+	int ret;
+
+	spi_message_init(&msg);
+	priv->spi_transfer_buf_off = 0;
+	t_count = enc28j60_set_bank_t(priv, address, &msg);
+	spi_write_t(priv, ENC28J60_WRITE_CTRL_REG, address, data, t_count,
+			&msg);
+	ret = spi_sync(priv->spi, &msg);
+	if (ret && netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+			__func__, ret);
 }
 
 static void locked_regb_write(struct enc28j60_net *priv,
@@ -344,10 +418,21 @@ static void locked_regb_write(struct enc
 static void nolock_regw_write(struct enc28j60_net *priv,
 				       u8 address, u16 data)
 {
-	enc28j60_set_bank(priv, address);
-	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, address, (u8) data);
-	spi_write_op(priv, ENC28J60_WRITE_CTRL_REG, address + 1,
-		     (u8) (data >> 8));
+	struct spi_message msg;
+	unsigned t_count;
+	int ret;
+
+	spi_message_init(&msg);
+	priv->spi_transfer_buf_off = 0;
+	t_count = enc28j60_set_bank_t(priv, address, &msg);
+	spi_write_t(priv, ENC28J60_WRITE_CTRL_REG, address, (u8) data, t_count,
+			&msg);
+	spi_write_t(priv, ENC28J60_WRITE_CTRL_REG, address + 1,
+			 (u8) (data >> 8), t_count+1, &msg);
+	ret = spi_sync(priv->spi, &msg);
+	if (ret && netif_msg_drv(priv))
+		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
+			__func__, ret);
 }
 
 static void locked_regw_write(struct enc28j60_net *priv,

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org - tel: +972.2.679.5364, http://www.tkos.co.il -

------------------------------------------------------------------------------
