From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next 3/4] rocker: add fwd_mark support
Date: Sun, 14 Jun 2015 09:02:56 +0200
Message-ID: <20150614070256.GC2105@nanopsycho.orion>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
 <1434218670-43821-4-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	roopa@cumulusnetworks.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:38416 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbbFNHC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 03:02:59 -0400
Received: by wibdq8 with SMTP id dq8so48704048wib.1
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 00:02:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434218670-43821-4-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jun 13, 2015 at 08:04:29PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>If device flags ingress packet as "fwd offload", mark the skb->fwd_mark
>using the ingress port's dev->fwd_mark.  This will be the hint to the
>kernel that this packet has already been forwarded by device to egress
>ports matching skb->fwd_mark.
>
>For rocker, derive port dev->fwd_mark based on device switch ID.  If port
>is bridged, include the bridge's ifindex in the key for deriving
>dev->fwd_mark.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> drivers/net/ethernet/rocker/rocker.c |   24 ++++++++++++++++++++++++
> drivers/net/ethernet/rocker/rocker.h |    1 +
> 2 files changed, 25 insertions(+)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index a06b93d..81407d8 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -4701,6 +4701,7 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
> 	const struct rocker_tlv *attrs[ROCKER_TLV_RX_MAX + 1];
> 	struct sk_buff *skb = rocker_desc_cookie_ptr_get(desc_info);
> 	size_t rx_len;
>+	u16 rx_flags = 0;
> 
> 	if (!skb)
> 		return -ENOENT;
>@@ -4708,6 +4709,8 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
> 	rocker_tlv_parse_desc(attrs, ROCKER_TLV_RX_MAX, desc_info);
> 	if (!attrs[ROCKER_TLV_RX_FRAG_LEN])
> 		return -EINVAL;
>+	if (attrs[ROCKER_TLV_RX_FLAGS])
>+		rx_flags = rocker_tlv_get_u16(attrs[ROCKER_TLV_RX_FLAGS]);
> 
> 	rocker_dma_rx_ring_skb_unmap(rocker, attrs);
> 
>@@ -4715,6 +4718,9 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
> 	skb_put(skb, rx_len);
> 	skb->protocol = eth_type_trans(skb, rocker_port->dev);
> 
>+	if (rx_flags & ROCKER_RX_FLAGS_FWD_OFFLOAD)

Nasty :) I'm not sure that this can be easily done for real hw. But
anyway, that is a driver problem.


>+		skb->fwd_mark = rocker_port->dev->fwd_mark;
>+
> 	rocker_port->dev->stats.rx_packets++;
> 	rocker_port->dev->stats.rx_bytes += skb->len;
> 
>@@ -4814,6 +4820,21 @@ static void rocker_port_dev_addr_init(struct rocker_port *rocker_port)
> 	}
> }
> 
>+static void rocker_port_fwd_mark_set(struct rocker_port *rocker_port)
>+{
>+	struct rocker *rocker = rocker_port->rocker;
>+	struct {
>+		u64 hw_id;
>+		int ifindex;
>+	} key = {
>+		.hw_id = rocker->hw.id,
>+		.ifindex = rocker_port_is_bridged(rocker_port) ?
>+			   rocker_port->bridge_dev->ifindex : 0,
>+	};
>+
>+	rocker_port->dev->fwd_mark = switchdev_mark_get(&key, sizeof(key));
>+}
>+
> static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
> {
> 	const struct pci_dev *pdev = rocker->pdev;
>@@ -4832,6 +4853,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
> 	rocker_port->pport = port_number + 1;
> 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
> 	INIT_LIST_HEAD(&rocker_port->trans_mem);
>+	rocker_port_fwd_mark_set(rocker_port);
> 
> 	rocker_port_dev_addr_init(rocker_port);
> 	dev->netdev_ops = &rocker_port_netdev_ops;
>@@ -5131,6 +5153,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
> 		rocker_port_internal_vlan_id_get(rocker_port, bridge->ifindex);
> 
> 	rocker_port->bridge_dev = bridge;
>+	rocker_port_fwd_mark_set(rocker_port);
> 
> 	return rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
> 				    untagged_vid, 0);
>@@ -5152,6 +5175,7 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
> 						 rocker_port->dev->ifindex);
> 
> 	rocker_port->bridge_dev = NULL;
>+	rocker_port_fwd_mark_set(rocker_port);


Hmm, wouldn't it make sense to move fwd_mark setting from drivers to
switchdev core? This will look the same for all drivers, so I think it
should be in common swithdev core, always generated according to "switch id".

So all what driver needs to do is to call some helper like:
static inline void switchdev_skb_fwd_mark(struct sk_buff *skb,
					  struct net_device *dev) {
	skb->fwd_mark = dev->fwd_mark;
}
