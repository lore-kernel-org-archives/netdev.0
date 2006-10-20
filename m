From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 14:01:49 -0700 (PDT)
Message-ID: <20061020.140149.125893169.davem@davemloft.net>
References: <20061020084015.5c559326@localhost.localdomain>
	<20061020.134209.85688168.davem@davemloft.net>
	<20061020134826.75dd1cba@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9603
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946504AbWJTVBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 17:01:49 -0400
To: shemminger@osdl.org
In-Reply-To: <20061020134826.75dd1cba@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 20 Oct 2006 13:48:26 -0700

> On Fri, 20 Oct 2006 13:42:09 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > We really can't handle TX stopped this way from the netpoll_send_skb()
> > path.  All that old retry logic in netpoll_send_skb() is really
> > necessary.
> > 
> > If we are in deep IRQ context, took an OOPS, and are trying to get a
> > netpoll packet out for the kernel log message, we have to try as hard
> > as possible to get the packet out then and there, even if that means
> > waiting some amount of time for netif_queue_stopped() to become false.
> 
> But, it also violates the assumptions of the network devices.
> It calls NAPI poll back with IRQ's disabled and potentially doesn't
> obey the semantics about only running on the same CPU as the
> received packet.

Actually, all the locking here is fine, that's why it checks
poll_owner for current smp_processor_id().

Otherwise it is safe to sit and spin waiting for link up/down or
TX full conditions to pass.

> So we can try once and if that fails we have to defer to tasklet.

Not true, we should spin and retry for some reasonable amount of time.
That "reasonable amount of time" should be the maximum of the time
it takes to free up space from a TX full condition and the time it
takes to bring the link up.

That is what the current code is trying to do, and you've erroneously
deleted all of that logic.
