From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic
Date: Fri, 20 Apr 2007 16:35:15 -0700 (PDT)
Message-ID: <20070420.163515.26929060.davem@davemloft.net>
References: <20070222134918.e2f1af6d.akpm@linux-foundation.org>
	<20070312102403.GB1664@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, snakebyte@gmx.de
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50336
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751980AbXDTXfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 19:35:14 -0400
In-Reply-To: <20070312102403.GB1664@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Mon, 12 Mar 2007 11:24:03 +0100

> > the ipcomp handler is xfrm6_rcv(), which calls xfrm6_rcv_spi(), which contrary
> > to all other handlers returns -1 instead of 0 after calling kfree_skb() on the
> > skb. Changing the return value to 0 in xfrm6_input.c:xfrm6_rcv_spi() fixes the
> > problem.
> > But I got no clue at all if this would be a correct fix
> 
> I think your diagnose is correct (all "return -1" should be
> changed to "return 0" in xfrm6_input.c).

Unfortunately, that won't work.

The return value logic for proto->handler() is different in
IPV6's ip6_input.c than it is for IPV4's ip_input.c.

IPv4 goes:

			ret = ipprot->handler(skb);
			if (ret < 0) {
				protocol = -ret;
				goto resubmit;
			}

whereas IPV6 goes:

		ret = ipprot->handler(&skb);
		if (ret > 0)
			goto resubmit;

There was a good reason why things were done differently for
this case, but I don't remember what that reason was.

Anyways, changing -1 to 0 in xfrm6_input.c will break everything
even though it might make this crash go away. :-)))


