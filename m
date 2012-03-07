From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH v3 0/2] Fix routing metrics
Date: Wed, 7 Mar 2012 08:19:40 +0100
Message-ID: <20120307071940.GF15404@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56823 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489Ab2CGHTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2012 02:19:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the moment we initialize the routing metrics with the, on the inetpeer
cached values in rt_init_metrics(). So if we have the metrics cached on
the inetpeer, we ignore the user configured fib_metrics. This leads to
the fact that we can't configure the mtu, hoplimit etc. if we have learned
metrics cached.

The first patch invalidates the inetpeer tree along routing cache.
This is done by replacing the old tree with a fresh initialized
inet_peer_base when rt_cache_invalidate() is invoked. The old tree
is added to a garbage collector list and destroyed later with a delayed
work queue. I use a delay of 60 seconds, so rt_check_expire() ran at least
on time before on a default configuration.

The second patch removes the redirect_genid handling. We don't need this
any more because we remove the whole inetpeer tree when the redirects
are invalidated.

Changes from v2:

- Fix possible null pointer dereference in ip_rt_redirect()
