From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Adjust softirq raising in __napi_schedule
Date: Thu, 22 Oct 2009 04:29:39 -0700 (PDT)
Message-ID: <20091022.042939.95166154.davem@davemloft.net>
References: <20091021211906.GA11401@ami.dom.local>
	<1256160330.12174.2.camel@johannes.local>
	<20091021213947.GA12202@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, tilman@imap.cc,
	hidave.darkstar@gmail.com, linux-kernel@vger.kernel.org,
	tglx@linutronix.de, linux-wireless@vger.kernel.org,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	paulus@samba.org, mb@bu3sch.de, oliver@hartkopp.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38916
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754362AbZJVL3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 07:29:16 -0400
In-Reply-To: <20091021213947.GA12202@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 21 Oct 2009 23:39:47 +0200

> I'm not sure I can understand your question. This patch is mainly to
> avoid using netif_rx()/netif_rx_ni() pair as a test of proper process
> context handling; IMHO there're better tools for this (lockdep,
> WARN_ON's).

Semantically I think your patch is correct, but I wonder about cost.

Something that is a simply per-cpu inline "or" operation is now a
function call and potentially mispredicted branch inside of
raise_softirq_irqoff().

And netif_rx() is indeed a fast path for tunnels and other users so
this does matter.

I like having people call things in the correct context the function
was built for, and thus we can avoiryd completely useless operations and
tests as we can now in netif_rx().

Makaing things general purpose costs something, and it costs too much
here for this critical routine, sorry.

I was just having a talk with Nick Piggin about these kinds of issues
today, too few people care about these ever encrouching tiny pieces
of bloat that slow the kernel down gradually over time, and I simply
won't stand for it when I notice it :-)
