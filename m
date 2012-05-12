From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v4 01/13] mac802154: basic ieee802.15.4 device structures
Date: Sat, 12 May 2012 17:59:13 +0400
Message-ID: <1336831165-23944-2-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:50719 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754647Ab2ELOAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 10:00:12 -0400
Received: by weyu7 with SMTP id u7so920892wey.19
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 07:00:10 -0700 (PDT)
In-Reply-To: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IEEE 802.15.4 Working Group focuses on the standardization of the
bottom two layers of ISO/OSI protocol stack: Physical (PHY) and MAC.
The MAC layer provides access control to a shared channel and reliable
data delivery. The main functions performed by the MAC sublayer are:
association and disassociation, security control, optional star
network topology functions, such as beacon generation and Guaranteed
Time Slots (GTSs) management, generation of ACK frames (if used), and,
finally, application support for the two possible network topologies
described in the standard.

This is an initial commit which describes main data structures needed
for ieee802.15.4 compatible devices representation in MAC layer and
callbacks that the driver may, or in some cases, must handle, for
example to transmit a frame

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/net/mac802154.h |  131 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 131 insertions(+), 0 deletions(-)
 create mode 100644 include/net/mac802154.h

diff --git a/include/net/mac802154.h b/include/net/mac802154.h
new file mode 100644
index 0000000..a846511
--- /dev/null
+++ b/include/net/mac802154.h
@@ -0,0 +1,131 @@
+/*
+ * IEEE802.15.4-2003 specification
+ *
+ * Copyright (C) 2007-2011 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+#ifndef NET_MAC802154_H
+#define NET_MAC802154_H
+
+#include <net/af_ieee802154.h>
+
+/*
+ * The following flags are used to indicate changed address settings from
+ * the stack to the hardware.
+ */
+
+/* indicates that the Short Address changed*/
+#define IEEE802515_AFILT_SADDR_CHANGED		0x00000001
+/* indicates that the IEEE Address changed */
+#define IEEE802515_AFILT_IEEEADDR_CHANGED	0x00000002
+/* indicates that the PAN ID changed */
+#define IEEE802515_AFILT_PANID_CHANGED		0x00000004
+/* indicates that PAN Coordinator status changed */
+#define	IEEE802515_AFILT_PANC_CHANGED		0x00000008
+
+struct ieee802154_hw_addr_filt {
+	__le16	pan_id;		/* Each independent PAN selects a unique
+				 * identifier. This PAN id allows communication
+				 * between devices within a network using short
+				 * addresses and enables transmissions between
+				 * devices across independent networks.
+				 */
+	__le16	short_addr;
+	u8	ieee_addr[IEEE802154_ADDR_LEN];
+	u8	pan_coord;
+};
+
+struct ieee802154_dev {
+	/* filled by the driver */
+	int	extra_tx_headroom;		/* tx headroom to reserve */
+	u32	flags;				/* flags for device to set */
+	struct	device *parent;
+
+	/* filled by mac802154 core */
+	struct	ieee802154_hw_addr_filt hw_filt;
+	void	*priv;				/* driver-specific data */
+	struct	wpan_phy *phy;
+};
+
+/* Checksum is in hardware and is omitted from packet
+ *
+ * These following flags are used to indicate hardware capabilities to
+ * the stack. Generally, flags here should have their meaning
+ * done in a way that the simplest hardware doesn't need setting
+ * any particular flags. There are some exceptions to this rule,
+ * however, so you are advised to review these flags carefully.
+ */
+
+/*
+ * Indicates that receiver omits FCS and transmitter will add
+ * FCS on it's own.
+ */
+#define	IEEE802154_HW_OMIT_CKSUM	0x00000001
+/* Indicates that receiver will autorespond with ACK frames. */
+#define	IEEE802154_HW_AACK		0x00000002
+
+/**
+ * struct ieee802154_ops - callbacks from mac802154 to the driver
+ *
+ * This structure contains various callbacks that the driver may
+ * handle or, in some cases, must handle, for example to transmit
+ * a frame.
+ *
+ * @start: Handler that 802.15.4 module calls for device initialisation.
+ *	This function is called before the first interface is attached.
+ *
+ * @stop: Handler that 802.15.4 module calls for device cleanup
+ *	This function is called after the last interface is removed.
+ *
+ * @xmit: Handler that 802.15.4 module calls for each transmitted frame.
+ *	skb cntains the buffer starting from the IEEE 802.15.4 header.
+ *	The low-level driver should send the frame based on available
+ *	configuration.
+ *	This function should return zero or negative errno.
+ *	Called with pib_lock held.
+ *
+ * @ed: Handler that 802.15.4 module calls for Energy Detection.
+ *	This function should place the value for detected energy
+ *	(usually device-dependant) in the level pointer and return
+ *	either zero or negative errno.
+ *	Called with pib_lock held.
+ *
+ * @set_channel: Set radio for listening on specific channel.
+ *	Set the device for listening on specified channel.
+ *	Returns either zero, or negative errno.
+ *	Called with pib_lock held.
+ *
+ * @set_hw_addr_filt: Set radio for listening on specific address.
+ *	Set the device for listening on specified address.
+ *	Returns either zero, or negative errno.
+ */
+struct ieee802154_ops {
+	struct module	*owner;
+	int		(*start)(struct ieee802154_dev *dev);
+	void		(*stop)(struct ieee802154_dev *dev);
+	int		(*xmit)(struct ieee802154_dev *dev,
+				struct sk_buff *skb);
+	int		(*ed)(struct ieee802154_dev *dev, u8 *level);
+	int		(*set_channel)(struct ieee802154_dev *dev,
+				       int page,
+				       int channel);
+	int		(*set_hw_addr_filt)(struct ieee802154_dev *dev,
+					  struct ieee802154_hw_addr_filt *filt,
+					    unsigned long changed);
+	int		(*ieee_addr)(struct ieee802154_dev *dev,
+				     u8 addr[IEEE802154_ADDR_LEN]);
+};
+
+#endif /* NET_MAC802154_H */
-- 
1.7.2.3
