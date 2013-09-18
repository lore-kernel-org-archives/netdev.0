From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH ] ipv6: handle the update of the NDISC_REDIRECT error code in icmpv6_err_convert
Date: Wed, 18 Sep 2013 20:00:19 +0200
Message-ID: <20130918180019.GA25829@order.stressinduktion.org>
References: <523996E0.9080702@cn.fujitsu.com> <20130918.123613.61436246160249555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36692 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab3IRSAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 14:00:20 -0400
Content-Disposition: inline
In-Reply-To: <20130918.123613.61436246160249555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 18, 2013 at 12:36:13PM -0400, David Miller wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> Date: Wed, 18 Sep 2013 20:04:48 +0800
> 
> > From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> > 
> > when dealing with redirect message in udpv6_err() and
> > rawv6_err() the err shoud be assigned to 0, not EPROTO.
> > 
> > Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> No, you should fix this the same way you handled DCCP, but skipping
> the whole socket error setting path for NDISC_REDIRECT.
> 
> Clearing the socket error to zero is not correct, it means you will
> lose any existing error setting.

My reasoning when I proposed this change was that we should not stop
appending ipv6 redirects to the raw and udp sockets error queues because
userland could want to deal with them (and probably already does). Also,
we need to notify poll of the appended error, hence we still needed a
call to sk_err_report to fire up a POLL_ERR event. Because we don't know
if the router sending the redirect actually dropped the packet I thought
taht '0' would be the only sane choice. We currently report back EPROTO,
IPv4 does report (rightfully) EHOSTUNREACH.

Perhaps we should stay with EPROTO?

I agree, all other error functions should return early after updating
the routing table without reporting any error. Either they should not
call into this function or ignore err == 0 (I prefer the first).

I know, it is a bit hacky but this was the most sane idea I came up with.

(I still have not reviewed this patch, just wanted to provide a bit of
background that lead to this change.)

Greetings,

  Hannes
