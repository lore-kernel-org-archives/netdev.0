From: Scott Feldman <scott.feldman@intel.com>
Subject: [e100 2.6 2/2] big-endian fix for ethtool -e/E
Date: Mon, 3 May 2004 15:01:13 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405031458360.5014@sfeldma-ich5.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Reads/write from/to eeprom using ethtool weren't working right
  on big-endian.  Now they are.

--------------

--- linux-2.5/drivers/net/e100.c	2004-05-03 14:46:27.872163392 -0700
+++ linux-2.5/drivers/net/e100.c.mod	2004-05-03 14:47:50.209646192 -0700
@@ -641,7 +641,8 @@ static void e100_eeprom_write(struct nic

 	/* Three cmds: write/erase enable, write data, write/erase disable */
 	cmd_addr_data[0] = op_ewen << (addr_len - 2);
-	cmd_addr_data[1] = (((op_write << addr_len) | addr) << 16) | data;
+	cmd_addr_data[1] = (((op_write << addr_len) | addr) << 16) |
+		cpu_to_le16(data);
 	cmd_addr_data[2] = op_ewds << (addr_len - 2);

 	/* Bit-bang cmds to write word to eeprom */
@@ -668,7 +669,6 @@ static void e100_eeprom_write(struct nic
 		writeb(0, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
 	}
-
 };

 /* General technique stolen from the eepro100 driver - very clever */
@@ -709,7 +709,7 @@ static u16 e100_eeprom_read(struct nic *
 	writeb(0, &nic->csr->eeprom_ctrl_lo);
 	e100_write_flush(nic); udelay(4);

-	return data;
+	return le16_to_cpu(data);
 };

 /* Load entire EEPROM image into driver cache and validate checksum */
@@ -724,12 +724,12 @@ static int e100_eeprom_load(struct nic *
 	for(addr = 0; addr < nic->eeprom_wc; addr++) {
 		nic->eeprom[addr] = e100_eeprom_read(nic, &addr_len, addr);
 		if(addr < nic->eeprom_wc - 1)
-			checksum += nic->eeprom[addr];
+			checksum += cpu_to_le16(nic->eeprom[addr]);
 	}

 	/* The checksum, stored in the last word, is calculated such that
 	 * the sum of words should be 0xBABA */
-	checksum = 0xBABA - checksum;
+	checksum = le16_to_cpu(0xBABA - checksum);
 	if(checksum != nic->eeprom[nic->eeprom_wc - 1]) {
 		DPRINTK(PROBE, ERR, "EEPROM corrupted\n");
 		return -EAGAIN;
@@ -756,9 +756,10 @@ static int e100_eeprom_save(struct nic *
 	/* The checksum, stored in the last word, is calculated such that
 	 * the sum of words should be 0xBABA */
 	for(addr = 0; addr < nic->eeprom_wc - 1; addr++)
-		checksum += nic->eeprom[addr];
-	nic->eeprom[nic->eeprom_wc - 1] = 0xBABA - checksum;
-	e100_eeprom_write(nic, addr_len, nic->eeprom_wc - 1, 0xBABA - checksum);
+		checksum += cpu_to_le16(nic->eeprom[addr]);
+	nic->eeprom[nic->eeprom_wc - 1] = le16_to_cpu(0xBABA - checksum);
+	e100_eeprom_write(nic, addr_len, nic->eeprom_wc - 1,
+		nic->eeprom[nic->eeprom_wc - 1]);

 	return 0;
 }
@@ -1901,6 +1902,7 @@ static int e100_set_eeprom(struct net_de

 	if(eeprom->magic != E100_EEPROM_MAGIC)
 		return -EINVAL;
+
 	memcpy(&((u8 *)nic->eeprom)[eeprom->offset], bytes, eeprom->len);

 	return e100_eeprom_save(nic, eeprom->offset >> 1,
@@ -2209,9 +2211,8 @@ static int __devinit e100_probe(struct p

 	if((err = e100_eeprom_load(nic)))
 		goto err_out_free;
-	((u16 *)netdev->dev_addr)[0] = le16_to_cpu(nic->eeprom[0]);
-	((u16 *)netdev->dev_addr)[1] = le16_to_cpu(nic->eeprom[1]);
-	((u16 *)netdev->dev_addr)[2] = le16_to_cpu(nic->eeprom[2]);
+
+	memcpy(netdev->dev_addr, nic->eeprom, ETH_ALEN);
 	if(!is_valid_ether_addr(netdev->dev_addr)) {
 		DPRINTK(PROBE, ERR, "Invalid MAC address from "
 			"EEPROM, aborting.\n");
