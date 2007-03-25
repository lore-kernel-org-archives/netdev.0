From: David Miller <davem@davemloft.net>
Subject: Re: [irda-users] [2.6.20-rt8] "Neighbour table overflow."
Date: Sat, 24 Mar 2007 22:10:34 -0700 (PDT)
Message-ID: <20070324.221034.45741983.davem@davemloft.net>
References: <FuqKSqqx.1174476366.8345250.samuel@sortiz.org>
	<Pine.LNX.4.63.0703211235220.534@pcgl.dsa-ac.de>
	<Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org, paulus@samba.org
To: gl@dsa-ac.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933180AbXCYFKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 01:10:35 -0400
In-Reply-To: <Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guennadi Liakhovetski <gl@dsa-ac.de>
Date: Fri, 23 Mar 2007 13:14:43 +0100 (CET)

> On Wed, 21 Mar 2007, Guennadi Liakhovetski wrote:
> 
> > On Wed, 21 Mar 2007, Samuel Ortiz wrote:
> >
> >> I'm quite sure the leak is in the IrDA code rather than in the ppp or
> >> ipv4 one, hence the need for full irda debug...
> 
> Well, looks like you were wrong, Samuel. Below is a patch that fixes ONE 
> sk_buff leak (maintainer added to cc: hi, Paul:-)). Still investigating if 
> there are more there.

This is strange.

The PPP generic layer seems to be very careful about it's handling of
the ->xmit_pending packet.

When a packet is added to ->xmit_pending, immediately ppp_push() is
called, and ppp_push() gives the packet to the channels xmit function,
and unless the xmit function returns zero the ->xmit_pending is reset
to NULL because non-zero return from the channel xmit functions means
that the driver took the packet.

Now I checked irnet_ppp.c, which is the driver under scrutiny here,
and it never ever returns zero, under any circumstance, it always
return one.

So the ->xmit_pending should always be NULL'd out by ppp_push().

There is some funny BLOCK_WHEN_CONNECT code, which will return
0 in certain cases, but that define it never set during the
build.

Nevermind... that code does get enabled. :(

This looks like it might be a bug, perhaps you can only return zero
from the transmit function when your queue really is full and you plan
to wake things up properly when space appears (via
ppp_output_wakeup()).  You can't return 0 because of an event which
might never occur, that's what makes ->xmit_pending get stuck and
leak.

I'm really surprised this leak doesn't trigger already via the
ppp_synctty.c and ppp_async.c drivers, perhaps they do something to
make sure the transmitter gets purged properly when unregistering and
therefore ->xmit_pending does not get left non-NULL at unregister
time.
