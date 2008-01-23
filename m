From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 1/3] pasemi_mac: Add support for changing mac address
Date: Wed, 23 Jan 2008 13:56:19 -0600
Message-ID: <20080123195619.GB32380@lixom.net>
References: <20080123195537.GA32380@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46902 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740AbYAWTx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 14:53:29 -0500
Content-Disposition: inline
In-Reply-To: <20080123195537.GA32380@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Straightforward. It used to be hardcoded and impossible to override
with ifconfig.

Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index bb88a41..59dea3f 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -221,6 +221,33 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 	return 0;
 }
 
+static int pasemi_mac_set_mac_addr(struct net_device *dev, void *p)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	struct sockaddr *addr = p;
+	unsigned int adr0, adr1;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	adr0 = dev->dev_addr[2] << 24 |
+	       dev->dev_addr[3] << 16 |
+	       dev->dev_addr[4] << 8 |
+	       dev->dev_addr[5];
+	adr1 = read_mac_reg(mac, PAS_MAC_CFG_ADR1);
+	adr1 &= ~0xffff;
+	adr1 |= dev->dev_addr[0] << 8 | dev->dev_addr[1];
+
+	pasemi_mac_intf_disable(mac);
+	write_mac_reg(mac, PAS_MAC_CFG_ADR0, adr0);
+	write_mac_reg(mac, PAS_MAC_CFG_ADR1, adr1);
+	pasemi_mac_intf_enable(mac);
+
+	return 0;
+}
+
 static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
 		       void **tcph, u64 *hdr_flags, void *data)
 {
@@ -1475,6 +1502,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->stop = pasemi_mac_close;
 	dev->hard_start_xmit = pasemi_mac_start_tx;
 	dev->set_multicast_list = pasemi_mac_set_rx_mode;
+	dev->set_mac_address = pasemi_mac_set_mac_addr;
 
 	if (err)
 		goto out;
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
index 8bee2a6..39d3259 100644
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -96,6 +96,8 @@ struct pasemi_mac_buffer {
 /* MAC CFG register offsets */
 enum {
 	PAS_MAC_CFG_PCFG = 0x80,
+	PAS_MAC_CFG_ADR0 = 0x8c,
+	PAS_MAC_CFG_ADR1 = 0x90,
 	PAS_MAC_CFG_TXP = 0x98,
 	PAS_MAC_IPC_CHNL = 0x208,
 };
