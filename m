From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netlink limitations
Date: Sun, 07 Nov 2010 18:17:43 +0100
Message-ID: <4CD6DF37.6010800@trash.net>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41682 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab0KGRR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 12:17:59 -0500
In-Reply-To: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.11.2010 17:44, Jan Engelhardt wrote:
> we mentioned it only briefly at the Netfilter workshop a few weeks ago, 
> but as I am trying to figure out how to use Netlink in Xtables, 
> Netlink's limitations really start ruining my day.
> 
> The well-known issue is that NL messages the kernel is supposed to 
> receive have a max size of 64K, due to nlmsghdr's use of uint16_t. This 
> is very problematic because attributes can easily amass more than 64K. 
> Think of a chain full of rules, represented by a top-level attribute 
> that nests attributes. The problem is bidirectional, a table 
> dump has the same problem.

Messages are not limited to 64k, individual attributes are. Holger
started working on a nlattr32, which uses 32 bit for the length
value.

> A further problem seems to be that the kernel does not seem to have 
> support for receiving NLM_F_MULTI messages, so even assuming chains were 
> just 40K, one cannot atomically replace an entire table with 2 chains of 
> 40K each. Trying to slap transaction support on _top_ of netlink is not 
> going to work with the current implementation, because there is no 
> notification of when the socket is closed before a NLMSG_DONE has been 
> sent.

There is, search for NETLINK_URELEASE in af_netlink.c. With 32 bit
attribute lengths this should not be needed anymore however.

> What I would also like is streaming support, i.e. that I can tag an 
> attribute container (one that has nested attrs) with .len = -1 to define 
> that the end of the container is given not by .len, but by a stop 
> marker.

That's somewhat similar to the nlattr32 idea, but a length of 0 makes
more sense since that's currently not used. In that case the length
would be read from a second length field which has 32 bits.
