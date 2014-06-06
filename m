From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v6 ethtool 1/2] ethtool: Support for configurable RSS hash key
Date: Fri, 6 Jun 2014 21:21:27 +0530
Message-ID: <904d1ad2-ba4b-42da-919e-6964487dea64@CMEXHTCAS2.ad.emulex.com>
References: <1402069888-13302-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:41373 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632AbaFFPxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 11:53:06 -0400
In-Reply-To: <1402069888-13302-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch adds new structure ethtool_rxfh definition for ETHTOOL_GRSSH
and ETHTOOL_SRSSH commands.

Kernel tree: net-next

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 ethtool-copy.h |  478 ++++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 363 insertions(+), 115 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index b5515c2..61b78fc 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -16,37 +16,97 @@
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
-/* This should work for both 32 and 64 bit userland. */
+/* All structures exposed to userland should be defined such that they
+ * have the same layout for 32-bit and 64-bit userland.
+ */
+
+/**
+ * struct ethtool_cmd - link control and status
+ * @cmd: Command number = %ETHTOOL_GSET or %ETHTOOL_SSET
+ * @supported: Bitmask of %SUPPORTED_* flags for the link modes,
+ *	physical connectors and other link features for which the
+ *	interface supports autonegotiation or auto-detection.
+ *	Read-only.
+ * @advertising: Bitmask of %ADVERTISED_* flags for the link modes,
+ *	physical connectors and other link features that are
+ *	advertised through autonegotiation or enabled for
+ *	auto-detection.
+ * @speed: Low bits of the speed
+ * @duplex: Duplex mode; one of %DUPLEX_*
+ * @port: Physical connector type; one of %PORT_*
+ * @phy_address: MDIO address of PHY (transceiver); 0 or 255 if not
+ *	applicable.  For clause 45 PHYs this is the PRTAD.
+ * @transceiver: Historically used to distinguish different possible
+ *	PHY types, but not in a consistent way.  Deprecated.
+ * @autoneg: Enable/disable autonegotiation and auto-detection;
+ *	either %AUTONEG_DISABLE or %AUTONEG_ENABLE
+ * @mdio_support: Bitmask of %ETH_MDIO_SUPPORTS_* flags for the MDIO
+ *	protocols supported by the interface; 0 if unknown.
+ *	Read-only.
+ * @maxtxpkt: Historically used to report TX IRQ coalescing; now
+ *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
+ * @maxrxpkt: Historically used to report RX IRQ coalescing; now
+ *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
+ * @speed_hi: High bits of the speed
+ * @eth_tp_mdix: Ethernet twisted-pair MDI(-X) status; one of
+ *	%ETH_TP_MDI_*.  If the status is unknown or not applicable, the
+ *	value will be %ETH_TP_MDI_INVALID.  Read-only.
+ * @eth_tp_mdix_ctrl: Ethernet twisted pair MDI(-X) control; one of
+ *	%ETH_TP_MDI_*.  If MDI(-X) control is not implemented, reads
+ *	yield %ETH_TP_MDI_INVALID and writes may be ignored or rejected.
+ *	When written successfully, the link should be renegotiated if
+ *	necessary.
+ * @lp_advertising: Bitmask of %ADVERTISED_* flags for the link modes
+ *	and other link features that the link partner advertised
+ *	through autonegotiation; 0 if unknown or not applicable.
+ *	Read-only.
+ *
+ * The link speed in Mbps is split between @speed and @speed_hi.  Use
+ * the ethtool_cmd_speed() and ethtool_cmd_speed_set() functions to
+ * access it.
+ *
+ * If autonegotiation is disabled, the speed and @duplex represent the
+ * fixed link mode and are writable if the driver supports multiple
+ * link modes.  If it is enabled then they are read-only; if the link
+ * is up they represent the negotiated link mode; if the link is down,
+ * the speed is 0, %SPEED_UNKNOWN or the highest enabled speed and
+ * @duplex is %DUPLEX_UNKNOWN or the best enabled duplex mode.
+ *
+ * Some hardware interfaces may have multiple PHYs and/or physical
+ * connectors fitted or do not allow the driver to detect which are
+ * fitted.  For these interfaces @port and/or @phy_address may be
+ * writable, possibly dependent on @autoneg being %AUTONEG_DISABLE.
+ * Otherwise, attempts to write different values may be ignored or
+ * rejected.
+ *
+ * Users should assume that all fields not marked read-only are
+ * writable and subject to validation by the driver.  They should use
+ * %ETHTOOL_GSET to get the current values before making specific
+ * changes and then applying them with %ETHTOOL_SSET.
+ *
+ * Drivers that implement set_settings() should validate all fields
+ * other than @cmd that are not described as read-only or deprecated,
+ * and must ignore all fields described as read-only.
+ *
+ * Deprecated fields should be ignored by both users and drivers.
+ */
 struct ethtool_cmd {
 	__u32	cmd;
-	__u32	supported;	/* Features this interface supports */
-	__u32	advertising;	/* Features this interface advertises */
-	__u16	speed;	        /* The forced speed (lower bits) in
-				 * Mbps. Please use
-				 * ethtool_cmd_speed()/_set() to
-				 * access it */
-	__u8	duplex;		/* Duplex, half or full */
-	__u8	port;		/* Which connector port */
-	__u8	phy_address;	/* MDIO PHY address (PRTAD for clause 45).
-				 * May be read-only or read-write
-				 * depending on the driver.
-				 */
-	__u8	transceiver;	/* Which transceiver to use */
-	__u8	autoneg;	/* Enable or disable autonegotiation */
-	__u8	mdio_support;	/* MDIO protocols supported.  Read-only.
-				 * Not set by all drivers.
-				 */
-	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
-	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
-	__u16	speed_hi;       /* The forced speed (upper
-				 * bits) in Mbps. Please use
-				 * ethtool_cmd_speed()/_set() to
-				 * access it */
-	__u8	eth_tp_mdix;	/* twisted pair MDI-X status */
-	__u8    eth_tp_mdix_ctrl; /* twisted pair MDI-X control, when set,
-				   * link should be renegotiated if necessary
-				   */
-	__u32	lp_advertising;	/* Features the link partner advertises */
+	__u32	supported;
+	__u32	advertising;
+	__u16	speed;
+	__u8	duplex;
+	__u8	port;
+	__u8	phy_address;
+	__u8	transceiver;
+	__u8	autoneg;
+	__u8	mdio_support;
+	__u32	maxtxpkt;
+	__u32	maxrxpkt;
+	__u16	speed_hi;
+	__u8	eth_tp_mdix;
+	__u8	eth_tp_mdix_ctrl;
+	__u32	lp_advertising;
 	__u32	reserved[2];
 };
 
@@ -79,37 +139,68 @@ static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 
 #define ETHTOOL_FWVERS_LEN	32
 #define ETHTOOL_BUSINFO_LEN	32
-/* these strings are set to whatever the driver author decides... */
+
+/**
+ * struct ethtool_drvinfo - general driver and device information
+ * @cmd: Command number = %ETHTOOL_GDRVINFO
+ * @driver: Driver short name.  This should normally match the name
+ *	in its bus driver structure (e.g. pci_driver::name).  Must
+ *	not be an empty string.
+ * @version: Driver version string; may be an empty string
+ * @fw_version: Firmware version string; may be an empty string
+ * @bus_info: Device bus address.  This should match the dev_name()
+ *	string for the underlying bus device, if there is one.  May be
+ *	an empty string.
+ * @n_priv_flags: Number of flags valid for %ETHTOOL_GPFLAGS and
+ *	%ETHTOOL_SPFLAGS commands; also the number of strings in the
+ *	%ETH_SS_PRIV_FLAGS set
+ * @n_stats: Number of u64 statistics returned by the %ETHTOOL_GSTATS
+ *	command; also the number of strings in the %ETH_SS_STATS set
+ * @testinfo_len: Number of results returned by the %ETHTOOL_TEST
+ *	command; also the number of strings in the %ETH_SS_TEST set
+ * @eedump_len: Size of EEPROM accessible through the %ETHTOOL_GEEPROM
+ *	and %ETHTOOL_SEEPROM commands, in bytes
+ * @regdump_len: Size of register dump returned by the %ETHTOOL_GREGS
+ *	command, in bytes
+ *
+ * Users can use the %ETHTOOL_GSSET_INFO command to get the number of
+ * strings in any string set (from Linux 2.6.34).
+ *
+ * Drivers should set at most @driver, @version, @fw_version and
+ * @bus_info in their get_drvinfo() implementation.  The ethtool
+ * core fills in the other fields using other driver operations.
+ */
 struct ethtool_drvinfo {
 	__u32	cmd;
-	char	driver[32];	/* driver short name, "tulip", "eepro100" */
-	char	version[32];	/* driver version string */
-	char	fw_version[ETHTOOL_FWVERS_LEN];	/* firmware version string */
-	char	bus_info[ETHTOOL_BUSINFO_LEN];	/* Bus info for this IF. */
-				/* For PCI devices, use pci_name(pci_dev). */
+	char	driver[32];
+	char	version[32];
+	char	fw_version[ETHTOOL_FWVERS_LEN];
+	char	bus_info[ETHTOOL_BUSINFO_LEN];
 	char	reserved1[32];
 	char	reserved2[12];
-				/*
-				 * Some struct members below are filled in
-				 * using ops->get_sset_count().  Obtaining
-				 * this info from ethtool_drvinfo is now
-				 * deprecated; Use ETHTOOL_GSSET_INFO
-				 * instead.
-				 */
-	__u32	n_priv_flags;	/* number of flags valid in ETHTOOL_GPFLAGS */
-	__u32	n_stats;	/* number of u64's from ETHTOOL_GSTATS */
+	__u32	n_priv_flags;
+	__u32	n_stats;
 	__u32	testinfo_len;
-	__u32	eedump_len;	/* Size of data from ETHTOOL_GEEPROM (bytes) */
-	__u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes) */
+	__u32	eedump_len;
+	__u32	regdump_len;
 };
 
 #define SOPASS_MAX	6
-/* wake-on-lan settings */
+
+/**
+ * struct ethtool_wolinfo - Wake-On-Lan configuration
+ * @cmd: Command number = %ETHTOOL_GWOL or %ETHTOOL_SWOL
+ * @supported: Bitmask of %WAKE_* flags for supported Wake-On-Lan modes.
+ *	Read-only.
+ * @wolopts: Bitmask of %WAKE_* flags for enabled Wake-On-Lan modes.
+ * @sopass: SecureOn(tm) password; meaningful only if %WAKE_MAGICSECURE
+ *	is set in @wolopts.
+ */
 struct ethtool_wolinfo {
 	__u32	cmd;
 	__u32	supported;
 	__u32	wolopts;
-	__u8	sopass[SOPASS_MAX]; /* SecureOn(tm) password */
+	__u8	sopass[SOPASS_MAX];
 };
 
 /* for passing single values */
@@ -118,20 +209,51 @@ struct ethtool_value {
 	__u32	data;
 };
 
-/* for passing big chunks of data */
+/**
+ * struct ethtool_regs - hardware register dump
+ * @cmd: Command number = %ETHTOOL_GREGS
+ * @version: Dump format version.  This is driver-specific and may
+ *	distinguish different chips/revisions.  Drivers must use new
+ *	version numbers whenever the dump format changes in an
+ *	incompatible way.
+ * @len: On entry, the real length of @data.  On return, the number of
+ *	bytes used.
+ * @data: Buffer for the register dump
+ *
+ * Users should use %ETHTOOL_GDRVINFO to find the maximum length of
+ * a register dump for the interface.  They must allocate the buffer
+ * immediately following this structure.
+ */
 struct ethtool_regs {
 	__u32	cmd;
-	__u32	version; /* driver-specific, indicates different chips/revs */
-	__u32	len; /* bytes */
+	__u32	version;
+	__u32	len;
 	__u8	data[0];
 };
 
-/* for passing EEPROM chunks */
+/**
+ * struct ethtool_eeprom - EEPROM dump
+ * @cmd: Command number = %ETHTOOL_GEEPROM, %ETHTOOL_GMODULEEEPROM or
+ *	%ETHTOOL_SEEPROM
+ * @magic: A 'magic cookie' value to guard against accidental changes.
+ *	The value passed in to %ETHTOOL_SEEPROM must match the value
+ *	returned by %ETHTOOL_GEEPROM for the same device.  This is
+ *	unused when @cmd is %ETHTOOL_GMODULEEEPROM.
+ * @offset: Offset within the EEPROM to begin reading/writing, in bytes
+ * @len: On entry, number of bytes to read/write.  On successful
+ *	return, number of bytes actually read/written.  In case of
+ *	error, this may indicate at what point the error occurred.
+ * @data: Buffer to read/write from
+ *
+ * Users may use %ETHTOOL_GDRVINFO or %ETHTOOL_GMODULEINFO to find
+ * the length of an on-board or module EEPROM, respectively.  They
+ * must allocate the buffer immediately following this structure.
+ */
 struct ethtool_eeprom {
 	__u32	cmd;
 	__u32	magic;
-	__u32	offset; /* in bytes */
-	__u32	len; /* in bytes */
+	__u32	offset;
+	__u32	len;
 	__u8	data[0];
 };
 
@@ -229,17 +351,18 @@ struct ethtool_modinfo {
  * @rate_sample_interval: How often to do adaptive coalescing packet rate
  *	sampling, measured in seconds.  Must not be zero.
  *
- * Each pair of (usecs, max_frames) fields specifies this exit
- * condition for interrupt coalescing:
+ * Each pair of (usecs, max_frames) fields specifies that interrupts
+ * should be coalesced until
  *	(usecs > 0 && time_since_first_completion >= usecs) ||
  *	(max_frames > 0 && completed_frames >= max_frames)
+ *
  * It is illegal to set both usecs and max_frames to zero as this
  * would cause interrupts to never be generated.  To disable
  * coalescing, set usecs = 0 and max_frames = 1.
  *
  * Some implementations ignore the value of max_frames and use the
- * condition:
- *	time_since_first_completion >= usecs
+ * condition time_since_first_completion >= usecs
+ *
  * This is deprecated.  Drivers for hardware that does not support
  * counting completions should validate that max_frames == !rx_usecs.
  *
@@ -279,22 +402,37 @@ struct ethtool_coalesce {
 	__u32	rate_sample_interval;
 };
 
-/* for configuring RX/TX ring parameters */
+/**
+ * struct ethtool_ringparam - RX/TX ring parameters
+ * @cmd: Command number = %ETHTOOL_GRINGPARAM or %ETHTOOL_SRINGPARAM
+ * @rx_max_pending: Maximum supported number of pending entries per
+ *	RX ring.  Read-only.
+ * @rx_mini_max_pending: Maximum supported number of pending entries
+ *	per RX mini ring.  Read-only.
+ * @rx_jumbo_max_pending: Maximum supported number of pending entries
+ *	per RX jumbo ring.  Read-only.
+ * @tx_max_pending: Maximum supported number of pending entries per
+ *	TX ring.  Read-only.
+ * @rx_pending: Current maximum number of pending entries per RX ring
+ * @rx_mini_pending: Current maximum number of pending entries per RX
+ *	mini ring
+ * @rx_jumbo_pending: Current maximum number of pending entries per RX
+ *	jumbo ring
+ * @tx_pending: Current maximum supported number of pending entries
+ *	per TX ring
+ *
+ * If the interface does not have separate RX mini and/or jumbo rings,
+ * @rx_mini_max_pending and/or @rx_jumbo_max_pending will be 0.
+ *
+ * There may also be driver-dependent minimum values for the number
+ * of entries per ring.
+ */
 struct ethtool_ringparam {
-	__u32	cmd;	/* ETHTOOL_{G,S}RINGPARAM */
-
-	/* Read only attributes.  These indicate the maximum number
-	 * of pending RX/TX ring entries the driver will allow the
-	 * user to set.
-	 */
+	__u32	cmd;
 	__u32	rx_max_pending;
 	__u32	rx_mini_max_pending;
 	__u32	rx_jumbo_max_pending;
 	__u32	tx_max_pending;
-
-	/* Values changeable by the user.  The valid values are
-	 * in the range 1 to the "*_max_pending" counterpart above.
-	 */
 	__u32	rx_pending;
 	__u32	rx_mini_pending;
 	__u32	rx_jumbo_pending;
@@ -329,51 +467,96 @@ struct ethtool_channels {
 	__u32	combined_count;
 };
 
-/* for configuring link flow control parameters */
+/**
+ * struct ethtool_pauseparam - Ethernet pause (flow control) parameters
+ * @cmd: Command number = %ETHTOOL_GPAUSEPARAM or %ETHTOOL_SPAUSEPARAM
+ * @autoneg: Flag to enable autonegotiation of pause frame use
+ * @rx_pause: Flag to enable reception of pause frames
+ * @tx_pause: Flag to enable transmission of pause frames
+ *
+ * Drivers should reject a non-zero setting of @autoneg when
+ * autoneogotiation is disabled (or not supported) for the link.
+ *
+ * If the link is autonegotiated, drivers should use
+ * mii_advertise_flowctrl() or similar code to set the advertised
+ * pause frame capabilities based on the @rx_pause and @tx_pause flags,
+ * even if @autoneg is zero.  They should also allow the advertised
+ * pause frame capabilities to be controlled directly through the
+ * advertising field of &struct ethtool_cmd.
+ *
+ * If @autoneg is non-zero, the MAC is configured to send and/or
+ * receive pause frames according to the result of autonegotiation.
+ * Otherwise, it is configured directly based on the @rx_pause and
+ * @tx_pause flags.
+ */
 struct ethtool_pauseparam {
-	__u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
-
-	/* If the link is being auto-negotiated (via ethtool_cmd.autoneg
-	 * being true) the user may set 'autoneg' here non-zero to have the
-	 * pause parameters be auto-negotiated too.  In such a case, the
-	 * {rx,tx}_pause values below determine what capabilities are
-	 * advertised.
-	 *
-	 * If 'autoneg' is zero or the link is not being auto-negotiated,
-	 * then {rx,tx}_pause force the driver to use/not-use pause
-	 * flow control.
-	 */
+	__u32	cmd;
 	__u32	autoneg;
 	__u32	rx_pause;
 	__u32	tx_pause;
 };
 
 #define ETH_GSTRING_LEN		32
+
+/**
+ * enum ethtool_stringset - string set ID
+ * @ETH_SS_TEST: Self-test result names, for use with %ETHTOOL_TEST
+ * @ETH_SS_STATS: Statistic names, for use with %ETHTOOL_GSTATS
+ * @ETH_SS_PRIV_FLAGS: Driver private flag names, for use with
+ *	%ETHTOOL_GPFLAGS and %ETHTOOL_SPFLAGS
+ * @ETH_SS_NTUPLE_FILTERS: Previously used with %ETHTOOL_GRXNTUPLE;
+ *	now deprecated
+ * @ETH_SS_FEATURES: Device feature names
+ */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
-	ETH_SS_NTUPLE_FILTERS,	/* Do not use, GRXNTUPLE is now deprecated */
+	ETH_SS_NTUPLE_FILTERS,
 	ETH_SS_FEATURES,
 };
 
-/* for passing string sets for data tagging */
+/**
+ * struct ethtool_gstrings - string set for data tagging
+ * @cmd: Command number = %ETHTOOL_GSTRINGS
+ * @string_set: String set ID; one of &enum ethtool_stringset
+ * @len: On return, the number of strings in the string set
+ * @data: Buffer for strings.  Each string is null-padded to a size of
+ *	%ETH_GSTRING_LEN.
+ *
+ * Users must use %ETHTOOL_GSSET_INFO to find the number of strings in
+ * the string set.  They must allocate a buffer of the appropriate
+ * size immediately following this structure.
+ */
 struct ethtool_gstrings {
-	__u32	cmd;		/* ETHTOOL_GSTRINGS */
-	__u32	string_set;	/* string set id e.c. ETH_SS_TEST, etc*/
-	__u32	len;		/* number of strings in the string set */
+	__u32	cmd;
+	__u32	string_set;
+	__u32	len;
 	__u8	data[0];
 };
 
+/**
+ * struct ethtool_sset_info - string set information
+ * @cmd: Command number = %ETHTOOL_GSSET_INFO
+ * @sset_mask: On entry, a bitmask of string sets to query, with bits
+ *	numbered according to &enum ethtool_stringset.  On return, a
+ *	bitmask of those string sets queried that are supported.
+ * @data: Buffer for string set sizes.  On return, this contains the
+ *	size of each string set that was queried and supported, in
+ *	order of ID.
+ *
+ * Example: The user passes in @sset_mask = 0x7 (sets 0, 1, 2) and on
+ * return @sset_mask == 0x6 (sets 1, 2).  Then @data[0] contains the
+ * size of set 1 and @data[1] contains the size of set 2.
+ *
+ * Users must allocate a buffer of the appropriate size (4 * number of
+ * sets queried) immediately following this structure.
+ */
 struct ethtool_sset_info {
-	__u32	cmd;		/* ETHTOOL_GSSET_INFO */
+	__u32	cmd;
 	__u32	reserved;
-	__u64	sset_mask;	/* input: each bit selects an sset to query */
-				/* output: each bit a returned sset */
-	__u32	data[0];	/* ETH_SS_xxx count, in order, based on bits
-				   in sset_mask.  One bit implies one
-				   __u32, two bits implies two
-				   __u32's, etc. */
+	__u64	sset_mask;
+	__u32	data[0];
 };
 
 /**
@@ -393,24 +576,58 @@ enum ethtool_test_flags {
 	ETH_TEST_FL_EXTERNAL_LB_DONE	= (1 << 3),
 };
 
-/* for requesting NIC test and getting results*/
+/**
+ * struct ethtool_test - device self-test invocation
+ * @cmd: Command number = %ETHTOOL_TEST
+ * @flags: A bitmask of flags from &enum ethtool_test_flags.  Some
+ *	flags may be set by the user on entry; others may be set by
+ *	the driver on return.
+ * @len: On return, the number of test results
+ * @data: Array of test results
+ *
+ * Users must use %ETHTOOL_GSSET_INFO or %ETHTOOL_GDRVINFO to find the
+ * number of test results that will be returned.  They must allocate a
+ * buffer of the appropriate size (8 * number of results) immediately
+ * following this structure.
+ */
 struct ethtool_test {
-	__u32	cmd;		/* ETHTOOL_TEST */
-	__u32	flags;		/* ETH_TEST_FL_xxx */
+	__u32	cmd;
+	__u32	flags;
 	__u32	reserved;
-	__u32	len;		/* result length, in number of u64 elements */
+	__u32	len;
 	__u64	data[0];
 };
 
-/* for dumping NIC-specific statistics */
+/**
+ * struct ethtool_stats - device-specific statistics
+ * @cmd: Command number = %ETHTOOL_GSTATS
+ * @n_stats: On return, the number of statistics
+ * @data: Array of statistics
+ *
+ * Users must use %ETHTOOL_GSSET_INFO or %ETHTOOL_GDRVINFO to find the
+ * number of statistics that will be returned.  They must allocate a
+ * buffer of the appropriate size (8 * number of statistics)
+ * immediately following this structure.
+ */
 struct ethtool_stats {
-	__u32	cmd;		/* ETHTOOL_GSTATS */
-	__u32	n_stats;	/* number of u64's being returned */
+	__u32	cmd;
+	__u32	n_stats;
 	__u64	data[0];
 };
 
+/**
+ * struct ethtool_perm_addr - permanent hardware address
+ * @cmd: Command number = %ETHTOOL_GPERMADDR
+ * @size: On entry, the size of the buffer.  On return, the size of the
+ *	address.  The command fails if the buffer is too small.
+ * @data: Buffer for the address
+ *
+ * Users must allocate the buffer immediately following this structure.
+ * A buffer size of %MAX_ADDR_LEN should be sufficient for any address
+ * type.
+ */
 struct ethtool_perm_addr {
-	__u32	cmd;		/* ETHTOOL_GPERMADDR */
+	__u32	cmd;
 	__u32	size;
 	__u8	data[0];
 };
@@ -593,7 +810,7 @@ struct ethtool_rx_flow_spec {
  * %ETHTOOL_SRXCLSRLINS may add the rule at any suitable unused
  * location, and may remove a rule at a later location (lower
  * priority) that matches exactly the same set of flows.  The special
- * values are: %RX_CLS_LOC_ANY, selecting any location;
+ * values are %RX_CLS_LOC_ANY, selecting any location;
  * %RX_CLS_LOC_FIRST, selecting the first suitable location (maximum
  * priority); and %RX_CLS_LOC_LAST, selecting the last suitable
  * location (minimum priority).  Additional special values may be
@@ -630,6 +847,38 @@ struct ethtool_rxfh_indir {
 };
 
 /**
+ * struct ethtool_rxfh - command to get/set RX flow hash indir or/and hash key.
+ * @cmd: Specific command number - %ETHTOOL_GRSSH or %ETHTOOL_SRSSH
+ * @rss_context: RSS context identifier.
+ * @indir_size: On entry, the array size of the user buffer for the
+ *	indirection table, which may be zero, or (for %ETHTOOL_SRSSH),
+ *	%ETH_RXFH_INDIR_NO_CHANGE.  On return from %ETHTOOL_GRSSH,
+ *	the array size of the hardware indirection table.
+ * @key_size: On entry, the array size of the user buffer for the hash key,
+ *	which may be zero.  On return from %ETHTOOL_GRSSH, the size of the
+ *	hardware hash key.
+ * @rsvd:	Reserved for future extensions.
+ * @rss_config: RX ring/queue index for each hash value i.e., indirection table
+ *	of @indir_size __u32 elements, followed by hash key of @key_size
+ *	bytes.
+ *
+ * For %ETHTOOL_GRSSH, a @indir_size and key_size of zero means that only the
+ * size should be returned.  For %ETHTOOL_SRSSH, an @indir_size of
+ * %ETH_RXFH_INDIR_NO_CHANGE means that indir table setting is not requested
+ * and a @indir_size of zero means the indir table should be reset to default
+ * values.
+ */
+struct ethtool_rxfh {
+	__u32   cmd;
+	__u32	rss_context;
+	__u32   indir_size;
+	__u32   key_size;
+	__u32	rsvd[2];
+	__u32   rss_config[0];
+};
+#define ETH_RXFH_INDIR_NO_CHANGE	0xffffffff
+
+/**
  * struct ethtool_rx_ntuple_flow_spec - specification for RX flow filter
  * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
  * @h_u: Flow field values to match (dependent on @flow_type)
@@ -704,9 +953,6 @@ struct ethtool_flash {
  * 	 for %ETHTOOL_GET_DUMP_FLAG command
  * @data: data collected for get dump data operation
  */
-
-#define ETH_FW_DUMP_DISABLE 0
-
 struct ethtool_dump {
 	__u32	cmd;
 	__u32	version;
@@ -715,6 +961,8 @@ struct ethtool_dump {
 	__u8	data[0];
 };
 
+#define ETH_FW_DUMP_DISABLE 0
+
 /* for returning and changing feature sets */
 
 /**
@@ -734,8 +982,9 @@ struct ethtool_get_features_block {
 /**
  * struct ethtool_gfeatures - command to get state of device's features
  * @cmd: command number = %ETHTOOL_GFEATURES
- * @size: in: number of elements in the features[] array;
- *       out: number of elements in features[] needed to hold all features
+ * @size: On entry, the number of elements in the features[] array;
+ *	on return, the number of elements in features[] needed to hold
+ *	all features
  * @features: state of features
  */
 struct ethtool_gfeatures {
@@ -901,11 +1150,13 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
 #define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
 
+#define ETHTOOL_GRSSH		0x00000046 /* Get RX flow hash configuration */
+#define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
 
-/* Indicates what features are supported by the interface. */
 #define SUPPORTED_10baseT_Half		(1 << 0)
 #define SUPPORTED_10baseT_Full		(1 << 1)
 #define SUPPORTED_100baseT_Half		(1 << 2)
@@ -934,7 +1185,6 @@ enum ethtool_sfeatures_retval_bits {
 #define SUPPORTED_40000baseSR4_Full	(1 << 25)
 #define SUPPORTED_40000baseLR4_Full	(1 << 26)
 
-/* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
 #define ADVERTISED_10baseT_Full		(1 << 1)
 #define ADVERTISED_100baseT_Half	(1 << 2)
@@ -993,15 +1243,13 @@ enum ethtool_sfeatures_retval_bits {
 #define PORT_OTHER		0xff
 
 /* Which transceiver to use. */
-#define XCVR_INTERNAL		0x00
-#define XCVR_EXTERNAL		0x01
+#define XCVR_INTERNAL		0x00 /* PHY and MAC are in the same package */
+#define XCVR_EXTERNAL		0x01 /* PHY and MAC are in different packages */
 #define XCVR_DUMMY1		0x02
 #define XCVR_DUMMY2		0x03
 #define XCVR_DUMMY3		0x04
 
-/* Enable or disable autonegotiation.  If this is set to enable,
- * the forced link modes above are completely ignored.
- */
+/* Enable or disable autonegotiation. */
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
-- 
1.7.1
