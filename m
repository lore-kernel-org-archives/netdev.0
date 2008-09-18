From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2]: Software RX flow seperation
Date: Wed, 17 Sep 2008 19:34:38 -0700 (PDT)
Message-ID: <20080917.193438.112772191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens.axboe@oracle.com, nickpiggin@yahoo.com.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53694
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752463AbYIRCev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 22:34:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The other day I got wind that Jens Axboe had this cool
facility he was testing in his block development tree
that allows scheduling softirq work on remote cpus cheaply.

So I ran home from kernel summit as fast as I could and
started trying to make it generic and then try and use it
for networking packet receive processing.

These patches suck as-is, on the networking side.

For example, I do flow seperation for netif_rx(), which for
loopback is a lose for every benchmark I've tried.  For
things like tbench on localhost the cpus are already loaded
already and the RX flow seperation just adds more overhead,
increases latency, and decreases bandwidth.

That's easy to change, just make netif_rx() use

	target_cpu = smp_processor_id();

But for non-NAPI hardware devices it might still make sense.

Next, adding the "struct call_single_data" object to the sk_buff
is also negatively effecting performance.  I have some ideas
to cure that, for example I've always wanted sk_buff to use
a struct list_head instead of it's by-hand list implementation
hacks.

But this patch might improve some routing, firewalling, and
IPSEC gateway configurations when using cards that don't
support RX flow seperation in hardware.
