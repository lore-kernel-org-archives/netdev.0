From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 05/10] rocker: introduce rocker switch driver
Date: Tue, 11 Nov 2014 16:28:24 +0100
Message-ID: <20141111152824.GG1825@nanopsycho.lan>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-6-git-send-email-jiri@resnulli.us>
 <5461366A.9050900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvac
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35360 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbaKKP21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 10:28:27 -0500
Received: by mail-wi0-f181.google.com with SMTP id n3so1993676wiv.2
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 07:28:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5461366A.9050900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 10, 2014 at 11:04:26PM CET, john.fastabend@gmail.com wrote:
>On 11/09/2014 02:51 AM, Jiri Pirko wrote:
>>This patch introduces the first driver to benefit from the switchdev
>>infrastructure and to implement newly introduced switch ndos. This is a
>>driver for emulated switch chip implemented in qemu:
>>https://github.com/sfeldma/qemu-rocker/
>>
>>This patch is a result of joint work with Scott Feldman.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>>  MAINTAINERS                          |    7 +
>>  drivers/net/ethernet/Kconfig         |    1 +
>>  drivers/net/ethernet/Makefile        |    1 +
>>  drivers/net/ethernet/rocker/Kconfig  |   27 +
>>  drivers/net/ethernet/rocker/Makefile |    5 +
>>  drivers/net/ethernet/rocker/rocker.c | 2060 ++++++++++++++++++++++++++++++++++
>>  drivers/net/ethernet/rocker/rocker.h |  427 +++++++
>>  7 files changed, 2528 insertions(+)
>>  create mode 100644 drivers/net/ethernet/rocker/Kconfig
>>  create mode 100644 drivers/net/ethernet/rocker/Makefile
>>  create mode 100644 drivers/net/ethernet/rocker/rocker.c
>>  create mode 100644 drivers/net/ethernet/rocker/rocker.h
>>
>
>[...]
>
>>+
>>+static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct net_device *dev)
>>+{
>>+	struct rocker_port *rocker_port = netdev_priv(dev);
>>+	struct rocker *rocker = rocker_port->rocker;
>>+	struct rocker_desc_info *desc_info;
>>+	struct rocker_tlv *frags;
>>+	int i;
>>+	int err;
>>+
>>+	desc_info = rocker_desc_head_get(&rocker_port->tx_ring);
>>+	if (unlikely(!desc_info)) {
>>+		if (net_ratelimit())
>
>Could you have a netif_stop_queue() here as well same as below? Not
>that optimizing the xmit routine is the interesting part of this patch.
>But I guess this is just some strange error path because I see you
>check this case below.

This code should never be reached.
If the ring is full, the queue is previously stopped by:

        desc_info = rocker_desc_head_get(&rocker_port->tx_ring);
        if (!desc_info)
                netif_stop_queue(dev);





>
>>+			netdev_err(dev, "tx ring full when queue awake\n");
>>+		return NETDEV_TX_BUSY;
>>+	}
>>+
>>+	rocker_desc_cookie_ptr_set(desc_info, skb);
>>+
>>+	frags = rocker_tlv_nest_start(desc_info, ROCKER_TLV_TX_FRAGS);
>>+	if (!frags)
>>+		goto out;
>>+	err = rocker_tx_desc_frag_map_put(rocker_port, desc_info,
>>+					  skb->data, skb_headlen(skb));
>>+	if (err)
>>+		goto nest_cancel;
>>+	if (skb_shinfo(skb)->nr_frags > ROCKER_TX_FRAGS_MAX)
>>+		goto nest_cancel;
>>+
>>+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>>+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
>>+
>>+		err = rocker_tx_desc_frag_map_put(rocker_port, desc_info,
>>+						  skb_frag_address(frag),
>>+						  skb_frag_size(frag));
>>+		if (err)
>>+			goto unmap_frags;
>>+	}
>>+	rocker_tlv_nest_end(desc_info, frags);
>>+
>>+	rocker_desc_gen_clear(desc_info);
>>+	rocker_desc_head_set(rocker, &rocker_port->tx_ring, desc_info);
>>+
>>+	desc_info = rocker_desc_head_get(&rocker_port->tx_ring);
>>+	if (!desc_info)
>>+		netif_stop_queue(dev);
>
>I'm not entirely sure I followed the TLV usage here but OK. If it
>works...
>
>>+
>>+	return NETDEV_TX_OK;
>>+
>>+unmap_frags:
>>+	rocker_tx_desc_frags_unmap(rocker_port, desc_info);
>>+nest_cancel:
>>+	rocker_tlv_nest_cancel(desc_info, frags);
>>+out:
>>+	dev_kfree_skb(skb);
>>+	return NETDEV_TX_OK;
>>+}
>>+
>>+static int rocker_port_set_mac_address(struct net_device *dev, void *p)
>>+{
>>+	struct sockaddr *addr = p;
>>+	struct rocker_port *rocker_port = netdev_priv(dev);
>>+	int err;
>>+
>>+	if (!is_valid_ether_addr(addr->sa_data))
>>+		return -EADDRNOTAVAIL;
>>+
>>+	err = rocker_cmd_set_port_settings_macaddr(rocker_port, addr->sa_data);
>>+	if (err)
>>+		return err;
>>+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
>>+	return 0;
>>+}
>>+
>>+static int rocker_port_sw_parent_id_get(struct net_device *dev,
>>+					struct netdev_phys_item_id *psid)
>>+{
>>+	struct rocker_port *rocker_port = netdev_priv(dev);
>>+	struct rocker *rocker = rocker_port->rocker;
>>+
>
>hmm looks like you read this out of a magic switch register :) but
>my switch doesn't have this magic reg. I suposse the switch MAC address
>should work.
>
>>+	psid->id_len = sizeof(rocker->hw.id);
>>+	memcpy(&psid->id, &rocker->hw.id, psid->id_len);
>>+	return 0;
>>+}
>>+
>>+static const struct net_device_ops rocker_port_netdev_ops = {
>>+	.ndo_open			= rocker_port_open,
>>+	.ndo_stop			= rocker_port_stop,
>>+	.ndo_start_xmit			= rocker_port_xmit,
>>+	.ndo_set_mac_address		= rocker_port_set_mac_address,
>>+	.ndo_sw_parent_id_get		= rocker_port_sw_parent_id_get,
>>+};
>>+
>>+/********************
>>+ * ethtool interface
>>+ ********************/
>>+
>>+static int rocker_port_get_settings(struct net_device *dev,
>>+				    struct ethtool_cmd *ecmd)
>>+{
>>+	struct rocker_port *rocker_port = netdev_priv(dev);
>>+
>>+	return rocker_cmd_get_port_settings_ethtool(rocker_port, ecmd);
>>+}
>>+
>>+static int rocker_port_set_settings(struct net_device *dev,
>>+				    struct ethtool_cmd *ecmd)
>>+{
>>+	struct rocker_port *rocker_port = netdev_priv(dev);
>>+
>>+	return rocker_cmd_set_port_settings_ethtool(rocker_port, ecmd);
>>+}
>>+
>>+static void rocker_port_get_drvinfo(struct net_device *dev,
>>+				    struct ethtool_drvinfo *drvinfo)
>>+{
>>+	strlcpy(drvinfo->driver, rocker_driver_name, sizeof(drvinfo->driver));
>>+	strlcpy(drvinfo->version, UTS_RELEASE, sizeof(drvinfo->version));
>>+}
>>+
>>+static const struct ethtool_ops rocker_port_ethtool_ops = {
>>+	.get_settings		= rocker_port_get_settings,
>>+	.set_settings		= rocker_port_set_settings,
>>+	.get_drvinfo		= rocker_port_get_drvinfo,
>>+	.get_link		= ethtool_op_get_link,
>>+};
>>+
>
>[...]
>
>Looks reasonable to me, although I mostly scanned it and looked
>over the interface parts. My comments are just observations no
>need to change anything for them.
>
>Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
>
>
>-- 
>John Fastabend         Intel Corporation
