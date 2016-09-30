From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: remove skb_mpls_header
Date: Fri, 30 Sep 2016 10:06:08 +0200
Message-ID: <20160930100608.1b4308b2@griffin>
References: <cover.1475176437.git.jbenc@redhat.com>
        <e32cd7d5d03b4cb86a872e76730aa29a2f7d9e38.1475176437.git.jbenc@redhat.com>
        <CAOrHB_DJunwVXJse8XyVMqAxt2sf4BZ67vospaKD0Lj-6HS_yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34770 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751670AbcI3IGM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 04:06:12 -0400
In-Reply-To: <CAOrHB_DJunwVXJse8XyVMqAxt2sf4BZ67vospaKD0Lj-6HS_yQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Sep 2016 16:03:19 -0700, pravin shelar wrote:
> > --- a/include/net/mpls.h
> > +++ b/include/net/mpls.h
> > @@ -25,15 +25,4 @@ static inline bool eth_p_mpls(__be16 eth_type)
> >                 eth_type == htons(ETH_P_MPLS_MC);
> >  }
> >
> > -/*
> > - * For non-MPLS skbs this will correspond to the network header.
> > - * For MPLS skbs it will be before the network_header as the MPLS
> > - * label stack lies between the end of the mac header and the network
> > - * header. That is, for MPLS skbs the end of the mac header
> > - * is the top of the MPLS label stack.
> > - */
> > -static inline unsigned char *skb_mpls_header(struct sk_buff *skb)
> > -{
> > -       return skb_mac_header(skb) + skb->mac_len;
> > -}
> 
> I think we should keep this API, so that it is clear that MPLS header
> mapped skb network header.

I was pondering this but I don't think it really gains us anything.
Wrappers like ip_hdr() are useful as they do type conversion; it's much
nicer to write
	ip_hdr(skb)->daddr
than 
	(struct iphdr *)skb_network_header(skb)->daddr.

But we don't really have a good type to return from skb_mpls_header, it
boils down to be 100% equivalent to skb_network_header. In fact, you
could just do:
#define skb_mpls_header skb_network_header

In the code, I don't think there's much benefit from calling the
wrapper, meaning of skb_network_header itself is clear enough. It *is*
the network header, after all. In the whole openvswitch code, MPLS is
treated as L3 header - no dissection is performed after the MPLS
headers, the network header and mac_len is set as expected now, etc.

 Jiri
