From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [Intel-wired-lan] [PATCH V2 RFC 2/2] ixgbe: ixgbe_atr() compute
 l4_proto only if non-paged data has network/transport headers
Date: Mon, 17 Oct 2016 15:18:04 -0400
Message-ID: <20161017191804.GE15976@oracle.com>
References: <cover.1476724638.git.sowmini.varadhan@oracle.com>
 <ff985fc71358a90f7a97ca176abb96845852269e.1476724638.git.sowmini.varadhan@oracle.com>
 <CAKgT0Uee88Vh8aHDDzMBZojGjkEz_Po5AKq+6yJ2tVambzH8zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24559 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934034AbcJQTSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 15:18:13 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0Uee88Vh8aHDDzMBZojGjkEz_Po5AKq+6yJ2tVambzH8zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/17/16 11:15), Alexander Duyck wrote:
> I would say you probably only need the first check here for skb->data
> and could probably skip the second part.  You will be testing for
> skb_tail_pointer in all the other tests you added so this check is
> redundant anyway.
> 
> Also you might want to go through and wrap these with unlikely() since
> most of these are exception cases.

Ok.. v3 will have this.

> >         /* Currently only IPv4/IPv6 with TCP is supported */
> >         switch (hdr.ipv4->version) {
> >         case IPVERSION:
> >                 /* access ihl as u8 to avoid unaligned access on ia64 */
> >                 hlen = (hdr.network[0] & 0x0F) << 2;
> > +               if (skb_tail_pointer(skb) < hdr.network + hlen +
> > +                                           sizeof(struct tcphdr))
> > +                       return;
> >                 l4_proto = hdr.ipv4->protocol;
> >                 break;
> >         case 6:
> >                 hlen = hdr.network - skb->data;
> > +               if (skb_tail_pointer(skb) < hdr.network + hlen +
> > +                                           sizeof(struct tcphdr))
> > +                       return;
> >                 l4_proto = ipv6_find_hdr(skb, &hlen, IPPROTO_TCP, NULL, NULL);
> >                 hlen -= hdr.network - skb->data;
> >                 break;
> 
> I believe one more check is needed after this block to verify the TCP
> header fields are present.
> 
> So you probably need to add a check for "skb_tail_pointer(skb) <
> (hdr.network + hlen + 20)".

But isnt that the same thing as the checks before l4_proto computation above?

--Sowmini
