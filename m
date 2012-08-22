From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding: time limits too tight in bond_ab_arp_inspect
Date: Wed, 22 Aug 2012 11:42:02 -0700
Message-ID: <24655.1345660922@death.nxdomain>
References: <20120822174534.GA20260@midget.suse.cz> <50351CC5.3030109@genband.com>
Cc: Jiri Bohac <jbohac@suse.cz>, Andy Gospodarek <andy@greyhouse.net>,
	netdev@vger.kernel.org, Petr Tesarik <ptesarik@suse.cz>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:60133 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818Ab2HVSmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 14:42:50 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 22 Aug 2012 12:42:49 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 3C0603E40042
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 12:42:46 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7MIgVUD102846
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 12:42:34 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7MIg45n005604
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 12:42:06 -0600
In-reply-to: <50351CC5.3030109@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <chris.friesen@genband.com> wrote:

>On 08/22/2012 11:45 AM, Jiri Bohac wrote:
>
>> This code is run from bond_activebackup_arp_mon() about
>> delta_in_ticks jiffies after the previous ARP probe has been
>> sent. If the delayed work gets executed exactly in delta_in_ticks
>> jiffies, there is a chance the slave will be brought up.  If the
>> delayed work runs one jiffy later, the slave will stay down.

	Presumably the ARP reply is coming back in less than one jiffy,
then, so the slave_last_rx() value is the same jiffy as when the
_inspect was previously called?

><snip>
>
>> Should they perhaps all be increased by, say, delta_in_ticks/2, to make this
>> less dependent on the current scheduling latencies?
>
>We have been using a patch that tracks the arpmon requested sleep time vs
>the actual sleep time and adds any scheduling latency to the allowed
>delta.  That way if we sleep too long due to scheduling latency it doesn't
>affect the calculation.

	How much scheduling latency do you see?

	Is that really better than just permitting a bit more slack in
the timing window?

	As to the 2 * delta and 3 * delta calculations, these values
predate my involvement with bonding, so I'm not entirely sure why those
specific values were chosen (there are no log messages from that era
that I'm aware of).  My presumption has been that this part:

                /*
                 * Active slave is down if:
                 * - more than 2*delta since transmitting OR
                 * - (more than 2*delta since receive AND
                 *    the bond has an IP address)
                 */
                trans_start = dev_trans_start(slave->dev);
                if (bond_is_active_slave(slave) &&
                    (!time_in_range(jiffies,
                        trans_start - delta_in_ticks,
                        trans_start + 2 * delta_in_ticks) ||
                     !time_in_range(jiffies,
                        slave_last_rx(bond, slave) - delta_in_ticks,
                        slave_last_rx(bond, slave) + 2 * delta_in_ticks))) {

                        slave->new_link = BOND_LINK_DOWN;
                        commit++;
                }

	was structured this way (allowing 2 * delta) to permit the loss
of a single ARP on an otherwise idle interface without triggering a link
down.

	My guess, though, is that until relatively recently the timing
window was not too tight, and there was effectively some slack in the
calculation, because the slave_last_rx() would be set to some small
number of jiffies after the last exection of the monitor, and so the
"slave_last_rx() + delta_in_ticks" wasn't as narrow a window as it
appears to be now.

	So, without having tested this myself, based on the above, I
don't see that adding some slack would be a problem.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
