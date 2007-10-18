From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: multicast: bug or "feature"
Date: Thu, 18 Oct 2007 12:17:12 -0400
Message-ID: <47178708.2040606@hp.com>
References: <4716694D.6030508@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	David Stevens <dlstevens@us.ibm.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:42358 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757062AbXJRQRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 12:17:46 -0400
In-Reply-To: <4716694D.6030508@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote:
> We've been trying to field some questions regarding multicast
> behavior and one such behavior has stumped us.
> 
> I've reproduced the following behavior on 2.6.23.
> 
> The application opens 2 sockets.  One socket is the receiver
> and it simply binds to 0.0.0.0:2000 and joins a multicast group
> on interface eth0 (for the test we used 224.0.1.3).  The other
> socket is the sender.  It turns off MULTICAST_LOOP, sets MULTICAST_IF
> to eth1, and sends a packet to the group that the first socket
> joined.
> 
> We are expecting to receive the data on the receiver socket, but
> nothing comes back.
> 
> Running tcpdump on both interfaces during the test, I see the packet
> on both interfaces, ie. I see it sent on eth0 and received on eth1 with
> IP statistics going up appropriately.
> 
> Looking at the group memberships, I see the receiving interface as
> part of the group and IGMP messages were on the wire.
> 
> So, before I try to spend time figuring out where the packet went is
> why, I'd like to know if this is a Linux "feature".
> 

Ok, so I've traced the failure down to fib_validate_source().

Because the packet we received was sourced from one of our own
addresses, we end up finding a RTN_LOCAL route and fail out
of that function with -EINVAL.

I can see the reason for this behavior and I think dropping
in this case is fine.

Now, to figure out what IPv6 does different and why it works.
Seems to me that the two should have the same behavior.

-vlad
