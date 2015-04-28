From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next v3 0/4] net: Introduce IFF_PROTO_DOWN flag.
Date: Tue, 28 Apr 2015 08:43:51 -0700
Message-ID: <CACcJQnSeyVpLHAfFOh+oWfVNvOMzv5J68HmVucS0ncXDpsFY5w@mail.gmail.com>
References: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
	<CAE4R7bAGRKGShQuSqjvQDW8cG6MHE8Jie7Hp=7FJw00kJM4NgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:33300 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030276AbbD1Pnx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 11:43:53 -0400
Received: by layy10 with SMTP id y10so107702719lay.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 08:43:51 -0700 (PDT)
In-Reply-To: <CAE4R7bAGRKGShQuSqjvQDW8cG6MHE8Jie7Hp=7FJw00kJM4NgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2015 at 10:45 PM, Scott Feldman <sfeldma@gmail.com> wro=
te:
> On Mon, Apr 27, 2015 at 10:38 AM,  <anuradhak@cumulusnetworks.com> wr=
ote:
>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>
>> User space daemons can detect errors in the network that need to be
>> notified to the switch device drivers.
>>
>> Drivers can react to this error state by doing a phy-down on the
>> switch-port which would result in a carrier-off locally and on the
>> directly connected switch. Doing that would prevent loops and
>> black-holes in the network.
>
> (Sorry if this was asked earlier)
>
> Can the application simply send a SETLINK with IFF_UP clear and the
> port driver's ndo_stop would bring the PHY link down?

(Re-sending as plain text) -

Yes, Clearing IFF_UP on detecting errors (PROTO_DOWN) is possible and w=
e tried
that implementation as well. Unfortunately it failed because of the fol=
lowing
reasons -

1. There is no way to disambiguate between admin_down (!IFF_UP) and an
APP/driver enforced error_down (IFF_PROTO_DOWN). Administrator or
automatation-scripts that monitor the config assumed that switch-port
configuration had somehow fallen out of sync (and attempted to reinstat=
e the
admin_up repeatedly).

2. Automatic error recovery was not possible; consider the following sc=
enario
for e.g.
   a. The MLAG peer-link is down so the MLAG app on the secondary switc=
h has
      proto_down=E2=80=99ed all the MLAG ports (including switch-port s=
wp1) by clearing
      IFF_UP.
   b. At the same time the administrator is in the process of making so=
me
      changes on the network connected to swp1. To avoid doing it live =
he would
      admin_disable swp1 (!IFF_UP) by doing an "ip link set swp1 down" =
(this
      is a no-op as event #a has already cleared IFF_UP on swp1).
   c. If the MLAG peer-link recovers at this point the MLAG app on the
      secondary switch would try to automatically recover the MLAG port=
s
      by clearing proto_down (i.e. setting IFF_UP); including on swp1. =
Doing
      that overrides the administrator=E2=80=99s directive to keep swp1=
 admin_down.
      Overriding an admin-down in a live network can be very dangerous =
so it
      is not possible to do auto-error-recovery unless we have a way to
      disambiguate between the admin and error states.
