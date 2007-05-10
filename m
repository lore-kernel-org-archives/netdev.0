From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 13:57:07 -0700 (PDT)
Message-ID: <20070510.135707.10298706.davem@davemloft.net>
References: <464375F9.1050600@gmail.com>
	<20070510.133710.15264671.davem@davemloft.net>
	<46438336.5070408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, rick.jones2@hp.com, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: gaagaan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55092
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbXEJU5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:57:04 -0400
In-Reply-To: <46438336.5070408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gagan Arneja <gaagaan@gmail.com>
Date: Thu, 10 May 2007 13:40:22 -0700

> David Miller wrote:
> > 
> > If the qdisc is packed with packets and we would just loop sending
> > them to the device, yes it might make sense.
> > 
> > But if that isn't the case, which frankly is the usual case, you add a
> > non-trivial amount of latency by batching and that's bad exactly for
> > the kind of applications that send small frames.
> > 
> 
> I don't understand how transmitting already batched up packets in one go 
> introduce latency.

Keep thinking :-)

The only case where these ideas can be seriously considered is during
netif_wake_queue().  In all other cases we go straight to the device
from sendmsg(), since there is space in the TX ring, and we should
not try to batch as that will add latency.

So maybe find a solution in that area, some new driver interface that
can suck N packets out of a qdisc when netif_wake_queue() occurs.

If you look at the contexts in which netif_wake_queue() is called,
it's perfect, it already has the TX state of the driver locked, it has
the TX descriptor head/tail pointers handy, etc. and it's already
taken all the cache misses needed in order to work with this state.
