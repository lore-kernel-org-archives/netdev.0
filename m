From: David Miller <davem@davemloft.net>
Subject: NAPI poll behavior in various Intel drivers
Date: Fri, 04 Jan 2008 03:40:36 -0800 (PST)
Message-ID: <20080104.034036.160194618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44027
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751419AbYADLkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:40:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several Intel networking drivers such as e1000, e1000e
and e100 all do this to exit NAPI polling:

	if ((!tx_cleaned && (work_done == 0)) ||
 	   !netif_running(poll_dev)) {

I tried to make this use in the NAPI rework:

	if ((!tx_cleaned && (work_done < budget)) ||
 	   !netif_running(poll_dev)) {

But that got reverted by:

	commit f7bbb9098315d712351aba7861a8c9fcf6bf0213

	e1000: Fix NAPI state bug when Rx complete
    
	Don't exit polling when we have not yet used our budget, this causes
	the NAPI system to end up with a messed up poll list.
    
	Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
	Signed-off-by: Jeff Garzik <jeff@garzik.org>

I definitely would not have signed off on that :-)

That "tx_cleaned" thing clouds the logic in all of these driver's
poll routines.

The one necessary precondition is that when work_done < budget
we exit polling and return a value less than budget.

If the ->poll() returns a value less than budget, net_rx_action()
assumes that the device has been removed from the poll() list.

		/* Drivers must not modify the NAPI state if they
		 * consume the entire weight.  In such cases this code
		 * still "owns" the NAPI instance and therefore can
		 * move the instance around on the list at-will.
		 */
		if (unlikely(work == weight))
			list_move_tail(&n->poll_list, list);

This "work_done == 0" test in these drivers, is thus, wrong.  It
should be "work_done < budget" and the whole tx_cleaned thing needs to
be removed.

It happens to work, because what happens is that we loop again and
process the same NAPI struct again.

As a result, E1000 devices get polled TWICE every time they
process at least one RX packet, but do not consume the whole
quota.

I smell a performance hack, and if so this is wrong and against
all of the principles of NAPI.  Either that or it's a workaround
for the "!netif_running()" case.

I noticed this while trying to work on a generic fix for the
"->poll() does not exit when device is brought down while being
bombed with packets" bug.
