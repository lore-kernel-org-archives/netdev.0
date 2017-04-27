From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW
 transmit timestamping
Date: Thu, 27 Apr 2017 18:39:11 +0200
Message-ID: <20170427163911.GC3401@localhost>
References: <20170426145035.25846-1-mlichvar@redhat.com>
 <20170426145035.25846-6-mlichvar@redhat.com>
 <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com>
 <20170427161700.GB3401@localhost>
 <CAF=yD-+HK-dCG_XjqBKfkSF1bjJavTr7EFgeFNH2yRc2CXgOxA@mail.gmail.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:42164 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932573AbdD0Qj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 12:39:26 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+HK-dCG_XjqBKfkSF1bjJavTr7EFgeFNH2yRc2CXgOxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 12:21:00PM -0400, Willem de Bruijn wrote:
> >> > @@ -720,6 +720,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
> >> >                 empty = 0;
> >> >         if (shhwtstamps &&
> >> >             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
> >> > +           (empty || !skb_is_err_queue(skb)) &&
> >> >             ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
> >>
> >> I find skb->tstamp == 0 easier to understand than the condition on empty.
> >>
> >> Indeed, this is so non-obvious that I would suggest another helper function
> >> skb_is_hwtx_tstamp with a concise comment about the race condition
> >> between tx software and hardware timestamps (as in the last sentence of
> >> the commit message).
> >
> > Should it include also the skb_is_err_queue() check? If it returned
> > true for both TX and RX HW timestamps, maybe it could be called
> > skb_has_hw_tstamp?
> 
> For the purpose of documenting why this complex condition exists,
> I would call the skb_is_err_queue in that helper function and make
> it tx + hw specific.

Hm, like this?

        if (shhwtstamps &&
            (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
+           (skb_is_hwtx_tstamp(skb) || !skb_is_err_queue(skb)) &&
            ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {

where skb_is_hwtx_tstamp() has
	return skb->tstamp == 0 && skb_is_err_queue(skb);

I was just not sure about the unnecessary skb_is_err_queue() call.

-- 
Miroslav Lichvar
