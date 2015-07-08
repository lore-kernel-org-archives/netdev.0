From: Timo Teras <timo.teras@iki.fi>
Subject: Re: ip_forward_use_pmtu and forwarding to xfrm'ed gre
Date: Wed, 8 Jul 2015 21:51:56 +0300
Message-ID: <20150708215156.7007eb09@vostro>
References: <20150708163032.5b5df2ec@vostro>
	<1436370752.3846.36.camel@stressinduktion.org>
	<20150708191751.3fc42725@vostro>
	<1436377198.3846.46.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33986 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbbGHSwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 14:52:00 -0400
Received: by lbnk3 with SMTP id k3so61827490lbn.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 11:51:59 -0700 (PDT)
In-Reply-To: <1436377198.3846.46.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 08 Jul 2015 19:39:58 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Wed, 2015-07-08 at 19:17 +0300, Timo Teras wrote:
> > On Wed, 08 Jul 2015 17:52:32 +0200
> > Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > 
> > > On Wed, 2015-07-08 at 16:30 +0300, Timo Teras wrote:
> > > If above idea does not work, we could simply add an option to gre
> > > driver to set skb->ignore_df, but I don't like that much.
> > 
> > This is not acceptable. The gre driver has two operating modes: DF
> > and non-DF mode (which is triggered by 'ttl inherit' or 'ttl
> > <number>' option on tunnel creation). The DF mode intentionally
> > sets DF on all tunnel packets so the pmtu is learned and relayed up
> > the stack. In non-DF mode the tunnel packets DF is derived from
> > encapsulated packet.
> > 
> > Basically this info could be used. If the target is gre1 in DF
> > mode, we
> > should be trusting the pmtu. Otherwise the existing internal
> > mechanism breaks.
> > 
> > Thoughts?
> 
> At least we know which interface the packet would leave. Should we
> override this behavior on a per-interface basis?

That would be one option. We could also make the exception just for GRE
interface in the DF mode. Or some sort of per-interface flag that is
set internally by the driver.

> (Although I am in favor of admins just correcting the mtu by hand and
> documenting this as you proposed earlier. I really don't know if it is
> worth the effort to propagate those information.).

The problem with GRE + DF is that the internal packet is no-DF and
potentially fragmented, but the tunneled packets (fragments) do have DF
set. So no interim router can defrag+frag if needed. This means pmtu
must be honored. And on nbma gre tunnels (target tunnel address depends
on encapsulated packet's address) the path mtu needs to be propagated
back to the sender.

In this configuration ip_forward_use_pmtu needs to be enabled (system
wide, per-interface config, or implicitly by interface flags). Or
alternatively the trusted pmtu needs to be propagated via alternate
mechanism. But that might be quite tricky to implement.

I believe other tunnels have similar mechanism. E.g. ipip tunnels seems
to share same DF vs. non-DF mode based on 'ttl' setting.
