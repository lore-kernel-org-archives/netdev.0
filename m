From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 4/6] ethtool: Fill out and update comment for
 struct ethtool_ops
Date: Sun, 03 Apr 2011 20:52:31 +0100
Message-ID: <1301860351.2935.27.camel@localhost>
References: <1301859889.2935.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9945 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab1DCTwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 15:52:34 -0400
In-Reply-To: <1301859889.2935.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Briefly document all operations (except get_rx_ntuple), including
whether they may return an error code and whether they are deprecated.
Also mention some things that should be handled by the ethtool core
rather than by drivers.

Briefly document general requirements for callers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |  121 +++++++++++++++++++++++++++++++++++------------
 1 files changed, 90 insertions(+), 31 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index ab12f84..6da626e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -683,22 +683,28 @@ void ethtool_ntuple_flush(struct net_device *dev);
 bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
 
 /**
- * struct ethtool_ops - Alter and report network device settings
- * @get_settings: Get device-specific settings.
- *	@get_settings is passed an &ethtool_cmd to fill in.  It returns
- *	an negative errno or zero.
- * @set_settings: Set device-specific settings.
- *	@set_settings is passed an &ethtool_cmd and should attempt to set
- *	all the settings this device supports.  It may return an error value
- *	if something goes wrong (otherwise 0).
- * @get_drvinfo: Report driver information
+ * struct ethtool_ops - optional netdev operations
+ * @get_settings: Get various device settings including Ethernet link
+ *	settings.  Returns a negative error code or zero.
+ * @set_settings: Set various device settings including Ethernet link
+ *	settings.  Returns a negative error code or zero.
+ * @get_drvinfo: Report driver/device information.  Should only set the
+ *	@driver, @version, @fw_version and @bus_info fields.  If not
+ *	implemented, the @driver and @bus_info fields will be filled in
+ *	according to the netdev's parent device.
+ * @get_regs_len: Get buffer length required for @get_regs
  * @get_regs: Get device registers
  * @get_wol: Report whether Wake-on-Lan is enabled
- * @set_wol: Turn Wake-on-Lan on or off
- * @get_msglevel: Report driver message level
+ * @set_wol: Turn Wake-on-Lan on or off.  Returns a negative error code
+ *	or zero.
+ * @get_msglevel: Report driver message level.  This should be the value
+ *	of the @msg_enable field used by netif logging functions.
  * @set_msglevel: Set driver message level
- * @nway_reset: Restart autonegotiation
- * @get_link: Get link status
+ * @nway_reset: Restart autonegotiation.  Returns a negative error code
+ *	or zero.
+ * @get_link: Report whether physical link is up.  Will only be called if
+ *	the netdev is up.  Should usually be set to ethtool_op_get_link(),
+ *	which uses netif_carrier_ok().
  * @get_eeprom: Read data from the device EEPROM.
  *	Should fill in the magic field.  Don't need to check len for zero
  *	or wraparound.  Fill in the data argument with the eeprom values
@@ -708,28 +714,81 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
  *	Should validate the magic field.  Don't need to check len for zero
  *	or wraparound.  Update len to the amount written.  Returns an error
  *	or zero.
- * @get_coalesce: Get interrupt coalescing parameters
- * @set_coalesce: Set interrupt coalescing parameters
+ * @get_coalesce: Get interrupt coalescing parameters.  Returns a negative
+ *	error code or zero.
+ * @set_coalesce: Set interrupt coalescing parameters.  Returns a negative
+ *	error code or zero.
  * @get_ringparam: Report ring sizes
- * @set_ringparam: Set ring sizes
+ * @set_ringparam: Set ring sizes.  Returns a negative error code or zero.
  * @get_pauseparam: Report pause parameters
- * @set_pauseparam: Set pause parameters
- * @get_rx_csum: Report whether receive checksums are turned on or off
- * @set_rx_csum: Turn receive checksum on or off
- * @get_tx_csum: Report whether transmit checksums are turned on or off
- * @set_tx_csum: Turn transmit checksums on or off
- * @get_sg: Report whether scatter-gather is enabled
- * @set_sg: Turn scatter-gather on or off
- * @get_tso: Report whether TCP segmentation offload is enabled
- * @set_tso: Turn TCP segmentation offload on or off
- * @get_ufo: Report whether UDP fragmentation offload is enabled
- * @set_ufo: Turn UDP fragmentation offload on or off
+ * @set_pauseparam: Set pause parameters.  Returns a negative error code
+ *	or zero.
+ * @get_rx_csum: Deprecated in favour of the netdev feature %NETIF_F_RXCSUM.
+ *	Report whether receive checksums are turned on or off.
+ * @set_rx_csum: Deprecated in favour of the netdev op ndo_set_flags.  Turn
+ *	receive checksum on or off.  Returns a negative error code or zero.
+ * @get_tx_csum: Deprecated as redundant. Report whether transmit checksums
+ *	are turned on or off.
+ * @set_tx_csum: Deprecated in favour of the netdev op ndo_set_flags.  Turn
+ *	transmit checksums on or off.  Returns a egative error code or zero.
+ * @get_sg: Deprecated as redundant.  Report whether scatter-gather is
+ *	enabled.  
+ * @set_sg: Deprecated in favour of the netdev op ndo_set_flags.  Turn
+ *	scatter-gather on or off. Returns a negative error code or zero.
+ * @get_tso: Deprecated as redundant.  Report whether TCP segmentation
+ *	offload is enabled.
+ * @set_tso: Deprecated in favour of the netdev op ndo_set_flags.  Turn TCP
+ *	segmentation offload on or off.  Returns a negative error code or zero.
  * @self_test: Run specified self-tests
  * @get_strings: Return a set of strings that describe the requested objects
- * @phys_id: Identify the device
- * @get_stats: Return statistics about the device
- * @get_flags: get 32-bit flags bitmap
- * @set_flags: set 32-bit flags bitmap
+ * @phys_id: Identify the physical device, e.g. by flashing an LED
+ *	attached to it until interrupted by a signal or the given time
+ *	(in seconds) elapses.  If the given time is zero, use a default
+ *	time limit.  Returns a negative error code or zero.  Being
+ *	interrupted by a signal is not an error.
+ * @get_ethtool_stats: Return extended statistics about the device.
+ *	This is only useful if the device maintains statistics not
+ *	included in &struct rtnl_link_stats64.
+ * @begin: Function to be called before any other operation.  Returns a
+ *	negative error code or zero.
+ * @complete: Function to be called after any other operation except
+ *	@begin.  Will be called even if the other operation failed.
+ * @get_ufo: Deprecated as redundant.  Report whether UDP fragmentation
+ *	offload is enabled.
+ * @set_ufo: Deprecated in favour of the netdev op ndo_set_flags.  Turn UDP
+ *	fragmentation offload on or off.  Returns a negative error code or zero.
+ * @get_flags: Deprecated as redundant.  Report features included in
+ *	&enum ethtool_flags that are enabled.  
+ * @set_flags: Deprecated in favour of the netdev op ndo_set_flags.  Turn
+ *	features included in &enum ethtool_flags on or off.  Returns a
+ *	negative error code or zero.
+ * @get_priv_flags: Report driver-specific feature flags.
+ * @set_priv_flags: Set driver-specific feature flags.  Returns a negative
+ *	error code or zero.
+ * @get_sset_count: Get number of strings that @get_strings will write.
+ * @get_rxnfc: Get RX flow classification rules.  Returns a negative
+ *	error code or zero.
+ * @set_rxnfc: Set RX flow classification rules.  Returns a negative
+ *	error code or zero.
+ * @flash_device: Write a firmware image to device's flash memory.
+ *	Returns a negative error code or zero.
+ * @reset: Reset (part of) the device, as specified by a bitmask of
+ *	flags from &enum ethtool_reset_flags.  Returns a negative
+ *	error code or zero.
+ * @set_rx_ntuple: Set an RX n-tuple rule.  Returns a negative error code
+ *	or zero.
+ * @get_rx_ntuple: Deprecated.
+ * @get_rxfh_indir: Get the contents of the RX flow hash indirection table.
+ *	Returns a negative error code or zero.
+ * @set_rxfh_indir: Set the contents of the RX flow hash indirection table.
+ *	Returns a negative error code or zero.
+ *
+ * All operations are optional (i.e. the function pointer may be set
+ * to %NULL) and callers must take this into account.  Callers must
+ * hold the RTNL, except that for @get_drvinfo the caller may or may
+ * not hold the RTNL.
+ *
+ * See the structures used by these operations for further documentation.
  */
 struct ethtool_ops {
 	int	(*get_settings)(struct net_device *, struct ethtool_cmd *);
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

