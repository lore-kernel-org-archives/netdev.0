From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Thu, 07 Jul 2016 18:48:07 -0700
Message-ID: <21892.1467942487@famine>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com> <20295.1467215964@famine> <CAKdSkDXprDpOUbKqw7+sqAj8LZ2tGC17YONmX0D1oLLUnCvRYw@mail.gmail.com> <CAKdSkDXBhg-n=TrZ6UiVp-xSxgYmKJ3Oaa-5ei_N+kRu7Xf_5Q@mail.gmail.com> <29688.1467753616@famine> <CAKdSkDUkW5DaM_nDkyMNAhWC_MAXK2pXzt-T9opQKDm0xdhibQ@mail.gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:49086 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbcGHBsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 21:48:19 -0400
In-reply-to: <CAKdSkDUkW5DaM_nDkyMNAhWC_MAXK2pXzt-T9opQKDm0xdhibQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:

>2016-07-06 0:20 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
>> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
>>
>>>2016-06-30 14:15 GMT+03:00 Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>:
>>>> 2016-06-29 18:59 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
>>>>> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
>>>
>>>>>         I tried this locally, but don't see any failure (at the end, the
>>>>> "Switch A" agg is still active with the single port).  I am starting
>>>>> with just two ports in each aggregator (instead of three), so that may
>>>>> be relevant.
>>>>
>>>> When the connection problem occurs, /proc/net/bonding/bond0 always
>>>> shows the aggregator that has a link up active. Dumpcap sees at least
>>>> broadcast traffic on the port, but I haven't done extensive analysis
>>>> on that yet. All TCP connections are cut until the bond is up again
>>>> when more ports are enabled on the switch. ping doesn't work either
>>>> way.
>>>
>>>I did some further testing on this and it looks like I can get this
>>>working by enabling the ports in the new aggregator the same way as
>>>the ports in old aggregator are disabled in ad_agg_selection_logic().
>>
>>         I tested with this some as well, using 6 ports total across two
>> switches, and was still not able to reproduce the issue.  How are you
>> configuring the bond in the first place?  It may be that there is some
>> dependency on the ordering of the slaves within the bond and how they
>> are disabled.
>
>The switch configuration should be pretty basic - port group that has
>LACP as type. L4 based hashing is configured on the switches. The bond
>is running as untagged on the ports. "show run" shows them as such:
>
>trunk 20-22 trk4 lacp
>trunk-load-balance L4-based
>
>Both switches have similar configuration. I'm not an expert in switch
>configurations, so I do not know if there's anything else interesting
>in there.
>
>The servers are running Ubuntu 16.04 and systemd-networkd is used to
>configure the interfaces. Using /etc/network/interfaces failed quite
>often to setup all interfaces at boot time, so we switched over to
>systemd-networkd.
>
>>         Also, I am taking the ports down by physically unplugging the
>> cable from the switch.  If you're doing it differently, that might be
>> relevant.
>
>The servers are in remote location, so I'm disabling the ports in
>switch configuration. Unfortunately I do not have a similar setup that
>I could access physically at the moment.
>
>>>Normally the ports seem to get enabled from ad_mux_machine() in "case
>>>AD_MUX_COLLECTING_DISTRIBUTING", but something different happens there
>>>as the port does get enabled, but no traffic passes through. So far I
>>>haven't been able to figure out what happens. When the connection is
>>>lost, dumpcap sees traffic on the only active port in the bond, but it
>>>seems like nothing catches it. If I disable and re-enable the same
>>>port, traffic start flowing again normally.
>>
>>         Looking at the debug log you provided, the step that fails
>> appears to correspond to this portion:
>
>...
>
>>         The "Periodic Machine" 3->4 then 4->3 then "Sent LACPDU" looks
>> normal (3->4 is the periodic timer expiring, state 4 sets port->ntt,
>> then the next iteration moves back to state 3), and includes both send
>> and receive of LACPDUs on port 2 (which is enp5s0f0).
>>
>>         I don't see a transition to COLL/DIST state for port 2 in the
>> log, so presumably it takes place prior to the beginning.  This is the
>> place that would call __enable_port.
>>
>>         What you're describing sounds consistent with the slave not
>> being set to active, which would cause bond_handle_frame ->
>> bond_should_deliver_exact_match to return RX_HANDLER_EXACT.
>>
>>         This leads me to wonder if the port in question is in this
>> incorrect state from the beginning, but it only manifests once it
>> becomes the only active port.
>>
>>         Can you instrument __enable_port to see when it is called for
>> the bad port, and if it actually calls bond_set_slave_active_flags for
>> the port in question (without your additional patch)?
>
>Thanks for the pointers. Adding some extra debug in __enable_port
>helped me to get in right direction. And adding quite a bit of extra
>debug information after that.
>
>It looks like I'm hitting a case where the port is not initialized
>when bond_update_slave_arr is run and this causes a failure in
>bond_xmit_slave_id as it cannot find any ports that would be usable
>for sending.
>
>When the aggregator changes for the first time, __disable_port() is
>called for all the ports in the old aggregator in
>ad_agg_selection_logic():
>
>                if (active) {
>                        for (port = active->lag_ports; port;
>                             port = port->next_port_in_aggregator) {
>                                __disable_port(port);
>                        }
>                }
>                /* Slave array needs update. */
>                *update_slave_arr = true;
>
>This sets slave->inactive for the port and also slave->backup is set.
>These are still set when agg_selection_logic() is called to reselect
>the aggregator with your patch. It sets the is_enabled flag, but does
>not touch inactive and backup flags.
>
>ad_agg_selection_logic() sets update_slave_arr to true, but the port
>is not enabled yet when bond_update_slave_arr() gets called. When
>__enable_port() is called for the ports in ad_mux_machine() case
>AD_MUX_COLLECTING_DISTRIBUTING, bond_update_slave_arr() is not called
>again. This leaves the xmit hash without any slaves. I added some
>debugging in bond_3ad_xor_xmit() to see that it drops packets while
>connection is not working. The problem is cleared right away when a
>port comes up and bond_update_slave_arr() gets called.

	I think this is the key right here.  The slave array update and
the move to COLL_DIST state are not synchronized, and the port is not
eligible to be added to the array until it reaches COLL_DIST state.

	This is managed by __enable/__disable_port, which changes the
backup flag that bond_update_slave_arr uses to test for eligibility in
802.3ad mode (via bond_slave_can_tx).

[ from an earlier message ]
>It is also possible to reproduce this with two aggregators with two
>links each. The steps are:
>
>   Agg 1   Agg 2
>   P1 P2   P3 P4
>   X   X   X   X   OK (Agg 2 active)
>   X   X   X   -   OK (Agg 1 active)
>   X   -   X   -   OK (Agg 1 active)
>   -   -   X   -   Fail (Agg 2 active)

	I think I might see what's the sequence of events; stepping
through the above for P3:

	1) Should be up and ok.  Presumably COLL_DIST state.

	2) P3 is run through __disable_port by agg_selection at "LAG %d
chosen as the active LAG" when "Agg 1" is made the active aggregator.
Still likely COLL_DIST state, as all this does is set slave->inactive
(which affects packet RX logic, but not the LACP state).  I don't see a
message for "Disabling port" in the debug log that would be printed if
it went through ad_disable_coll/dist.

	3) no change to P3

	4) link change calls ad_agg_selection_logic, and then updates
slave array, but P3 is still ->inactive, so isn't added.  Later, the
state machine calls ad_mux_machine, which hits the case that calls
__enable_port, but this case doesn't also update the slave array,
leading to the issue at hand.

	Prior to the slave arrays, __enable_port would be enough to
permit the port to send and receive traffic, but an array update needs
to be done when __enable_port actually enables the port.

>I can try to collect debug logs with some extra debugging enabled if that helps.
>
>I was able to get it working by setting the update_slave_arr in
>ad_mux_machine when a port is enabled. I'm not sure if this the best
>place to get bond_update_slave_arr() invoked, but it seems to do the
>trick.
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index ca81f46..9b8653c 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -970,6 +980,9 @@ static void ad_mux_machine(struct port *port, bool
>*update_slave_arr)
>                                    !__port_is_enabled(port)) {
>
>                                        __enable_port(port);
>+
>+                                       if (__port_is_enabled(port))
>+                                               *update_slave_arr = true;
>                                }
>                        }
>                        break;

	The part I didn't follow at first is that later on in
ad_mux_machine it does:

		switch (port->sm_mux_state) {
[...]
                case AD_MUX_COLLECTING_DISTRIBUTING:
                        port->actor_oper_port_state |= AD_STATE_COLLECTING;
                        port->actor_oper_port_state |= AD_STATE_DISTRIBUTING;
                        port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
                        ad_enable_collecting_distributing(port,
                                                          update_slave_arr);
                        port->ntt = true;
                        break;

	and ad_enable_collecting_distributing should set
update_slave_arr, so in principle it shouldn't be necessary to add your
logic to ad_mux_machine.

	But, this switch case section will run first (because it occurs
when the port initially goes into COLL_DIST state), and the earlier
section that you changed happens the next time through the state
machine, when the port is already in COLL_DIST state.  So, the section I
copied above setting update_slave_arr won't do anything, because the
port is not enabled until the next pass through the state machine.

	I wonder if this is the real problem here: that the port does
not become enabled until the second pass through the state machine in
COLL_DIST state, and then only as a failsafe:

                                /* if port state hasn't changed make
                                 * sure that a collecting distributing
                                 * port in an active aggregator is enabled
                                 */

	Perhaps this happens because in your case the port enters (or
stays in) COLL_DIST state when it is not part of the active aggregator,
and ad_enable_coll/dist doesn't call __enable_port for the port.

	The current call to __enable_port in ad_agg_selection_logic will
only enable the port if it has no partner and is the active aggregator,
which should be the case only when the port's link partner is not
enabled for LACP, so in theory that should not apply here.

>The earlier patch that called __enable_port() in
>ad_agg_selection_logic probably did the same by getting the inactive
>and backup flags cleared so that bond_update_slave_arr() included the
>ports in the xmit hash, but I haven't looked through the steps there.
>I really cannot claim to understand all the logic in the code, so this
>might be totally wrong..

	Either fix (agg_selection_logic enabling all ports in the new
active agg, or ad_mux_machine setting *update_slave_arr = true) seems to
resolve the issue.  I'm not 100% sure about edge cases yet, though.

	We're kind of in uncharted territory here a bit with regard to
the behavior required by the standard, since it doesn't really address
choosing between multiple possible aggregators.

	Thinking about it, I am leaning towards the logic of your prior
patch, the one that enables all ports when an aggregator is made active
in ad_agg_selection_logic.  That feels to me to be a clearer fix, and I
think it may get the slave array properly updated 100ms faster (as it
won't wait for a subsequent invocation of the state machine).

	I think the following will do the right thing (disclaimer: I
have not even tried to compile this):

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index edc70ffad660..2da5be91226e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1713,18 +1713,12 @@ static void ad_agg_selection_logic(struct aggregator *agg,
 		*update_slave_arr = true;
 	}
 
-	/* if the selected aggregator is of join individuals
-	 * (partner_system is NULL), enable their ports
-	 */
 	active = __get_active_agg(origin);
 
 	if (active) {
-		if (!__agg_has_partner(active)) {
-			for (port = active->lag_ports; port;
-			     port = port->next_port_in_aggregator) {
-				__enable_port(port);
-			}
-		}
+		for (port = active->lag_ports; port;
+		     port = port->next_port_in_aggregator)
+			__enable_port(port);
 	}
 
 	rcu_read_unlock();


	Rather than adding a new loop as your original patch did, this
one repurposes the existing loop for individual links and does the
enable for all cases.

	I think this may still need a check for the port state in there,
as ports in the aggregator may be link up but still not suitable for
TX/RX if the LACP negotiation doesn't put the port into COLL_DIST state.

	Enabling a port that is already enabled is harmless, and if the
port is link down, the enable will do nothing, so I think this should
resolve things.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
