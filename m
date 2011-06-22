From: Fabienne Ducroquet <fabiduc@gmail.com>
Subject: net/ipv4: commit d0733d2e29b breaks rtorrent
Date: Wed, 22 Jun 2011 14:40:45 +0200
Message-ID: <20110622124045.GA3247@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sundell.software@gmail.com, Reinhard Max <max@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Marcus Meissner <meissner@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bamako.nerim.net ([62.4.17.28]:65067 "EHLO bamako.nerim.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757882Ab1FVMu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 08:50:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

With the latest versions of the Linux kernel (I've just tried 
3.0.0-rc4-00034-g2992c4b) rtorrent (version 0.8.7 with libtorrent 
0.12.7, from Debian unstable) fails to start with the error message:

	rtorrent: Could not open/bind port for listening: Invalid argument

I bisected it down to:

	commit d0733d2e29b652b2e7b1438ececa732e4eed98eb
	Author: Marcus Meissner <meissner@suse.de>
	Date:   Wed Jun 1 21:05:22 2011 -0700

	    net/ipv4: Check for mistakenly passed in non-IPv4 address

	    Check against mistakenly passing in IPv6 addresses (which would result
	    in an INADDR_ANY bind) or similar incompatible sockaddrs.

	    Signed-off-by: Marcus Meissner <meissner@suse.de>
	    Cc: Reinhard Max <max@suse.de>
	    Signed-off-by: David S. Miller <davem@davemloft.net>
	---
	 net/ipv4/af_inet.c |    3 +++
	 1 files changed, 3 insertions(+), 0 deletions(-)

	diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
	index cc14631..9c19260 100644
	--- a/net/ipv4/af_inet.c
	+++ b/net/ipv4/af_inet.c
	@@ -465,6 +465,9 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
		if (addr_len < sizeof(struct sockaddr_in))
			goto out;

	+       if (addr->sin_family != AF_INET)
	+               goto out;
	+
		chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);

		/* Not specified by any standard per-se, however it breaks too

With this commit reverted rtorrent works again.

Fabienne
