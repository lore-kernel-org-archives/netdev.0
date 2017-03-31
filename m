From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2] net: dsa: Mock-up driver
Date: Fri, 31 Mar 2017 09:40:37 -0700
Message-ID: <3952b60b-1c24-487d-7f8d-9cad5dc69dcc@gmail.com>
References: <20170331014321.3248-1-f.fainelli@gmail.com>
 <20170331160601.GC12814@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35379 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933159AbdCaQks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 12:40:48 -0400
Received: by mail-wm0-f65.google.com with SMTP id z133so600065wmb.2
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 09:40:47 -0700 (PDT)
In-Reply-To: <20170331160601.GC12814@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 03/31/2017 09:06 AM, Andrew Lunn wrote:
> Hi Florian
> 
>> +static enum dsa_tag_protocol dsa_loop_get_protocol(struct dsa_switch *ds)
>> +{
>> +	dev_dbg(ds->dev, "%s\n", __func__);
>> +
>> +	return DSA_TAG_PROTO_NONE;
>> +}
> 
> I'm wondering how safe this is:
> 
> static const struct dsa_device_ops none_ops = {
>         .xmit   = dsa_slave_notag_xmit,
>         .rcv    = NULL,
> };
> 
>         /*
>          * If the CPU connects to this switch, set the switch tree
>          * tagging protocol to the preferred tagging format of this
>          * switch.
>          */
>         if (dst->cpu_switch == ds) {
>                 enum dsa_tag_protocol tag_protocol;
> 
>                 tag_protocol = ops->get_tag_protocol(ds);
>                 dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
>                 if (IS_ERR(dst->tag_ops))
>                         return PTR_ERR(dst->tag_ops);
> 
>                 dst->rcv = dst->tag_ops->rcv;
>         }
> 
> 
> static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
>                           struct packet_type *pt, struct net_device *orig_dev)
> {
>         struct dsa_switch_tree *dst = dev->dsa_ptr;
> 
>         if (unlikely(dst == NULL)) {
>                 kfree_skb(skb);
>                 return 0;
>         }
> 
>         return dst->rcv(skb, dev, pt, orig_dev);
> }
> 
> static struct packet_type dsa_pack_type __read_mostly = {
>         .type   = cpu_to_be16(ETH_P_XDSA),
>         .func   = dsa_switch_rcv,
> };
> 
> It looks like when a frame is received, we are going to dereference a
> NULL pointer.

Actually we do not, because netdev_uses_dsa() returns true only when
dst->rcv is different from NULL. When dst->rcv is NULL we completely
bypass the DSA hook in eth_type_trans() and everything is well, the
master network device is the one receiving packets.

This is actually the intended behavior for netdev_uses_dsa() because it
really tells whether there is a DSA tagging protocol set-up and that is
what NIC drivers (e.g: bcmsysport) would care about.

Thanks!
-- 
Florian
