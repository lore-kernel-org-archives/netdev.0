From: James Chapman <jchapman@katalix.com>
Subject: Re: NAPI poll behavior in various Intel drivers
Date: Fri, 04 Jan 2008 20:10:30 +0000
Message-ID: <477E92B6.8010809@katalix.com>
References: <20080104.034036.160194618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:58420 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753737AbYADVc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 16:32:26 -0500
In-Reply-To: <20080104.034036.160194618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Several Intel networking drivers such as e1000, e1000e
> and e100 all do this to exit NAPI polling:
> 
> 	if ((!tx_cleaned && (work_done == 0)) ||
>  	   !netif_running(poll_dev)) {
> 
> I tried to make this use in the NAPI rework:
> 
> 	if ((!tx_cleaned && (work_done < budget)) ||
>  	   !netif_running(poll_dev)) {
> 
> But that got reverted by:
> 
> 	commit f7bbb9098315d712351aba7861a8c9fcf6bf0213
> 
> 	e1000: Fix NAPI state bug when Rx complete
>     
> 	Don't exit polling when we have not yet used our budget, this causes
> 	the NAPI system to end up with a messed up poll list.
>     
> 	Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 	Signed-off-by: Jeff Garzik <jeff@garzik.org>
> 
> I definitely would not have signed off on that :-)
> 
> That "tx_cleaned" thing clouds the logic in all of these driver's
> poll routines.
> 
> The one necessary precondition is that when work_done < budget
> we exit polling and return a value less than budget.
> 
> If the ->poll() returns a value less than budget, net_rx_action()
> assumes that the device has been removed from the poll() list.
> 
> 		/* Drivers must not modify the NAPI state if they
> 		 * consume the entire weight.  In such cases this code
> 		 * still "owns" the NAPI instance and therefore can
> 		 * move the instance around on the list at-will.
> 		 */
> 		if (unlikely(work == weight))
> 			list_move_tail(&n->poll_list, list);
> 
> This "work_done == 0" test in these drivers, is thus, wrong.  It
> should be "work_done < budget" and the whole tx_cleaned thing needs to
> be removed.
> 
> It happens to work, because what happens is that we loop again and
> process the same NAPI struct again.
> 
> As a result, E1000 devices get polled TWICE every time they
> process at least one RX packet, but do not consume the whole
> quota.
> 
> I smell a performance hack, and if so this is wrong and against
> all of the principles of NAPI.  Either that or it's a workaround
> for the "!netif_running()" case.

You have a good nose, Dave. :) And you can probably partly blame me for
this scheme. I worked with the e100 driver author (Scott Feldman) 5
years ago to performance tune and stress test the driver. I found much
better packets/sec forwarding performance (packets in one e100, out
another) by staying in polled mode until no receive or transmit was done.

With the latest NAPI, this code has to change. But rather than remove
the tx_cleaned logic completely, shouldn't transmit processing be
included in the work_done accounting when a driver does transmit cleanup
processing in the poll? If not, then when an interface is transmitting
far more than receiving, it will exit polled mode on every poll.

> I noticed this while trying to work on a generic fix for the
> "->poll() does not exit when device is brought down while being
> bombed with packets" bug.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

