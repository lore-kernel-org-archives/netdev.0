From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 1/1][CORE] resend - fix free_netdev on register_netdev
 failure
Date: Tue, 30 Oct 2007 21:52:43 -0700
Message-ID: <20071030215243.60e276bf@freepuppy.rosehill>
References: <20071030161925.487151276@mai.toulouse-stg.fr.ibm.com>
	<20071030162059.010348834@mai.toulouse-stg.fr.ibm.com>
	<20071030.153830.120597346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36476 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751216AbXJaExj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 00:53:39 -0400
In-Reply-To: <20071030.153830.120597346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Oct 2007 15:38:30 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> Date: Tue, 30 Oct 2007 17:19:26 +0100
> 
> > Point 1:
> > The unregistering of a network device schedule a netdev_run_todo.
> > This function calls dev->destructor when it is set and the
> > destructor calls free_netdev.
> > 
> > Point 2:
> > In the case of an initialization of a network device the usual code
> > is:
> >  * alloc_netdev
> >  * register_netdev
> >     -> if this one fails, call free_netdev and exit with error.
> > 
> > Point 3:
> > In the register_netdevice function at the later state, when the device
> > is at the registered state, a call to the netdevice_notifiers is made.
> > If one of the notification falls into an error, a rollback to the
> > registered state is done using unregister_netdevice.
> > 
> > Conclusion:
> > When a network device fails to register during initialization because
> > one network subsystem returned an error during a notification call
> > chain, the network device is freed twice because of fact 1 and fact 2.
> > The second free_netdev will be done with an invalid pointer.
> > 
> > Proposed solution:
> > The following patch move all the code of unregister_netdevice *except* 
> > the call to net_set_todo, to a new function "rollback_registered".
> > 
> > The following functions are changed in this way:
> >  * register_netdevice: calls rollback_registered when a notification fails
> >  * unregister_netdevice: calls rollback_register + net_set_todo, the call
> >                          order to net_set_todo is changed because it is the
> >                          latest now. Since it justs add an element to a list
> >                          that should not break anything.
> > 
> > Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> Looks good, applied.

Agreed, but I wish the unwind code wouldn't have to be separate function.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
