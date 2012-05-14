From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH ethtool] Add command to dump module EEPROM
Date: Mon, 14 May 2012 18:13:51 +0300
Message-ID: <1337008431-6304-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3146 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754499Ab2ENMPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 08:15:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,
This patch adds a new option to dump (SFP+, XFP, ...) module EEPROM following
recent support to kernel side. Below some examples:

bash-3.00# ethtool -m eth1 offset 0x14 length 32 raw on
JDSU            PLRXPLSCS432

bash-3.00# ethtool -m eth1 offset 0x14 length 32
Offset          Values
------          ------
0x0014          4a 44 53 55 20 20 20 20 20 20 20 20 20 20 20 20
0x0024          00 00 01 9c 50 4c 52 58 50 4c 53 43 53 34 33 32

Please consider applying to ethtool.
Thanks,
Yaniv

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
---
 ethtool-copy.h |  312 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 ethtool.8.in   |   23 ++++-
 ethtool.c      |   63 +++++++++++
 3 files changed, 393 insertions(+), 5 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d904c1a..604dbef 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -13,6 +13,9 @@
 #ifndef _LINUX_ETHTOOL_H
 #define _LINUX_ETHTOOL_H
 
+#ifdef __KERNEL__
+#include <linux/compat.h>
+#endif
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
@@ -27,10 +30,15 @@ struct ethtool_cmd {
 				 * access it */
 	__u8	duplex;		/* Duplex, half or full */
 	__u8	port;		/* Which connector port */
-	__u8	phy_address;
+	__u8	phy_address;	/* MDIO PHY address (PRTAD for clause 45).
+				 * May be read-only or read-write
+				 * depending on the driver.
+				 */
 	__u8	transceiver;	/* Which transceiver to use */
 	__u8	autoneg;	/* Enable or disable autonegotiation */
-	__u8	mdio_support;
+	__u8	mdio_support;	/* MDIO protocols supported.  Read-only.
+				 * Not set by all drivers.
+				 */
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;       /* The forced speed (upper
@@ -43,7 +51,7 @@ struct ethtool_cmd {
 	__u32	reserved[2];
 };
 
-static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
+static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 					 __u32 speed)
 {
 
@@ -51,11 +59,25 @@ static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
+static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 {
 	return (ep->speed_hi << 16) | ep->speed;
 }
 
+/* Device supports clause 22 register access to PHY or peripherals
+ * using the interface defined in <linux/mii.h>.  This should not be
+ * set if there are known to be no such peripherals present or if
+ * the driver only emulates clause 22 registers for compatibility.
+ */
+#define ETH_MDIO_SUPPORTS_C22	1
+
+/* Device supports clause 45 register access to PHY or peripherals
+ * using the interface defined in <linux/mii.h> and <linux/mdio.h>.
+ * This should not be set if there are known to be no such peripherals
+ * present.
+ */
+#define ETH_MDIO_SUPPORTS_C45	2
+
 #define ETHTOOL_FWVERS_LEN	32
 #define ETHTOOL_BUSINFO_LEN	32
 /* these strings are set to whatever the driver author decides... */
@@ -115,6 +137,23 @@ struct ethtool_eeprom {
 };
 
 /**
+ * struct ethtool_modinfo - plugin module eeprom information
+ * @cmd: %ETHTOOL_GMODULEINFO
+ * @type: Standard the module information conforms to %ETH_MODULE_SFF_xxxx
+ * @eeprom_len: Length of the eeprom
+ *
+ * This structure is used to return the information to
+ * properly size memory for a subsequent call to %ETHTOOL_GMODULEEEPROM.
+ * The type code indicates the eeprom data format
+ */
+struct ethtool_modinfo {
+	__u32   cmd;
+	__u32   type;
+	__u32   eeprom_len;
+	__u32   reserved[8];
+};
+
+/**
  * struct ethtool_coalesce - coalescing parameters for IRQs and stats updates
  * @cmd: ETHTOOL_{G,S}COALESCE
  * @rx_coalesce_usecs: How many usecs to delay an RX interrupt after
@@ -528,6 +567,30 @@ struct ethtool_rxnfc {
 	__u32				rule_locs[0];
 };
 
+#ifdef __KERNEL__
+#ifdef CONFIG_COMPAT
+
+struct compat_ethtool_rx_flow_spec {
+	u32		flow_type;
+	union ethtool_flow_union h_u;
+	struct ethtool_flow_ext h_ext;
+	union ethtool_flow_union m_u;
+	struct ethtool_flow_ext m_ext;
+	compat_u64	ring_cookie;
+	u32		location;
+};
+
+struct compat_ethtool_rxnfc {
+	u32				cmd;
+	u32				flow_type;
+	compat_u64			data;
+	struct compat_ethtool_rx_flow_spec fs;
+	u32				rule_cnt;
+	u32				rule_locs[0];
+};
+
+#endif /* CONFIG_COMPAT */
+#endif /* __KERNEL__ */
 
 /**
  * struct ethtool_rxfh_indir - command to get or set RX flow hash indirection
@@ -680,6 +743,29 @@ struct ethtool_sfeatures {
 	struct ethtool_set_features_block features[0];
 };
 
+/**
+ * struct ethtool_ts_info - holds a device's timestamping and PHC association
+ * @cmd: command number = %ETHTOOL_GET_TS_INFO
+ * @so_timestamping: bit mask of the sum of the supported SO_TIMESTAMPING flags
+ * @phc_index: device index of the associated PHC, or -1 if there is none
+ * @tx_types: bit mask of the supported hwtstamp_tx_types enumeration values
+ * @rx_filters: bit mask of the supported hwtstamp_rx_filters enumeration values
+ *
+ * The bits in the 'tx_types' and 'rx_filters' fields correspond to
+ * the 'hwtstamp_tx_types' and 'hwtstamp_rx_filters' enumeration values,
+ * respectively.  For example, if the device supports HWTSTAMP_TX_ON,
+ * then (1 << HWTSTAMP_TX_ON) in 'tx_types' will be set.
+ */
+struct ethtool_ts_info {
+	__u32	cmd;
+	__u32	so_timestamping;
+	__s32	phc_index;
+	__u32	tx_types;
+	__u32	tx_reserved[3];
+	__u32	rx_filters;
+	__u32	rx_reserved[3];
+};
+
 /*
  * %ETHTOOL_SFEATURES changes features present in features[].valid to the
  * values of corresponding bits in features[].requested. Bits in .requested
@@ -715,6 +801,215 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
 #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
 
+#ifdef __KERNEL__
+
+#include <linux/rculist.h>
+
+extern int __ethtool_get_settings(struct net_device *dev,
+				  struct ethtool_cmd *cmd);
+
+/**
+ * enum ethtool_phys_id_state - indicator state for physical identification
+ * @ETHTOOL_ID_INACTIVE: Physical ID indicator should be deactivated
+ * @ETHTOOL_ID_ACTIVE: Physical ID indicator should be activated
+ * @ETHTOOL_ID_ON: LED should be turned on (used iff %ETHTOOL_ID_ACTIVE
+ *	is not supported)
+ * @ETHTOOL_ID_OFF: LED should be turned off (used iff %ETHTOOL_ID_ACTIVE
+ *	is not supported)
+ */
+enum ethtool_phys_id_state {
+	ETHTOOL_ID_INACTIVE,
+	ETHTOOL_ID_ACTIVE,
+	ETHTOOL_ID_ON,
+	ETHTOOL_ID_OFF
+};
+
+struct net_device;
+
+/* Some generic methods drivers may use in their ethtool_ops */
+u32 ethtool_op_get_link(struct net_device *dev);
+int ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *eti);
+
+/**
+ * ethtool_rxfh_indir_default - get default value for RX flow hash indirection
+ * @index: Index in RX flow hash indirection table
+ * @n_rx_rings: Number of RX rings to use
+ *
+ * This function provides the default policy for RX flow hash indirection.
+ */
+static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
+{
+	return index % n_rx_rings;
+}
+
+/**
+ * struct ethtool_ops - optional netdev operations
+ * @get_settings: Get various device settings including Ethernet link
+ *	settings. The @cmd parameter is expected to have been cleared
+ *	before get_settings is called. Returns a negative error code or
+ *	zero.
+ * @set_settings: Set various device settings including Ethernet link
+ *	settings.  Returns a negative error code or zero.
+ * @get_drvinfo: Report driver/device information.  Should only set the
+ *	@driver, @version, @fw_version and @bus_info fields.  If not
+ *	implemented, the @driver and @bus_info fields will be filled in
+ *	according to the netdev's parent device.
+ * @get_regs_len: Get buffer length required for @get_regs
+ * @get_regs: Get device registers
+ * @get_wol: Report whether Wake-on-Lan is enabled
+ * @set_wol: Turn Wake-on-Lan on or off.  Returns a negative error code
+ *	or zero.
+ * @get_msglevel: Report driver message level.  This should be the value
+ *	of the @msg_enable field used by netif logging functions.
+ * @set_msglevel: Set driver message level
+ * @nway_reset: Restart autonegotiation.  Returns a negative error code
+ *	or zero.
+ * @get_link: Report whether physical link is up.  Will only be called if
+ *	the netdev is up.  Should usually be set to ethtool_op_get_link(),
+ *	which uses netif_carrier_ok().
+ * @get_eeprom: Read data from the device EEPROM.
+ *	Should fill in the magic field.  Don't need to check len for zero
+ *	or wraparound.  Fill in the data argument with the eeprom values
+ *	from offset to offset + len.  Update len to the amount read.
+ *	Returns an error or zero.
+ * @set_eeprom: Write data to the device EEPROM.
+ *	Should validate the magic field.  Don't need to check len for zero
+ *	or wraparound.  Update len to the amount written.  Returns an error
+ *	or zero.
+ * @get_coalesce: Get interrupt coalescing parameters.  Returns a negative
+ *	error code or zero.
+ * @set_coalesce: Set interrupt coalescing parameters.  Returns a negative
+ *	error code or zero.
+ * @get_ringparam: Report ring sizes
+ * @set_ringparam: Set ring sizes.  Returns a negative error code or zero.
+ * @get_pauseparam: Report pause parameters
+ * @set_pauseparam: Set pause parameters.  Returns a negative error code
+ *	or zero.
+ * @self_test: Run specified self-tests
+ * @get_strings: Return a set of strings that describe the requested objects
+ * @set_phys_id: Identify the physical devices, e.g. by flashing an LED
+ *	attached to it.  The implementation may update the indicator
+ *	asynchronously or synchronously, but in either case it must return
+ *	quickly.  It is initially called with the argument %ETHTOOL_ID_ACTIVE,
+ *	and must either activate asynchronous updates and return zero, return
+ *	a negative error or return a positive frequency for synchronous
+ *	indication (e.g. 1 for one on/off cycle per second).  If it returns
+ *	a frequency then it will be called again at intervals with the
+ *	argument %ETHTOOL_ID_ON or %ETHTOOL_ID_OFF and should set the state of
+ *	the indicator accordingly.  Finally, it is called with the argument
+ *	%ETHTOOL_ID_INACTIVE and must deactivate the indicator.  Returns a
+ *	negative error code or zero.
+ * @get_ethtool_stats: Return extended statistics about the device.
+ *	This is only useful if the device maintains statistics not
+ *	included in &struct rtnl_link_stats64.
+ * @begin: Function to be called before any other operation.  Returns a
+ *	negative error code or zero.
+ * @complete: Function to be called after any other operation except
+ *	@begin.  Will be called even if the other operation failed.
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
+ * @get_rxfh_indir_size: Get the size of the RX flow hash indirection table.
+ *	Returns zero if not supported for this specific device.
+ * @get_rxfh_indir: Get the contents of the RX flow hash indirection table.
+ *	Will not be called if @get_rxfh_indir_size returns zero.
+ *	Returns a negative error code or zero.
+ * @set_rxfh_indir: Set the contents of the RX flow hash indirection table.
+ *	Will not be called if @get_rxfh_indir_size returns zero.
+ *	Returns a negative error code or zero.
+ * @get_channels: Get number of channels.
+ * @set_channels: Set number of channels.  Returns a negative error code or
+ *	zero.
+ * @get_dump_flag: Get dump flag indicating current dump length, version,
+ *	and flag of the device.
+ * @get_dump_data: Get dump data.
+ * @set_dump: Set dump specific flags to the device.
+ * @get_ts_info: Get the time stamping and PTP hardware clock capabilities.
+ *	Drivers supporting transmit time stamps in software should set this to
+ *	ethtool_op_get_ts_info().
+ * @get_module_info: Get the size and type of the eeprom contained within
+ *	a plug-in module.
+ * @get_module_eeprom: Get the eeprom information from the plug-in module
+ *
+ * All operations are optional (i.e. the function pointer may be set
+ * to %NULL) and callers must take this into account.  Callers must
+ * hold the RTNL lock.
+ *
+ * See the structures used by these operations for further documentation.
+ *
+ * See &struct net_device and &struct net_device_ops for documentation
+ * of the generic netdev features interface.
+ */
+struct ethtool_ops {
+	int	(*get_settings)(struct net_device *, struct ethtool_cmd *);
+	int	(*set_settings)(struct net_device *, struct ethtool_cmd *);
+	void	(*get_drvinfo)(struct net_device *, struct ethtool_drvinfo *);
+	int	(*get_regs_len)(struct net_device *);
+	void	(*get_regs)(struct net_device *, struct ethtool_regs *, void *);
+	void	(*get_wol)(struct net_device *, struct ethtool_wolinfo *);
+	int	(*set_wol)(struct net_device *, struct ethtool_wolinfo *);
+	u32	(*get_msglevel)(struct net_device *);
+	void	(*set_msglevel)(struct net_device *, u32);
+	int	(*nway_reset)(struct net_device *);
+	u32	(*get_link)(struct net_device *);
+	int	(*get_eeprom_len)(struct net_device *);
+	int	(*get_eeprom)(struct net_device *,
+			      struct ethtool_eeprom *, u8 *);
+	int	(*set_eeprom)(struct net_device *,
+			      struct ethtool_eeprom *, u8 *);
+	int	(*get_coalesce)(struct net_device *, struct ethtool_coalesce *);
+	int	(*set_coalesce)(struct net_device *, struct ethtool_coalesce *);
+	void	(*get_ringparam)(struct net_device *,
+				 struct ethtool_ringparam *);
+	int	(*set_ringparam)(struct net_device *,
+				 struct ethtool_ringparam *);
+	void	(*get_pauseparam)(struct net_device *,
+				  struct ethtool_pauseparam*);
+	int	(*set_pauseparam)(struct net_device *,
+				  struct ethtool_pauseparam*);
+	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
+	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
+	int	(*set_phys_id)(struct net_device *, enum ethtool_phys_id_state);
+	void	(*get_ethtool_stats)(struct net_device *,
+				     struct ethtool_stats *, u64 *);
+	int	(*begin)(struct net_device *);
+	void	(*complete)(struct net_device *);
+	u32	(*get_priv_flags)(struct net_device *);
+	int	(*set_priv_flags)(struct net_device *, u32);
+	int	(*get_sset_count)(struct net_device *, int);
+	int	(*get_rxnfc)(struct net_device *,
+			     struct ethtool_rxnfc *, u32 *rule_locs);
+	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
+	int	(*flash_device)(struct net_device *, struct ethtool_flash *);
+	int	(*reset)(struct net_device *, u32 *);
+	u32	(*get_rxfh_indir_size)(struct net_device *);
+	int	(*get_rxfh_indir)(struct net_device *, u32 *);
+	int	(*set_rxfh_indir)(struct net_device *, const u32 *);
+	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
+	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
+	int	(*get_dump_flag)(struct net_device *, struct ethtool_dump *);
+	int	(*get_dump_data)(struct net_device *,
+				 struct ethtool_dump *, void *);
+	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
+	int	(*get_ts_info)(struct net_device *, struct ethtool_ts_info *);
+	int     (*get_module_info)(struct net_device *,
+				   struct ethtool_modinfo *);
+	int     (*get_module_eeprom)(struct net_device *,
+				     struct ethtool_eeprom *, u8 *);
+
+
+};
+#endif /* __KERNEL__ */
 
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
@@ -786,6 +1081,9 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
+#define ETHTOOL_GMODULEINFO	0x00000042 /* Get plug-in module information */
+#define ETHTOOL_GMODULEEEPROM	0x00000043 /* Get plug-in module eeprom */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -935,6 +1233,12 @@ enum ethtool_sfeatures_retval_bits {
 #define RX_CLS_LOC_FIRST	0xfffffffe
 #define RX_CLS_LOC_LAST		0xfffffffd
 
+/* EEPROM Standards for plug in modules */
+#define ETH_MODULE_SFF_8079		0x1
+#define ETH_MODULE_SFF_8079_LEN		256
+#define ETH_MODULE_SFF_8472		0x2
+#define ETH_MODULE_SFF_8472_LEN		512
+
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
  * were actually reset.  On successful return, the flags indicate the
diff --git a/ethtool.8.in b/ethtool.8.in
index 63d5d48..470fd8d 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -325,6 +325,13 @@ ethtool \- query or control network driver and hardware settings
 .I devname flag
 .A1 on off
 .RB ...
+.HP
+.B ethtool \-m|\-\-mod\-eeprom\-dump
+.I devname
+.B2 raw on off
+.BN offset
+.BN length
+.HP
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -800,6 +807,19 @@ Sets the device's private flags as specified.
 .I flag
 .A1 on off
 Sets the state of the named private flag.
+.TP
+.B \-m \-\-mod\-eeprom\-dump
+Retrieves and prints module (SFP+, XFP, ...) EEPROMs dump for the specified network device.
+Default is to dump the entire EEPROM.
+.TP
+.BI raw \ on|off
+Dumps the raw EEPROM data to stdout.
+.TP
+.BI offset \ N
+Start address of module EEPROM dump.
+.TP
+.BI length \ N
+Length of module EEPROM dump.
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
@@ -815,7 +835,8 @@ Eli Kupermann,
 Scott Feldman,
 Andi Kleen,
 Alexander Duyck,
-Sucheta Chakraborty.
+Sucheta Chakraborty,
+Yaniv Rosner.
 .SH AVAILABILITY
 .B ethtool
 is available from
diff --git a/ethtool.c b/ethtool.c
index e80b38b..6d022c3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2214,6 +2214,64 @@ static int do_nway_rst(struct cmd_context *ctx)
 	return err;
 }
 
+static int do_gmoduleeeprom(struct cmd_context *ctx)
+{
+	int geeprom_changed = 0;
+	int geeprom_dump_raw = 0;
+	u32 geeprom_offset = 0;
+	u32 geeprom_length = -1;
+	struct cmdline_info cmdline_geeprom[] = {
+		{ "offset", CMDL_U32, &geeprom_offset, NULL },
+		{ "length", CMDL_U32, &geeprom_length, NULL },
+		{ "raw", CMDL_BOOL, &geeprom_dump_raw, NULL },
+	};
+	int err;
+	struct ethtool_modinfo modinfo;
+	struct ethtool_eeprom *eeprom;
+	struct ethtool_drvinfo drvinfo;
+
+	parse_generic_cmdline(ctx, &geeprom_changed,
+			      cmdline_geeprom, ARRAY_SIZE(cmdline_geeprom));
+
+	drvinfo.cmd = ETHTOOL_GDRVINFO;
+	err = send_ioctl(ctx, &drvinfo);
+	if (err < 0) {
+		perror("Cannot get driver information");
+		return 74;
+	}
+
+	modinfo.cmd = ETHTOOL_GMODULEINFO;
+	err = send_ioctl(ctx, &modinfo);
+	if (err < 0) {
+		perror("Cannot get driver information");
+		return 74;
+	}
+
+	if (geeprom_length == -1)
+		geeprom_length = modinfo.eeprom_len;
+
+	if (modinfo.eeprom_len < geeprom_offset + geeprom_length)
+		geeprom_length = modinfo.eeprom_len - geeprom_offset;
+	eeprom = calloc(1, sizeof(*eeprom)+geeprom_length);
+	if (!eeprom) {
+		perror("Cannot allocate memory for EEPROM data");
+		return 75;
+	}
+	eeprom->cmd = ETHTOOL_GMODULEEEPROM;
+	eeprom->len = geeprom_length;
+	eeprom->offset = geeprom_offset;
+	err = send_ioctl(ctx, eeprom);
+	if (err < 0) {
+		perror("Cannot get EEPROM data");
+		free(eeprom);
+		return 74;
+	}
+	err = dump_eeprom(geeprom_dump_raw, &drvinfo, eeprom);
+	free(eeprom);
+
+	return err;
+}
+
 static int do_geeprom(struct cmd_context *ctx)
 {
 	int geeprom_changed = 0;
@@ -3231,6 +3289,11 @@ static const struct option {
 	{ "--show-priv-flags" , 1, do_gprivflags, "Query private flags" },
 	{ "--set-priv-flags", 1, do_sprivflags, "Set private flags",
 	  "		FLAG on|off ...\n" },
+	{ "-m|--mod-eeprom-dump", 1, do_gmoduleeeprom,
+	  "Dumps SFP+ module EEPROM",
+	  "		[ raw on|off ]\n"
+	  "		[ offset N ]\n"
+	  "		[ length N ]\n" },
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
-- 
1.7.7.1
