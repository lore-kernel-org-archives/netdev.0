From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 04/12] net-caif: add CAIF Link layer device
 header files
Date: Wed, 31 Mar 2010 01:56:22 +0200
Message-ID: <1269993390-23830-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-2-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-3-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756287Ab0C3X45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:56:57 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400CAID6MAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:46 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:46 +0200 (CEST)
In-reply-to: <1269993390-23830-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Header files for CAIF Link layer net-device,
and link-layer registration.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h    |   90 ++++++++++++++++++++++++++++++++++++++++
 include/net/caif/caif_device.h |   55 ++++++++++++++++++++++++
 2 files changed, 145 insertions(+), 0 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
new file mode 100644
index 0000000..42a7c78
--- /dev/null
+++ b/include/net/caif/caif_dev.h
@@ -0,0 +1,90 @@
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
+ * struct caif_param - CAIF parameters.
+ * @size:	Length of data
+ * @data:	Binary Data Blob
+ */
+struct caif_param {
+	u16  size;
+	u8   data[256];
+};
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
+ *			to connect on the Modem.
+ * @client_layer:	User implementation of client layer. This layer
+ *			MUST have receive and control callback functions
+ *			implemented.
+ *
+ * This function connects a CAIF channel. The Client must implement
+ * the struct cflayer. This layer represents the Client layer and holds
+ * receive functions and control callback functions. Control callback
+ * function will receive information about connect/disconnect responses,
+ * flow control etc (see enum caif_control).
+ * E.g. CAIF Socket will call this function for each socket it connects
+ * and have one client_layer instance for each socket.
+ */
+int caif_connect_client(struct caif_connect_request *config,
+			   struct cflayer *client_layer);
+
+/**
+ * caif_disconnect_client - Disconnects a client from the CAIF stack.
+ *
+ * @client_layer: Client layer to be removed.
+ */
+int caif_disconnect_client(struct cflayer *client_layer);
+
+/**
+ * connect_req_to_link_param - Translate configuration parameters
+ *				from socket format to internal format.
+ * @cnfg:	Pointer to configuration handler
+ * @con_req:	Configuration parameters supplied in function
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
index 0000000..d02f044
--- /dev/null
+++ b/include/net/caif/caif_device.h
@@ -0,0 +1,55 @@
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
-- 
1.6.3.3

