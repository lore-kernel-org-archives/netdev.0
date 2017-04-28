From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW
 transmit timestamping
Date: Fri, 28 Apr 2017 18:23:25 +0200
Message-ID: <20170428162325.GA2932@localhost>
References: <20170426145035.25846-1-mlichvar@redhat.com>
 <20170426145035.25846-6-mlichvar@redhat.com>
 <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com>
 <20170428085422.GD3401@localhost>
 <CAF=yD-+DYwBbhU0fOMOj4XO+diG4-GLn6Ruh9ZMoXVv5ZS4PgQ@mail.gmail.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:49568 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939073AbdD1QX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 12:23:29 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+DYwBbhU0fOMOj4XO+diG4-GLn6Ruh9ZMoXVv5ZS4PgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 28, 2017 at 11:50:28AM -0400, Willem de Bruijn wrote:
> On Fri, Apr 28, 2017 at 4:54 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> >>   if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
> >> -        !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
> >> +      (!(skb_shinfo(orig_skb)->tx_flags & SKBTX_IN_PROGRESS)) ||
> >> +      (skb->sk && skb->sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW)
> >
> > I'm not sure if this can work. sk_buff.h would need to include sock.h
> > in order to get the definition of struct sock. Any suggestions?
> 
> A more elegant solution would be to not set SKBTX_IN_PROGRESS
> at all if SOF_TIMESTAMPING_OPT_TX_SWHW is set on the socket.
> But the patch to do so is not elegant, having to update callsites in many
> device drivers.

Also, it would change the meaning of the flag as it seems some drivers
actually use the SKBTX_IN_PROGRESS flag to check if they expect a
timestamp.

How about allocating the last bit of tx_flags for SKBTX_SWHW_TSTAMP?

> Otherwise you may indeed have to call skb_tstamp_tx for every packet
> that has SKBTX_SW_TSTAMP set, as you do. We can at least move
> the skb->sk != NULL check into skb_tx_timestamp in skbuff.h.
> 
> By the way, if changing this code, I think that it's time to get rid of
> sw_tx_timestamp. It is only called from skb_tx_timestamp. Let's
> just move the condition in there.

Ok. I assume that should be a separate patch.

-- 
Miroslav Lichvar
