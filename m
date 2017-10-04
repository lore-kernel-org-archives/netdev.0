From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [Bridge] [PATCH net-next v4 2/3] bridge: suppress arp pkts on
 BR_NEIGH_SUPPRESS ports
Date: Wed, 4 Oct 2017 16:35:27 +0900
Message-ID: <7b8bf9e3-b34c-38c3-4935-9136f7aa2d2d@lab.ntt.co.jp>
References: <1507093953-59929-1-git-send-email-roopa@cumulusnetworks.com>
 <1507093953-59929-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:44018 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750945AbdJDHgX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 03:36:23 -0400
In-Reply-To: <1507093953-59929-3-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/10/04 14:12, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch avoids flooding and proxies arp packets
> for BR_NEIGH_SUPPRESS ports.
> 
> Moves existing br_do_proxy_arp to br_do_proxy_suppress_arp
> to support both proxy arp and neigh suppress.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
...
> +static void br_arp_send(struct net_bridge_port *p, int type, int ptype,

type and ptype are always the same so seems unnecessary.

> +			__be32 dest_ip, struct net_device *dev,
> +			__be32 src_ip, const unsigned char *dest_hw,
> +			const unsigned char *src_hw,
> +			const unsigned char *target_hw,
> +			__be16 vlan_proto, u16 vlan_tci)
> +{
> +	struct sk_buff *skb;
> +
> +	netdev_dbg(dev, "arp send dev %s dst %pI4 dst_hw %pM src %pI4 src_hw %pM\n",
> +		   dev->name, &dest_ip, dest_hw, &src_ip, src_hw);
> +
> +	if (!vlan_tci) {
> +		arp_send(type, ptype, dest_ip, dev, src_ip,
> +			 dest_hw, src_hw, target_hw);

I may be missing something, but wouldn't it send arp reply from the
bridge device, while it should be received to the bridge device, when p
== NULL?

> +		return;
> +	}
> +
> +	skb = arp_create(type, ptype, dest_ip, dev, src_ip,
> +			 dest_hw, src_hw, target_hw);
> +	if (!skb)
> +		return;
> +
> +	if (p) {

Why doesn't bridge device consider pvid?

> +		struct net_bridge_vlan_group *vg;
> +		u16 pvid;
> +
> +		vg = nbp_vlan_group_rcu(p);
> +		pvid = br_get_pvid(vg);
> +		if (pvid == vlan_tci)

Need vlan_tci & VLAN_VID_MASK
Or use skb_vlan_tag_get_id() in caller side.

> +			vlan_tci = 0;
> +	}
> +
> +	if (vlan_tci) {
> +		skb = vlan_insert_tag_set_proto(skb, vlan_proto,
> +						vlan_tci);

Should be __vlan_hwaccel_put_tag()

> +		if (!skb) {
> +			net_err_ratelimited("%s: failed to insert VLAN tag\n",
> +					    __func__);
> +			return;
> +		}
> +	}
> +
> +	arp_xmit(skb);
> +}
...
> +void br_do_proxy_suppress_arp(struct sk_buff *skb, struct net_bridge *br,
> +			      u16 vid, struct net_bridge_port *p)
> +{
...
> +	if (br->neigh_suppress_enabled) {
> +		if (p && (p->flags & BR_NEIGH_SUPPRESS))
> +			return;
> +		if (ipv4_is_zeronet(sip) || sip == tip) {
> +			/* prevent flooding to neigh suppress ports */
> +			BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
> +			return;
> +		}
> +	}
> +
> +	if (parp->ar_op != htons(ARPOP_REQUEST))
> +		return;
> +
> +	if (vid != 0) {

vid should be 0 if untagged is set on the bridge device?

> +		vlandev = __vlan_find_dev_deep_rcu(br->dev, skb->vlan_proto,
> +						   vid);
> +		if (!vlandev)
> +			return;
> +	}
> +
> +	if (br->neigh_suppress_enabled && br_is_local_ip(vlandev, tip)) {
> +		/* its our local ip, so don't proxy reply
> +		 * and don't forward to neigh suppress ports
> +		 */
> +		BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
> +		return;
> +	}

-- 
Toshiaki Makita
