From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: slow tcp connect when using IPsec
Date: Fri, 25 Mar 2011 07:41:16 +0100
Message-ID: <20110325064116.GE1290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45940 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754203Ab1CYGlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 02:41:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm fighting with a strange behaviour since a some days.
When I try to send tcp data over an IPsec tunnel, the tcp connect hangs
for about 20 seconds before it finally sends out the SYN packet.
This happens just on tcp with IPsec. When I bind the connection to
a specific local port, everything works fine. After some time of 
unsuccessful debugging, I bisected this issue down to

commit 5e2b61f78411be25f0b84f97d5b5d312f184dfd1
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Mar 4 21:47:09 2011 -0800

    ipv4: Remove flowi from struct rtable.

Some time and a lot of trace_printks later I found that we set up
the flow informations without source _and_ destination address in
ip_route_newports(). That is because we take the address informations
from the the rt_key_src and rt_key_dst fields of the rtable here
and they appear to be empty. If I restore the behaviour before the bisected
commit by taking the address informations from rt_src and rt_dst the issue
is gone. So now I know why it did not behave as expected, but unfortunately
I still don't know why it magically started to work after 20 seconds...

I'll send the patch that fixed the issue in replay to this mail.

Steffen


