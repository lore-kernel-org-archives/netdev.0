From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: NETIF_F_GSO_SOFTWARE vs NETIF_F_GSO
Date: Fri, 6 Nov 2015 02:31:59 +0100
Message-ID: <CAHmME9ruZb=F+Nv5BqfS+9gEL4FriCgGkaD6Pvy2iD1FXv0EQg@mail.gmail.com>
References: <CAHmME9rGvViDN2iFa8xfXvUJpQThJnrCcZ1yHgQrdgEQRUWtfg@mail.gmail.com>
	<20151105121501.GA5776@gondor.apana.org.au>
	<CAHmME9pP1E64CCc7+XW8X1duYGQZdYj9s_r8UNq3KMh6xey_Hw@mail.gmail.com>
	<1446738967.4184.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHmME9ptruMW4MFZ1q3=tgTANro1_CdwnCWS5O_0_WwbFKgUAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9ptruMW4MFZ1q3=tgTANro1_CdwnCWS5O_0_WwbFKgUAw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

I'm still facing some considerable problems. Please see below.

On Thu, Nov 5, 2015 at 5:28 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> As mentioned, I receive packets on ndo_start_xmit, "do something to
> them with function magic()", and then push them out of a UDP socket
> using udp_tunnel_xmit_skb. There appears to be significant overhead
> from calling udp_tunnel_xmit_skb over and over. What I'd really like
> to do is pass the NETIF_F_GSO_SOFTWARE-provided super packet directly
> to udp_tunnel_xmit_skb, but in fact the magic() function mentioned
> above needs to work on an entire MTU-sized IP packet, not a a super
> packet. So, instead, what it's looking like is:
>
> 1. Set NETIF_F_GSO_SOFTWARE to receive super packets.
> 2. For each super packet, break it down using skb_gso_segment().
>      2a. For each segmented packet, "do my magic() function"
> 3. After having done the magic() to each of the segmented packets, I
> *repack the results* into a new super packet. I then pass that super
> packet to udp_tunnel_xmit_skb().
>
> Is this approach a real possibility?
>
> If so, it seems like the best way to get GSO-like qualities out of
> udp_tunnel_xmit_skb. I've successfully done (1) and (2), following the
> example of validate_xmit_skb() from net/core/dev.c. Now I need to
> figure out how to do (3). Hopefully I'll find some nice convenience
> functions for this...

So far implementing (3) is failing miserably. Is there anything wrong
with my general idea that might make this a priori impossible? For
example, will udp_tunnel_xmit_skb not accept super-packets? Or, am I
just not making use of whatever nice convenience functions are
available for constructing super-packets, and thus am doing something
wrong?

Currently, I'm doing essentially what follows below. It seems like it
ought to be working, but it's not.


    gso_segs = DIV_ROUND_UP(skb->len, skb_shinfo(skb)->gso_size);
    segs = skb_gso_segment(skb, 0);
    if (IS_ERR(segs)) {
        kfree_skb(skb);
        return PTR_ERR(segs);
    }
    dev_kfree_skb(skb);

    gso_size = magic_len(segs->len);
    len = gso_size * gso_segs;

    outgoing = alloc_skb(len, GFP_ATOMIC);
    if (!outgoing) {
        kfree_skb_list(segs);
        return -ENOMEM;
    }
    skb_shinfo(outgoing)->gso_type = SKB_GSO_UDP;
    skb_shinfo(outgoing)->gso_size = gso_size;
    skb_shinfo(outgoing)->gso_segs = 0;
    outgoing->ip_summed = CHECKSUM_PARTIAL;

    src = segs;
    while (src) {
        next = src->next;
        dst_buffer = skb_put(outgoing, magic_len(src->len));
        ret = do_magic(dst_buffer, src);
        if (ret) {
            dev_kfree_skb(outgoing);
            return ret;
        }
        ++skb_shinfo(outgoing)->gso_segs;
        src = next;
    }
    return eventually_udp_tunnel_xmit_skb(outgoing);


Let me know if there is something fundamentally wrong with this
approach. Or if you have any other pointers...

Regards,
Jason
