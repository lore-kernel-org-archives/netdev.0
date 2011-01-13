From: Frank Blaschka <frank.blaschka@de.ibm.com>
Subject: Re: [patch 2/2] [PATCH] qeth: l3 hw tx csum circumvent hw bug
Date: Thu, 13 Jan 2011 09:23:59 +0100
Message-ID: <20110113082359.GA11455@tuxmaker.boeblingen.de.ibm.com>
References: <20110113064223.429450048@de.ibm.com> <20110113064310.729751199@de.ibm.com> <20110112.234735.160088590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:33666 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753171Ab1AMIYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 03:24:02 -0500
Content-Disposition: inline
In-Reply-To: <20110112.234735.160088590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 12, 2011 at 11:47:35PM -0800, David Miller wrote:
> From: frank.blaschka@de.ibm.com
> Date: Thu, 13 Jan 2011 07:42:25 +0100
> 
> > --- a/drivers/s390/net/qeth_l3_main.c
> > +++ b/drivers/s390/net/qeth_l3_main.c
> > @@ -2998,7 +2998,9 @@ static inline void qeth_l3_hdr_csum(stru
> >  	 */
> >  	if (iph->protocol == IPPROTO_UDP)
> >  		hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_UDP;
> > -	hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_CSUM_TRANSP_REQ;
> > +	hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_CSUM_TRANSP_REQ |
> > +		QETH_HDR_EXT_CSUM_HDR_REQ;
> > +	iph->check = 0;
> >  	if (card->options.performance_stats)
> >  		card->perf_stats.tx_csum++;
> >  }
> 
> You may not change the packet header contents blindly like this.
> Otherwise unpredictable contents will be seen by tcpdump and any
> other code path which has a clone of this packet.
> 
> Thus, you'll need to guard this change with something like:
> 
> 		if (skb_header_cloned(skb) &&
> 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
> 			dev_kfree_skb(skb);
> 			goto tx_fail;
> 		}
Yes I know. Because of the suboptimal l3 driver design :-) we already have
a private copy of the skb at this place. Thx!
> 
> Please fix this and resubmit your two patches.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
