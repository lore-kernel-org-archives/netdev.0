From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] [PATCH] qeth: l3 hw tx csum circumvent hw bug
Date: Sat, 15 Jan 2011 20:46:25 -0800 (PST)
Message-ID: <20110115.204625.226782089.davem@davemloft.net>
References: <20110113064310.729751199@de.ibm.com>
	<20110112.234735.160088590.davem@davemloft.net>
	<20110113082359.GA11455@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754349Ab1APEpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 23:45:52 -0500
In-Reply-To: <20110113082359.GA11455@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>
Date: Thu, 13 Jan 2011 09:23:59 +0100

> On Wed, Jan 12, 2011 at 11:47:35PM -0800, David Miller wrote:
>> From: frank.blaschka@de.ibm.com
>> Date: Thu, 13 Jan 2011 07:42:25 +0100
>> 
>> > --- a/drivers/s390/net/qeth_l3_main.c
>> > +++ b/drivers/s390/net/qeth_l3_main.c
>> > @@ -2998,7 +2998,9 @@ static inline void qeth_l3_hdr_csum(stru
>> >  	 */
>> >  	if (iph->protocol == IPPROTO_UDP)
>> >  		hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_UDP;
>> > -	hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_CSUM_TRANSP_REQ;
>> > +	hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_CSUM_TRANSP_REQ |
>> > +		QETH_HDR_EXT_CSUM_HDR_REQ;
>> > +	iph->check = 0;
>> >  	if (card->options.performance_stats)
>> >  		card->perf_stats.tx_csum++;
>> >  }
>> 
>> You may not change the packet header contents blindly like this.
>> Otherwise unpredictable contents will be seen by tcpdump and any
>> other code path which has a clone of this packet.
>> 
>> Thus, you'll need to guard this change with something like:
>> 
>> 		if (skb_header_cloned(skb) &&
>> 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
>> 			dev_kfree_skb(skb);
>> 			goto tx_fail;
>> 		}
> Yes I know. Because of the suboptimal l3 driver design :-) we already have
> a private copy of the skb at this place. Thx!

I see, thanks for explaining.

Both patches applied, thanks.
