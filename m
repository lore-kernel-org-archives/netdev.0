From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Re: 802.3ad bonding aggregator reselection
Date: Wed, 22 Jun 2016 20:43:50 +0300
Message-ID: <CAKdSkDVjoS7djSbZhGku=vdkPDq5cbADUxAh4GEzpWhnByjiww@mail.gmail.com>
References: <CAKdSkDUb94mR7cDiZbxsc6fgm_8O5wagjUec4g-t5DF7R_GFDw@mail.gmail.com>
 <CAKdSkDUfat0bM=WBv-Numnaa0MVKu2V6Rcx8eUeTZjcuDiYLpw@mail.gmail.com>
 <CAD=hENdGOFY5027964=f3xk_qeNmVccHYvr2rvTJtpFmaeFG2w@mail.gmail.com>
 <CAKdSkDXPYPvHh=AOyysAPWpR0eoMf-wobCTdi35GsF3FYbLxag@mail.gmail.com>
 <13338.1466523960@famine> <CAKdSkDWo-fwEMkZGQn2gkL+wT2yWEv1k-t+vVanZ-Cxzi=PcXQ@mail.gmail.com>
 <20835.1466556541@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: zhuyj <zyjzyj2000@gmail.com>, netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35385 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbcFVRod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:44:33 -0400
Received: by mail-oi0-f41.google.com with SMTP id r2so33253348oih.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 10:43:51 -0700 (PDT)
In-Reply-To: <20835.1466556541@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-06-22 3:49 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
>
> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
> [...]
>>>>The ports are configured in switch settings (HP Procurve 2530-48G) in
>>>>same trunk group (TrkX) and trunk group type is set as LACP.
>>>>/proc/net/bonding/bond0 also shows that the three ports belong to same
>>>>aggregator and bandwidth tests also support this. In my understanding
>>>>Procurve's trunk group is pretty much the same as etherchannel in
>>>>Cisco's terminology. The bonded link comes always up properly, but
>>>>handling of links going down is the problem. Are there known
>>>>differences between different vendors there?
>>>
>>>         I did the original LACP reselection testing on a Cisco switch,
>>> but I have an HP 2530 now; I'll test it later today or tomorrow and see
>>> if it behaves properly, and whether your proposed patch is needed.
>>
>>Thanks for taking a look at this. Here are some more details about the
>>setup as Zhu Yanjun also requested.
>
>         Summary (because anything involving a standard tends to get long
> winded):
>
>         This is not a switch problem.  Bonding appears to be following
> the standard in this case.  I've identified when this behavior changed,
> and I think we should violate the standard in this case for ad_select
> set to "bandwidth" or "count," neither of which is the default value.
>
>         Long winded version:
>
>         I've reproduced the issue locally, and it does not appear to be
> anything particular to the switch.  It appears to be due to changes from
>
> commit 7bb11dc9f59ddcb33ee317da77b235235aaa582a
> Author: Mahesh Bandewar <maheshb@google.com>
> Date:   Sat Oct 31 12:45:06 2015 -0700
>
>     bonding: unify all places where actor-oper key needs to be updated.
>
>         Specifically this block:
>
>  void bond_3ad_handle_link_change(struct slave *slave, char link)
> [...]
> -       /* there is no need to reselect a new aggregator, just signal the
> -        * state machines to reinitialize
> -        */
> -       port->sm_vars |= AD_PORT_BEGIN;
>
>         Previously, setting BEGIN would cause the port in question to be
> reinitialized, which in turn would trigger reselection.
>
>         I'm not sure that adding this section back is the correct fix
> from the point of view of the standard, however, as 802.1AX 5.2.3.1.2
> defines BEGIN as:
>
>         A Boolean variable that is set to TRUE when the System is
>         initialized or reinitialized, and is set to FALSE when
>         (re-)initialization has completed.
>
>         and in this case we're not reinitializing the System (i.e., the
> bond).
>
>         Further, 802.1AX 5.4.12 says:
>
>         If the port becomes inoperable and a BEGIN event has not
>         occurred, the state machine enters the PORT_DISABLED
>         state. Partner_Oper_Port_State.Synchronization is set to
>         FALSE. This state allows the current Selection state to remain
>         undisturbed, so that, in the event that the port is still
>         connected to the same Partner and Partner port when it becomes
>         operable again, there will be no disturbance caused to higher
>         layers by unneccessary re-configuration.
>
>         At the moment, bonding is doing what 5.4.12 specifies, by
> placing the port into PORT_DISABLED state.  bond_3ad_handle_link_change
> clears port->is_enabled, which causes ad_rx_machine to clear
> AD_PORT_MATCHED but leave AD_PORT_SELECTED set.  This in turn cause the
> selection logic to skip this port, resulting in the observed behavior
> (that the port is link down, but stays in the aggregator).
>
>         Bonding will still remove the slave from the bond->slave_arr, so
> it won't actually try to send on this slave.  I'll further note that
> 802.1AX 5.4.7 defines port_enabled as:
>
>         A variable indicating that the physical layer has indicated that
>         the link has been established and the port is operable.
>         Value: Boolean
>         TRUE if the physical layer has indicated that the port is operable.
>         FALSE otherwise.
>
>         So, it appears that bonding is in conformance with the standard
> in this case.

I haven't done extensive testing on this, but I haven't noticed
anything that would indicate that anything is sent to failed ports. So
this part should be working.

>         I don't see an issue with the above behavior when ad_select is
> set to the default value of "stable"; bonding does reselect a new
> aggregator when all links fail, and it appears to follow the standard.

In my testing ad_select=stable does not reselect a new aggregator when
all links have failed. Reselection seems to occur only when a link
comes up the failure. Here's an example of two bonds having three
links each. Aggregator ID 3 is active with three ports and ID 2 has
also three ports up.


802.3ad info
LACP rate: fast
Min links: 0
Aggregator selection policy (ad_select): stable
System priority: 65535
System MAC address: 0c:c4:7a:34:c7:f1
Active Aggregator Info:
        Aggregator ID: 3
        Number of ports: 3
        Actor Key: 9
        Partner Key: 57
        Partner Mac Address: 6c:3b:e5:df:7a:80


Disable all ports in aggregator id 2 (enp5s0f1, ens5f1 and ens6f1) in
switch configuration at the same time:

[  146.783003] ixgbe 0000:05:00.1 enp5s0f1: NIC Link is Down
[  146.783223] ixgbe 0000:05:00.1 enp5s0f1: speed changed to 0 for port enp5s0f1
[  146.858824] bond0: link status down for interface enp5s0f1,
disabling it in 200 ms
[  147.058932] bond0: link status definitely down for interface
enp5s0f1, disabling it
[  147.291259] igb 0000:81:00.1 ens5f1: igb: ens5f1 NIC Link is Down
[  147.303303] igb 0000:82:00.1 ens6f1: igb: ens6f1 NIC Link is Down
[  147.358862] bond0: link status down for interface ens6f1, disabling
it in 200 ms
[  147.358868] bond0: link status down for interface ens5f1, disabling
it in 200 ms
[  147.558929] bond0: link status definitely down for interface
ens6f1, disabling it
[  147.558987] bond0: link status definitely down for interface
ens5f1, disabling it

At this point there is no connection to the host and the aggregator
with all failed links is still active.

802.3ad info
LACP rate: fast
Min links: 0
Aggregator selection policy (ad_select): stable
System priority: 65535
System MAC address: 0c:c4:7a:34:c7:f1
Active Aggregator Info:
        Aggregator ID: 3
        Number of ports: 3
        Actor Key: 9
        Partner Key: 57
        Partner Mac Address: 6c:3b:e5:df:7a:80

If I then bring down an interface that is connected to an active
switch port and bring it back up, reselection is done:

# ifconfig ens5f0 down
# ifconfig ens5f0 up

[  190.258900] bond0: link status down for interface ens5f0, disabling
it in 200 ms
[  190.458934] bond0: link status definitely down for interface
ens5f0, disabling it
[  193.192453] 8021q: adding VLAN 0 to HW filter on device ens5f0
[  196.156105] igb 0000:81:00.0 ens5f0: igb: ens5f0 NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX
[  196.158912] bond0: link status up for interface ens5f0, enabling it in 200 ms
[  196.360471] bond0: link status definitely up for interface ens5f0,
1000 Mbps full duplex

802.3ad info
LACP rate: fast
Min links: 0
Aggregator selection policy (ad_select): stable
System priority: 65535
System MAC address: 0c:c4:7a:34:c7:f1
Active Aggregator Info:
        Aggregator ID: 2
        Number of ports: 3
        Actor Key: 9
        Partner Key: 57
        Partner Mac Address: 6c:3b:e5:e0:90:80

At this point all connections resume normally.

Are you able to reproduce this or is reselection working as expected?


>         I think a reasonable compromise here is to utilize a modified
> version of your patch that clears SELECTED (to trigger reselection) when
> a link goes down, but only if ad_select is not "stable", for example:
>
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index b9304a295f86..1ee5a3a5e658 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -2458,6 +2458,8 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
>                 /* link has failed */
>                 port->is_enabled = false;
>                 ad_update_actor_keys(port, true);
> +               if (__get_agg_selection_mode(port) != BOND_AD_STABLE)
> +                       port->port->sm_vars &= ~AD_PORT_SELECTED;
>         }
>         netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
>                    port->actor_port_number,
>
>         I'll test this locally and will submit a formal patch with an
> update to bonding.txt tomorrow (if it works).
>
>         -J
>
> ---
>         -Jay Vosburgh, jay.vosburgh@canonical.com
