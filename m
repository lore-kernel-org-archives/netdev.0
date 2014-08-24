From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v3 09/12] net: dsa: add Broadcom tag RX/TX handler
Date: Sun, 24 Aug 2014 15:51:01 -0700
Message-ID: <53FA6C55.5040903@gmail.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com> <1408905869-10471-10-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:61916 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461AbaHXWvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 18:51:06 -0400
Received: by mail-pd0-f176.google.com with SMTP id y10so18810784pdj.7
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 15:51:06 -0700 (PDT)
In-Reply-To: <1408905869-10471-10-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2014 11:44 AM, Florian Fainelli wrote:
> Add support for the 4-bytes Broadcom tag that built-in switches such as
> the Starfighter 2 might insert when receiving packets, or that we need
> to insert while targetting specific switch ports. We use a fake
> EtherType field for this 4-bytes switch tag: ETH_P_BRCMTAG since we need
> to use the skb->protocol override in the receive path.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v3:
> - add ETH_P_BRCMTAG as part of this changeset and not in a previous patch
> - fixed an early de-reference in the receive hook

I was just wondering.  Is there a reason we need to register this as yet
another protocol?

It seems like we should be able to just register one DSA tag protocol
and then we could push the parsing function out to a function pointer
contained in the DSA switch structure.  My concern is that as we add
each new switch message format we are looking at the potential for yet
another Ethertype and they are a limited resource.

So for example in the section below you already have to dig out the
dsa_switch structure and tree before you even start processing the
headers. 

> +
> +static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
> +			struct packet_type *pt, struct net_device *orig_dev)
> +{
> +	struct dsa_switch_tree *dst = dev->dsa_ptr;
> +	struct dsa_switch *ds;
> +	int source_port;
> +	u8 *brcm_tag;
> +
> +	if (unlikely(dst == NULL))
> +		goto out_drop;
> +
> +	ds = dst->ds[0];
> +
> +	skb = skb_unshare(skb, GFP_ATOMIC);
> +	if (skb == NULL)
> +		goto out;

At this point here we already have the dsa pointers and could just pull
up a function pointer so all of the code below could potentially be
moved into a separate function allowing us to drop the need to have
multiple Ethertypes and so we could just use ETH_P_DSA for all DSA
tagging type.  We could then also rewrite the check for if we need to
insert a DSA tag to simply check for if this function pointer is set or not.

> +	if (unlikely(!pskb_may_pull(skb, BRCM_TAG_LEN)))
> +		goto out_drop;
> +
> +	/* skb->data points to the EtherType, the tag is right before it */
> +	brcm_tag = skb->data - 2;
> +
> +	/* The opcode should never be different than 0b000 */
> +	if (unlikely((brcm_tag[0] >> BRCM_OPCODE_SHIFT) & BRCM_OPCODE_MASK))
> +		goto out_drop;
> +
> +	/* We should never see a reserved reason code without knowing how to
> +	 * handle it
> +	 */
> +	WARN_ON(brcm_tag[2] & BRCM_EG_RC_RSVD);
> +
> +	/* Locate which port this is coming from */
> +	source_port = brcm_tag[3] & BRCM_EG_PID_MASK;
> +
> +	/* Validate port against switch setup, either the port is totally */
> +	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
> +		goto out_drop;
> +
> +	/* Remove Broadcom tag and update checksum */
> +	skb_pull_rcsum(skb, BRCM_TAG_LEN);
> +
> +	/* Move the Ethernet DA and SA */
> +	memmove(skb->data - ETH_HLEN,
> +		skb->data - ETH_HLEN - BRCM_TAG_LEN,
> +		2 * ETH_ALEN);
> +
> +	skb_push(skb, ETH_HLEN);
> +	skb->pkt_type = PACKET_HOST;
> +	skb->dev = ds->ports[source_port];
> +	skb->protocol = eth_type_trans(skb, skb->dev);
> +
> +	skb->dev->stats.rx_packets++;
> +	skb->dev->stats.rx_bytes += skb->len;
> +
> +	netif_receive_skb(skb);
> +
> +	return 0;
> +
> +out_drop:
> +	kfree_skb(skb);
> +out:
> +	return 0;
> +}
> +
> +struct packet_type brcm_tag_packet_type __read_mostly = {
> +	.type	= cpu_to_be16(ETH_P_BRCMTAG),
> +	.func	= brcm_tag_rcv,
> +};
