From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely duplicate route_reverse function
Date: Wed, 29 Nov 2006 00:56:35 +0100
Message-ID: <m3slg3ktvw.fsf@defiant.localdomain>
References: <m3fyc3e84s.fsf@defiant.localdomain> <456C94D2.9000602@trash.net>
	<m3wt5fb8lz.fsf@defiant.localdomain> <456CAE0D.2080209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:3467 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1757796AbWK2CJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 21:09:17 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <456CAE0D.2080209@trash.net> (Patrick McHardy's message of "Tue, 28 Nov 2006 22:45:49 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> It might be the case that your network device has a
> hard_header_len > LL_MAX_HEADER, which could trigger
> a corruption.

Hmm... GRE tunnels add 24 bytes... I just noticed the following code in
include/linux/netdevice.h:

/*
 *      Compute the worst case header length according to the protocols
 *      used.
 */
 
#if !defined(CONFIG_AX25) && !defined(CONFIG_AX25_MODULE) && !defined(CONFIG_TR)
#define LL_MAX_HEADER   32
#else
#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
#define LL_MAX_HEADER   96
#else
#define LL_MAX_HEADER   48
#endif
#endif

#if !defined(CONFIG_NET_IPIP) && \
    !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE)
#define MAX_HEADER LL_MAX_HEADER
#else
#define MAX_HEADER (LL_MAX_HEADER + 48)
#endif

I don't use AX25, Token Ring, the old IPIP tunnels nor IPv6 here, but
I wonder if GRE tunnel (which is basically another, more compatible
form of IPIP) need the same treatment as IPIP.

I've confirmed that REJECTs over GRE tunnel caused that corruption.

> Please try this patch on top of the REJECT patch (ideally after
> verifying that the REJECT patch is really introducing the
> corruption).

That was certain. The patch fixed the problem, confirmed with current
git tree as well. Thanks for looking at it.


I'm not sure about LL_MAX_HEADER (and/or MAX_HEADER) though. Should it
be changed as well?

There are many devices adding data to header space, perhaps tacking
devices doesn't count as the skb is being linearized in
dev->hard_start_xmit() or equivalent path?
-- 
Krzysztof Halasa
