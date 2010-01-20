From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 10/13] net-caif: add kernel-client API for CAIF
Date: Wed, 20 Jan 2010 23:55:27 +0100
Message-ID: <1264028130-14364-11-git-send-email-sjur.brandeland@stericsson.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:52371 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500Ab0ATX4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:37 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00CFAIDPGCC0@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:13 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00LQBICIDUE0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:13 +0100 (CET)
In-reply-to: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

This patch provides a CAIF API for managing CAIF devices from
kernel modules.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_kernel.h |  309 ++++++++++++++++++++++++++++++++++++++++
 net/caif/caif_chnlif.c         |  177 +++++++++++++++++++++++
 2 files changed, 486 insertions(+), 0 deletions(-)

diff --git a/include/net/caif/caif_kernel.h b/include/net/caif/caif_kernel.h
new file mode 100644
index 0000000..6617a8f
--- /dev/null
+++ b/include/net/caif/caif_kernel.h
@@ -0,0 +1,309 @@
+/*
+ * CAIF Kernel Internal interface for configuring and accessing
+ * CAIF Channels.
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_KERNEL_H_
+#define CAIF_KERNEL_H_
+#include <linux/caif/caif_config.h>
+struct sk_buff;
+
+/*!\page  caif_kernel.h
+ * This is the specification of the CAIF kernel internal interface to
+ * CAIF Channels.
+ * This interface follows the pattern used in Linux device drivers with a
+ *  struct \ref caif_device
+ * holding control data handling each device instance.
+ *
+ * The functional interface consists of a few basic functions:
+ *  - \ref caif_add_device             Configure and connect the CAIF
+ *               channel to the remote end. Configuration is described in
+ *               \ref caif_channel_config.
+ *  - \ref caif_remove_device          Disconnect and remove the channel.
+ *  - \ref caif_transmit               Sends a CAIF message on the link.
+ *  - \ref caif_device.receive_cb      Receive callback function for
+ *                receiving packets.
+ *  - \ref caif_device.control_cb      Control information from the CAIF stack.
+ *  - \ref caif_flow_control           Send flow control message to remote end.
+ *
+ *
+ * Details:
+ * \see { caif_kernel }
+ *
+ * \code
+ *
+#include <net/caif/caif_kernel.h>"
+
+	static void my_receive(struct caif_device *dev, struct sk_buff *skb)
+	{
+	...
+	}
+
+	static void my_control(struct caif_device *dev, enum caif_control ctrl)
+	{
+	....
+	}
+
+	int kernel_caif_usage_example()
+	{
+		struct sk_buff *skb;
+		char *message = "hello";
+
+		// Connect the channel
+		struct caif_device caif_dev = {
+			.caif_config = {
+				.name = "MYDEV",
+				.priority = CAIF_PRIO_NORMAL,
+				.type = CAIF_CHTY_UTILITY,
+				.phy_pref = CAIF_PHYPREF_LOW_LAT,
+				.u.utility.name = "CAIF_PSOCK_TEST",
+				.u.utility.params = {0x01},
+				.u.utility.paramlen = 1,
+		},
+
+		.receive_cb = my_receive,
+		.control_cb = my_control,
+
+		};
+	ret = caif_add_device(&caif_dev);
+	if (ret)
+	goto error;
+
+	// Send a packet
+	skb = caif_create_skb(message, strlen(message));
+	ret = caif_transmit(&caif_dev, skb);
+	if (ret)
+		goto error;
+
+	// Remove device
+	ret = caif_remove_device(&caif_dev);
+	if (ret)
+		goto error;
+
+}
+
+* \endcode
+*
+* \section Linux Socket Buffer (SKB)
+    *          When sending out packets on a connection (\ref caif_transmit)
+    *          the CAIF stack will add CAIF protocol headers.
+    *          This requires space in the SKB.
+    *          CAIF has defined \ref CAIF_SKB_HEAD_RESERVE for minimum
+    *          required reserved head-space in the packet and
+    *          \ref CAIF_SKB_TAIL_RESERVE for minimum reserved tail-space.
+    *
+    *          \b NOTE The Linux kernel SKB operations panic if not
+    *                  enough space is available!
+    *
+    */
+
+    /*! \addtogroup caif_kernel
+     *  @{
+     */
+
+struct caif_device;
+
+	/** Minimum required CAIF socket buffer head-space */
+#define CAIF_SKB_HEAD_RESERVE 32
+
+	/** Minimum required CAIF socket buffer tail-space */
+#define CAIF_SKB_TAIL_RESERVE 32
+
+	/** CAIF control information (used in \ref caif_device.control_cb)
+	 *   used for receiving control information from the modem.
+	 */
+enum caif_control {
+	/** Modem has sent Flow-ON, Clients can start transmitting
+	 *  data using \ref caif_transmit.
+	 */
+	CAIF_CONTROL_FLOW_ON = 0,
+	/** Modem has sent Flow-OFF, Clients must stop transmitting
+	 * data using \ref caif_transmit.
+	 */
+	CAIF_CONTROL_FLOW_OFF = 1,
+
+	/** Channel creation is complete. This is an acknowledgement to
+	 *  \ref caif_add_device from the modem.
+	 *  The channel is ready for transmit (Flow-state is ON).
+	 */
+	CAIF_CONTROL_DEV_INIT = 3,
+
+	/** Spontaneous close request from the modem, only applicable
+	 *   for utility link. The client should respond by calling
+	 *   \ref caif_remove_device.
+	 */
+	CAIF_CONTROL_REMOTE_SHUTDOWN = 4,
+
+	/** Channel disconnect is complete. This is an acknowledgement to
+	 *  \ref caif_remove_device from the modem.
+	 *  \ref caif_transmit or \ref caif_flow_control must not be
+	 *  called after this.
+	 */
+	CAIF_CONTROL_DEV_DEINIT = 5,
+
+	/** Channel creation has failed. This is a negative acknowledgement
+	 *  to \ref caif_add_device from the modem.
+	 */
+	CAIF_CONTROL_DEV_INIT_FAILED = 6
+};
+
+/** Flow control information (used in \ref caif_device.control_cb) used
+ *  for controlling outgoing flow.
+ */
+enum caif_flowctrl {
+	/** Flow Control is ON, transmit function can start sending data */
+	CAIF_FLOWCTRL_ON = 0,
+	/** Flow Control is OFF, transmit function should stop sending data */
+	CAIF_FLOWCTRL_OFF = 1,
+};
+
+/** Transmits CAIF packets on channel.
+ * This function is non-blocking and safe to use in tasklet context.
+ * The CAIF stack takes ownership of the socket buffer (SKB) after calling
+ * \ref caif_transmit.
+ * This means that the user cannot access the SKB afterwards; this applies
+ * even in error situations.
+ *
+ * @return 0 on success, < 0 upon error.
+ *
+ * @param[in] skb         Socket buffer holding data to be written.
+ * @param[in] dev         Structure used when creating the channel
+ *
+ *
+ * Error codes:
+ *  - \b ENOTCONN,   The channel is not connected.
+ *  - \b EPROTO,     Protocol error (or SKB is faulty)
+ *  - \b EIO         IO error (unspecified error)
+ */
+int caif_transmit(struct caif_device *dev, struct sk_buff *skb);
+
+/** Function for sending flow ON / OFF to remote end.
+ * This function is non-blocking and safe to use in tasklet context.
+ *
+ * @param[in] dev        Reference to device data.
+ * @param[in] flow       Flow control information.
+
+ * @return 0 on success, < 0 upon error.
+ * Error codes:
+ *  - \b ENOTCONN,   The channel is not connected.
+ *  - \b EPROTO,     Protocol error.
+ *  - \b EIO         IO error (unspecified error).
+ */
+int caif_flow_control(struct caif_device *dev, enum caif_flowctrl flow);
+
+/** Handle for kernel internal CAIF channels.
+ * All fields in this structure must be filled in by client before calling
+ * \ref caif_add_device (except _caif_handle).
+ */
+struct caif_device {
+
+    /** Channel configuration parameter. Contains information about type
+     *	and configuration of the channel.
+     *  This must be set before calling \ref caif_add_device.
+     */
+	struct caif_channel_config caif_config;
+
+
+    /** Callback function for receiving CAIF Packets from channel.
+     * This callback is called from softirq context (tasklet).
+     * The receiver <b> must </b> free the SKB.
+     * <b> DO NOT BLOCK IN THIS FUNCTION! </b>
+     *
+     * If the client has to do blocking operations then
+     * it must start its own work queue (or kernel thread).
+     *
+     * @param[in] dev       Reference to device data.
+     * @param[in] skb       Socket buffer with received data.
+     */
+	void (*receive_cb) (struct caif_device *dev, struct sk_buff *skb);
+
+
+    /** Callback function for notifying flow control from remote end - see
+     *  \ref caif_control.
+     * This callback is called from from softirq context (tasklet).
+     *
+     * <b> DO NOT BLOCK IN THIS FUNCTION! </b>
+     *
+     * Client must not call \ref caif_transmit from this function.
+     *
+     * If the client has queued packets to send then
+     * it must start its own thread to do \ref caif_transmit.
+     *
+     * @param[in] dev        Reference to device data.
+     * @param[in] ctrl       CAIF control info \ref caif_control.
+     *                       e.g. Flow control
+     *                       \ref CAIF_CONTROL_FLOW_ON or
+     *                       \ref CAIF_CONTROL_FLOW_OFF
+     */
+	void (*control_cb) (struct caif_device *dev, enum caif_control ctrl);
+
+    /** This is a CAIF private attribute, holding CAIF internal reference
+     * to the CAIF stack. Do not update this field.
+     */
+	void *_caif_handle;
+
+    /** This field may be filled in by client for their own usage. */
+	void *user_data;
+};
+
+/** Add (connect) a CAIF Channel.
+ * This function is non-blocking. The channel connect is reported in
+ * \ref caif_device.control_cb.
+ * The channel is not open until \ref caif_device.control_cb is called with
+ * \ref CAIF_CONTROL_DEV_INIT.
+ * If setting up the channel fails then \ref caif_device.control_cb is called
+ * with \ref CAIF_CONTROL_DEV_INIT_FAILED.
+ *
+ * \ref caif_transmit, \ref caif_flow_control or \ref caif_remove_device must
+ * not be called before receiveing CAIF_CONTROL_DEV_INIT.
+ * @return 0 on success, < 0 on failure.
+ *
+ * Error codes:
+ * - \b -EINVAL    Invalid arguments
+ * - \b -ENODEV    No PHY device exists.
+ * - \b -EIO       IO error (unspecified error)
+ */
+int caif_add_device(struct caif_device *dev);
+
+/** Disconnect a CAIF Channel
+ * This function is non-blocking.
+ * The channel has not been disconnected until \ref caif_device : control_cb is
+ * called with \ref CAIF_CONTROL_DEV_DEINIT.
+ * \ref caif_transmit or \ref caif_flow_control \b must not be called after
+ * receiving \ref CAIF_CONTROL_DEV_DEINIT.
+ * The client is responsible for freeing the \ref caif_device structure after
+ * receiving  \ref CAIF_CONTROL_DEV_DEINIT (if applicable).
+ * @return 0 on success.
+ *
+ * - \b EIO       IO error (unspecified error)
+ */
+int caif_remove_device(struct caif_device *caif_dev);
+
+/** Convenience function for allocating a socket buffer for usage with CAIF
+ * and copy user data into the socket buffer.
+ * @param[in] data 		User data to send with CAIF.
+ * @param[in] data_length 	Length of data to send.
+ * @return 	New socket buffer containing user data.
+ */
+struct sk_buff *caif_create_skb(unsigned char *data, unsigned int data_length);
+
+/** Convenience function for extracting data from a socket buffer (SKB) and
+ *  then destroying the SKB.
+ *  Copies data from the SKB and then frees the SKB.
+ * @param[in] skb	SKB to extract data from. SKB will be freed after
+ *			extracting data.
+ *
+ * @param[in] data	User data buffer to extract packet data into.
+ * @param[in] max_length User data buffer length,
+ * @return number of bytes extracted; < 0 upon error.
+ *
+ */
+int caif_extract_and_destroy_skb(struct sk_buff *skb, unsigned char *data,
+				 unsigned int max_length);
+
+/*! @} */
+
+#endif				/* CAIF_KERNEL_H_ */
diff --git a/net/caif/caif_chnlif.c b/net/caif/caif_chnlif.c
new file mode 100644
index 0000000..5b70f4b
--- /dev/null
+++ b/net/caif/caif_chnlif.c
@@ -0,0 +1,177 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/skbuff.h>
+#include <net/caif/caif_kernel.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/caif_dev.h>
+struct caif_kernelif {
+	struct layer layer;
+	struct caif_device *dev;
+	struct cfctrl_link_param param;
+};
+
+
+/*
+ * func caif_create_skb - Creates a CAIF SKB buffer
+ * @data:		data to add to buffer
+ * @data_length:	length of data
+ */
+struct sk_buff *caif_create_skb(unsigned char *data, unsigned int data_length)
+{
+	/* NOTE: Make room for CAIF headers when using SKB inside CAIF. */
+	struct sk_buff *skb =
+	    alloc_skb(data_length + CAIF_SKB_HEAD_RESERVE +
+		      CAIF_SKB_TAIL_RESERVE, GFP_ATOMIC);
+	if (skb == NULL)
+		return NULL;
+	skb_reserve(skb, CAIF_SKB_HEAD_RESERVE);
+
+	memcpy(skb_put(skb, data_length), data, data_length);
+	return skb;
+}
+EXPORT_SYMBOL(caif_create_skb);
+
+int caif_extract_and_destroy_skb(struct sk_buff *skb, unsigned char *data,
+			     unsigned int max_length)
+{
+	unsigned int len;
+	len = skb->len;
+	/*
+	 * Note: skb_linearize only fails on an out of memory condition
+	 * if we fail here we are NOT freeing the skb.
+	 */
+	if (!skb_linearize(skb) || skb->len > max_length)
+		return CFGLU_EOVERFLOW;
+	memcpy(data, skb->data, skb->len);
+	kfree_skb(skb);
+	return len;
+}
+EXPORT_SYMBOL(caif_extract_and_destroy_skb);
+
+/*
+ * NOTE: transmit takes ownership of the SKB.
+ *       I.e. transmit only fails on severe errors.
+ *       flow_off is not checked on transmit; this is client's responcibility.
+ */
+int caif_transmit(struct caif_device *dev, struct sk_buff *skb)
+{
+	struct caif_kernelif *chnlif =
+	    (struct caif_kernelif *) dev->_caif_handle;
+	struct cfpkt *pkt;
+	pkt = cfpkt_fromnative(CAIF_DIR_OUT, (void *) skb);
+	return chnlif->layer.dn->transmit(chnlif->layer.dn, pkt);
+}
+EXPORT_SYMBOL(caif_transmit);
+
+int caif_flow_control(struct caif_device *dev, enum caif_flowctrl flow)
+{
+	enum caif_modemcmd modemcmd;
+	struct caif_kernelif *chnlif =
+	    (struct caif_kernelif *) dev->_caif_handle;
+	switch (flow) {
+	case CAIF_FLOWCTRL_ON:
+		modemcmd = CAIF_MODEMCMD_FLOW_ON_REQ;
+		break;
+	case CAIF_FLOWCTRL_OFF:
+		modemcmd = CAIF_MODEMCMD_FLOW_OFF_REQ;
+		break;
+	default:
+		return -EINVAL;
+	}
+	return chnlif->layer.dn->modemcmd(chnlif->layer.dn, modemcmd);
+}
+EXPORT_SYMBOL(caif_flow_control);
+
+static int chnlif_receive(struct layer *layr, struct cfpkt *cfpkt)
+{
+	struct caif_kernelif *chnl =
+		container_of(layr, struct caif_kernelif, layer);
+	struct sk_buff *skb;
+	skb = (struct sk_buff *) cfpkt_tonative(cfpkt);
+	chnl->dev->receive_cb(chnl->dev, skb);
+	return CFGLU_EOK;
+}
+
+static void chnlif_flowctrl(struct layer *layr, enum caif_ctrlcmd ctrl,
+			int phyid)
+{
+	struct caif_kernelif *chnl = (struct caif_kernelif *) layr;
+	enum caif_control ctl;
+
+	switch (ctrl) {
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+		ctl = CAIF_CONTROL_FLOW_OFF;
+		break;
+	case CAIF_CTRLCMD_FLOW_ON_IND:
+		ctl = CAIF_CONTROL_FLOW_ON;
+		break;
+	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
+		ctl = CAIF_CONTROL_REMOTE_SHUTDOWN;
+		break;
+	case CAIF_CTRLCMD_DEINIT_RSP:
+		ctl = CAIF_CONTROL_DEV_DEINIT;
+		chnl->dev->_caif_handle = NULL;
+		chnl->dev->control_cb(chnl->dev, ctl);
+		memset(chnl, 0, sizeof(chnl));
+		cfglu_free(chnl);
+		return;
+
+	case CAIF_CTRLCMD_INIT_RSP:
+		ctl = CAIF_CONTROL_DEV_INIT;
+		break;
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+		ctl = CAIF_CONTROL_DEV_INIT_FAILED;
+		break;
+	default:
+		return;
+	}
+	chnl->dev->control_cb(chnl->dev, ctl);
+}
+
+int caif_add_device(struct caif_device *dev)
+{
+	int ret;
+	struct caif_kernelif *chnl = cfglu_alloc(sizeof(struct caif_kernelif));
+	if (!chnl)
+		return -ENOMEM;
+	chnl->dev = dev;
+	chnl->layer.ctrlcmd = chnlif_flowctrl;
+	chnl->layer.receive = chnlif_receive;
+	ret =
+	    channel_config_2_link_param(get_caif_conf(), &dev->caif_config,
+				&chnl->param);
+	if (ret < 0) {
+		ret = CFGLU_EBADPARAM;
+		goto error;
+	}
+	if (cfcnfg_add_adaptation_layer(get_caif_conf(), &chnl->param,
+				&chnl->layer)) {
+		ret = CFGLU_ENOTCONN;
+		goto error;
+	}
+	dev->_caif_handle = chnl;
+
+	return CFGLU_EOK;
+error:
+	chnl->dev->_caif_handle = NULL;
+	memset(chnl, 0, sizeof(chnl));
+	cfglu_free(chnl);
+	return ret;
+}
+EXPORT_SYMBOL(caif_add_device);
+
+int caif_remove_device(struct caif_device *caif_dev)
+{
+
+	struct caif_kernelif *chnl =
+	    container_of(caif_dev->_caif_handle, struct caif_kernelif, layer);
+	return cfcnfg_del_adapt_layer(get_caif_conf(), &chnl->layer);
+}
+EXPORT_SYMBOL(caif_remove_device);
-- 
1.6.3.3

