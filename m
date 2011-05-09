From: =?UTF-8?B?SMOla29uIEzDuHZkYWw=?= <hlovdal@gmail.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Mon, 9 May 2011 02:08:41 +0200
Message-ID: <BANLkTimao-Zyk6ypW3UxzqtsgmQ-6qvYng@mail.gmail.com>
References: <1304791360.1738.6.camel@Joe-Laptop>
	<BANLkTimKs39m_htMFEygR+3Bfu7Butc-zQ@mail.gmail.com>
	<BANLkTik_gMCHYp4sOnzzR1Gs=bn2pkpjfQ@mail.gmail.com>
	<20110508.161012.258121848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mfmooney@gmail.com, joe@perches.com, aquini@linux.com,
	kernel-janitors@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, shemminger@vyatta.com, netdev@vger.kernel.org,
	nikai@nikai.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:57786 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab1EIAIn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 20:08:43 -0400
In-Reply-To: <20110508.161012.258121848.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 May 2011 01:10, David Miller <davem@davemloft.net> wrote:
> From: H=C3=A5kon L=C3=B8vdal <hlovdal@gmail.com>
> Date: Mon, 9 May 2011 01:08:44 +0200
>
>> On 7 May 2011 21:35, matt mooney <mfmooney@gmail.com> wrote:
>>> But isn't the preferred style to have a single exit point?
>>
>> This is generally considered to be a bad advice, see
>> http://stackoverflow.com/questions/1701686/why-should-methods-have-a=
-single-entry-and-exit-points/1701721#1701721
>> for instance.
>
> That article totally ignores the issue of locking and how hard it is
> to get right without single exit points, and how unlocking in
> multiple spots bloats up the code.
>
> Definitely don't take that article's advice when working on the
> kernel.
>

I think we agree, but my answer was probably too short, unclear and
imprecise. In the case of locking and single exit points in the kernel,
they are (almost always) reached through goto/labels, and this is a fin=
e
way of handling exiting a function, e.g.


void bond_3ad_state_machine_handler(struct work_struct *work)
{
        struct bonding *bond =3D container_of(work, struct bonding,
                                            ad_work.work);
        struct port *port;
        struct aggregator *aggregator;

        read_lock(&bond->lock);

        if (bond->kill_timers)
                goto out;

        //check if there are any slaves
        if (bond->slave_cnt =3D=3D 0)
              goto re_arm;

        ...

re_arm:
        queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks)=
;
out:
        read_unlock(&bond->lock);
}


I often advocate usage of goto to achive this kind of style.

What I assosiate with "writing a function as single exit style" would
be something like the following (and usually littered with
temporary remember-this-for-later variables).


void bond_3ad_state_machine_handler(struct work_struct *work)
{
        struct bonding *bond =3D container_of(work, struct bonding,
                                            ad_work.work);
        struct port *port;
        struct aggregator *aggregator;

        read_lock(&bond->lock);

        if (! bond->kill_timers) {

                //check if there are any slaves
                if (bond->slave_cnt !=3D 0) {
                        ...
                }
                queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_i=
n_ticks);
        }
        read_unlock(&bond->lock);
}


And this was what I trying to reccommend against (and which the
stackoverflow question is about). So most probably my assosiasion was t=
oo
implicit to make my reply useful. That was not the intention, hopefully
this followup clears up a little.

BR H=C3=A5kon L=C3=B8vdal
