From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: udev can't name PS3's network devices correctly
Date: Mon, 14 Apr 2008 12:11:18 +0100
Message-ID: <1208171478.31695.58.camel@pmac.infradead.org>
References: <ftdb3v$tls$1@ger.gmane.org>
	 <20080407143805.GA9492@bongo.bofh.it>
	 <1208167737.31695.32.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Hoyer <harald@redhat.com>, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com
To: Marco d'Itri <md@Linux.IT>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42356 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbYDNLLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 07:11:33 -0400
In-Reply-To: <1208167737.31695.32.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-14 at 11:08 +0100, David Woodhouse wrote:
> One alternative approach would be to use dev->dev_id (is that exported
> in sysfs?). That's what IPv6 addrconf uses in addition to the MAC
> address to provide a unique address when MAC addresses are shared.
> 
> We could modify the libertas and gelic (and any other affected) drivers
> to provide a dev_id, make sure it's exported in sysfs, and then use that
> in the udev rules. Would that make you happy?

That would look something like this (in fact, I think it would let us
get rid of the special case for S390 too)...

--- ./udev-120/extras/rule_generator/75-persistent-net-generator.rules~	2008-04-03 20:12:53.000000000 +0100
+++ ./udev-120/extras/rule_generator/75-persistent-net-generator.rules	2008-04-14 11:52:46.000000000 +0100
@@ -18,7 +18,7 @@ SUBSYSTEM!="net", GOTO="persistent_net_g
 NAME=="?*", GOTO="persistent_net_generator_end"
 
 # device name whitelist
-KERNEL!="eth*|ath*|wlan*[0-9]|ra*|sta*|ctc*|lcs*|hsi*", GOTO="persistent_net_generator_end"
+KERNEL!="eth*|ath*|wlan*[0-9]|ra*|sta*|ctc*|lcs*|hsi*|msh*", GOTO="persistent_net_generator_end"
 
 # ignore Xen virtual interfaces
 SUBSYSTEMS=="xen", GOTO="persistent_net_generator_end"
@@ -29,6 +29,9 @@ ENV{MATCHADDR}="$attr{address}"
 # match interface type
 ENV{MATCHIFTYPE}="$attr{type}"
 
+# match dev_id
+ENV{MATCHDEVID}="$attr{dev_id}"
+
 # do not use "locally administered" MAC address
 ENV{MATCHADDR}=="?[2367abef]:*", ENV{MATCHADDR}=""
 
--- ./udev-120/extras/rule_generator/write_net_rules~	2008-04-03 20:12:53.000000000 +0100
+++ ./udev-120/extras/rule_generator/write_net_rules	2008-04-14 11:47:27.000000000 +0100
@@ -15,6 +15,7 @@
 # variables used to communicate:
 #   MATCHADDR             MAC address used for the match
 #   MATCHID               bus_id used for the match
+#   MATCHDEVID            dev_id used for the match
 #   MATCHDRV              driver name used for the match
 #   MATCHIFTYPE           interface type match
 #   COMMENT               comment to add to the generated rule
@@ -78,6 +79,10 @@ if [ "$MATCHDRV" ]; then
 	match="$match, DRIVERS==\"$MATCHDRV\""
 fi
 
+if [ "$MATCHDEVID" ]; then
+	match="$match, ATTR{dev_id}==\"$MATCHDEVID\""
+fi
+
 if [ "$MATCHID" ]; then
 	match="$match, KERNELS==\"$MATCHID\""
 fi


... and this...

--- ./linux-2.6.24.ppc/drivers/net/ps3_gelic_wireless.c~	2008-04-13 13:38:15.000000000 +0100
+++ ./linux-2.6.24.ppc/drivers/net/ps3_gelic_wireless.c	2008-04-14 11:15:10.000000000 +0100
@@ -2699,6 +2699,7 @@ int gelic_wl_driver_probe(struct gelic_c
 	gelic_wl_setup_netdev_ops(netdev);
 
 	/* setup some of net_device and register it */
+	netdev->dev_id = GELIC_PORT_WIRELESS;
 	ret = gelic_net_setup_netdev(netdev, card);
 	if (ret)
 		goto fail_setup;
--- ./linux-2.6.24.ppc/drivers/net/ps3_gelic_net.c~	2008-04-13 13:38:15.000000000 +0100
+++ ./linux-2.6.24.ppc/drivers/net/ps3_gelic_net.c	2008-04-14 11:15:19.000000000 +0100
@@ -1635,6 +1635,7 @@ static int ps3_gelic_driver_probe(struct
 	netdev->irq = card->irq;
 	SET_NETDEV_DEV(netdev, &card->dev->core);
 	gelic_ether_setup_netdev_ops(netdev, &card->napi);
+	netdev->dev_id = GELIC_PORT_ETHERNET;
 	result = gelic_net_setup_netdev(netdev, card);
 	if (result) {
 		dev_dbg(&dev->core, "%s: setup_netdev failed %d",
--- ./linux-2.6.24.ppc/drivers/net/wireless/libertas/main.c~	2008-04-13 13:38:16.000000000 +0100
+++ ./linux-2.6.24.ppc/drivers/net/wireless/libertas/main.c	2008-04-14 10:49:52.000000000 +0100
@@ -1205,6 +1205,8 @@ int lbs_start_card(struct lbs_private *p
 	/* init 802.11d */
 	lbs_init_11d(priv);
 
+	dev->dev_id = 0;
+
 	if (register_netdev(dev)) {
 		lbs_pr_err("cannot register ethX device\n");
 		goto done;
@@ -1327,6 +1329,7 @@ static int lbs_add_mesh(struct lbs_priva
 	mesh_dev->wireless_handlers = (struct iw_handler_def *)&mesh_handler_def;
 #endif
 	/* Register virtual mesh interface */
+	mesh_dev->dev_id = 1;
 	ret = register_netdev(mesh_dev);
 	if (ret) {
 		lbs_pr_err("cannot register mshX virtual interface\n");
@@ -1542,6 +1545,7 @@ static int lbs_add_rtap(struct lbs_priva
 	rtap_dev->set_multicast_list = lbs_set_multicast_list;
 	rtap_dev->priv = priv;
 
+	rtap_dev->dev_id = 2;
 	ret = register_netdev(rtap_dev);
 	if (ret) {
 		free_netdev(rtap_dev);
--- ./linux-2.6.24.ppc/net/core/net-sysfs.c~	2008-04-13 13:38:24.000000000 +0100
+++ ./linux-2.6.24.ppc/net/core/net-sysfs.c	2008-04-14 10:58:32.000000000 +0100
@@ -87,6 +87,7 @@ static ssize_t netdev_store(struct devic
 	return ret;
 }
 
+NETDEVICE_SHOW(dev_id, fmt_hex);
 NETDEVICE_SHOW(addr_len, fmt_dec);
 NETDEVICE_SHOW(iflink, fmt_dec);
 NETDEVICE_SHOW(ifindex, fmt_dec);
@@ -210,6 +211,7 @@ static ssize_t store_tx_queue_len(struct
 
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
+	__ATTR(dev_id, S_IRUGO, show_dev_id, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
 	__ATTR(ifindex, S_IRUGO, show_ifindex, NULL),
 	__ATTR(features, S_IRUGO, show_features, NULL),

-- 
dwmw2

