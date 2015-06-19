From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next RFC v2 3/3] mpls: support for ip tunnels
Date: Fri, 19 Jun 2015 17:06:45 +0100
Message-ID: <55843E15.2040301@brocade.com>
References: <1434689355-4088-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>,
	<tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:35274 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752116AbbFSQHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 12:07:07 -0400
In-Reply-To: <1434689355-4088-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/06/15 05:49, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Support ip mpls tunnels using the new lwt infrastructure.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
...
> +int mpls_output(struct sock *sk, struct sk_buff *skb)
> +{
> +	struct mpls_iptunnel_encap *tun_encap_info;
> +	struct mpls_shim_hdr *hdr;
> +	struct mpls_entry_decoded dec;
> +	struct net_device *out_dev;
> +	unsigned int hh_len;
> +	unsigned int new_header_size;
> +	unsigned int mtu;
> +	struct lwtunnel_state *lwtstate;
> +	struct rtable *rt = skb_rtable(skb);
> +	int err;
> +	bool bos;
> +	int i;
> +
> +	if (skb->pkt_type != PACKET_HOST)
> +		goto drop;
> +
> +	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
> +		goto drop;
> +
> +	if (!rt)
> +		goto drop;
> +
> +	/* Find the output device */
> +	out_dev = rcu_dereference(skb_dst(skb)->dev);

Since the entire label stack and the output device is encoded in the 
route, this means that you won't get prefix-independent convergence with 
this implementation for an IGP route change. I.e. if you've got 10 
million VPN routes via an IGP route for the BGP nexthop, and the IGP 
route for the BGP nexthop changes (e.g. because a link has gone down 
somewhere in the network) then you'll have to update all 10 million IP 
routes to change the output device, gateway and IGP label.

That's going to represent a scaling obstacle for one of the primary MPLS 
use cases.

> +	if (!mpls_output_possible(out_dev))
> +		goto drop;
> +
> +	if (skb_warn_if_lro(skb))
> +		goto drop;
> +	skb_forward_csum(skb);
> +
> +	lwtstate = rt->rt_lwtstate;
> +	if (!lwtstate)
> +		goto drop;
> +
> +	tun_encap_info = mpls_lwt_hdr(lwtstate);
> +
> +	/* Verify the destination can hold the packet */
> +	new_header_size = mpls_encap_size(tun_encap_info);
> +	mtu = mpls_dev_mtu(out_dev);
> +	if (mpls_pkt_too_big(skb, mtu - new_header_size))
> +		goto drop;
> +
> +	hh_len = LL_RESERVED_SPACE(out_dev);
> +	if (!out_dev->header_ops)
> +		hh_len = 0;
> +
> +	/* Ensure there is enough space for the headers in the skb */
> +	if (skb_cow(skb, hh_len + new_header_size))
> +		goto drop;
> +
> +	skb->dev = out_dev;
> +	skb->protocol = htons(ETH_P_MPLS_UC);
> +
> +	skb_push(skb, new_header_size);
> +	skb_reset_network_header(skb);
> +
> +	/* Push the new labels */
> +	hdr = mpls_hdr(skb);
> +	bos = true;
> +	for (i = tun_encap_info->labels - 1; i >= 0; i--) {
> +		hdr[i] = mpls_entry_encode(tun_encap_info->label[i],
> +					   dec.ttl, 0, bos);

dec is never initialised in this function, so this will encode a garbage 
ttl into the packet.

This should instead be deriving the ttl from the IP packet, as Eric did 
in his original patch.

Thanks,
Rob

> +		bos = false;
> +	}
> +
> +	err = neigh_xmit(NEIGH_ARP_TABLE, out_dev, &rt->rt_gateway,
> +			 skb);
> +	if (err)
> +		net_dbg_ratelimited("%s: packet transmission failed: "
> +					"%d\n", __func__, err);
> +
> +	return 0;
> +
> +drop:
> +	kfree_skb(skb);
> +	return -EINVAL;
> +}
