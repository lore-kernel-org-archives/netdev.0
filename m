From: Daniel Silverstone <dsilvers@digital-scurf.org>
Subject: [PATCH 1/1] IEEE80154: Add documentation to the IEEE80154 netlink and fakehard driver
Date: Wed, 22 Jul 2009 18:51:24 +0200
Message-ID: <1248281484-3064-1-git-send-email-dsilvers@digital-scurf.org>
Cc: Daniel Silverstone <dsilvers@digital-scurf.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from flounder.pepperfish.net ([87.237.62.181]:55253 "EHLO
	flounder.pepperfish.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbZGVRTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 13:19:53 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds some perfunctory documentation comments to the IEEE 802.15.4
fakehard.c driver (Fake hard MAC) and the nl802154.h (outgoing netlink messages)
header.

These comments are not necessarily complete, but they do reference the
IEEE 802.15.4-2006 document where possible.

Signed-off-by: Daniel Silverstone <dsilvers@simtec.co.uk>
---
 drivers/ieee802154/fakehard.c     |  120 +++++++++++++++++++++++++++++++++++++
 include/net/ieee802154/nl802154.h |   76 +++++++++++++++++++++++
 2 files changed, 196 insertions(+), 0 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 0384144..9ec07e8 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -31,6 +31,12 @@
 #include <net/ieee802154/mac_def.h>
 #include <net/ieee802154/nl802154.h>
 
+/**
+ * fake_get_pan_id - Retrieve the PAN ID of the device.
+ * @dev: The network device to retrieve the PAN of.
+ *
+ * Return the ID of the PAN from the PIB.
+ */
 static u16 fake_get_pan_id(struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
@@ -38,6 +44,14 @@ static u16 fake_get_pan_id(struct net_device *dev)
 	return 0xeba1;
 }
 
+/**
+ * fake_get_short_addr - Retrieve the short address of the device.
+ * @dev: The network device to retrieve the short address of.
+ *
+ * Returns the IEEE 802.15.4 short-form address cached for this
+ * device. If the device has not yet had a short address assigned
+ * then this should return 0xFFFF to indicate a lack of association.
+ */
 static u16 fake_get_short_addr(struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
@@ -45,6 +59,19 @@ static u16 fake_get_short_addr(struct net_device *dev)
 	return 0x1;
 }
 
+/**
+ * fake_get_dsn - Retrieve the DSN of the device.
+ * @dev: The network device to retrieve the DSN for.
+ *
+ * Returns the IEEE 802.15.4 DSN for the network device.
+ * The DSN is the sequence number which will be added to each
+ * packet or MAC command frame by the MAC during transmission.
+ *
+ * DSN means 'Data Sequence Number'.
+ *
+ * Note: This is in section 7.2.1.2 of the IEEE 802.15.4-2006
+ *       document.
+ */
 static u8 fake_get_dsn(struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
@@ -52,6 +79,19 @@ static u8 fake_get_dsn(struct net_device *dev)
 	return 0x00; /* DSN are implemented in HW, so return just 0 */
 }
 
+/**
+ * fake_get_bsn - Retrieve the BSN of the device.
+ * @dev: The network device to retrieve the BSN for.
+ *
+ * Returns the IEEE 802.15.4 BSN for the network device.
+ * The BSN is the sequence number which will be added to each
+ * beacon frame sent by the MAC.
+ *
+ * BSN means 'Beacon Sequence Number'.
+ *
+ * Note: This is in section 7.2.1.2 of the IEEE 802.15.4-2006
+ *       document.
+ */
 static u8 fake_get_bsn(struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
@@ -59,6 +99,19 @@ static u8 fake_get_bsn(struct net_device *dev)
 	return 0x00; /* BSN are implemented in HW, so return just 0 */
 }
 
+/**
+ * fake_assoc_req - Make an association request to the HW.
+ * @dev: The network device which we are associating to a network.
+ * @addr: The coordinator with which we wish to associate.
+ * @channel: The channel on which to associate.
+ * @cap: The capability information field to use in the association.
+ *
+ * Start an association with a coordinator. The coordinator's address
+ * and PAN ID can be found in @addr.
+ *
+ * Note: This is in section 7.3.1 and 7.5.3.1 of the IEEE
+ *       802.15.4-2006 document.
+ */
 static int fake_assoc_req(struct net_device *dev,
 		struct ieee802154_addr *addr, u8 channel, u8 cap)
 {
@@ -67,18 +120,70 @@ static int fake_assoc_req(struct net_device *dev,
 			IEEE802154_SUCCESS);
 }
 
+/**
+ * fake_assoc_resp - Send an association response to a device.
+ * @dev: The network device on which to send the response.
+ * @addr: The address of the device to respond to.
+ * @short_addr: The assigned short address for the device (if any).
+ * @status: The result of the association request.
+ *
+ * Queue the association response of the coordinator to another
+ * device's attempt to associate with the network which we
+ * coordinate. This is then added to the indirect-send queue to be
+ * transmitted to the end device when it polls for data.
+ *
+ * Note: This is in section 7.3.2 and 7.5.3.1 of the IEEE
+ *       802.15.4-2006 document.
+ */
 static int fake_assoc_resp(struct net_device *dev,
 		struct ieee802154_addr *addr, u16 short_addr, u8 status)
 {
 	return 0;
 }
 
+/**
+ * fake_disassoc_req - Disassociate a device from a network.
+ * @dev: The network device on which we're disassociating a device.
+ * @addr: The device to disassociate from the network.
+ * @reason: The reason to give to the device for being disassociated.
+ *
+ * This sends a disassociation notification to the device being
+ * disassociated from the network.
+ *
+ * Note: This is in section 7.5.3.2 of the IEEE 802.15.4-2006
+ *       document, with the reason described in 7.3.3.2.
+ */
 static int fake_disassoc_req(struct net_device *dev,
 		struct ieee802154_addr *addr, u8 reason)
 {
 	return ieee802154_nl_disassoc_confirm(dev, IEEE802154_SUCCESS);
 }
 
+/**
+ * fake_start_req - Start an IEEE 802.15.4 PAN.
+ * @dev: The network device on which to start the PAN.
+ * @addr: The coordinator address to use when starting the PAN.
+ * @channel: The channel on which to start the PAN.
+ * @bcn_ord: Beacon order.
+ * @sf_ord: Superframe order.
+ * @pan_coord: Whether or not we are the PAN coordinator or just
+ *             requesting a realignment perhaps?
+ * @blx: Battery Life Extension feature bitfield.
+ * @coord_realign: Something to realign something else.
+ *
+ * If pan_coord is non-zero then this starts a network with the
+ * provided parameters, otherwise it attempts a coordinator
+ * realignment of the stated network instead.
+ *
+ * Note: This is in section 7.5.2.3 of the IEEE 802.15.4-2006
+ * document, with 7.3.8 describing coordinator realignment.
+ *
+ * Note: There is currently no way to notify the coordinator userland
+ * program of whether or not the PAN has started successfully. As
+ * such, the coordinator program cannot know when the MAC has
+ * completed starting the network and will simply have to assume
+ * completeness based on some form of time delay.
+ */
 static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
 				u8 channel,
 				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
@@ -87,6 +192,21 @@ static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
 	return 0;
 }
 
+/**
+ * fake_scan_req - Start a channel scan.
+ * @dev: The network device on which to perform a channel scan.
+ * @type: The type of scan to perform.
+ * @channels: The channel bitmask to scan.
+ * @duration: How long to spend on each channel.
+ *
+ * This starts either a passive (energy) scan or an active (PAN) scan
+ * on the channels indicated in the @channels bitmask. The duration of
+ * the scan is measured in terms of superframe duration. Specifically,
+ * the scan will spend aBaseSuperFrameDuration * ((2^n) + 1) on each
+ * channel.
+ *
+ * Note: This is in section 7.5.2.1 of the IEEE 802.15.4-2006 document.
+ */
 static int fake_scan_req(struct net_device *dev, u8 type, u32 channels,
 		u8 duration)
 {
diff --git a/include/net/ieee802154/nl802154.h b/include/net/ieee802154/nl802154.h
index 78efcdf..6096096 100644
--- a/include/net/ieee802154/nl802154.h
+++ b/include/net/ieee802154/nl802154.h
@@ -24,17 +24,93 @@
 struct net_device;
 struct ieee802154_addr;
 
+/**
+ * ieee802154_nl_assoc_indic - Notify userland of an association request.
+ * @dev: The network device on which this association request was
+ *       received.
+ * @addr: The address of the device requesting association.
+ * @cap: The capability information field from the device.
+ *
+ * This informs a userland coordinator of a device requesting to
+ * associate with the PAN controlled by the coordinator.
+ *
+ * Note: This is in section 7.3.1 of the IEEE 802.15.4-2006 document.
+ */
 int ieee802154_nl_assoc_indic(struct net_device *dev,
 		struct ieee802154_addr *addr, u8 cap);
+
+/**
+ * ieee802154_nl_assoc_confirm - Notify userland of association.
+ * @dev: The device which has completed association.
+ * @short_addr: The short address assigned to the device.
+ * @status: The status of the association.
+ *
+ * Inform userland of the result of an association request. If the
+ * association request included asking the coordinator to allocate
+ * a short address then it is returned in @short_addr.
+ *
+ * Note: This is in section 7.3.2 of the IEEE 802.15.4 document.
+ */
 int ieee802154_nl_assoc_confirm(struct net_device *dev,
 		u16 short_addr, u8 status);
+
+/**
+ * ieee802154_nl_disassoc_indic - Notify userland of disassociation.
+ * @dev: The device on which disassociation was indicated.
+ * @addr: The device which is disassociating.
+ * @reason: The reason for the disassociation.
+ *
+ * Inform userland that a device has disassociated from the network.
+ *
+ * Note: This is in section 7.3.3 of the IEEE 802.15.4 document.
+ */
 int ieee802154_nl_disassoc_indic(struct net_device *dev,
 		struct ieee802154_addr *addr, u8 reason);
+
+/**
+ * ieee802154_nl_disassoc_confirm - Notify userland of disassociation
+ * completion.
+ * @dev: The device on which disassociation was ordered.
+ * @status: The result of the disassociation.
+ *
+ * Inform userland of the result of requesting that a device
+ * disassociate, or the result of requesting that we disassociate from
+ * a PAN managed by another coordinator.
+ *
+ * Note: This is in section 7.1.4.3 of the IEEE 802.15.4 document.
+ */
 int ieee802154_nl_disassoc_confirm(struct net_device *dev,
 		u8 status);
+
+/**
+ * ieee802154_nl_scan_confirm - Notify userland of completion of scan.
+ * @dev: The device which was instructed to scan.
+ * @status: The status of the scan operation.
+ * @scan_type: What type of scan was performed.
+ * @unscanned: Any channels that the device was unable to scan.
+ * @edl: The energy levels (if a passive scan).
+ *
+ *
+ * Note: This is in section 7.1.11 of the IEEE 802.15.4 document.
+ * Note: This API does not permit the return of an active scan result.
+ */
 int ieee802154_nl_scan_confirm(struct net_device *dev,
 		u8 status, u8 scan_type, u32 unscanned,
 		u8 *edl/*, struct list_head *pan_desc_list */);
+
+/**
+ * ieee802154_nl_beacon_indic - Notify userland of a received beacon.
+ * @dev: The device on which a beacon was received.
+ * @panid: The PAN of the coordinator.
+ * @coord_addr: The short address of the coordinator on that PAN.
+ *
+ * Note: This is in section 7.1.5 of the IEEE 802.15.4 document.
+ * Note: This API does not provide extended information such as what
+ * channel the PAN is on or what the LQI of the beacon frame was on
+ * receipt.
+ * Note: This API cannot indicate a beacon frame for a coordinator
+ *       operating in long addressing mode.
+ */
 int ieee802154_nl_beacon_indic(struct net_device *dev, u16 panid,
 		u16 coord_addr);
 
-- 
1.5.4.3

