From: David Miller <davem@davemloft.net>
Subject: Re: [patch 01/13] KS8851: Fix ks8851 snl transmit problem
Date: Mon, 03 May 2010 13:03:16 -0700 (PDT)
Message-ID: <20100503.130316.56362236.davem@davemloft.net>
References: <20100429231739.509103394@fluff.org.uk>
	<20100502.223852.219748077.davem@davemloft.net>
	<14385191E87B904DBD836449AA30269D6DE63A@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@simtec.co.uk, netdev@vger.kernel.org, support@tincantools.com
To: Tristram.Ha@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37066
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752832Ab0ECUDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 16:03:09 -0400
In-Reply-To: <14385191E87B904DBD836449AA30269D6DE63A@MORGANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Date: Mon, 3 May 2010 12:06:21 -0700

> The transmit done interrupt in the KSZ8851 chips is not required for
> normal operation.  Turning it off actually will improve transmit
> performance because the system will not be interrupted every time a
> packet is sent.

But you only trigger this workqueue when you notice in ->ndo_start_xmit()
that you're out of space.

This makes the chip sit idle with no packets to send until the workqueue
executes asynchronously to the initial transmit path which noticed the
queue was full.

That doesn't make any sense to me.  If anything you should at least try
to purge the TX queue and make space directly in the ->ndo_start_xmit()
handler.  And if that fails trigger an hrtimer to poll the TX state.

Without some kind of timer based polling mechanism, if the workqueue
finds the TX queue is still full, what's going to do more checks
later?  You will no longer get ->ndo_start_xmit() calls because the
queue has been marked full, so nothing will trigger the workqueue to
run any more.
