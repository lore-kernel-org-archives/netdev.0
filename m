From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NULL pointer dereference in veth_stats_one
Date: Fri, 4 Jan 2013 20:25:12 +0000
Message-ID: <1357331112.2693.33.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130104105955.GA3663@raven>
	 <1357314320.1678.1414.camel@edumazet-glaptop>
	 <1357316231.1678.1528.camel@edumazet-glaptop>
	 <1357323443.2693.9.camel@bwh-desktop.uk.solarflarecom.com>
	 <1357327406.1678.2139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:65258 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204Ab3ADUZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 15:25:17 -0500
In-Reply-To: <1357327406.1678.2139.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 11:23 -0800, Eric Dumazet wrote:
> On Fri, 2013-01-04 at 18:17 +0000, Ben Hutchings wrote:
> 
> > This possibly needs some memory barriers to properly synchronise with
> > veth_newlink().  But can you not move initialisation of the peer
> > pointers before registration of the devices in veth_newlink(), so that
> > veth_get_stats64() cannot be called before they are initialised?
> 
> The ->peer pointer cannot change once set. ( its never cleared )

We may still need an explicit barrier for data-dependency.

> So the problem would not be in veth_newlink(), but might be in
> veth_dellink()

A lot of things are done in between the unregister_netdevice_queue() and
the actual deletion which are probably sufficient to flush out any calls
to dev_get_stats().  But to make sure, I think we would need some small
amount of shared state that isn't freed until both devices are.

> It seems we would have a problem in veth_get_ethtool_stats() already...

That should be OK because both ethtool operations and the whole process
of interface deletion are serialised by the RTNL lock.

> More generally, what prevents a get_stats() being called while a
> dellink() (-> veth_dev_free() -> free_percpu()) is done ?

Anything calling dev_get_stats() must have a counted or RCU reference to
the device, and netdev_run_todo() waits for those to go away.  For
mutually referencing devices we want a kind of weak reference and we
have no good way to implement those.

Ben.

> (Same thing is done for tunnel/dummy stats percpu data)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
