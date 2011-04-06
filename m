From: David Miller <davem@davemloft.net>
Subject: Re: problem of "ipv4: revert Set rt->rt_iif more sanely on output
 routes."
Date: Wed, 06 Apr 2011 13:28:29 -0700 (PDT)
Message-ID: <20110406.132829.116375350.davem@davemloft.net>
References: <87oc4kj1bt.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hirofumi@mail.parknet.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50930
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755805Ab1DFU3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:29:07 -0400
In-Reply-To: <87oc4kj1bt.fsf@devron.myhome.or.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date: Tue, 05 Apr 2011 22:05:10 +0900

> ipv4: Set rt->rt_iif more sanely on output routes.
> (1018b5c01636c7c6bda31a719bda34fc631db29a)
> 
> The above patch seems to be caused of avahi breakage.
> 
> I'm not debugging fully though, avahi is using IP_PKTINFO and checking
> in_pktinfo->ipi_ifindex > 0.
> 
> And if I reverted above patch, it seems to fix avahi's IP_PKTINFO problem.

in_pktinfo is given to the application only during recvmsg() calls, the
call chain is (for example):

udp_recvmsg()
	--> ip_cmsg_recv()
		--> ip_cmsg_recv_pktinfo()

Therefore we will only be working with receive packets, whose routes are
computed using ip_route_input*() which will fill in the rt_iif field
appropriately.

The only exception to this would be packets which are looped back, in
which case the cached output route attached to the packet will be used.

Your RFC patch should work, but we're trying to make "struct rtable"
smaller rather than larger.

In what way does routing break if you simply restore the original
rt_iif assignment in output route creation?  That's the most preferred
fix for this.
