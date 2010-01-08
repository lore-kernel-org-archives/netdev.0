From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] IPv6: fix rt_lookup in pmtu_discovery
Date: Thu, 7 Jan 2010 17:05:36 -0800
Message-ID: <55a4f86e1001071705i33f8c58cubae56f5616216de4@mail.gmail.com>
References: <65634d661001062043s1b4eb204v63566149bb44f144@mail.gmail.com>
	 <20100107.012701.257511338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: therbert@google.com, netdev@vger.kernel.org, lorenzo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.216.174]:42827 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152Ab0AHBFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 20:05:37 -0500
Received: by pxi4 with SMTP id 4so1680148pxi.33
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 17:05:36 -0800 (PST)
In-Reply-To: <20100107.012701.257511338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This needs to do what the IPV4 side does, iterate over specific then
> "any" device index, doing a lookup for each case until the route is
> found, therefore starting from more specific and going towards less
> specific routes.

I've spoken with Tom and we can't quite seem to figure out what
exactly the code should be attempting to accomplish here.
Is checking the specific device index meant to deal with link local IPs?

As for the v4 code, I assume you're referring to ip_rt_frag_needed in
net/ipv4/route.c.

If so, shouldn't this sort of route lookup be abstracted away into
some function?
Path mtu discovery / fragmentation handling functions don't seem to be
the right place to be implementing route lookup policy.

Are you suggesting the following logic for ipv6:

rt = rt6_lookup(net, daddr, saddr, dev->ifindex, 0);
if (rt == NULL)
        rt = rt6_lookup(net, daddr, saddr, 0, 0);
if (rt == NULL)
        rt = rt6_lookup(net, daddr, 0, dev->ifindex, 0);
if (rt == NULL)
        rt = rt6_lookup(net, daddr, 0, 0, 0);
if (rt == NULL)
        return;

It's not clear to me what the last two lookups with saddr replaced
with 0 are for.

Maciej
