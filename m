From: David Miller <davem@davemloft.net>
Subject: Re: IPV6 source routing patch is still broken?
Date: Fri, 27 Apr 2007 02:08:05 -0700 (PDT)
Message-ID: <20070427.020805.88703639.davem@davemloft.net>
References: <46311F76.9040803@redhat.com>
	<20070426.153142.57441302.davem@davemloft.net>
	<46312E42.4070204@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, vsu@altlinux.ru
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43095
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755500AbXD0JH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 05:07:57 -0400
In-Reply-To: <46312E42.4070204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Ebbert <cebbert@redhat.com>
Date: Thu, 26 Apr 2007 18:57:06 -0400

> David Miller wrote:
> >> +       case IPV6_SRCRT_TYPE_2:
> >> +               if (accept_source_route >= 0)
> >> +                       break;
> >> +               kfree_skb(skb);
> >> +               return -1;
> >> +       case IPV6_SRCRT_TYPE_0:
> >> +               if (accept_source_route > 0)
> >> +                       break;
> >> +               kfree_skb(skb);
> >> +               return -1;
> > 
> > Yes, that looks like it matches the sysctl documentation more closely:
> > 
> > accept_source_route - INTEGER
> > 	Accept source routing (routing extension header).
> > 
> > 	> 0: Accept routing header.
> > 	= 0: Accept only routing header type 2.
> > 	< 0: Do not accept routing header.
> > 
> > Type 2 packets should get through as long as the value of the sysctl
> > is not negative.
> 
> It was Sergey Vlasov who first found this. I had tried to find his original
> message but I was searching the wrong place.

Actually, earlier in the function accept_source_route is
verified, and if it is negative ipv6_rthdr_rcv() returns
immediately.  This is done by the initial code which reads:

	if (accept_source_route < 0 ||
	    ((idev = in6_dev_get(skb->dev)) == NULL)) {
		kfree_skb(skb);
		return -1;
	}
	if (idev->cnf.accept_source_route < 0) {
		in6_dev_put(idev);
		kfree_skb(skb);
		return -1;
	}

then the function proceeds to use the largest of
'accept_source_route' and 'idev->cnf.accept_source_route'
for further checks.

So when we get to the switch statement in question, we know
it will be a positive value, so none of the purely negative
cases need to be considered.

So with Yoshifuji-sans small fix, the switch statement
covers all the cases properly:

	switch (hdr->type) {
#ifdef CONFIG_IPV6_MIP6
	case IPV6_SRCRT_TYPE_2:
		break;
#endif
	case IPV6_SRCRT_TYPE_0:
		if (accept_source_route > 0)
			break;
		kfree_skb(skb);
		return -1;
	default:
		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
				 IPSTATS_MIB_INHDRERRORS);
		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->type) - skb->nh.raw);
		return -1;
	}
