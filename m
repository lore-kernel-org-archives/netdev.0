From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: netif_tx_disable and lockless TX
Date: Tue, 30 May 2006 21:51:03 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BC90@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:55564 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751695AbWEaEvW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 00:51:22 -0400
Content-class: urn:content-classes:message
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> On Tue, May 30, 2006 at 09:13:22PM -0700, David Miller wrote:
> > As per the bug, I always keep thinking about changing how we
> > do the lockless stuff by simply making xmit_lock a pointer.
> > Drivers like tg3 can make it point to their local driver lock.
> 
> This is equivalent to just using the xmit_lock in the driver, right?
> IIRC the problem was with IRQ disabling vs. BH disabling.

For drivers that always take a private tx lock between tx completion
and hard_start_xmit on top of the xmit_lock, getting rid of the
xmit_lock using LLTX is a net gain.

For drivers that don't need a private tx lock or rarely need it between
tx completion and hard_start_xmit, it makes little difference whether
you use xmit_lock or private lock with LLTX.

> 
> That's why I suggest that every NIC that uses this feature be forced
> to do what TG3 does so only BH disabling is needed.  Once that's done
> they can just use xmit_lock and everyone will be happy again.
> 

As long as the tx completion is all done in NAPI, it can use BH
disabling
without irq disabling.

TG3 uses LLTX with a private tx_lock. BNX2 uses xmit_lock with a private
tx_lock that is rarely used. Both drivers use BH disabling. The profiles
of the 2 drivers are very similar.

