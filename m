From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v4 04/12] net-caif: add CAIF Link layer device header files
Date: Fri, 26 Feb 2010 23:13:29 +0100
Message-ID: <1267222417-2764-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1267222417-2764-1-git-send-email-sjur.brandeland@stericsson.com>
 <1267222417-2764-2-git-send-email-sjur.brandeland@stericsson.com>
 <1267222417-2764-3-git-send-email-sjur.brandeland@stericsson.com>
 <1267222417-2764-4-git-send-email-sjur.brandeland@stericsson.com>
Cc: daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gktv.no ([80.239.85.213]:58324 "EHLO mail.gktv.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966385Ab0BZWWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 17:22:16 -0500
In-Reply-To: <1267222417-2764-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Header files for CAIF Link layer net-device,
and link-layer registration.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h    |   81 ++++++++++++++++++++++++++++++++++++++++
 include/net/caif/caif_device.h |   57 ++++++++++++++++++++++++++++
 2 files changed, 138 insertions(+), 0 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
new file mode 100644
index 0000000..3cf7012
--- /dev/null
+++ b/include/net/caif/caif_dev.h
@@ -0,0 +1,81 @@
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
+#include <linux/caif/caif_socket.h>
+#include <linux/if.h>
+
+/**
+ * caif_connect_request - Request data for CAIF channel setup.
+ * @sockaddr:		Socket address to connect.
+ * @priority:		Priority of the connection.
+ * @link_selector:	Link selector (high bandwidth or low latency)
+ * @link_name:		Name of the CAIF Link Layer to use.
+ *
+ * This struct is used when connecting a CAIF channel.
+ * It contains all CAIF channel configuration options.
+ */
+struct caif_connect_request {
+	int protocol;
+	struct sockaddr_caif sockaddr;
+	enum caif_channel_priority priority;
+	enum caif_link_selector link_selector;
+	char link_name[16];
+	struct caif_param param;
+};
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
+int caif_connect_client(struct caif_connect_request *config,
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
+ * connect_req_to_link_param - Translate configuration parameters
+ * 				from socket format to internal format.
+ * @cnfg: 	Pointer to configuration handler
+ * @con_req: 	Configuration parameters supplied in function
+ *		caif_connect_client
+ * @channel_setup_param: Parameters supplied to the CAIF Core stack for
+ *			 setting up channels.
+ *
+ */
+int connect_req_to_link_param(struct cfcnfg *cnfg,
+				struct caif_connect_request *con_req,
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

