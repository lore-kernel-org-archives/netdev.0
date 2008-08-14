From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
 iptables nat routing
Date: Thu, 14 Aug 2008 15:00:55 -0700 (PDT)
Message-ID: <20080814.150055.201449155.davem@davemloft.net>
References: <1218679700.23510.8.camel@2710p.home>
	<20080813.192101.221940876.davem@davemloft.net>
	<48A41139.9080509@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42819
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755851AbYHNWAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 18:00:54 -0400
In-Reply-To: <48A41139.9080509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 14 Aug 2008 13:04:25 +0200

> David Miller wrote:
> > Patrick I wonder if there a case where iptables NAT will COW the packet
> > when it really doesn't need to.
> 
> I don't think so, its using skb_make_writable everywhere, which checks
> for skb_clone_writable, which should usually avoid COWing local TCP
> packets. It would also be unlikely to have that much of a performance
> impact (1MB/s -> 34kb/s).

I think he is NAT'ing locally generated traffic, look at the bugzilla
entry.

He has two cases of the same wget transfer, one is direct and another
uses a 127.0.0.1:XXXX URL that does the transfer over an SSH tunnel.
Normally they go roughly at the same rate.

Then he adds iptables NAT entries that redirect the first transfer
case over the SSH tunnel addr/port.  And it is this case that degrades
in performance with the GSO changeset.

So it is locally generated TCP traffic, NAT'd to another port and IP
address (specifically, redirected to 127.0.0.1:8888).

Perhaps the problem has something to do with the fact that as far as
TCP is concerned, the destination device can do SG and CSUM and thus
GSO.  But then iptables NATs this traffic to loopback.  I think that
is what leads to some kind of slowpath.
