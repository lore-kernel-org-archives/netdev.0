From: Simon Kirby <sim@netnation.com>
Subject: TCP syn flood handling regression
Date: Sat, 10 Mar 2012 04:27:25 -0800
Message-ID: <20120310122725.GA31129@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:33365 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637Ab2CJMoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 07:44:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

A typical port 80 SYN flood started up to one of our clusters, but this
time, it didn't work so well. Legitimate connections and trying to fetch
server-status via localhost would hang for ~30 seconds before responding,
even though though the box had plenty of spare cycles. An strace of all
Apache processes showed quite a bit of sleeping in accept4().

This was with 3.2.9, so I went back in kernel builds and found that 3.1
and 3.0 were also broken, while 2.6.39 works as I remember -- when syn
cookies are enabled, everything just works and is fast. The DoS kept up,
so I was able to feed a bit to a node to do some bisection.

Of course, the DoS stopped literally seconds before the last bisection
test, but I got it down to:

# good: [0e734419923bd8e599858f8fc196c7804bb85564] ipv4: Use inet_csk_route_child_sock() in DCCP and TCP.
# bad: [ea4fc0d6193ff56fcef39b0d2210d402a7acb5f0] ipv4: Don't use rt->rt_{src,dst} in ip_queue_xmit().

...leaving ea4fc0d6193ff56fcef39b0d2210d402a7acb5f0 and
d9d8da805dcb503ef8ee49918a94d49085060f23 as culprits.

I've stared at them but can't see what could be doing this.

Simon-
