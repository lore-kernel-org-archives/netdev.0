From: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Subject: [PATCH 09/16] pcmcia: use dynamic debug infrastructure, deprecate CS_CHECK (ray-cs.c)
Date: Sat, 24 Oct 2009 21:42:59 +0200
Message-ID: <1256413386-20501-9-git-send-email-linux@dominikbrodowski.net>
References: <20091024194219.GA19546@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091024194219.GA19546-S7uyTPAaJ/sb6pqDj42GsMgv3T4z79SOrE5yTffgRl4@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert PCMCIA drivers to use the dynamic debug infrastructure, instead of
requiring manual settings of PCMCIA_DEBUG.

Also, remove all usages of the CS_CHECK macro and replace them with proper
Linux style calling and return value checking. The extra error reporting may
be dropped, as the PCMCIA core already complains about any (non-driver-author)
errors.

CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
---
 drivers/net/wireless/ray_cs.c |  347 ++++++++++++++++++++---------------------
 1 files changed, 169 insertions(+), 178 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 88cd58e..28db791 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -71,25 +71,7 @@ typedef u_char mac_addr[ETH_ALEN];	/* Hardware address */
 #include "rayctl.h"
 #include "ray_cs.h"
 
-/* All the PCMCIA modules use PCMCIA_DEBUG to control debugging.  If
-   you do not define PCMCIA_DEBUG at all, all the debug code will be
-   left out.  If you compile with PCMCIA_DEBUG=0, the debug code will
-   be present but disabled -- but it can then be enabled for specific
-   modules at load time with a 'pc_debug=#' option to insmod.
-*/
 
-#ifdef RAYLINK_DEBUG
-#define PCMCIA_DEBUG RAYLINK_DEBUG
-#endif
-#ifdef PCMCIA_DEBUG
-static int ray_debug;
-static int pc_debug = PCMCIA_DEBUG;
-module_param(pc_debug, int, 0);
-/* #define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args); */
-#define DEBUG(n, args...) if (pc_debug > (n)) printk(args);
-#else
-#define DEBUG(n, args...)
-#endif
 /** Prototypes based on PCMCIA skeleton driver *******************************/
 static int ray_config(struct pcmcia_device *link);
 static void ray_release(struct pcmcia_device *link);
@@ -325,7 +307,7 @@ static int ray_probe(struct pcmcia_device *p_dev)
 	ray_dev_t *local;
 	struct net_device *dev;
 
-	DEBUG(1, "ray_attach()\n");
+	dev_dbg(&p_dev->dev, "ray_attach()\n");
 
 	/* Allocate space for private device-specific data */
 	dev = alloc_etherdev(sizeof(ray_dev_t));
@@ -357,7 +339,7 @@ static int ray_probe(struct pcmcia_device *p_dev)
 	local->card_status = CARD_INSERTED;
 	local->authentication_state = UNAUTHENTICATED;
 	local->num_multi = 0;
-	DEBUG(2, "ray_attach p_dev = %p,  dev = %p,  local = %p, intr = %p\n",
+	dev_dbg(&p_dev->dev, "ray_attach p_dev = %p,  dev = %p,  local = %p, intr = %p\n",
 	      p_dev, dev, local, &ray_interrupt);
 
 	/* Raylink entries in the device structure */
@@ -370,7 +352,7 @@ static int ray_probe(struct pcmcia_device *p_dev)
 #endif /* WIRELESS_SPY */
 
 
-	DEBUG(2, "ray_cs ray_attach calling ether_setup.)\n");
+	dev_dbg(&p_dev->dev, "ray_cs ray_attach calling ether_setup.)\n");
 	netif_stop_queue(dev);
 
 	init_timer(&local->timer);
@@ -393,7 +375,7 @@ static void ray_detach(struct pcmcia_device *link)
 	struct net_device *dev;
 	ray_dev_t *local;
 
-	DEBUG(1, "ray_detach(0x%p)\n", link);
+	dev_dbg(&link->dev, "ray_detach\n");
 
 	this_device = NULL;
 	dev = link->priv;
@@ -408,7 +390,7 @@ static void ray_detach(struct pcmcia_device *link)
 			unregister_netdev(dev);
 		free_netdev(dev);
 	}
-	DEBUG(2, "ray_cs ray_detach ending\n");
+	dev_dbg(&link->dev, "ray_cs ray_detach ending\n");
 } /* ray_detach */
 
 /*=============================================================================
@@ -416,19 +398,17 @@ static void ray_detach(struct pcmcia_device *link)
     is received, to configure the PCMCIA socket, and to make the
     ethernet device available to the system.
 =============================================================================*/
-#define CS_CHECK(fn, ret) \
-do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
 #define MAX_TUPLE_SIZE 128
 static int ray_config(struct pcmcia_device *link)
 {
-	int last_fn = 0, last_ret = 0;
+	int ret = 0;
 	int i;
 	win_req_t req;
 	memreq_t mem;
 	struct net_device *dev = (struct net_device *)link->priv;
 	ray_dev_t *local = netdev_priv(dev);
 
-	DEBUG(1, "ray_config(0x%p)\n", link);
+	dev_dbg(&link->dev, "ray_config\n");
 
 	/* Determine card type and firmware version */
 	printk(KERN_INFO "ray_cs Detected: %s%s%s%s\n",
@@ -440,14 +420,17 @@ static int ray_config(struct pcmcia_device *link)
 	/* Now allocate an interrupt line.  Note that this does not
 	   actually assign a handler to the interrupt.
 	 */
-	CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
+	ret = pcmcia_request_irq(link, &link->irq);
+	if (ret)
+		goto failed;
 	dev->irq = link->irq.AssignedIRQ;
 
 	/* This actually configures the PCMCIA socket -- setting up
 	   the I/O windows and the interrupt mapping.
 	 */
-	CS_CHECK(RequestConfiguration,
-		 pcmcia_request_configuration(link, &link->conf));
+	ret = pcmcia_request_configuration(link, &link->conf);
+	if (ret)
+		goto failed;
 
 /*** Set up 32k window for shared memory (transmit and control) ************/
 	req.Attributes =
@@ -455,10 +438,14 @@ static int ray_config(struct pcmcia_device *link)
 	req.Base = 0;
 	req.Size = 0x8000;
 	req.AccessSpeed = ray_mem_speed;
-	CS_CHECK(RequestWindow, pcmcia_request_window(&link, &req, &link->win));
+	ret = pcmcia_request_window(&link, &req, &link->win);
+	if (ret)
+		goto failed;
 	mem.CardOffset = 0x0000;
 	mem.Page = 0;
-	CS_CHECK(MapMemPage, pcmcia_map_mem_page(link->win, &mem));
+	ret = pcmcia_map_mem_page(link->win, &mem);
+	if (ret)
+		goto failed;
 	local->sram = ioremap(req.Base, req.Size);
 
 /*** Set up 16k window for shared memory (receive buffer) ***************/
@@ -467,11 +454,14 @@ static int ray_config(struct pcmcia_device *link)
 	req.Base = 0;
 	req.Size = 0x4000;
 	req.AccessSpeed = ray_mem_speed;
-	CS_CHECK(RequestWindow,
-		 pcmcia_request_window(&link, &req, &local->rmem_handle));
+	ret = pcmcia_request_window(&link, &req, &local->rmem_handle);
+	if (ret)
+		goto failed;
 	mem.CardOffset = 0x8000;
 	mem.Page = 0;
-	CS_CHECK(MapMemPage, pcmcia_map_mem_page(local->rmem_handle, &mem));
+	ret = pcmcia_map_mem_page(local->rmem_handle, &mem);
+	if (ret)
+		goto failed;
 	local->rmem = ioremap(req.Base, req.Size);
 
 /*** Set up window for attribute memory ***********************************/
@@ -480,16 +470,19 @@ static int ray_config(struct pcmcia_device *link)
 	req.Base = 0;
 	req.Size = 0x1000;
 	req.AccessSpeed = ray_mem_speed;
-	CS_CHECK(RequestWindow,
-		 pcmcia_request_window(&link, &req, &local->amem_handle));
+	ret = pcmcia_request_window(&link, &req, &local->amem_handle);
+	if (ret)
+		goto failed;
 	mem.CardOffset = 0x0000;
 	mem.Page = 0;
-	CS_CHECK(MapMemPage, pcmcia_map_mem_page(local->amem_handle, &mem));
+	ret = pcmcia_map_mem_page(local->amem_handle, &mem);
+	if (ret)
+		goto failed;
 	local->amem = ioremap(req.Base, req.Size);
 
-	DEBUG(3, "ray_config sram=%p\n", local->sram);
-	DEBUG(3, "ray_config rmem=%p\n", local->rmem);
-	DEBUG(3, "ray_config amem=%p\n", local->amem);
+	dev_dbg(&link->dev, "ray_config sram=%p\n", local->sram);
+	dev_dbg(&link->dev, "ray_config rmem=%p\n", local->rmem);
+	dev_dbg(&link->dev, "ray_config amem=%p\n", local->amem);
 	if (ray_init(dev) < 0) {
 		ray_release(link);
 		return -ENODEV;
@@ -511,9 +504,7 @@ static int ray_config(struct pcmcia_device *link)
 
 	return 0;
 
-cs_failed:
-	cs_error(link, last_fn, last_ret);
-
+failed:
 	ray_release(link);
 	return -ENODEV;
 } /* ray_config */
@@ -543,9 +534,9 @@ static int ray_init(struct net_device *dev)
 	struct ccs __iomem *pccs;
 	ray_dev_t *local = netdev_priv(dev);
 	struct pcmcia_device *link = local->finder;
-	DEBUG(1, "ray_init(0x%p)\n", dev);
+	dev_dbg(&link->dev, "ray_init(0x%p)\n", dev);
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(0, "ray_init - device not present\n");
+		dev_dbg(&link->dev, "ray_init - device not present\n");
 		return -1;
 	}
 
@@ -567,13 +558,13 @@ static int ray_init(struct net_device *dev)
 	local->fw_ver = local->startup_res.firmware_version[0];
 	local->fw_bld = local->startup_res.firmware_version[1];
 	local->fw_var = local->startup_res.firmware_version[2];
-	DEBUG(1, "ray_init firmware version %d.%d \n", local->fw_ver,
+	dev_dbg(&link->dev, "ray_init firmware version %d.%d \n", local->fw_ver,
 	      local->fw_bld);
 
 	local->tib_length = 0x20;
 	if ((local->fw_ver == 5) && (local->fw_bld >= 30))
 		local->tib_length = local->startup_res.tib_length;
-	DEBUG(2, "ray_init tib_length = 0x%02x\n", local->tib_length);
+	dev_dbg(&link->dev, "ray_init tib_length = 0x%02x\n", local->tib_length);
 	/* Initialize CCS's to buffer free state */
 	pccs = ccs_base(local);
 	for (i = 0; i < NUMBER_OF_CCS; i++) {
@@ -592,7 +583,7 @@ static int ray_init(struct net_device *dev)
 
 	clear_interrupt(local);	/* Clear any interrupt from the card */
 	local->card_status = CARD_AWAITING_PARAM;
-	DEBUG(2, "ray_init ending\n");
+	dev_dbg(&link->dev, "ray_init ending\n");
 	return 0;
 } /* ray_init */
 
@@ -605,9 +596,9 @@ static int dl_startup_params(struct net_device *dev)
 	struct ccs __iomem *pccs;
 	struct pcmcia_device *link = local->finder;
 
-	DEBUG(1, "dl_startup_params entered\n");
+	dev_dbg(&link->dev, "dl_startup_params entered\n");
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs dl_startup_params - device not present\n");
+		dev_dbg(&link->dev, "ray_cs dl_startup_params - device not present\n");
 		return -1;
 	}
 
@@ -625,7 +616,7 @@ static int dl_startup_params(struct net_device *dev)
 	local->dl_param_ccs = ccsindex;
 	pccs = ccs_base(local) + ccsindex;
 	writeb(CCS_DOWNLOAD_STARTUP_PARAMS, &pccs->cmd);
-	DEBUG(2, "dl_startup_params start ccsindex = %d\n",
+	dev_dbg(&link->dev, "dl_startup_params start ccsindex = %d\n",
 	      local->dl_param_ccs);
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
@@ -641,7 +632,7 @@ static int dl_startup_params(struct net_device *dev)
 	local->timer.data = (long)local;
 	local->timer.function = &verify_dl_startup;
 	add_timer(&local->timer);
-	DEBUG(2,
+	dev_dbg(&link->dev,
 	      "ray_cs dl_startup_params started timer for verify_dl_startup\n");
 	return 0;
 } /* dl_startup_params */
@@ -717,11 +708,11 @@ static void verify_dl_startup(u_long data)
 	struct pcmcia_device *link = local->finder;
 
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs verify_dl_startup - device not present\n");
+		dev_dbg(&link->dev, "ray_cs verify_dl_startup - device not present\n");
 		return;
 	}
-#ifdef PCMCIA_DEBUG
-	if (pc_debug > 2) {
+#if 0
+	{
 		int i;
 		printk(KERN_DEBUG
 		       "verify_dl_startup parameters sent via ccs %d:\n",
@@ -760,7 +751,7 @@ static void start_net(u_long data)
 	int ccsindex;
 	struct pcmcia_device *link = local->finder;
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs start_net - device not present\n");
+		dev_dbg(&link->dev, "ray_cs start_net - device not present\n");
 		return;
 	}
 	/* Fill in the CCS fields for the ECF */
@@ -771,7 +762,7 @@ static void start_net(u_long data)
 	writeb(0, &pccs->var.start_network.update_param);
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
-		DEBUG(1, "ray start net failed - card not ready for intr\n");
+		dev_dbg(&link->dev, "ray start net failed - card not ready for intr\n");
 		writeb(CCS_BUFFER_FREE, &(pccs++)->buffer_status);
 		return;
 	}
@@ -790,7 +781,7 @@ static void join_net(u_long data)
 	struct pcmcia_device *link = local->finder;
 
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs join_net - device not present\n");
+		dev_dbg(&link->dev, "ray_cs join_net - device not present\n");
 		return;
 	}
 	/* Fill in the CCS fields for the ECF */
@@ -802,7 +793,7 @@ static void join_net(u_long data)
 	writeb(0, &pccs->var.join_network.net_initiated);
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
-		DEBUG(1, "ray join net failed - card not ready for intr\n");
+		dev_dbg(&link->dev, "ray join net failed - card not ready for intr\n");
 		writeb(CCS_BUFFER_FREE, &(pccs++)->buffer_status);
 		return;
 	}
@@ -821,7 +812,7 @@ static void ray_release(struct pcmcia_device *link)
 	ray_dev_t *local = netdev_priv(dev);
 	int i;
 
-	DEBUG(1, "ray_release(0x%p)\n", link);
+	dev_dbg(&link->dev, "ray_release\n");
 
 	del_timer(&local->timer);
 
@@ -831,13 +822,13 @@ static void ray_release(struct pcmcia_device *link)
 	/* Do bother checking to see if these succeed or not */
 	i = pcmcia_release_window(local->amem_handle);
 	if (i != 0)
-		DEBUG(0, "ReleaseWindow(local->amem) ret = %x\n", i);
+		dev_dbg(&link->dev, "ReleaseWindow(local->amem) ret = %x\n", i);
 	i = pcmcia_release_window(local->rmem_handle);
 	if (i != 0)
-		DEBUG(0, "ReleaseWindow(local->rmem) ret = %x\n", i);
+		dev_dbg(&link->dev, "ReleaseWindow(local->rmem) ret = %x\n", i);
 	pcmcia_disable_device(link);
 
-	DEBUG(2, "ray_release ending\n");
+	dev_dbg(&link->dev, "ray_release ending\n");
 }
 
 static int ray_suspend(struct pcmcia_device *link)
@@ -871,9 +862,9 @@ static int ray_dev_init(struct net_device *dev)
 	ray_dev_t *local = netdev_priv(dev);
 	struct pcmcia_device *link = local->finder;
 
-	DEBUG(1, "ray_dev_init(dev=%p)\n", dev);
+	dev_dbg(&link->dev, "ray_dev_init(dev=%p)\n", dev);
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_dev_init - device not present\n");
+		dev_dbg(&link->dev, "ray_dev_init - device not present\n");
 		return -1;
 	}
 #ifdef RAY_IMMEDIATE_INIT
@@ -887,7 +878,7 @@ static int ray_dev_init(struct net_device *dev)
 	/* Postpone the card init so that we can still configure the card,
 	 * for example using the Wireless Extensions. The init will happen
 	 * in ray_open() - Jean II */
-	DEBUG(1,
+	dev_dbg(&link->dev,
 	      "ray_dev_init: postponing card init to ray_open() ; Status = %d\n",
 	      local->card_status);
 #endif /* RAY_IMMEDIATE_INIT */
@@ -896,7 +887,7 @@ static int ray_dev_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &local->sparm.b4.a_mac_addr, ADDRLEN);
 	memset(dev->broadcast, 0xff, ETH_ALEN);
 
-	DEBUG(2, "ray_dev_init ending\n");
+	dev_dbg(&link->dev, "ray_dev_init ending\n");
 	return 0;
 }
 
@@ -906,9 +897,9 @@ static int ray_dev_config(struct net_device *dev, struct ifmap *map)
 	ray_dev_t *local = netdev_priv(dev);
 	struct pcmcia_device *link = local->finder;
 	/* Dummy routine to satisfy device structure */
-	DEBUG(1, "ray_dev_config(dev=%p,ifmap=%p)\n", dev, map);
+	dev_dbg(&link->dev, "ray_dev_config(dev=%p,ifmap=%p)\n", dev, map);
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_dev_config - device not present\n");
+		dev_dbg(&link->dev, "ray_dev_config - device not present\n");
 		return -1;
 	}
 
@@ -924,14 +915,14 @@ static netdev_tx_t ray_dev_start_xmit(struct sk_buff *skb,
 	short length = skb->len;
 
 	if (!pcmcia_dev_present(link)) {
-		DEBUG(2, "ray_dev_start_xmit - device not present\n");
+		dev_dbg(&link->dev, "ray_dev_start_xmit - device not present\n");
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
-	DEBUG(3, "ray_dev_start_xmit(skb=%p, dev=%p)\n", skb, dev);
+	dev_dbg(&link->dev, "ray_dev_start_xmit(skb=%p, dev=%p)\n", skb, dev);
 	if (local->authentication_state == NEED_TO_AUTH) {
-		DEBUG(0, "ray_cs Sending authentication request.\n");
+		dev_dbg(&link->dev, "ray_cs Sending authentication request.\n");
 		if (!build_auth_frame(local, local->auth_id, OPEN_AUTH_REQUEST)) {
 			local->authentication_state = AUTHENTICATED;
 			netif_stop_queue(dev);
@@ -971,7 +962,7 @@ static int ray_hw_xmit(unsigned char *data, int len, struct net_device *dev,
 	struct tx_msg __iomem *ptx;	/* Address of xmit buffer in PC space */
 	short int addr;		/* Address of xmit buffer in card space */
 
-	DEBUG(3, "ray_hw_xmit(data=%p, len=%d, dev=%p)\n", data, len, dev);
+	pr_debug("ray_hw_xmit(data=%p, len=%d, dev=%p)\n", data, len, dev);
 	if (len + TX_HEADER_LENGTH > TX_BUF_SIZE) {
 		printk(KERN_INFO "ray_hw_xmit packet too large: %d bytes\n",
 		       len);
@@ -979,9 +970,9 @@ static int ray_hw_xmit(unsigned char *data, int len, struct net_device *dev,
 	}
 	switch (ccsindex = get_free_tx_ccs(local)) {
 	case ECCSBUSY:
-		DEBUG(2, "ray_hw_xmit tx_ccs table busy\n");
+		pr_debug("ray_hw_xmit tx_ccs table busy\n");
 	case ECCSFULL:
-		DEBUG(2, "ray_hw_xmit No free tx ccs\n");
+		pr_debug("ray_hw_xmit No free tx ccs\n");
 	case ECARDGONE:
 		netif_stop_queue(dev);
 		return XMIT_NO_CCS;
@@ -1018,12 +1009,12 @@ static int ray_hw_xmit(unsigned char *data, int len, struct net_device *dev,
 	writeb(PSM_CAM, &pccs->var.tx_request.pow_sav_mode);
 	writeb(local->net_default_tx_rate, &pccs->var.tx_request.tx_rate);
 	writeb(0, &pccs->var.tx_request.antenna);
-	DEBUG(3, "ray_hw_xmit default_tx_rate = 0x%x\n",
+	pr_debug("ray_hw_xmit default_tx_rate = 0x%x\n",
 	      local->net_default_tx_rate);
 
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
-		DEBUG(2, "ray_hw_xmit failed - ECF not ready for intr\n");
+		pr_debug("ray_hw_xmit failed - ECF not ready for intr\n");
 /* TBD very inefficient to copy packet to buffer, and then not
    send it, but the alternative is to queue the messages and that
    won't be done for a while.  Maybe set tbusy until a CCS is free?
@@ -1040,7 +1031,7 @@ static int translate_frame(ray_dev_t *local, struct tx_msg __iomem *ptx,
 {
 	__be16 proto = ((struct ethhdr *)data)->h_proto;
 	if (ntohs(proto) >= 1536) { /* DIX II ethernet frame */
-		DEBUG(3, "ray_cs translate_frame DIX II\n");
+		pr_debug("ray_cs translate_frame DIX II\n");
 		/* Copy LLC header to card buffer */
 		memcpy_toio(&ptx->var, eth2_llc, sizeof(eth2_llc));
 		memcpy_toio(((void __iomem *)&ptx->var) + sizeof(eth2_llc),
@@ -1056,9 +1047,9 @@ static int translate_frame(ray_dev_t *local, struct tx_msg __iomem *ptx,
 			    len - ETH_HLEN);
 		return (int)sizeof(struct snaphdr_t) - ETH_HLEN;
 	} else { /* already  802 type, and proto is length */
-		DEBUG(3, "ray_cs translate_frame 802\n");
+		pr_debug("ray_cs translate_frame 802\n");
 		if (proto == htons(0xffff)) { /* evil netware IPX 802.3 without LLC */
-			DEBUG(3, "ray_cs translate_frame evil IPX\n");
+			pr_debug("ray_cs translate_frame evil IPX\n");
 			memcpy_toio(&ptx->var, data + ETH_HLEN, len - ETH_HLEN);
 			return 0 - ETH_HLEN;
 		}
@@ -1603,7 +1594,7 @@ static int ray_open(struct net_device *dev)
 	struct pcmcia_device *link;
 	link = local->finder;
 
-	DEBUG(1, "ray_open('%s')\n", dev->name);
+	dev_dbg(&link->dev, "ray_open('%s')\n", dev->name);
 
 	if (link->open == 0)
 		local->num_multi = 0;
@@ -1613,7 +1604,7 @@ static int ray_open(struct net_device *dev)
 	if (local->card_status == CARD_AWAITING_PARAM) {
 		int i;
 
-		DEBUG(1, "ray_open: doing init now !\n");
+		dev_dbg(&link->dev, "ray_open: doing init now !\n");
 
 		/* Download startup parameters */
 		if ((i = dl_startup_params(dev)) < 0) {
@@ -1629,7 +1620,7 @@ static int ray_open(struct net_device *dev)
 	else
 		netif_start_queue(dev);
 
-	DEBUG(2, "ray_open ending\n");
+	dev_dbg(&link->dev, "ray_open ending\n");
 	return 0;
 } /* end ray_open */
 
@@ -1640,7 +1631,7 @@ static int ray_dev_close(struct net_device *dev)
 	struct pcmcia_device *link;
 	link = local->finder;
 
-	DEBUG(1, "ray_dev_close('%s')\n", dev->name);
+	dev_dbg(&link->dev, "ray_dev_close('%s')\n", dev->name);
 
 	link->open--;
 	netif_stop_queue(dev);
@@ -1656,7 +1647,7 @@ static int ray_dev_close(struct net_device *dev)
 /*===========================================================================*/
 static void ray_reset(struct net_device *dev)
 {
-	DEBUG(1, "ray_reset entered\n");
+	pr_debug("ray_reset entered\n");
 	return;
 }
 
@@ -1669,17 +1660,17 @@ static int interrupt_ecf(ray_dev_t *local, int ccs)
 	struct pcmcia_device *link = local->finder;
 
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs interrupt_ecf - device not present\n");
+		dev_dbg(&link->dev, "ray_cs interrupt_ecf - device not present\n");
 		return -1;
 	}
-	DEBUG(2, "interrupt_ecf(local=%p, ccs = 0x%x\n", local, ccs);
+	dev_dbg(&link->dev, "interrupt_ecf(local=%p, ccs = 0x%x\n", local, ccs);
 
 	while (i &&
 	       (readb(local->amem + CIS_OFFSET + ECF_INTR_OFFSET) &
 		ECF_INTR_SET))
 		i--;
 	if (i == 0) {
-		DEBUG(2, "ray_cs interrupt_ecf card not ready for interrupt\n");
+		dev_dbg(&link->dev, "ray_cs interrupt_ecf card not ready for interrupt\n");
 		return -1;
 	}
 	/* Fill the mailbox, then kick the card */
@@ -1698,12 +1689,12 @@ static int get_free_tx_ccs(ray_dev_t *local)
 	struct pcmcia_device *link = local->finder;
 
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs get_free_tx_ccs - device not present\n");
+		dev_dbg(&link->dev, "ray_cs get_free_tx_ccs - device not present\n");
 		return ECARDGONE;
 	}
 
 	if (test_and_set_bit(0, &local->tx_ccs_lock)) {
-		DEBUG(1, "ray_cs tx_ccs_lock busy\n");
+		dev_dbg(&link->dev, "ray_cs tx_ccs_lock busy\n");
 		return ECCSBUSY;
 	}
 
@@ -1716,7 +1707,7 @@ static int get_free_tx_ccs(ray_dev_t *local)
 		}
 	}
 	local->tx_ccs_lock = 0;
-	DEBUG(2, "ray_cs ERROR no free tx CCS for raylink card\n");
+	dev_dbg(&link->dev, "ray_cs ERROR no free tx CCS for raylink card\n");
 	return ECCSFULL;
 } /* get_free_tx_ccs */
 
@@ -1730,11 +1721,11 @@ static int get_free_ccs(ray_dev_t *local)
 	struct pcmcia_device *link = local->finder;
 
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs get_free_ccs - device not present\n");
+		dev_dbg(&link->dev, "ray_cs get_free_ccs - device not present\n");
 		return ECARDGONE;
 	}
 	if (test_and_set_bit(0, &local->ccs_lock)) {
-		DEBUG(1, "ray_cs ccs_lock busy\n");
+		dev_dbg(&link->dev, "ray_cs ccs_lock busy\n");
 		return ECCSBUSY;
 	}
 
@@ -1747,7 +1738,7 @@ static int get_free_ccs(ray_dev_t *local)
 		}
 	}
 	local->ccs_lock = 0;
-	DEBUG(1, "ray_cs ERROR no free CCS for raylink card\n");
+	dev_dbg(&link->dev, "ray_cs ERROR no free CCS for raylink card\n");
 	return ECCSFULL;
 } /* get_free_ccs */
 
@@ -1823,7 +1814,7 @@ static struct net_device_stats *ray_get_stats(struct net_device *dev)
 	struct pcmcia_device *link = local->finder;
 	struct status __iomem *p = local->sram + STATUS_BASE;
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs net_device_stats - device not present\n");
+		dev_dbg(&link->dev, "ray_cs net_device_stats - device not present\n");
 		return &local->stats;
 	}
 	if (readb(&p->mrx_overflow_for_host)) {
@@ -1856,12 +1847,12 @@ static void ray_update_parm(struct net_device *dev, UCHAR objid, UCHAR *value,
 	struct ccs __iomem *pccs;
 
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_update_parm - device not present\n");
+		dev_dbg(&link->dev, "ray_update_parm - device not present\n");
 		return;
 	}
 
 	if ((ccsindex = get_free_ccs(local)) < 0) {
-		DEBUG(0, "ray_update_parm - No free ccs\n");
+		dev_dbg(&link->dev, "ray_update_parm - No free ccs\n");
 		return;
 	}
 	pccs = ccs_base(local) + ccsindex;
@@ -1874,7 +1865,7 @@ static void ray_update_parm(struct net_device *dev, UCHAR objid, UCHAR *value,
 	}
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
-		DEBUG(0, "ray_cs associate failed - ECF not ready for intr\n");
+		dev_dbg(&link->dev, "ray_cs associate failed - ECF not ready for intr\n");
 		writeb(CCS_BUFFER_FREE, &(pccs++)->buffer_status);
 	}
 }
@@ -1891,12 +1882,12 @@ static void ray_update_multi_list(struct net_device *dev, int all)
 	void __iomem *p = local->sram + HOST_TO_ECF_BASE;
 
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_update_multi_list - device not present\n");
+		dev_dbg(&link->dev, "ray_update_multi_list - device not present\n");
 		return;
 	} else
-		DEBUG(2, "ray_update_multi_list(%p)\n", dev);
+		dev_dbg(&link->dev, "ray_update_multi_list(%p)\n", dev);
 	if ((ccsindex = get_free_ccs(local)) < 0) {
-		DEBUG(1, "ray_update_multi - No free ccs\n");
+		dev_dbg(&link->dev, "ray_update_multi - No free ccs\n");
 		return;
 	}
 	pccs = ccs_base(local) + ccsindex;
@@ -1910,7 +1901,7 @@ static void ray_update_multi_list(struct net_device *dev, int all)
 		for (dmip = &dev->mc_list; (dmi = *dmip) != NULL;
 		     dmip = &dmi->next) {
 			memcpy_toio(p, dmi->dmi_addr, ETH_ALEN);
-			DEBUG(1,
+			dev_dbg(&link->dev,
 			      "ray_update_multi add addr %02x%02x%02x%02x%02x%02x\n",
 			      dmi->dmi_addr[0], dmi->dmi_addr[1],
 			      dmi->dmi_addr[2], dmi->dmi_addr[3],
@@ -1921,12 +1912,12 @@ static void ray_update_multi_list(struct net_device *dev, int all)
 		if (i > 256 / ADDRLEN)
 			i = 256 / ADDRLEN;
 		writeb((UCHAR) i, &pccs->var);
-		DEBUG(1, "ray_cs update_multi %d addresses in list\n", i);
+		dev_dbg(&link->dev, "ray_cs update_multi %d addresses in list\n", i);
 		/* Interrupt the firmware to process the command */
 		local->num_multi = i;
 	}
 	if (interrupt_ecf(local, ccsindex)) {
-		DEBUG(1,
+		dev_dbg(&link->dev,
 		      "ray_cs update_multi failed - ECF not ready for intr\n");
 		writeb(CCS_BUFFER_FREE, &(pccs++)->buffer_status);
 	}
@@ -1938,11 +1929,11 @@ static void set_multicast_list(struct net_device *dev)
 	ray_dev_t *local = netdev_priv(dev);
 	UCHAR promisc;
 
-	DEBUG(2, "ray_cs set_multicast_list(%p)\n", dev);
+	pr_debug("ray_cs set_multicast_list(%p)\n", dev);
 
 	if (dev->flags & IFF_PROMISC) {
 		if (local->sparm.b5.a_promiscuous_mode == 0) {
-			DEBUG(1, "ray_cs set_multicast_list promisc on\n");
+			pr_debug("ray_cs set_multicast_list promisc on\n");
 			local->sparm.b5.a_promiscuous_mode = 1;
 			promisc = 1;
 			ray_update_parm(dev, OBJID_promiscuous_mode,
@@ -1950,7 +1941,7 @@ static void set_multicast_list(struct net_device *dev)
 		}
 	} else {
 		if (local->sparm.b5.a_promiscuous_mode == 1) {
-			DEBUG(1, "ray_cs set_multicast_list promisc off\n");
+			pr_debug("ray_cs set_multicast_list promisc off\n");
 			local->sparm.b5.a_promiscuous_mode = 0;
 			promisc = 0;
 			ray_update_parm(dev, OBJID_promiscuous_mode,
@@ -1984,19 +1975,19 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 	if (dev == NULL)	/* Note that we want interrupts with dev->start == 0 */
 		return IRQ_NONE;
 
-	DEBUG(4, "ray_cs: interrupt for *dev=%p\n", dev);
+	pr_debug("ray_cs: interrupt for *dev=%p\n", dev);
 
 	local = netdev_priv(dev);
 	link = (struct pcmcia_device *)local->finder;
 	if (!pcmcia_dev_present(link)) {
-		DEBUG(2,
-		      "ray_cs interrupt from device not present or suspended.\n");
+		pr_debug(
+			"ray_cs interrupt from device not present or suspended.\n");
 		return IRQ_NONE;
 	}
 	rcsindex = readb(&((struct scb __iomem *)(local->sram))->rcs_index);
 
 	if (rcsindex >= (NUMBER_OF_CCS + NUMBER_OF_RCS)) {
-		DEBUG(1, "ray_cs interrupt bad rcsindex = 0x%x\n", rcsindex);
+		dev_dbg(&link->dev, "ray_cs interrupt bad rcsindex = 0x%x\n", rcsindex);
 		clear_interrupt(local);
 		return IRQ_HANDLED;
 	}
@@ -2008,33 +1999,33 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 		case CCS_DOWNLOAD_STARTUP_PARAMS:	/* Happens in firmware someday */
 			del_timer(&local->timer);
 			if (status == CCS_COMMAND_COMPLETE) {
-				DEBUG(1,
+				dev_dbg(&link->dev,
 				      "ray_cs interrupt download_startup_parameters OK\n");
 			} else {
-				DEBUG(1,
+				dev_dbg(&link->dev,
 				      "ray_cs interrupt download_startup_parameters fail\n");
 			}
 			break;
 		case CCS_UPDATE_PARAMS:
-			DEBUG(1, "ray_cs interrupt update params done\n");
+			dev_dbg(&link->dev, "ray_cs interrupt update params done\n");
 			if (status != CCS_COMMAND_COMPLETE) {
 				tmp =
 				    readb(&pccs->var.update_param.
 					  failure_cause);
-				DEBUG(0,
+				dev_dbg(&link->dev,
 				      "ray_cs interrupt update params failed - reason %d\n",
 				      tmp);
 			}
 			break;
 		case CCS_REPORT_PARAMS:
-			DEBUG(1, "ray_cs interrupt report params done\n");
+			dev_dbg(&link->dev, "ray_cs interrupt report params done\n");
 			break;
 		case CCS_UPDATE_MULTICAST_LIST:	/* Note that this CCS isn't returned */
-			DEBUG(1,
+			dev_dbg(&link->dev,
 			      "ray_cs interrupt CCS Update Multicast List done\n");
 			break;
 		case CCS_UPDATE_POWER_SAVINGS_MODE:
-			DEBUG(1,
+			dev_dbg(&link->dev,
 			      "ray_cs interrupt update power save mode done\n");
 			break;
 		case CCS_START_NETWORK:
@@ -2043,11 +2034,11 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 				if (readb
 				    (&pccs->var.start_network.net_initiated) ==
 				    1) {
-					DEBUG(0,
+					dev_dbg(&link->dev,
 					      "ray_cs interrupt network \"%s\" started\n",
 					      local->sparm.b4.a_current_ess_id);
 				} else {
-					DEBUG(0,
+					dev_dbg(&link->dev,
 					      "ray_cs interrupt network \"%s\" joined\n",
 					      local->sparm.b4.a_current_ess_id);
 				}
@@ -2075,12 +2066,12 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 				local->timer.expires = jiffies + HZ * 5;
 				local->timer.data = (long)local;
 				if (status == CCS_START_NETWORK) {
-					DEBUG(0,
+					dev_dbg(&link->dev,
 					      "ray_cs interrupt network \"%s\" start failed\n",
 					      local->sparm.b4.a_current_ess_id);
 					local->timer.function = &start_net;
 				} else {
-					DEBUG(0,
+					dev_dbg(&link->dev,
 					      "ray_cs interrupt network \"%s\" join failed\n",
 					      local->sparm.b4.a_current_ess_id);
 					local->timer.function = &join_net;
@@ -2091,19 +2082,19 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 		case CCS_START_ASSOCIATION:
 			if (status == CCS_COMMAND_COMPLETE) {
 				local->card_status = CARD_ASSOC_COMPLETE;
-				DEBUG(0, "ray_cs association successful\n");
+				dev_dbg(&link->dev, "ray_cs association successful\n");
 			} else {
-				DEBUG(0, "ray_cs association failed,\n");
+				dev_dbg(&link->dev, "ray_cs association failed,\n");
 				local->card_status = CARD_ASSOC_FAILED;
 				join_net((u_long) local);
 			}
 			break;
 		case CCS_TX_REQUEST:
 			if (status == CCS_COMMAND_COMPLETE) {
-				DEBUG(3,
+				dev_dbg(&link->dev,
 				      "ray_cs interrupt tx request complete\n");
 			} else {
-				DEBUG(1,
+				dev_dbg(&link->dev,
 				      "ray_cs interrupt tx request failed\n");
 			}
 			if (!sniffer)
@@ -2111,21 +2102,21 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 			netif_wake_queue(dev);
 			break;
 		case CCS_TEST_MEMORY:
-			DEBUG(1, "ray_cs interrupt mem test done\n");
+			dev_dbg(&link->dev, "ray_cs interrupt mem test done\n");
 			break;
 		case CCS_SHUTDOWN:
-			DEBUG(1,
+			dev_dbg(&link->dev,
 			      "ray_cs interrupt Unexpected CCS returned - Shutdown\n");
 			break;
 		case CCS_DUMP_MEMORY:
-			DEBUG(1, "ray_cs interrupt dump memory done\n");
+			dev_dbg(&link->dev, "ray_cs interrupt dump memory done\n");
 			break;
 		case CCS_START_TIMER:
-			DEBUG(2,
+			dev_dbg(&link->dev,
 			      "ray_cs interrupt DING - raylink timer expired\n");
 			break;
 		default:
-			DEBUG(1,
+			dev_dbg(&link->dev,
 			      "ray_cs interrupt Unexpected CCS 0x%x returned 0x%x\n",
 			      rcsindex, cmd);
 		}
@@ -2139,7 +2130,7 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 			ray_rx(dev, local, prcs);
 			break;
 		case REJOIN_NET_COMPLETE:
-			DEBUG(1, "ray_cs interrupt rejoin net complete\n");
+			dev_dbg(&link->dev, "ray_cs interrupt rejoin net complete\n");
 			local->card_status = CARD_ACQ_COMPLETE;
 			/* do we need to clear tx buffers CCS's? */
 			if (local->sparm.b4.a_network_type == ADHOC) {
@@ -2149,7 +2140,7 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 				memcpy_fromio(&local->bss_id,
 					      prcs->var.rejoin_net_complete.
 					      bssid, ADDRLEN);
-				DEBUG(1,
+				dev_dbg(&link->dev,
 				      "ray_cs new BSSID = %02x%02x%02x%02x%02x%02x\n",
 				      local->bss_id[0], local->bss_id[1],
 				      local->bss_id[2], local->bss_id[3],
@@ -2159,15 +2150,15 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 			}
 			break;
 		case ROAMING_INITIATED:
-			DEBUG(1, "ray_cs interrupt roaming initiated\n");
+			dev_dbg(&link->dev, "ray_cs interrupt roaming initiated\n");
 			netif_stop_queue(dev);
 			local->card_status = CARD_DOING_ACQ;
 			break;
 		case JAPAN_CALL_SIGN_RXD:
-			DEBUG(1, "ray_cs interrupt japan call sign rx\n");
+			dev_dbg(&link->dev, "ray_cs interrupt japan call sign rx\n");
 			break;
 		default:
-			DEBUG(1,
+			dev_dbg(&link->dev,
 			      "ray_cs Unexpected interrupt for RCS 0x%x cmd = 0x%x\n",
 			      rcsindex,
 			      (unsigned int)readb(&prcs->interrupt_id));
@@ -2186,7 +2177,7 @@ static void ray_rx(struct net_device *dev, ray_dev_t *local,
 	int rx_len;
 	unsigned int pkt_addr;
 	void __iomem *pmsg;
-	DEBUG(4, "ray_rx process rx packet\n");
+	pr_debug("ray_rx process rx packet\n");
 
 	/* Calculate address of packet within Rx buffer */
 	pkt_addr = ((readb(&prcs->var.rx_packet.rx_data_ptr[0]) << 8)
@@ -2199,28 +2190,28 @@ static void ray_rx(struct net_device *dev, ray_dev_t *local,
 	pmsg = local->rmem + pkt_addr;
 	switch (readb(pmsg)) {
 	case DATA_TYPE:
-		DEBUG(4, "ray_rx data type\n");
+		pr_debug("ray_rx data type\n");
 		rx_data(dev, prcs, pkt_addr, rx_len);
 		break;
 	case AUTHENTIC_TYPE:
-		DEBUG(4, "ray_rx authentic type\n");
+		pr_debug("ray_rx authentic type\n");
 		if (sniffer)
 			rx_data(dev, prcs, pkt_addr, rx_len);
 		else
 			rx_authenticate(local, prcs, pkt_addr, rx_len);
 		break;
 	case DEAUTHENTIC_TYPE:
-		DEBUG(4, "ray_rx deauth type\n");
+		pr_debug("ray_rx deauth type\n");
 		if (sniffer)
 			rx_data(dev, prcs, pkt_addr, rx_len);
 		else
 			rx_deauthenticate(local, prcs, pkt_addr, rx_len);
 		break;
 	case NULL_MSG_TYPE:
-		DEBUG(3, "ray_cs rx NULL msg\n");
+		pr_debug("ray_cs rx NULL msg\n");
 		break;
 	case BEACON_TYPE:
-		DEBUG(4, "ray_rx beacon type\n");
+		pr_debug("ray_rx beacon type\n");
 		if (sniffer)
 			rx_data(dev, prcs, pkt_addr, rx_len);
 
@@ -2233,7 +2224,7 @@ static void ray_rx(struct net_device *dev, ray_dev_t *local,
 		ray_get_stats(dev);
 		break;
 	default:
-		DEBUG(0, "ray_cs unknown pkt type %2x\n",
+		pr_debug("ray_cs unknown pkt type %2x\n",
 		      (unsigned int)readb(pmsg));
 		break;
 	}
@@ -2262,7 +2253,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 			    rx_len >
 			    (dev->mtu + RX_MAC_HEADER_LENGTH + ETH_HLEN +
 			     FCS_LEN)) {
-				DEBUG(0,
+				pr_debug(
 				      "ray_cs invalid packet length %d received \n",
 				      rx_len);
 				return;
@@ -2273,17 +2264,17 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 			    rx_len >
 			    (dev->mtu + RX_MAC_HEADER_LENGTH + ETH_HLEN +
 			     FCS_LEN)) {
-				DEBUG(0,
+				pr_debug(
 				      "ray_cs invalid packet length %d received \n",
 				      rx_len);
 				return;
 			}
 		}
 	}
-	DEBUG(4, "ray_cs rx_data packet\n");
+	pr_debug("ray_cs rx_data packet\n");
 	/* If fragmented packet, verify sizes of fragments add up */
 	if (readb(&prcs->var.rx_packet.next_frag_rcs_index) != 0xFF) {
-		DEBUG(1, "ray_cs rx'ed fragment\n");
+		pr_debug("ray_cs rx'ed fragment\n");
 		tmp = (readb(&prcs->var.rx_packet.totalpacketlength[0]) << 8)
 		    + readb(&prcs->var.rx_packet.totalpacketlength[1]);
 		total_len = tmp;
@@ -2301,7 +2292,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 		} while (1);
 
 		if (tmp < 0) {
-			DEBUG(0,
+			pr_debug(
 			      "ray_cs rx_data fragment lengths don't add up\n");
 			local->stats.rx_dropped++;
 			release_frag_chain(local, prcs);
@@ -2313,7 +2304,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 
 	skb = dev_alloc_skb(total_len + 5);
 	if (skb == NULL) {
-		DEBUG(0, "ray_cs rx_data could not allocate skb\n");
+		pr_debug("ray_cs rx_data could not allocate skb\n");
 		local->stats.rx_dropped++;
 		if (readb(&prcs->var.rx_packet.next_frag_rcs_index) != 0xFF)
 			release_frag_chain(local, prcs);
@@ -2321,7 +2312,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 	}
 	skb_reserve(skb, 2);	/* Align IP on 16 byte (TBD check this) */
 
-	DEBUG(4, "ray_cs rx_data total_len = %x, rx_len = %x\n", total_len,
+	pr_debug("ray_cs rx_data total_len = %x, rx_len = %x\n", total_len,
 	      rx_len);
 
 /************************/
@@ -2354,7 +2345,7 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs,
 	tmp = 17;
 	if (readb(&prcs->var.rx_packet.next_frag_rcs_index) != 0xFF) {
 		prcslink = prcs;
-		DEBUG(1, "ray_cs rx_data in fragment loop\n");
+		pr_debug("ray_cs rx_data in fragment loop\n");
 		do {
 			prcslink = rcs_base(local)
 			    +
@@ -2426,8 +2417,8 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 	memcpy(destaddr, ieee80211_get_DA(pmac), ADDRLEN);
 	memcpy(srcaddr, ieee80211_get_SA(pmac), ADDRLEN);
 
-#ifdef PCMCIA_DEBUG
-	if (pc_debug > 3) {
+#if 0
+	if {
 		print_hex_dump(KERN_DEBUG, "skb->data before untranslate: ",
 			       DUMP_PREFIX_NONE, 16, 1,
 			       skb->data, 64, true);
@@ -2441,7 +2432,7 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 
 	if (psnap->dsap != 0xaa || psnap->ssap != 0xaa || psnap->ctrl != 3) {
 		/* not a snap type so leave it alone */
-		DEBUG(3, "ray_cs untranslate NOT SNAP %02x %02x %02x\n",
+		pr_debug("ray_cs untranslate NOT SNAP %02x %02x %02x\n",
 		      psnap->dsap, psnap->ssap, psnap->ctrl);
 
 		delta = RX_MAC_HEADER_LENGTH - ETH_HLEN;
@@ -2450,7 +2441,7 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 	} else { /* Its a SNAP */
 		if (memcmp(psnap->org, org_bridge, 3) == 0) {
 		/* EtherII and nuke the LLC */
-			DEBUG(3, "ray_cs untranslate Bridge encap\n");
+			pr_debug("ray_cs untranslate Bridge encap\n");
 			delta = RX_MAC_HEADER_LENGTH
 			    + sizeof(struct snaphdr_t) - ETH_HLEN;
 			peth = (struct ethhdr *)(skb->data + delta);
@@ -2459,14 +2450,14 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 			switch (ntohs(type)) {
 			case ETH_P_IPX:
 			case ETH_P_AARP:
-				DEBUG(3, "ray_cs untranslate RFC IPX/AARP\n");
+				pr_debug("ray_cs untranslate RFC IPX/AARP\n");
 				delta = RX_MAC_HEADER_LENGTH - ETH_HLEN;
 				peth = (struct ethhdr *)(skb->data + delta);
 				peth->h_proto =
 				    htons(len - RX_MAC_HEADER_LENGTH);
 				break;
 			default:
-				DEBUG(3, "ray_cs untranslate RFC default\n");
+				pr_debug("ray_cs untranslate RFC default\n");
 				delta = RX_MAC_HEADER_LENGTH +
 				    sizeof(struct snaphdr_t) - ETH_HLEN;
 				peth = (struct ethhdr *)(skb->data + delta);
@@ -2482,12 +2473,12 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 	}
 /* TBD reserve  skb_reserve(skb, delta); */
 	skb_pull(skb, delta);
-	DEBUG(3, "untranslate after skb_pull(%d), skb->data = %p\n", delta,
+	pr_debug("untranslate after skb_pull(%d), skb->data = %p\n", delta,
 	      skb->data);
 	memcpy(peth->h_dest, destaddr, ADDRLEN);
 	memcpy(peth->h_source, srcaddr, ADDRLEN);
-#ifdef PCMCIA_DEBUG
-	if (pc_debug > 3) {
+#if 0
+	{
 		int i;
 		printk(KERN_DEBUG "skb->data after untranslate:");
 		for (i = 0; i < 64; i++)
@@ -2529,7 +2520,7 @@ static void release_frag_chain(ray_dev_t *local, struct rcs __iomem *prcs)
 	while (tmp--) {
 		writeb(CCS_BUFFER_FREE, &prcslink->buffer_status);
 		if (rcsindex >= (NUMBER_OF_CCS + NUMBER_OF_RCS)) {
-			DEBUG(1, "ray_cs interrupt bad rcsindex = 0x%x\n",
+			pr_debug("ray_cs interrupt bad rcsindex = 0x%x\n",
 			      rcsindex);
 			break;
 		}
@@ -2543,9 +2534,9 @@ static void release_frag_chain(ray_dev_t *local, struct rcs __iomem *prcs)
 static void authenticate(ray_dev_t *local)
 {
 	struct pcmcia_device *link = local->finder;
-	DEBUG(0, "ray_cs Starting authentication.\n");
+	dev_dbg(&link->dev, "ray_cs Starting authentication.\n");
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs authenticate - device not present\n");
+		dev_dbg(&link->dev, "ray_cs authenticate - device not present\n");
 		return;
 	}
 
@@ -2573,11 +2564,11 @@ static void rx_authenticate(ray_dev_t *local, struct rcs __iomem *prcs,
 	copy_from_rx_buff(local, buff, pkt_addr, rx_len & 0xff);
 	/* if we are trying to get authenticated */
 	if (local->sparm.b4.a_network_type == ADHOC) {
-		DEBUG(1, "ray_cs rx_auth var= %02x %02x %02x %02x %02x %02x\n",
+		pr_debug("ray_cs rx_auth var= %02x %02x %02x %02x %02x %02x\n",
 		      msg->var[0], msg->var[1], msg->var[2], msg->var[3],
 		      msg->var[4], msg->var[5]);
 		if (msg->var[2] == 1) {
-			DEBUG(0, "ray_cs Sending authentication response.\n");
+			pr_debug("ray_cs Sending authentication response.\n");
 			if (!build_auth_frame
 			    (local, msg->mac.addr_2, OPEN_AUTH_RESPONSE)) {
 				local->authentication_state = NEED_TO_AUTH;
@@ -2591,13 +2582,13 @@ static void rx_authenticate(ray_dev_t *local, struct rcs __iomem *prcs,
 			/* Verify authentication sequence #2 and success */
 			if (msg->var[2] == 2) {
 				if ((msg->var[3] | msg->var[4]) == 0) {
-					DEBUG(1, "Authentication successful\n");
+					pr_debug("Authentication successful\n");
 					local->card_status = CARD_AUTH_COMPLETE;
 					associate(local);
 					local->authentication_state =
 					    AUTHENTICATED;
 				} else {
-					DEBUG(0, "Authentication refused\n");
+					pr_debug("Authentication refused\n");
 					local->card_status = CARD_AUTH_REFUSED;
 					join_net((u_long) local);
 					local->authentication_state =
@@ -2617,22 +2608,22 @@ static void associate(ray_dev_t *local)
 	struct net_device *dev = link->priv;
 	int ccsindex;
 	if (!(pcmcia_dev_present(link))) {
-		DEBUG(2, "ray_cs associate - device not present\n");
+		dev_dbg(&link->dev, "ray_cs associate - device not present\n");
 		return;
 	}
 	/* If no tx buffers available, return */
 	if ((ccsindex = get_free_ccs(local)) < 0) {
 /* TBD should never be here but... what if we are? */
-		DEBUG(1, "ray_cs associate - No free ccs\n");
+		dev_dbg(&link->dev, "ray_cs associate - No free ccs\n");
 		return;
 	}
-	DEBUG(1, "ray_cs Starting association with access point\n");
+	dev_dbg(&link->dev, "ray_cs Starting association with access point\n");
 	pccs = ccs_base(local) + ccsindex;
 	/* fill in the CCS */
 	writeb(CCS_START_ASSOCIATION, &pccs->cmd);
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
-		DEBUG(1, "ray_cs associate failed - ECF not ready for intr\n");
+		dev_dbg(&link->dev, "ray_cs associate failed - ECF not ready for intr\n");
 		writeb(CCS_BUFFER_FREE, &(pccs++)->buffer_status);
 
 		del_timer(&local->timer);
@@ -2655,7 +2646,7 @@ static void rx_deauthenticate(ray_dev_t *local, struct rcs __iomem *prcs,
 /*  UCHAR buff[256];
     struct rx_msg *msg = (struct rx_msg *)buff;
 */
-	DEBUG(0, "Deauthentication frame received\n");
+	pr_debug("Deauthentication frame received\n");
 	local->authentication_state = UNAUTHENTICATED;
 	/* Need to reauthenticate or rejoin depending on reason code */
 /*  copy_from_rx_buff(local, buff, pkt_addr, rx_len & 0xff);
@@ -2823,7 +2814,7 @@ static int build_auth_frame(ray_dev_t *local, UCHAR *dest, int auth_type)
 
 	/* If no tx buffers available, return */
 	if ((ccsindex = get_free_tx_ccs(local)) < 0) {
-		DEBUG(1, "ray_cs send authenticate - No free tx ccs\n");
+		pr_debug("ray_cs send authenticate - No free tx ccs\n");
 		return -1;
 	}
 
@@ -2855,7 +2846,7 @@ static int build_auth_frame(ray_dev_t *local, UCHAR *dest, int auth_type)
 
 	/* Interrupt the firmware to process the command */
 	if (interrupt_ecf(local, ccsindex)) {
-		DEBUG(1,
+		pr_debug(
 		      "ray_cs send authentication request failed - ECF not ready for intr\n");
 		writeb(CCS_BUFFER_FREE, &(pccs++)->buffer_status);
 		return -1;
@@ -2942,9 +2933,9 @@ static int __init init_ray_cs(void)
 {
 	int rc;
 
-	DEBUG(1, "%s\n", rcsid);
+	pr_debug("%s\n", rcsid);
 	rc = pcmcia_register_driver(&ray_driver);
-	DEBUG(1, "raylink init_module register_pcmcia_driver returns 0x%x\n",
+	pr_debug("raylink init_module register_pcmcia_driver returns 0x%x\n",
 	      rc);
 
 #ifdef CONFIG_PROC_FS
@@ -2964,7 +2955,7 @@ static int __init init_ray_cs(void)
 
 static void __exit exit_ray_cs(void)
 {
-	DEBUG(0, "ray_cs: cleanup_module\n");
+	pr_debug("ray_cs: cleanup_module\n");
 
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry("driver/ray_cs/ray_cs", NULL);
-- 
1.6.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
