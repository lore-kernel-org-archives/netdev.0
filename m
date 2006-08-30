From: David Miller <davem@davemloft.net>
Subject: Re: high latency with TCP connections
Date: Wed, 30 Aug 2006 14:39:55 -0700 (PDT)
Message-ID: <20060830.143955.55510936.davem@davemloft.net>
References: <20060830100734.GA22235@isil.ipib.msu.ru>
	<20060830102727.11e11453@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2444
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932107AbWH3Vjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 17:39:55 -0400
To: shemminger@osdl.org
In-Reply-To: <20060830102727.11e11453@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 30 Aug 2006 10:27:27 -0700

> Linux TCP implements "Appropriate Byte Count" (ABC) and this penalizes
> applications that do small sends. The problem is that the other side
> may be delaying acknowledgments.  If receiver doesn't acknowledge the
> sender will limit itself to the congestion window. If the flow is light,
> then you will be limited to 4 packets.

Right.

However it occured to me the other day that ABC could be made smarter.
If we sent small frames, ABC should account for that.

The problem with ABC is that it prevents CWND growth not just during
ACK division, but also when we truly are sending smaller sized frames.

In fact, for "chatty" protocols, the real load on a router for the
small packets is much less than that for full sized frames.  So it is
in fact these small frame sending cases for which we can be less
conservative, whatever that means here.

So my suggestion is that ABC should go look in the retransmit queue
and see how many "real packets" are being fully ACK'd, rather than
assuming the send queue is composed of MSS sized frames.

I also think we should seriously consider changing the ABC default to
"2" rather than "1".

> Expecting any performance with one byte write's is silly.

This is absolutely true.  TCP_NODELAY can only save you when you are
sending a small amount of data "in aggregate", such as in an SSH or
telnet session, whereas in the case being shown here a large amount of
data is being sent in small chunks which will always get bad
performance.

