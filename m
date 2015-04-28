From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next v3 0/4] net: Introduce IFF_PROTO_DOWN flag.
Date: Tue, 28 Apr 2015 12:37:46 -0700
Message-ID: <CAE4R7bAbe34eOqfdEUqNAp57936Eqcu54+r_Bp75CDdB4FgThw@mail.gmail.com>
References: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
	<CAE4R7bAGRKGShQuSqjvQDW8cG6MHE8Jie7Hp=7FJw00kJM4NgQ@mail.gmail.com>
	<CACcJQnRw5HVUb0M3A2u_zbMtp85pi+kdCUa5gaY6cN4HXpVyeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:33072 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031031AbbD1Thr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 15:37:47 -0400
Received: by qgdy78 with SMTP id y78so2477661qgd.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 12:37:46 -0700 (PDT)
In-Reply-To: <CACcJQnRw5HVUb0M3A2u_zbMtp85pi+kdCUa5gaY6cN4HXpVyeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 8:39 AM, Anuradha Karuppiah
<anuradhak@cumulusnetworks.com> wrote:
>
>
> On Mon, Apr 27, 2015 at 10:45 PM, Scott Feldman <sfeldma@gmail.com> w=
rote:
>>
>> On Mon, Apr 27, 2015 at 10:38 AM,  <anuradhak@cumulusnetworks.com> w=
rote:
>> > From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>> >
>> > User space daemons can detect errors in the network that need to b=
e
>> > notified to the switch device drivers.
>> >
>> > Drivers can react to this error state by doing a phy-down on the
>> > switch-port which would result in a carrier-off locally and on the
>> > directly connected switch. Doing that would prevent loops and
>> > black-holes in the network.
>>
>> (Sorry if this was asked earlier)
>>
>> Can the application simply send a SETLINK with IFF_UP clear and the
>> port driver's ndo_stop would bring the PHY link down?
>
>
> Yes, Clearing IFF_UP on detecting errors (PROTO_DOWN) is possible and=
 we
> tried
> that implementation as well. Unfortunately it failed because of the
> following
> reasons -
>
> 1. There is no way to disambiguate between admin_down (!IFF_UP) and a=
n
> APP/driver enforced error_down (IFF_PROTO_DOWN). Administrator or
> automation-scripts that monitor the config assumed that switch-port
> configuration had somehow fallen out of sync (and attempted to reinst=
ate the
> admin_up repeatedly).
>
> 2. Automatic error recovery was not possible; consider the following
> scenario
> for e.g.
>    a. The MLAG peer-link is down so the MLAG app on the secondary swi=
tch has
>       proto_down=E2=80=99ed all the MLAG ports (including switch-port=
 swp1) by
> clearing
>       IFF_UP.
>    b. At the same time the administrator is in the process of making =
some
>       changes on the network connected to swp1. To avoid doing it liv=
e he
> would
>       admin_disable swp1 (!IFF_UP) by doing an "ip link set swp1 down=
" (this
>       is a no-op as event #a has already cleared IFF_UP on swp1).
>    c. If the MLAG peer-link recovers at this point the MLAG app on th=
e
>       secondary switch would try to automatically recover the MLAG po=
rts
>       by clearing proto_down (i.e. setting IFF_UP); including on swp1=
=2E Doing
>       that overrides the administrator=E2=80=99s directive to keep sw=
p1 admin_down.
>       Overriding an admin-down in a live network can be very dangerou=
s so it
>       is not possible to do auto-error-recovery unless we have a way =
to
>       disambiguate between the admin and error states

That makes sense.

Dang, this is so close to IFF_DORMANT.  The interface can be IFF_UP
and link mode can be DORMANT.  Can the port driver kill PHY link if
dev->flags&IFF_DORMANT in ndo_set_rx_mode()?  Would require
IFF_DORMANT is included in dev->flags in __dev_change_flags().
