From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/3] net-next: dsa: add Qualcomm tag RX/TX handler
Date: Mon, 12 Sep 2016 14:26:58 +0200
Message-ID: <20160912122658.GA17533@lunn.ch>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-3-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41490 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758208AbcILM1E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 08:27:04 -0400
Content-Disposition: inline
In-Reply-To: <1473669337-21221-3-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John

> +
> +static inline int reg_to_port(int reg)
> +{
> +	if (reg < 5)
> +		return reg + 1;
> +
> +	return -1;
> +}
> +
> +static inline int port_to_reg(int port)
> +{
> +	if (port >= 1 && port <= 6)
> +		return port - 1;
> +
> +	return -1;
> +}

No need for inline, leave the compiler to decide.

> +
> +static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	u16 *phdr, hdr;
> +
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += skb->len;
> +
> +	if (skb_cow_head(skb, 0) < 0)
> +		goto out_free;
> +
> +	skb_push(skb, QCA_HDR_LEN);
> +
> +	memmove(skb->data, skb->data + QCA_HDR_LEN, 2 * ETH_ALEN);
> +	phdr = (u16 *)(skb->data + 2 * ETH_ALEN);
> +
> +	/* Set the version field, and set destination port information */
> +	hdr = QCA_HDR_VERSION << QCA_HDR_XMIT_VERSION_S |
> +		QCA_HDR_XMIT_FROM_CPU |
> +		1 << reg_to_port(p->port);
> +
> +	*phdr = htons(hdr);
> +
> +	//skb->dev = p->parent->dst->master_netdev;
> +	//dev_queue_xmit(skb);

No commented out code please.

> +
> +	return skb;
> +
> +out_free:
> +	kfree_skb(skb);
> +	return NULL;
> +}
> +
> +static int qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
> +		       struct packet_type *pt, struct net_device *orig_dev)
> +{
> +	struct dsa_switch_tree *dst = dev->dsa_ptr;
> +	struct dsa_switch *ds;
> +	u8 ver;
> +	int port, phy;
> +	__be16 *phdr, hdr;
> +
> +	if (unlikely(!dst))
> +		goto out_drop;
> +
> +	skb = skb_unshare(skb, GFP_ATOMIC);
> +	if (!skb)
> +		goto out;
> +
> +	if (unlikely(!pskb_may_pull(skb, QCA_HDR_LEN)))
> +		goto out_drop;
> +
> +	/* Ethernet is added by the switch between src addr and Ethertype

'Ethernet' seems to be the wrong word here.

> +
> +	/* Get source port information */
> +	port = (hdr & QCA_HDR_RECV_SOURCE_PORT_MASK);
> +	phy = port_to_reg(port);
> +	if (unlikely(phy < 0) || !ds->ports[phy].netdev)
> +		goto out_drop;

Could you use a different variable name than phy. phy has a well known
meaning, and this usage is not it.

Otherwise, this looks good.

	   Andrew
