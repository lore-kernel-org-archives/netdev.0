From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH] hostap: Reduce stack use
Date: Thu, 24 Mar 2005 19:21:43 -0800
Message-ID: <20050325032142.GA8198@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Reduce stack use by kmalloc'ing some of the large local variables.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


Index: wireless-2.6/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/hostap/hostap_cs.c	2005-03-22 20:07:48.000000000 -0800
+++ wireless-2.6/drivers/net/wireless/hostap/hostap_cs.c	2005-03-22 21:12:48.000000000 -0800
@@ -270,19 +270,26 @@
 }
 
 
-static void sandisk_enable_wireless(struct net_device *dev)
+static int sandisk_enable_wireless(struct net_device *dev)
 {
-	int res;
+	int res, ret = 0;
 	conf_reg_t reg;
 	struct hostap_interface *iface = dev->priv;
 	local_info_t *local = iface->local;
 	tuple_t tuple;
-	cisparse_t parse;
+	cisparse_t *parse = NULL;
 	u_char buf[64];
 
 	if (local->link->io.NumPorts1 < 0x42) {
 		/* Not enough ports to be SanDisk multi-function card */
-		return;
+		ret = -ENODEV;
+		goto done;
+	}
+
+	parse = kmalloc(sizeof(cisparse_t), GFP_KERNEL);
+	if (parse == NULL) {
+		ret = -ENOMEM;
+		goto done;
 	}
 
 	tuple.DesiredTuple = CISTPL_MANFID;
@@ -292,19 +299,21 @@
 	tuple.TupleOffset = 0;
 	if (pcmcia_get_first_tuple(local->link->handle, &tuple) ||
 	    pcmcia_get_tuple_data(local->link->handle, &tuple) ||
-	    pcmcia_parse_tuple(local->link->handle, &tuple, &parse) ||
-	    parse.manfid.manf != 0xd601 || parse.manfid.card != 0x0101) {
+	    pcmcia_parse_tuple(local->link->handle, &tuple, parse) ||
+	    parse->manfid.manf != 0xd601 || parse->manfid.card != 0x0101) {
 		/* No SanDisk manfid found */
-		return;
+		ret = -ENODEV;
+		goto done;
 	}
 
 	tuple.DesiredTuple = CISTPL_LONGLINK_MFC;
 	if (pcmcia_get_first_tuple(local->link->handle, &tuple) ||
 	    pcmcia_get_tuple_data(local->link->handle, &tuple) ||
-	    pcmcia_parse_tuple(local->link->handle, &tuple, &parse) ||
-		parse.longlink_mfc.nfn < 2) {
+	    pcmcia_parse_tuple(local->link->handle, &tuple, parse) ||
+		parse->longlink_mfc.nfn < 2) {
 		/* No multi-function links found */
-		return;
+		ret = -ENODEV;
+		goto done;
 	}
 
 	printk(KERN_DEBUG "%s: Multi-function SanDisk ConnectPlus detected"
@@ -319,7 +328,7 @@
 	if (res != CS_SUCCESS) {
 		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
 		       dev->name, res);
-		return;
+		goto done;
 	}
 	mdelay(5);
 
@@ -335,7 +344,7 @@
 	if (res != CS_SUCCESS) {
 		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
 		       dev->name, res);
-		return;
+		goto done;
 	}
 	mdelay(5);
 
@@ -345,6 +354,10 @@
 	udelay(10);
 	HFA384X_OUTB(0x4b, SANDISK_WLAN_ACTIVATION_OFF);
 	udelay(10);
+
+done:
+	kfree(parse);
+	return ret;
 }
 
 
@@ -594,9 +607,9 @@
 	struct net_device *dev;
 	struct hostap_interface *iface;
 	local_info_t *local;
-	int ret;
+	int ret = 1;
 	tuple_t tuple;
-	cisparse_t parse;
+	cisparse_t *parse;
 	int last_fn, last_ret;
 	u_char buf[64];
 	config_info_t conf;
@@ -604,6 +617,12 @@
 
 	PDEBUG(DEBUG_FLOW, "prism2_config()\n");
 
+	parse = kmalloc(sizeof(cisparse_t), GFP_KERNEL);
+	if (parse == NULL) {
+		ret = -ENOMEM;
+		goto failed;
+	}
+
 	tuple.DesiredTuple = CISTPL_CONFIG;
 	tuple.Attributes = 0;
 	tuple.TupleData = buf;
@@ -611,9 +630,9 @@
 	tuple.TupleOffset = 0;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link->handle, &tuple));
 	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link->handle, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link->handle, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
+	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link->handle, &tuple, parse));
+	link->conf.ConfigBase = parse->config.base;
+	link->conf.Present = parse->config.rmask[0];
 
 	CS_CHECK(GetConfigurationInfo,
 		 pcmcia_get_configuration_info(link->handle, &conf));
@@ -625,11 +644,11 @@
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link->handle, &tuple));
 	for (;;) {
-		cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
+		cistpl_cftable_entry_t *cfg = &(parse->cftable_entry);
 		CFG_CHECK2(GetTupleData,
 			   pcmcia_get_tuple_data(link->handle, &tuple));
 		CFG_CHECK2(ParseTuple,
-			   pcmcia_parse_tuple(link->handle, &tuple, &parse));
+			   pcmcia_parse_tuple(link->handle, &tuple, parse));
 
 		if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
 			dflt = *cfg;
@@ -792,14 +811,16 @@
 		if (ret == 0 && local->ddev)
 			strcpy(local->node.dev_name, local->ddev->name);
 	}
+	kfree(parse);
 	return ret;
 
  cs_failed:
 	cs_error(link->handle, last_fn, last_ret);
 
  failed:
+	kfree(parse);
 	prism2_release((u_long)link);
-	return 1;
+	return ret;
 }
 
 
Index: wireless-2.6/drivers/net/wireless/hostap/hostap_ioctl.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/hostap/hostap_ioctl.c	2005-03-22 20:07:48.000000000 -0800
+++ wireless-2.6/drivers/net/wireless/hostap/hostap_ioctl.c	2005-03-22 21:15:44.000000000 -0800
@@ -519,8 +519,8 @@
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
-	struct sockaddr addr[IW_MAX_AP];
-	struct iw_quality qual[IW_MAX_AP];
+	struct sockaddr *addr;
+	struct iw_quality *qual;
 
 	iface = netdev_priv(dev);
 	local = iface->local;
@@ -532,12 +532,24 @@
 		return -EOPNOTSUPP;
 	}
 
+	addr = kmalloc(sizeof(struct sockaddr) * IW_MAX_AP, GFP_KERNEL);
+	qual = kmalloc(sizeof(struct iw_quality) * IW_MAX_AP, GFP_KERNEL);
+	if (addr == NULL || qual == NULL) {
+		kfree(addr);
+		kfree(qual);
+		data->length = 0;
+		return -ENOMEM;
+	}
+
 	data->length = prism2_ap_get_sta_qual(local, addr, qual, IW_MAX_AP, 1);
 
-	memcpy(extra, &addr, sizeof(addr[0]) * data->length);
+	memcpy(extra, &addr, sizeof(struct sockaddr) * data->length);
 	data->flags = 1; /* has quality information */
-	memcpy(extra + sizeof(addr[0]) * data->length, &qual,
-	       sizeof(qual[0]) * data->length);
+	memcpy(extra + sizeof(struct sockaddr) * data->length, &qual,
+	       sizeof(struct iw_quality) * data->length);
+
+	kfree(addr);
+	kfree(qual);
 
 	return 0;
 }
@@ -1794,7 +1806,7 @@
 	u8 *pos;
 	u8 *ssid;
 	size_t ssid_len;
-	char buf[MAX_WPA_IE_LEN * 2 + 30];
+	char *buf;
 
 	if (bss) {
 		ssid = bss->ssid;
@@ -1916,7 +1928,8 @@
 	}
 
 	/* TODO: add BeaconInt,resp_rate,atim into BSS table */
-	if (scan || hscan) {
+	buf = kmalloc(MAX_WPA_IE_LEN * 2 + 30, GFP_KERNEL);
+	if (buf && (scan || hscan)) {
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "bcn_int=%d",
@@ -1944,6 +1957,7 @@
 							  &iwe, buf);
 		}
 	}
+	kfree(buf);
 
 	if (bss && bss->wpa_ie_len > 0 && bss->wpa_ie_len <= MAX_WPA_IE_LEN) {
 		memset(&iwe, 0, sizeof(iwe));
Index: wireless-2.6/drivers/net/wireless/hostap/hostap_plx.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/hostap/hostap_plx.c	2005-03-22 20:07:48.000000000 -0800
+++ wireless-2.6/drivers/net/wireless/hostap/hostap_plx.c	2005-03-22 21:06:23.000000000 -0800
@@ -333,11 +333,15 @@
 #define CISTPL_MANFID 0x20
 #define CISTPL_END 0xFF
 #define CIS_MAX_LEN 256
-	u8 cis[CIS_MAX_LEN];
+	u8 *cis;
 	int i, pos;
 	unsigned int rmsz, rasz, manfid1, manfid2;
 	struct prism2_plx_manfid *manfid;
 
+	cis = kmalloc(CIS_MAX_LEN, GFP_KERNEL);
+	if (cis == NULL)
+		return -ENOMEM;
+
 	/* read CIS; it is in even offsets in the beginning of attr_mem */
 	for (i = 0; i < CIS_MAX_LEN; i++)
 		cis[i] = readb(attr_mem + 2 * i);
@@ -373,6 +377,7 @@
 			if (*cor_offset > attr_len) {
 				printk(KERN_ERR "%s: COR offset not within "
 				       "attr_mem\n", dev_info);
+				kfree(cis);
 				return -1;
 			}
 			break;
@@ -394,8 +399,10 @@
 		goto cis_error;
 
 	for (manfid = prism2_plx_known_manfids; manfid->manfid1 != 0; manfid++)
-		if (manfid1 == manfid->manfid1 && manfid2 == manfid->manfid2)
+		if (manfid1 == manfid->manfid1 && manfid2 == manfid->manfid2) {
+			kfree(cis);
 			return 0;
+		}
 
 	printk(KERN_INFO "%s: unknown manfid 0x%04x, 0x%04x - assuming this is"
 	       " not supported card\n", dev_info, manfid1, manfid2);
@@ -405,6 +412,7 @@
 	printk(KERN_WARNING "%s: invalid CIS data\n", dev_info);
 
  fail:
+	kfree(cis);
 	if (ignore_cis) {
 		printk(KERN_INFO "%s: ignore_cis parameter set - ignoring "
 		       "errors during CIS verification\n", dev_info);

-- 
Jouni Malinen                                            PGP id EFC895FA
