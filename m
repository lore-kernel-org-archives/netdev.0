From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: Extend SOF_TIMESTAMPING_RX_SOFTWARE to
 TCP recvmsg
Date: Tue, 22 Aug 2017 14:57:32 -0400
Message-ID: <CAF=yD-KM9N_ZAVe2p+NSAq8O1eX1Hm6Z15gCH7XjGqMSmPsCfA@mail.gmail.com>
References: <20170822172703.31703-1-maloneykernel@gmail.com> <20170822172703.31703-2-maloneykernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Mike Maloney <maloney@google.com>
To: Mike Maloney <maloneykernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:37250 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752235AbdHVS6Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:58:16 -0400
Received: by mail-oi0-f68.google.com with SMTP id k77so5765747oib.4
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 11:58:15 -0700 (PDT)
In-Reply-To: <20170822172703.31703-2-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 1:27 PM, Mike Maloney <maloneykernel@gmail.com> wrote:
> From: Mike Maloney <maloney@google.com>
>
> When SOF_TIMESTAMPING_RX_SOFTWARE is enabled for tcp sockets, return the
> timestamp corresponding to the highest sequence number data returned.
>
> Previously the skb->tstamp is overwritten when a TCP packet is placed
> in the out of order queue.  While the packet is in the ooo queue, save the
> timestamp in the TCB_SKB_CB.  This space is shared with the gso_*
> options which are only used on the tx path, and a previously unused 4
> byte hole.
>
> When skbs are coalesced either in the sk_receive_queue or the
> out_of_order_queue always choose the timestamp of the appended skb to
> maintain the invariant of returning the timestamp of the last byte in
> the recvmsg buffer.
>

> +static void tcp_update_recv_tstamps(struct sk_buff *skb,
> +                                   struct scm_timestamping *tss)
> +{
> +       if (skb->tstamp)
> +               tss->ts[0] = ktime_to_timespec(skb->tstamp);
> +       else
> +               tss->ts[0] = (struct timespec) {0};
> +
> +       if (skb_hwtstamps(skb)->hwtstamp)
> +               tss->ts[2] = ktime_to_timespec(skb_hwtstamps(skb)->hwtstamp);
> +       else
> +               tss->ts[2] = (struct timespec) {0};

tss->ts[1] may remain uninitialized.
