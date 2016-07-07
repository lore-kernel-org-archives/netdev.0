From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Thu, 7 Jul 2016 23:04:01 +0300
Message-ID: <CAKdSkDUkW5DaM_nDkyMNAhWC_MAXK2pXzt-T9opQKDm0xdhibQ@mail.gmail.com>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com>
 <20295.1467215964@famine> <CAKdSkDXprDpOUbKqw7+sqAj8LZ2tGC17YONmX0D1oLLUnCvRYw@mail.gmail.com>
 <CAKdSkDXBhg-n=TrZ6UiVp-xSxgYmKJ3Oaa-5ei_N+kRu7Xf_5Q@mail.gmail.com> <29688.1467753616@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33708 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcGGUEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 16:04:04 -0400
Received: by mail-oi0-f52.google.com with SMTP id u201so38230220oie.0
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 13:04:03 -0700 (PDT)
In-Reply-To: <29688.1467753616@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-07-06 0:20 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
>
>>2016-06-30 14:15 GMT+03:00 Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>:
>>> 2016-06-29 18:59 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
>>>> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
>>
>>>>         I tried this locally, but don't see any failure (at the end, the
>>>> "Switch A" agg is still active with the single port).  I am starting
>>>> with just two ports in each aggregator (instead of three), so that may
>>>> be relevant.
>>>
>>> When the connection problem occurs, /proc/net/bonding/bond0 always
>>> shows the aggregator that has a link up active. Dumpcap sees at least
>>> broadcast traffic on the port, but I haven't done extensive analysis
>>> on that yet. All TCP connections are cut until the bond is up again
>>> when more ports are enabled on the switch. ping doesn't work either
>>> way.
>>
>>I did some further testing on this and it looks like I can get this
>>working by enabling the ports in the new aggregator the same way as
>>the ports in old aggregator are disabled in ad_agg_selection_logic().
>
>         I tested with this some as well, using 6 ports total across two
> switches, and was still not able to reproduce the issue.  How are you
> configuring the bond in the first place?  It may be that there is some
> dependency on the ordering of the slaves within the bond and how they
> are disabled.

The switch configuration should be pretty basic - port group that has
LACP as type. L4 based hashing is configured on the switches. The bond
is running as untagged on the ports. "show run" shows them as such:

trunk 20-22 trk4 lacp
trunk-load-balance L4-based

Both switches have similar configuration. I'm not an expert in switch
configurations, so I do not know if there's anything else interesting
in there.

The servers are running Ubuntu 16.04 and systemd-networkd is used to
configure the interfaces. Using /etc/network/interfaces failed quite
often to setup all interfaces at boot time, so we switched over to
systemd-networkd.

>         Also, I am taking the ports down by physically unplugging the
> cable from the switch.  If you're doing it differently, that might be
> relevant.

The servers are in remote location, so I'm disabling the ports in
switch configuration. Unfortunately I do not have a similar setup that
I could access physically at the moment.

>>Normally the ports seem to get enabled from ad_mux_machine() in "case
>>AD_MUX_COLLECTING_DISTRIBUTING", but something different happens there
>>as the port does get enabled, but no traffic passes through. So far I
>>haven't been able to figure out what happens. When the connection is
>>lost, dumpcap sees traffic on the only active port in the bond, but it
>>seems like nothing catches it. If I disable and re-enable the same
>>port, traffic start flowing again normally.
>
>         Looking at the debug log you provided, the step that fails
> appears to correspond to this portion:

...

>         The "Periodic Machine" 3->4 then 4->3 then "Sent LACPDU" looks
> normal (3->4 is the periodic timer expiring, state 4 sets port->ntt,
> then the next iteration moves back to state 3), and includes both send
> and receive of LACPDUs on port 2 (which is enp5s0f0).
>
>         I don't see a transition to COLL/DIST state for port 2 in the
> log, so presumably it takes place prior to the beginning.  This is the
> place that would call __enable_port.
>
>         What you're describing sounds consistent with the slave not
> being set to active, which would cause bond_handle_frame ->
> bond_should_deliver_exact_match to return RX_HANDLER_EXACT.
>
>         This leads me to wonder if the port in question is in this
> incorrect state from the beginning, but it only manifests once it
> becomes the only active port.
>
>         Can you instrument __enable_port to see when it is called for
> the bad port, and if it actually calls bond_set_slave_active_flags for
> the port in question (without your additional patch)?

Thanks for the pointers. Adding some extra debug in __enable_port
helped me to get in right direction. And adding quite a bit of extra
debug information after that.

It looks like I'm hitting a case where the port is not initialized
when bond_update_slave_arr is run and this causes a failure in
bond_xmit_slave_id as it cannot find any ports that would be usable
for sending.

When the aggregator changes for the first time, __disable_port() is
called for all the ports in the old aggregator in
ad_agg_selection_logic():

                if (active) {
                        for (port = active->lag_ports; port;
                             port = port->next_port_in_aggregator) {
                                __disable_port(port);
                        }
                }
                /* Slave array needs update. */
                *update_slave_arr = true;

This sets slave->inactive for the port and also slave->backup is set.
These are still set when agg_selection_logic() is called to reselect
the aggregator with your patch. It sets the is_enabled flag, but does
not touch inactive and backup flags.

ad_agg_selection_logic() sets update_slave_arr to true, but the port
is not enabled yet when bond_update_slave_arr() gets called. When
__enable_port() is called for the ports in ad_mux_machine() case
AD_MUX_COLLECTING_DISTRIBUTING, bond_update_slave_arr() is not called
again. This leaves the xmit hash without any slaves. I added some
debugging in bond_3ad_xor_xmit() to see that it drops packets while
connection is not working. The problem is cleared right away when a
port comes up and bond_update_slave_arr() gets called.

I can try to collect debug logs with some extra debugging enabled if that helps.

I was able to get it working by setting the update_slave_arr in
ad_mux_machine when a port is enabled. I'm not sure if this the best
place to get bond_update_slave_arr() invoked, but it seems to do the
trick.

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index ca81f46..9b8653c 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -970,6 +980,9 @@ static void ad_mux_machine(struct port *port, bool
*update_slave_arr)
                                    !__port_is_enabled(port)) {

                                        __enable_port(port);
+
+                                       if (__port_is_enabled(port))
+                                               *update_slave_arr = true;
                                }
                        }
                        break;

The earlier patch that called __enable_port() in
ad_agg_selection_logic probably did the same by getting the inactive
and backup flags cleared so that bond_update_slave_arr() included the
ports in the xmit hash, but I haven't looked through the steps there.
I really cannot claim to understand all the logic in the code, so this
might be totally wrong..


Veli-Matti
