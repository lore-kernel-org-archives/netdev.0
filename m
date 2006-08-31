From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [RFC] Wake-on-LAN flex filters
Date: Thu, 31 Aug 2006 16:20:35 -0700
Message-ID: <1157066435.4416.34.camel@strongmad>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-etr0yB/7/qypGA3FC9Le"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7257 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S932412AbWHaXVC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 19:21:02 -0400
To: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-etr0yB/7/qypGA3FC9Le
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Most modern Ethernet hardware supports flexible filters for wake-on-LAN,
probably because it's a requirement for certification with Another
Operating System.

This patch implements this feature on e1000 via Ethtool.  The kernel
portion of this code is fairly well polished, but the changes to the
tool are extremely hacky and ugly.  Don't bother to comment on that
portion; if people want this feature either Jeff or I will redo it
correctly.

To create a filter:
# ethtool -F <interface> <filter number> <filter>

where <filter number> can be from 0 - 3 (at least for e1000), and where
filter is a string of hex digits describing what the filtered frame
should look like.  Each byte MUST be represented by two hex digits, and
no whitespace is allowed.  If a particular byte should be ignored by the
filter, represent it with "xx".   

For example:
# ethtool -F eth0 1 00xxxxxxxx11223344567890xx

To show a filter:
# ethtool -f <interface> <filter num>   

To enable WOL filters (after setting one):
# ethtool -s <interface> wol f 

Please review and comment, and thanks.

Kernel patch is inline, ethtool patch is attached. 

-Mitch

diff -urpN -X linux-2.6.18-rc4/Documentation/dontdiff linux-2.6.18-rc4-clean/include/linux/ethtool.h linux-2.6.18-rc4/include/linux/ethtool.h
--- linux-2.6.18-rc4-clean/include/linux/ethtool.h	2006-08-21 13:28:47.000000000 -0700
+++ linux-2.6.18-rc4/include/linux/ethtool.h	2006-08-21 13:48:59.000000000 -0700
@@ -53,6 +53,17 @@ struct ethtool_wolinfo {
 	__u32	supported;
 	__u32	wolopts;
 	__u8	sopass[SOPASS_MAX]; /* SecureOn(tm) password */
+	__u32	n_filters;
+};
+
+#define WOL_FILTER_MAX 256
+#define WOL_FILTER_IGNORE 0x100
+/* wake-on-lan flexible filters */
+struct ethtool_wol_filter {
+	__u32	cmd;
+	__u32	index;
+	__u32	len;
+	__u16	mask_val[0];
 };
 
 /* for passing single values */
@@ -372,6 +383,8 @@ struct ethtool_ops {
 	void	(*complete)(struct net_device *);
 	u32     (*get_ufo)(struct net_device *);
 	int     (*set_ufo)(struct net_device *, u32);
+	int	(*get_wol_filter)(struct net_device *, struct ethtool_wol_filter *, u16 *);
+	int	(*set_wol_filter)(struct net_device *, struct ethtool_wol_filter *, u16 *);
 };
 #endif /* __KERNEL__ */
 
@@ -413,6 +426,8 @@ struct ethtool_ops {
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
 #define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
+#define ETHTOOL_GWOLFILTER	0x00000025 /* Get WOL flex filter */
+#define ETHTOOL_SWOLFILTER	0x00000026 /* Set WOL flex filter */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -497,5 +512,6 @@ struct ethtool_ops {
 #define WAKE_ARP		(1 << 4)
 #define WAKE_MAGIC		(1 << 5)
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
+#define WAKE_FILTER		(1 << 7)
 
 #endif /* _LINUX_ETHTOOL_H */
diff -urpN -X linux-2.6.18-rc4/Documentation/dontdiff linux-2.6.18-rc4-clean/net/core/ethtool.c linux-2.6.18-rc4/net/core/ethtool.c
--- linux-2.6.18-rc4-clean/net/core/ethtool.c	2006-08-21 13:28:48.000000000 -0700
+++ linux-2.6.18-rc4/net/core/ethtool.c	2006-08-21 13:59:14.000000000 -0700
@@ -229,6 +229,63 @@ static int ethtool_set_wol(struct net_de
 	return dev->ethtool_ops->set_wol(dev, &wol);
 }
 
+static int ethtool_get_wol_filter(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_wol_filter wolfilt = { ETHTOOL_GWOLFILTER };
+	u16 *data;
+
+	if (!dev->ethtool_ops->get_wol_filter)
+		return -EOPNOTSUPP;
+
+	data = kmalloc(WOL_FILTER_MAX*2, GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	if (copy_from_user(&wolfilt, useraddr, sizeof(wolfilt)))
+		return -EFAULT;
+
+	dev->ethtool_ops->get_wol_filter(dev, &wolfilt, data);
+
+	if (copy_to_user(useraddr, &wolfilt, sizeof(wolfilt)))
+		return -EFAULT;
+	if (copy_to_user(useraddr + sizeof(wolfilt), data, wolfilt.len*2))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int ethtool_set_wol_filter(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_wol_filter wolfilt;
+	u16 *data;
+	int ret;
+
+	if (!dev->ethtool_ops->get_wol_filter)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&wolfilt, useraddr, sizeof(wolfilt)))
+		return -EFAULT;
+
+	if (wolfilt.len > WOL_FILTER_MAX)
+		return -EOPNOTSUPP;
+		
+	if (wolfilt.len) {
+		data = kmalloc(wolfilt.len*2, GFP_KERNEL);
+		if (!data)
+			return -ENOMEM;
+	}
+
+	ret = -EFAULT;
+	if (copy_from_user(data, useraddr + sizeof(wolfilt), wolfilt.len*2))
+		goto out;
+
+	ret = dev->ethtool_ops->set_wol_filter(dev, &wolfilt, data);
+ out:
+	kfree(data);
+	return ret;
+		
+}
+
 static int ethtool_get_msglevel(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata = { ETHTOOL_GMSGLVL };
@@ -934,6 +991,12 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_SGSO:
 		rc = ethtool_set_gso(dev, useraddr);
 		break;
+	case ETHTOOL_GWOLFILTER:
+		rc = ethtool_get_wol_filter(dev, useraddr);
+		break;
+	case ETHTOOL_SWOLFILTER:
+		rc = ethtool_set_wol_filter(dev, useraddr);
+		break;
 	default:
 		rc =  -EOPNOTSUPP;
 	}
diff -urpN -X linux-2.6.18-rc4/Documentation/dontdiff linux-2.6.18-rc4-clean/drivers/net/e1000/e1000_ethtool.c linux-2.6.18-rc4/drivers/net/e1000/e1000_ethtool.c
--- linux-2.6.18-rc4-clean/drivers/net/e1000/e1000_ethtool.c	2006-08-21 13:28:43.000000000 -0700
+++ linux-2.6.18-rc4/drivers/net/e1000/e1000_ethtool.c	2006-08-31 14:05:46.000000000 -0700
@@ -1704,6 +1704,9 @@ e1000_get_wol(struct net_device *netdev,
 
 	default:
 		wol->supported = WAKE_UCAST | WAKE_MCAST |
+#ifdef ETHTOOL_GWOLFILTER
+				 WAKE_FILTER |
+#endif
 				 WAKE_BCAST | WAKE_MAGIC;
 		wol->wolopts = 0;
 
@@ -1716,6 +1719,12 @@ do_defaults:
 			wol->wolopts |= WAKE_BCAST;
 		if (adapter->wol & E1000_WUFC_MAG)
 			wol->wolopts |= WAKE_MAGIC;
+#ifdef ETHTOOL_GWOLFILTER
+		if (adapter->wol & E1000_WUFC_FLX_FILTERS) {
+			wol->wolopts |= WAKE_FILTER;
+			wol->n_filters = 4;
+		}
+#endif
 		return;
 	}
 }
@@ -1770,10 +1779,100 @@ e1000_set_wol(struct net_device *netdev,
 			adapter->wol |= E1000_WUFC_BC;
 		if (wol->wolopts & WAKE_MAGIC)
 			adapter->wol |= E1000_WUFC_MAG;
+#ifdef ETHTOOL_GWOLFILTER
+		if (wol->wolopts & WAKE_FILTER)
+			adapter->wol |= adapter->wol_filters;
+#endif
+	}
+
+	return 0;
+}
+
+#ifdef ETHTOOL_GWOLFILTER
+static int
+e1000_get_wol_filter(struct net_device *netdev,
+		struct ethtool_wol_filter *wolfilt,
+		uint16_t *mask_val)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	uint32_t mask, mt_val, vt_val, fflt, shift;
+	int i;
+	
+	if (wolfilt->index > E1000_FLEXIBLE_FILTER_COUNT_MAX)
+		return -EOPNOTSUPP;
+	
+	mask = 1 << wolfilt->index;
+	shift = wolfilt->index * 8;
+
+	fflt = E1000_READ_REG_ARRAY(hw, FFLT, wolfilt->index*2);
+	wolfilt->len = fflt & 0xff;
+	for (i = 0; i < wolfilt->len; i++) {
+		mt_val = E1000_READ_REG_ARRAY(hw, FFMT, i*2);
+		vt_val = E1000_READ_REG_ARRAY(hw, FFVT, i*2);
+		mt_val &= mask;
+		vt_val = (vt_val >> shift) & 0xff;
+		if (!mt_val) {
+			mask_val[i] = WOL_FILTER_IGNORE | vt_val;
+		}
+		else
+			mask_val[i] = vt_val;
+	}
+
+	return 0;
+}
+static int
+e1000_set_wol_filter(struct net_device *netdev,
+		struct ethtool_wol_filter *wolfilt,
+		uint16_t *mask_val)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	int i, shift;
+	uint32_t mask, wufc, mt_val, vt_val, fflt;
+
+	if ((wolfilt->index > E1000_FLEXIBLE_FILTER_COUNT_MAX) ||
+	    (wolfilt->len > E1000_FLEXIBLE_FILTER_SIZE_MAX)) {
+		return -EOPNOTSUPP;
 	}
+	
+	wufc = E1000_READ_REG(hw, WUFC);
+	mask = 1 << wolfilt->index;
+	if (wolfilt->len) {
+		shift = wolfilt->index * 8;
+		/* first, disable all filters */
+		E1000_WRITE_REG(hw, WUFC, (wufc & ~E1000_WUFC_FLX_FILTERS));
+		for (i = 0; i < wolfilt->len; i++) {
+			mt_val = E1000_READ_REG_ARRAY(hw, FFMT, i*2);
+			vt_val = E1000_READ_REG_ARRAY(hw, FFVT, i*2);
+			vt_val &= ~(0xffL << shift);
+			if (mask_val[i] & WOL_FILTER_IGNORE) {
+				mt_val &= ~mask;
+			} else {
+				mt_val |= mask;
+			}
+			vt_val |= ((mask_val[i] & 0xff) << shift);
+			E1000_WRITE_REG_ARRAY(hw, FFMT, i*2, mt_val);
+			E1000_WRITE_REG_ARRAY(hw, FFVT, i*2, vt_val);
+		}
+		adapter->wol_filters |= mask << E1000_WUFC_FLX_OFFSET;
+	} else {
+		/* account for zero-length filters */
+		adapter->wol_filters &= ~(mask << E1000_WUFC_FLX_OFFSET);
+		wufc &= ~(mask << E1000_WUFC_FLX_OFFSET);
+	}
+	
+	fflt = E1000_READ_REG_ARRAY(hw, FFLT, wolfilt->index * 2);
+	fflt &= ~0xff;
+	fflt |= wolfilt->len;
+	E1000_WRITE_REG_ARRAY(hw, FFLT, wolfilt->index * 2, fflt);
+	/* restore active filter settings.  This filter will not be
+	   active until enabled with ETHTOOL_SWOL. */
+	E1000_WRITE_REG(hw, WUFC, wufc);
 
 	return 0;
 }
+#endif  /* ETHTOOL_GWOLFILTER */
 
 /* toggle LED 4 times per second = 2 "blinks" per second */
 #define E1000_ID_INTERVAL	(HZ/4)
@@ -1923,6 +2022,10 @@ static struct ethtool_ops e1000_ethtool_
 	.get_stats_count        = e1000_get_stats_count,
 	.get_ethtool_stats      = e1000_get_ethtool_stats,
 	.get_perm_addr		= ethtool_op_get_perm_addr,
+#ifdef ETHTOOL_GWOLFILTER
+	.get_wol_filter		= e1000_get_wol_filter,
+	.set_wol_filter		= e1000_set_wol_filter,
+#endif
 };
 
 void e1000_set_ethtool_ops(struct net_device *netdev)
diff -urpN -X linux-2.6.18-rc4/Documentation/dontdiff linux-2.6.18-rc4-clean/drivers/net/e1000/e1000.h linux-2.6.18-rc4/drivers/net/e1000/e1000.h
--- linux-2.6.18-rc4-clean/drivers/net/e1000/e1000.h	2006-08-21 13:28:43.000000000 -0700
+++ linux-2.6.18-rc4/drivers/net/e1000/e1000.h	2006-08-31 14:09:51.000000000 -0700
@@ -343,6 +343,7 @@ struct e1000_adapter {
 #endif
 	boolean_t smart_power_down;	/* phy smart power down */
 	unsigned long flags;
+	uint32_t wol_filters;
 };
 
 enum e1000_state_t {


--=-etr0yB/7/qypGA3FC9Le
Content-Disposition: attachment; filename=ff.ethtool.diff
Content-Type: text/x-patch; name=ff.ethtool.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urpN ethtool-4/ethtool.c ethtool-4-ff/ethtool.c
--- ethtool-4/ethtool.c	2006-07-18 19:21:38.000000000 -0700
+++ ethtool-4-ff/ethtool.c	2006-08-21 14:12:02.000000000 -0700
@@ -65,6 +65,9 @@ static int do_scoalesce(int fd, struct i
 static int do_goffload(int fd, struct ifreq *ifr);
 static int do_soffload(int fd, struct ifreq *ifr);
 static int do_gstats(int fd, struct ifreq *ifr);
+static int do_gwolfilter(int fd, struct ifreq *ifr);
+static int do_swolfilter(int fd, struct ifreq *ifr);
+static void parse_filter(char *cmdline);
 
 static enum {
 	MODE_HELP = -1,
@@ -86,6 +89,8 @@ static enum {
 	MODE_GOFFLOAD,
 	MODE_SOFFLOAD,
 	MODE_GSTATS,
+	MODE_GFILTER,
+	MODE_SFILTER,
 } mode = MODE_GSET;
 
 static struct option { 
@@ -162,6 +167,8 @@ static struct option { 
     { "-t", "--test", MODE_TEST, "Execute adapter self test",
                 "               [ online | offline ]\n" },
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
+    { "-f", "--show-filter", MODE_GFILTER, "Show WOL filter N\n"},
+    { "-F", "--change-filter", MODE_SFILTER, "Set WOL filter N\n"},
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -255,6 +262,10 @@ static int seeprom_changed = 0;
 static int seeprom_magic = 0;
 static int seeprom_offset = -1;
 static int seeprom_value = 0;
+static int gfilter_num = 0;
+static int sfilter_num = 0;
+static u16 filter[WOL_FILTER_MAX];
+static int filter_len = 0;
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -407,6 +418,8 @@ static void parse_cmdline(int argc, char
 			    (mode == MODE_GOFFLOAD) ||
 			    (mode == MODE_SOFFLOAD) ||
 			    (mode == MODE_GSTATS) ||
+			    (mode == MODE_GFILTER) ||
+			    (mode == MODE_SFILTER) ||
 			    (mode == MODE_PHYS_ID)) {
 				devname = argp[i];
 				break;
@@ -486,6 +499,26 @@ static void parse_cmdline(int argc, char
 				i = argc;
 				break;
 			}
+			if (mode == MODE_GFILTER) {
+				long v;
+				v = strtol(argp[i], NULL, 0);
+				if (v < 0)
+					show_usage(1);
+				gfilter_num = (int) v;
+				break;
+			}
+			if (mode == MODE_SFILTER) {
+				long v;
+				v = strtol(argp[i], NULL, 0);
+				if (v < 0)
+					show_usage(1);
+				sfilter_num = (int) v;
+				i += 1;
+				if (i >= argc)
+					show_usage(1);
+				parse_filter(argp[i]);
+				break;
+			}
 			if (mode != MODE_SSET)
 				show_usage(1);
 			if (!strcmp(argp[i], "speed")) {
@@ -865,6 +898,9 @@ static int parse_wolopts(char *optstr, u
 			case 's':
 				*data |= WAKE_MAGICSECURE;
 				break;
+			case 'f':
+				*data |= WAKE_FILTER;
+				break;
 			case 'd':
 				*data = 0;
 				break;
@@ -896,6 +932,8 @@ static char *unparse_wolopts(int wolopts
 			*p++ = 'a';
 		if (wolopts & WAKE_MAGIC)
 			*p++ = 'g';
+		if (wolopts & WAKE_FILTER)
+			*p++ = 'f';
 		if (wolopts & WAKE_MAGICSECURE)
 			*p++ = 's';
 	} else {
@@ -905,6 +943,75 @@ static char *unparse_wolopts(int wolopts
 	return buf;
 }
 
+static void parse_filter(char *cmdline)
+{
+	int i = 0;
+	int j = 0;
+	u16 temp = 0;
+	while (i < strlen(cmdline)) {
+		if (i & 1) /* i is odd */
+			temp = temp << 4;
+		else
+			temp = 0;
+			
+		switch (cmdline[i]) {
+		case '0' ... '9':
+			temp |= (cmdline[i] - '0');
+			break;
+		case 'a' ... 'f':
+			temp |= (cmdline[i] - 'a' + 0xa);
+			break;
+		case 'A' ... 'F':
+			temp |= (cmdline[i] - 'A' + 0xa);
+			break;
+		case 'X':
+		case 'x':
+			if (i & 1)
+				show_usage(1);
+			i++;
+			if ((cmdline[i] != 'x') && (cmdline[i] != 'X'))
+				show_usage(1);
+			temp = 0x100;
+			break;
+		default:
+			show_usage(1);
+			break;
+		} /* switch */
+		if (i & 1) {
+			filter[j++] = temp;
+		}
+		i++;
+	}
+	filter_len = j;
+}
+
+static int dump_wol_filter(struct ethtool_wol_filter *wolfilt)
+{
+	int i = 0;
+	u16 *mask_val;
+	
+	mask_val = (u16 *)((void *)wolfilt + sizeof(struct ethtool_wol_filter));
+
+	fprintf(stdout, "Wake-on-LAN filter %d, length %d\n",wolfilt->index, wolfilt->len);
+	if (wolfilt->mask_val[i] & 0xFF00)
+		fprintf(stdout, "\txx");
+	else
+		fprintf(stdout, "\t%2.2x", wolfilt->mask_val[i]);
+	for (i = 1; i < wolfilt->len; i++) {
+		if (wolfilt->mask_val[i] & 0xFF00)
+			fprintf(stdout, ":xx");
+		else
+			fprintf(stdout, ":%2.2x", wolfilt->mask_val[i]);
+		if ((i % 22) == 0)
+			fprintf(stdout, "\n\t");
+	}
+
+	fprintf(stdout, "\n");
+
+	return 0;
+}
+
+
 static int parse_sopass(char *src, unsigned char *dest)
 {
 	int count;
@@ -1185,6 +1292,10 @@ static int doit(void)
 		return do_soffload(fd, &ifr);
 	} else if (mode == MODE_GSTATS) {
 		return do_gstats(fd, &ifr);
+	} else if (mode == MODE_GFILTER) {
+		return do_gwolfilter(fd, &ifr);
+	} else if (mode == MODE_SFILTER) {
+		return do_swolfilter(fd, &ifr);
 	}
 
 	return 69;
@@ -1813,6 +1924,46 @@ static int do_seeprom(int fd, struct ifr
 	return err;
 }
 
+static int do_gwolfilter(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_wol_filter *gfilter;
+
+	gfilter = calloc(1, sizeof(struct ethtool_wol_filter)+ WOL_FILTER_MAX * 2);
+	if (!gfilter) {
+		perror("Cannot allocate memory for filter data");
+		return 75;
+	}
+	gfilter->cmd = ETHTOOL_GWOLFILTER;
+	gfilter->index = gfilter_num;
+	ifr->ifr_data = (caddr_t)gfilter;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	dump_wol_filter(gfilter);
+	free(gfilter);
+	return err;
+}
+
+static int do_swolfilter(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_wol_filter *sfilter;
+
+	sfilter = calloc(1, sizeof(*sfilter)+ WOL_FILTER_MAX * 2);
+	if (!filter) {
+		perror("Cannot allocate memory for filter data");
+		return 75;
+	}
+	sfilter->cmd = ETHTOOL_SWOLFILTER;
+	sfilter->index = sfilter_num;
+	sfilter->len = filter_len;
+	memcpy((void *)sfilter + sizeof(struct ethtool_wol_filter), filter, filter_len * 2);
+	ifr->ifr_data = (caddr_t)sfilter;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	free(sfilter);
+	return err;
+}
+
+
 static int do_test(int fd, struct ifreq *ifr)
 {
 	int err;
diff -urpN ethtool-4/ethtool-copy.h ethtool-4-ff/ethtool-copy.h
--- ethtool-4/ethtool-copy.h	2006-07-18 19:21:38.000000000 -0700
+++ ethtool-4-ff/ethtool-copy.h	2006-08-16 11:16:43.000000000 -0700
@@ -52,9 +52,19 @@ struct ethtool_wolinfo {
 	u32	cmd;
 	u32	supported;
 	u32	wolopts;
+	u32	n_filters;
 	u8	sopass[SOPASS_MAX]; /* SecureOn(tm) password */
 };
 
+#define WOL_FILTER_MAX 256
+/* wake-on-lan flexible filters */
+struct ethtool_wol_filter {
+	u32	cmd;
+	u32	index;
+	u32	len;
+	u16	mask_val[0];
+};
+
 /* for passing single values */
 struct ethtool_value {
 	u32	cmd;
@@ -285,6 +295,8 @@ struct ethtool_stats {
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
 #define ETHTOOL_GUFO		0x00000021 /* Get UFO enable (ethtool_value) */
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
+#define ETHTOOL_GWOLFILTER	0x00000025 /* Get WOL flex filter */
+#define ETHTOOL_SWOLFILTER	0x00000026 /* Set WOL flex filter */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -364,5 +376,6 @@ struct ethtool_stats {
 #define WAKE_ARP		(1 << 4)
 #define WAKE_MAGIC		(1 << 5)
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
+#define WAKE_FILTER		(1 << 7)
 
 #endif /* _LINUX_ETHTOOL_H */

--=-etr0yB/7/qypGA3FC9Le--
