From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW
 transmit timestamping
Date: Thu, 27 Apr 2017 18:17:00 +0200
Message-ID: <20170427161700.GB3401@localhost>
References: <20170426145035.25846-1-mlichvar@redhat.com>
 <20170426145035.25846-6-mlichvar@redhat.com>
 <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52948 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939250AbdD0QRE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 12:17:04 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 08:00:02PM -0400, Willem de Bruijn wrote:
> > +       if (!hwtstamps && !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW) &&
> > +           skb_shinfo(orig_skb)->tx_flags & SKBTX_IN_PROGRESS)
> > +               return;
> > +
> 
> This check should only happen for software transmit timestamps, so simpler to
> revise the check in sw_tx_timestamp above to
> 
>   if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
> -        !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
> +      (!(skb_shinfo(orig_skb)->tx_flags & SKBTX_IN_PROGRESS)) ||
> +      (skb->sk && skb->sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW)

Good point. This will avoid unnecessary calls of skb_tstamp_tx() in
the common case when SOF_TIMESTAMPING_OPT_TX_SWHW will not be enabled.

> > @@ -720,6 +720,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
> >                 empty = 0;
> >         if (shhwtstamps &&
> >             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
> > +           (empty || !skb_is_err_queue(skb)) &&
> >             ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
> 
> I find skb->tstamp == 0 easier to understand than the condition on empty.
> 
> Indeed, this is so non-obvious that I would suggest another helper function
> skb_is_hwtx_tstamp with a concise comment about the race condition
> between tx software and hardware timestamps (as in the last sentence of
> the commit message).

Should it include also the skb_is_err_queue() check? If it returned
true for both TX and RX HW timestamps, maybe it could be called
skb_has_hw_tstamp?

-- 
Miroslav Lichvar
