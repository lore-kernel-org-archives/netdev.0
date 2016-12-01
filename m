From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next] net: hns: Fix to conditionally convey RX
 checksum flag to stack
Date: Thu, 1 Dec 2016 16:59:14 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A7D5EF1@lhreml503-mbx>
References: <20161129130945.919372-1-salil.mehta@huawei.com>
 <20161130.142539.1927956259851457047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:4731 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758673AbcLAQ71 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:59:27 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Salil Mehta
> Sent: Thursday, December 01, 2016 12:09 PM
> To: 'David Miller'
> Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: RE: [PATCH V2 net-next] net: hns: Fix to conditionally convey
> RX checksum flag to stack
> 
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Wednesday, November 30, 2016 7:26 PM
> > To: Salil Mehta
> > Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> > netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> > Subject: Re: [PATCH V2 net-next] net: hns: Fix to conditionally
> convey
> > RX checksum flag to stack
> >
> > From: Salil Mehta <salil.mehta@huawei.com>
> > Date: Tue, 29 Nov 2016 13:09:45 +0000
> >
> > > +	/* We only support checksum for IPv4,UDP(over IPv4 or IPv6),
> > TCP(over
> > > +	 * IPv4 or IPv6) and SCTP but we support many L3(IPv4, IPv6,
> > MPLS,
> > > +	 * PPPoE etc) and L4(TCP, UDP, GRE, SCTP, IGMP, ICMP etc.)
> > protocols.
> > > +	 * We want to filter out L3 and L4 protocols early on for which
> > checksum
> > > +	 * is not supported.
> >  ...
> > > +	 */
> > > +	l3id = hnae_get_field(flag, HNS_RXD_L3ID_M, HNS_RXD_L3ID_S);
> > > +	l4id = hnae_get_field(flag, HNS_RXD_L4ID_M, HNS_RXD_L4ID_S);
> > > +	if ((l3id != HNS_RX_FLAG_L3ID_IPV4) &&
> > > +	    ((l3id != HNS_RX_FLAG_L3ID_IPV6) ||
> > > +	     (l4id != HNS_RX_FLAG_L4ID_UDP)) &&
> > > +	    ((l3id != HNS_RX_FLAG_L3ID_IPV6) ||
> > > +	     (l4id != HNS_RX_FLAG_L4ID_TCP)) &&
> > > +	    (l4id != HNS_RX_FLAG_L4ID_SCTP))
> > > +		return;
> >
> > I have a hard time understanding this seemingly overcomplicated
> > check.
> >
> > It looks like if L3 is IPV4 it will accept any underlying L4
> protocol,
> > but is that what is really intended?  That doesn't match what this
> new
> > comment states.
> I agree that it is bit difficult to read. Earlier, I was banking on the
> register(mistakenly, its hardware implementation err ) to de-multiplex
> the checksum error type. The register supported indication of just IPv4
> Header Checksum Error as well (which meant it could carry any L4
> protocol).
> IPv6 does not have similar Header checksum error. Therefore, to check
> if it is just IPv4 Header checksum error or any supported L4 transport
> (UDP or TCP) error over IPv4 or IPv6 I had to bank upon above complex
> check
> 
> Below suggested solution check would have been insufficient for
> example, if packet had IPv4/IGMP and there was a checksum error in IPv4
> header.
> 
> Comment states:
> " We only support checksum for IPv4, UDP(over IPv4 or IPv6),
>   TCP(over IPv4 or IPv6) and SCTP"
>    1) Checksum of IPv4 (IPv4 header)
>    2) UDP(over IPv4 or IPv6)
>    3) TCP(over IPv4 or IPv6)
>    4) SCTP (over IPv4 or IPv6)*
> 
> (*) I should have put IPv4/IPv6 check for SCTP in the code
>     and made it clear in the comment as well?
> 
> >
> > My understanding is that the chip supports checksums for:
> >
> > 	UDP/IPV4
> > 	UDP/IPV6
> > 	TCP/IPV4
> > 	TCP/IPV6
> > 	SCTP/IPV4
> > 	SCTP/IPV6
> 
> Hardware also supports checksum of IPv4 Header.
> 
> >
> > So the simplest thing is to validate each level one at a time:
> >
> > 	if (l3 != IPV4 && l3 != IPV6)
> > 		return;
> > 	if (l4 != UDP && l4 != TCP && l4 != SCTP)
> > 		return;
> I guess above check will fail to catch cases like IPv4/IGMP, when there
> is a bad checksum in The IPv4 header.
> 
> But maybe now since we don't have any method to de-multiplex the kind
> of
> checksum error (cannot depend upon register) we can have below code
> re-arrangement:
> 
> hns_nic_rx_checksum() {
>       /* check supported L3 protocol */
> 	if (l3 != IPV4 && l3 != IPV6)
> 		return;
>       /* check if L3 protocols error */
>       if (l3e)
> 	 	return;
> 
>       /* check if the packets are fragmented */
> 	If (l3frags)
> 		Return;
> 
>       /* check supported L4 protocol */
>  	if (l4 != UDP && l4 != TCP && l4 != SCTP)
>  		return;
Hi David,
This logic might not do as well since IGMP packet with valid IP
Checksum will be bypassed here. We would want to set
CHECKSUM_UNNECESSARY for such IP packets as well.

It looks to me the cumbersome check in the PATCH V2 should
be retained.

>       /* check if any L4 protocol error */
>       if (l3e)
> 	 	return;
> 
>       /* packet with valid checksum - covey to stack */
>       skb->ip_summed = CHECKSUM_UNNECESSARY
> }

> 
> Hope I am not missing something here. Please correct my understanding
> if there is any gap here. Thanks!
> 
> Best regards
> Salil
