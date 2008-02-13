From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [RFC, PATCH]: Pass link level header from/to PPP interface
Date: 13 Feb 2008 17:56:00 +0100
Message-ID: <ygflk5opzhb.fsf@janus.isnogud.escape.de>
References: <ygfprv55egs.fsf@janus.isnogud.escape.de>
	<20080212.220603.111665989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:35850 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762511AbYBMRAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 12:00:08 -0500
In-Reply-To: <20080212.220603.111665989.davem@davemloft.net>; from David Miller on Tue, 12 Feb 2008 22:06:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

> But if libpcap and tcpdump can already identify PPP packets
> then, besides "consistency", what does this buy us other
> than potential breakage?

My reason for the patch is mostly cleanliness and to make the kernel
match what is described in packet(7).

If you open a PF_PACKET/SOCK_RAW socket and bind it to an interface
you get a fixed type of frame/packet depending on the type of
interface, including the LL header.  Also if you bind to all
interfaces you can look at the interface type to know what type of
packet you get.  But not for PPP interfaces.

I've written a small packet dump util with a packet parser (somewhat
comparable to tcpdump but much smaller), which looks like this

        struct sockaddr_ll addr;
        ...
        s = open(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
        ...
        recvfrom(s, buffer, sizeof(buffer), 0, &addr, &size);
        switch (addr.sll_hatype) {
        case ARPHRD_ETHER:
        case ARPHRD_IEEE80211:
        case ARPHRD_LOOPBACK:
                parse_ether(buffer);
                break;
        case ARPHRD_TUNNEL:
                parse_ip(buffer);
                break;
        case ARPHRD_SIT:
                parse_ipv6(buffer);
                break;

and so on.  Only for PPP I need to switch on the addr.sll_protocol
since with PPP I don't get the PPP header:

        case ARPHRD_PPP:
                switch (ntohs(addr.sll_protocol))
		case ETH_P_IP:
		    parse_ip(buffer);
		    break;
		case ETH_P_IPV6:
		    parse_ipv6(buffer);
		    break;
                ...
		}
		break;

With my patch you would write

        case ARPHRD_PPP:
                parse_ppp(buffer);
                break;

and the parse function can show the complete PPP frame with protocol
field.  Without the patch there is no way to see the 2-byte PPP header
and, in contrast to packet(7), SOCK_DGRAM and SOCK_RAW are the same.

Do you consider this strong enough to justify this change?

urs
