From: Timo Teras <timo.teras@iki.fi>
Subject: Re: ip_forward_use_pmtu and forwarding to xfrm'ed gre
Date: Thu, 9 Jul 2015 17:48:46 +0300
Message-ID: <20150709174847.334f58ad@vostro>
References: <20150708163032.5b5df2ec@vostro>
	<1436370752.3846.36.camel@stressinduktion.org>
	<20150708191751.3fc42725@vostro>
	<1436377198.3846.46.camel@stressinduktion.org>
	<20150708215156.7007eb09@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:33431 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbGIOsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 10:48:52 -0400
Received: by laar3 with SMTP id r3so248315268laa.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 07:48:51 -0700 (PDT)
In-Reply-To: <20150708215156.7007eb09@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, 8 Jul 2015 21:51:56 +0300
Timo Teras <timo.teras@iki.fi> wrote:

> On Wed, 08 Jul 2015 19:39:58 +0200
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > 
> > At least we know which interface the packet would leave. Should we
> > override this behavior on a per-interface basis?
> 
> That would be one option. We could also make the exception just for
> GRE interface in the DF mode. Or some sort of per-interface flag that
> is set internally by the driver.
> 
> > (Although I am in favor of admins just correcting the mtu by hand
> > and documenting this as you proposed earlier. I really don't know
> > if it is worth the effort to propagate those information.).
> 
> The problem with GRE + DF is that the internal packet is no-DF and
> potentially fragmented, but the tunneled packets (fragments) do have
> DF set. So no interim router can defrag+frag if needed. This means
> pmtu must be honored. And on nbma gre tunnels (target tunnel address
> depends on encapsulated packet's address) the path mtu needs to be
> propagated back to the sender.
> 
> In this configuration ip_forward_use_pmtu needs to be enabled (system
> wide, per-interface config, or implicitly by interface flags). Or
> alternatively the trusted pmtu needs to be propagated via alternate
> mechanism. But that might be quite tricky to implement.
> 
> I believe other tunnels have similar mechanism. E.g. ipip tunnels
> seems to share same DF vs. non-DF mode based on 'ttl' setting.

Thinking more on this, the issue happens even without XFRM. XFRM just
makes it pretty much immediate to happen.

Basically tunnel devices with 'pmtudisc' flag set (default for many,
and especially if 'ttl' parameter is used), have the issue always. As
the tunnel header has DF always set the routers handling tunnel packets
cannot really re-fragment.

I believe we should have a flag describing this functionality, and
enable ip_forward_use_pmtu for those interface. IFF_XMIT_DST_RELEASE is
a prerequisite to update the inner flow pmtu, so it might be used as
hint. Though, it's set even if 'nopmtudisc' was configured. So I
suppose this would deserve it's own flag. Grepping for drivers calling
netif_keep_dst() gives a list of drivers which need to be checked if
they rely on this behaviour.

Thanks,
Timo
