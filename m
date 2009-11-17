From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] dev->refcnt long term holder
Date: Tue, 17 Nov 2009 00:30:19 -0800 (PST)
Message-ID: <20091117.003019.196504832.davem@davemloft.net>
References: <4B019381.2010509@gmail.com>
	<20091116110207.08b60c81@nehalam>
	<4B01ADF5.8090904@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198AbZKQIaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 03:30:02 -0500
In-Reply-To: <4B01ADF5.8090904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Nov 2009 20:54:29 +0100

> I was hoping a fast path, but anyway, a linkwatch_forget_dev(dev) is
> probably better, (in case "ip link del" closely follows an "ip link
> add / up")
> 
> I'll post something when tested.

Let's face it, linkwatch has been a thorn in our sides for a long
time.  A non-stop source of problems.

I suspect that here in this VLAN case you care about, the work can
even be done synchronously.

I'm trying to remember why we added this asynchronous link state event
processing monster.  It probably has something to do with needing a
sleepable context.  What's amusing is that linkwatch has repeatably
caused RTNL deadlock issues over the years. :-)

If it is purely an issue of doing link state processing outside of
HW irq context:

1) PHY events in most drivers are handled in softirq (NAPI ->poll())
   or a workqueue of some sort these days.  If we can make all of
   the link state management softirq safe (it probably is, except
   for perhaps RTNL), these case can be done synchronously always.

2) The remaining cases are device probe, open, and close.  None of
   which execute in HW irq context, they can sleep, and they hold
   RTNL already.

I'm sure there are a few drivers which still can invoke
netif_carrier_*() in HW interrupt context, but we can create a tiny
workqueue helper or something like that for them.  It won't be the
main way to invoke carrier state changes, just a compatability item.

Anyways, just some food for thought.
