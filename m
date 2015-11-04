From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: NETIF_F_GSO_SOFTWARE vs NETIF_F_GSO
Date: Wed, 4 Nov 2015 12:24:47 +0100
Message-ID: <CAHmME9rGvViDN2iFa8xfXvUJpQThJnrCcZ1yHgQrdgEQRUWtfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am making a network device driver that receives packets in
ndo_start_xmit, "does something to them", and then sends the resultant
packet out of a kernelspace UDP socket.

The routine looks something along the lines of:

    size_t outgoing_len = calculate_outgoing_length(skb);
    struct sk_buff *outgoing = alloc_skb(outgoing_len);
    u8 *output_buffer = skb_put(outgoing, outgoing_len);

    struct scatterlist sglist[MAX_SKB_FRAGS + 1] = { 0 };
    sg_init_table(sglist, skb_shinfo(skb)->nr_frags + 1);
    skb_to_sgvec(skb, sglist, 0, skb->len);

    magic_transformer state;
    begin_magic(&state, outgoing_buffer);
    for (struct scatterlist *sg = &sglist; sg; sg = sg_next(sg)) {
        u8 *vaddr = kmap_atomic(sg_page(sg));
        update_magic(&state, vaddr + sg->offset, sg->length);
        kunmap_atomic(vaddr);
    }
    finish_magic(&state);

    send_udp(outgoing);

Hopefully that's straight-forward enough. I make the skb into an
scatterlist, and then iterate over the scatterlist, to apply a
particular transformation to each part, and then finally I send it
out.

For this, I'm using these netdev features:

    #define MY_FEATURES (NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_SG \
                                             | NETIF_F_GSO | NETIF_F_HIGHDMA)
    dev->features |= MY_FEATURES;
    dev->hw_features |= MY_FEATURES;
    dev->hw_enc_features |= MY_FEATURES;

Using this set of features, everything works well. But the performance
isn't great. I suspect this has something to do with having to
traverse the network stack. So I've looked into offloading features.

Strangely, the performance does not change at all regardless of
whether or not NETIF_F_GSO is specified.

However, the performance becomes incredible when I use
NETIF_F_GSO_SOFTWARE instead of NETIF_F_GSO. But, when using
NETIF_F_GSO_SOFTWARE, skb->len is bigger than the MTU! This poses some
problems for me. Perhaps this is intended behavior? I'm not really
sure. My question is: how can I gain the performance benefits of
NETIF_F_GSO_SOFTWARE while still having skbs that fit inside the MTU?
And what's the difference between specifying NETIF_F_GSO and
NETIF_F_GSO_SOFTWARE?

Thank you,
Jason
