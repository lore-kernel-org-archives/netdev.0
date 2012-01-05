From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 3/3] qmi_wwan: Driver for WWAN devices requiring use of the QMI protocol
Date: Thu, 05 Jan 2012 09:58:11 +0100
Message-ID: <87r4zey198.fsf@nemi.mork.no>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
	<1323750784-32608-4-git-send-email-bjorn@mork.no>
	<1323882501.2077.3.camel@dcbw.foobar.com>
	<87r506b1ap.fsf@nemi.mork.no>
	<1323971530.23419.13.camel@dcbw.foobar.com>
	<874nx0bj1d.fsf@nemi.mork.no>
	<1324055842.17587.18.camel@dcbw.foobar.com>
	<1325710654.7269.42.camel@d430>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38924 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714Ab2AEI6t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 03:58:49 -0500
In-Reply-To: <1325710654.7269.42.camel@d430> (Dan Williams's message of "Wed,
	04 Jan 2012 14:57:34 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:

> I spent some time with the Pantech UML290 (a dual-mode CDMA/LTE devic=
e
> based off MSM9xxx) and its network port is basically the same as the
> Huawei and the Gobi devices; it uses control transfers for the QMI
> commands and bulk transfers for the network data.  Interestingly, the
> UML290 uses the "rawip" mode instead of 802.3 mode, so the incoming a=
nd
> outgoing data is simply raw IP packets.

Interesting.  I assume that's the mode I have been seeing under certain
circumstances too.  But I've not yet discovered how to enable/disable
it.

> The IPv4 and IPv6 addresses of
> the interface are determined either through QMI requests (IPv4) or
> through WMC requests on a separate port (IPv6).  I'm hopeful that we
> could switch the device over to 802.3 mode by just sending the right =
QMI
> TLV as part of the CTL/Set Data Format command (0x26) using TLV 0x01
> (CTL/Set Data Format Request/Format) and TLV 0x10 (CTL/Set Data Forma=
t
> Request/Protocol).  But I'm not sure, I haven't tried it yet, and it'=
s
> obviously not something that Pantech is actually testing otherwise th=
e
> Windows driver would use 802.3 mode.

So the Windows driver uses this mode?  Then it could be something the
vendor chooses when building the firmware, and therefore not runtime
configurable at all.

> But what this says to me is that we do need a generic QMI driver for
> devices that handles the network traffic and also QMI passthrough.  A=
nd
> then separate interface drivers that handle the USB-level quirks like
> your Huawei driver.  We already have the "gobi_net" driver that Elly
> Jones from Google cleaned up back in 2009, but it's not split out lik=
e
> you've done here and I haven't looked into what changes would need to=
 be
> done for that.

I have barely started looking at this, but christmas and a beach
vacation have been far more interesting lately :-)

> I'm still somewhat uncomfortable with the amount of QMI logic in this
> driver though, given that for the most part, we try to keep this sort=
 of
> stuff out of the kernel and in userland.  It also gives the wrong
> impression that the interface can actually be used like a normal
> interface, where for the most part it cannot unless there is addition=
al
> control logic in userspace.  I don't view it as any different from
> AT-based WWAN devices in this regard and I think treating it differen=
tly
> from them is not the right approach.

Yes, agree fully that my first draft had too much QMI logic built-in.  =
I
do want to keep the bare minimum to make the driver work out-of-the-box
with "ip link set dev wwanX up", but nothing more than that.

I started thinking about just exporting the raw embedded protocol as a
char device, making the exported device completely protocol agnostic
(just a wrapper around USB_CDC_SEND_ENCAPSULATED_COMMAND/
USB_CDC_GET_ENCAPSULATED_RESPONSE, ignoring the contents).  But this
would not allow multiplexing more than one client.   Therefore I added =
a
bit of QMI logic to allow multiple simultaneous clients, multiplexing b=
y
the transaction ID.  This allows the wwan driver to act as a QMI client
and at the same time have multiple clients using the char device
interface.

I have a working demo of this, but the current state of the code is so
bad that I'm hesitating posting it publicly. It needs a lot of cleanup,
and I want to split out the remaining QMI parts from what's now become =
a
generic CDC encapsulated command/response interface.



Bj=C3=B8rn
