From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next v3 0/4] net: Introduce IFF_PROTO_DOWN flag.
Date: Tue, 28 Apr 2015 13:04:41 -0700
Message-ID: <CACcJQnSZJGU2ohYo=NKjiyo3n0rX-0SP2Aupt74ONbvY7aE33A@mail.gmail.com>
References: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
	<CAE4R7bAGRKGShQuSqjvQDW8cG6MHE8Jie7Hp=7FJw00kJM4NgQ@mail.gmail.com>
	<CACcJQnRw5HVUb0M3A2u_zbMtp85pi+kdCUa5gaY6cN4HXpVyeQ@mail.gmail.com>
	<CAE4R7bAbe34eOqfdEUqNAp57936Eqcu54+r_Bp75CDdB4FgThw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:35596 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031023AbbD1UEo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:04:44 -0400
Received: by labbd9 with SMTP id bd9so4662575lab.2
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:04:41 -0700 (PDT)
In-Reply-To: <CAE4R7bAbe34eOqfdEUqNAp57936Eqcu54+r_Bp75CDdB4FgThw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 12:37 PM, Scott Feldman <sfeldma@gmail.com> wro=
te:
> On Tue, Apr 28, 2015 at 8:39 AM, Anuradha Karuppiah
> <anuradhak@cumulusnetworks.com> wrote:
>>
>>
>> On Mon, Apr 27, 2015 at 10:45 PM, Scott Feldman <sfeldma@gmail.com> =
wrote:
>>>
>>> On Mon, Apr 27, 2015 at 10:38 AM,  <anuradhak@cumulusnetworks.com> =
wrote:
>>> > From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>> >
>>> > User space daemons can detect errors in the network that need to =
be
>>> > notified to the switch device drivers.
>>> >
>>> > Drivers can react to this error state by doing a phy-down on the
>>> > switch-port which would result in a carrier-off locally and on th=
e
>>> > directly connected switch. Doing that would prevent loops and
>>> > black-holes in the network.
>>>
>>> (Sorry if this was asked earlier)
>>>
>>> Can the application simply send a SETLINK with IFF_UP clear and the
>>> port driver's ndo_stop would bring the PHY link down?
>>
>>
>> Yes, Clearing IFF_UP on detecting errors (PROTO_DOWN) is possible an=
d we
>> tried
>> that implementation as well. Unfortunately it failed because of the
>> following
>> reasons -
>>
>> 1. There is no way to disambiguate between admin_down (!IFF_UP) and =
an
>> APP/driver enforced error_down (IFF_PROTO_DOWN). Administrator or
>> automation-scripts that monitor the config assumed that switch-port
>> configuration had somehow fallen out of sync (and attempted to reins=
tate the
>> admin_up repeatedly).
>>
>> 2. Automatic error recovery was not possible; consider the following
>> scenario
>> for e.g.
>>    a. The MLAG peer-link is down so the MLAG app on the secondary sw=
itch has
>>       proto_down=E2=80=99ed all the MLAG ports (including switch-por=
t swp1) by
>> clearing
>>       IFF_UP.
>>    b. At the same time the administrator is in the process of making=
 some
>>       changes on the network connected to swp1. To avoid doing it li=
ve he
>> would
>>       admin_disable swp1 (!IFF_UP) by doing an "ip link set swp1 dow=
n" (this
>>       is a no-op as event #a has already cleared IFF_UP on swp1).
>>    c. If the MLAG peer-link recovers at this point the MLAG app on t=
he
>>       secondary switch would try to automatically recover the MLAG p=
orts
>>       by clearing proto_down (i.e. setting IFF_UP); including on swp=
1. Doing
>>       that overrides the administrator=E2=80=99s directive to keep s=
wp1 admin_down.
>>       Overriding an admin-down in a live network can be very dangero=
us so it
>>       is not possible to do auto-error-recovery unless we have a way=
 to
>>       disambiguate between the admin and error states
>
> That makes sense.
>
> Dang, this is so close to IFF_DORMANT.  The interface can be IFF_UP
> and link mode can be DORMANT.  Can the port driver kill PHY link if
> dev->flags&IFF_DORMANT in ndo_set_rx_mode()?  Would require
> IFF_DORMANT is included in dev->flags in __dev_change_flags().

Yes, IFF_DORMANT does seem close to what is needed; in the current/stan=
dard
interpretation IFF_DORMANT keeps the switch port phy-up and running (an=
d most
PDUs are also exchanged in the dormant state). Like you said we could
re-interpret IFF_DORMANT in this context to phy-down the switch-port;
unfortunately we are already using IFF_DORMANT as well (in its standard
interpretation)...

We are using the dormant mode (for the MLAG app itself) to hold the MLA=
G port
in a brief/transition-ary suspended state when the switch-port link/car=
rier up
happens. This has been done to co-ordinate states across the MLAG peer =
switches
and to ensure that egress port block masks are programmed on the peer s=
witch
before transitioning the local switch port to an OPER_UP state. If we d=
idn't do
that the dual-connected server would see duplicate packets every time a
link-down to link-up happened on a MLAG port.

So IFF_DORMANT re-interpretation is not going to be easily possible for=
 the
MLAG use case.
