From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next v3 0/4] net: Introduce IFF_PROTO_DOWN flag.
Date: Wed, 29 Apr 2015 15:04:09 -0700
Message-ID: <CACcJQnSmQQtZoPAEOwAGsvaLHzb4_fU2dxrgAXDXAjHsgkaFhA@mail.gmail.com>
References: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
	<CAE4R7bAGRKGShQuSqjvQDW8cG6MHE8Jie7Hp=7FJw00kJM4NgQ@mail.gmail.com>
	<CACcJQnRw5HVUb0M3A2u_zbMtp85pi+kdCUa5gaY6cN4HXpVyeQ@mail.gmail.com>
	<CAE4R7bAbe34eOqfdEUqNAp57936Eqcu54+r_Bp75CDdB4FgThw@mail.gmail.com>
	<CACcJQnSZJGU2ohYo=NKjiyo3n0rX-0SP2Aupt74ONbvY7aE33A@mail.gmail.com>
	<CAE4R7bC6tchoeSz+N82s_3h62tSUujx0+aCD_HBhjNBRixv17A@mail.gmail.com>
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
Received: from mail-la0-f45.google.com ([209.85.215.45]:35971 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbbD2WEL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:04:11 -0400
Received: by lagv1 with SMTP id v1so30675949lag.3
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:04:10 -0700 (PDT)
In-Reply-To: <CAE4R7bC6tchoeSz+N82s_3h62tSUujx0+aCD_HBhjNBRixv17A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 5:28 PM, Scott Feldman <sfeldma@gmail.com> wrot=
e:
> On Tue, Apr 28, 2015 at 1:04 PM, Anuradha Karuppiah
> <anuradhak@cumulusnetworks.com> wrote:
>> On Tue, Apr 28, 2015 at 12:37 PM, Scott Feldman <sfeldma@gmail.com> =
wrote:
>>> On Tue, Apr 28, 2015 at 8:39 AM, Anuradha Karuppiah
>>> <anuradhak@cumulusnetworks.com> wrote:
>>>>
>>>>
>>>> On Mon, Apr 27, 2015 at 10:45 PM, Scott Feldman <sfeldma@gmail.com=
> wrote:
>>>>>
>>>>> On Mon, Apr 27, 2015 at 10:38 AM,  <anuradhak@cumulusnetworks.com=
> wrote:
>>>>> > From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>>>> >
>>>>> > User space daemons can detect errors in the network that need t=
o be
>>>>> > notified to the switch device drivers.
>>>>> >
>>>>> > Drivers can react to this error state by doing a phy-down on th=
e
>>>>> > switch-port which would result in a carrier-off locally and on =
the
>>>>> > directly connected switch. Doing that would prevent loops and
>>>>> > black-holes in the network.
>>>>>
>>>>> (Sorry if this was asked earlier)
>>>>>
>>>>> Can the application simply send a SETLINK with IFF_UP clear and t=
he
>>>>> port driver's ndo_stop would bring the PHY link down?
>>>>
>>>>
>>>> Yes, Clearing IFF_UP on detecting errors (PROTO_DOWN) is possible =
and we
>>>> tried
>>>> that implementation as well. Unfortunately it failed because of th=
e
>>>> following
>>>> reasons -
>>>>
>>>> 1. There is no way to disambiguate between admin_down (!IFF_UP) an=
d an
>>>> APP/driver enforced error_down (IFF_PROTO_DOWN). Administrator or
>>>> automation-scripts that monitor the config assumed that switch-por=
t
>>>> configuration had somehow fallen out of sync (and attempted to rei=
nstate the
>>>> admin_up repeatedly).
>>>>
>>>> 2. Automatic error recovery was not possible; consider the followi=
ng
>>>> scenario
>>>> for e.g.
>>>>    a. The MLAG peer-link is down so the MLAG app on the secondary =
switch has
>>>>       proto_down=E2=80=99ed all the MLAG ports (including switch-p=
ort swp1) by
>>>> clearing
>>>>       IFF_UP.
>>>>    b. At the same time the administrator is in the process of maki=
ng some
>>>>       changes on the network connected to swp1. To avoid doing it =
live he
>>>> would
>>>>       admin_disable swp1 (!IFF_UP) by doing an "ip link set swp1 d=
own" (this
>>>>       is a no-op as event #a has already cleared IFF_UP on swp1).
>>>>    c. If the MLAG peer-link recovers at this point the MLAG app on=
 the
>>>>       secondary switch would try to automatically recover the MLAG=
 ports
>>>>       by clearing proto_down (i.e. setting IFF_UP); including on s=
wp1. Doing
>>>>       that overrides the administrator=E2=80=99s directive to keep=
 swp1 admin_down.
>>>>       Overriding an admin-down in a live network can be very dange=
rous so it
>>>>       is not possible to do auto-error-recovery unless we have a w=
ay to
>>>>       disambiguate between the admin and error states
>>>
>>> That makes sense.
>>>
>>> Dang, this is so close to IFF_DORMANT.  The interface can be IFF_UP
>>> and link mode can be DORMANT.  Can the port driver kill PHY link if
>>> dev->flags&IFF_DORMANT in ndo_set_rx_mode()?  Would require
>>> IFF_DORMANT is included in dev->flags in __dev_change_flags().
>>
>> Yes, IFF_DORMANT does seem close to what is needed; in the current/s=
tandard
>> interpretation IFF_DORMANT keeps the switch port phy-up and running =
(and most
>> PDUs are also exchanged in the dormant state). Like you said we coul=
d
>> re-interpret IFF_DORMANT in this context to phy-down the switch-port=
;
>> unfortunately we are already using IFF_DORMANT as well (in its stand=
ard
>> interpretation)...
>
> That makes sense; best to not confuse IFF_DORMANT with this new need.
>
>> We are using the dormant mode (for the MLAG app itself) to hold the =
MLAG port
>> in a brief/transition-ary suspended state when the switch-port link/=
carrier up
>> happens. This has been done to co-ordinate states across the MLAG pe=
er switches
>> and to ensure that egress port block masks are programmed on the pee=
r switch
>> before transitioning the local switch port to an OPER_UP state. If w=
e didn't do
>> that the dual-connected server would see duplicate packets every tim=
e a
>> link-down to link-up happened on a MLAG port.
>
> How can we see this in action?  I didn't find where the kernel egress
> blocks the port when dormant.  What are the requirements for a kernel
> port driver to support your MLAG app?  Is this MLAG app available
> somewhere?

Traffic forwarding on local dormant switch ports is being done implicit=
ly by
using MSTP which puts !OPER_UP (OPER_DOWN, OPER_DORMANT) ports in an ST=
P
disabled/blocking state. Egress traffic blocking is really needed on th=
e peer
switch to prevent the traffic from the peer link being sent again to
the server.We are using
ebtables for this purpose currently so there are no additional kernel
requirements.

=46urther details on the MLAG app can also be found at -
https://www.netdev01.org/sessions/23

We are actively working on consolidating the MLAG app and making it ava=
ilable
for everybody's use soon. Getting proto_down out was part of that proce=
ss.

PROTO_DOWN also has other use cases - like a link-dampening app which c=
an
monitor (and proto_down) flapping or otherwise-misbehaving switch ports=
 and
attempt paced/periodic auto-recovery.
