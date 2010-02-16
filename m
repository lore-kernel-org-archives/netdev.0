From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v2 04/12] net-caif: add CAIF Link layer device
 header files
Date: Tue, 16 Feb 2010 14:46:49 +0100
Message-ID: <1266328017-28406-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1266328017-28406-1-git-send-email-sjur.brandeland@stericsson.com>
 <1266328017-28406-2-git-send-email-sjur.brandeland@stericsson.com>
 <1266328017-28406-3-git-send-email-sjur.brandeland@stericsson.com>
 <1266328017-28406-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	daniel.martensson@stericsson.com, kaber@trash.net,
	marcel@holtmann.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:56525 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659Ab0BPNrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 08:47:40 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KXX00066SZ1VAD0@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Tue, 16 Feb 2010 14:47:27 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KXX00DUYSYQXZJ0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Tue, 16 Feb 2010 14:47:22 +0100 (CET)
In-reply-to: <1266328017-28406-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Header files for CAIF Link layer net-device,
and link-layer registration.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h    |   65 ++++++++++++++++++++++++++++++++++++++++
 include/net/caif/caif_device.h |   57 +++++++++++++++++++++++++++++++++++
 2 files changed, 122 insertions(+), 0 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
new file mode 100644
index 0000000..a85e632
--- /dev/null
+++ b/include/net/caif/caif_dev.h
@@ -0,0 +1,65 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_DEV_H_
+#define CAIF_DEV_H_
+
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfcnfg.h>
+#include <linux/caif/caif_config.h>
+#include <linux/if.h>
+
+struct caif_service_config;
+
+/**
+ * caif_connect_client - Connect a client to CAIF Core Stack.
+ * @config:		Channel setup parameters, specifying what address
+ *                      to connect on the Modem.
+ * @client_layer:	User implementation of client layer. This layer
+ *                      MUST have receive and control callback functions
+ *                      implemented.
+ *
+ * This function connects a CAIF channel. The Client must implement
+ * the struct layer. This layer represents the Client layer and holds
+ * receive functions and control callback functions. Control callback
+ * function will receive information about connect/disconnect responses,
+ * flow control etc (see enum caif_control).
+ * E.g. CAIF Socket will call this function for each socket it connects
+ * and have one client_layer instance for each socket.
+ */
+int caif_connect_client(struct caif_channel_config *config,
+			   struct layer *client_layer);
+
+/**
+ * caif_disconnect_client - Disconnects a client from the CAIF stack.
+ *
+ * @client_layer: Client layer to be removed.
+ */
+int caif_disconnect_client(struct layer *client_layer);
+
+
+/**
+ * channel_config_2_link_param - Translate configuration parameters
+ * 				 from external to internal format.
+ *
+ * @cnfg: 	Pointer to configuration handler
+ * @config: 	Configuration parameters supplied in function
+ *		caif_connect_client
+ * @channel_setup_param: Parameters supplied to the CAIF Core stack for
+ *			 setting up channels.
+ *
+ */
+int channel_config_2_link_param(struct cfcnfg *cnfg,
+				struct caif_channel_config *config,
+				struct cfctrl_link_param *channel_setup_param);
+
+/**
+ * get_caif_conf() - Get the configuration handler.
+ */
+struct cfcnfg *get_caif_conf(void);
+
+
+#endif /* CAIF_DEV_H_ */
diff --git a/include/net/caif/caif_device.h b/include/net/caif/caif_device.h
new file mode 100644
index 0000000..ba22ee5
--- /dev/null
+++ b/include/net/caif/caif_device.h
@@ -0,0 +1,57 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_DEVICE_H_
+#define CAIF_DEVICE_H_
+#include <linux/kernel.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/caif/caif_socket.h>
+#include <net/caif/caif_device.h>
+
+
+/**
+ * struct caif_dev_common - data shared between CAIF drivers and stack.
+ * @flowctrl:		Flow Control callback function. This function is
+ *                      supplied by CAIF Core Stack and is used by CAIF
+ *                      Link Layer to send flow-stop to CAIF Core.
+ *                      The flow information will be distributed to all
+ *                      clients of CAIF.
+ *
+ * @link_select:	Profile of device, either high-bandwidth or
+ *			low-latency. This member is set by CAIF Link
+ *			Layer Device in	order to indicate if this device
+ *			is a high bandwidth or low latency device.
+ *
+ * @use_frag:		CAIF Frames may be fragmented.
+ *			Is set by CAIF Link Layer in order to indicate if the
+ *			interface receives fragmented frames that must be
+ *			assembled by CAIF Core Layer.
+ *
+ * @use_fcs:		Indicate if Frame CheckSum (fcs) is used.
+ *			Is set if the physical interface is
+ *			using Frame Checksum on the CAIF Frames.
+ *
+ * @use_stx:		Indicate STart of frame eXtension (stx) in use.
+ *			Is set if the CAIF Link Layer expects
+ *			CAIF Frames to start with the STX byte.
+ *
+ * This structure is shared between the CAIF drivers and the CAIF stack.
+ * It is used by the device to register its behavior.
+ * CAIF Core layer must set the member flowctrl in order to supply
+ * CAIF Link Layer with the flow control function.
+ *
+ */
+ struct caif_dev_common {
+	void (*flowctrl)(struct net_device *net, int on);
+	enum caif_link_selector link_select;
+	int use_frag;
+	int use_fcs;
+	int use_stx;
+};
+
+#endif	/* CAIF_DEVICE_H_ */
+
-- 
1.6.3.3

