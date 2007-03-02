From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] bridge: avoid ptype_all packet handling
Date: Fri, 02 Mar 2007 15:18:03 -0800 (PST)
Message-ID: <20070302.151803.74748558.davem@davemloft.net>
References: <20070302.132638.38710461.davem@davemloft.net>
	<20070302140929.262e8460@freekitty>
	<20070302.144818.99455241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51112
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992729AbXCBXSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 18:18:05 -0500
In-Reply-To: <20070302.144818.99455241.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Fri, 02 Mar 2007 14:48:18 -0800 (PST)

> Back to a workable solution, why doesn't DHCP specify a specific
> device?  It would fix this performance problem completely, at the
> application level.

Since nobody seems to be able to be bothered to actually look
at what DHCP clients are doing, I actually did and it's no
surprise that broken stuff is happening here.

Here is how dhcp3-3.0.3 binds AF_PACKET sockets, in common/lpf.c:

	struct sockaddr sa;
 ...
	/* Bind to the interface name */
	memset (&sa, 0, sizeof sa);
	sa.sa_family = AF_PACKET;
	strncpy (sa.sa_data, (const char *)info -> ifp, sizeof sa.sa_data);
	if (bind (sock, &sa, sizeof sa)) {
		if (errno == ENOPROTOOPT || errno == EPROTONOSUPPORT ||
		    errno == ESOCKTNOSUPPORT || errno == EPFNOSUPPORT ||
		    errno == EAFNOSUPPORT || errno == EINVAL) {
			log_error ("socket: %m - make sure");
			log_error ("CONFIG_PACKET (Packet socket) %s",
				   "and CONFIG_FILTER");
			log_error ("(Socket Filtering) are enabled %s",
				   "in your kernel");
			log_fatal ("configuration!");
		}
		log_fatal ("Bind socket to interface: %m");
	}

So it puts a string into the sockaddr data, and there
is no mention of sockaddr_ll, which is what is supposed to be
provided as the socket address here, in the entire DHCP tree.

I'm tempted to say I must be missing something here, since I can't see
how this could possible work at all.  The string passed in should
be interpreted as the ifindex value, and thus trigger a -ENODEV
return from AF_PACKET's bind() implementation.

My suspicions are confirmed by the patch here:

http://kernel.org/pub/linux/kernel/people/chuyee/patches/dhcp-3.0/dhcp-3.0-linux_cooked_packet.patch

Really, this bogus bind() explains everything.


