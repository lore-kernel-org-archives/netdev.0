From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver
 code
Date: Thu, 14 Aug 2008 15:13:31 -0700 (PDT)
Message-ID: <20080814.151331.114224935.davem@davemloft.net>
References: <20080813095324.GA15055@ben.ifi.uio.no>
	<20080813.033749.165504341.davem@davemloft.net>
	<84144f020808140628m31d6d099t1fecdb1701c0bbdc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, vegardno@ifi.uio.no,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, adobriyan@gmail.com
To: penberg@cs.helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45948
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751396AbYHNWN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 18:13:29 -0400
In-Reply-To: <84144f020808140628m31d6d099t1fecdb1701c0bbdc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Date: Thu, 14 Aug 2008 16:28:37 +0300

> On Wed, Aug 13, 2008 at 1:37 PM, David Miller <davem@davemloft.net> wrote:
> > 2) Do your locking differently so that the link status handling
> >   locking does not bisect the locking used for packet transmit
> >   in ->hard_start_xmit().
> >
> > #2 is the reason why most other drivers don't have this silly
> > bug, they don't hold TX path locks when handling link status
> > and printing out such messages.
> 
> Yeah, that works for the link status case, but not for things like the
> printks in rtl8139_tx_interrupt()... Hmm.

Note that netconsole specifically does trylock on the netdev
xmit lock specifically to handle this case.

If you could command the TX path solely under this generic lock
already provided by the generic networking, you could avoid this
deadlock as well.

This is yet another reason many other drivers don't get hit by
this problem.  The solution is built into netpoll but it only
works if you use the provided generic locking mechanisms to
mutex the driver's TX path.
