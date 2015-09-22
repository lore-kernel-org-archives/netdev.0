From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] 8139cp: Improve accuracy of cp_interrupt() return,
 to survive IRQ storms
Date: Tue, 22 Sep 2015 16:45:22 -0700 (PDT)
Message-ID: <20150922.164522.1769837358584981735.davem@davemloft.net>
References: <1442843991.7367.4.camel@infradead.org>
	<1442844109.7367.5.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758811AbbIVXpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 19:45:25 -0400
In-Reply-To: <1442844109.7367.5.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 21 Sep 2015 15:01:49 +0100

> From: David Woodhouse <David.Woodhouse@intel.com>
> 
> The TX timeout handling has been observed to trigger RX IRQ storms. And
> since cp_interrupt() just keeps saying that it handled the interrupt,
> the machine then dies. Fix the return value from cp_interrupt(), and
> the offending IRQ gets disabled and the machine survives.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Like Francois, I don't like this.

First of all, there are only 3 bits not handled explicitly by
cp_interrupt().  And for those if they are set and no other condition
was rasied, you should report the event and the status bits set, and
then forcibly clear the interrupt.

And if we are getting Rx* interrupts with napi_schedule_prep()
returning false, that's a serious problem.  It can mean that the TX
timeout handler's resetting of the chip is either miscoded or is
racing with either NAPI polling or this interrupt handler.

And if that's the case your patch is making the chip's IRQ line get
disabled when this race triggers.

This change is even worse, in my opinion, if patch #2 indeed makes
the problem go away.
