From: =?UTF-8?B?SMOla29uIEzDuHZkYWw=?= <hlovdal@gmail.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Mon, 9 May 2011 03:30:10 +0200
Message-ID: <BANLkTin77k5oHGvn-E-6asQForB62it1Yw@mail.gmail.com>
References: <BANLkTik_gMCHYp4sOnzzR1Gs=bn2pkpjfQ@mail.gmail.com>
	<20110508.161012.258121848.davem@davemloft.net>
	<BANLkTimao-Zyk6ypW3UxzqtsgmQ-6qvYng@mail.gmail.com>
	<20110508.171204.27789908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mfmooney@gmail.com, joe@perches.com, aquini@linux.com,
	kernel-janitors@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, shemminger@vyatta.com, netdev@vger.kernel.org,
	nikai@nikai.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:45905 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab1EIBaL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 21:30:11 -0400
In-Reply-To: <20110508.171204.27789908.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 May 2011 02:12, David Miller <davem@davemloft.net> wrote:
> From: H=C3=A5kon L=C3=B8vdal <hlovdal@gmail.com>
> Date: Mon, 9 May 2011 02:08:41 +0200
>
>> void bond_3ad_state_machine_handler(struct work_struct *work)
>> {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct bonding *bond =3D container_of(wo=
rk, struct bonding,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 ad_work.work);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct port *port;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct aggregator *aggregator;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_lock(&bond->lock);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (! bond->kill_timers) {
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 //check if t=
here are any slaves
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (bond->sl=
ave_cnt !=3D 0) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 ...
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 queue_delaye=
d_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_unlock(&bond->lock);
>> }
>>
>>
>> And this was what I trying to reccommend against (and which the
>> stackoverflow question is about).
>
> I really don't see anything wrong with either approach.

The example above looks innocent since it is so small. But written
this way, the all of core of the function ("...") will have two extra,
unnecessary indentation levels. My rule of thumb is to always test for
exceptions, not the normal case.


Expanding the example to cover the full function, it could be like the
following:


void bond_3ad_state_machine_handler(struct work_struct *work)
{
        struct bonding *bond =3D container_of(work, struct bonding,
                                            ad_work.work);
        struct port *port;
        struct aggregator *aggregator;

        read_lock(&bond->lock);

        if (! bond->kill_timers)
        {
                //check if there are any slaves
                if (bond->slave_cnt !=3D 0)
                {
                        int uninitialized =3D 0;
                        // check if agg_select_timer timer after
initialize is timed out
                        if (BOND_AD_INFO(bond).agg_select_timer &&
!(--BOND_AD_INFO(bond).agg_select_timer)) {
                                // select the active aggregator for the=
 bond
                                if ((port =3D __get_first_port(bond))) =
{
                                        if (port->slave) {
                                                aggregator =3D
__get_first_agg(port);

ad_agg_selection_logic(aggregator);
                                        } else {
                                                pr_warning("%s:
Warning: bond's first port is uninitialized\n",
                                                           bond->dev->n=
ame);
                                                uninitialized =3D 1;
                                        }

                                }
                                if (! uninitialized)|
                                        bond_3ad_set_carrier(bond);
                        }

                        if (! uninitialized) {
                                // for each port run the state machines
                                for (port =3D __get_first_port(bond);
port; port =3D __get_next_port(port)) {
                                        if (port->slave) {

                                                /* Lock around state
machines to protect data accessed
                                                 * by all (e.g.,
port->sm_vars).  ad_rx_machine may run
                                                 * concurrently due to
incoming LACPDU.
                                                 */
                                                __get_state_machine_loc=
k(port);

                                                ad_rx_machine(NULL, por=
t);
                                                ad_periodic_machine(por=
t);
                                                ad_port_selection_logic=
(port);
                                                ad_mux_machine(port);
                                                ad_tx_machine(port);

                                                // turn off the BEGIN
bit, since we already handled it
                                                if (port->sm_vars &
AD_PORT_BEGIN)
                                                        port->sm_vars
&=3D ~AD_PORT_BEGIN;


__release_state_machine_lock(port);
                                        } else {
                                                pr_warning("%s:
Warning: Found an uninitialized port\n",
                                                           bond->dev->n=
ame);
                                        }
                                }
                        }

                }
                queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_i=
n_ticks);
        }
        read_unlock(&bond->lock);
}

Notice for instance "aggregator =3D __get_first_agg(port);" now have 5
levels of indentation in addition to the function body level, compared
to just 2 in the original.

That extra indentation is one thing, but the most important in my opini=
on
is that layout of the code becomes harder to read. This is because the
error handling code will typically be much more intrusive in the "layou=
t".
Good code written like

        if (error_check) {
                error
                handling
                code
        }
        normal
        code
        here

is possible to quickly scan/read, but if code is written like

        if (some_check) {
                error
                handling
                code
        } else {
                normal
                code
                here
        }

or

        if (some_check) {
                normal
                code
                here
        } else {
                error
                handling
                code
        }

you have to go into slow gear and read and mentally process (relatively=
)
much more of the code to get the same picture. Combine a few such if/el=
se,
nested - now everything is tightly intervened and impossible to quickly
grasp and/or hold in your head.

And the "uninitialized" variable is a crutch.


BR H=C3=A5kon L=C3=B8vdal
