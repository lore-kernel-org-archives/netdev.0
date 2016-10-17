From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [Intel-wired-lan] [PATCH V2 RFC 2/2] ixgbe: ixgbe_atr() compute
 l4_proto only if non-paged data has network/transport headers
Date: Mon, 17 Oct 2016 17:16:40 -0400
Message-ID: <20161017211640.GA17226@oracle.com>
References: <cover.1476724638.git.sowmini.varadhan@oracle.com>
 <ff985fc71358a90f7a97ca176abb96845852269e.1476724638.git.sowmini.varadhan@oracle.com>
 <CAKgT0Uee88Vh8aHDDzMBZojGjkEz_Po5AKq+6yJ2tVambzH8zw@mail.gmail.com>
 <20161017191804.GE15976@oracle.com>
 <CAKgT0UcGy_fD6HYxfzO_xoWOcB+Cjf38Qon8ZdWxyTNtzP7-=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28590 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964894AbcJQVQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 17:16:49 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UcGy_fD6HYxfzO_xoWOcB+Cjf38Qon8ZdWxyTNtzP7-=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/17/16 12:49), Alexander Duyck wrote:
> >> >         /* Currently only IPv4/IPv6 with TCP is supported */
> >> >         switch (hdr.ipv4->version) {
> >> >         case IPVERSION:
> >> >                 /* access ihl as u8 to avoid unaligned access on ia64 */
> >> >                 hlen = (hdr.network[0] & 0x0F) << 2;
> >> > +               if (skb_tail_pointer(skb) < hdr.network + hlen +
> >> > +                                           sizeof(struct tcphdr))
> >> > +                       return;
> >> >                 l4_proto = hdr.ipv4->protocol;
> >> >                 break;
> >> >         case 6:
> >> >                 hlen = hdr.network - skb->data;
> >> > +               if (skb_tail_pointer(skb) < hdr.network + hlen +
> >> > +                                           sizeof(struct tcphdr))
> >> > +                       return;
> >> >                 l4_proto = ipv6_find_hdr(skb, &hlen, IPPROTO_TCP, NULL, NULL);
> >> >                 hlen -= hdr.network - skb->data;
> >> >                 break;
   :
> >> So you probably need to add a check for "skb_tail_pointer(skb) <
> >> (hdr.network + hlen + 20)".
> >
> > But isnt that the same thing as the checks before l4_proto computation above?
> 
> Sort of.  The problem is IPv6 can include extension headers and that
> can totally mess with us.  So we need to do one more check to verify
> that we have enough space for IPv6 w/ TCP which would be hdr.raw + 20
> + hlenl.

Yes, you are right. So given that I already check that I have
at least 40 bytes past the network header, and ipv6_find_hdr
will pull up exthdrs as needed, my checks are not needed, and the
real ones should happen after we come out of that switch().

--Sowmini
