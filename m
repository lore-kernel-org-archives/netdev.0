From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [RFC PATCH 3/7] net: add option to get information about
 timestamped packets
Date: Mon, 24 Apr 2017 11:00:43 +0200
Message-ID: <20170424090043.GF8847@localhost>
References: <20170412141737.5881-1-mlichvar@redhat.com>
 <20170412141737.5881-4-mlichvar@redhat.com>
 <CAF=yD-Lsbr7f7aPUsFF3gCtFdyR8yb1=VBPJGQuxv_JbrJud6Q@mail.gmail.com>
 <20170413151806.GA26613@localhost>
 <CAF=yD-+tJpY7XJrqxga=0_kn-FjS0M=yuu59m_ZRRrrcpJCbZw@mail.gmail.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:49908 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1167290AbdDXJAr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 05:00:47 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+tJpY7XJrqxga=0_kn-FjS0M=yuu59m_ZRRrrcpJCbZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 12:16:09PM -0400, Willem de Bruijn wrote:
> On Thu, Apr 13, 2017 at 11:18 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > On Thu, Apr 13, 2017 at 10:37:07AM -0400, Willem de Bruijn wrote:
> >> Why is this L2 length needed?
> >
> > It's needed for incoming packets to allow converting of preamble
> > timestamps to trailer timestamps.
> 
> Receiving the mac length of a packet sounds like a feature independent
> from timestamping.

I agree, but so far nobody suggested another use for this information.
Do you have any suggestions?

The idea was that if it is useful only with HW timestamping, it would
be better to save it only with the timestamp, so there is no
performance impact in the more common case when HW timestamping is
disabled. Am I overly cautious here?

> Either an ioctl similar to SIOCGIFMTU or, if it may
> vary due to existince of vlan headers, a new independent cmsg at the
> SOL_SOCKET layer.

It's not just the VLAN headers. The length of the IP header may vary
with IP options, so the offset of the UDP data in the packet cannot be
assumed to be constant.

Now I'm wondering if it's actually necessary to save the original
value of skb->mac_len + skb->len. Would "skb->data - skb->head -
skb->mac_header + skb->len" always work as the L2 length for received
packets at the time when the cmsg is prepared?

As for the original ifindex, it seems to me it does need to be saved
to a new field since __netif_receive_skb_core() intentionally
overwrites skb->skb_iif. What would be the best place for it, sk_buff
or skb_shared_info?

And would it really be acceptable to save it for all packets in
__netif_receive_skb_core(), even when HW timestamping is disabled?
Seeing how the code and the data structures were optimized over time,
I have a feeling it would not be accepted.

-- 
Miroslav Lichvar
