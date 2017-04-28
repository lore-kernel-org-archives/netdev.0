From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW
 transmit timestamping
Date: Fri, 28 Apr 2017 10:54:22 +0200
Message-ID: <20170428085422.GD3401@localhost>
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
Received: from mx1.redhat.com ([209.132.183.28]:47504 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754645AbdD1IyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 04:54:25 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 08:00:02PM -0400, Willem de Bruijn wrote:
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 81ef53f..42bff22 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -3300,8 +3300,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
> >
> >  static inline void sw_tx_timestamp(struct sk_buff *skb)
> >  {
> > -       if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
> > -           !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
> > +       if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP)
> >                 skb_tstamp_tx(skb, NULL);
> >  }

> > +++ b/net/core/skbuff.c
> > @@ -3874,6 +3874,10 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
> >         if (!sk)
> >                 return;
> >
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

I'm not sure if this can work. sk_buff.h would need to include sock.h
in order to get the definition of struct sock. Any suggestions?

-- 
Miroslav Lichvar
