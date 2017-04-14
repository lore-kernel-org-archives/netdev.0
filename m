From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Fri, 14 Apr 2017 09:33:12 -0700
Message-ID: <CALDO+SZwdxCwsARxFKpEXEDKK8+94t-_dVdJNWiCDgx4yWUYqw@mail.gmail.com>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32768 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbdDNQdx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 12:33:53 -0400
In-Reply-To: <20170413.120925.2082322246776478766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 9:09 AM, David Miller <davem@davemloft.net> wrote:
>
[snip]


> +static u32 netif_receive_generic_xdp(struct sk_buff *skb,
> +                                    struct bpf_prog *xdp_prog)
> +{
> +       struct xdp_buff xdp;
> +       u32 act = XDP_DROP;
> +       void *orig_data;
> +       int hlen, off;
> +
> +       if (skb_linearize(skb))
> +               goto do_drop;
> +
> +       /* The XDP program wants to see the packet starting at the MAC
> +        * header.
> +        */
> +       hlen = skb_headlen(skb) + skb->mac_len;
> +       xdp.data = skb->data - skb->mac_len;
> +       xdp.data_end = xdp.data + hlen;
> +       xdp.data_hard_start = xdp.data - skb_headroom(skb);
> +       orig_data = xdp.data;
> +
> +       act = bpf_prog_run_xdp(xdp_prog, &xdp);
> +
> +       off = xdp.data - orig_data;

should we do "orig_data - xdp.data" instead?
The 'off' might be < 0, when pushing new header.

> +       if (off)
> +               __skb_push(skb, off);

When doing encapsulation by calling xdp_adjust_head(skb, offset), the
offset is < 0 in order to make extra room in the front ; so xdp.data <
orig_data, off < 0.

But if we are decapsulating protocol, then off > 0, and maybe we
should call __skb_pull()?

Thanks,
William
