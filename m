From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: The proper way of delaying tx in a driver
Date: Wed, 23 Jul 2008 16:37:23 +1000
Message-ID: <1216795043.11027.311.camel@pasglop>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41272 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747AbYGWGh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 02:37:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi !

(Dave: this is basically the conversation we had on IRC, I think at that
point it's worth discussing here and I'll see if I can update the
documentation along fix fixing a handful of drivers).

So the problem: various drivers need to temporarily stop TX, ie, make
sure their hard_hard_xmit() is not running and will not be called for a
certain amount of time, in order to perform various housekeeping tasks.

This ranges from things like change_mtu() to reset tasks, or whatever
other things driver may want to do that require that locking.

For a short amount of time, just locking the tx lock
(netif_tx_lock{_bh}) does the job just fine. So let's ignore that. We
are in the case of a driver that wants to do something long, such as
reallocating the entire RX ring (change_mtu) or resetting hardware, and
potentially want to sleep / schedule.

The drivers historically use netif_stop_queue()/netif_wake_queue() to do
that. This is fishy due to locking, but let's assume that at this stage
we have a clueful driver writer, and thus like tg3, we do
netif_tx_disable / netif_wake_queue instead.

The above unfortunately hits the new WARN_ON() as Dave pointed out, it's
not legal to call netif_wake_queue() before a driver's open() function
called netif_start_queue().

Drivers like tg3 seem to be at least -somewhat- careful, and only do
those things when netif_running(). However, unless I missed something,
this is true from just before the driver open() is called, that is, too
early for closing the race.

So the question is, what is the proper approach ?

I'm happy to help fixing tg3, sungem and emac at least as I'm somewhat
familiar with those 3 drivers once we decide what is the right sequence
of operations here.

Cheers,
Ben.


