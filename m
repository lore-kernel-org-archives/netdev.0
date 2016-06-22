From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: 802.3ad bonding aggregator reselection
Date: Tue, 21 Jun 2016 17:49:01 -0700
Message-ID: <20835.1466556541@famine>
References: <CAKdSkDUb94mR7cDiZbxsc6fgm_8O5wagjUec4g-t5DF7R_GFDw@mail.gmail.com> <CAKdSkDUfat0bM=WBv-Numnaa0MVKu2V6Rcx8eUeTZjcuDiYLpw@mail.gmail.com> <CAD=hENdGOFY5027964=f3xk_qeNmVccHYvr2rvTJtpFmaeFG2w@mail.gmail.com> <CAKdSkDXPYPvHh=AOyysAPWpR0eoMf-wobCTdi35GsF3FYbLxag@mail.gmail.com> <13338.1466523960@famine> <CAKdSkDWo-fwEMkZGQn2gkL+wT2yWEv1k-t+vVanZ-Cxzi=PcXQ@mail.gmail.com>
Cc: zhuyj <zyjzyj2000@gmail.com>, netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:37679 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239AbcFVAtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 20:49:14 -0400
In-reply-to: <CAKdSkDWo-fwEMkZGQn2gkL+wT2yWEv1k-t+vVanZ-Cxzi=PcXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
[...]
>>>The ports are configured in switch settings (HP Procurve 2530-48G) in
>>>same trunk group (TrkX) and trunk group type is set as LACP.
>>>/proc/net/bonding/bond0 also shows that the three ports belong to same
>>>aggregator and bandwidth tests also support this. In my understanding
>>>Procurve's trunk group is pretty much the same as etherchannel in
>>>Cisco's terminology. The bonded link comes always up properly, but
>>>handling of links going down is the problem. Are there known
>>>differences between different vendors there?
>>
>>         I did the original LACP reselection testing on a Cisco switch,
>> but I have an HP 2530 now; I'll test it later today or tomorrow and see
>> if it behaves properly, and whether your proposed patch is needed.
>
>Thanks for taking a look at this. Here are some more details about the
>setup as Zhu Yanjun also requested.

	Summary (because anything involving a standard tends to get long
winded):

	This is not a switch problem.  Bonding appears to be following
the standard in this case.  I've identified when this behavior changed,
and I think we should violate the standard in this case for ad_select
set to "bandwidth" or "count," neither of which is the default value.

	Long winded version:

	I've reproduced the issue locally, and it does not appear to be
anything particular to the switch.  It appears to be due to changes from

commit 7bb11dc9f59ddcb33ee317da77b235235aaa582a
Author: Mahesh Bandewar <maheshb@google.com>
Date:   Sat Oct 31 12:45:06 2015 -0700

    bonding: unify all places where actor-oper key needs to be updated.

	Specifically this block:

 void bond_3ad_handle_link_change(struct slave *slave, char link)
[...]
-       /* there is no need to reselect a new aggregator, just signal the
-        * state machines to reinitialize
-        */
-       port->sm_vars |= AD_PORT_BEGIN;

	Previously, setting BEGIN would cause the port in question to be
reinitialized, which in turn would trigger reselection.

	I'm not sure that adding this section back is the correct fix
from the point of view of the standard, however, as 802.1AX 5.2.3.1.2
defines BEGIN as:

	A Boolean variable that is set to TRUE when the System is
	initialized or reinitialized, and is set to FALSE when
	(re-)initialization has completed.

	and in this case we're not reinitializing the System (i.e., the
bond).

	Further, 802.1AX 5.4.12 says:

	If the port becomes inoperable and a BEGIN event has not
	occurred, the state machine enters the PORT_DISABLED
	state. Partner_Oper_Port_State.Synchronization is set to
	FALSE. This state allows the current Selection state to remain
	undisturbed, so that, in the event that the port is still
	connected to the same Partner and Partner port when it becomes
	operable again, there will be no disturbance caused to higher
	layers by unneccessary re-configuration.

	At the moment, bonding is doing what 5.4.12 specifies, by
placing the port into PORT_DISABLED state.  bond_3ad_handle_link_change
clears port->is_enabled, which causes ad_rx_machine to clear
AD_PORT_MATCHED but leave AD_PORT_SELECTED set.  This in turn cause the
selection logic to skip this port, resulting in the observed behavior
(that the port is link down, but stays in the aggregator).

	Bonding will still remove the slave from the bond->slave_arr, so
it won't actually try to send on this slave.  I'll further note that
802.1AX 5.4.7 defines port_enabled as:

	A variable indicating that the physical layer has indicated that
	the link has been established and the port is operable.
	Value: Boolean
	TRUE if the physical layer has indicated that the port is operable.
	FALSE otherwise.

	So, it appears that bonding is in conformance with the standard
in this case.

	I don't see an issue with the above behavior when ad_select is
set to the default value of "stable"; bonding does reselect a new
aggregator when all links fail, and it appears to follow the standard.

	I think a reasonable compromise here is to utilize a modified
version of your patch that clears SELECTED (to trigger reselection) when
a link goes down, but only if ad_select is not "stable", for example:

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b9304a295f86..1ee5a3a5e658 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2458,6 +2458,8 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 		/* link has failed */
 		port->is_enabled = false;
 		ad_update_actor_keys(port, true);
+		if (__get_agg_selection_mode(port) != BOND_AD_STABLE)
+			port->port->sm_vars &= ~AD_PORT_SELECTED;
 	}
 	netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
 		   port->actor_port_number,

	I'll test this locally and will submit a formal patch with an
update to bonding.txt tomorrow (if it works).

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
