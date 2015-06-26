From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: Issue with LACP mode in linux bonding driver
Date: Fri, 26 Jun 2015 14:19:26 -0700
Message-ID: <13466.1435353566@famine>
References: <CADAe=+LvNgHV+crN_+E4xB+Pcz=KSvZpK5ADKzYFjHL2gGJq2Q@mail.gmail.com> <6462.1435284902@famine> <CADAe=+LmF_O5Tw_+kcg35urKBjJJOFZrYs3R2LNkdh-XW6r2ng@mail.gmail.com>
Cc: vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:57303 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbbFZVTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 17:19:31 -0400
In-reply-to: <CADAe=+LmF_O5Tw_+kcg35urKBjJJOFZrYs3R2LNkdh-XW6r2ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ajith Adapa <adapa.ajith@gmail.com> wrote:

>On 26 June 2015 at 07:45, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>> echo 'module bonding =p' > /sys/kernel/debug/dynamic_debug/control
>Hi,
>
>thanks for the reply.

	I tried this out a bit here, and could reproduce the problem on
3.13, but not on 4.0.0.  A bit of checking suggests that this problem is
fixed by the following commit:

commit 63b46242f707849a1df10b70e026281bfa40e849
Author: Wilson Kok <wkok@cumulusnetworks.com>
Date:   Mon Jan 26 01:16:59 2015 -0500

    bonding: fix incorrect lacp mux state when agg not active

	which looks to have first appeared in the 4.0 kernel.  I did a
quick backport of that to 3.13 (leaving out the style and pr_debug
changes), and it appears to resolve the problem.

	Ajith: can you test this patch?  If this resolves the problem
for you, we can request this patch for -stable to get it into the older
kernels.

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index dc0c56a..8c62f90 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -890,19 +890,23 @@ static void ad_mux_machine(struct port *port)
 		case AD_MUX_ATTACHED:
 			// check also if agg_select_timer expired(so the edable port will take place only after this timer)
 			if ((port->sm_vars & AD_PORT_SELECTED) && (port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) && !__check_agg_selection_timer(port)) {
-				port->sm_mux_state = AD_MUX_COLLECTING_DISTRIBUTING;// next state
+				if (port->aggregator->is_active)
+					port->sm_mux_state = AD_MUX_COLLECTING_DISTRIBUTING;// next state
 			} else if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_STANDBY)) {	  // if UNSELECTED or STANDBY
 				port->sm_vars &= ~AD_PORT_READY_N;
 				// in order to withhold the selection logic to check all ports READY_N value
 				// every callback cycle to update ready variable, we check READY_N and update READY here
 				__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
 				port->sm_mux_state = AD_MUX_DETACHED;// next state
+			} else if (port->aggregator->is_active) {
+				port->actor_oper_port_state |=
+					AD_STATE_SYNCHRONIZATION;
 			}
 			break;
 		case AD_MUX_COLLECTING_DISTRIBUTING:
 			if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_STANDBY) ||
-			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION)
-			   ) {
+			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) ||
+			    !(port->actor_oper_port_state & AD_STATE_SYNCHRONIZATION)) {
 				port->sm_mux_state = AD_MUX_ATTACHED;// next state
 
 			} else {
@@ -941,7 +945,12 @@ static void ad_mux_machine(struct port *port)
 			break;
 		case AD_MUX_ATTACHED:
 			__attach_bond_to_agg(port);
-			port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
+			if (port->aggregator->is_active)
+				port->actor_oper_port_state |=
+					AD_STATE_SYNCHRONIZATION;
+			else
+				port->actor_oper_port_state &=
+					~AD_STATE_SYNCHRONIZATION;
 			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
 			port->actor_oper_port_state &= ~AD_STATE_DISTRIBUTING;
 			ad_disable_collecting_distributing(port);
@@ -950,6 +959,7 @@ static void ad_mux_machine(struct port *port)
 		case AD_MUX_COLLECTING_DISTRIBUTING:
 			port->actor_oper_port_state |= AD_STATE_COLLECTING;
 			port->actor_oper_port_state |= AD_STATE_DISTRIBUTING;
+			port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
 			ad_enable_collecting_distributing(port);
 			port->ntt = true;
 			break;
@@ -1350,6 +1360,9 @@ static void ad_port_selection_logic(struct port *port)
 
 	aggregator = __get_first_agg(port);
 	ad_agg_selection_logic(aggregator);
+
+	if (!port->aggregator->is_active)
+		port->actor_oper_port_state &= ~AD_STATE_SYNCHRONIZATION;
 }
 
 /*


	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
