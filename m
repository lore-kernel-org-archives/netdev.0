From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Huaei E3131 - status
Date: Wed, 03 Jul 2013 10:15:32 +0200
Message-ID: <871u7gvz2z.fsf@nemi.mork.no>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
	<87wqp9xja5.fsf@nemi.mork.no>
	<alpine.LNX.2.02.1307021855270.19053@eeeadesso>
	<alpine.LNX.2.02.1307022202570.26010@eeeadesso>
	<alpine.LNX.2.02.1307022207060.26010@eeeadesso>
	<alpine.LNX.2.02.1307022210470.26010@eeeadesso>
	<alpine.LNX.2.02.1307022213380.26010@eeeadesso>
	<alpine.LNX.2.02.1307030836270.12831@eeeadesso>
	<alpine.LNX.2.02.1307030908090.13789@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52222 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755262Ab3GCIPz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 04:15:55 -0400
In-Reply-To: <alpine.LNX.2.02.1307030908090.13789@eeeadesso> (Enrico Mioso's
	message of "Wed, 3 Jul 2013 09:11:19 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> Ok ... As Bjorn stated, cdc-wdm is handling the notifications now - o=
r, better:=20
> is not handling them, as it is not made to do these things! The conne=
ction=20
> stays up and the character device seems to work properly. Obviously c=
dc-wdm=20
> notices me about one single unknown notifications.
> We're ignoring all the notifications from the NCM erspective, but all=
 works=20
> because the device probably doesn't rely on them so much.
> Aniway - now I'm conscious about why it works. Now it's time to impro=
ve the=20
> situation of the driver, and might be the api. Waiting for suggestion=
s and=20
> injuries! :)

The only notification actually used for anything by cdc_ncm is
USB_CDC_NOTIFY_NETWORK_CONNECTION, which it uses to set the link up or
down. That functionality is disabled in your driver, leaving the link
always up.

This is of course not entirely correct if we apply a strict NCM
specification to this driver. But it does no harm either.  You have
added support for the embedded management channel, which must be used t=
o
configure and connect the device.  Connection status will also be
reported here, and the managing userspace application (for example
ModemManager) will use this to pick up the actual network connection
state.  So the link state reported by NCM is redundant for these
devices.

The issue is that the few simple notifications standardized in CDC NCM
are sufficient for management of ethernet connections, but not for
3G/LTE connections.  That's why you need access to the additional vendo=
r
specific management channel in the first place.  And when you have that
channel, then the additional NCM notifications are redundant at best.
Or confusing at worst.

The second notification implemented by cdc_ncm is
USB_CDC_NOTIFY_SPEED_CHANGE, which is shown in your logs.  But there is
nothing cdc_ncm can do with this, so it will just log it.  That's mostl=
y
useless, both for wired and wireless devices.  3G/LTE management
applications will pick up the same information via the appropriate
management channel instead.

So the main reason why you should implement support for these
notifications eventually is not so much to handle them, but to silence
cdc-wdm. It will otherwise complain, which will confuse some users.  Bu=
t
this is a really minor issue, and I see no reason why it should hold
back this driver.  It is perfectly usable as it is, and all necessary
features are implemented.


Bj=C3=B8rn
