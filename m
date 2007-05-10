From: "Giampaolo Tomassoni" <Giampaolo@Tomassoni.biz>
Subject: 2.6.20 and multipath routing
Date: Thu, 10 May 2007 23:22:56 +0200
Message-ID: <003d01c79349$60da1870$228e4950$@biz>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.libero.it ([212.52.84.46]:35122 "EHLO
	smtp-out4.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759672AbXEJVWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:22:25 -0400
Received: from localhost (172.31.0.42) by smtp-out4.libero.it (7.3.120)
        id 4611FF520255DD80 for netdev@vger.kernel.org; Thu, 10 May 2007 23:22:24 +0200
Received: from smtp-out4.libero.it ([172.31.0.40])
	by localhost (asav-out2.libero.it [192.168.32.30]) (amavisd-new, port 10024)
	with ESMTP id 2wh+PglYhlYN for <netdev@vger.kernel.org>;
	Thu, 10 May 2007 23:22:23 +0200 (CEST)
Received: from famiglio (151.72.93.43) by smtp-out4.libero.it (7.3.120)
        id 4611FEBC03496375 for netdev@vger.kernel.org; Thu, 10 May 2007 23:22:23 +0200
Content-Language: it
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

this is yet-another-question about multipath routing.

I would like to do load-balancing on traffic outgoing through two DSL lines.

I would prefer to increase the bandwidth of each connection instead of just
the total one, thereby I guess I'm looking for a packet-based multipath
routing solution.

Somewhere in the Net I found someone writing that I was needed to rebuild my
2.6.20 with CONFIG_IP_ROUTE_MULTIPATH_CACHED=y and some
CONFIG_IP_ROUTE_MULTIPATH_(RR|RANDOM|WRANDOM|DRR) in order to obtain this,
since with CONFIG_IP_ROUTE_MULTIPATH_CACHED=n I could only do
connection-oriented multipath routing.

Is this true? I did compile my 2.6.20 with multipath caching on and all the
multipath policies as modules, but I seem unable to obtain what I want.

My setup is the following:

	- linux-2.6.20 from Gentoo (sys-kernel/gentoo-sources-2.6.20-r8)
	- iproute2-2.6.20.20070313
	- two ClIP lines over ADSL
	- two ethernet cards

eth0 is my local lan (say, 192.168.0.100/24), eth1 is my DMZ with two
addresses (say, 1.1.1.6/29 and 1.2.1.6/29), atm0 is the ClIP interface (say,
1.1.2.1/24) to which my provider sends packet addressed to 1.1.1.0/29, while
atm1 (say, 1.2.2.1/24) is the one receiving packets for 1.2.1.0/29.

Isn't that easy? :)

Ok, let me summarize:

	eth0:	192.168.0.100/24
	eth1: 1.2.1.6/29 (first address) and 1.1.1.6/29
	atm0: 1.1.2.1/24, point-to-point with 1.1.2.254, receives in behalf
of 1.1.1.0/29
	atm1: 1.2.2.1/24, point-to-point with 1.2.2.254, receives in behalf
of 1.2.1.0/29

There are many services running in the router (smtp, http, https, pop3,
imap, ftp, domain) which have to be accessed from Internet. It is basically
much more an all-in-one box than just a router. I'm not actually
interested in traffic to and from my DMZ, nor I am that much interested in
having traffic from eth0 being dynamically MASQueraded with both the
addresses of my DMZ (a hard-coded one is fine). I would prefer to make
things
simple, so I decided that my outgoing address will always be 1.2.1.6, which
is
also the only address that "outside" knows to reach my services. The matter
here is that I have plenty of downlink bandwidth per ADSL line, while I
would
like to obtain more uplink bandwidth.

Thereby, after modprobing multipath_rr, I invoked this only, simple routing
command:

	ip route add default src 1.2.1.6 mpath rr \
		nexthop via 1.2.2.254 dev atm1 \
		nexthop via 1.1.2.254 dev atm0

I see this way outgoing packets seem to get routed on a per-connection
basis: once a connection decided a path, that is kept until the connection
shuts down.

Now the questions:

	1) Is there any way to obtain a per-packed balancing?

	2) Would setting CONFIG_IP_ROUTE_MULTIPATH_CACHED=n help in this?
	   I didn't (yet) try this latter because I'm quite sure it wouldn't
	   help.

	3) why do I need to pre-load multipath_rr?

	4) when I do a "ip route list" I see:

		1.2.1.0/29 dev eth1  proto kernel  scope link  src 1.2.1.6
		1.1.1.0/29 dev eth1  proto kernel  scope link  src 1.1.1.6
		192.168.0.0/24 dev eth0  proto kernel  scope link  src
192.168.0.100
		1.2.2.0/24 dev atm1  proto kernel  scope link  src 1.2.2.1
		1.1.2.0/24 dev atm0  proto kernel  scope link  src 1.1.2.1
		127.0.0.0/8 dev lo  scope link
		default  src 1.2.1.6
		        nexthop via 1.2.2.254  dev atm0 weight 1
		        nexthop via 1.1.2.254  dev atm1 weight 1

	See? The mpath I choose is not mentioned in the default route. Is it
	right? I see iproute2 code has code to show it, but it doesn't.

Many thanks,

-------------------------------------
Giampaolo Tomassoni - I.T. Consultant
Piazza VIII Aprile 1948, 4
I-53043 Chiusi (SI) - Italy
Tel/Ph: +39-0578-21100

MAI mandare un messaggio a:
NEVER send an e-mail to:

 rainbowl@tomassoni.biz

