From: Alex Aizman <alex@neterion.com>
Subject: VJ Channel API - driver level (PATCH)
Date: Tue, 02 May 2006 15:53:50 -0700
Message-ID: <4457E2FE.50505@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:30441 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S965031AbWEBWx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 May 2006 18:53:57 -0400
Received: from guinness.s2io.com (owa.neterion.com [72.1.205.136])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id 700F32000329
	for <netdev@vger.kernel.org>; Tue,  2 May 2006 18:53:56 -0400 (EDT)
Received: from [10.16.16.76] ([10.16.16.76])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id k42MrsDr003102
	for <netdev@vger.kernel.org>; Tue, 2 May 2006 18:53:54 -0400 (EDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alex Aizman <alex@xxxxxxxxxx>

Hacked netdevice.h to support multiple channels.

--- netdevice-orig.h	2006-03-04 10:01:38.000000000 -0800
+++ netdevice-channel.h	2006-03-09 10:17:11.419955200 -0800
@@ -246,6 +246,147 @@
 
 extern int __init netdev_boot_setup(char *str);
 
+#ifdef CONFIG_NET_CHANNELS
+/***************  NETDEVICE HW CHANNELS data structures *****************/
+/**
+ * enum netdev_hwchannel_rx_flow_e - Hardware receive channel "flow" types.
+ * @HWCH_RX_FLOW_NONE: does not filter rx packets.
+ * @HWCH_RX_FLOW_MACADDR: filters based upon the rx mac address
+ * @HWCH_RX_FLOW_VLAN_ID: filters based upon the rx vlan id tag
+ * @HWCH_RX_FLOW_VLAN_QOS: fikters based upon the vlan qos field
+ * @HWCH_RX_FLOW_PORT: filters based upon the tcp or udp receive port number
+ * @HWCH_RX_FLOW_L4_HASH: filters based upon a hash of the tcp session id
+ * @HWCH_RX_FLOW_L4_SPDM: filters based upon a hash of the four-tuple of the
+ * following: source ip, source port, destination ip, destinaton port
+ *
+ * A rx is bound to a specific device.  When one of thsese enums is used, 
+ * traffic is filtered onto the queue of only the requested type.  By default
+ * we use HWCH_RX_FLOW_NONE as we usually want all traffic from this device.
+ **/
+typedef enum netdev_hwchannel_rx_flow_e  {
+	HWCH_RX_FLOW_NONE,
+	HWCH_RX_FLOW_MACADDR,
+	HWCH_RX_FLOW_VLAN_ID,
+	HWCH_RX_FLOW_VLAN_QOS,
+	HWCH_RX_FLOW_PORT,
+	HWCH_RX_FLOW_L4_HASH,
+	HWCH_RX_FLOW_L4_SPDM,
+} netdev_hwchan_rx_flow_e;
+
+/**
+ * enum enum netdev_hwchannel_priority_e - Hardware channel priorities.
+ * @HWCH_PRIORITY_NONE: no priority, process as fast as possible
+ * @HWCH_PRIORITY_LOWEST: process all other channels first
+ * @HWCH_PRIORITY_LOW: channel with low priority
+ * @HWCH_PRIORITY_MEDIUM: channel with medium priority
+ * @HWCH_PRIORITY_HIGH: channel with high priority
+ * @HWCH_PRIORITY_HIGHEST: process this channel before all others
+ *
+ * Channel priorities can be set on both tx and rx channels.  A default
+ * priority of HWCH_PRIORITY_NONE means all channels are considered equal by
+ * the hardware.  If a priority is set then HWCH_PRIORITY_HIGHEST is treated
+ * first and HWCH_PRIORITY_LOWEST is treated last.
+ * 
+ **/
+typedef enum netdev_hwchannel_priority_e {
+	HWCH_PRIORITY_NONE,
+	HWCH_PRIORITY_LOWEST,
+	HWCH_PRIORITY_LOW,
+	HWCH_PRIORITY_MEDIUM,
+	HWCH_PRIORITY_HIGH,
+	HWCH_PRIORITY_HIGHEST,
+} netdev_hwchan_priority_e;
+
+/**
+ * struct netdev_rx_flow - Uniquely identifies the traffic flow for a given
+ * rx channel.
+ * @type: specifies what type of traffic flow this channel will use.  This
+ * also specifies which of the fields in the union will be examined.
+ * @macaddr: if type is set to HWCH_RX_FLOW_MACADDR this field will be used
+ * to only accept traffic from this mac address
+ * @vlan_id: if type is set to HWCH_RX_FLOW_VLAN_ID this field will be used
+ * to only accept traffic from packets with this vlan id
+ * @vlan_qos: if type is set to HWCH_RX_FLOW_VLAN_QOS this field will be used
+ * to only accept traffic from packets with this vlan qos tag
+ * @port: if type is set to HWCH_RX_FLOW_PORT this field will be used to only
+ * accept traffic from tcp or udp packets with this destination port number
+ * @session_id: if type is set to HWCH_RX_FLOW_L4_HASH this field will be used
+ * to only allow tcp traffic from this specific session id
+ * @l4_4tuple: if type ie set to HWCH_RX_FLOW_L4_SPDM this struct will be
+ * used to only accept traffic which has the correct four-tuple consisting of:
+ * source ip, source port, destination ip, destinatopn port
+ *
+ * Receive channels can be set to shape the types of traffic placed upon them.
+ * This interface allows one to determine how to shape incoming traffic on
+ * a specified channel.  For example, if 
+ * netdev_rx_flow.type = HWCH_RX_FLOW_PORT and 
+ * netdev_rx_flow.rx_flow_val.port = 3260 identifies all standard iSCSI
+ * traffic.  The API call bind_rx_channel() is used to take the contents of
+ * struct netdev_rx_flow and apply it to a given rx channel.
+ **/
+struct netdev_rx_flow {
+	netdev_hwchan_rx_flow_e	type;
+	union rx_flow_val {
+		unsigned char macaddr[MAX_ADDR_LEN];/* HWCH_RX_FLOW_MACADDR  */
+		unsigned short vlan_id;		    /* HWCH_RX_FLOW_VLAN_ID  */
+		unsigned char  vlan_qos;	    /* HWCH_RX_FLOW_VLAN_QOS */
+		unsigned short port;		    /* HWCH_RX_FLOW_PORT     */
+		unsigned int session_id;	    /* HWCH_RX_FLOW_L4_HASH */
+		struct {			    /* HWCH_RX_FLOW_L4_SPDM */
+			uint32_t	src_ip;
+			unsigned short	src_port;
+			uint32_t	dst_ip;
+			unsigned short	dst_port;
+		} l4_4tuple;
+	} rx_flow_val;
+};
+
+/**
+ * (*netif_rx_hwchannel_cb) - function to be used for an rx channels callback.
+ * @skb: system network buffer to place next available packet from the channel
+ * @kernel_channelh: hardware rx channel handle to bind process
+ * @flow: specifies the type of traffic flow to examine for the given hardware
+ * rx channel
+ *
+ * By using this callback an application can harvest traffic from a specific
+ * hardware rx channel bypassing the kernel.  This function is optional.
+ **/
+typedef int (*netif_rx_hwchannel_cb) (struct sk_buff *skb,
+				      void *kernel_channelh,
+				      struct netdev_rx_flow flow);
+
+/**************************************************************************
+ * 2. Kernel-provided Calls (optional).
+ * ----------------------------------
+ * "Channelized" alterations of the corresponding netif_() callbacks.
+ *************************************************************************/
+
+/**
+ * netif_rx_hwchannel - gives a received buffer from an rx channel to the 
+ * linux stack.
+ * @skb: system network buffer to place next available packet from the channel
+ * @kernel_channelh: hardware rx channel handle to process
+ * @flow: specifies the type of traffic flow to examine for the given hardware
+ * rx channel
+ *
+ * Post a buffer received on a given Rx hardware channel to the stack.
+ * Used only if the channel callback is _not_ specified,
+ * see open_rx_hwchannel().
+ **/
+extern int netif_rx_hwchannel (struct sk_buff *skb,
+			       void *kernel_channelh,
+			       struct netdev_rx_flow flow);
+
+/*
+ * Start/Stop/Wakeup all traffic (flows) using a given Tx channel.
+ * The channel must be Tx, that is - it must be open with open_tx_hwchannel().
+ */
+extern void netif_start_queue_tx_hwchannel (void *kernel_channelh);
+extern void netif_stop_queue_tx_hwchannel (void *kernel_channelh);
+extern void netif_wakeup_queue_tx_hwchannel (void *kernel_channelh);
+extern void netif_queue_stopped (void *kernel_channelh);
+#endif /* CONFIG_NET_CHANNELS */
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -502,6 +643,144 @@
 
 	/* class/net/name entry */
 	struct class_device	class_dev;
+
+#ifdef CONFIG_NET_CHANNELS
+	/***************** NET DEVICE HW CHANNELS ******************
+	 *  1. Low-level calls.  
+	 *  Exposes uni-directional hardware-supported channel: hw_channelh.
+	 *  Provided by a multi-channel (driver + adapter).
+ 	 *****************************************************************/
+
+	/**
+	 * (*open_tx_hwchannel) - open a channel to be used for transmit
+	 * @dev: net_device structure to associate with this channel
+	 * @priority: the channel priority as to how it is processed relative
+	 * to other channels
+	 * @burst_size: size of the channel, number of descriptors, etc.
+	 * @kernel_channelh: hardware channel to bind transmit traffic to
+	 * @hw_channelh: pointer to a user handle for a given hardware channel
+	 *
+	 * Opens a transmit channel and binds it to the hw_channelh parameter.
+	 * A hardware channel cannot be opened twice and cannot be used prior
+	 * to openeing.  Should any error occur, hw_channelh will point to 
+	 * NULL.
+	 **/
+	int (*open_tx_hwchannel) (struct net_device *dev,
+				  netdev_hwchan_priority_e priority,
+				  int burst_size,
+				  void *kernel_channelh,
+				  void **hw_channelh);
+
+	/**
+	 * (*open_rx_hwchannel) - open a channel to be used for receive
+	 * @dev: net_device structure to associate with this channel
+	 * @flow_type: the receive channel flow type to associate with this
+	 * hardware channel
+	 * @priority: the channel priority as to how it is processed relative
+	 * to other channels
+	 * @burst_size: size of the channel, number of descriptors, etc.
+	 * @kernel_channelh: hardware channel to bind transimit traffic to
+	 * @hw_channelh: pointer to a user handle for a given hardware channel
+	 *
+	 * Opens a receive channel and binds it to the hw_channelh parameter.
+	 * A hardware channel cannot be opened twice and cannot be used prior
+	 * to openeing.  Should any error occur, hw_channelh will point to 
+	 * NULL.  
+	 * Note: open_rx_hwchannel is optional.  If the callback is not 
+	 * specified the driver will use the regular netif_ API.
+	 **/
+	int (*open_rx_hwchannel) (struct net_device *dev,
+				  netdev_hwchan_rx_flow_e flow_type,
+				  netdev_hwchan_priority_e priority,
+				  int cpu,
+				  int burst_size,
+				  netif_rx_hwchannel_cb	callback,
+				  void *kernel_channelh, 
+				  void **hw_channelh);
+
+	/**
+	 * (*close_hwchannel) - close a hardware channel.
+	 * @hw_channelh - specifies the particular hardware channel to close.
+	 *
+	 * Closes down a hardware channel that has been opened.  This applies
+	 * to either a transmit or receive channel.  Note in order to close
+	 * down a channel link, both the transmit and receive channels have 
+	 * to be closed separately.
+	 **/
+	int (*close_hwchannel) (void *hw_channelh);
+
+	/**
+	 * (*hard_start_xmit_hwchannel) - post a buffer to a transmit channel
+	 * @skb: network packet to add to the transmit channel
+	 * @hw_channelh: transmit channel to append the packet
+	 *
+	 * Posts a packet into the next available slot on the given transmit
+	 * channel.  This call will fail if hw_channelh is not open or is 
+	 * not a transmit channel.  Note that unlike receive there is no API
+	 * to bind transmit traffic to a given channel.
+	 **/
+	int (*hard_start_xmit_hwchannel) (struct sk_buff *skb,
+					  void *hw_channelh);
+
+	/**
+	 * (*bind_rx_hwchannel) - binds a given receive traffic flow to a 
+	 * receive channel
+	 * @flow: specific receive flow pattern to match traffic against
+	 * @hw_channelh: receive hardware channel to match traffic based upon
+	 * the given flow
+	 *
+	 * Given a specific flow this function will bind that flow to the 
+	 * named receive hardware channel.  The relationship between receive
+	 * flows and receive hardware channels is one-to-many.  This means
+	 * several flows can be bound to the same receive hardware channel.
+	 * The function call will fail if the channel is not a receive channel,
+	 * if the channel is not opened, or if the specified flow does not
+	 * correspond with the channel type applied to the channel during
+	 * channel open.
+	 **/
+	int (*bind_rx_hwchannel) (struct netdev_rx_flow flow, void *hw_channelh);
+
+	/**
+	 * (*unbind_rx_hwchannel) - unbinds a given receive traffic flow to a 
+	 * receive channel
+	 * @flow: specific receive flow pattern to match traffic against
+	 * @hw_channelh: receive hardware channel to match traffic based upon
+	 * the given flow
+	 *
+	 * Unbindes a certain flow from a receive hardware channel.  The
+	 * function will fail if the channel is not open, the channel is not
+	 * a receive channel, or if the given flow has not been previously
+	 * bound to the receive channel.
+	 **/
+	int (*unbind_rx_hwchannel) (struct netdev_rx_flow flow, void *hw_channelh);
+
+	/* 
+	 * (*poll_hwchannel) - completion handler executed in a polling mode
+	 * @hw_channel: hardware channel to poll
+	 * @budget: number of completions "budgeted" for processing in this 
+	 * iteration
+	 *
+	 * Polls a hardware channel and tries to reap at least as many 
+	 * packets as contained in budgeted.  This works for both transmit
+	 * and receive channels.  For transmit this function cleans up 
+	 * packets marked as completed by the hardware.  For receive the 
+	 * packets are either passed up the netif_ stack or by the 
+	 * channel receive callback if one was given.
+	 */ 
+	int (*poll_hwchannel) (int *budget, void *hw_channelh);
+
+	/**
+	 * (*get_stats_hwchannel) - obtain statistics about a hardware channel
+	 * @hw_channelh: specific transmit or receive hardware channel to 
+	 * query for statistics
+	 *
+	 * Returns the standard statistics about a given transmit or receive
+	 * hardware channel.  The statistics are stored in the usual 
+	 * struct net_device_stats format.
+	 **/
+	struct net_device_stats* (*get_stats_hwchannel) (void *hw_channelh);
+
+#endif /* CONFIG_NET_CHANNELS */
 };
 
 #define	NETDEV_ALIGN		32


