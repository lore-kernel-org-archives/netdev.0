From: Chris Friesen <chris.friesen@genband.com>
Subject: [BUG?]  bonding, slave selection, carrier loss, etc.
Date: Fri, 10 Feb 2012 17:47:04 -0600
Message-ID: <4F35AC78.3010907@genband.com>
References: <49CD5B93.7010407@nortel.com> <31087.1238198438@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>, andy@greyhouse.net,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og105.obsmtp.com ([64.18.2.163]:58488 "EHLO
	exprod7og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab2BJXyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 18:54:51 -0500
In-Reply-To: <31087.1238198438@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

I'm resurrecting an ancient discussion I had with Jay, because I think
the issue described below is still present and the code he talked about
submitting to close it doesn't appear to have ever gone in.

Basically in active/backup mode with mii monitoring there is a window
between the active slave device losing carrier and calling
netif_carrier_off() and the miimon code actually detecting the loss of
the carrier and selecting a new active slave.

The best solution would be for bonding to just register for notification
of the link going down.  Presumably most drivers should be doing that
properly by now, and for devices that get interrupt-driven notification
of link status changes this would allow the bonding code to react much
quicker.

Barring that, I think something like the following is needed.  This is
against 2.6.27, but could easily be reworked against current.



---------------------- drivers/net/bonding/bond_main.c -----------------------
index 8499558..e4445d8 100644
@@ -4313,20 +4313,33 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 	read_lock(&bond->lock);
 	read_lock(&bond->curr_slave_lock);
 
 	if (!BOND_IS_OK(bond)) {
 		goto out;
 	}
 
 	if (!bond->curr_active_slave)
 		goto out;
 
+	/* Verify that the active slave is actually up before
+	 * trying to send packets.  If it isn't, then
+	 * trigger the selection of a new active slave.
+	 */
+	if (!IS_UP(bond->curr_active_slave->dev)) {
+		read_unlock(&bond->curr_slave_lock);
+		write_lock(&bond->curr_slave_lock);
+		bond_select_active_slave(bond);
+		write_unlock(&bond->curr_slave_lock);
+		read_lock(&bond->curr_slave_lock);
+		if (!bond->curr_active_slave)
+			goto out;
+	}
 	res = bond_dev_queue_xmit(bond, skb, bond->curr_active_slave->dev);
 
 out:
 	if (res) {
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
 	}
 	read_unlock(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
 	return 0;

Chris




On 03/27/2009 06:00 PM, Jay Vosburgh wrote:
> Chris Friesen<cfriesen@nortel.com>  wrote:
> 
>> In a much earlier version of the bonding driver we ran into problems
>> where we could have lost carrier on one of the slaves, but at the time
>> of xmit the bonding driver hadn't yet switched to a better slave.
>> Because of this we added a patch very much like the one below.
>>
>> A quick glance at the current bonding code would seem to indicate that
>> there could still be a window between the active slave device losing
>> carrier and calling netif_carrier_off() and the miimon code actually
>> detecting the loss of the carrier and selecting a new active slave.
>> Do I have this correct?  If so, would the patch below be correct?
> 
> 	Yes, the window is equal to whatever the monitoring interval is
> (for miimon) or double the interval for ARP.
> 
> 	Your patch, I think, would work, but it's suboptimal in that it
> only affects one mode, and doesn't resolve any of the bigger issues with
> the link monitoring system in bonding (see below).  Trying to do the
> equivalent in other modes may have issues; some modes require RTNL to be
> held when changing slave states, so it's difficult to do that from the
> transmit routine.
> 
>> On a related note--assuming the net driver can detect link loss and
>> is properly calling netif_carrier_off() why do we still need to poll
>> the status in the bonding driver?  Isn't there some way to hook into
>> the network stack and get notified when the carrier goes down?
> 
> 	This is actually something I'm working on now.
> 
> 	There are notifier callbacks that are tied to a driver calling
> netif_carrier_on or _off.  The problem is that a bunch of older (mostly
> 10/100, although acenic is a gigabit) drivers don't do netif_carrier_on
> or _off, or check their link state on a ridiculously long interval, so
> simply dropping the current miimon implementation and replacing it with
> the event notifier may not be feasible for backwards compatibility
> reasons.  Heck, I've still got 3c59x and acenic cards in my test
> systems, neither of which do netif_carrier correctly; I can't be the
> only one.
> 
> 	An additional goal is to permit the state change notifications
> (or miimon) and the ARP monitor to run concurrently.  Sadly, the current
> "link state" system can't handle two things simultaneously poking at the
> slave's link state; if, e.g., ARP says down, but MII/notifiers says up,
> then the link state can flap, so it needs a sort of "arbitrator."
> 
> 	A minor advantage of reworking all of that is that it should end
> up being less code when all done, and should be more modular, so it'd be
> easier if somebody wanted to add, say, an ICMP probe monitor.
> 
> 	I'll probably be posting an RFC patch next week.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 


-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
