From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Fri, 8 Jul 2016 15:22:30 +0300
Message-ID: <CAKdSkDUvv1YNp5hmposci87_yZqkanS3zswL4txOCzA+CJFgSQ@mail.gmail.com>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com>
 <20295.1467215964@famine> <CAKdSkDXprDpOUbKqw7+sqAj8LZ2tGC17YONmX0D1oLLUnCvRYw@mail.gmail.com>
 <CAKdSkDXBhg-n=TrZ6UiVp-xSxgYmKJ3Oaa-5ei_N+kRu7Xf_5Q@mail.gmail.com>
 <29688.1467753616@famine> <CAKdSkDUkW5DaM_nDkyMNAhWC_MAXK2pXzt-T9opQKDm0xdhibQ@mail.gmail.com>
 <21892.1467942487@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36755 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755072AbcGHMWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 08:22:34 -0400
Received: by mail-oi0-f53.google.com with SMTP id f189so58876888oig.3
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 05:22:34 -0700 (PDT)
In-Reply-To: <21892.1467942487@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-07-08 4:48 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
>
>>2016-07-06 0:20 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:

>>Thanks for the pointers. Adding some extra debug in __enable_port
>>helped me to get in right direction. And adding quite a bit of extra
>>debug information after that.
>>
>>It looks like I'm hitting a case where the port is not initialized
>>when bond_update_slave_arr is run and this causes a failure in
>>bond_xmit_slave_id as it cannot find any ports that would be usable
>>for sending.
>>
>>When the aggregator changes for the first time, __disable_port() is
>>called for all the ports in the old aggregator in
>>ad_agg_selection_logic():
>>
>>                if (active) {
>>                        for (port = active->lag_ports; port;
>>                             port = port->next_port_in_aggregator) {
>>                                __disable_port(port);
>>                        }
>>                }
>>                /* Slave array needs update. */
>>                *update_slave_arr = true;
>>
>>This sets slave->inactive for the port and also slave->backup is set.
>>These are still set when agg_selection_logic() is called to reselect
>>the aggregator with your patch. It sets the is_enabled flag, but does
>>not touch inactive and backup flags.
>>
>>ad_agg_selection_logic() sets update_slave_arr to true, but the port
>>is not enabled yet when bond_update_slave_arr() gets called. When
>>__enable_port() is called for the ports in ad_mux_machine() case
>>AD_MUX_COLLECTING_DISTRIBUTING, bond_update_slave_arr() is not called
>>again. This leaves the xmit hash without any slaves. I added some
>>debugging in bond_3ad_xor_xmit() to see that it drops packets while
>>connection is not working. The problem is cleared right away when a
>>port comes up and bond_update_slave_arr() gets called.
>
>         I think this is the key right here.  The slave array update and
> the move to COLL_DIST state are not synchronized, and the port is not
> eligible to be added to the array until it reaches COLL_DIST state.
>
>         This is managed by __enable/__disable_port, which changes the
> backup flag that bond_update_slave_arr uses to test for eligibility in
> 802.3ad mode (via bond_slave_can_tx).
>
> [ from an earlier message ]
>>It is also possible to reproduce this with two aggregators with two
>>links each. The steps are:
>>
>>   Agg 1   Agg 2
>>   P1 P2   P3 P4
>>   X   X   X   X   OK (Agg 2 active)
>>   X   X   X   -   OK (Agg 1 active)
>>   X   -   X   -   OK (Agg 1 active)
>>   -   -   X   -   Fail (Agg 2 active)
>
>         I think I might see what's the sequence of events; stepping
> through the above for P3:
>
>         1) Should be up and ok.  Presumably COLL_DIST state.
>
>         2) P3 is run through __disable_port by agg_selection at "LAG %d
> chosen as the active LAG" when "Agg 1" is made the active aggregator.
> Still likely COLL_DIST state, as all this does is set slave->inactive
> (which affects packet RX logic, but not the LACP state).  I don't see a
> message for "Disabling port" in the debug log that would be printed if
> it went through ad_disable_coll/dist.

>         3) no change to P3
>
>         4) link change calls ad_agg_selection_logic, and then updates
> slave array, but P3 is still ->inactive, so isn't added.  Later, the
> state machine calls ad_mux_machine, which hits the case that calls
> __enable_port, but this case doesn't also update the slave array,
> leading to the issue at hand.

Yes, this is what I'm seeing after adding debug information to the
relevant calls.


>         Prior to the slave arrays, __enable_port would be enough to
> permit the port to send and receive traffic, but an array update needs
> to be done when __enable_port actually enables the port.


>>I was able to get it working by setting the update_slave_arr in
>>ad_mux_machine when a port is enabled. I'm not sure if this the best
>>place to get bond_update_slave_arr() invoked, but it seems to do the
>>trick.
>>
>>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>>index ca81f46..9b8653c 100644
>>--- a/drivers/net/bonding/bond_3ad.c
>>+++ b/drivers/net/bonding/bond_3ad.c
>>@@ -970,6 +980,9 @@ static void ad_mux_machine(struct port *port, bool
>>*update_slave_arr)
>>                                    !__port_is_enabled(port)) {
>>
>>                                        __enable_port(port);
>>+
>>+                                       if (__port_is_enabled(port))
>>+                                               *update_slave_arr = true;
>>                                }
>>                        }
>>                        break;
>
>         The part I didn't follow at first is that later on in
> ad_mux_machine it does:
>
>                 switch (port->sm_mux_state) {
> [...]
>                 case AD_MUX_COLLECTING_DISTRIBUTING:
>                         port->actor_oper_port_state |= AD_STATE_COLLECTING;
>                         port->actor_oper_port_state |= AD_STATE_DISTRIBUTING;
>                         port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
>                         ad_enable_collecting_distributing(port,
>                                                           update_slave_arr);
>                         port->ntt = true;
>                         break;
>
>         and ad_enable_collecting_distributing should set
> update_slave_arr, so in principle it shouldn't be necessary to add your
> logic to ad_mux_machine.
>
>         But, this switch case section will run first (because it occurs
> when the port initially goes into COLL_DIST state), and the earlier
> section that you changed happens the next time through the state
> machine, when the port is already in COLL_DIST state.  So, the section I
> copied above setting update_slave_arr won't do anything, because the
> port is not enabled until the next pass through the state machine.
>
>         I wonder if this is the real problem here: that the port does
> not become enabled until the second pass through the state machine in
> COLL_DIST state, and then only as a failsafe:
>
>                                 /* if port state hasn't changed make
>                                  * sure that a collecting distributing
>                                  * port in an active aggregator is enabled
>                                  */
>
>         Perhaps this happens because in your case the port enters (or
> stays in) COLL_DIST state when it is not part of the active aggregator,
> and ad_enable_coll/dist doesn't call __enable_port for the port.

I added some debugging there and this seems to be the case.

>         The current call to __enable_port in ad_agg_selection_logic will
> only enable the port if it has no partner and is the active aggregator,
> which should be the case only when the port's link partner is not
> enabled for LACP, so in theory that should not apply here.

After adding some debugging again, it looks like in
ad_agg_selection_logic() calls __enable_port() here when the bond is
being set up and the first port ends up being treated here as an
individual port. But there's no call to __enable_port() here after the
bond has been setup properly and link partner is found.

        if (active) {
                if (!__agg_has_partner(active)) {
                        for (port = active->lag_ports; port;
                             port = port->next_port_in_aggregator) {
                                __enable_port(port);
                        }
                }
        }


>>The earlier patch that called __enable_port() in
>>ad_agg_selection_logic probably did the same by getting the inactive
>>and backup flags cleared so that bond_update_slave_arr() included the
>>ports in the xmit hash, but I haven't looked through the steps there.
>>I really cannot claim to understand all the logic in the code, so this
>>might be totally wrong..
>
>         Either fix (agg_selection_logic enabling all ports in the new
> active agg, or ad_mux_machine setting *update_slave_arr = true) seems to
> resolve the issue.  I'm not 100% sure about edge cases yet, though.
>
>         We're kind of in uncharted territory here a bit with regard to
> the behavior required by the standard, since it doesn't really address
> choosing between multiple possible aggregators.
>
>         Thinking about it, I am leaning towards the logic of your prior
> patch, the one that enables all ports when an aggregator is made active
> in ad_agg_selection_logic.  That feels to me to be a clearer fix, and I
> think it may get the slave array properly updated 100ms faster (as it
> won't wait for a subsequent invocation of the state machine).
>
>         I think the following will do the right thing (disclaimer: I
> have not even tried to compile this):

I did do some testing with similar change already yesterday before
posting the other patch and this patch does fix the problem at least
in this case.

Calling __enable_port() in ad_agg_selection_logic does seem to get the
state corrected faster and I'd say that there are less dropped packets
than having ad_mux_machine set *update_slave_arr = true. But I really
don't have an environment to test where the traffic would be the same
between tests, so this is just my feeling.

> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index edc70ffad660..2da5be91226e 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -1713,18 +1713,12 @@ static void ad_agg_selection_logic(struct aggregator *agg,
>                 *update_slave_arr = true;
>         }
>
> -       /* if the selected aggregator is of join individuals
> -        * (partner_system is NULL), enable their ports
> -        */
>         active = __get_active_agg(origin);
>
>         if (active) {
> -               if (!__agg_has_partner(active)) {
> -                       for (port = active->lag_ports; port;
> -                            port = port->next_port_in_aggregator) {
> -                               __enable_port(port);
> -                       }
> -               }
> +               for (port = active->lag_ports; port;
> +                    port = port->next_port_in_aggregator)
> +                       __enable_port(port);
>         }
>
>         rcu_read_unlock();
>
>
>         Rather than adding a new loop as your original patch did, this
> one repurposes the existing loop for individual links and does the
> enable for all cases.
>
>         I think this may still need a check for the port state in there,
> as ports in the aggregator may be link up but still not suitable for
> TX/RX if the LACP negotiation doesn't put the port into COLL_DIST state.
>
>         Enabling a port that is already enabled is harmless, and if the
> port is link down, the enable will do nothing, so I think this should
> resolve things.

I can test any patches with additional checks, but this change seems
to fix it for us.

Thanks for help! It has been enlightening to dig through the code to
actually understand what happens.

Veli-Matti
