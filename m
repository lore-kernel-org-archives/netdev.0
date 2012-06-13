From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Wed, 13 Jun 2012 10:01:52 +0200
Message-ID: <20120613080152.GN27795@secunet.com>
References: <20120611114256.GL27795@secunet.com>
 <20120611.160258.866525532025442350.davem@davemloft.net>
 <20120612114440.GM27795@secunet.com>
 <20120612.133333.527780673034196147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60932 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141Ab2FMICE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 04:02:04 -0400
Content-Disposition: inline
In-Reply-To: <20120612.133333.527780673034196147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 12, 2012 at 01:33:33PM -0700, David Miller wrote:
> 
> We can't do exactly as my patch did, because it allows remote entities
> to easily poison PMTU information.  All they have to know is that
> there is some UDP or RAW socket open with a certain ID and then send
> forged ICMP to us.

Yes, I know what you mean. But not updating the the cached pmtu
informations results in slow path fragmentation along the path.

Btw. what happens to ipv6 if we stop doing pmtu discovery?
Shouldn't we reduce the packet size to 1280 bytes then?

> 
> What we possibly could do is adjust the socket's IP_PMTUDISC_* setting
> from IP_PMTUDISC_WANT to IP_PMTUDISC_DONT in response to PMTU
> messages.
> 

I think an application that sets IP_PMTUDISC_WANT explicitly will
rely on the fact that the kernel does pmtu discovery. Changing
the socket setting to IP_PMTUDISC_DONT the first time we get into
trouble makes IP_PMTUDISC_WANT pointless for udp and raw sockets.

Another option would be to change the sockets default setting
from IP_PMTUDISC_WANT to IP_PMTUDISC_DONT (at least for udp and
raw) and do pmtu discovery if an application sets IP_PMTUDISC_WANT.

With this we don't have the pmtu cache poisoning issue as the default.
We would only have it if a sockets sets IP_PMTUDISC_WANT explicitly.

This is not perfect too, but I fear there is no perfect solution here.
