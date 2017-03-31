From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2] net: dsa: Mock-up driver
Date: Fri, 31 Mar 2017 18:06:01 +0200
Message-ID: <20170331160601.GC12814@lunn.ch>
References: <20170331014321.3248-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41919 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933149AbdCaQGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 12:06:06 -0400
Content-Disposition: inline
In-Reply-To: <20170331014321.3248-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian

> +static enum dsa_tag_protocol dsa_loop_get_protocol(struct dsa_switch *ds)
> +{
> +	dev_dbg(ds->dev, "%s\n", __func__);
> +
> +	return DSA_TAG_PROTO_NONE;
> +}

I'm wondering how safe this is:

static const struct dsa_device_ops none_ops = {
        .xmit   = dsa_slave_notag_xmit,
        .rcv    = NULL,
};

        /*
         * If the CPU connects to this switch, set the switch tree
         * tagging protocol to the preferred tagging format of this
         * switch.
         */
        if (dst->cpu_switch == ds) {
                enum dsa_tag_protocol tag_protocol;

                tag_protocol = ops->get_tag_protocol(ds);
                dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
                if (IS_ERR(dst->tag_ops))
                        return PTR_ERR(dst->tag_ops);

                dst->rcv = dst->tag_ops->rcv;
        }


static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
                          struct packet_type *pt, struct net_device *orig_dev)
{
        struct dsa_switch_tree *dst = dev->dsa_ptr;

        if (unlikely(dst == NULL)) {
                kfree_skb(skb);
                return 0;
        }

        return dst->rcv(skb, dev, pt, orig_dev);
}

static struct packet_type dsa_pack_type __read_mostly = {
        .type   = cpu_to_be16(ETH_P_XDSA),
        .func   = dsa_switch_rcv,
};

It looks like when a frame is received, we are going to dereference a
NULL pointer.

Either we need a NOP rcv function, or we don't register dsa_pack_type
if rcv is NULL.

   Andrew
