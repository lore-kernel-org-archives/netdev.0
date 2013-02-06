From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Wed, 6 Feb 2013 19:42:28 +0200
Message-ID: <20130206174228.GA16991@redhat.com>
References: <20130206114321.GA13497@redhat.com>
 <1360156059.28557.28.camel@edumazet-glaptop>
 <20130206155049.GB14735@redhat.com>
 <1360167332.28557.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, stephen.s.ko@intel.com,
	jeffrey.t.kirsher@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, sony.chacko@qlogic.com, mchan@broadcom.com,
	jitendra.kalsaria@qlogic.com, eilong@broadcom.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755156Ab3BFRiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 12:38:16 -0500
Content-Disposition: inline
In-Reply-To: <1360167332.28557.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 08:15:32AM -0800, Eric Dumazet wrote:
> On Wed, 2013-02-06 at 17:50 +0200, Michael S. Tsirkin wrote:
> 
> > Also, I'm not sure I understand when should drivers set gso size
> > for incoming messages and what is a reasonable value.
> > Commit log talks about improved performance for lossy connections,
> > in this case, isn't this something net core should set?
> > 
> > I see 3 in-tree drivers that do this:
> > 
> > drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c:                skb_shinfo(skb)->gso_size = bnx2x
> 
> bnx2x is fine, take a look at lines 464

Is this what you mean?

        /* This is needed in order to enable forwarding support */
        if (frag_size) {
                skb_shinfo(skb)->gso_size = bnx2x_set_lro_mss(bp,
                                        tpa_info->parsing_flags, len_on_bd);

                /* set for GRO */
                if (fp->mode == TPA_MODE_GRO)
                        skb_shinfo(skb)->gso_type =
                            (GET_FLAG(tpa_info->parsing_flags,
                                      PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
                                                PRS_FLAG_OVERETH_IPV6) ?
                                SKB_GSO_TCPV6 : SKB_GSO_TCPV4;
        }


I see it sets gso_type but apparently only if mode is GRO?
Will this still break if mode is set to LRO?




> > drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:  skb_shinfo(skb)->gso_size = DIV_ROUND_UP((skb->le
> > drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:         skb_shinfo(skb)->gso_size = qlcnic_get_lr
> > 
> > It seems likely the same issue applies there?
> 
> Yes
