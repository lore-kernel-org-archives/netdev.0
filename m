From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Thu, 19 Jul 2007 17:27:47 +0100
Message-ID: <20070719172747.7f01b38e@oldman.hamilton.local>
References: <200707101244.32753.okir@lst.de>
	<200707110941.38587.okir@lst.de>
	<20070711.193320.102574858.davem@davemloft.net>
	<200707191719.21034.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Olaf Kirch <okir@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58710 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758288AbXGSQ2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 12:28:00 -0400
In-Reply-To: <200707191719.21034.okir@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 17:19:19 +0200
Olaf Kirch <okir@lst.de> wrote:

> On Thursday 12 July 2007 04:33, David Miller wrote:
> > I'll add merge your patch with a target of 2.6.23
> > 
> > If you really want, after this patch has sat in 2.6.23 for a while
> > and got some good testing, we can consider a submission for -stable.
> 
> Okay, those of you who followed the discussion on lkml will have
> read why this patch breaks on e1000.
> 
> Short summary: some NIC drivers expect that there is a one-to-one
> relation between calls to net_rx_schedule (where we put the device
> on the poll list) and netif_rx_complete (where it's supposed to be
> taken off the list). The e1000 is such a beast. Not sure if other
> drivers make the same assumption re NAPI.
> 
> So: should a driver be allowed to rely on this behavior? Or should
> I go and look for another fix to the poll_napi issue?
> 
> I keep coming back to the question Jarek asked - why does netpoll
> want to call dev->poll() anyway? I dug around a little and it
> seems the original idea was to do this only if netpoll_poll was
> running on the CPU the netdevice was scheduled to.
> 
> So one way to fix the problem is to add a dev->poll_cpu field
> that tells us on which CPU's poll list it has been added - and
> check for this in poll_napi.
> 
> Comments?

Please revisit the requirements that netconsole needs and redesign it
from scratch.  The existing code  is causing too much breakage. 

Can it be done without breaking the semantics of network
devices, or should we rewrite the driver interface to take have a different
interface like netdev_sync_send_skb()  that is slow, synchronous and 
non-interrupt (ie polls for completion).  Of course, then people will complain
that netconsole traffic slows the machine down.
for completion.

> David, should I submit an updated patch for 2.6.23, or do you
> prefer to yank the patch now and try again for 2.6.24?
> 
> Olaf
> -- 
> Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
> okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
