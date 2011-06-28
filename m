From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Tue, 28 Jun 2011 19:34:57 +0100
Message-ID: <BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
References: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
	<20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
	<BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
	<20110624120859.3c43bbcb@nehalam.ftrdhcpuser.net>
	<BANLkTin4XOCmpFaETsjkYb2kk+psZUBKcA@mail.gmail.com>
	<BANLkTimD+fvhrhpc+kPXt1qMnQvVi2dw=Q@mail.gmail.com>
	<20110628150257.GB126252@jupiter.n2.diac24.net>
	<20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
	<20110628160018.GC126252@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:49050 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760801Ab1F1Se6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 14:34:58 -0400
Received: by pwj7 with SMTP id 7so320084pwj.19
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2011 11:34:57 -0700 (PDT)
In-Reply-To: <20110628160018.GC126252@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 June 2011 17:00, David Lamparter <equinox@diac24.net> wrote:
> On Tue, Jun 28, 2011 at 08:10:15AM -0700, Stephen Hemminger wrote:
>> On Tue, 28 Jun 2011 17:02:57 +0200
>> David Lamparter <equinox@diac24.net> wrote:
>> > > =A0 if (skb) {
>> > > + =A0 =A0 =A0 =A0 /* Prevent Crosstalk where a Supplicant on one=
 Port attempts to
>> > > + =A0 =A0 =A0 =A0 =A0* interfere with authentications occurring =
on another Port.
>> > > + =A0 =A0 =A0 =A0 =A0* (IEEE Std 802.1X-2001 C.3.3)
>> > > + =A0 =A0 =A0 =A0 =A0*/
>> > > + =A0 =A0 =A0 =A0 if (unlikely(!br->pae_forward &&
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 skb->protocol =3D=3D htons(ETH_P_PAE))=
)
>> >
>> > No, please don't.
>> >
>> > Linux bridging has two "grand" modes: dumb and STP enabled.
>> >
>> > If we're running a dumb bridge, we behave like an ethernet hub wit=
hout
>> > any intelligence, and in that case we should absolutely forward 80=
2.1X
>> > frames. We may have (e.g. VM) client(s) that want to authenticate =
with a
>> > physical switch.
>> > (For the spec, this counts as "repeater", not "bridge"/"switch")
>> >
>> > If we're running with STP enabled, then 802.1X traffic should alre=
ady be
>> > caught by the general ethernet link-local multicast drop (which ap=
plies
>> > to 01:80:c2:/24 and therefore catches 802.1X too.)
>>
>> The problem is that STP is not enabled by default, and most people d=
on't
>> know how to enable it.
>
> Yes, the default is a dumb hub (IMHO correctly so). And a dumb hub wi=
ll
> forward 802.1X packets (IMHO also correctly so).
>
> Why should we specifically add a knob for EAPOL? Next we're adding on=
e
> for STP itself, then one for LLDP, then one for Cisco's deprecated
> crap (CDP, DTP, ...) etc.
>
> If you want a dumb hub that drops EAPOL, use ebtables.
>
> -David
>
>
If we are not going to have an EAPOL knob, but we are going to act as
a repeater when STP is off then we still need these diffs to forward
the PAE group address.
(In fact we cant just act as a repeater because of the recent ethernet
bonding regression)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 90e985b..267f581 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -163,7 +163,8 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb=
)
                        goto drop;

                /* If STP is turned off, then forward */
-               if (p->br->stp_enabled =3D=3D BR_NO_STP && dest[5] =3D=3D=
 0)
+               if (p->br->stp_enabled =3D=3D BR_NO_STP &&
+                       (dest[5] =3D=3D 0 || skb->protocol =3D=3D htons=
(ETH_P_PAE)))
                        goto forward;
Nick
