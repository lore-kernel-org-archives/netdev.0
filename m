From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Fri, 10 Aug 2007 14:39:14 -0700 (PDT)
Message-ID: <20070810.143914.18309374.davem@davemloft.net>
References: <1186587154.5155.43.camel@localhost>
	<adamyx0od9p.fsf@cisco.com>
	<1186754107.5188.32.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, xma@us.ibm.com, jgarzik@pobox.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	shemminger@linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755197AbXHJVjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:39:23 -0400
In-Reply-To: <1186754107.5188.32.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 10 Aug 2007 09:55:07 -0400

> On Thu, 2007-09-08 at 09:58 -0700, Roland Dreier wrote:
> 
> > Could you explain why this is unfair?  
> 
> The simple answer is the core attempts DRR scheduling (search for the
> paper by Varghese et al for more details)
> If you have multiple users of a resource (network interfaces in this
> case), then the quantum defines their weight. If you use more than your
> fair quota, then you are being unfair. 

Actually, in the ipoib case they use less than their share :)

When they re-enable interrupts and then recheck for pending events, if
events are pending they re-disable interrupts and return immediately
instead of looping and trying to use the rest of their available
"budget" in-situ.

They do this because the time it takes to return back to the ->poll()
invoker and then call back into ->poll() the chip accumulates more
work.

If they don't do this it's really easy for them to hit cases where
they process one packet, enable interrupts, more events arrive, so
re-disable interrupts and loop, over and over again which is very
inefficient if that is in fact what happens.

To be honest, it's a workaround for the hardware design and they would
do well with even the most minimalist HW irq mitigation assist.
