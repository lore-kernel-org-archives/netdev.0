From: David Miller <davem@davemloft.net>
Subject: Re: bnx2_poll panicking kernel
Date: Tue, 24 Jun 2008 17:04:27 -0700 (PDT)
Message-ID: <20080624.170427.50552402.davem@davemloft.net>
References: <20080623213657.GA26447@orion.carnet.hr>
	<48602847.1020203@broadcom.com>
	<48617C19.3010005@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joy@entuzijast.net, billfink@mindspring.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	mirrors@debian.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48397
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752311AbYFYAE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 20:04:27 -0400
In-Reply-To: <48617C19.3010005@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 24 Jun 2008 15:58:33 -0700

> Michael Chan wrote:
> > I will send Josip another patch to print more SKB fields.  I can
> > even save all the SKB fields and see which other ones are modified besides
> > the nr_frags.  May be that will give us a better clue.
> > 
> Please try this patch, which should go on top of the last debug patch.
> Thanks.

Thanks for taking the time to track this down Michael.

Regardless of whether there is some bug in HTB or similar,
the trush is that currently nr_frags can change on us even
if the SKB is cloned.

For example, when using TSO, the TCP ACK processing path can mince up
a TSO packet into two parts, changing nr_frags in the original packet.
This is done by tcp_tso_fragment().

This would rarely hit an SKB still on a device queue, but perhaps HTB
makes this situation much more likely.

This behavior I consider a bug, because it could trigger while the
driver is initially queueing the packet and thus result in strange
OOPS's as the driver ends up trying to derefernce page slots in
skb_shared_info() which suddenly become not value.

Therefore, I suggest we do a few things:

1) Add an assertion to skb_split() such that it BUG()'s if
   the SKB it is asked to operate on is cloned/shared.

2) Make tcp_tso_fragment() make a copy if the SKB is cloned.
   Similarly to how code pathes leading up to tcp_fragment()
   behave.

I'll try to get to this after I finish up some TX path reworking
I'm deeply into at the moment, but if someone beats me to it,
all the better :-)
