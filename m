From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Fri, 21 Feb 2014 14:10:35 -0300
Message-ID: <20140221171034.GA2488@localhost.localdomain>
References: <20140221100158.GA19594@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tobias Waldekranz <tobias@waldekranz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755212AbaBURKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 12:10:40 -0500
Content-Disposition: inline
In-Reply-To: <20140221100158.GA19594@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 21, 2014 at 11:01:58AM +0100, Tobias Waldekranz wrote:
> I have a system with the following configuration:
> 
>    * eth0 is a regular Ethernet MAC, connected to a hardware switch.
>    * port[1-4] are the in-kernel representation of the switch.
>    * team0 is a regular team-interface which bonds port1 and port2.
> 
>       +-------+
>       | team0 |
>       +---+---+
>           |
>      +----+----+
>      |         |
>  +---+---+ +---+---+ +-------+ +-------+
>  | port1 | | port2 | | port3 | | port4 | 
>  +---+---+ +---+---+ +---+---+ +---+---+
>      |         |         |         |
>      +---------+----+----+---------+
>                     |
>                 +---+---+
>                 | eth0  |
>                 +-------+
> 
> Both the switch and the team driver attaches rx-handlers to their
> lower layers. The problem is that team expects LACP frames that
> are intercepted by team0, to also be delivered to the port interface
> by __netif_receive_skb_core (in the final iteration of the registered
> protocols). However in this case, when two rx-handlers are cascaded,
> the skb will be delivered to eth0, since that is the original device
> (orig_dev).

Indeed. It is not possible to update orig_dev, so it is stuck
on eth0 regardless of all the stacked interfaces.

> There are a few ways this can be solved as far as i can see:
> 
>    1. Introduce a new rx-handler return code that specifies that
>    skb->dev has been altered, like RX_HANDLER_ANOTHER, and that we
>    also want to change orig_dev to this new device.

But then you need to know which rx-handler will run next, because
the orig_dev might still be implicit wanted.
 
>    2. Change the switch driver to return RX_HANDLER_CONSUMED and then
>    queue the skb all over again, though I am afraid that this will eat
>    some cycles.

Before queue again, you need to update skb->dev, right? This seems
similar to (1).

>    3. Keep track of all traversed interfaces and change the final
>    protocol iteration to deliver the skb to all intermediate devices.

That's what I thought too.

fbl
