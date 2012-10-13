From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [net: stable request] dst->obsolete handling in 2.6.32-stable kernels - invalid cached routes never invalidated
Date: Sat, 13 Oct 2012 13:52:40 -0400
Message-ID: <20121013175240.GK5453@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:57151 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753929Ab2JMRwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2012 13:52:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David et al,

While investigating a problem on a 2.6.32 kernels (still present in 2.6.32.60) 
where a change to an ipv4 route was not taking effect, I came across the 
"dst->obsolete has become pointless" thread from November 2011 which is 
related, eventually finding the problem fixed (or at least worked around) in 
2.6.34 by "ipv4: check rt_genid in dst_check" aka 
d11a4dc18bf41719c9f0d7ed494d295dd2973b92.  

What I am seeing is that dst->obsolete is never being set for a cached 
output route that becomes obsolete.  For example, a cached route for 
10.0.0.3 is never marked obsolete when the route for 10.0.0.3 is removed 
from the routing table -- dst_check() and sk_dst_check() never invalidate 
the cached dst because of the test for dst->obsolete (which remains 0).

Reproducing the issue is easily done:

	# assuming eth0 has some ip and default route
	ifconfig eth1 9.0.0.1/8
	route add -host 10.0.0.3 gw 9.0.0.2	# assuming there is a 9.0.0.2
	nc -u 10.0.0.3 1234
	# <enter a few lines and note the packets sent to eth1 via 9.0.0.2>

	# On another terminal, without exiting nc, delete the route to 10.0.0.3
	route del -host 10.0.0.3 gw 9.0.0.2

	# Go back to the first terminal and send a few more packets by
	# entering another line or two to nc.  Note the packets still go via
	# eth1, even though they should now be transmitted via the default
	# route on eth0.

To fix this bug, would it be possible to get commit 
d11a4dc18bf41719c9f0d7ed494d295dd2973b92 queued up for 2.6.32-stable?  
Setting dst.obsolete to -1 seems to be the least invasive way of fixing 
this bug.  Thanks a bunch,

		-ben
-- 
"Thought is the essence of where you are now."
