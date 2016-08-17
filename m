From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V2 1/5] flow_dissector: For stripped vlan, get
 vlan info from skb->vlan_tci
Date: Wed, 17 Aug 2016 12:46:14 +0200
Message-ID: <20160817104614.GD1956@nanopsycho>
References: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
 <1471430174-27740-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <tom@herbertland.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35799 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082AbcHQKqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 06:46:18 -0400
Received: by mail-wm0-f68.google.com with SMTP id i5so22718201wmg.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 03:46:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471430174-27740-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 17, 2016 at 12:36:10PM CEST, hadarh@mellanox.com wrote:
>Early in the datapath skb_vlan_untag function is called, stripped
>the vlan from the skb and set skb->vlan_tci and skb->vlan_proto fields.
>
>The current dissection doesn't handle stripped vlan packets correctly.
>In some flows, vlan doesn't exist in skb->data anymore when applying
>flow dissection on the skb, fix that.
>
>In case vlan info wasn't stripped before applying flow_dissector (RPS
>flow for example), or in case of skb with multiple vlans (e.g. 802.1ad),
>get the vlan info from skb->data. The flow_dissector correctly skips
>any number of vlans and stores only the first level vlan.
>
>Fixes: 0744dd00c1b1 ('net: introduce skb_flow_dissect()')
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
>---
> net/core/flow_dissector.c | 34 ++++++++++++++++++++++++++--------
> 1 file changed, 26 insertions(+), 8 deletions(-)
>
>diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>index 91028ae..362d693 100644
>--- a/net/core/flow_dissector.c
>+++ b/net/core/flow_dissector.c
>@@ -119,12 +119,14 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
> 	struct flow_dissector_key_ports *key_ports;
> 	struct flow_dissector_key_tags *key_tags;
> 	struct flow_dissector_key_keyid *key_keyid;
>+	bool skip_vlan = false;
> 	u8 ip_proto = 0;
> 	bool ret = false;
> 
> 	if (!data) {
> 		data = skb->data;
>-		proto = skb->protocol;
>+		proto = skb_vlan_tag_present(skb) ?
>+			 skb->vlan_proto : skb->protocol;
> 		nhoff = skb_network_offset(skb);
> 		hlen = skb_headlen(skb);
> 	}
>@@ -243,23 +245,39 @@ ipv6:
> 	case htons(ETH_P_8021AD):
> 	case htons(ETH_P_8021Q): {
> 		const struct vlan_hdr *vlan;
>-		struct vlan_hdr _vlan;
> 
>-		vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan), data, hlen, &_vlan);
>-		if (!vlan)
>-			goto out_bad;
>+		if (skb_vlan_tag_present(skb))
>+			proto = skb->protocol;
>+
>+		if (!skb_vlan_tag_present(skb) ||
>+		    proto == cpu_to_be16(ETH_P_8021Q) ||
>+		    proto == cpu_to_be16(ETH_P_8021AD)) {

How this can happen? Could you give me an example?
