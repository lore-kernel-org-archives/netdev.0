From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Wed, 6 Feb 2013 19:50:24 +0200
Message-ID: <20130206175024.GA17058@redhat.com>
References: <20130206114321.GA13497@redhat.com>
 <1360156059.28557.28.camel@edumazet-glaptop>
 <20130206155049.GB14735@redhat.com>
 <1360167332.28557.36.camel@edumazet-glaptop>
 <20130206174228.GA16991@redhat.com>
 <1360172565.28557.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, stephen.s.ko@intel.com,
	jeffrey.t.kirsher@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, sony.chacko@qlogic.com, mchan@broadcom.com,
	jitendra.kalsaria@qlogic.com, eilong@broadcom.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757670Ab3BFRqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 12:46:09 -0500
Content-Disposition: inline
In-Reply-To: <1360172565.28557.44.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 09:42:45AM -0800, Eric Dumazet wrote:
> On Wed, 2013-02-06 at 19:42 +0200, Michael S. Tsirkin wrote:
> > On Wed, Feb 06, 2013 at 08:15:32AM -0800, Eric Dumazet wrote:
> > > On Wed, 2013-02-06 at 17:50 +0200, Michael S. Tsirkin wrote:
> > > 
> > > > Also, I'm not sure I understand when should drivers set gso size
> > > > for incoming messages and what is a reasonable value.
> > > > Commit log talks about improved performance for lossy connections,
> > > > in this case, isn't this something net core should set?
> > > > 
> > > > I see 3 in-tree drivers that do this:
> > > > 
> > > > drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c:                skb_shinfo(skb)->gso_size = bnx2x
> > > 
> > > bnx2x is fine, take a look at lines 464
> > 
> > Is this what you mean?
> > 
> >         /* This is needed in order to enable forwarding support */
> >         if (frag_size) {
> >                 skb_shinfo(skb)->gso_size = bnx2x_set_lro_mss(bp,
> >                                         tpa_info->parsing_flags, len_on_bd);
> > 
> >                 /* set for GRO */
> >                 if (fp->mode == TPA_MODE_GRO)
> >                         skb_shinfo(skb)->gso_type =
> >                             (GET_FLAG(tpa_info->parsing_flags,
> >                                       PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
> >                                                 PRS_FLAG_OVERETH_IPV6) ?
> >                                 SKB_GSO_TCPV6 : SKB_GSO_TCPV4;
> >         }
> > 
> > 
> > I see it sets gso_type but apparently only if mode is GRO?
> > Will this still break if mode is set to LRO?
> > 
> > 
> 
> 
> In net-next tree, line 464 looks like :
> 
> static void bnx2x_set_gro_params(struct sk_buff *skb, u16 parsing_flags,
>                                  u16 len_on_bd, unsigned int pkt_len)
> {
>         /* TPA aggregation won't have either IP options or TCP options
>          * other than timestamp or IPv6 extension headers.
>          */
>         u16 hdrs_len = ETH_HLEN + sizeof(struct tcphdr);
> 
>         if (GET_FLAG(parsing_flags, PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
>             PRS_FLAG_OVERETH_IPV6) {
>                 hdrs_len += sizeof(struct ipv6hdr);
> <HERE>          skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
>         } else {
>                 hdrs_len += sizeof(struct iphdr);
> <HERE>          skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
>         }
> 
>         /* Check if there was a TCP timestamp, if there is it's will
>          * always be 12 bytes length: nop nop kind length echo val.
>          *
>          * Otherwise FW would close the aggregation.
>          */
>         if (parsing_flags & PARSING_FLAGS_TIME_STAMP_EXIST_FLAG)
>                 hdrs_len += TPA_TSTAMP_OPT_LEN;
> 
>         skb_shinfo(skb)->gso_size = len_on_bd - hdrs_len;
> ...
> 

OK, it looks like intel/qlogic can just look at skb protocol
and set gso_type to TCPV4/V6.
I'll try it and see if this works.

-- 
MST
