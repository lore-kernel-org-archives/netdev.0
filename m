From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/3 v4] drivers: net: ethernet: qualcomm: rmnet:
 Initial implementation
Date: Wed, 16 Aug 2017 13:30:17 +0200
Message-ID: <20170816113017.GJ1868@nanopsycho>
References: <1502856953-30321-1-git-send-email-subashab@codeaurora.org>
 <1502856953-30321-4-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, stephen@networkplumber.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33202 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751212AbdHPLaU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 07:30:20 -0400
Received: by mail-wr0-f196.google.com with SMTP id n88so2531385wrb.0
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 04:30:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1502856953-30321-4-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 16, 2017 at 06:15:53AM CEST, subashab@codeaurora.org wrote:
>RmNet driver provides a transport agnostic MAP (multiplexing and
>aggregation protocol) support in embedded module. Module provides
>virtual network devices which can be attached to any IP-mode
>physical device. This will be used to provide all MAP functionality
>on future hardware in a single consistent location.
>
>Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

[...]


>+struct rmnet_phys_ep_conf_s {

The name is cryptic. Why "_s"?


>+	struct net_device *dev;
>+	struct rmnet_logical_ep_conf_s local_ep;
>+	struct rmnet_logical_ep_conf_s muxed_ep[RMNET_MAX_LOGICAL_EP];
>+	u32 ingress_data_format;
>+	u32 egress_data_format;
>+	struct net_device *rmnet_devices[RMNET_MAX_VND];
>+};
>+
>+extern struct rtnl_link_ops rmnet_link_ops;
>+
>+struct rmnet_vnd_private_s {

Again, cryptic.


>+	struct rmnet_logical_ep_conf_s local_ep;
>+	u32 msg_enable;
>+};

[...]


>+rx_handler_result_t rmnet_ingress_handler(struct sk_buff *skb)
>+{
>+	struct rmnet_phys_ep_conf_s *config;

I still fail to understand why the name of this is "config". Please
change to something else across whole code. Including the name of the struct.


>+	struct net_device *dev;
>+	int rc;
>+
>+	if (!skb)
>+		return RX_HANDLER_CONSUMED;
>+
>+	dev = skb->dev;
>+	config = rmnet_get_phys_ep_config(skb->dev);

You have dev. Why not use dev?


>+
>+	/* Sometimes devices operate in ethernet mode even thouth there is no
>+	 * ethernet header. This causes the skb->protocol to contain a bogus
>+	 * value and the skb->data pointer to be off by 14 bytes. Fix it if
>+	 * configured to do so
>+	 */
>+	if (config->ingress_data_format & RMNET_INGRESS_FIX_ETHERNET) {
>+		skb_push(skb, RMNET_ETHERNET_HEADER_LENGTH);
>+		rmnet_set_skb_proto(skb);
>+	}
>+
>+	if (config->ingress_data_format & RMNET_INGRESS_FORMAT_MAP) {
>+		rc = rmnet_map_ingress_handler(skb, config);
>+	} else {
>+		switch (ntohs(skb->protocol)) {
>+		case ETH_P_MAP:
>+			if (config->local_ep.rmnet_mode ==
>+				RMNET_EPMODE_BRIDGE) {
>+				rc = rmnet_ingress_deliver_packet(skb, config);
>+			} else {
>+				kfree_skb(skb);
>+				rc = RX_HANDLER_CONSUMED;
>+			}
>+			break;
>+
>+		case ETH_P_ARP:
>+		case ETH_P_IP:
>+		case ETH_P_IPV6:
>+			rc = rmnet_ingress_deliver_packet(skb, config);
>+			break;
>+
>+		default:
>+			rc = RX_HANDLER_PASS;
>+		}
>+	}
>+
>+	return rc;
>+}
>+
>+rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
>+{
>+	return rmnet_ingress_handler(*pskb);

This is just silly. Why you don't have the content of rmnet_ingress_handler
right here?
