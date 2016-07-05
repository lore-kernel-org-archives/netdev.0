From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Tue, 05 Jul 2016 14:20:16 -0700
Message-ID: <29688.1467753616@famine>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com> <20295.1467215964@famine> <CAKdSkDXprDpOUbKqw7+sqAj8LZ2tGC17YONmX0D1oLLUnCvRYw@mail.gmail.com> <CAKdSkDXBhg-n=TrZ6UiVp-xSxgYmKJ3Oaa-5ei_N+kRu7Xf_5Q@mail.gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47649 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbcGEVUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 17:20:23 -0400
In-reply-to: <CAKdSkDXBhg-n=TrZ6UiVp-xSxgYmKJ3Oaa-5ei_N+kRu7Xf_5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:

>2016-06-30 14:15 GMT+03:00 Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>:
>> 2016-06-29 18:59 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
>>> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
>
>>>         I tried this locally, but don't see any failure (at the end, the
>>> "Switch A" agg is still active with the single port).  I am starting
>>> with just two ports in each aggregator (instead of three), so that may
>>> be relevant.
>>
>> When the connection problem occurs, /proc/net/bonding/bond0 always
>> shows the aggregator that has a link up active. Dumpcap sees at least
>> broadcast traffic on the port, but I haven't done extensive analysis
>> on that yet. All TCP connections are cut until the bond is up again
>> when more ports are enabled on the switch. ping doesn't work either
>> way.
>
>I did some further testing on this and it looks like I can get this
>working by enabling the ports in the new aggregator the same way as
>the ports in old aggregator are disabled in ad_agg_selection_logic().

	I tested with this some as well, using 6 ports total across two
switches, and was still not able to reproduce the issue.  How are you
configuring the bond in the first place?  It may be that there is some
dependency on the ordering of the slaves within the bond and how they
are disabled.

	Also, I am taking the ports down by physically unplugging the
cable from the switch.  If you're doing it differently, that might be
relevant.

>Normally the ports seem to get enabled from ad_mux_machine() in "case
>AD_MUX_COLLECTING_DISTRIBUTING", but something different happens there
>as the port does get enabled, but no traffic passes through. So far I
>haven't been able to figure out what happens. When the connection is
>lost, dumpcap sees traffic on the only active port in the bond, but it
>seems like nothing catches it. If I disable and re-enable the same
>port, traffic start flowing again normally.

	Looking at the debug log you provided, the step that fails
appears to correspond to this portion:

[  367.811419] bond0: link status definitely down for interface enp5s0f1, disabl
ing it
[  367.811425] bond0: best Agg=2; P=3; a k=9; p k=57; Ind=0; Act=0
[  367.811429] bond0: best ports ffff8830113f6638 slave ffff8830113cfe00 enp5s0f
0
[  367.811432] bond0: Agg=1; P=3; a k=9; p k=57; Ind=0; Act=0
[  367.811434] bond0: Agg=2; P=3; a k=9; p k=57; Ind=0; Act=0
[  367.811437] bond0: Agg=3; P=0; a k=0; p k=0; Ind=0; Act=0
[  367.811439] bond0: Agg=4; P=0; a k=0; p k=0; Ind=0; Act=0
[  367.811441] bond0: Agg=5; P=0; a k=0; p k=0; Ind=0; Act=0
[  367.811444] bond0: Agg=6; P=0; a k=0; p k=0; Ind=0; Act=0
[  367.811446] bond0: LAG 2 chosen as the active LAG
[  367.811448] bond0: Agg=2; P=3; a k=9; p k=57; Ind=0; Act=1
[  367.811451] bond0: Port 1 changed link status to DOWN
[  367.811455] bond0: first active interface up!
[  367.811461] Rx Machine: Port=1 (enp5s0f1), Last State=6, Curr State=2
[  367.811495] ixgbe 0000:05:00.0 enp5s0f0: event: 1b
[  367.811497] ixgbe 0000:05:00.0 enp5s0f0: IFF_SLAVE
[  367.811519] ixgbe 0000:05:00.1 enp5s0f1: event: 19
[  367.811522] ixgbe 0000:05:00.1 enp5s0f1: IFF_SLAVE
[  367.811525] ixgbe 0000:05:00.1 enp5s0f1: event: 19
[  367.811528] ixgbe 0000:05:00.1 enp5s0f1: IFF_SLAVE
[  386.809542] Periodic Machine: Port=2, Last State=3, Curr State=4
[  386.909543] Periodic Machine: Port=2, Last State=4, Curr State=3
[  387.009530] update lacpdu: enp5s0f0, actor port state 3d
[  387.009541] Sent LACPDU on port 2
[  387.571372] bond0: Received LACPDU on port 2 slave enp5s0f0
[  387.571379] Rx Machine: Port=2 (enp5s0f0), Last State=6, Curr State=6
[  387.571381] enp5s0f0 partner sync=1
[  416.810767] Periodic Machine: Port=2, Last State=3, Curr State=4
[  416.910786] Periodic Machine: Port=2, Last State=4, Curr State=3
[  417.010749] update lacpdu: enp5s0f0, actor port state 3d
[  417.010761] Sent LACPDU on port 2
[  417.569137] bond0: Received LACPDU on port 2 slave enp5s0f0
[  417.569156] Rx Machine: Port=2 (enp5s0f0), Last State=6, Curr State=6
[... repeats this cycle for a while ....]
[  537.614050] enp5s0f0 partner sync=1
[  566.816851] Periodic Machine: Port=2, Last State=3, Curr State=4
[  566.916843] Periodic Machine: Port=2, Last State=4, Curr State=3
[  567.016829] update lacpdu: enp5s0f0, actor port state 3d
[  567.016839] Sent LACPDU on port 2
[  567.558379] bond0: Received LACPDU on port 2 slave enp5s0f0
[  567.558399] Rx Machine: Port=2 (enp5s0f0), Last State=6, Curr State=6
[  567.558403] enp5s0f0 partner sync=1
[  572.925434] igb 0000:81:00.0 ens5f0: igb: ens5f0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[  572.925862] igb 0000:81:00.0 ens5f0: event: 4
[  572.925865] igb 0000:81:00.0 ens5f0: IFF_SLAVE
[  572.925890] bond0: Port 6 Received link speed 0 update from adapter

	The "Periodic Machine" 3->4 then 4->3 then "Sent LACPDU" looks
normal (3->4 is the periodic timer expiring, state 4 sets port->ntt,
then the next iteration moves back to state 3), and includes both send
and receive of LACPDUs on port 2 (which is enp5s0f0).

	I don't see a transition to COLL/DIST state for port 2 in the
log, so presumably it takes place prior to the beginning.  This is the
place that would call __enable_port.

	What you're describing sounds consistent with the slave not
being set to active, which would cause bond_handle_frame ->
bond_should_deliver_exact_match to return RX_HANDLER_EXACT.

	This leads me to wonder if the port in question is in this
incorrect state from the beginning, but it only manifests once it
becomes the only active port.

	Can you instrument __enable_port to see when it is called for
the bad port, and if it actually calls bond_set_slave_active_flags for
the port in question (without your additional patch)?

	Actually, your patch looks to have some debug output; what does
that provide?

>Here's the patch I used for testing on top of 4.7.0-rc6. I haven't
>tested this with other modes or h/w setups yet.

	I'm a bit leery of putting this in until the root cause is
understood, as it otherwise may just be masking the real issue.

	-J

>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index ca81f46..45c06c4 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -1706,6 +1706,25 @@ static void ad_agg_selection_logic(struct
>aggregator *agg,
>                                __disable_port(port);
>                        }
>                }
>+
>+               /* Enable ports in the new aggregator */
>+                if (best) {
>+                       netdev_dbg(bond->dev, "Enable ports\n");
>+
>+                        for (port = best->lag_ports; port;
>+                             port = port->next_port_in_aggregator) {
>+                                netdev_dbg(bond->dev, "Agg: %d, P=%d:
>Port: %s; Enabled=%d\n",
>+                                            best->aggregator_identifier,
>+                                            best->num_of_ports,
>+                                            port->slave->dev->name,
>+                                            __port_is_enabled(port));
>+
>+                                if (!__port_is_enabled(port))
>+                                        __enable_port(port);
>+                        }
>+                }
>+
>+
>                /* Slave array needs update. */
>                *update_slave_arr = true;
>        }
>
>Veli-Matti

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
